# background only. no area2d, no collision, you can't grab these.
extends Node2D

var speed: float = 55.0
var amplitude: float = 22.0
var frequency: float = 1.2
var base_y: float = 160.0
var direction: int = 1
var bounds: Vector2 = Vector2(40, 960)

var _t: float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite


# depth 0 = far, 1 = near. picks speed and drift, never scale or tint - the
# three sizes are three separate PNGs.
func setup(frames: SpriteFrames, y: float, spd: float, dir: int, depth: float,
		travel: Vector2) -> void:
	if sprite == null:
		sprite = $Sprite
	sprite.sprite_frames = frames
	sprite.play(&"swim")
	base_y = y
	speed = spd * lerpf(0.55, 1.2, depth)
	direction = dir
	bounds = travel
	position.x = randf_range(bounds.x, bounds.y)
	position.y = y
	amplitude = lerpf(10.0, 28.0, depth)
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
	# every fish in assets/fish/ is drawn facing LEFT, so the flip belongs on
	# the rightward swim, not the leftward one.
	sprite.flip_h = direction > 0
