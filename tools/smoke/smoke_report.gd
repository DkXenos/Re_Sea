# what a day is worth, now that there is no day score:
#   only correctly sorted items reach the material store, and a wrong bin
#   loses the item outright.
#   godot --headless --script tools/smoke/smoke_report.gd
extends SceneTree


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	game.start_run(99)
	game.advance_day()
	game.advance_day() # day 3, quota 8

	# --- the breakdown counts, it does not score ---
	game.stats = {"correct": 4, "wrong": 2, "sorted": 6, "grabs_used": 12}
	var b: Dictionary = game.end_day_breakdown()
	print("messy: quota %d sorted %d correct %d wrong %d" %
		[b["quota"], b["sorted"], b["correct"], b["wrong"]])
	assert(not b["quota_met"], "quota should not be met")
	for gone: String in ["delta", "shortfall", "clean_bonus", "fish"]:
		assert(not b.has(gone), "%s is a score term and must be gone entirely" % gone)

	game.stats = {"correct": 8, "wrong": 0, "sorted": 8, "grabs_used": 10}
	assert(game.end_day_breakdown()["quota_met"], "quota met should read as met")

	# --- a wrong bin pays nothing, and the report says so ---
	var day: DayData = game.current_day()
	var rules: Array[RuleData] = day.active_rules
	var right: int = 0
	var wrong: int = 0
	game.begin_day()
	for item: ItemData in day.item_pool:
		if item.is_container:
			continue
		var entry: CarriedItem = game.add_to_inventory(item)
		var correct_bin: int = int(RuleChecker.resolve(item, rules)["category"])
		# every third item goes in the wrong bin on purpose
		var into: int = correct_bin if (right + wrong) % 3 != 2 else (correct_bin + 1) % 4
		if RuleChecker.judge(entry, into, rules):
			right += 1
		else:
			wrong += 1
	assert(right > 0 and wrong > 0, "the fixture needs both a correct and a wrong sort")

	var recovered: Dictionary = game.day_recovered()
	var total: int = 0
	for category: int in recovered:
		total += int(recovered[category])
	print("sorted %d right, %d wrong -> %d recovered" % [right, wrong, total])
	assert(total == right, "recovered material must equal the correct sorts, not %d" % total)

	# and every unit of it is filed under the bin it BELONGED in
	for entry: CarriedItem in game.inventory:
		if entry.sorted_to == -1 or entry.was_correct:
			continue
		assert(entry.sorted_to != entry.expected_category, "a wrong sort matched its bin")

	# --- committing the day moves exactly that much into the store ---
	var before: Dictionary = game.materials.duplicate()
	game.commit_day_result(game.end_day_breakdown())
	var gained: int = 0
	for category: int in game.materials:
		gained += int(game.materials[category]) - int(before.get(category, 0))
	assert(gained == right, "the store gained %d from %d correct sorts" % [gained, right])
	print("material store credited %d, wrong sorts credited nothing" % gained)

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
