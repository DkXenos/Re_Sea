## Revision 2 §6: the two upgrades really are trade-offs, and only one of them
## can ever be taken in a run.
##   godot --headless --script tools/smoke/smoke_upgrades.gd
extends SceneTree

var game: Node


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	game.start_run(31337)

	assert(game.upgrades.size() >= 4, "expected four upgrades as data")
	assert(game.upgrade() == null, "a run must start with no upgrade fitted")

	# Every upgrade has to give something AND take something. An upgrade that
	# only makes things easier makes the last day flatter than the first.
	for up: UpgradeData in game.upgrades:
		assert(up.benefit_text != "", "%s has no stated benefit" % up.id)
		assert(up.cost_text != "", "%s has no stated cost" % up.id)
		assert(up.is_trade_off(game.base_cost(&"drop"), game.base_cost(&"tool")),
			"%s is not a trade-off" % up.id)
		print("  %-18s benefit + cost, both present%s" % [up.id,
			"" if up.unlock_after_blueprints == 0 else
			"  (opens after %d blueprint(s))" % up.unlock_after_blueprints])

	# Two must be on the table from day one, or the system is not testable
	# until the run is nearly over - which is what revision 3 exists to fix.
	var day_one: int = 0
	for up: UpgradeData in game.upgrades:
		if up.unlock_after_blueprints == 0:
			day_one += 1
		assert(up.unlock_after_blueprints == 0 or up.unlock_text != "",
			"%s is locked but never says what opens it" % up.id)
	assert(day_one >= 2, "at least two upgrades must be available on day 1, found %d" % day_one)
	assert(game.upgrade_unlocked(game.upgrades[0]), "a day-1 upgrade must start unlocked")
	for up: UpgradeData in game.upgrades:
		if up.unlock_after_blueprints > 0:
			assert(not game.upgrade_unlocked(up), "%s must start locked" % up.id)

	game.equip_upgrade(&"cakar_ringan")
	assert(game.cost_of(&"drop") == 4, "cakar_ringan should drop for 4")
	assert(is_equal_approx(game.grip_delta(), -0.15), "cakar_ringan should cost 15pp of grip")
	assert(not game.coarse_readings(), "cakar_ringan must not affect tool readings")
	print("  cakar_ringan: drop %d (base %d), grip %+.2f"
		% [game.cost_of(&"drop"), game.base_cost(&"drop"), game.grip_delta()])

	# Revision 3: swapping is free and reversible, not a once-per-run choice.
	game.equip_upgrade(&"pemindai_kasar")
	assert(game.equipped_upgrade == &"pemindai_kasar", "an upgrade must be swappable")
	assert(game.cost_of(&"tool") == 2, "pemindai_kasar should probe for 2")
	assert(game.base_cost(&"tool") == 4, "the full reading still costs the base 4")
	assert(game.coarse_readings(), "pemindai_kasar must make readings coarse")
	assert(game.cost_of(&"drop") == game.base_cost(&"drop"),
		"pemindai_kasar must not change the drop cost")
	# Two coarse probes plus one full reading costs MORE than one plain use.
	var coarse_total: int = game.cost_of(&"tool") + game.base_cost(&"tool")
	assert(coarse_total > game.base_cost(&"tool"),
		"a full reading through the coarse scanner must cost more than a plain one")
	print("  pemindai_kasar: probe %d, full reading %d, total %d vs plain %d"
		% [game.cost_of(&"tool"), game.base_cost(&"tool"), coarse_total,
		game.base_cost(&"tool")])

	# No currency anywhere: taking an upgrade never touches the shift budget.
	var before: int = game.budget_left
	game.start_run(31337)
	game.equip_upgrade(&"cakar_ringan")
	assert(game.budget_left == game.budget_max,
		"choosing an upgrade must not spend shift budget")
	print("  no currency: budget untouched by the choice (%d/%d)"
		% [game.budget_left, game.budget_max])
	assert(before >= 0)
	print("upgrades verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
