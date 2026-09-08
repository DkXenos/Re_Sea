# Machines fit themselves. There is no gear tab, nothing to choose and nothing
# to take off: a blueprint that has been built is a machine that is running,
# its upgrade is on from that moment to the end of the run, and by the last day
# all three are on together.
#   godot --headless --script tests/smoke_upgrades.gd
extends SceneTree

var game: Node


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	game.start_run(31337)

	_check_every_upgrade_belongs_to_a_machine()
	_check_nothing_is_a_trade_off()
	_check_building_switches_it_on()
	_check_effects_stack()
	print("upgrades verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


## The blueprint is the only way in. An upgrade no machine names could never be
## reached now that the gear tab is gone, and a machine that names nothing is a
## five-day build that does nothing to the claw.
func _check_every_upgrade_belongs_to_a_machine() -> void:
	var granted: Dictionary = {}
	for bp: BlueprintData in game.blueprints:
		assert(bp.unlocks_upgrade != &"", "%s fits nothing to the claw" % bp.id)
		var up: UpgradeData = game.upgrade_for(bp)
		assert(up != null, "%s names %s, which is not in data/upgrades/"
			% [bp.id, bp.unlocks_upgrade])
		assert(not granted.has(up.id), "%s is granted by two machines" % up.id)
		granted[up.id] = true
		print("  %-22s -> %s" % [bp.id, up.id])
	for up: UpgradeData in game.upgrades:
		assert(granted.has(up.id),
			"%s is not granted by any blueprint, so nothing can ever fit it" % up.id)


## Every upgrade has to be a straight improvement. A machine built out of five
## days of sorting that hands back a drawback reads as a punishment for winning.
func _check_nothing_is_a_trade_off() -> void:
	var drop: int = game.base_cost(&"drop")
	var tool: int = game.base_cost(&"tool")
	for up: UpgradeData in game.upgrades:
		assert(up.benefit_text != "", "%s never says what it does" % up.id)
		assert(up.has_benefit(drop, tool), "%s improves nothing" % up.id)
		assert(not up.has_cost(drop, tool), "%s takes something away" % up.id)
		print("  %-18s pure benefit: %s" % [up.id, up.benefit_text])


func _check_building_switches_it_on() -> void:
	game.start_run(31337)
	assert(game.active_upgrades().is_empty(), "a run must start with nothing fitted")
	for bp: BlueprintData in game.blueprints:
		var up: UpgradeData = game.upgrade_for(bp)
		assert(not _is_active(up), "%s is running before its machine is built" % up.id)
		var before: int = game.budget_left
		_build(bp)
		assert(_is_active(up), "%s did not switch on when its machine was built" % up.id)
		# no currency anywhere: the machine is paid for in materials, not in shift
		assert(game.budget_left == before,
			"building a machine spent shift time (%d -> %d)" % [before, game.budget_left])
	assert(game.active_upgrades().size() == game.blueprints.size(),
		"every machine is built but only %d upgrades are running"
		% game.active_upgrades().size())
	print("  building a machine switches its upgrade on, and it stays on")


## They are on TOGETHER at the end, so the numbers have to combine rather than
## the last one winning.
func _check_effects_stack() -> void:
	game.start_run(31337)
	var base_tool: int = game.cost_of(&"tool")
	var base_grip: float = game.grip_delta()
	var base_speed: float = game.move_speed_multiplier()
	assert(is_zero_approx(base_grip), "grip starts modified")
	assert(is_equal_approx(base_speed, 1.0), "rail speed starts modified")

	var expect_tool: int = base_tool
	var expect_grip: float = 0.0
	var expect_speed: float = 1.0
	for bp: BlueprintData in game.blueprints:
		_build(bp)
		var up: UpgradeData = game.upgrade_for(bp)
		if up.tool_cost >= 0:
			expect_tool = mini(expect_tool, up.tool_cost)
		expect_grip += up.grip_delta
		expect_speed *= up.move_speed_multiplier
	assert(game.cost_of(&"tool") == expect_tool,
		"tool costs %d with everything built, expected %d"
		% [game.cost_of(&"tool"), expect_tool])
	assert(is_equal_approx(game.grip_delta(), expect_grip),
		"grip is %+.2f with everything built, expected %+.2f"
		% [game.grip_delta(), expect_grip])
	assert(is_equal_approx(game.move_speed_multiplier(), expect_speed),
		"rail speed is x%.2f with everything built, expected x%.2f"
		% [game.move_speed_multiplier(), expect_speed])
	# nothing a machine fits may make anything worse
	assert(game.cost_of(&"drop") <= game.base_cost(&"drop"), "a machine raised the drop cost")
	assert(game.grip_delta() >= 0.0, "a machine lowered the grip chance")
	assert(game.move_speed_multiplier() >= 1.0, "a machine slowed the rail down")
	assert(not game.coarse_readings(), "a machine made the tools worse")
	assert(is_zero_approx(game.post_drop_lockout()), "a machine froze the rail")
	print("  all three running: tool %d, grip %+.2f, rail x%.2f"
		% [game.cost_of(&"tool"), game.grip_delta(), game.move_speed_multiplier()])


func _is_active(up: UpgradeData) -> bool:
	for active: UpgradeData in game.active_upgrades():
		if active.id == up.id:
			return true
	return false


# materials are not what this test is about, so hand it enough and build
func _build(bp: BlueprintData) -> void:
	for category in ItemData.Category.values():
		game.materials[category] = 99
	for component: ComponentData in bp.components:
		game.craft_component(component)
	assert(game.build_blueprint(bp.id) != null, "%s refused to build" % bp.id)
