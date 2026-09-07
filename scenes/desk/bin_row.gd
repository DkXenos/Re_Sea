# four bins, always clickable. you can sort with zero evidence.
#
# the delivered art is ONE drawing per bin, so state is not a second drawing
# here: a separate outline png sits behind the bin and is shown or hidden. it is
# the only overlay, and it means "the evidence points here", never "correct".
#
# there is no accept/reject art any more. a refused sort already says why in the
# toast and the reject sfx, which is where that information belongs - the bin
# lighting up red was a second copy of it.
extends Control

signal bin_chosen(category: int)

const OUTLINE := preload("res://assets/bins/bin_outline.png")

# indexed by ItemData.Category, left to right - same order the rulebook reads in
const CATEGORY_ASSETS: Array[String] = ["organic", "recyclable", "hazard", "landfill"]
const CATEGORY_KEYS: Array[String] = ["bin_organic", "bin_recyclable", "bin_hazard", "bin_landfill"]

# TODO the four bins are hardcoded to four here. adding a fifth category means
# touching this + CATEGORY_KEYS + the enum. should read off the enum really.

var _sprites: Array[AnimatedSprite2D] = []
var _outlines: Array[TextureRect] = []


func _ready() -> void:
	var slot := size.x / float(CATEGORY_ASSETS.size())
	for i in CATEGORY_ASSETS.size():
		var centre := slot * (i + 0.5)

		# behind the bin, hidden until the evidence points at this one
		var outline := TextureRect.new()
		outline.texture = OUTLINE
		outline.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		outline.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		outline.size = Vector2(OUTLINE.get_width(), OUTLINE.get_height())
		outline.position = Vector2(centre - OUTLINE.get_width() * 0.5, 90 - OUTLINE.get_height() * 0.5)
		outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		outline.visible = false
		add_child(outline)
		_outlines.append(outline)

		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = load("res://data/frames/bin_%s_frames.tres" % CATEGORY_ASSETS[i])
		sprite.play(&"idle")
		sprite.position = Vector2(centre, 90)
		add_child(sprite)
		_sprites.append(sprite)

		var label := Label.new()
		label.text = Strings.t(CATEGORY_KEYS[i])
		label.position = Vector2(centre - slot * 0.5, 158)
		label.size = Vector2(slot, 26)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		add_child(label)

		var button := Button.new()
		button.flat = true
		button.position = Vector2(centre - slot * 0.5 + 8, 8)
		button.size = Vector2(slot - 16, 176)
		button.pressed.connect(bin_chosen.emit.bind(i))
		add_child(button)


# other half of the chip highlight - reasoning and conclusion light up together
func highlight(category: int) -> void:
	for i in _outlines.size():
		_outlines[i].visible = i == category


# the bin took it, or it could not. no art for either - the sfx says which, and
# a refusal also carries a toast explaining why. kept so callers read the same.
func flash(_category: int, _accepted: bool) -> void:
	pass
