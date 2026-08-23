## Phase A. A fixed viewpoint facing the machine: the tank renders into a
## SubViewport so the glass edge clips it for free, the console and HUD sit on
## their own CanvasLayers above it, and a Camera2D inside the SubViewport
## follows the claw across a seabed wider than the window.
extends Node2D

const ITEM_SCENE := preload("res://scenes/claw/tank_item.tscn")
const FISH_SCENE := preload("res://scenes/claw/fish.tscn")
const FISH_FRAMES: Array[String] = [
	"res://data/frames/fish_bg_small_frames.tres",
	"res://data/frames/fish_bg_medium_frames.tres",
	"res://data/frames/fish_bg_large_frames.tres",
]
const MINIMAP_DOT := preload("res://assets/ui/minimap_item.png")
## The visible slice of the tank, in tank world units.
const TANK_VIEW := Vector2(1000.0, 368.0)
## Where items come to rest, and the depths fish drift at.
const ITEM_REST_Y := Vector2(246.0, 278.0)
const FISH_DEPTH_Y := Vector2(72.0, 208.0)
## Nearest-layer mouse parallax in pixels. Small numbers - enough to read as
## depth, not enough to distract.
const PARALLAX := [2.0, 4.0, 6.0]
## How far the water background slides against the camera. Also small.
const BG_CAMERA_PARALLAX := 0.04

## Seabed width in tank world units. The brief asked for 2.5x viewport width;
## the viewport is 1280 but the tank window is only 1000 wide, so this is 2.6x
## of what the player can actually see and stays under the 3x ceiling - past
## that, searching becomes sweeping, which is boring. Tuning knob.
@export var seabed_width: float = 2600.0

## Fish density is an atmosphere knob, not a difficulty one - fish cannot be
## grabbed and cost nothing. It came from the ocean tier in revision 2; revision
## 3 deferred all tier ART, so it is a plain export again. When the designers
## build the four tiers, this goes back to OceanTierData.fish_count.
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
## Items that have not drifted in yet.
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


## Everything that depends on how wide the seabed is, in one place.
func _setup_tank() -> void:
	# One seabed PNG tiled across the width, rather than a 2600px asset the
	# designers would have to redraw whenever the width is tuned.
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


## The ocean tier drives one text label in the shift bar and nothing else.
##
## Revision 2 swapped the seabed, tinted the water and scattered coral per tier.
## Revision 3 DEFERRED all of that: four sets of tier art is polish on a reward
## loop whose value is still unproven, and the label proves the loop just as
## well. The tier data is still filled in and still computed - see
## data/ocean_tier_data.gd for what the designers eventually draw, and the
## dormant Decor node below the seabed for where it hangs.

## The seabed opens partly stocked and fills up over the shift. Starting empty
## would mean waiting, and waiting is dead time; starting full would mean there
## is no reason to keep watching the tank.
func _spawn_items() -> void:
	var pool := _day.item_pool.duplicate()
	_shuffle(pool)
	# The fraction is the intent, but the availability floor wins: on a small
	# pool a 40% seed would open below min_available_items and the player would
	# start by waiting.
	var seeded := mini(pool.size(),
		maxi(_day.min_available_items, int(round(pool.size() * _day.initial_seed_fraction))))
	var usable := seabed_width - 240.0
	var lane := usable / maxf(1.0, float(seeded))
	for i in seeded:
		var node := _make_item(pool[i])
		node.position = Vector2(
			120.0 + lane * i + Game.rng.randf_range(-lane * 0.25, lane * 0.25),
			Game.rng.randf_range(ITEM_REST_Y.x, ITEM_REST_Y.y))
		node.home_y = node.position.y
	_pending.assign(pool.slice(seeded))
	_reset_spawn_timer()


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


## The next item arrives on its timer, or immediately if the tank has dropped
## below the day's floor - the player must never have a reason to sit and wait.
func _update_spawning(delta: float) -> void:
	if _pending.is_empty():
		return
	_spawn_timer -= delta
	if _spawn_timer > 0.0 and _items.get_child_count() >= _day.min_available_items:
		return
	var node := _make_item(_pending.pop_front())
	node.drift_in(Game.rng.randf_range(140.0, seabed_width - 140.0),
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


## The one visible thing wired to the VFX slider, so the slider is testable.
func _rebuild_bubbles(intensity: float) -> void:
	_clear(_bubbles)
	_bubble_speeds.clear()
	# Bubbles are AnimatedSprite2D like every other animated thing, playing
	# "rise". Their upward travel is movement; the animation is the designer's.
	var frames: SpriteFrames = load("res://data/frames/bubble_frames.tres")
	for i in int(round(14.0 * clampf(intensity, 0.0, 1.0))):
		var bubble := AnimatedSprite2D.new()
		bubble.sprite_frames = frames
		bubble.play(&"rise")
		bubble.position = Vector2(randf_range(160.0, 1120.0), randf_range(80.0, 428.0))
		bubble.scale = Vector2.ONE * randf_range(0.5, 1.3)
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


## Three CanvasLayers offset by a few pixels from the mouse, nearest moving
## most, plus the water sliding against the camera. Cheaper and far more
## predictable than a 3D camera.
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


## Failure has to be the player's judgement, not a surprise, so the odds are on
## screen before the drop - and they belong to the exact item the drop will
## reach, because both come from the same prediction.
func _update_grip_preview() -> void:
	if _claw.is_busy():
		return
	var target: Node2D = _claw.predict_target(_items.get_children())
	_claw.predicted_target = target
	if target == null:
		_grip_label.text = Strings.t("claw_grip_none")
	else:
		# Nothing in the tank has been identified yet, so the readout describes
		# what the claw can see rather than naming it (revision 2 §3).
		_grip_label.text = "%s  -  %s" % [target.data.surface_label(),
			Strings.tf("claw_grip_chance", {"n": int(round(target.grip_chance() * 100.0))})]


## Without this, "where was that heavy thing" becomes tedious rather than tense.
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


## The claw does not know what a drop costs; the tank charges the shift.
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


## True while the tank can still produce something to grab. The shift asks
## this; the tank does not decide when the day ends any more.
func has_work() -> bool:
	return not _pending.is_empty() or _items.get_child_count() > 0


## Switching tabs costs nothing and stops nothing: items keep drifting in and a
## cycle already in the air still lands. Only input and drawing are suspended.
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


## queue_free() alone leaves the old children in the tree for the rest of the
## frame, so a list rebuilt twice in one frame would briefly show both sets.
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
