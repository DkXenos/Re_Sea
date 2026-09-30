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
# the fourth plate is still named bin_landfill.png on disk - the category was
# renamed to RESIDUE, the artwork was not redrawn
const CATEGORY_ASSETS: Array[String] = ["organic", "recyclable", "hazard", "landfill"]
const CATEGORY_KEYS: Array[String] = ["bin_organic", "bin_recyclable", "bin_hazard", "bin_residue"]

# the bin stands in a pedestal painted into desk_bg. these two put it in the
# tray and put its name on the tray's front face, where the pale blue takes
# dark text - white on that plate could not be read at all.
const BIN_CENTRE_Y := 96.0
# the flat top of the tray is only ~125px across at this height, and RECYCLABLE
# at 15pt ran the full width of it and out over both sloped sides. 13pt is the
# largest that leaves a margin on the longest of the four names.
const LABEL_WIDTH := 128.0
const LABEL_FONT_SIZE := 13
# the tray's front face: top edge, then how tall it is. the label is the size
# of the face and centred inside it - a 24px box top-aligned on that edge left
# the name tucked up under the recessed lip instead of sitting on the face.
const LABEL_Y := 165.0
const LABEL_HEIGHT := 35.0
const LABEL_COLOUR := Color(0.05, 0.19, 0.36)

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
		outline.position = Vector2(centre - OUTLINE.get_width() * 0.5,
			BIN_CENTRE_Y - OUTLINE.get_height() * 0.5)
		outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		outline.visible = false
		add_child(outline)
		_outlines.append(outline)

		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = load("res://data/frames/bin_%s_frames.tres" % CATEGORY_ASSETS[i])
		sprite.play(&"idle")
		sprite.position = Vector2(centre, BIN_CENTRE_Y)
		add_child(sprite)
		_sprites.append(sprite)

		var label := Label.new()
		label.text = Strings.t(CATEGORY_KEYS[i])
		# sized to the pedestal, not to the slot - a slot-wide label ran off
		# both sides of the tray it is meant to be sitting on
		label.position = Vector2(centre - LABEL_WIDTH * 0.5, LABEL_Y)
		label.size = Vector2(LABEL_WIDTH, LABEL_HEIGHT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
		label.add_theme_color_override("font_color", LABEL_COLOUR)
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
