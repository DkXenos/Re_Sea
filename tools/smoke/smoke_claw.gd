## Headless smoke test for the claw phase. Plays a whole day of grabbing and
## reports what ended up in the inventory.
##   godot --headless --script tools/smoke/smoke_claw.gd
##
## The script passed to --script is compiled before the autoloads are
## registered, so Game and Events are fetched from the tree rather than named
## directly. Scripts inside the scenes compile later and use them normally.
extends SceneTree

var finished := false


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	var events: Node = root.get_node("/root/Events")
	game.start_run(12345)
	events.phase_finished.connect(func() -> void: finished = true)
	var phase: Node = load("res://scenes/claw/claw_phase.tscn").instantiate()
	root.add_child(phase)
	await physics_frame
	await physics_frame
	var world: Node = phase.get_node("TankLayer/TankContainer/TankViewport/TankWorld")
	var claw: Node2D = world.get_node("Claw")
	var items: Node2D = world.get_node("Items")
	print("spawned items=%d fish=%d max_grabs=%d" % [items.get_child_count(),
		world.get_node("FishHolder").get_child_count(), game.current_day().max_grabs])
	# Modes: default aims at items; --fish aims at fish; --fail forces every
	# grip roll to fail so the slip-on-the-way-up path is exercised.
	var args := OS.get_cmdline_user_args()
	var aim_fish := "--fish" in args
	if "--fail" in args:
		game.force_grip = -1
	var target_holder: Node2D = world.get_node("FishHolder") if aim_fish else items
	var guard := 0
	while not finished and guard < 6000:
		guard += 1
		await physics_frame
		if claw.state == 0 and claw.can_drop:
			if target_holder.get_child_count() > 0:
				claw.position.x = clampf(target_holder.get_child(0).position.x,
					claw.min_x, claw.max_x)
			claw.start_drop()
	print("finished=%s frames=%d inventory=%d fish=%d grabs_used=%d items_left=%d" %
		[finished, guard, game.inventory.size(), game.stats["fish"],
		game.stats["grabs_used"], items.get_child_count()])
	for e in game.inventory:
		print("   carried %s (weight %.1f, grip %d%%)" % [e.data.id, e.data.weight,
			int(round(clampf(1.0 - e.data.weight * 0.15, 0.25, 0.95) * 100.0))])
	# This harness quits mid-frame, so release any sound still playing rather
	# than letting Godot report it as a leaked stream.
	game.stop_all_sfx()
	await process_frame
	quit()
