## Revision 2 §6, for the EXPERIMENTAL §5 feature. Two things only:
##   1. the flag really gates it - with it false, no puzzle is ever built
##   2. the order check works, failing is free, and retrying is immediate
##
## The "a full run with the flag off finishes with the same health" half of the
## requirement is a shell check in run_all.sh: it runs the whole game twice on
## one seed and compares the ending.
##   godot --headless --script tools/smoke/smoke_puzzle.gd
extends SceneTree

## Loaded at runtime, not preloaded: a --script entry point compiles before the
## autoloads register, and preloading a scene whose script says `Game` would
## fail to compile it.
const PUZZLE_PATH := "res://scenes/puzzle/calibration_puzzle.tscn"

var game: Node
var puzzle_scene: PackedScene


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	game.start_run(2024)
	puzzle_scene = load(PUZZLE_PATH)

	assert(game.feature_calibration_puzzle, "the flag ships on")

	# Exactly two machines are built, and an unknown blueprint refuses.
	var unknown: CanvasLayer = puzzle_scene.instantiate()
	assert(not unknown.setup(&"pemulih_terumbu"),
		"a blueprint with no sequence must refuse rather than invent one")
	unknown.free()

	for blueprint_id: StringName in [&"penyaring_mikroplastik", &"penetral_b3"]:
		await _check_sequence(blueprint_id)
	print("calibration puzzle verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


func _check_sequence(blueprint_id: StringName) -> void:
	var puzzle: CanvasLayer = puzzle_scene.instantiate()
	assert(puzzle.setup(blueprint_id), "no sequence for %s" % blueprint_id)
	root.add_child(puzzle)
	await process_frame

	assert(puzzle._steps.size() == 4, "a sequence is exactly four steps")
	assert(not puzzle._is_correct(puzzle._order),
		"the puzzle must never open already solved")

	# Reorder through the real drag path. Setting _order directly is what let a
	# broken _drop_data ship: the check passed while dragging a row did nothing
	# at all in the running game.
	var rows: Array = puzzle._rows.get_children()
	var before: Array[int] = puzzle._order.duplicate()
	rows[0]._drop_data(Vector2.ZERO, rows[1])
	assert(puzzle._order[0] == before[1] and puzzle._order[1] == before[0],
		"dropping one row on another must swap them")
	print("  %s drag reorder works: %s -> %s" % [blueprint_id, before, puzzle._order])

	# Away from the ceiling, so a +2 bonus is actually visible.
	game.set_ocean_health(50)
	# Wrong order: a readable line that is not the generic fallback, no health
	# change, and the puzzle stays open for another try.
	var health_before: int = game.ocean_health
	var budget_before: int = game.budget_left
	var backwards: Array[int] = [3, 2, 1, 0]
	puzzle._order = backwards
	puzzle._on_run()
	var failure: String = puzzle._message.text
	print("  %s failed with: %s" % [blueprint_id, failure])
	assert(failure != "", "a wrong order must say something")
	assert(failure != Strings.t("puzzle_wrong"),
		"a wrong order must explain WHY, not just that it is wrong")
	assert(game.ocean_health == health_before, "failing must cost no health")
	assert(game.budget_left == budget_before, "failing must cost no shift budget")
	assert(not puzzle._solved, "a failed run must be retryable")

	# Right order: the flat bonus, once.
	var correct: Array[int] = [0, 1, 2, 3]
	puzzle._order = correct
	puzzle._on_run()
	assert(puzzle._solved, "the correct order must solve it")
	assert(game.ocean_health == health_before + puzzle.HEALTH_BONUS,
		"solving pays the flat bonus and nothing else")
	assert(game.budget_left == budget_before, "solving must not touch the shift budget")
	puzzle._on_run()
	assert(game.ocean_health == health_before + puzzle.HEALTH_BONUS,
		"the bonus must not be payable twice")
	print("  %s solved: health %+d, budget untouched" % [blueprint_id, puzzle.HEALTH_BONUS])

	puzzle._close()
	await process_frame
