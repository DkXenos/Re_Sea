# one bit of trash in the tank. area2d so the claw finds it by overlap, no
# physics bodies anywhere in this project.
extends Area2D

const FALL_SPEED := 300.0
const DRIFT_SPEED := 52.0
const DRIFT_SWAY := 26.0
const DRIFT_SWAY_RATE := 1.1
const DRIFT_START_Y := -70.0

enum State { SETTLED, CARRIED, FALLING, DRIFTING }

var data: ItemData
var home_y: float = 0.0
var state: State = State.SETTLED

# remembered separately, otherwise a slipped item reparents to wherever the
# claw happened to be
var _home_parent: Node = null
var _drift_x: float = 0.0
var _drift_t: float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	_home_parent = get_parent()


func setup(item: ItemData) -> void:
	data = item
	if sprite == null:
		sprite = $Sprite
	if item.frames != null:
		sprite.sprite_frames = item.frames
	sprite.play(&"idle")


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
