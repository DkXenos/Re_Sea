## Autoload 2 of 2: run and day state. Owns the seeded RNG, the day list, the
## inventory carried from claw phase to desk phase, tool charges, ocean health
## and the audio/vfx settings. No scene tree knowledge lives here.
extends Node

const DAY_DIR := "res://data/days/"
const SFX_DIR := "res://assets/audio/"
const SFX_POOL_SIZE := 6

# --- run ---
var run_seed: int = 0
var rng := RandomNumberGenerator.new()
var days: Array[DayData] = []
var day_index: int = 0
var ocean_health: int = 100

# --- current day ---
var inventory: Array[CarriedItem] = []
var tool_charges: Dictionary = {} ## tool id -> remaining
var tools: Array[ToolData] = []
var stats: Dictionary = {}

# --- settings ---
var settings: Dictionary = {}
var vfx_intensity: float = 1.0

# --- debug switches (only ever set by the F1 overlay) ---
var force_grip: int = 0 ## 1 = always succeed, -1 = always fail, 0 = roll

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_cache: Dictionary = {}


func _ready() -> void:
	_build_sfx_pool()
	settings = SaveSettings.load_all()
	for key: String in settings:
		apply_setting(key, settings[key], false)
	_load_days()
	_load_tools()
	Events.sfx_requested.connect(play_sfx)
	Events.debug_command.connect(_on_debug_command)


# ---------------------------------------------------------------- content load

func _load_days() -> void:
	days.clear()
	var dir := DirAccess.open(DAY_DIR)
	if dir == null:
		push_warning("No day data directory yet: %s" % DAY_DIR)
		return
	var names := dir.get_files()
	names.sort()
	for file_name: String in names:
		var clean := file_name.trim_suffix(".remap")
		if not clean.ends_with(".tres"):
			continue
		var day: DayData = load(DAY_DIR + clean)
		if day != null:
			days.append(day)
	days.sort_custom(func(a: DayData, b: DayData) -> bool: return a.day_number < b.day_number)


func _load_tools() -> void:
	tools.clear()
	var dir := DirAccess.open("res://data/tools/")
	if dir == null:
		return
	var names := dir.get_files()
	names.sort()
	for file_name: String in names:
		var clean := file_name.trim_suffix(".remap")
		if not clean.ends_with(".tres"):
			continue
		var tool_data: ToolData = load("res://data/tools/" + clean)
		if tool_data != null:
			tools.append(tool_data)


func get_tool(tool_id: StringName) -> ToolData:
	for t: ToolData in tools:
		if t.id == tool_id:
			return t
	return null


# ------------------------------------------------------------------- run / day

func start_run(seed_value: int = 0) -> void:
	run_seed = seed_value if seed_value != 0 else int(Time.get_unix_time_from_system() * 1000.0) % 100000000
	rng.seed = run_seed
	day_index = 0
	ocean_health = 100
	force_grip = 0
	Events.ocean_health_changed.emit(ocean_health)
	begin_day()


func current_day() -> DayData:
	if days.is_empty():
		return null
	return days[clampi(day_index, 0, days.size() - 1)]


func begin_day() -> void:
	inventory.clear()
	stats = {"correct": 0, "wrong": 0, "fish": 0, "sorted": 0, "grabs_used": 0}
	tool_charges.clear()
	var day := current_day()
	if day != null:
		for tool_id: StringName in day.tool_charges:
			tool_charges[tool_id] = int(day.tool_charges[tool_id])
	# Each day re-derives its stream from the run seed, so a seed reproduces the
	# whole run and any single day of it.
	rng.seed = run_seed + day_index * 7919
	print("[Game] Day %d start | seed %d" % [day.day_number if day else 0, run_seed])
	if day != null:
		Events.day_started.emit(day)


func is_last_day() -> bool:
	return day_index >= days.size() - 1


func advance_day() -> void:
	day_index += 1
	begin_day()


# ------------------------------------------------------------------- inventory

func add_to_inventory(item: ItemData) -> CarriedItem:
	var entry := CarriedItem.new(item)
	inventory.append(entry)
	return entry


func unsorted_items() -> Array[CarriedItem]:
	var out: Array[CarriedItem] = []
	for e: CarriedItem in inventory:
		if e.sorted_to == -1:
			out.append(e)
	return out


# ----------------------------------------------------------------- tool charges

func charges_for(tool_id: StringName) -> int:
	return int(tool_charges.get(tool_id, 0))


func tool_available(tool_id: StringName) -> bool:
	var day := current_day()
	if day == null or not day.tools_enabled:
		return false
	return tool_charges.has(tool_id)


## Always spends, even when the click reveals nothing. That is the risk.
func spend_charge(tool_id: StringName) -> bool:
	if charges_for(tool_id) <= 0:
		return false
	tool_charges[tool_id] = charges_for(tool_id) - 1
	return true


func refill_charges() -> void:
	var day := current_day()
	if day == null:
		return
	for tool_id: StringName in day.tool_charges:
		tool_charges[tool_id] = int(day.tool_charges[tool_id])


# ---------------------------------------------------------------- ocean health

## Section 15 of the brief, verbatim. Every term is returned separately so the
## day report can show the player exactly how the number was reached.
func end_day_breakdown() -> Dictionary:
	var day := current_day()
	var quota: int = day.quota if day != null else 0
	var correct: int = int(stats.get("correct", 0))
	var wrong: int = int(stats.get("wrong", 0))
	var fish: int = int(stats.get("fish", 0))
	var sorted_count: int = int(stats.get("sorted", 0))
	var shortfall: int = maxi(0, quota - sorted_count) * 3
	var delta: int = (correct * 1) - (wrong * 4) - (fish * 2) - shortfall
	var before: int = ocean_health
	var after: int = clampi(before + delta, 0, 100)
	return {
		"correct": correct,
		"wrong": wrong,
		"fish": fish,
		"sorted": sorted_count,
		"quota": quota,
		"shortfall": shortfall,
		"delta": delta,
		"health_before": before,
		"health_after": after,
		"quota_met": sorted_count >= quota,
	}


func commit_day_result(breakdown: Dictionary) -> void:
	ocean_health = int(breakdown["health_after"])
	Events.ocean_health_changed.emit(ocean_health)


func set_ocean_health(value: int) -> void:
	ocean_health = clampi(value, 0, 100)
	Events.ocean_health_changed.emit(ocean_health)


func is_game_over() -> bool:
	return ocean_health <= 0


# ------------------------------------------------------------------- settings

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


# ------------------------------------------------------------------------ sfx

func _build_sfx_pool() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)


func play_sfx(sfx_name: StringName) -> void:
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


# -------------------------------------------------------------------- debug

func _on_debug_command(command: StringName, arg: Variant) -> void:
	match command:
		&"refill_charges": refill_charges()
		&"set_health": set_ocean_health(int(arg))
		&"force_grip": force_grip = int(arg)
		&"set_seed":
			run_seed = int(arg)
			rng.seed = run_seed
