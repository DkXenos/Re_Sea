# run + day state. no scene tree stuff in here
extends Node

const DAY_DIR := "res://data/days/"
const TIER_DIR := "res://data/tiers/"
const BLUEPRINT_DIR := "res://data/blueprints/"
const UPGRADE_DIR := "res://data/upgrades/"
const SFX_DIR := "res://assets/audio/"
const SFX_POOL_SIZE := 6
const CLEAN_DAY_BONUS := 5
#const CLEAN_DAY_BONUS := 3   # too stingy, nobody ever felt it

# big prime, keeps box streams from colliding
const CONTAINER_STREAM := 104729

const ACTION_COST: Dictionary = {
	&"drop": 6,
	&"tool": 4,
	&"sort": 1,
}

var run_seed: int = 0
var rng := RandomNumberGenerator.new()
var days: Array[DayData] = []
var day_index: int = 0
# started at 100 originally but then nothing the meter drives was ever visible
const STARTING_HEALTH := 35
var ocean_health: int = STARTING_HEALTH

var tiers: Array[OceanTierData] = []
# what the ART shows. only updates at the day report, never mid-shift
var visual_tier: int = 3

var blueprints: Array[BlueprintData] = []
# category -> how many we can spend. credited at the report, not mid-shift
var materials: Dictionary = {}
var crafted: Dictionary = {}
var unlocked_blueprints: Array[StringName] = []
var forced_tier: int = -1

var upgrades: Array[UpgradeData] = []
var equipped_upgrade: StringName = &""

var inventory: Array[CarriedItem] = []
var containers_grabbed: int = 0
var tools: Array[ToolData] = []
var stats: Dictionary = {}
var last_breakdown: Dictionary = {}
var budget_max: int = 0
var budget_left: int = 0

var settings: Dictionary = {}
var vfx_intensity: float = 1.0
var show_hotspots: bool = true

var force_grip: int = 0  # 1 always, -1 never, 0 roll

# headless runs turn this off or godot yells about leaked streams
var sfx_enabled: bool = true

var feature_calibration_puzzle: bool = true

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_cache: Dictionary = {}


func _ready() -> void:
	_build_sfx_pool()
	settings = SaveSettings.load_all()
	for key: String in settings:
		if SaveSettings.TOGGLES.has(key):
			apply_toggle(key, bool(settings[key]), false)
		else:
			apply_setting(key, float(settings[key]), false)
	_load_days()
	_load_tools()
	_load_tiers()
	_load_blueprints()
	_load_upgrades()
	Events.sfx_requested.connect(play_sfx)
	Events.debug_command.connect(_on_debug_command)


func _load_days() -> void:
	days.assign(_load_dir(DAY_DIR))
	if days.is_empty():
		push_warning("No day data found in %s" % DAY_DIR)
	days.sort_custom(func(a: DayData, b: DayData) -> bool: return a.day_number < b.day_number)


func _load_tools() -> void:
	tools.assign(_load_dir("res://data/tools/"))
	tools.sort_custom(func(a: ToolData, b: ToolData) -> bool: return a.sort_order < b.sort_order)


func _load_tiers() -> void:
	tiers.assign(_load_dir(TIER_DIR))
	tiers.sort_custom(func(a: OceanTierData, b: OceanTierData) -> bool:
		return a.min_health < b.min_health)


func _load_blueprints() -> void:
	blueprints.assign(_load_dir(BLUEPRINT_DIR))
	blueprints.sort_custom(func(a: BlueprintData, b: BlueprintData) -> bool:
		return a.sort_order < b.sort_order)


func _load_upgrades() -> void:
	upgrades.assign(_load_dir(UPGRADE_DIR))
	upgrades.sort_custom(func(a: UpgradeData, b: UpgradeData) -> bool:
		return a.sort_order < b.sort_order)


func _load_dir(dir_path: String) -> Array:
	var out: Array = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	var names := dir.get_files()
	names.sort()
	for file_name: String in names:
		# exported builds hand you .tres.remap instead
		var clean := file_name.trim_suffix(".remap")
		if not clean.ends_with(".tres"):
			continue
		var res: Resource = load(dir_path + clean)
		if res != null:
			out.append(res)
	return out


func get_tool(tool_id: StringName) -> ToolData:
	for t: ToolData in tools:
		if t.id == tool_id:
			return t
	return null


