# The two shifts that end on a message rather than "time is up": one where
# nothing was sorted, and one that cleared the water.
#
# Both are easy to break by accident, because the ordinary path still works:
# the line is chosen once, at the moment the shift ends, off state that has
# already moved on by the time the report renders.
#
# NOTE the --script file compiles before the autoloads register, so the scene
# is loaded inside _run rather than preloaded up here.
#   godot --headless --script tools/smoke/smoke_shift_end.gd
extends SceneTree

var game: Node


func _init() -> void:
	_run()


func _new_shift() -> Node:
	var shift: Node = load("res://scenes/shift/shift_phase.tscn").instantiate()
	root.add_child(shift)
	await physics_frame
	return shift


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	game.start_run(6060)

	await _check_nothing_sorted()
	await _check_sea_cleared()
	await _check_ordinary_shift()
	print("shift-end messages verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


## Ending without sorting anything says so, whatever else happened.
func _check_nothing_sorted() -> void:
	game.begin_day()
	var shift: Node = await _new_shift()
	assert(int(game.stats["sorted"]) == 0, "fixture already sorted something")
	shift._end_shift()
	var line: String = shift._status.text
	assert(line == Strings.t("shift_nothing_sorted"),
		"a shift with nothing sorted ended on \"%s\"" % line)
	print("  nothing sorted -> \"%s\"" % line)
	shift.free()
	await process_frame


## Grab and sort the day's entire delivery, and the closing line changes.
func _check_sea_cleared() -> void:
	game.begin_day()
	var day: DayData = game.current_day()
	var shift: Node = await _new_shift()
	var claw_view: Node = shift.get_node("ClawView")

	# Take the tank's whole pool straight into the inventory - the point here
	# is the closing line, not the claw.
	claw_view._pending.clear()
	for node: Node in claw_view.get_node(
			"TankLayer/TankContainer/TankViewport/TankWorld/Items").get_children():
		node.free()
	await process_frame
	assert(not claw_view.has_work(), "the tank still has work after emptying it")

	for item: ItemData in day.item_pool:
		if item.is_container:
			continue
		var entry: CarriedItem = game.add_to_inventory(item)
		RuleChecker.judge(entry, int(RuleChecker.resolve(item, day.active_rules)["category"]),
			day.active_rules)
		game.stats["sorted"] = int(game.stats["sorted"]) + 1
	assert(game.unsorted_items().is_empty(), "fixture left something unsorted")
	assert(shift.sea_cleared(), "empty tank + empty desk did not read as cleared")

	shift._end_shift()
	var line: String = shift._status.text
	assert(line == Strings.t("shift_sea_cleared"),
		"a cleared sea ended on \"%s\"" % line)
	print("  sea cleared -> \"%s\"" % line)
	shift.free()
	await process_frame


## Anything in between still gets the plain line - the two above are special
## because they are rare, and they stop being special if one of them fires on
## an ordinary day.
func _check_ordinary_shift() -> void:
	game.begin_day()
	var day: DayData = game.current_day()
	var shift: Node = await _new_shift()
	var entry: CarriedItem = game.add_to_inventory(day.item_pool[0])
	RuleChecker.judge(entry, 0, day.active_rules)
	game.stats["sorted"] = 1
	# something is still out there, so the sea is not clear
	assert(shift.get_node("ClawView").has_work(),
		"fixture emptied the tank; this case needs work left in it")
	assert(not shift.sea_cleared(), "a tank with work left read as cleared")

	shift._end_shift()
	var line: String = shift._status.text
	assert(line == Strings.t("shift_over"),
		"an ordinary shift ended on \"%s\"" % line)
	print("  sorted some, sea not clear -> \"%s\"" % line)
	shift.free()
	await process_frame
