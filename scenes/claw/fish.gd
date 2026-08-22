## A decoy. Drifts back and forth on a sine path - no AI, no pathfinding, and
## deliberately no avoidance: the fish is an obstacle the player must read, not
## an opponent.
extends Area2D

var speed: float = 55.0
var amplitude: float = 22.0
var frequency: float = 1.2
var base_y: float = 160.0
var direction: int = 1
var bounds: Vector2 = Vector2(40, 960)

var _t: float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite


func setup(frames: SpriteFrames, y: float, spd: float, dir: int) -> void:
	if sprite == null:
		sprite = $Sprite
	sprite.sprite_frames = frames
	sprite.play(&"swim")
	base_y = y
	speed = spd
	direction = dir
	position.y = y
	_t = randf() * TAU


func _process(delta: float) -> void:
	_t += delta
	position.x += direction * speed * delta
	position.y = base_y + sin(_t * frequency) * amplitude
	if position.x < bounds.x:
		position.x = bounds.x
		direction = 1
	elif position.x > bounds.y:
		position.x = bounds.y
		direction = -1
	sprite.flip_h = direction < 0