func start_run(seed_value: int = 0) -> void:
	run_seed = seed_value if seed_value != 0 else int(Time.get_unix_time_from_system() * 1000.0) % 100000000
	rng.seed = run_seed
	day_index = 0
	ocean_health = STARTING_HEALTH
	force_grip = 0
	materials = {}
	crafted = {}
	unlocked_blueprints = []
	forced_tier = -1
	equipped_upgrade = &""
	last_breakdown = {}
	visual_tier = tier_for(ocean_health)
	Events.ocean_health_changed.emit(ocean_health)
	begin_day()


func current_day() -> DayData:
	if days.is_empty():
		return null
	return days[clampi(day_index, 0, days.size() - 1)]


func begin_day() -> void:
	inventory.clear()
	containers_grabbed = 0
	stats = {"correct": 0, "wrong": 0, "sorted": 0, "drops": 0, "tool_uses": 0, "spent": 0}
	var day := current_day()
	budget_max = day.budget if day != null else 0
	budget_left = budget_max
	Events.budget_changed.emit(budget_left, budget_max)
	# re-derive per day so one seed reproduces the whole run
	rng.seed = run_seed + day_index * 7919
	print("[Game] Day %d start | seed %d" % [day.day_number if day else 0, run_seed])
	if day != null:
		Events.day_started.emit(day)


func is_last_day() -> bool:
	return day_index >= days.size() - 1

func advance_day() -> void:
	day_index += 1
	begin_day()


func add_to_inventory(item: ItemData) -> CarriedItem:
	var entry := CarriedItem.new(item)
	if entry.is_container():
		# don't pull from Game.rng here - spawn timers share that stream, so the
		# contents would depend on how long the player stared at the tank
		entry.container_seed = run_seed + day_index * 7919 \
			+ CONTAINER_STREAM * (containers_grabbed + 1)
		containers_grabbed += 1
	inventory.append(entry)
	return entry


# box leaves the inventory, its contents take its place. costs nothing.
func open_container(entry: CarriedItem) -> Array[CarriedItem]:
	var out: Array[CarriedItem] = []
	var day := current_day()
	if day == null or entry == null or not entry.is_container() or entry.opened:
		return out
	var pool := day.content_pool()
	if pool.is_empty():
		push_warning("Day %d has a box but nothing for it to contain" % day.day_number)
		return out
	var stream := RandomNumberGenerator.new()
	stream.seed = entry.container_seed
	var count := day.contents_count(stream)
	var at := inventory.find(entry)
	entry.opened = true
	inventory.erase(entry)
	for i in count:
		# pool already has boxes filtered out, so no box inside a box
		var made := CarriedItem.new(pool[stream.randi() % pool.size()])
		inventory.insert(clampi(at + i, 0, inventory.size()), made)
		out.append(made)
	Events.container_opened.emit(entry, out)
	return out


# debug only
func fill_inventory(count: int) -> void:
	var day := current_day()
	if day == null or day.item_pool.is_empty():
		return
	for i in count:
		add_to_inventory(day.item_pool[rng.randi() % day.item_pool.size()])


func unsorted_items() -> Array[CarriedItem]:
	var out: Array[CarriedItem] = []
	for e: CarriedItem in inventory:
		if e.sorted_to == -1:
			out.append(e)
	return out


# unsorted minus sealed boxes - a box counts as work left but can't go in a bin
func sortable_items() -> Array[CarriedItem]:
	var out: Array[CarriedItem] = []
	for e: CarriedItem in unsorted_items():
		if not e.is_container():
			out.append(e)
	return out


# TODO: box left sealed at the end of the shift just vanishes. not in the
# report, not in the after-day haul. probably needs a line somewhere.
func sealed_containers() -> Array[CarriedItem]:
	var out: Array[CarriedItem] = []
	for e: CarriedItem in unsorted_items():
		if e.is_container():
			out.append(e)
	return out


func base_cost(action: StringName) -> int:
	return int(ACTION_COST.get(action, 0))


func cost_of(action: StringName) -> int:
	var up := upgrade()
	if up != null:
		match action:
			&"drop":
				if up.drop_cost >= 0:
					return up.drop_cost
			&"tool":
				if up.tool_cost >= 0:
					return up.tool_cost
	return base_cost(action)


func can_afford(action: StringName) -> bool:
	return budget_left >= cost_of(action)


# spends even when a tool reveals nothing. that's the risk.
func spend(action: StringName) -> bool:
	return spend_amount(cost_of(action))


func spend_amount(cost: int) -> bool:
	if budget_left < cost:
		return false
	budget_left -= cost
	stats["spent"] = int(stats.get("spent", 0)) + cost
	Events.budget_changed.emit(budget_left, budget_max)
	return true


