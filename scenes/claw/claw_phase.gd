## Phase A. A fixed viewpoint facing the machine: the tank renders into a
## SubViewport so the glass edge clips it for free, the console and HUD sit on
## their own CanvasLayers above it, and a few pixels of mouse-driven parallax
## between those layers is all the depth this needs.
extends Node2D

const ITEM_SCENE := preload("res://scenes/claw/tank_item.tscn")
const FISH_SCENE := preload("res://scenes/claw/fish.tscn")
const FISH_FRAMES: Array[String] = [
	"res://data/frames/fish_small_frames.tres",
	"res://data/frames/fish_medium_frames.tres",
	"res://data/frames/fish_large_frames.tres",
]
const END_DELAY := 1.4
## Nearest-layer parallax travel in pixels. Small numbers - enough to read as
## depth, not enough to distract.
const PARALLAX := [2.0, 4.0, 6.0]

@onready var _tank_layer: CanvasLayer = $TankLayer
@onready var _bg_layer: CanvasLayer = $BgLayer
@onready var _glass_layer: CanvasLayer = $GlassLayer
@onready var _world: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld
@onready var _items: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld/Items
@onready var _fish: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld/FishHolder
@onready var _claw: Node2D = $TankLayer/TankContainer/TankViewport/TankWorld/Claw
@onready var _bubbles: Node2D = $GlassLayer/Bubbles
@onready var _knob: TextureRect = $FrameLayer/JoystickKnob

## Fish density is an atmosphere knob, not a difficulty knob - they cannot be
## grabbed and cost nothing. Tune freely.
@export var fish_count: int = 7
@export var fish_speed_min: float = 25.0
@export var fish_speed_max: float = 65.0

@onready var _day_label: Label = $HudLayer/HudRoot/Hud/DayLabel
@onready var _quota_label: Label = $HudLayer/HudRoot/Hud/QuotaLabel
@onready var _grabs_label: Label = $HudLayer/HudRoot/Hud/GrabsLabel
@onready var _collected_label: Label = $HudLayer/HudRoot/Hud/CollectedLabel
@onready var _grip_label: Label = $HudLayer/HudRoot/GripLabel
@onready var _toast: Label = $HudLayer/HudRoot/Toast
@onready var _hint: Label = $HudLayer/HudRoot/Hint

var _day: DayData
var _grabs_left: int = 0
var _finished: bool = false
var _knob_home: Vector2
var _bubble_speeds: Array[float] = []


func _ready() -> void:
	_day = Game.current_day()
	if _day == null:
		push_warning("Claw phase started with no day loaded")
		return
	_grabs_left = _day.max_grabs
	_knob_home = _knob.position
	_claw.cycle_finished.connect(_on_cycle_finished)
	$FrameLayer/ArrowLeft.button_down.connect(func() -> void: _claw.button_axis = -1.0)
	$FrameLayer/ArrowLeft.button_up.connect(func() -> void: _claw.button_axis = 0.0)
	$FrameLayer/ArrowRight.button_down.connect(func() -> void: _claw.button_axis = 1.0)
	$FrameLayer/ArrowRight.button_up.connect(func() -> void: _claw.button_axis = 0.0)
	$FrameLayer/DropButton.pressed.connect(_claw.start_drop)
	Events.toast_requested.connect(_show_toast)
	Events.vfx_intensity_changed.connect(_rebuild_bubbles)
	_hint.text = Strings.t("claw_hint")
	$FrameLayer/DropButton.text = Strings.t("claw_drop_button")
	_toast.text = ""
	_spawn_items()
	_spawn_fish()
	_rebuild_bubbles(Game.vfx_intensity)
	_refresh_hud()


func _spawn_items() -> void:
	var count := _day.item_pool.size()
	var lane := 800.0 / maxf(1.0, float(count))
	var order := range(count)
	for i in count:
		var item: ItemData = _day.item_pool[i]
		var node: Area2D = ITEM_SCENE.instantiate()
		_items.add_child(node)
		node.setup(item)
		node.add_to_group(&"tank_item")
		node.position = Vector2(
			120.0 + lane * order[i] + Game.rng.randf_range(-lane * 0.22, lane * 0.22),
			Game.rng.randf_range(286.0, 318.0))
		node.home_y = node.position.y


