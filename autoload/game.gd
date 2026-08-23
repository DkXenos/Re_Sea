## Autoload 2 of 2: run and day state. Owns the seeded RNG, the day list, the
## inventory carried from claw phase to desk phase, tool charges, ocean health
## and the audio/vfx settings. No scene tree knowledge lives here.
extends Node

const DAY_DIR := "res://data/days/"
const TIER_DIR := "res://data/tiers/"
const SFX_DIR := "res://assets/audio/"
const SFX_POOL_SIZE := 6
## Paid once for a day with no mis-sorts that also met quota. Tuning candidate.
const CLEAN_DAY_BONUS := 5

## What each action spends from the shift budget.
##
## Time is spent by ACTIONS, never by the clock - there is no real-time
## countdown anywhere in this game. That is deliberate: a ticking timer would
## destroy the careful inspection the whole design is built around, while an
## action-cost budget creates the intended tension, "do I grab another item, or
## spend that on examining what I already have?". Thinking, panning, zooming,
## moving the camera and reading the rulebook are all free.
##
## All three numbers are tuning candidates.
const ACTION_COST: Dictionary = {
	&"drop": 6,
	&"tool": 4,
	&"sort": 1,
}

# --- run ---
var run_seed: int = 0
var rng := RandomNumberGenerator.new()
var days: Array[DayData] = []
var day_index: int = 0
var ocean_health: int = 100

# --- ocean recovery tiers (revision 2 §1) ---
var tiers: Array[OceanTierData] = []
## The tier the ART is currently showing. It follows ocean_health, but only at
## the day report: the seabed must not shift under the player mid-shift, and
## stability reads as a world that changes when the day turns over rather than
## one that flickers.
var visual_tier: int = 3

# --- current day ---
var inventory: Array[CarriedItem] = []
var tools: Array[ToolData] = []
var stats: Dictionary = {}
var budget_max: int = 0
var budget_left: int = 0

# --- settings ---
var settings: Dictionary = {}
var vfx_intensity: float = 1.0
## Whether the hotspot ring overlay is drawn on items in the inspect panel.
var show_hotspots: bool = true

# --- debug switches (only ever set by the F1 overlay) ---
var force_grip: int = 0 ## 1 = always succeed, -1 = always fail, 0 = roll

## Headless harnesses quit mid-frame, and a sound still playing at that moment
## is reported as a leaked stream. They switch this off; the game never does.
var sfx_enabled: bool = true

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
	Events.sfx_requested.connect(play_sfx)
	Events.debug_command.connect(_on_debug_command)


# ---------------------------------------------------------------- content load

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


## Shared by every content directory: sorted, .remap-aware, silent if missing.
func _load_dir(dir_path: String) -> Array:
	var out: Array = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	var names := dir.get_files()
	names.sort()
	for file_name: String in names:
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


# ------------------------------------------------------------------- run / day

func start_run(seed_value: int = 0) -> void:
	run_seed = seed_value if seed_value != 0 else int(Time.get_unix_time_from_system() * 1000.0) % 100000000
	rng.seed = run_seed
	day_index = 0
	ocean_health = 100
	force_grip = 0
	visual_tier = tier_for(ocean_health)
	Events.ocean_health_changed.emit(ocean_health)
	begin_day()


func current_day() -> DayData:
	if days.is_empty():
		return null
	return days[clampi(day_index, 0, days.size() - 1)]


func begin_day() -> void:
	inventory.clear()
	stats = {"correct": 0, "wrong": 0, "sorted": 0, "drops": 0, "tool_uses": 0, "spent": 0}
	var day := current_day()
	budget_max = day.budget if day != null else 0
	budget_left = budget_max
	Events.budget_changed.emit(budget_left, budget_max)
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


## Debug only: skip the claw phase and go straight to sorting.
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


# ---------------------------------------------------------------- shift budget

func cost_of(action: StringName) -> int:
	return int(ACTION_COST.get(action, 0))


func can_afford(action: StringName) -> bool:
	return budget_left >= cost_of(action)


## Always spends, including when a tool click reveals nothing. That is the risk.
func spend(action: StringName) -> bool:
	var cost := cost_of(action)
	if budget_left < cost:
		return false
	budget_left -= cost
	stats["spent"] = int(stats.get("spent", 0)) + cost
	Events.budget_changed.emit(budget_left, budget_max)
	return true


## True while the player can still do something that changes the outcome. Being
## unable to afford a drop is not the end of the shift if there is still
## sorting to do.
func can_still_act() -> bool:
	if can_afford(&"drop"):
		return true
	return not unsorted_items().is_empty() and can_afford(&"sort")


func tool_unlocked(tool_id: StringName) -> bool:
	var day := current_day()
	return day != null and tool_id in day.available_tools


func refill_budget() -> void:
	budget_left = budget_max
	Events.budget_changed.emit(budget_left, budget_max)


# ---------------------------------------------------------------- ocean health

## Every term is returned separately so the day report can show the player
## exactly how the number was reached.
##
## Revision 1 replaced the original formula: correct sorts now pay 2 instead of
## 1, a clean day pays a flat bonus, and the fish penalty is gone entirely
## (fish are background now). A well-played day has to visibly RAISE the meter -
## the old numbers meant a perfect run still drifted down to 92/100, which
## contradicted the subject matter. The 4x asymmetry on wrong sorts stays: that
## part was right.
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
	ocean_health = int(breakdown["health_after"])
	Events.ocean_health_changed.emit(ocean_health)
	refresh_visual_tier()


# ------------------------------------------------------------- ocean tiers

## Which tier a health value falls in. Data decides the thresholds; if they ever
## leave a gap, the nearest tier below wins rather than nothing at all.
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


## Called only at the day report and at the start of a run. Returns the tier the
## art moved to, or -1 if nothing changed, so the report can say one quiet line.
func refresh_visual_tier() -> int:
	var was := visual_tier
	visual_tier = tier_for(ocean_health)
	return visual_tier if visual_tier != was else -1


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


## On/off settings, kept separate from the sliders so a bool never gets clamped
## into a float.
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


# ------------------------------------------------------------------------ sfx

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


func stop_all_sfx() -> void:
	for player: AudioStreamPlayer in _sfx_players:
		player.stop()
		player.stream = null
	_sfx_cache.clear()


## Without this a sound still playing at shutdown keeps its stream alive and
## Godot reports it as a leaked instance.
func _exit_tree() -> void:
	stop_all_sfx()


# -------------------------------------------------------------------- debug

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
