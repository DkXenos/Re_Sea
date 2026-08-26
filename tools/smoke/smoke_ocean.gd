# The seabed and the ending are both driven by ONE number now: how many
# blueprints have actually been built. This checks that mapping and nothing
# else - whether a real run can reach tier 3 is smoke_full's job.
#   godot --headless --script tools/smoke/smoke_ocean.gd
extends SceneTree

var game: Node


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled

	_check_tiers()
	_check_tier_mapping()
	_check_endings()
	_check_art_is_authored()
	print("ocean tiers and endings verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


## One tier per blueprint, indexed 0..N with no gaps.
func _check_tiers() -> void:
	assert(game.tiers.size() >= 2, "need at least two tiers, got %d" % game.tiers.size())
	for i in game.tiers.size():
		assert(game.tiers[i].tier == i,
			"tiers must be indexed 0..N with no gaps; slot %d holds tier %d"
			% [i, game.tiers[i].tier])
	# a tier per blueprint, plus the untouched-ocean tier at the bottom
	assert(game.tiers.size() == game.blueprints.size() + 1,
		"expected %d tiers for %d blueprints, got %d"
		% [game.blueprints.size() + 1, game.blueprints.size(), game.tiers.size()])
	print("  %d tiers, indexed 0..%d, one per blueprint plus tier 0"
		% [game.tiers.size(), game.tiers.size() - 1])


## Building the Nth machine moves the seabed to tier N, and nothing else does.
func _check_tier_mapping() -> void:
	game.start_run()
	assert(game.visual_tier == 0, "a fresh run must start at tier 0, got %d" % game.visual_tier)
	for i in game.blueprints.size():
		game.unlocked_blueprints.append(game.blueprints[i].id)
		var moved: int = game.refresh_visual_tier()
		assert(game.visual_tier == i + 1,
			"%d blueprints built should be tier %d, got %d"
			% [i + 1, i + 1, game.visual_tier])
		assert(moved == i + 1, "the tier change must be reported, got %d" % moved)
	# over-building cannot walk off the end of the tier list
	assert(game.tier_for(99) == game.tiers.size() - 1, "tier must clamp to the top")
	assert(game.tier_for(-5) == 0, "tier must clamp to the bottom")
	print("  0/1/2/3 blueprints -> tier 0/1/2/3, clamped at both ends")


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


## The tier art the designers authored must actually be reachable - this is the
## check that would have caught the art sitting unused for the whole project.
func _check_art_is_authored() -> void:
	for t in game.tiers:
		assert(t.seabed != null, "tier %d has no seabed texture" % t.tier)
		assert(t.coral_count == 0 or t.coral_frames != null,
			"tier %d wants %d coral but has no frames" % [t.tier, t.coral_count])
		assert(t.debris_count == 0 or t.debris_frames != null,
			"tier %d wants %d debris but has no frames" % [t.tier, t.debris_count])
		assert(t.display_name != "", "tier %d has no display name" % t.tier)
	# the seabed must visibly differ, or the tiers are decorative only
	var paths := {}
	for t in game.tiers:
		paths[t.seabed.resource_path] = true
	assert(paths.size() == game.tiers.size(),
		"every tier needs its own seabed art; found %d distinct for %d tiers"
		% [paths.size(), game.tiers.size()])
	print("  every tier has its own seabed, plus coral and debris frames")
