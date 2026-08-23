## Proves the central claim of the data model: a 15th item, a 7th rule and a
## 6th day can be added with new .tres files and zero code changes. Creates
## them, drives both phases with them, then deletes them again.
##   godot --headless --script tools/smoke/smoke_extensibility.gd
extends SceneTree

const ITEM_PATH := "res://data/items/_tmp_test_item.tres"
const RULE_PATH := "res://data/rules/_tmp_test_rule.tres"
const DAY_PATH := "res://data/days/day_06.tres"


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	var before: int = game.days.size()

	# --- item #15: a trap that looks like clean glass but is coated ---
	var item: ItemData = ItemData.new()
	item.id = &"test_coated_jar"
	item.display_name = "Toples Uji Berlapis"
	item.texture = load("res://assets/items/item_glass_jar.png")
	item.frames = load("res://data/frames/item_glass_jar_frames.tres")
	item.weight = 1.8
	item.visible_material = "kaca"
	item.visible_label = "UJI"
	item.true_material = "kaca berlapis plastik"
	item.is_multilayer = true
	item.correct_category = ItemData.Category.RECYCLABLE
	item.source_batch = &"uji_coba"
	var spots: Array[Dictionary] = [{
		"pos": Vector2(0.5, 0.5), "radius": 0.2,
		"tool": "cutter", "reveals": "true_material"}]
	item.hotspots = spots
	assert(ResourceSaver.save(item, ITEM_PATH) == OK)

	# --- rule #7: a new override, higher priority than anything shipped ---
	var rule: RuleData = RuleData.new()
	rule.id = &"r_test_coating"
	rule.text = "Aturan uji: barang berlapis plastik masuk B3."
	rule.applies_when = {"is_multilayer": true}
	rule.forces_category = ItemData.Category.HAZARD
	rule.priority = 999
	assert(ResourceSaver.save(rule, RULE_PATH) == OK)

	# --- day #6 using both ---
	var day: DayData = DayData.new()
	day.day_number = 6
	day.quota = 1
	day.budget = 40
	var day_tools: Array[StringName] = [&"cutter"]
	day.available_tools = day_tools
	day.initial_seed_fraction = 1.0
	day.min_available_items = 1
	day.intro_text = "Hari uji."
	var rules: Array[RuleData] = [load(RULE_PATH)]
	day.active_rules = rules
	var pool: Array[ItemData] = [load(ITEM_PATH)]
	day.item_pool = pool
	assert(ResourceSaver.save(day, DAY_PATH) == OK)

	# The day list is a directory scan, so the new file is simply picked up.
	game._load_days()
	assert(game.days.size() == before + 1, "new day .tres was not picked up")
	print("days: %d -> %d, no code changed" % [before, game.days.size()])

	game.start_run(5150)
	game.day_index = game.days.size() - 1
	game.begin_day()
	var loaded_item: ItemData = game.current_day().item_pool[0]
	var verdict := RuleChecker.resolve(loaded_item, game.current_day().active_rules)
	assert(int(verdict["category"]) == ItemData.Category.HAZARD,
		"new rule did not override the new item")
	print("rule #7 (priority %d) overrode item #15: %s -> B3" %
		[rule.priority, loaded_item.visible_material])

	# Claw phase spawns it from data alone.
	var claw_phase: Node = load("res://scenes/claw/claw_phase.tscn").instantiate()
	root.add_child(claw_phase)
	await physics_frame
	var items: Node = claw_phase.get_node(
		"TankLayer/TankContainer/TankViewport/TankWorld/Items")
	assert(items.get_child_count() == 1, "new item did not spawn in the tank")
	assert(items.get_child(0).data.id == &"test_coated_jar", "wrong item spawned")
	print("claw phase spawned it with its own texture and SpriteFrames")
	claw_phase.queue_free()
	await process_frame

	# Desk phase inspects it, and its brand new hotspot reveals.
	game.add_to_inventory(loaded_item)
	var desk: Node = load("res://scenes/desk/desk_phase.tscn").instantiate()
	root.add_child(desk)
	await process_frame
	var inspect: Control = desk.get_node("UiLayer/Root/InspectPanel")
	inspect._armed = &"cutter"
	inspect._use_tool_at(Vector2(180, 180)) # centre = the new hotspot
	assert(inspect.entry.is_revealed("true_material"), "new hotspot did not reveal")
	print("desk phase revealed its hotspot: %s" % loaded_item.get_field_text("true_material"))

	# Clean up so the repo is left exactly as it was. Drop every reference to
	# the temporary resources first, or they outlive the files they came from.
	desk.queue_free()
	await process_frame
	game.inventory.clear()
	game.day_index = 0
	item = null
	rule = null
	day = null
	loaded_item = null
	rules.clear()
	pool.clear()
	for path: String in [ITEM_PATH, RULE_PATH, DAY_PATH]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game._load_days()
	assert(game.days.size() == before, "cleanup failed")
	print("removed the test .tres files; days back to %d" % game.days.size())

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
