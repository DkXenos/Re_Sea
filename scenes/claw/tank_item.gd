## One piece of trash in the tank. An Area2D so the claw can find it by overlap
## - there is no physics body and no RigidBody2D anywhere in this project.
##
## Revision 1, §1: nothing here animates the sprite. Falling is positional
## travel driven by game state, which the animation rules allow; the *look* of
## the item at any moment is whichever named animation is playing, and this
## script only chooses between "idle", "wobble" and "sinking". The old version
## tweened position and rotation, which was code deciding what the motion looked
## like.
extends Area2D

const FALL_SPEED := 300.0
## Drifting in on the current: slow, with a gentle sway.
const DRIFT_SPEED := 52.0
const DRIFT_SWAY := 26.0
const DRIFT_SWAY_RATE := 1.1
const DRIFT_START_Y := -70.0

enum State { SETTLED, CARRIED, FALLING, DRIFTING }

var data: ItemData
var home_y: float = 0.0
var state: State = State.SETTLED

## Where this item lives when it is not in the claw. Remembered on its own so a
## slipped item always returns to the item holder rather than wherever the claw
## happened to be parented.
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


## Arrives from above and sinks on a curved path to its resting height.
## Drifting rather than popping into place is physically plausible, shows the
## player that trash arrives from somewhere, and sets up the source_batch field
## for a future "trace the polluter" arc. It is grabbable the whole way down.
func drift_in(target_x: float, rest_y: float) -> void:
	home_y = rest_y
	_drift_x = target_x
	_drift_t = randf() * TAU
	position = Vector2(target_x, DRIFT_START_Y)
	state = State.DRIFTING
	sprite.play(&"sinking")


## The weight curve, plus whatever the run's upgrade traded away. A lighter claw
## is cheaper to drop and worse at holding on (revision 2 §4); the number the
## player sees before the drop already includes that.
func grip_chance() -> float:
	return clampf(1.0 - data.weight * 0.15 + Game.grip_delta(), 0.05, 0.95)


## Carried by the claw: reparented so it simply follows. No joint, no physics.
func attach_to(claw: Node2D) -> void:
	monitorable = false
	state = State.CARRIED
	reparent(claw)
	position = Vector2(0, 78)
	sprite.play(&"wobble")


## Slipped out of the claw during the rise. It sinks back to its resting height.
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
