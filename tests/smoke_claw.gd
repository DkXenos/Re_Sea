# plays a whole day of grabbing, prints what ended up in the inventory.
#   godot --headless --script tests/smoke_claw.gd
#
# NOTE the --script file compiles before the autoloads register, so Game and
# Events have to come off the tree here instead of by name. scripts inside the
# scenes compile later and can use them normally.
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
	print("seeded items=%d background fish=%d budget=%d (drop costs %d)" %
		[items.get_child_count(), world.get_node("FishHolder").get_child_count(),
		game.budget_left, game.cost_of(&"drop")])
	# Fish are background now: no Area2D anywhere in the fish holder, so the
	# claw physically cannot catch one.
	for f in world.get_node("FishHolder").get_children():
		assert(not (f is Area2D), "fish must not be an Area2D any more")
		assert(f.get_node_or_null("Shape") == null, "fish must have no collision shape")
	await _check_targeting_promise(game, claw, items)

	# --fail forces every grip roll to fail so the slip-on-the-way-up path is
	# exercised.
	var args := OS.get_cmdline_user_args()
	if "--fail" in args:
		game.force_grip = -1
	var target_holder: Node2D = items
	var guard := 0
	while not finished and guard < 6000:
		guard += 1
		await physics_frame
		if claw.state == 0 and claw.can_drop:
			if target_holder.get_child_count() > 0:
				claw.position.x = clampf(target_holder.get_child(0).position.x,
					claw.min_x, claw.max_x)
			claw.start_drop()
	print("finished=%s frames=%d inventory=%d drops=%d budget_left=%d items_left=%d" %
		[finished, guard, game.inventory.size(), game.stats["drops"],
		game.budget_left, items.get_child_count()])
	for e in game.inventory:
		print("   carried %s (weight %.1f, grip %d%%)" % [e.data.id, e.data.weight,
			int(round(clampf(1.0 - e.data.weight * 0.15, 0.25, 0.95) * 100.0))])
	# This harness quits mid-frame, so release any sound still playing rather
	# than letting Godot report it as a leaked stream.
	game.stop_all_sfx()
	await process_frame
	quit()


# the % shown before a drop has to belong to the item that actually comes up.
# two items crowded together is the case that used to break - preview measured
# horizontal distance to the claw origin, grab measured distance to the grab
# point, so it named the neighbour.
func _check_targeting_promise(game: Node, claw: Node2D, items: Node2D) -> void:
	if items.get_child_count() < 2:
		return
	var previous_force: int = game.force_grip
	game.force_grip = 1
	# Deliberately set up so the two rules disagree: `closest_in_x` sits nearer
	# the claw horizontally, but `contacted_first` sits high enough that the
	# descending grab circle reaches it sooner. The old preview named
	# closest_in_x; the claw brought up contacted_first.
	var closest_in_x: Node2D = items.get_child(0)
	var contacted_first: Node2D = items.get_child(1)
	closest_in_x.position = Vector2(600.0, 300.0)
	closest_in_x.home_y = closest_in_x.position.y
	contacted_first.position = Vector2(650.0, 262.0)
	contacted_first.home_y = contacted_first.position.y
	claw.position.x = 612.0
	await physics_frame

	var predicted: Node2D = claw.predict_target(items.get_children())
	assert(predicted != null, "prediction found nothing with two items in reach")
	assert(predicted == contacted_first,
		"prediction fell back to nearest-in-x instead of first-contacted")
	claw.predicted_target = predicted
	# The phase frees the grabbed node as soon as the cycle ends, so record its
	# identity inside the callback rather than comparing freed references.
	var predicted_id: int = predicted.get_instance_id()
	var predicted_name: String = String(predicted.data.id)
	var grabbed: Array = []
	claw.cycle_finished.connect(func(result: Dictionary) -> void:
		var node: Node = result.get("node", null)
		grabbed.append(node.get_instance_id() if is_instance_valid(node) else 0),
		CONNECT_ONE_SHOT)
	claw.start_drop()
	var guard := 0
	while grabbed.is_empty() and guard < 4000:
		guard += 1
		await physics_frame
	assert(not grabbed.is_empty(), "the claw never finished its cycle")
	assert(grabbed[0] == predicted_id,
		"the grip preview named a different item than the claw brought up")
	print("targeting promise: preview named %s, and the claw returned that node" %
		predicted_name)
	game.force_grip = previous_force
