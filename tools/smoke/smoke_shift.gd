## The two invariants the shift model has to hold (revision 1 §10):
##
##   1. Budget accounting is exact - what was spent equals the sum of the
##      actions taken, across a whole simulated day.
##   2. An item is always reachable - the tank never drops below the day's
##      min_available_items while the pool still has items to give.
##
##   godot --headless --script tools/smoke/smoke_shift.gd -- [day]
extends SceneTree


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	Engine.time_scale = 6.0
	var args := OS.get_cmdline_user_args()
	var day_number: int = int(args[0]) if args.size() > 0 else 5
	game.start_run(2024)
	for i in day_number - 1:
		game.advance_day()
	var day = game.current_day()

	var phase: Node = load("res://scenes/claw/claw_phase.tscn").instantiate()
	root.add_child(phase)
	await physics_frame
	var world: Node = phase.get_node("TankLayer/TankContainer/TankViewport/TankWorld")
	var claw: Node2D = world.get_node("Claw")
	var items: Node2D = world.get_node("Items")
	print("day %d | budget %d | pool %d | seeded %d | floor %d" %
		[day.day_number, game.budget_max, day.item_pool.size(),
		items.get_child_count(), day.min_available_items])

	# --- invariant 2, sampled every physics frame ---
	var worst_available: int = 999
	var starved_frames: int = 0

	var finished := false
	root.get_node("/root/Events").phase_finished.connect(
		func() -> void: finished = true)

	var guard := 0
	while not finished and guard < 8000:
		guard += 1
		await physics_frame
		var pool_exhausted: bool = phase._pending.is_empty()
		var available: int = items.get_child_count()
		if not pool_exhausted:
			worst_available = mini(worst_available, available)
			if available < day.min_available_items:
				starved_frames += 1
		# Alternate between grabbing and sorting so both costs are exercised.
		if claw.state == 0 and claw.can_drop and items.get_child_count() > 0:
			claw.position.x = clampf(items.get_child(0).position.x, claw.min_x, claw.max_x)
			claw.start_drop()
		var unsorted: Array = game.unsorted_items()
		if not unsorted.is_empty() and game.can_afford(&"sort"):
			RuleChecker.judge(unsorted[0], 0, day.active_rules)
			game.spend(&"sort")
			game.stats["sorted"] = int(game.stats["sorted"]) + 1

	# --- invariant 1 ---
	var drops: int = int(game.stats["drops"])
	var tool_uses: int = int(game.stats["tool_uses"])
	var sorts: int = int(game.stats["sorted"])
	var expected: int = drops * game.cost_of(&"drop") \
		+ tool_uses * game.cost_of(&"tool") \
		+ sorts * game.cost_of(&"sort")
	var spent: int = int(game.stats["spent"])
	print("actions: %d drops x%d + %d tools x%d + %d sorts x%d = %d" %
		[drops, game.cost_of(&"drop"), tool_uses, game.cost_of(&"tool"),
		sorts, game.cost_of(&"sort"), expected])
	print("budget: %d - %d spent = %d left" % [game.budget_max, spent, game.budget_left])
	assert(spent == expected, "budget spent does not equal the sum of action costs")
	assert(game.budget_max - game.budget_left == spent,
		"budget remaining does not match what was spent")
	assert(game.budget_left >= 0, "budget went negative")

	print("availability: lowest %d while the pool still had items (floor %d), "
		% [worst_available, day.min_available_items]
		+ "%d starved frames" % starved_frames)
	assert(starved_frames == 0,
		"the tank dropped below min_available_items while the pool was unexhausted")

	# There is no real-time timer anywhere: standing still must cost nothing.
	var idle_before: int = game.budget_left
	for i in 60:
		await physics_frame
	assert(game.budget_left == idle_before,
		"the budget drained while the player did nothing - time must be spent by "
		+ "actions, never by the clock")
	print("idling 60 frames cost 0 budget - no real-time timer anywhere")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