func can_still_act() -> bool:
	if can_afford(&"drop"):
		return true
	# opening is free, so a sealed box always counts as something left to do.
	# still not sure opening should be free tbh
	if not sealed_containers().is_empty() and can_afford(&"sort"):
		return true
	return not sortable_items().is_empty() and can_afford(&"sort")


func tool_unlocked(tool_id: StringName) -> bool:
	var day := current_day()
	return day != null and tool_id in day.available_tools


func refill_budget() -> void:
	budget_left = budget_max
	Events.budget_changed.emit(budget_left, budget_max)


# every term separate so the report can show its working
# FIXME these numbers are guesses. correct=2 / wrong=-4 / short=-3 feels ok on
# days 1-3 and way too harsh on 5. needs an actual playtest.
func end_day_breakdown() -> Dictionary:
	var day := current_day()
	var quota: int = day.quota if day != null else 0
	var correct: int = int(stats.get("correct", 0))
	var wrong: int = int(stats.get("wrong", 0))
	var sorted_count: int = int(stats.get("sorted", 0))
	var shortfall: int = maxi(0, quota - sorted_count) * 3
	var quota_met: bool = sorted_count >= quota
	var clean_bonus: int = CLEAN_DAY_BONUS if wrong == 0 and quota_met else 0
	var delta: int = (correct * 2) - (wrong * 4) - shortfall + clean_bonus
	var before: int = ocean_health
	var after: int = clampi(before + delta, 0, 100)
	return {
		"correct": correct,
		"wrong": wrong,
		"sorted": sorted_count,
		"quota": quota,
		"shortfall": shortfall,
		"clean_bonus": clean_bonus,
		"delta": delta,
		"health_before": before,
		"health_after": after,
		"quota_met": quota_met,
	}


func commit_day_result(breakdown: Dictionary) -> void:
	last_breakdown = breakdown
	ocean_health = int(breakdown["health_after"])
	Events.ocean_health_changed.emit(ocean_health)
	_credit_materials()
	refresh_visual_tier()


# called once, from the day report
func _credit_materials() -> void:
	for entry: CarriedItem in inventory:
		if entry.sorted_to == -1 or not entry.was_correct:
			continue
		var category: int = entry.expected_category
		materials[category] = int(materials.get(category, 0)) + 1
	Events.blueprints_changed.emit()


func material_count(category: int) -> int:
	return int(materials.get(category, 0))

# not used any more, the blueprint strip counts parts instead. leaving it in
# case the flat total comes back.
func total_materials() -> int:
	var n := 0
	for c in materials:
		n += int(materials[c])
	return n


# category -> how many short. empty dict means craftable
func craft_shortfall(component: ComponentData) -> Dictionary:
	return component.shortfall(materials)


func component_crafted(component: ComponentData) -> bool:
	return bool(crafted.get(component.id, false))


func can_craft(component: ComponentData) -> bool:
	return not component_crafted(component) and component.affordable(materials)


func craft_component(component: ComponentData) -> bool:
	# affordability is checked on the whole cost first, so a component that's
	# short on its 2nd material doesn't eat the 1st
	if not can_craft(component):
		return false
	for category: int in component.requirements:
		materials[category] = int(materials.get(category, 0)) - int(component.requirements[category])
	crafted[component.id] = true
	Events.component_crafted.emit(component)
	Events.blueprints_changed.emit()
	return true


func blueprint_ready(bp: BlueprintData) -> bool:
	return not blueprint_unlocked(bp.id) and bp.is_complete(crafted)


func ready_blueprints() -> Array[BlueprintData]:
	var out: Array[BlueprintData] = []
	for bp: BlueprintData in blueprints:
		if blueprint_ready(bp):
			out.append(bp)
	return out


func build_blueprint(blueprint_id: StringName) -> BlueprintData:
	for bp: BlueprintData in blueprints:
		if bp.id != blueprint_id or not blueprint_ready(bp):
			continue
		unlocked_blueprints.append(bp.id)
		if bp.forces_tier >= 0:
			forced_tier = maxi(forced_tier, bp.forces_tier)
		set_ocean_health(ocean_health + bp.health_gain)
		refresh_visual_tier()
		Events.blueprints_changed.emit()
		return bp
	return null


func blueprint_unlocked(blueprint_id: StringName) -> bool:
	return blueprint_id in unlocked_blueprints


