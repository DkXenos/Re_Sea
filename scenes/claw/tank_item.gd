## One piece of trash sitting in the tank. An Area2D so the claw can find it by
## overlap - there is no physics body and no RigidBody2D anywhere in this
## project. Falling back after a failed grip is a tween, not gravity.
extends Area2D

const FALL_TIME := 0.55

var data: ItemData
var home_y: float = 0.0

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
		sprite.play(&"wobble")


func grip_chance() -> float:
	return clampf(1.0 - data.weight * 0.15, 0.25, 0.95)


## Carried by the claw: reparented so it simply follows, no joint, no physics.
func attach_to(claw: Node2D) -> void:
	monitorable = false
	reparent(claw)
	position = Vector2(0, 78)
	rotation = 0.0


## Slipped out of the claw during the rise.
func drop_into() -> void:
	var world_pos := global_position
	reparent(_home_parent)
	global_position = world_pos
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", home_y, FALL_TIME)
	tween.parallel().tween_property(self, "rotation", randf_range(-0.4, 0.4), FALL_TIME)
	tween.tween_callback(func() -> void: monitorable = true)
