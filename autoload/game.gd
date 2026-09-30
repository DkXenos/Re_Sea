# run + day state. no scene tree stuff in here
extends Node

const DAY_DIR := "res://data/days/"
const BLUEPRINT_DIR := "res://data/blueprints/"
const UPGRADE_DIR := "res://data/upgrades/"
const SFX_DIR := "res://assets/audio/"
const SFX_POOL_SIZE := 6

# Two beds, both looping for the whole session and both on the Music bus, so
# the one Music slider covers everything that is not a one-shot. The song sits
# under the ambience rather than over it - the sea is the room, the song is the
# thing playing in it.
const MUSIC_TRACK := "res://assets/audio/music_game.mp3"
const AMBIENCE_TRACK := "res://assets/audio/amb_sea.mp3"
const MUSIC_DB := -8.0
const AMBIENCE_DB := -4.0

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

var inventory: Array[CarriedItem] = []
var containers_grabbed: int = 0
var tools: Array[ToolData] = []
var stats: Dictionary = {}
var last_breakdown: Dictionary = {}
## `commit_day_result` credits the material store, and that is not idempotent.
## The end-of-day screen can be rebuilt or re-entered, so it asks this first.
var day_committed: bool = false
var budget_max: int = 0
var budget_left: int = 0

var settings: Dictionary = {}
var vfx_intensity: float = 1.0

## The guided tour is not a choice: it runs on the first run of every launch, so
## nobody reaches the desk without having been told what a bin does.
##
## It used to run once on a machine and never again, remembered in
## user://settings.cfg. That is right for one player on their own laptop and
## wrong for everything else this game actually does: the second person to sit
## down never saw it, playtesting a change to the tour meant editing a settings
## file by hand, and on a machine it is being demoed on it showed up for the
## first player of the day and nobody after. Once per launch costs a repeat
## viewing to whoever restarts the game, and costs nobody the explanation.
##
## `tutorial_seen` keeps the cockpit half and the desk half to one showing each,
## so switching views doesn't replay them; `tutorial_shown_this_launch` is what
## stops the next run in the same sitting from starting the tour over.
var tutorial_active: bool = false
var tutorial_seen: Dictionary = {}
var tutorial_shown_this_launch: bool = false

var force_grip: int = 0  # 1 always, -1 never, 0 roll

# headless runs turn this off or godot yells about leaked streams
var sfx_enabled: bool = true

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_cache: Dictionary = {}
var _beds: Array[AudioStreamPlayer] = []


func _ready() -> void:
	_build_sfx_pool()
	settings = SaveSettings.load_all()
	for key: String in settings:
		apply_setting(key, float(settings[key]), false)
	_start_music()
	_load_days()
	_load_tools()
	_load_blueprints()
	_load_upgrades()
	Events.sfx_requested.connect(play_sfx)
	Events.debug_command.connect(_on_debug_command)
	Events.tutorial_segment_finished.connect(_on_tutorial_segment_finished)


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
	last_breakdown = {}
	tutorial_seen = {}
	# armed here rather than by the menu - the menu is a splash with nothing to
	# press, and a first-timer should not have to opt in to being taught
	tutorial_active = not tutorial_shown_this_launch
	begin_day()


## Asks for a tour segment the first time that screen is reached in a tutorial
## run, and never again. Returns whether it actually asked.
func request_tutorial(segment: StringName) -> bool:
	if not tutorial_active or tutorial_seen.has(segment):
		return false
	tutorial_seen[segment] = true
	Events.tutorial_requested.emit(segment)
	return true


## Puts the guided tour back for whoever is sitting down next. The screen that
## is already up asks again straight away - it is listening for the signal below
## - and every other screen picks it up the first time it is reached, so a new
## run still runs the whole thing from the top.
func replay_tutorial() -> void:
	tutorial_shown_this_launch = false
	tutorial_active = true
	tutorial_seen = {}
	Events.tutorial_replay_requested.emit()


# Every segment seen means this player has been shown the game. Drop the flag so
# a retry from the game-over screen doesn't sit them through it again, and
# remember it for the rest of this launch.
#
# The end-of-day screen is in here too, and it is the last one reached - the
# cockpit and the desk are both behind the player by the time the day closes.
# Leave it out and the flag drops on the desk, which switches the tour off
# before the screen that explains what all the sorting was for.
const TUTORIAL_SEGMENTS: Array[StringName] = [&"claw", &"desk", &"after_day"]

func _on_tutorial_segment_finished() -> void:
	if not tutorial_active:
		return
	for segment: StringName in TUTORIAL_SEGMENTS:
		if not tutorial_seen.has(segment):
			return
	tutorial_active = false
	tutorial_shown_this_launch = true


func current_day() -> DayData:
	if days.is_empty():
		return null
	return days[clampi(day_index, 0, days.size() - 1)]


func begin_day() -> void:
	inventory.clear()
	containers_grabbed = 0
	day_committed = false
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


