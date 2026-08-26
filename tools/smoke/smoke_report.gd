# ocean health arithmetic, term by term:
#   health += correct*2 - wrong*4 - max(0, quota-sorted)*3 + clean_day_bonus
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

	# --- a messy day: mistakes and a shortfall, no clean bonus ---
	game.stats = {"correct": 4, "wrong": 2, "sorted": 6, "grabs_used": 12}
	var b: Dictionary = game.end_day_breakdown()
	var expected_shortfall: int = maxi(0, 8 - 6) * 3
	var expected_delta: int = 4 * 2 - 2 * 4 - expected_shortfall
	print("messy: quota %d sorted %d shortfall -%d clean +%d delta %+d" %
		[b["quota"], b["sorted"], b["shortfall"], b["clean_bonus"], b["delta"]])
	assert(int(b["shortfall"]) == expected_shortfall, "shortfall penalty wrong")
	assert(int(b["clean_bonus"]) == 0, "clean bonus must not pay on a day with mistakes")
	assert(int(b["delta"]) == expected_delta, "day score delta wrong")
	assert(not b["quota_met"], "quota should not be met")
	assert(not b.has("fish"), "the fish penalty must be gone entirely")

	# --- a clean day has to score positively ---
	game.stats = {"correct": 8, "wrong": 0, "sorted": 8, "grabs_used": 10}
	var clean: Dictionary = game.end_day_breakdown()
	print("clean: correct %d clean +%d delta %+d" %
		[clean["correct"], clean["clean_bonus"], clean["delta"]])
	assert(int(clean["clean_bonus"]) == 5, "clean day bonus not paid")
	assert(int(clean["delta"]) == 8 * 2 + 5, "clean day delta wrong")
	assert(int(clean["delta"]) > 0, "a perfectly played day must score positively")

	# A clean day that misses quota gets no bonus - the bonus needs both.
	game.stats = {"correct": 5, "wrong": 0, "sorted": 5, "grabs_used": 8}
	var short_clean: Dictionary = game.end_day_breakdown()
	assert(int(short_clean["clean_bonus"]) == 0, "clean bonus needs quota met too")
	print("clean but short of quota: clean +%d (correctly withheld)" %
		short_clean["clean_bonus"])

	# --- the 4x asymmetry on wrong sorts survives the revision ---
	game.stats = {"correct": 1, "wrong": 0, "sorted": 8, "grabs_used": 8}
	var one_right: int = int(game.end_day_breakdown()["delta"])
	game.stats = {"correct": 0, "wrong": 1, "sorted": 8, "grabs_used": 8}
	var one_wrong: int = int(game.end_day_breakdown()["delta"])
	assert(one_wrong == -4 and one_right == 2 + 5,
		"wrong sorts must still cost 4, twice what a correct sort pays")
	print("asymmetry intact: one correct %+d, one wrong %+d" % [one_right - 5, one_wrong])

	# a disastrous day must score negatively, a perfect one positively
	game.stats = {"correct": 0, "wrong": 5, "sorted": 5, "grabs_used": 5}
	assert(int(game.end_day_breakdown()["delta"]) < 0, "a bad day must score negative")
	game.stats = {"correct": 8, "wrong": 0, "sorted": 8, "grabs_used": 8}
	assert(int(game.end_day_breakdown()["delta"]) > 0, "a good day must score positive")
	print("day score sign ok")
	print("formula verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
