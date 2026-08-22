## The four bins. Always clickable - the player may sort with zero evidence at
## any time, and nothing here tells them whether they were right. Correctness is
## revealed in the day report, and that delay is what makes a decision weigh.
##
## "accept" plays when a bin takes an item, not when the answer was correct.
## "reject" plays when the click could not be honoured at all.
extends Control

signal bin_chosen(category: int)

const CATEGORY_ASSETS: Array[String] = ["organic", "recyclable", "hazard", "landfill"]
const CATEGORY_KEYS: Array[String] = ["bin_organic", "bin_recyclable", "bin_hazard", "bin_landfill"]

var _sprites: Array[AnimatedSprite2D] = []
var _highlighted: int = -1


func _ready() -> void:
	var slot := size.x / float(CATEGORY_ASSETS.size())
	for i in CATEGORY_ASSETS.size():
		var centre := slot * (i + 0.5)

		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = load("res://data/frames/bin_%s_frames.tres" % CATEGORY_ASSETS[i])
		sprite.play(&"idle")
		sprite.scale = Vector2(0.72, 0.72)
		sprite.position = Vector2(centre, 96)
		add_child(sprite)
		_sprites.append(sprite)

		var label := Label.new()
		label.text = Strings.t(CATEGORY_KEYS[i])
		label.position = Vector2(centre - slot * 0.5, 186)
		label.size = Vector2(slot, 26)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 18)
		add_child(label)

		var button := Button.new()
		button.flat = true
		button.position = Vector2(centre - slot * 0.5 + 8, 8)
		button.size = Vector2(slot - 16, 200)
		button.pressed.connect(bin_chosen.emit.bind(i))
		add_child(button)


## Marks the bin the player's own revealed evidence currently points at. This
## is the other half of the chip highlight: the reasoning and its conclusion
## light up together.
func highlight(category: int) -> void:
	for i in _sprites.size():
		var sprite := _sprites[i]
		if sprite.animation in [&"accept", &"reject"]:
			continue  # a flash is playing; leave it alone
		sprite.play(&"highlight" if i == category else &"idle")


func flash(category: int, accepted: bool) -> void:
	if category < 0 or category >= _sprites.size():
		return
	var sprite := _sprites[category]
	sprite.play(&"accept" if accepted else &"reject")
	var timer := get_tree().create_timer(0.35)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.play(&"idle"))
	_highlighted = -1
