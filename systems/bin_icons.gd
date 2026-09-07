# category -> the bin plate png, so anywhere that talks about a material can
# show the bin it comes out of instead of only naming it. same four pngs the
# desk's bin row uses - one png, one thing, no tinting a generic icon.
class_name BinIcons
extends RefCounted

# indexed by ItemData.Category
const PATHS: Array[String] = [
	"res://assets/bins/bin_organic.png",
	"res://assets/bins/bin_recyclable.png",
	"res://assets/bins/bin_hazard.png",
	"res://assets/bins/bin_landfill.png",
]

# the art is 200x240, so a box that isn't taller than it is wide squashes it
const ASPECT := 200.0 / 240.0


static func texture(category: int) -> Texture2D:
	if category < 0 or category >= PATHS.size():
		return null
	return load(PATHS[category])


# a bin plate sized to sit beside a line of text
static func make_icon(category: int, height: float) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture(category)
	rect.custom_minimum_size = Vector2(height * ASPECT, height)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect
