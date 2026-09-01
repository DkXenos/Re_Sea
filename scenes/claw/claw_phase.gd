# tank renders into a SubViewport so the glass edge clips it for free. camera
# inside follows the claw across a seabed wider than the window.
#
# the sea only exists inside that viewport. everything outside the frame is the
# hull we are sitting in, so the window really is a window - move the claw and
# the water moves behind it.
extends Node2D

const ITEM_SCENE := preload("res://scenes/claw/tank_item.tscn")
const FISH_SCENE := preload("res://scenes/claw/fish.tscn")
const FISH_FRAMES: Array[String] = [
	"res://data/frames/fish_bg_small_frames.tres",
	"res://data/frames/fish_bg_medium_frames.tres",
	"res://data/frames/fish_bg_large_frames.tres",
]
const MINIMAP_DOT := preload("res://assets/ui/minimap_item.png")
# The window in machine_frame.png, measured off its own transparency. If the
# cockpit art is redrawn, this and TankContainer follow the new opening.
const TANK_VIEW := Vector2(848.0, 408.0)
# where items rest, and the depths fish drift at
const ITEM_REST_Y := Vector2(273.0, 308.0)
const FISH_DEPTH_Y := Vector2(80.0, 231.0)
# bubbles drift inside the glass, so they live in the window's screen rect
const WINDOW_RECT := Rect2(216.0, 122.0, 848.0, 408.0)
# The rail the slider runs along at the top of the cockpit, in screen pixels -
# the rail itself is painted into machine_frame.png, so these are read off the
# art rather than derived from anything.
const RAIL := Vector2(232.0, 1050.0)
# The keys do the same job as the console buttons, so the console has to look
# the same either way. A TextureButton only draws its pressed art for its own
# mouse press, so a held key swaps texture_normal instead.
const KEY_BUTTONS: Array[Dictionary] = [
	{"action": &"claw_left", "node": "ArrowLeft",
		"up": preload("res://assets/ui/machine_left.png"),
		"down": preload("res://assets/ui/machine_left_pressed.png")},
	{"action": &"claw_right", "node": "ArrowRight",
		"up": preload("res://assets/ui/machine_right.png"),
		"down": preload("res://assets/ui/machine_right_pressed.png")},
	{"action": &"claw_drop", "node": "GrabButton",
		"up": preload("res://assets/ui/machine_grab.png"),
		"down": preload("res://assets/ui/machine_grab_pressed.png")},
]
# A tap of the drop key is over in two frames, which reads as the button not
# working. Hold it down long enough to see.
const KEY_PRESS_HOLD := 0.12

# mouse parallax, nearest layer. keep it small.
const PARALLAX := [2.0, 4.0, 6.0]

# The depth layers behind the seabed, furthest first. `scroll` is how much of
# the camera's travel that layer takes:
#
#   0.0  painted on the glass - never moves, however far the claw goes
#   1.0  the world itself - the seabed, the items, the claw
#
# `repeat` turns a row into scenery: that many copies of the cut-out spread
# along the layer, planted on the seabed at the size the manifest installed it
# at. Leave it out and the row is one continuous backdrop instead.
#
# Add a row and it shows up. Nothing here says how big anything is: every layer
# is sized from its own texture, so art at any resolution lands in the window at
# its true proportions. A backdrop is only ever scaled UP far enough to reach
# across its own travel and the window crops the rest, so no layer is ever
# stretched on one axis.
const PARALLAX_LAYERS: Array[Dictionary] = [
	{"texture": "res://assets/env/water_bg.png", "scroll": 0.12},
	{"texture": "res://assets/env/coral_dead.png", "scroll": 0.4, "repeat": 7},
	{"texture": "res://assets/env/coral_healthy.png", "scroll": 0.62, "repeat": 5},
]
# far enough behind the seabed (-10) that nothing can land between them
const PARALLAX_Z := -20
# where the foot of a piece of scenery sits, so it looks planted in the seabed
# rather than floating over it. same units as ITEM_REST_Y.
const SCENERY_BASE_Y := Vector2(250.0, 286.0)
# the span a backdrop needs works out exact, which means the far end of the
# rail lands on the boundary and a rounding error there is a visible sliver of
# nothing. a few pixels of slack costs nothing and removes the class of bug.
const PARALLAX_OVERSCAN := 8.0

# ~2.6x the tank window (1000 wide, not the 1280 viewport). wider than 3x and
# searching turns into sweeping.
@export var seabed_width: float = 2600.0

# atmosphere only, fish can't be grabbed.
@export var fish_count: int = 9
@export var fish_speed_min: float = 25.0
@export var fish_speed_max: float = 65.0

