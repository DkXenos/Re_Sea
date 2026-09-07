# The ending is driven by ONE number: how many blueprints have actually been
# built. The seabed no longer changes with it - there is a single seabed PNG and
# no tier art - so this checks the ending mapping and nothing else.
#   godot --headless --script tests/smoke_ending.gd
extends SceneTree

var game: Node


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled

	_check_endings()
	print("endings verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


## One tier per machine built: 0 is the bay left as it was, every machine is the
## full recovery, and each step between has its own screen.
func _check_endings() -> void:
	var total: int = game.blueprints.size()
	game.start_run()
	assert(game.ending_tier() == 0,
		"no blueprints must be tier 0, got %d" % game.ending_tier())
	for i in total:
		game.unlocked_blueprints.append(game.blueprints[i].id)
		assert(game.ending_tier() == i + 1, "%d blueprints should be tier %d, got %d"
			% [i + 1, i + 1, game.ending_tier()])
	print("  %d machines -> %d tiers, one per machine" % [total, total + 1])
	# every tier must have text and a still, or the screen renders blank
	for tier in total + 1:
		for part: String in ["title", "body"]:
			var key := "end_%d_%s" % [tier, part]
			assert(Strings.t(key) != key, "missing string: %s" % key)
	game.start_run()
	for tier in total + 1:
		if tier > 0:
			game.unlocked_blueprints.append(game.blueprints[tier - 1].id)
		var still: String = game.ending_still()
		assert(ResourceLoader.exists(still),
			"tier %d points at a still that is not there: %s" % [tier, still])
	print("  every tier has a title, a body and a still")
