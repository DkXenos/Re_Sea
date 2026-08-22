## Plays the entire game headlessly through the real main.tscn: menu, cutscene,
## five days of claw and desk, a report after each, then the ending.
##   godot --headless --script tools/smoke/smoke_full.gd
extends SceneTree

var game: Node
var main: Node
var bad_mode := false
var verbose := false


func _init() -> void:
	_run()


func _current() -> Node:
	var holder: Node = main.get_node("SceneHolder")
	return holder.get_child(0) if holder.get_child_count() > 0 else null


func _run() -> void:
	await process_frame
	# Headless physics still ticks in real time, so a full five-day run takes
	# well over a minute at 1x. Scaling time compresses the same simulated run
	# into far fewer frames; the claw's descent step stays well inside the
	# grab-area overlap window, so nothing is skipped.
	# Pass --realtime when the numbers matter (balance checks); the scaled run
	# is a different but equally valid simulation, since where the claw stops
	# during a coarser descent step changes which item it contacts.
	Engine.time_scale = 1.0 if "--realtime" in OS.get_cmdline_user_args() else 6.0
	bad_mode = "--bad" in OS.get_cmdline_user_args()
	verbose = "--verbose-days" in OS.get_cmdline_user_args()
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	main = load("res://main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var seen: Array[String] = []
	var guard := 0
	while guard < 40000:
		guard += 1
		await physics_frame
		var scene: Node = _current()
		if scene == null:
			continue
		var kind := scene.name
		if seen.is_empty() or seen[-1] != String(kind) + "|" + str(game.day_index):
			seen.append(String(kind) + "|" + str(game.day_index))
			print("-> %-10s day_index=%d health=%d" % [kind, game.day_index, game.ocean_health])
		match String(kind):
			"MainMenu":
				scene.get_node("UiLayer/Root/Buttons/PlayButton").pressed.emit()
			"Cutscene":
				scene._finish()
			"DayStart":
				scene.get_node("UiLayer/Root/BeginButton").pressed.emit()
			"ClawPhase":
				_drive_claw(scene)
			"DeskPhase":
				_drive_desk(scene)
			"DayReport":
				if verbose:
					var b: Dictionary = scene._result
					print("     quota %d, sorted %d, correct %d, wrong %d, "
						% [b["quota"], b["sorted"], b["correct"], b["wrong"]]
						+ "shortfall -%d, clean +%d, delta %+d"
						% [b["shortfall"], b["clean_bonus"], b["delta"]])
				scene.get_node("UiLayer/Root/NextButton").pressed.emit()
			"GameOver":
				print("reached ending: health=%d title=%s" % [game.ocean_health,
					scene.get_node("UiLayer/Root/TitleLabel").text])
				break
	print("frames=%d  scenes visited=%d" % [guard, seen.size()])
	assert(String(_current().name) == "GameOver", "run did not reach an ending")
	if bad_mode:
		assert(game.ocean_health == 0, "sorting everything wrong should bottom out the ocean")
	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


func _drive_claw(scene: Node) -> void:
	var world: Node = scene.get_node("TankLayer/TankContainer/TankViewport/TankWorld")
	var claw: Node2D = world.get_node("Claw")
	var items: Node2D = world.get_node("Items")
	if claw.state != 0 or not claw.can_drop:
		return
	if items.get_child_count() > 0:
		claw.position.x = clampf(items.get_child(0).position.x, claw.min_x, claw.max_x)
	claw.start_drop()


## Sorts using the same resolver the game judges with, so the run survives to
## day 5 and the win ending is reached rather than the loss ending.
func _drive_desk(scene: Node) -> void:
	var inspect: Control = scene.get_node("UiLayer/Root/InspectPanel")
	var bins: Control = scene.get_node("UiLayer/Root/BinRow")
	var entry = inspect.entry
	if entry == null:
		return
	var day = game.current_day()
	var choice: int = int(RuleChecker.resolve(entry.data, day.active_rules)["category"])
	if bad_mode:
		choice = (choice + 1) % 4  # sort everything wrong, to reach the loss ending
	bins.bin_chosen.emit(choice)
