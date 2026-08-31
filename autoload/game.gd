# run + day state. no scene tree stuff in here
extends Node

const DAY_DIR := "res://data/days/"
const BLUEPRINT_DIR := "res://data/blueprints/"
const UPGRADE_DIR := "res://data/upgrades/"
const SFX_DIR := "res://assets/audio/"
const SFX_POOL_SIZE := 6

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

var blueprints: Array[BlueprintData] = []
# category -> how many we can spend. credited at the report, not mid-shift
var materials: Dictionary = {}
var crafted: Dictionary = {}
var unlocked_blueprints: Array[StringName] = []

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
		apply_setting(key, float(settings[key]), false)
	_load_days()
	_load_tools()
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
	force_grip = 0
	materials = {}
	crafted = {}
	unlocked_blueprints = []
	equipped_upgrade = &""
	last_breakdown = {}
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


# the box stays - it is rubbish too, so opening it adds the contents and leaves
# the empty crate behind to be sorted like anything else. costs nothing: the
# cost of a crate is the cutter charge you had to still have, not shift time.
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
	for i in count:
		# pool already has boxes filtered out, so no box inside a box
		var made := CarriedItem.new(pool[stream.randi() % pool.size()])
		inventory.insert(clampi(at + 1 + i, 0, inventory.size()), made)
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


# unsorted minus SEALED boxes. an opened crate is ordinary rubbish and goes in a
# bin like anything else - only a box you haven't opened yet is unsortable.
func sortable_items() -> Array[CarriedItem]:
	var out: Array[CarriedItem] = []
	for e: CarriedItem in unsorted_items():
		if not e.is_container() or e.opened:
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
	# A sealed crate is only work you can still do if today's kit can open it -
	# AND there is budget left to sort what falls out. Cutting is free, so
	# without that second half an unopened crate keeps the shift alive forever
	# on an empty budget and the day never ends.
	if not sealed_containers().is_empty() and container_opener() != null \
			and can_afford(&"sort"):
		return true
	return not sortable_items().is_empty() and can_afford(&"sort")


func tool_unlocked(tool_id: StringName) -> bool:
	var day := current_day()
	return day != null and tool_id in day.available_tools


# Today's crate opener, or null if the kit can't open one. Nothing names the
# cutter: a tool declares itself the opener in its own .tres, so swapping which
# tool does the job is a data change.
func container_opener() -> ToolData:
	for t: ToolData in tools:
		if t.opens_containers and tool_unlocked(t.id):
			return t
	return null


func refill_budget() -> void:
	budget_left = budget_max
	Events.budget_changed.emit(budget_left, budget_max)


# a count of what happened, no points. there is no day score - the only thing
# a day pays out is the correctly sorted material, credited below.
func end_day_breakdown() -> Dictionary:
	var day := current_day()
	var quota: int = day.quota if day != null else 0
	var sorted_count: int = int(stats.get("sorted", 0))
	return {
		"correct": int(stats.get("correct", 0)),
		"wrong": int(stats.get("wrong", 0)),
		"sorted": sorted_count,
		"quota": quota,
		"quota_met": sorted_count >= quota,
	}


func commit_day_result(breakdown: Dictionary) -> void:
	last_breakdown = breakdown
	_credit_materials()


# category -> how many of today's items went into the RIGHT bin.
#
# This is the only door into the material store. An item dropped in the wrong
# bin is gone: it is not counted here, so it never becomes blueprint material.
# Nothing else in the codebase may add to `materials`.
func day_recovered() -> Dictionary:
	var out: Dictionary = {}
	for entry: CarriedItem in inventory:
		if entry.sorted_to == -1 or not entry.was_correct:
			continue
		var category: int = entry.expected_category
		out[category] = int(out.get(category, 0)) + 1
	return out


# called once, from the day report
func _credit_materials() -> void:
	var recovered := day_recovered()
	for category: int in recovered:
		materials[category] = int(materials.get(category, 0)) + int(recovered[category])
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


## Which of the three endings this run earned. Every blueprint built is the good
## one, none at all is the bad one, anything between is the regular one - so it
## scales if a fourth blueprint is ever authored.
func ending_kind() -> StringName:
	var built: int = unlocked_blueprints.size()
	if built <= 0:
		return &"bad"
	return &"good" if built >= blueprints.size() else &"regular"


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
		&"force_grip": force_grip = int(arg)
		&"set_seed":
			run_seed = int(arg)
			rng.seed = run_seed