func _spawn_fish() -> void:
	for i in fish_count:
		var node: Node2D = FISH_SCENE.instantiate()
		_fish.add_child(node)
		var frames: SpriteFrames = load(FISH_FRAMES[i % FISH_FRAMES.size()])
		var depth: float = float(i) / maxf(1.0, float(fish_count - 1))
		node.setup(frames,
			Game.rng.randf_range(90.0, 250.0),
			Game.rng.randf_range(fish_speed_min, fish_speed_max),
			1 if i % 2 == 0 else -1,
			depth,
			Vector2(40.0, 960.0))


## The one visible thing wired to the VFX slider, so the slider is testable.
func _rebuild_bubbles(intensity: float) -> void:
	_clear(_bubbles)
	_bubble_speeds.clear()
	var texture: Texture2D = load("res://assets/env/bubble.png")
	for i in int(round(14.0 * clampf(intensity, 0.0, 1.0))):
		var s := Sprite2D.new()
		s.texture = texture
		s.position = Vector2(randf_range(160.0, 1120.0), randf_range(50.0, 450.0))
		s.scale = Vector2.ONE * randf_range(0.5, 1.3)
		_bubbles.add_child(s)
		_bubble_speeds.append(randf_range(18.0, 46.0))


func _process(delta: float) -> void:
	_update_parallax()
	_update_bubbles(delta)
	_update_grip_preview()
	_knob.position = _knob_home + Vector2(_claw_progress() * 22.0 - 11.0, 0.0)


func _claw_progress() -> float:
	return inverse_lerp(_claw.min_x, _claw.max_x, _claw.position.x)


## Fake parallax: three CanvasLayers offset by a few pixels from the mouse, the
## nearest moving most. Cheaper and far more predictable than a 3D camera.
func _update_parallax() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0.0:
		return
	var m := get_viewport().get_mouse_position() / vp - Vector2(0.5, 0.5)
	_bg_layer.offset = -m * PARALLAX[0]
	_tank_layer.offset = -m * PARALLAX[1]
	_glass_layer.offset = -m * PARALLAX[2]


func _update_bubbles(delta: float) -> void:
	var children := _bubbles.get_children()
	for i in children.size():
		var s: Sprite2D = children[i]
		s.position.y -= _bubble_speeds[i] * delta
		if s.position.y < 46.0:
			s.position.y = 452.0
			s.position.x = randf_range(160.0, 1120.0)


## Failure has to be the player's judgement, not a surprise, so the odds are on
## screen before the drop.
func _update_grip_preview() -> void:
	if _claw.is_busy():
		return
	var best: Node2D = null
	var best_dx := 70.0
	for node in _items.get_children():
		var dx: float = absf(node.position.x - _claw.position.x)
		if dx < best_dx:
			best_dx = dx
			best = node
	if best == null:
		_grip_label.text = Strings.t("claw_grip_none")
	else:
		_grip_label.text = "%s  -  %s" % [best.data.display_name,
			Strings.tf("claw_grip_chance", {"n": int(round(best.grip_chance() * 100.0))})]


func _on_cycle_finished(result: Dictionary) -> void:
	_grabs_left -= 1
	Game.stats["grabs_used"] = int(Game.stats.get("grabs_used", 0)) + 1
	Events.grabs_changed.emit(_grabs_left)
	match String(result["kind"]):
		"item":
			var item: ItemData = result["item"]
			Game.add_to_inventory(item)
			Events.item_grabbed.emit(item)
			_show_toast(item.display_name)
			result["node"].queue_free()
		"miss":
			_show_toast(Strings.t("claw_slipped"))
	_refresh_hud()
	_check_finished()


func _check_finished() -> void:
	if _finished:
		return
	if _grabs_left > 0 and _items.get_child_count() > 0:
		return
	_finished = true
	_claw.can_drop = false
	_show_toast(Strings.t("claw_finished"))
	Events.sfx_requested.emit(&"day_end")
	var timer := get_tree().create_timer(END_DELAY)
	timer.timeout.connect(func() -> void: Events.phase_finished.emit())


func _refresh_hud() -> void:
	_day_label.text = Strings.tf("day_label", {"n": _day.day_number})
	_quota_label.text = "%s %d" % [Strings.t("day_quota"), _day.quota]
	_grabs_label.text = "%s %d" % [Strings.t("claw_grabs_left"), _grabs_left]
	_collected_label.text = "%s %d" % [Strings.t("claw_inventory"), Game.inventory.size()]


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
