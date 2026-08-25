# tank renders into a SubViewport so the glass edge clips it for free. camera
# inside follows the claw across a seabed wider than the window.
extends Node2D

const ITEM_SCENE := preload("res://scenes/claw/tank_item.tscn")
const FISH_SCENE := preload("res://scenes/claw/fish.tscn")
const FISH_FRAMES: Array[String] = [
	"res://data/frames/fish_bg_small_frames.tres",
	"res://data/frames/fish_bg_medium_frames.tres",
	"res://data/frames/fish_bg_large_frames.tres",
]
const MINIMAP_DOT := preload("res://assets/ui/minimap_item.png")
# visible slice of the tank, in tank world units
const TANK_VIEW := Vector2(1000.0, 368.0)
# where items rest, and the depths fish drift at
const ITEM_REST_Y := Vector2(246.0, 278.0)
const FISH_DEPTH_Y := Vector2(72.0, 208.0)
# mouse parallax, nearest layer. keep it small.
const PARALLAX := [2.0, 4.0, 6.0]
# how far the water bg slides against the camera
const BG_CAMERA_PARALLAX := 0.04

# ~2.6x the tank window (1000 wide, not the 1280 viewport). wider than 3x and
# searching turns into sweeping.
@export var seabed_width: float = 2600.0

# atmosphere only, fish can't be grabbed.
# TODO move this back onto OceanTierData.fish_count when the tier art exists
@export var fish_count: int = 9
@export var fish_speed_min: float = 25.0
@export var fish_speed_max: float = 65.0

@onready var _tank_layer: CanvasLayer = $TankLayer
@onready var _bg_layer: CanvasLayer = $BgLayer
@onready var _glass_layer: CanvasLayer = $GlassLayer
@onready var _seabed: Sprite2D = $TankLayer/TankContainer/TankViewport/TankWorld/Seabed
@onready var _items: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld/Items
@onready var _fish: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld/FishHolder
@onready var _claw: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld/Claw
@onready var _camera: Camera2D = $TankLayer/TankContainer/TankViewport/TankWorld/Camera
@onready var _bubbles: Node2D = $GlassLayer/Bubbles
@onready var _knob: TextureRect = $FrameLayer/JoystickKnob

@onready var _grip_label: Label = $HudLayer/HudRoot/GripLabel
@onready var _toast: Label = $HudLayer/HudRoot/Toast
@onready var _hint: Label = $HudLayer/HudRoot/Hint
@onready var _map: Control = $HudLayer/HudRoot/Minimap
@onready var _map_view: TextureRect = $HudLayer/HudRoot/Minimap/View
@onready var _map_dots: Control = $HudLayer/HudRoot/Minimap/Dots
@onready var _map_claw: TextureRect = $HudLayer/HudRoot/Minimap/ClawMark

var _day: DayData
var _active: bool = true
# not drifted in yet
var _pending: Array[ItemData] = []
var _spawn_timer: float = 0.0
var _knob_home: Vector2
var _bubble_speeds: Array[float] = []
var _dots: Array[TextureRect] = []


func _ready() -> void:
	_day = Game.current_day()
	if _day == null:
		push_warning("Claw phase started with no day loaded")
		return
	_knob_home = _knob.position
	_setup_tank()
	_claw.cycle_finished.connect(_on_cycle_finished)
	_claw.drop_started.connect(_on_drop_started)
	$FrameLayer/ArrowLeft.button_down.connect(func() -> void: _claw.button_axis = -1.0)
	$FrameLayer/ArrowLeft.button_up.connect(func() -> void: _claw.button_axis = 0.0)
	$FrameLayer/ArrowRight.button_down.connect(func() -> void: _claw.button_axis = 1.0)
	$FrameLayer/ArrowRight.button_up.connect(func() -> void: _claw.button_axis = 0.0)
	$FrameLayer/DropButton.pressed.connect(_claw.start_drop)
	$FrameLayer/DropButton.text = Strings.tf("claw_drop_button",
		{"n": Game.cost_of(&"drop")})
	$FrameLayer/DropButton.tooltip_text = Strings.tf("budget_cost",
		{"n": Game.cost_of(&"drop")})
	Events.vfx_intensity_changed.connect(_rebuild_bubbles)
	_hint.text = Strings.t("claw_hint")
	_toast.text = ""
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


