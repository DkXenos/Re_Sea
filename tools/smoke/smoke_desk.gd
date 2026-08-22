## Headless smoke test for the desk phase: fills the inventory, exercises every
## tool on both a real hotspot and empty space, then sorts everything.
##   godot --headless --script tools/smoke/smoke_desk.gd -- [day]
extends SceneTree

var finished := false
var deliberate_wrong := 0


func _init() -> void:
	_run()


## Normalized texture coordinate -> point inside the inspect surface, mirroring
## inspect_panel._to_normalized().
func _point_for(n: Vector2) -> Vector2:
	return Vector2(180, 180) + (n - Vector2(0.5, 0.5)) * 320.0


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	var events: Node = root.get_node("/root/Events")
	var args := OS.get_cmdline_user_args()
	var day_number: int = int(args[0]) if args.size() > 0 else 4
	game.start_run(777)
	for i in day_number - 1:
		game.advance_day()
	var day = game.current_day()
	for item in day.item_pool:
		game.add_to_inventory(item)
	print("day %d | inventory %d | charges %s" % [day.day_number, game.inventory.size(),
		day.tool_charges])

	events.phase_finished.connect(func() -> void: finished = true)
	var phase: Node = load("res://scenes/desk/desk_phase.tscn").instantiate()
	root.add_child(phase)
	await process_frame
	await process_frame

	var inspect: Control = phase.get_node("UiLayer/Root/InspectPanel")
	var bins: Control = phase.get_node("UiLayer/Root/BinRow")
	var rulebook: Control = phase.get_node("UiLayer/Root/RulebookPanel")

	rulebook.toggle(true)
	print("rulebook lines: %d" % rulebook.get_node("Scroll/List").get_child_count())
	rulebook.toggle(false)

	var hits := 0
	var misses := 0
	var guard := 0
	while not game.unsorted_items().is_empty() and guard < 60:
		guard += 1
		var entry = inspect.entry
		if entry == null:
			break
		# Spend one charge on a real hotspot, and one on empty space, for each
		# tool this item actually has a hotspot for.
		for spot: Dictionary in entry.data.hotspots:
			var tool_id := StringName(spot["tool"])
			if game.charges_for(tool_id) <= 0:
				continue
			inspect._armed = tool_id
			var before: int = entry.revealed.size()
			inspect._use_tool_at(_point_for(spot["pos"]))
			if entry.revealed.size() > before:
				hits += 1
			if game.charges_for(tool_id) > 0:
				var charge_before: int = game.charges_for(tool_id)
				inspect._armed = tool_id
				inspect._use_tool_at(_point_for(Vector2(0.03, 0.03)))
				if game.charges_for(tool_id) == charge_before - 1:
					misses += 1
		inspect._armed = &""
		var chips: int = inspect.get_node("EvidenceScroll/EvidenceLog").get_child_count()
		print("  %-16s revealed=%d chips=%d" % [entry.data.id, entry.revealed.size(), chips])
		var verdict := RuleChecker.resolve(entry.data, day.active_rules)
		var choice: int = int(verdict["category"])
		if guard % 4 == 0:
			choice = (choice + 1) % 4  # deliberate mistake, to exercise the wrong path
			deliberate_wrong += 1
		bins.bin_chosen.emit(choice)
		await process_frame

	print("hotspot hits=%d  charge-burning misses=%d" % [hits, misses])
	print("sorted=%d correct=%d wrong=%d (deliberate mistakes %d) | charges left %s" %
		[game.stats["sorted"], game.stats["correct"], game.stats["wrong"], deliberate_wrong,
		game.tool_charges])
	assert(game.stats["wrong"] == deliberate_wrong, "rule checker disagreed with RuleChecker.resolve")
	var waited := 0
	while not finished and waited < 400:
		waited += 1
		await process_frame
	print("phase_finished=%s" % finished)
	# This harness quits mid-frame, so release any sound still playing rather
	# than letting Godot report it as a leaked stream.
	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
