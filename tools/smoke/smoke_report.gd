## Verifies the ocean-health arithmetic in the day report against section 15 of
## the brief, term by term.
##   godot --headless --script tools/smoke/smoke_report.gd
extends SceneTree


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	game.start_run(99)
	game.advance_day()
	game.advance_day() # day 3, quota 8
	game.stats = {"correct": 4, "wrong": 2, "fish": 1, "sorted": 6, "grabs_used": 12}
	var b: Dictionary = game.end_day_breakdown()
	var expected_shortfall: int = maxi(0, 8 - 6) * 3
	var expected_delta: int = 4 * 1 - 2 * 4 - 1 * 2 - expected_shortfall
	print("quota=%d sorted=%d shortfall=%d delta=%d health %d -> %d" %
		[b["quota"], b["sorted"], b["shortfall"], b["delta"],
		b["health_before"], b["health_after"]])
	assert(int(b["shortfall"]) == expected_shortfall, "shortfall penalty wrong")
	assert(int(b["delta"]) == expected_delta, "health delta wrong")
	assert(int(b["health_after"]) == 100 + expected_delta, "health not applied")
	assert(not b["quota_met"], "quota should not be met")

	# Clamping at both ends.
	game.set_ocean_health(3)
	game.stats = {"correct": 0, "wrong": 5, "fish": 0, "sorted": 5, "grabs_used": 5}
	var low: Dictionary = game.end_day_breakdown()
	assert(int(low["health_after"]) == 0, "health must clamp to 0")
	game.set_ocean_health(99)
	game.stats = {"correct": 8, "wrong": 0, "fish": 0, "sorted": 8, "grabs_used": 8}
	var high: Dictionary = game.end_day_breakdown()
	assert(int(high["health_after"]) == 100, "health must clamp to 100")
	assert(high["quota_met"], "quota should be met")
	print("clamps ok: low=%d high=%d" % [low["health_after"], high["health_after"]])
	print("formula verified")
	quit()