@onready var _tank_layer: CanvasLayer = $TankLayer
@onready var _glass_layer: CanvasLayer = $GlassLayer
@onready var _parallax: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld/Parallax
@onready var _seabed: Sprite2D = $TankLayer/TankContainer/TankViewport/TankWorld/Seabed
@onready var _items: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld/Items
@onready var _fish: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld/FishHolder
@onready var _claw: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld/Claw
@onready var _camera: Camera2D = $TankLayer/TankContainer/TankViewport/TankWorld/Camera
@onready var _bubbles: Node2D = $GlassLayer/Bubbles
@onready var _slider: TextureRect = $ConsoleLayer/Slider
@onready var _map_dots: Control = $ConsoleLayer/MapDots

@onready var _grip_label: Label = $HudLayer/HudRoot/GripLabel
@onready var _toast: Label = $HudLayer/HudRoot/Toast
@onready var _hint: Label = $HudLayer/HudRoot/Hint
@onready var _day_label: Label = $HudLayer/HudRoot/DayLabel
@onready var _budget_label: Label = $HudLayer/HudRoot/BudgetLabel
@onready var _quota_label: Label = $HudLayer/HudRoot/QuotaLabel
@onready var _ocean_label: Label = $HudLayer/HudRoot/OceanLabel

var _day: DayData
var _active: bool = true
# not drifted in yet
var _pending: Array[ItemData] = []
var _spawn_timer: float = 0.0
var _bubble_speeds: Array[float] = []
var _dots: Array[TextureRect] = []
var _layers: Array[Sprite2D] = []
# per layer, matched by index: how much camera travel it takes, and where it
# sits when the camera is at its leftmost
var _layer_scroll: Array[float] = []
var _layer_base: Array[float] = []
# per KEY_BUTTONS row: how long its art still has to stay down
var _key_hold: Array[float] = []


func _ready() -> void:
	_day = Game.current_day()
	if _day == null:
		push_warning("Claw phase started with no day loaded")
		return
	_setup_tank()
	_setup_parallax()
	_claw.cycle_finished.connect(_on_cycle_finished)
	_claw.drop_started.connect(_on_drop_started)
	var console := $ConsoleLayer
	console.get_node("ArrowLeft").button_down.connect(
		func() -> void: _claw.button_axis = -1.0)
	console.get_node("ArrowLeft").button_up.connect(
		func() -> void: _claw.button_axis = 0.0)
	console.get_node("ArrowRight").button_down.connect(
		func() -> void: _claw.button_axis = 1.0)
	console.get_node("ArrowRight").button_up.connect(
		func() -> void: _claw.button_axis = 0.0)
	console.get_node("GrabButton").pressed.connect(_claw.start_drop)
	console.get_node("GrabButton").tooltip_text = Strings.tf("claw_drop_button",
		{"n": Game.cost_of(&"drop")})
	# the folder and the cog are the machine's own controls for what used to be
	# buttons on the shift bar
	console.get_node("SortingButton").pressed.connect(
		func() -> void: Events.view_switch_requested.emit())
	console.get_node("SortingButton").tooltip_text = Strings.t("shift_to_desk")
	console.get_node("SettingsButton").pressed.connect(
		func() -> void: Events.pause_requested.emit())
	console.get_node("SettingsButton").tooltip_text = Strings.t("menu_settings")
	_key_hold.resize(KEY_BUTTONS.size())
	_key_hold.fill(0.0)
	Events.vfx_intensity_changed.connect(_rebuild_bubbles)
	_hint.text = Strings.t("claw_hint")
	_toast.text = ""
	$HudLayer/HudRoot/BudgetTitle.text = Strings.t("budget_label")
	$HudLayer/HudRoot/QuotaTitle.text = Strings.t("day_quota")
	$HudLayer/HudRoot/OceanTitle.text = Strings.t("machines_title")
	_update_readouts()
	_spawn_items()
	_spawn_fish()
	_rebuild_bubbles(Game.vfx_intensity)


# everything that depends on seabed width, in one place
func _setup_tank() -> void:
	# tile one PNG instead of asking for a 2600px asset every time this changes
	_seabed.centered = false
	_seabed.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_seabed.region_enabled = true
	_seabed.region_rect = Rect2(0.0, 0.0, seabed_width, _seabed.texture.get_height())
	_seabed.position = Vector2(0.0, ITEM_REST_Y.y - 40.0)

	_claw.min_x = 70.0
	_claw.max_x = seabed_width - 70.0
	_claw.position.x = seabed_width * 0.5

	_camera.limit_left = 0
	_camera.limit_right = int(seabed_width)
	_camera.limit_top = 0
	_camera.limit_bottom = int(TANK_VIEW.y)
	_camera.position = Vector2(_claw.position.x, TANK_VIEW.y * 0.5)
	_camera.reset_smoothing()


