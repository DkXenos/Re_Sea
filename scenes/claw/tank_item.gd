# one bit of trash in the tank. area2d so the claw finds it by overlap, no
# physics bodies anywhere in this project.
extends Area2D

const FALL_SPEED := 300.0
const DRIFT_SPEED := 52.0
const DRIFT_SWAY := 26.0
const DRIFT_SWAY_RATE := 1.1
const DRIFT_START_Y := -70.0
# Every drawing arrives inside the same square frame and fills a different part
# of it - a newspaper is flat and wide, a toothbrush is a thin column. A shape
# cut to that frame is the same tall square either way, so a flat item ends up
# with a hitbox reaching well above and below anything you can see. The shape is
# measured off the drawn pixels instead: what is on screen is what the claw
# catches, whatever the designer draws next and at whatever size.
const SHAPE_SLACK := 3.0 ## forgiveness around the edge of the drawing, in px
const FALLBACK_HALF := Vector2(40.0, 40.0) ## no art at all - still needs a shape

enum State { SETTLED, CARRIED, FALLING, DRIFTING }

var data: ItemData
var home_y: float = 0.0
var state: State = State.SETTLED

# remembered separately, otherwise a slipped item reparents to wherever the
# claw happened to be
var _home_parent: Node = null
var _drift_x: float = 0.0
var _drift_t: float = 0.0

# one alpha scan per texture instead of per item - the same drawing spawns all
# day and the scan is the only costly part of measuring it
static var _drawn_rects: Dictionary[String, Rect2] = {}

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var shape: CollisionShape2D = $Shape


func _ready() -> void:
	_home_parent = get_parent()


func setup(item: ItemData) -> void:
	data = item
	if sprite == null:
		sprite = $Sprite
	if item.frames != null:
		sprite.sprite_frames = item.frames
	sprite.play(&"idle")
	_fit_shape()


# the box the claw catches this item by, in the item's own coordinates. the
# claw asks rather than assuming a size, so its grip preview and its descent
# agree on where this drawing actually is.
func grab_box() -> Rect2:
	var box: RectangleShape2D = shape.shape as RectangleShape2D if shape != null else null
	if box == null:
		return Rect2(-FALLBACK_HALF, FALLBACK_HALF * 2.0)
	return Rect2(shape.position - box.size * 0.5, box.size)


# cut the shape to the drawing this item was just given
func _fit_shape() -> void:
	if shape == null:
		shape = $Shape
	var rect := _art_rect()
	# a fresh resource every time: the one in the .tscn is shared by every
	# instance of the scene, so resizing it would resize the whole tank
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	shape.position = rect.get_center()


# where the drawing really sits, in this node's own coordinates
func _art_rect() -> Rect2:
	var texture: Texture2D = null
	if sprite.sprite_frames != null and sprite.sprite_frames.get_frame_count(&"idle") > 0:
		texture = sprite.sprite_frames.get_frame_texture(&"idle", 0)
	if texture == null:
		return Rect2(-FALLBACK_HALF, FALLBACK_HALF * 2.0)
	var drawn := _drawn_rect(texture)
	# the sprite is centred, so the middle of the frame sits on the origin
	var frame_origin: Vector2 = -texture.get_size() * 0.5 if sprite.centered else Vector2.ZERO
	var rect := Rect2(
		(drawn.position + frame_origin + sprite.offset) * sprite.scale + sprite.position,
		drawn.size * sprite.scale)
	return rect.grow(SHAPE_SLACK)


# the opaque part of a texture, in its own pixels
static func _drawn_rect(texture: Texture2D) -> Rect2:
	var key := texture.resource_path
	if key.is_empty():
		key = str(texture.get_rid().get_id())
	if _drawn_rects.has(key):
		return _drawn_rects[key]
	# the whole frame, if the pixels can't be read
	var rect := Rect2(Vector2.ZERO, texture.get_size())
	var image := texture.get_image()
	if image != null and not image.is_compressed():
		var used := image.get_used_rect()
		if used.size.x > 0 and used.size.y > 0:
			rect = Rect2(used)
	_drawn_rects[key] = rect
	return rect


# comes in from above and sinks. grabbable the whole way down.
func drift_in(target_x: float, rest_y: float) -> void:
	home_y = rest_y
	_drift_x = target_x
	_drift_t = randf() * TAU
	position = Vector2(target_x, DRIFT_START_Y)
	state = State.DRIFTING
	sprite.play(&"sinking")


func grip_chance() -> float:
	return clampf(1.0 - data.weight * 0.15 + Game.grip_delta(), 0.05, 0.95)


# just reparent it, no joints
func attach_to(claw: Node2D) -> void:
	monitorable = false
	state = State.CARRIED
	reparent(claw)
	position = Vector2(0, 78)
	sprite.play(&"wobble")


func drop_into() -> void:
	var world_pos := global_position
	reparent(_home_parent)
	global_position = world_pos
	state = State.FALLING
	sprite.play(&"sinking")


func _process(delta: float) -> void:
	match state:
		State.FALLING:
			position.y = minf(position.y + FALL_SPEED * delta, home_y)
			if position.y >= home_y:
				_settle()
		State.DRIFTING:
			_drift_t += delta
			position.y = minf(position.y + DRIFT_SPEED * delta, home_y)
			position.x = _drift_x + sin(_drift_t * DRIFT_SWAY_RATE) * DRIFT_SWAY
			if position.y >= home_y:
				_settle()


func _settle() -> void:
	state = State.SETTLED
	monitorable = true
	sprite.play(&"idle")
