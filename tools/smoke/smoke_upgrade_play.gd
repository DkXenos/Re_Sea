# the day-1 upgrades measurably change play, by PLAYING not by reading the
# resource. the old tier check passed for ages while the tier never once fired
# in a real run, because it set health by hand. this drives the real
# ShiftPhase: same seed, same drops, only difference is what's fitted.
#   godot --headless --script tools/smoke/smoke_upgrade_play.gd
extends SceneTree

const SEED := 8080
const DROPS := 4

var game: Node


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	Engine.time_scale = 6.0

	var plain: Dictionary = await _play_shift(&"")
	var light: Dictionary = await _play_shift(&"cakar_ringan")
	print("  plain claw     : %d drops cost %d, %d grabbed, preview %.2f"
		% [plain["drops"], plain["spent"], plain["grabbed"], plain["chance"]])
	print("  cakar ringan   : %d drops cost %d, %d grabbed, preview %.2f"
		% [light["drops"], light["spent"], light["grabbed"], light["chance"]])

	assert(plain["drops"] == light["drops"], "the two runs must make the same drops")
	assert(int(light["spent"]) < int(plain["spent"]),
		"a cheaper claw must measurably lower what a shift spends")
	assert(int(plain["spent"]) - int(light["spent"]) == int(plain["drops"]) * 2,
		"each drop should cost exactly 2 less")
	# The number the HUD shows before the drop is the number the roll uses, so
	# checking it is checking the grip outcome the player was promised.
	assert(is_equal_approx(float(plain["chance"]) - float(light["chance"]), 0.15),
		"a cheaper claw must measurably lower the grip chance")

	await _check_coarse_scanner()
	print("upgrade effects verified in play")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


## Plays the opening of a real shift with one upgrade fitted, dropping on the
## same item each time so the two runs are comparable.
func _play_shift(upgrade_id: StringName) -> Dictionary:
	game.start_run(SEED)
	game.equip_upgrade(upgrade_id)
	var shift: Node = load("res://scenes/shift/shift_phase.tscn").instantiate()
	root.add_child(shift)
	for i in 4:
		await process_frame

	var world: Node = shift.get_node(
		"ClawView/TankLayer/TankContainer/TankViewport/TankWorld")
	var claw: Node2D = world.get_node("Claw")
	var items: Node2D = world.get_node("Items")
	var chance := 0.0
	var drops := 0
	var guard := 0
	while drops < DROPS and guard < 3000:
		guard += 1
		await physics_frame
		if claw.is_busy() or claw.is_rail_locked() or not game.can_afford(&"drop"):
			continue
		if items.get_child_count() == 0:
			break
		var target: Node2D = items.get_child(0)
		claw.position.x = clampf(target.position.x, claw.min_x, claw.max_x)
		if drops == 0:
			chance = target.grip_chance()
		claw.start_drop()
		drops += 1
	while claw.is_busy() and guard < 6000:
		guard += 1
		await physics_frame

	var out := {"drops": drops, "spent": int(game.stats.get("spent", 0)),
		"grabbed": game.inventory.size(), "chance": chance}
	root.remove_child(shift)
	shift.free()
	await process_frame
	return out


## Pemindai Kasar: the first use is cheap and says only that something is here;
## the second costs the normal price and reads it.
func _check_coarse_scanner() -> void:
	game.start_run(SEED)
	game.day_index = 3  # a day with tools available
	game.begin_day()
	game.equip_upgrade(&"pemindai_kasar")
	var shift: Node = load("res://scenes/shift/shift_phase.tscn").instantiate()
	root.add_child(shift)
	for i in 4:
		await process_frame

	var entry: CarriedItem = null
	for item: ItemData in game.current_day().item_pool:
		if item.hotspots.is_empty():
			continue
		entry = game.add_to_inventory(item)
		break
	assert(entry != null, "no item with a hotspot to probe")
	var spot: Dictionary = entry.data.hotspots[0]
	var tool_id := StringName(spot["tool"])

	var desk: Node = shift.get_node("DeskView")
	shift._toggle_view()
	for i in 3:
		await process_frame
	var inspect: Control = desk.get_node("UiLayer/Root/InspectPanel")
	inspect.show_entry(entry)
	await process_frame

	# Whatever day this is, the probe has to be affordable and the tool present.
	game.budget_left = game.budget_max
	if not game.tool_unlocked(tool_id):
		game.current_day().available_tools.append(tool_id)
	var point: Vector2 = Vector2(inspect._view.size) * 0.5 \
		+ (Vector2(spot["pos"]) - Vector2(0.5, 0.5)) * inspect._item_span() * inspect.BASE_SCALE

	var before: int = game.budget_left
	inspect._armed = tool_id
	inspect._use_tool_at(point)
	var first_cost: int = before - game.budget_left
	assert(first_cost == 2, "the coarse probe should cost 2, cost %d" % first_cost)
	assert(not entry.is_revealed(String(spot["reveals"])),
		"the coarse probe must not read the value")
	assert(entry.is_probed(String(spot["reveals"])), "the coarse probe must record the find")

	before = game.budget_left
	inspect._armed = tool_id
	inspect._use_tool_at(point)
	var second_cost: int = before - game.budget_left
	assert(second_cost == 4, "the full reading should cost the base 4, cost %d" % second_cost)
	assert(entry.is_revealed(String(spot["reveals"])), "the second use must read the value")
	print("  pemindai kasar : probe cost %d and read nothing, second cost %d and read it"
		% [first_cost, second_cost])

	root.remove_child(shift)
	shift.free()
	await process_frame
