# the sealed box, driven through the real UI. what has to hold: never
# sortable, opening costs nothing, the empty crate is kept and sortable,
# contents fixed by the run seed and not by
# when you got round to opening it, and no box inside a box.
#   godot --headless --script tests/smoke_box.gd
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


## The desk gives it no bin and no Open button - the crate opens by cutting it,
## and cutting spends nothing.
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

	assert(_open_button(inventory) == null,
		"the crate card still offers an Open button")
	assert(game.sortable_items().size() == 1,
		"a sealed box counted as something a bin would take")

	# whatever today's kit is, exactly one tool in it opens crates
	var opener: ToolData = game.container_opener()
	assert(opener != null, "day %d has a crate and no tool that opens one"
		% day.day_number)
	assert(opener.display_name in _card_text(inventory),
		"the crate card does not say %s is what opens it" % opener.display_name)

	# a bin refuses a sealed crate, and the refusal costs nothing
	inspect.show_entry(box)
	var budget_before: int = game.budget_left
	bins.bin_chosen.emit(ItemData.Category.RESIDUE)
	await process_frame
	assert(box.sorted_to == -1, "a bin took a sealed crate")
	assert(game.budget_left == budget_before, "refusing a sealed crate cost budget")

	# so does an inspection tool that is not the opener
	for other: ToolData in game.tools:
		if other.opens_containers or not game.tool_unlocked(other.id):
			continue
		inspect._armed = other.id
		inspect._use_tool()
		assert(not box.opened, "%s opened a crate it has no business opening"
			% other.display_name)
		assert(game.budget_left == budget_before,
			"%s charged for bouncing off a sealed crate" % other.display_name)

	var inventory_before: int = game.inventory.size()
	inspect._armed = opener.id
	inspect._use_tool()
	inspect._armed = &""
	await process_frame
	assert(box.opened, "%s did not open the crate" % opener.display_name)
	assert(game.budget_left == budget_before,
		"opening a crate spent %d budget" % [budget_before - game.budget_left])
	# the empty crate is rubbish too - it stays, and a bin will now take it
	assert(game.inventory.has(box), "the opened crate was thrown away instead of kept")
	assert(box in game.sortable_items(), "the opened crate cannot be sorted")
	assert(box.display_texture() != box.data.texture,
		"the opened crate still draws its closed art")

	var gained: int = game.inventory.size() - inventory_before
	assert(gained >= day.box_contents_min and gained <= day.box_contents_max,
		"a box yielded %d items, outside %d-%d"
		% [gained, day.box_contents_min, day.box_contents_max])
	print("  %s: %d items out, empty crate kept and sortable, budget still %d"
		% [opener.display_name, gained, game.budget_left])

	# A crate you can open for free must not count as work once there is no
	# budget left to sort what comes out of it - that is a shift that never
	# ends.
	var spare: CarriedItem = game.add_to_inventory(day.box_item)
	assert(spare.is_container() and not spare.opened, "fixture is not a sealed crate")
	game.budget_left = 0
	assert(not game.can_still_act(),
		"a sealed crate kept the shift alive with nothing left to spend")
	game.budget_left = game.cost_of(&"sort")
	assert(game.can_still_act(),
		"a sealed crate stopped counting as work while a sort was still affordable")
	game.inventory.erase(spare)
	game.budget_left = budget_before
	print("  a sealed crate is only work while a sort is still affordable")

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


# any button on a card that carries its own label, i.e. not the invisible
# full-card hit area
func _open_button(inventory: Control) -> Button:
	for card: Node in inventory.get_node("Scroll/Grid").get_children():
		for child: Node in card.get_children():
			if child is Button and (child as Button).text != "":
				return child as Button
	return null


func _card_text(inventory: Control) -> String:
	var out := ""
	for card: Node in inventory.get_node("Scroll/Grid").get_children():
		for label: Node in card.find_children("*", "Label", true, false):
			out += (label as Label).text + "\n"
	return out
