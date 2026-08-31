# desk phase: fill the inventory, use every tool on items that have something
# for it and on items that do not, cut open any crate, then sort everything.
#   godot --headless --script tools/smoke/smoke_desk.gd -- [day]
extends SceneTree

var finished := false
var deliberate_wrong := 0


func _init() -> void:
	_run()


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
	print("day %d | inventory %d | budget %d | tools %s" % [day.day_number,
		game.inventory.size(), game.budget_left, day.available_tools])

	events.phase_finished.connect(func() -> void: finished = true)
	var phase: Node = load("res://scenes/desk/desk_phase.tscn").instantiate()
	root.add_child(phase)
	await process_frame
	await process_frame

	var inspect: Control = phase.get_node("UiLayer/Root/InspectPanel")
	var inventory: Control = phase.get_node("UiLayer/Root/InventoryPanel")
	var bins: Control = phase.get_node("UiLayer/Root/BinRow")
	var rulebook: Control = phase.get_node("RulebookLayer/RulebookPanel")

	rulebook.toggle(true)
	print("rulebook lines: %d" % rulebook.get_node("Scroll/List").get_child_count())
	rulebook.toggle(false)

	var hits := 0
	var misses := 0
	var guard := 0
	var stopped_broke := false
	while not game.unsorted_items().is_empty() and guard < 60:
		guard += 1
		# Sorting costs budget too, so a shift can run out mid-desk. That is the
		# model working, not a failure - stop and report it.
		if not game.can_afford(&"sort"):
			stopped_broke = true
			break
		var entry = inspect.entry
		if entry == null:
			break
		# A sealed crate is cut open, not inspected and not binned.
		if entry.is_container() and not entry.opened:
			var opener: ToolData = game.container_opener()
			assert(opener != null, "day %d has a crate and nothing to open it with"
				% day.day_number)
			inspect._armed = opener.id
			inspect._use_tool()
			inspect._armed = &""
			assert(entry.opened, "the opener did not open the crate")
			inventory.refresh()
			inventory.select_first()
			continue
		# Every tool that has something to find here, then ONE that does not.
		# Spending the whole rack on every item just runs the shift dry before
		# it reaches the items worth inspecting.
		var idle_tool: StringName = &""
		for tool_data: ToolData in game.tools:
			var tool_id: StringName = tool_data.id
			if tool_data.opens_containers or not game.tool_unlocked(tool_id):
				continue
			if not entry.data.tool_can_reveal(tool_id):
				idle_tool = tool_id
				continue
			if not game.can_afford(&"tool"):
				continue
			var before: int = entry.revealed.size()
			inspect._armed = tool_id
			inspect._use_tool()
			assert(entry.revealed.size() > before,
				"%s has something for %s but clicking the item revealed nothing"
				% [entry.data.id, tool_id])
			hits += 1
		if idle_tool != &"" and game.can_afford(&"tool"):
			var budget_before: int = game.budget_left
			inspect._armed = idle_tool
			inspect._use_tool()
			assert(game.budget_left == budget_before - game.cost_of(&"tool"),
				"a tool that found nothing did not charge for the attempt")
			misses += 1
		inspect._armed = &""
		var chips: int = inspect.get_node("EvidenceScroll/EvidenceLog").get_child_count()
		print("  %-16s revealed=%d chips=%d" % [entry.data.id, entry.revealed.size(), chips])
		var verdict := RuleChecker.resolve(entry.data, day.active_rules)
		var choice: int = int(verdict["category"])
		var intended_wrong := guard % 4 == 0
		if intended_wrong:
			choice = (choice + 1) % 4  # deliberate mistake, to exercise the wrong path
		var sorted_before: int = int(game.stats["sorted"])
		bins.bin_chosen.emit(choice)
		# Only count it if the bin actually accepted it.
		if int(game.stats["sorted"]) > sorted_before and intended_wrong:
			deliberate_wrong += 1
		await process_frame

	assert(hits > 0, "no tool ever revealed anything - the click never landed")
	assert(misses > 0, "a tool that finds nothing was never exercised")
	print("tool hits=%d  budget-burning misses=%d%s" % [hits, misses,
		"  (shift ran out of budget mid-desk)" if stopped_broke else ""])
	print("sorted=%d correct=%d wrong=%d (deliberate mistakes %d) | budget left %d" %
		[game.stats["sorted"], game.stats["correct"], game.stats["wrong"], deliberate_wrong,
		game.budget_left])
	assert(game.stats["wrong"] == deliberate_wrong, "rule checker disagreed with RuleChecker.resolve")
	# The desk is a view inside the shift now; it never ends the day itself.
	assert(not finished, "the desk view must not end the shift on its own")
	print("desk view correctly left the shift-ending decision to the shift")
	# This harness quits mid-frame, so release any sound still playing rather
	# than letting Godot report it as a leaked stream.
	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
