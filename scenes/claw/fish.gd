## Background atmosphere. Revision 1 removed every interaction: no Area2D, no
## collision, no grab, no penalty. Punishing the player for something that was
## never a decision read as unfair and the system bought nothing; as background,
## fish carry the underwater feel the designers' art will live in.
##
## Motion is a sine drift driven by game state, which §1 allows. The fish itself
## is an AnimatedSprite2D playing "swim" - nothing about how it looks is decided
## here.
extends Node2D

var speed: float = 55.0
var amplitude: float = 22.0
var frequency: float = 1.2
var base_y: float = 160.0
var direction: int = 1
var bounds: Vector2 = Vector2(40, 960)

var _t: float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite


## depth 0 = far (small, slow, dim), 1 = near. Gives the shoal parallax without
## a second camera.
func setup(frames: SpriteFrames, y: float, spd: float, dir: int, depth: float,
		travel: Vector2) -> void:
	if sprite == null:
		sprite = $Sprite
	sprite.sprite_frames = frames
	sprite.play(&"swim")
	sprite.scale = Vector2.ONE * lerpf(0.55, 1.15, depth)
	sprite.modulate.a = lerpf(0.45, 1.0, depth)
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
	sprite.flip_h = direction < 0
