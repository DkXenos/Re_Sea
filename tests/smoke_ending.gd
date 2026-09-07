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


## Every machine is the good ending, none at all is the bad one.
func _check_endings() -> void:
	var total: int = game.blueprints.size()
	game.start_run()
	assert(game.ending_kind() == &"bad",
		"no blueprints must be the bad ending, got %s" % game.ending_kind())
	for i in total:
		game.unlocked_blueprints.append(game.blueprints[i].id)
		var got: StringName = game.ending_kind()
		var want: StringName = &"good" if i + 1 >= total else &"regular"
		assert(got == want, "%d/%d blueprints should be %s, got %s"
			% [i + 1, total, want, got])
	print("  0 -> bad, 1..%d -> regular, %d -> good" % [total - 1, total])
	# every ending must have text, or the screen renders blank
	for kind: String in ["bad", "regular", "good"]:
		for part: String in ["title", "body"]:
			var key := "end_%s_%s" % [kind, part]
			assert(Strings.t(key) != key, "missing string: %s" % key)
	print("  all three endings have a title and a body")