## Cheapest wins. Two machines that both touch a price is not a conflict, it is
## just the better of the two.
func cost_of(action: StringName) -> int:
	var cost := base_cost(action)
	for up: UpgradeData in active_upgrades():
		var fitted: int = -1
		match action:
			&"drop": fitted = up.drop_cost
			&"tool": fitted = up.tool_cost
		if fitted >= 0:
			cost = mini(cost, fitted)
	return cost


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


## The day's target, and how much of it is left.
##
## Sorted is sorted: a wrong bin counts here exactly as much as a right one.
## The desk never says which was which - that is what the report at the end of
## the day is for - so a quota that only counted correct sorts would be a score
## the player cannot see, and would tell them they got one wrong the moment the
## number failed to move.
func quota_left() -> int:
	var day := current_day()
	if day == null:
		return 0
	return maxi(0, day.quota - int(stats.get("sorted", 0)))


func quota_met() -> bool:
	return quota_left() == 0


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
	if day_committed:
		push_warning("the day was already committed - material would be paid twice")
		return
	day_committed = true
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
		# the machine is running from here, and it may have just changed what a
		# drop or a tool costs - anything showing a price has to hear about it
		Events.budget_changed.emit(budget_left, budget_max)
		return bp
	return null


func blueprint_unlocked(blueprint_id: StringName) -> bool:
	return blueprint_id in unlocked_blueprints


## What the machines you have built are doing to the claw right now.
##
## There is no gear tab and nothing to fit: a blueprint that has been built is
## a machine that is running, and its upgrade is on from that moment until the
## end of the run. Three machines means all three, together - which is why the
## getters below combine rather than pick.
func active_upgrades() -> Array[UpgradeData]:
	var out: Array[UpgradeData] = []
	for bp: BlueprintData in blueprints:
		if bp.unlocks_upgrade == &"" or not blueprint_unlocked(bp.id):
			continue
		for up: UpgradeData in upgrades:
			if up.id == bp.unlocks_upgrade:
				out.append(up)
	return out


## The upgrade a blueprint will bolt on, built or not, for the sheet to show.
func upgrade_for(bp: BlueprintData) -> UpgradeData:
	if bp == null or bp.unlocks_upgrade == &"":
		return null
	for up: UpgradeData in upgrades:
		if up.id == bp.unlocks_upgrade:
			return up
	return null


# points of grip add up
func grip_delta() -> float:
	var out := 0.0
	for up: UpgradeData in active_upgrades():
		out += up.grip_delta
	return out


func coarse_readings() -> bool:
	for up: UpgradeData in active_upgrades():
		if up.coarse_readings:
			return true
	return false


# speeds multiply - two machines that each move the rail move it together
func move_speed_multiplier() -> float:
	var out := 1.0
	for up: UpgradeData in active_upgrades():
		out *= up.move_speed_multiplier
	return out


func post_drop_lockout() -> float:
	var out := 0.0
	for up: UpgradeData in active_upgrades():
		out = maxf(out, up.post_drop_lockout)
	return out


## Which ending this run earned: one tier per machine actually built, so 0 is
## the bay left as it was and blueprints.size() is the full recovery. Authoring
## a fourth blueprint adds a fourth tier without touching this - only the
## end_N_* strings have to follow.
func ending_tier() -> int:
	return clampi(unlocked_blueprints.size(), 0, blueprints.size())


## One painting per tier, named by the number of machines running in it, so a
## fourth blueprint needs `ending_4.png` beside the other four and nothing else.
## Falls back to the bay-as-it-was still rather than showing a blank screen if
## that file is ever missing.
func ending_still() -> String:
	var path := "res://assets/env/ending_%d.png" % ending_tier()
	if not ResourceLoader.exists(path):
		push_warning("No ending still for tier %d" % ending_tier())
		return "res://assets/env/ending_0.png"
	return path


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


# One player per bed. Godot imports an .mp3 as a one-shot, so the loop flag is
# set here rather than asked for in the .import - that way dropping in a
# different track needs no import settings.
func _start_music() -> void:
	if not sfx_enabled or DisplayServer.get_name() == "headless":
		return
	for row: Array in [[MUSIC_TRACK, MUSIC_DB], [AMBIENCE_TRACK, AMBIENCE_DB]]:
		var path := String(row[0])
		if not ResourceLoader.exists(path):
			push_warning("Music track missing: %s" % path)
			continue
		var stream: AudioStream = load(path)
		if stream is AudioStreamMP3:
			(stream as AudioStreamMP3).loop = true
		var player := AudioStreamPlayer.new()
		player.bus = "Music"
		player.stream = stream
		player.volume_db = float(row[1])
		add_child(player)
		player.play()
		_beds.append(player)


func stop_music() -> void:
	for player: AudioStreamPlayer in _beds:
		player.stop()
		player.stream = null
	_beds.clear()


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
	stop_music()


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
