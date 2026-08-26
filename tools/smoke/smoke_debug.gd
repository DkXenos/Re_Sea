## Verifies every F1 debug command does what it says.
##   godot --headless --script tools/smoke/smoke_debug.gd
extends SceneTree


func _init() -> void:
	_run()


func _current(main: Node) -> Node:
	var holder: Node = main.get_node("SceneHolder")
	return holder.get_child(0) if holder.get_child_count() > 0 else null


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	var events: Node = root.get_node("/root/Events")
	var main: Node = load("res://main.tscn").instantiate()
	root.add_child(main)
	await process_frame

	var overlay: Node = main.get_node("DebugLayer/DebugOverlay")
	assert(is_instance_valid(overlay), "debug overlay missing in a debug build")
	assert(not overlay.visible, "debug overlay should start hidden")
	overlay.toggle(true)
	assert(overlay.visible, "debug overlay did not open")
	print("overlay opens; %d controls built" % overlay.get_node("Panel/List").get_child_count())

	game.start_run(4242)
	events.debug_command.emit(&"set_seed", 31337)
	assert(game.run_seed == 31337, "set_seed failed")
	events.debug_command.emit(&"set_tier", 2)
	assert(game.visual_tier == 2, "set_tier failed")
	events.debug_command.emit(&"force_grip", -1)
	assert(game.force_grip == -1, "force_grip failed")
	print("seed=%d tier=%d force_grip=%d" % [game.run_seed, game.visual_tier, game.force_grip])

	game.advance_day() # day 2 has tool charges
	events.debug_command.emit(&"fill_inventory", 6)
	assert(game.inventory.size() == 6, "fill_inventory failed")
	game.spend(&"tool")
	game.spend(&"drop")
	var spent: int = game.budget_left
	events.debug_command.emit(&"refill_budget", null)
	assert(game.budget_left > spent, "refill_budget failed")
	assert(game.budget_left == game.budget_max, "refill_budget did not restore the full shift")
	print("inventory=%d budget %d -> %d" % [game.inventory.size(), spent, game.budget_left])

	# reveal_all needs the desk scene, since it acts on the inspected item.
	events.scene_change_requested.emit(&"shift")
	await process_frame
	await process_frame
	var shift: Node = _current(main)
	assert(String(shift.name) == "ShiftPhase", "shift did not load")
	var desk: Node = shift.get_node("DeskView")
	var entry = desk.get_node("UiLayer/Root/InspectPanel").entry
	assert(entry != null, "no item selected on the desk")
	assert(entry.revealed.is_empty(), "item should start unrevealed")
	events.debug_command.emit(&"reveal_all", null)
	assert(entry.revealed.size() == 4, "reveal_all did not reveal every hidden field")
	print("reveal_all exposed %d fields on %s" % [entry.revealed.size(), entry.data.id])

	var before: int = game.day_index
	events.debug_command.emit(&"skip_day", null)
	await process_frame
	await process_frame
	assert(game.day_index == before + 1, "skip_day did not advance")
	assert(String(_current(main).name) == "DayStart", "skip_day did not land on day start")
	print("skip_day: day_index %d -> %d, now on %s" % [before, game.day_index,
		_current(main).name])

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