# Builds every row of PARALLAX_LAYERS into sprites. A scenery copy is just
# another entry with its own offset, so the per-frame loop stays flat.
func _setup_parallax() -> void:
	# its own stream: pulling from Game.rng here would shift every item spawn
	var scatter := RandomNumberGenerator.new()
	scatter.seed = Game.run_seed + Game.day_index * 7919 + 31

	for i in PARALLAX_LAYERS.size():
		var row: Dictionary = PARALLAX_LAYERS[i]
		var path := String(row["texture"])
		if not ResourceLoader.exists(path):
			push_warning("Parallax layer texture missing: %s" % path)
			continue
		var texture: Texture2D = load(path)
		var scroll := clampf(float(row.get("scroll", 0.0)), 0.0, 1.0)
		var base := _camera_min() * scroll - TANK_VIEW.x * 0.5 - PARALLAX_OVERSCAN * 0.5
		var copies := int(row.get("repeat", 0))
		if copies <= 0:
			_add_layer(_backdrop_sprite(texture, scroll, i), scroll, base)
			continue
		# a strict spread would read as fence posts, so each copy gets its own
		# slot on the layer and wanders inside it
		var span := _layer_span(scroll) - texture.get_width()
		var slot := span / float(copies)
		for j in copies:
			var sprite := _scenery_sprite(texture, i, scatter)
			_add_layer(sprite, scroll,
				base + slot * (float(j) + scatter.randf_range(0.05, 0.95)))
	_update_parallax_layers()


func _add_layer(sprite: Sprite2D, scroll: float, base: float) -> void:
	_parallax.add_child(sprite)
	_layers.append(sprite)
	_layer_scroll.append(scroll)
	_layer_base.append(base)


