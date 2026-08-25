# four bins, always clickable. you can sort with zero evidence.
# "accept" = the bin took it, NOT that it was right. "reject" = couldn't.
extends Control

# 200x240 art shown at 144x173, otherwise four don't fit across the desk
const BIN_DISPLAY_SCALE := 0.72

signal bin_chosen(category: int)

const CATEGORY_ASSETS: Array[String] = ["organic", "recyclable", "hazard", "landfill"]
const CATEGORY_KEYS: Array[String] = ["bin_organic", "bin_recyclable", "bin_hazard", "bin_landfill"]

var _sprites: Array[AnimatedSprite2D] = []
var _highlighted = -1


# TODO the four bins are hardcoded to four here. adding a fifth category means
# touching this + CATEGORY_KEYS + the enum. should read off the enum really.
func _ready() -> void:
	var slot := size.x / float(CATEGORY_ASSETS.size())
	for i in CATEGORY_ASSETS.size():
		var centre := slot * (i + 0.5)

		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = load("res://data/frames/bin_%s_frames.tres" % CATEGORY_ASSETS[i])
		sprite.play(&"idle")
		sprite.scale = Vector2.ONE * BIN_DISPLAY_SCALE
		sprite.position = Vector2(centre, 90)
		add_child(sprite)
		_sprites.append(sprite)

		var label := Label.new()
		label.text = Strings.t(CATEGORY_KEYS[i])
		label.position = Vector2(centre - slot * 0.5, 178)
		label.size = Vector2(slot, 26)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 18)
		add_child(label)

		var button := Button.new()
		button.flat = true
		button.position = Vector2(centre - slot * 0.5 + 8, 8)
		button.size = Vector2(slot - 16, 192)
		button.pressed.connect(bin_chosen.emit.bind(i))
		add_child(button)


# other half of the chip highlight - reasoning and conclusion light up together
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
