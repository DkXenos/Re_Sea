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

enum State { SETTLED, CARRIED, FALLING }

var data: ItemData
var home_y: float = 0.0
var state: State = State.SETTLED

## Where this item lives when it is not in the claw. Remembered on its own so a
## slipped item always returns to the item holder rather than wherever the claw
## happened to be parented.
var _home_parent: Node = null

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


func grip_chance() -> float:
	return clampf(1.0 - data.weight * 0.15, 0.25, 0.95)


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
	if state != State.FALLING:
		return
	position.y = minf(position.y + FALL_SPEED * delta, home_y)
	if position.y >= home_y:
		state = State.SETTLED
		monitorable = true
		sprite.play(&"idle")
