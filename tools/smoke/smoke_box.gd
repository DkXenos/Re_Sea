# the sealed box, driven through the real UI. what has to hold: never
# sortable, opening costs nothing, the empty crate is kept and sortable,
# contents fixed by the run seed and not by
# when you got round to opening it, and no box inside a box.
#   godot --headless --script tools/smoke/smoke_box.gd
extends SceneTree

const SEED := 77001

var game: Node


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	game.start_run(SEED)

	_check_data()
	await _check_tank_spawns()
	await _check_open_through_the_desk()
	_check_determinism()
	_check_no_nested_boxes()
	print("mystery box verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


## Day 1 stays clean, the later days carry boxes, and every one of them is
## data - no day names a box in code.
func _check_data() -> void:
	var with_boxes: int = 0
	for day: DayData in game.days:
		var boxes: int = day.spawn_pool().size() - day.item_pool.size()
		assert(boxes == maxi(0, day.box_spawn_count),
			"day %d spawns %d boxes, not %d" % [day.day_number, boxes, day.box_spawn_count])
		if day.day_number == 1:
			assert(day.box_spawn_count == 0, "day 1 must stay a box-free tutorial")
		if boxes > 0:
			with_boxes += 1
		assert(day.box_contents_min >= 1 and day.box_contents_max >= day.box_contents_min,
			"day %d has an impossible contents range" % day.day_number)
	assert(with_boxes >= 3, "only %d days spawn a box" % with_boxes)
	print("  boxes per day: %s" % [game.days.map(
		func(d: DayData) -> int: return d.box_spawn_count)])


## The tank spawns it from the day's data alone and treats it as one more thing
## on the seabed: same scene, same grip roll, same drop cost.
func _check_tank_spawns() -> void:
	game.day_index = _first_box_day()
	game.begin_day()
	var day: DayData = game.current_day()
	var claw_phase: Node = load("res://scenes/claw/claw_phase.tscn").instantiate()
	root.add_child(claw_phase)
	await physics_frame
	var items: Node = claw_phase.get_node(
		"TankLayer/TankContainer/TankViewport/TankWorld/Items")
	var seen_box: Node = null
	for child: Node in items.get_children():
		if child.data.is_container:
			seen_box = child
	# The seeded fraction may hold the box back as a pending drift-in, which is
	# equally correct - what matters is that the pool carries it.
	var pool_boxes: int = 0
	for entry: ItemData in day.spawn_pool():
		if entry.is_container:
			pool_boxes += 1
	assert(pool_boxes == day.box_spawn_count, "the spawn pool lost a box")
	if seen_box != null:
		var chance: float = seen_box.grip_chance()
		assert(chance > 0.5 and chance < 0.9,
			"a box should grip like a mid-weight item, got %.2f" % chance)
		print("  box rests on the seabed, grip %d%% at weight %.1f"
			% [int(round(chance * 100.0)), seen_box.data.weight])
	claw_phase.queue_free()
	await process_frame


## The desk offers it Buka and nothing else, and pressing it spends nothing.
func _check_open_through_the_desk() -> void:
	var day: DayData = game.current_day()
	game.add_to_inventory(day.item_pool[0])
	var box: CarriedItem = game.add_to_inventory(day.box_item)
	assert(box.is_container(), "the box resource is not marked as a container")

	var desk: Node = load("res://scenes/desk/desk_phase.tscn").instantiate()
	root.add_child(desk)
	await process_frame
	var inventory: Control = desk.get_node("UiLayer/Root/InventoryPanel")
	var inspect: Control = desk.get_node("UiLayer/Root/InspectPanel")
	var bins: Control = desk.get_node("UiLayer/Root/BinRow")

	# A box is never what the desk opens on, and a bin never takes one.
	assert(inspect.entry != null and not inspect.entry.is_container(),
		"the desk selected a sealed box for inspection")
	assert(game.sortable_items().size() == 1,
		"a sealed box counted as something a bin would take")

	var button: Button = _open_button(inventory)
	assert(button != null, "the box card has no Buka button")
	var budget_before: int = game.budget_left
	var inventory_before: int = game.inventory.size()
	button.pressed.emit()
	# The card holds the opened crate on screen briefly, so the swap lands on a
	# timer rather than on the next frame.
	var waited: int = 0
	while not box.opened and waited < 400:
		waited += 1
		await process_frame
	assert(box.opened, "Buka did not open the box within %d frames" % waited)
	assert(game.budget_left == budget_before,
		"opening a box spent %d budget" % [budget_before - game.budget_left])
	# the empty crate is rubbish too - it stays, and a bin will now take it
	assert(game.inventory.has(box), "the opened crate was thrown away instead of kept")
	assert(box in game.sortable_items(), "the opened crate cannot be sorted")
	assert(box.display_texture() != box.data.texture,
		"the opened crate still draws its closed art")

	var gained: int = game.inventory.size() - inventory_before
	assert(gained >= day.box_contents_min and gained <= day.box_contents_max,
		"a box yielded %d items, outside %d-%d"
		% [gained, day.box_contents_min, day.box_contents_max])
	assert(_open_button(inventory) == null, "the opened crate still offers Buka")
	print("  Buka: %d items out, empty crate kept and sortable, budget still %d"
		% [gained, game.budget_left])

	# What came out is an ordinary grabbed item from here on: it inspects, it
	# sorts, and it spends the sort cost like anything else.
	inventory.select_first()
	await process_frame
	var entry: CarriedItem = inspect.entry
	assert(entry != null, "nothing selectable after opening a box")
	var spent_before: int = game.budget_left
	bins.bin_chosen.emit(int(RuleChecker.resolve(entry.data, day.active_rules)["category"]))
	await process_frame
	assert(entry.sorted_to != -1, "a box's contents could not be sorted")
	assert(game.budget_left == spent_before - game.cost_of(&"sort"),
		"sorting a box's contents did not cost the sort price")
	print("  contents sort like any grabbed item (-%d)" % game.cost_of(&"sort"))

	desk.queue_free()
	await process_frame


## Same seed, same box, same contents - and it must not matter WHEN the box was
## opened. The tank's spawn timers advance Game.rng in real time, so contents
## drawn from that stream would drift with the frame rate.
func _check_determinism() -> void:
	var runs: Array[String] = []
	for attempt in 2:
		game.start_run(SEED)
		game.day_index = _first_box_day()
		game.begin_day()
		var day: DayData = game.current_day()
		var ids: Array[String] = []
		for i in 3:
			var box: CarriedItem = game.add_to_inventory(day.box_item)
			# Burn a different amount of the shared stream each time round, the
			# way a longer or shorter look at the tank would.
			for burn in attempt * 17 + i:
				game.rng.randf()
			for made: CarriedItem in game.open_container(box):
				ids.append(String(made.data.id))
		runs.append(", ".join(ids))
	assert(runs[0] == runs[1],
		"box contents changed between identical seeds:\n    %s\n    %s" % [runs[0], runs[1]])
	print("  seed %d always yields: %s" % [SEED, runs[0]])


func _check_no_nested_boxes() -> void:
	game.start_run(SEED)
	var checked: int = 0
	for index in game.days.size():
		game.day_index = index
		game.begin_day()
		var day: DayData = game.current_day()
		if day.box_item == null or day.box_spawn_count <= 0:
			continue
		for entry: ItemData in day.content_pool():
			assert(not entry.is_container,
				"day %d lets a box contain a box" % day.day_number)
		# Opened for real, many times over, rather than trusted to the filter.
		for i in 60:
			for made: CarriedItem in game.open_container(
					game.add_to_inventory(day.box_item)):
				assert(not made.is_container(), "a box contained another box")
				checked += 1
	game.day_index = 0
	game.begin_day()
	print("  %d drawn contents, not one of them a box" % checked)


func _first_box_day() -> int:
	for index in game.days.size():
		if game.days[index].box_spawn_count > 0:
			return index
	assert(false, "no day spawns a box")
	return 0


func _open_button(inventory: Control) -> Button:
	for card: Node in inventory.get_node("Scroll/Grid").get_children():
		for child: Node in card.get_children():
			if child is Button and (child as Button).text == Strings.t("box_open"):
				return child as Button
	return null