# one continuous picture, stretched across nothing - scaled uniformly until it
# covers the window and its own travel, and cropped by the window from there
func _backdrop_sprite(texture: Texture2D, scroll: float, depth: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.z_index = PARALLAX_Z + depth
	sprite.scale = _fit_scale(texture, _layer_span(scroll))
	# whatever is taller than the window hangs off both edges equally, so a tall
	# picture shows its middle rather than its top
	sprite.position.y = (TANK_VIEW.y - texture.get_height() * sprite.scale.y) * 0.5
	return sprite


# a cut-out at the size the manifest gave it, standing on the seabed
func _scenery_sprite(texture: Texture2D, depth: int, scatter: RandomNumberGenerator) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.z_index = PARALLAX_Z + depth
	sprite.position.y = scatter.randf_range(SCENERY_BASE_Y.x, SCENERY_BASE_Y.y) \
		- texture.get_height()
	return sprite


# How wide a layer has to be to still fill the window at both ends of the rail.
# A layer that takes none of the camera's travel only ever needs the window;
# one that takes all of it needs the whole seabed.
func _layer_span(scroll: float) -> float:
	return TANK_VIEW.x + (_camera_max() - _camera_min()) * scroll + PARALLAX_OVERSCAN


# Uniform, so nothing is stretched: big enough to fill the window's height AND
# reach across `span`, whichever demands more. The window crops the surplus.
func _fit_scale(texture: Texture2D, span: float) -> Vector2:
	var size := texture.get_size()
	if size.x <= 0.0 or size.y <= 0.0:
		return Vector2.ONE
	return Vector2.ONE * maxf(span / size.x, TANK_VIEW.y / size.y)


# the camera is clamped by its own limits, so the centre never leaves this range
func _camera_min() -> float:
	return TANK_VIEW.x * 0.5


func _camera_max() -> float:
	return seabed_width - TANK_VIEW.x * 0.5


# starts partly stocked and fills up. empty = waiting, full = no reason to
# watch the tank.
func _spawn_items() -> void:
	# items + boxes. tank doesn't know the difference and shouldn't have to.
	var pool := _day.spawn_pool()
	_shuffle(pool)
	# floor wins over the fraction, otherwise a small pool opens with 2 items
	var seeded := mini(pool.size(),
		maxi(_day.min_available_items, int(round(pool.size() * _day.initial_seed_fraction))))
	var usable := seabed_width - 240.0
	var lane := usable / maxf(1.0, float(seeded))
	for i in seeded:
		var node := _make_item(pool[i])
		# clamp to what the claw can reach. lane 0 jitter used to put items at
		# negative x where nothing could ever grab them.
		node.position = Vector2(
			clampf(120.0 + lane * i + Game.rng.randf_range(-lane * 0.25, lane * 0.25),
				_reach_min(), _reach_max()),
			Game.rng.randf_range(ITEM_REST_Y.x, ITEM_REST_Y.y))
		node.home_y = node.position.y
	_pending.assign(pool.slice(seeded))
	_reset_spawn_timer()


# read off the claw's own limits so the two can't drift apart
func _reach_min() -> float:
	return _claw.min_x


func _reach_max() -> float:
	return _claw.max_x


func _make_item(data: ItemData) -> Area2D:
	var node: Area2D = ITEM_SCENE.instantiate()
	_items.add_child(node)
	node.setup(data)
	node.add_to_group(&"tank_item")
	return node


func _shuffle(list: Array) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := Game.rng.randi_range(0, i)
		var swap: Variant = list[i]
		list[i] = list[j]
		list[j] = swap


func _reset_spawn_timer() -> void:
	_spawn_timer = Game.rng.randf_range(_day.spawn_interval_min, _day.spawn_interval_max)


# on a timer, or right away if we've dropped below the day's floor
func _update_spawning(delta: float) -> void:
	_top_up()
	if _pending.is_empty():
		return
	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	_drift_one_in()


# Back up to the day's floor in one go. One per frame is not enough: the floor
# is what guarantees there is always something to aim at, and trickling leaves
# the tank visibly short for a frame or two after every grab.
func _top_up() -> void:
	while not _pending.is_empty() \
			and _items.get_child_count() < _day.min_available_items:
		_drift_one_in()


func _drift_one_in() -> void:
	var node := _make_item(_pending.pop_front())
	node.drift_in(Game.rng.randf_range(_reach_min(), _reach_max()),
		Game.rng.randf_range(ITEM_REST_Y.x, ITEM_REST_Y.y))
	_reset_spawn_timer()


func _spawn_fish() -> void:
	var count: int = fish_count
	for i in count:
		var node: Node2D = FISH_SCENE.instantiate()
		_fish.add_child(node)
		var frames: SpriteFrames = load(FISH_FRAMES[i % FISH_FRAMES.size()])
		var depth: float = float(i) / maxf(1.0, float(count - 1))
		node.setup(frames,
			Game.rng.randf_range(FISH_DEPTH_Y.x, FISH_DEPTH_Y.y),
			Game.rng.randf_range(fish_speed_min, fish_speed_max),
			1 if i % 2 == 0 else -1,
			depth,
			Vector2(40.0, seabed_width - 40.0))


# only thing actually wired to the vfx slider
func _rebuild_bubbles(intensity: float) -> void:
	_clear(_bubbles)
	_bubble_speeds.clear()
	# all one size on purpose - don't randomly scale these, size variation is
	# the designers' job to draw
	var frames: SpriteFrames = load("res://data/frames/bubble_frames.tres")
	for i in int(round(14.0 * clampf(intensity, 0.0, 1.0))):
		var bubble := AnimatedSprite2D.new()
		bubble.sprite_frames = frames
		bubble.play(&"rise")
		bubble.position = Vector2(
			randf_range(WINDOW_RECT.position.x + 30.0, WINDOW_RECT.end.x - 30.0),
			randf_range(WINDOW_RECT.position.y + 20.0, WINDOW_RECT.end.y))
		_bubbles.add_child(bubble)
		_bubble_speeds.append(randf_range(18.0, 46.0))


func _process(delta: float) -> void:
	_update_spawning(delta)
	_claw.can_drop = _active and Game.can_afford(&"drop")
	$ConsoleLayer/GrabButton.disabled = not _claw.can_drop
	_camera.position.x = _claw.position.x
	_update_parallax()
	_update_bubbles(delta)
	_update_grip_preview()
	_update_console_keys(delta)
	_update_rail()
	_update_readouts()


# the tank and the glass are nudged by the mouse, the hull is not - we are
# sitting in it, so it has no business moving.
func _update_parallax() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0.0:
		return
	var m := get_viewport().get_mouse_position() / vp - Vector2(0.5, 0.5)
	_tank_layer.offset = -m * PARALLAX[1]
	_glass_layer.offset = -m * PARALLAX[2]
	_update_parallax_layers()


# A sprite sitting still in the world slides a full pixel across the window for
# every pixel the camera moves. Giving back (1 - scroll) of that movement is
# what makes a layer look further away.
func _update_parallax_layers() -> void:
	var centre := _camera.get_screen_center_position().x
	for i in _layers.size():
		_layers[i].position.x = _layer_base[i] + centre * (1.0 - _layer_scroll[i])


func _update_bubbles(delta: float) -> void:
	var children := _bubbles.get_children()
	for i in children.size():
		var bubble: AnimatedSprite2D = children[i]
		bubble.position.y -= _bubble_speeds[i] * delta
		if bubble.position.y < WINDOW_RECT.position.y:
			bubble.position.y = WINDOW_RECT.end.y
			bubble.position.x = randf_range(
				WINDOW_RECT.position.x + 30.0, WINDOW_RECT.end.x - 30.0)


func _update_console_keys(delta: float) -> void:
	for i in KEY_BUTTONS.size():
		var row: Dictionary = KEY_BUTTONS[i]
		var button: TextureButton = $ConsoleLayer.get_node(String(row["node"]))
		var held: bool = _active and Input.is_action_pressed(StringName(row["action"]))
		if held:
			_key_hold[i] = KEY_PRESS_HOLD
		else:
			_key_hold[i] = maxf(0.0, _key_hold[i] - delta)
		button.texture_normal = row["down"] if held or _key_hold[i] > 0.0 else row["up"]


# odds on screen before the drop, and for the exact item the drop will reach
func _update_grip_preview() -> void:
	if _claw.is_busy():
		return
	var target: Node2D = _claw.predict_target(_items.get_children())
	_claw.predicted_target = target
	# say so when the rail is locked or it just reads as a broken control
	if _claw.is_rail_locked():
		_grip_label.text = Strings.t("claw_rail_locked")
	elif target == null:
		_grip_label.text = Strings.t("claw_grip_none")
	else:
		# nothing's identified yet, so describe it instead of naming it
		_grip_label.text = "%s  -  %s" % [target.data.surface_label(),
			Strings.tf("claw_grip_chance", {"n": int(round(target.grip_chance() * 100.0))})]


# The marker on the top rail is the window: where it sits on the rail is which
# slice of the seabed you are looking at. The dots are the items still down
# there - without them "where was that heavy one" is just tedious.
func _update_rail() -> void:
	var travel := RAIL.y - RAIL.x - _slider.size.x
	var centre := _camera.get_screen_center_position().x
	var progress := inverse_lerp(_camera_min(), _camera_max(), centre)
	_slider.position.x = RAIL.x + travel * clampf(progress, 0.0, 1.0)

	var children := _items.get_children()
	while _dots.size() < children.size():
		var dot := TextureRect.new()
		dot.texture = MINIMAP_DOT
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_map_dots.add_child(dot)
		_dots.append(dot)
	var span := RAIL.y - RAIL.x
	for i in _dots.size():
		var visible_dot := i < children.size()
		_dots[i].visible = visible_dot
		if visible_dot:
			var item: Node2D = children[i]
			_dots[i].position = Vector2(
				RAIL.x + span * (item.position.x / seabed_width) - 5.0,
				_slider.position.y + _slider.size.y * 0.5 - 5.0)


# the readouts painted into the cockpit - the day on the calendar, the shift
# time and the target on the two panels, the machines on the gold one
func _update_readouts() -> void:
	if _day == null:
		return
	_day_label.text = str(_day.day_number)
	_budget_label.text = str(Game.budget_left)
	_quota_label.text = "%d/%d" % [int(Game.stats.get("sorted", 0)), _day.quota]
	_ocean_label.text = "%d/%d" % [Game.unlocked_blueprints.size(),
		Game.blueprints.size()]


# claw doesn't know what a drop costs, we charge it here
func _on_drop_started() -> void:
	Game.spend(&"drop")
	Game.stats["drops"] = int(Game.stats.get("drops", 0)) + 1


func _on_cycle_finished(result: Dictionary) -> void:
	if String(result["kind"]) == "item":
		var item: ItemData = result["item"]
		Game.add_to_inventory(item)
		Events.item_grabbed.emit(item)
		_show_toast(item.surface_label())
		# out of the tree NOW, not at the end of the frame - queue_free leaves
		# it counted, so the top-up below would think the tank is still full
		# and the floor would be broken until the frame after next
		var taken: Node = result["node"]
		taken.get_parent().remove_child(taken)
		taken.queue_free()
		_top_up()
	else:
		_show_toast(Strings.t("claw_slipped"))


# shift_phase asks this. the tank doesn't decide when the day ends.
func has_work() -> bool:
	return not _pending.is_empty() or _items.get_child_count() > 0


# switching tabs stops nothing, items keep drifting in. input + drawing only.
func set_view_active(active: bool) -> void:
	_active = active
	for child in get_children():
		if child is CanvasLayer:
			child.visible = active
	_claw.input_enabled = active


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.3)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.6)


# queue_free alone leaves them in the tree for the rest of the frame and you
# get both lists at once

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