func upgrade() -> UpgradeData:
	for up: UpgradeData in upgrades:
		if up.id == equipped_upgrade:
			return up
	return null


func upgrade_unlocked(up: UpgradeData) -> bool:
	for bp: BlueprintData in blueprints:
		if bp.unlocks_upgrade == up.id:
			return blueprint_unlocked(bp.id)
	return unlocked_blueprints.size() >= up.unlock_after_blueprints


# pass the one already equipped to take it off again
func equip_upgrade(upgrade_id: StringName) -> void:
	equipped_upgrade = &"" if upgrade_id == equipped_upgrade else upgrade_id
	Events.upgrade_equipped.emit(equipped_upgrade)
	Events.budget_changed.emit(budget_left, budget_max)


func grip_delta() -> float:
	var up := upgrade()
	return up.grip_delta if up != null else 0.0


func coarse_readings() -> bool:
	var up := upgrade()
	return up != null and up.coarse_readings


func move_speed_multiplier() -> float:
	var up := upgrade()
	return up.move_speed_multiplier if up != null else 1.0


func post_drop_lockout() -> float:
	var up := upgrade()
	return up.post_drop_lockout if up != null else 0.0


func tier_for(health: int) -> int:
	var best: int = 0
	for t: OceanTierData in tiers:
		if health >= t.min_health:
			best = maxi(best, t.tier)
	return best


func tier_data(tier: int) -> OceanTierData:
	for t: OceanTierData in tiers:
		if t.tier == tier:
			return t
	return null


func current_tier() -> OceanTierData:
	return tier_data(visual_tier)


# returns the new tier, or -1 if nothing moved. only call at the day report.
func refresh_visual_tier() -> int:
	var was := visual_tier
	visual_tier = tier_for(ocean_health)
	if forced_tier >= 0 and visual_tier < forced_tier:
		# ignore the forced tier if health has dropped below the one under it,
		# otherwise you get a healed reef sitting over a dying ocean
		var below := tier_data(forced_tier - 1)
		if below == null or ocean_health >= below.min_health:
			visual_tier = forced_tier
	return visual_tier if visual_tier != was else -1


func set_ocean_health(value: int) -> void:
	ocean_health = clampi(value, 0, 100)
	Events.ocean_health_changed.emit(ocean_health)


func is_game_over() -> bool:
	return ocean_health <= 0


func apply_setting(key: String, value: float, persist: bool = true) -> void:
	settings[key] = clampf(value, 0.0, 1.0)
	match key:
		"master": _set_bus("Master", settings[key])
		"music": _set_bus("Music", settings[key])
		"sfx": _set_bus("SFX", settings[key])
		"vfx":
			vfx_intensity = settings[key]
			Events.vfx_intensity_changed.emit(vfx_intensity)
	if persist:
		SaveSettings.save_all(settings)


# separate from apply_setting so a bool never gets clamped into a float
func apply_toggle(key: String, value: bool, persist: bool = true) -> void:
	settings[key] = value
	match key:
		"hotspots":
			show_hotspots = value
			Events.hotspots_visible_changed.emit(show_hotspots)
	if persist:
		SaveSettings.save_all(settings)


func _set_bus(bus_name: String, value: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	AudioServer.set_bus_mute(idx, is_zero_approx(value))
	AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(value, 0.001, 1.0)))


func _build_sfx_pool() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)


func play_sfx(sfx_name: StringName) -> void:
	if not sfx_enabled:
		return
	var stream: AudioStream = _sfx_cache.get(sfx_name, null)
	if stream == null:
		var path := SFX_DIR + String(sfx_name) + ".wav"
		if not ResourceLoader.exists(path):
			return
		stream = load(path)
		_sfx_cache[sfx_name] = stream
	for player: AudioStreamPlayer in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return
	# TODO: pool's full, oldest one should get stolen. 6 is enough for now


func stop_all_sfx() -> void:
	for player: AudioStreamPlayer in _sfx_players:
		player.stop()
		player.stream = null
	_sfx_cache.clear()


func _exit_tree() -> void:
	stop_all_sfx()


func _on_debug_command(command: StringName, arg: Variant) -> void:
	match command:
		&"refill_budget": refill_budget()
		&"fill_inventory": fill_inventory(int(arg))
		&"set_health": set_ocean_health(int(arg))
		&"force_grip": force_grip = int(arg)
		&"set_seed":
			run_seed = int(arg)
			rng.seed = run_seed
		&"toggle_hotspots": apply_toggle("hotspots", not show_hotspots)
