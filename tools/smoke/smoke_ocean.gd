## The tier and blueprint ARITHMETIC: thresholds cover every health value, a
## perfect day never loses ground, and no bonus can push the meter past 100.
##
## What this deliberately no longer does is claim anything about how a real run
## goes. Revision 2 asserted that here by setting health and stats by hand, and
## that check passed for a whole revision while the tier never once moved in
## actual play. Progression - two tier rises, two blueprints, the first by day
## 2 - is now asserted in smoke_full, from a run that was played (rev 3 §6).
##   godot --headless --script tools/smoke/smoke_ocean.gd
extends SceneTree

var game: Node


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled

	_check_tiers()
	_check_blueprints()
	_check_clamp()
	_check_forced_tier()
	print("ocean tiers and blueprints verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


## Four tiers, contiguous, and every health value lands in exactly one of them.
func _check_tiers() -> void:
	assert(game.tiers.size() >= 4, "expected four ocean tiers as data")
	for health in range(0, 101):
		var tier: int = game.tier_for(health)
		var data: OceanTierData = game.tier_data(tier)
		assert(data != null, "no tier data for health %d" % health)
		assert(health >= data.min_health and health <= data.max_health,
			"health %d landed in tier %d, which covers %d-%d"
			% [health, tier, data.min_health, data.max_health])
	assert(game.tier_for(0) == 0 and game.tier_for(100) == 3,
		"the extremes must be the extreme tiers")
	# Each tier must actually LOOK different, or it is not worth having.
	var seen: Dictionary = {}
	for tier: OceanTierData in game.tiers:
		assert(tier.seabed != null, "tier %d has no seabed art" % tier.tier)
		assert(tier.transition_text != "", "tier %d has no transition line" % tier.tier)
		assert(not seen.has(tier.seabed.resource_path), "two tiers share a seabed")
		seen[tier.seabed.resource_path] = true
	assert(game.tier_data(3).fish_count > game.tier_data(0).fish_count,
		"a recovered ocean must hold more fish than a dead one")
	assert(game.tier_data(3).debris_count < game.tier_data(0).debris_count,
		"a recovered ocean must hold less debris than a dead one")


## Day-shaped arithmetic only: a perfect day must never cost health, and a
## finished blueprint must become claimable. Whether a REAL run gets there is
## smoke_full's job.
func _check_blueprints() -> void:
	game.start_run(4242)
	game.set_ocean_health(30)
	game.refresh_visual_tier()
	var start_tier: int = game.visual_tier
	assert(start_tier == 1, "health 30 should be tier 1, got %d" % start_tier)

	var tier_rises: int = 0
	var unlocked: int = 0
	# Five clean days of correct sorts, one recyclable-heavy day at a time.
	for day in 5:
		var before_health: int = game.ocean_health
		var before_tier: int = game.visual_tier
		game.inventory.clear()
		var pool: Array = game.current_day().item_pool
		for i in 8:
			var entry: CarriedItem = game.add_to_inventory(pool[i % pool.size()])
			entry.sorted_to = entry.data.correct_category
			entry.expected_category = entry.data.correct_category
			entry.was_correct = true
		game.stats = {"correct": 8, "wrong": 0, "sorted": 8}
		var breakdown: Dictionary = game.end_day_breakdown()
		game.commit_day_result(breakdown)
		# Rising, or already full - a perfect day must never LOSE ground.
		assert(game.ocean_health > before_health or game.ocean_health == 100,
			"a perfect day must raise the meter (day %d)" % (day + 1))
		if game.visual_tier > before_tier:
			tier_rises += 1
		for bp: BlueprintData in game.claimable_blueprints():
			game.claim_blueprint(bp.id)
			unlocked += 1
			print("  day %d: unlocked %s (+%d) | health %d tier %d"
				% [day + 1, bp.display_name, bp.health_gain, game.ocean_health,
				game.visual_tier])
		if not game.is_last_day():
			game.advance_day()
	print("  arithmetic: %d blueprint(s) became claimable, %d tier increase(s)"
		% [unlocked, tier_rises])
	assert(unlocked >= 1, "correct sorting must make a blueprint claimable")
	assert(tier_rises >= 1, "correct sorting must raise the ocean tier")


## A blueprint bonus can never push the meter past full.
func _check_clamp() -> void:
	game.start_run(7)
	game.set_ocean_health(98)
	for c in 4:
		game.correct_by_category[c] = 99
	for bp: BlueprintData in game.claimable_blueprints():
		game.claim_blueprint(bp.id)
	assert(game.ocean_health == 100, "health must clamp at 100, got %d" % game.ocean_health)
	print("  three blueprint bonuses from 98 clamp at 100")


## "Forces tier 3 art if health allows": it does not paint a healed reef over a
## dying ocean.
func _check_forced_tier() -> void:
	game.start_run(8)
	game.forced_tier = 3
	game.set_ocean_health(60)
	game.refresh_visual_tier()
	assert(game.visual_tier == 3, "forced tier should apply at health 60")
	game.set_ocean_health(20)
	game.refresh_visual_tier()
	assert(game.visual_tier < 3,
		"a forced tier must not survive the ocean falling below the tier under it")
	print("  forced tier applies at health 60 and is withdrawn at 20")