# tier only drives one label right now. the seabed swap / water tint / coral
# is all still unbuilt - the Decor node under the seabed is where it goes.

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
	if _pending.is_empty():
		return
	_spawn_timer -= delta
	if _spawn_timer > 0.0 and _items.get_child_count() >= _day.min_available_items:
		return
	var node := _make_item(_pending.pop_front())
	node.drift_in(Game.rng.randf_range(_reach_min(), _reach_max()),
		Game.rng.randf_range(ITEM_REST_Y.x, ITEM_REST_Y.y))
	_reset_spawn_timer()


func _spawn_fish() -> void:
	for i in fish_count:
		var node: Node2D = FISH_SCENE.instantiate()
		_fish.add_child(node)
		var frames: SpriteFrames = load(FISH_FRAMES[i % FISH_FRAMES.size()])
		var depth: float = float(i) / maxf(1.0, float(fish_count - 1))
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
		bubble.position = Vector2(randf_range(160.0, 1120.0), randf_range(80.0, 428.0))
		_bubbles.add_child(bubble)
		_bubble_speeds.append(randf_range(18.0, 46.0))


func _process(delta: float) -> void:
	_update_spawning(delta)
	_claw.can_drop = _active and Game.can_afford(&"drop")
	$FrameLayer/DropButton.disabled = not _claw.can_drop
	_camera.position.x = _claw.position.x
	_update_parallax()
	_update_bubbles(delta)
	_update_grip_preview()
	_update_minimap()
	_knob.position = _knob_home + Vector2(_claw_progress() * 22.0 - 11.0, 0.0)


func _claw_progress() -> float:
	return inverse_lerp(_claw.min_x, _claw.max_x, _claw.position.x)


# three canvaslayers nudged by the mouse, nearest moves most
func _update_parallax() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0.0:
		return
	var m := get_viewport().get_mouse_position() / vp - Vector2(0.5, 0.5)
	var camera_slide := (_camera.get_screen_center_position().x - seabed_width * 0.5) \
		* BG_CAMERA_PARALLAX
	_bg_layer.offset = -m * PARALLAX[0] - Vector2(camera_slide, 0.0)
	_tank_layer.offset = -m * PARALLAX[1]
	_glass_layer.offset = -m * PARALLAX[2]


func _update_bubbles(delta: float) -> void:
	var children := _bubbles.get_children()
	for i in children.size():
		var bubble: AnimatedSprite2D = children[i]
		bubble.position.y -= _bubble_speeds[i] * delta
		if bubble.position.y < 76.0:
			bubble.position.y = 430.0
			bubble.position.x = randf_range(160.0, 1120.0)


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


# without this "where was that heavy one" is just tedious
func _update_minimap() -> void:
	var width := _map.size.x
	var scale_x := width / seabed_width
	_map_view.size.x = TANK_VIEW.x * scale_x
	_map_view.position.x = (_camera.get_screen_center_position().x - TANK_VIEW.x * 0.5) * scale_x
	_map_claw.position.x = _claw.position.x * scale_x - _map_claw.size.x * 0.5

	var children := _items.get_children()
	while _dots.size() < children.size():
		var dot := TextureRect.new()
		dot.texture = MINIMAP_DOT
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_map_dots.add_child(dot)
		_dots.append(dot)
	for i in _dots.size():
		var visible_dot := i < children.size()
		_dots[i].visible = visible_dot
		if visible_dot:
			var item: Node2D = children[i]
			_dots[i].position = Vector2(item.position.x * scale_x - 5.0, 9.0)


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
		result["node"].queue_free()
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
