# The machines measurably change play, by PLAYING and not by reading the
# resource. The old tier check passed for ages while the tier never once fired
# in a real run, because it set health by hand. This drives the real ShiftPhase:
# same seed, same drops, the only difference is which machines are running.
#   godot --headless --script tests/smoke_upgrade_play.gd
extends SceneTree

const SEED := 8080
# how long the rail is held down for, in physics frames
const RAIL_FRAMES := 40

var game: Node


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	Engine.time_scale = 6.0

	await _check_fast_rail()
	await _check_strong_grip()
	await _check_twin_arms()
	print("upgrade effects verified in play")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


## Fast Rail, off the Ocean Cleaning Drone: the claw covers more rail for the
## same time on the button, and is not frozen afterwards the way it used to be.
func _check_fast_rail() -> void:
	var plain: float = await _rail_travel(&"")
	var fitted: float = await _rail_travel(&"rel_cepat")
	print("  plain rail   : %.0f px in %d frames" % [plain, RAIL_FRAMES])
	print("  fast rail    : %.0f px in %d frames" % [fitted, RAIL_FRAMES])
	assert(plain > 0.0, "the claw did not move at all without the machine")
	assert(fitted > plain * 1.4,
		"the drone must measurably speed the rail up: %.0f vs %.0f" % [fitted, plain])
	assert(is_zero_approx(game.post_drop_lockout()),
		"the rail must not be frozen after a drop any more")


## Holds the rail down for a fixed stretch of shift and reports how far the claw
## actually travelled, through the same code the arrow keys drive.
func _rail_travel(upgrade_id: StringName) -> float:
	var shift: Node = await _start_shift(upgrade_id)
	var claw: Node2D = shift.get_node(
		"ClawView/TankLayer/TankContainer/TankViewport/TankWorld/Claw")
	claw.position.x = claw.min_x
	claw.button_axis = 1.0
	for i in RAIL_FRAMES:
		await physics_frame
	var travelled: float = claw.position.x - claw.min_x
	claw.button_axis = 0.0
	assert(travelled < claw.max_x - claw.min_x,
		"the claw hit the end of the rail, so the two runs are not comparable")
	await _end_shift(shift)
	return travelled


## Strong Grip, off the Recycling Station: the number the cockpit shows before
## the drop is the number the roll uses, so checking it is checking the promise.
func _check_strong_grip() -> void:
	var plain: float = await _grip_preview(&"")
	var fitted: float = await _grip_preview(&"cengkeraman_kuat")
	print("  plain grip   : %.2f" % plain)
	print("  strong grip  : %.2f" % fitted)
	# read off something heavy enough that 15 more points still fits under the
	# preview's own 0.95 ceiling, or the check would be measuring the clamp
	assert(plain <= 0.80,
		"the heaviest item in the day grips at %.2f - too easy to measure a bonus on"
		% plain)
	assert(is_equal_approx(fitted - plain, 0.15),
		"the station must add 15 points of grip: %.2f vs %.2f" % [fitted, plain])


func _grip_preview(upgrade_id: StringName) -> float:
	var shift: Node = await _start_shift(upgrade_id)
	var items: Node2D = shift.get_node(
		"ClawView/TankLayer/TankContainer/TankViewport/TankWorld/Items")
	assert(items.get_child_count() > 0, "nothing in the tank to read a grip chance off")
	# which items the shuffle put in the tank is not the point here, and a light
	# one pins the preview to its ceiling - so read the odds for the heaviest
	# thing the day can deliver, through the real item in the real tank
	var heavy: ItemData = null
	for item: ItemData in game.current_day().item_pool:
		if not item.is_container and (heavy == null or item.weight > heavy.weight):
			heavy = item
	var node: Node2D = items.get_child(0)
	node.data = heavy
	var chance: float = node.grip_chance()
	await _end_shift(shift)
	return chance


## Twin Arms, off the Reef Restoration Pod: a tool really is charged at 3, taken
## out of the budget by a real click on the real rack.
func _check_twin_arms() -> void:
	var plain: int = await _tool_charge(&"")
	var fitted: int = await _tool_charge(&"lengan_ganda")
	print("  plain tool   : charged %d" % plain)
	print("  twin arms    : charged %d" % fitted)
	assert(plain == game.base_cost(&"tool"), "a plain tool must charge the base cost")
	assert(fitted == 3, "the pod must charge 3 a tool, charged %d" % fitted)


## Uses one tool on one item at the real desk and returns what it took.
func _tool_charge(upgrade_id: StringName) -> int:
	var shift: Node = await _start_shift(upgrade_id, 3)
	var entry: CarriedItem = null
	for item: ItemData in game.current_day().item_pool:
		if item.hotspots.is_empty() or item.is_container:
			continue
		entry = game.add_to_inventory(item)
		break
	assert(entry != null, "no item with anything to find on it")
	var tool_id := StringName(entry.data.hotspots[0]["tool"])
	if not game.tool_unlocked(tool_id):
		game.current_day().available_tools.append(tool_id)

	shift._toggle_view()
	for i in 3:
		await process_frame
	var inspect: Control = shift.get_node("DeskView/UiLayer/Root/InspectPanel")
	inspect.show_entry(entry)
	await process_frame

	game.budget_left = game.budget_max
	var before: int = game.budget_left
	inspect._armed = tool_id
	inspect._use_tool()
	var charged: int = before - game.budget_left
	assert(entry.is_revealed(String(entry.data.hotspots[0]["reveals"])),
		"the tool charged but read nothing")
	await _end_shift(shift)
	return charged


## A real shift, with the named machine already built - which is the only way an
## upgrade gets fitted now.
func _start_shift(upgrade_id: StringName, day_number: int = 1) -> Node:
	game.start_run(SEED)
	for i in day_number - 1:
		game.advance_day()
	if upgrade_id != &"":
		_build_machine_granting(upgrade_id)
	var shift: Node = load("res://scenes/shift/shift_phase.tscn").instantiate()
	root.add_child(shift)
	for i in 4:
		await process_frame
	return shift


func _end_shift(shift: Node) -> void:
	root.remove_child(shift)
	shift.free()
	await process_frame


# materials are not what this test is about, so hand it enough and build
func _build_machine_granting(upgrade_id: StringName) -> void:
	for bp: BlueprintData in game.blueprints:
		if bp.unlocks_upgrade != upgrade_id:
			continue
		for category in ItemData.Category.values():
			game.materials[category] = 99
		for component: ComponentData in bp.components:
			game.craft_component(component)
		assert(game.build_blueprint(bp.id) != null, "%s refused to build" % bp.id)
		return
	assert(false, "no blueprint grants %s" % upgrade_id)
