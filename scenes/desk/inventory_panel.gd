## The grid of everything the claw brought up today. Cards are built from
## Game.unsorted_items() so nothing here knows how items got into the tank.
extends Control

signal item_selected(entry: CarriedItem)

const SLOT_BG := preload("res://assets/ui/panel_slot.png")
## Selection is a different PNG, not a tint on the plain one (rev 3 §1.4).
const SLOT_BG_SELECTED := preload("res://assets/ui/panel_slot_selected.png")

@onready var _grid: GridContainer = $Scroll/Grid
@onready var _title: Label = $Title
@onready var _empty: Label = $Empty

var _selected: CarriedItem = null


func _ready() -> void:
	_title.text = Strings.t("desk_inventory")
	_empty.text = Strings.t("desk_empty")


func refresh() -> void:
	_clear(_grid)
	var entries := Game.unsorted_items()
	_empty.visible = entries.is_empty()
	for entry: CarriedItem in entries:
		_grid.add_child(_make_card(entry))


func _make_card(entry: CarriedItem) -> Control:
	var card := Control.new()
	card.custom_minimum_size = Vector2(250, 84)

	var bg := NinePatchRect.new()
	# Selection is a different PNG, not a tint (rev 3 §1.4).
	bg.texture = SLOT_BG_SELECTED if entry == _selected else SLOT_BG
	for side: String in ["left", "top", "right", "bottom"]:
		bg.set("patch_margin_" + side, 24)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(bg)

	# The icon and the text live in a container. Setting a Label's size by hand
	# does not survive contact with the layout: it kept one line and ran off the
	# card, so a three-word property line was cut mid-word.
	var columns := HBoxContainer.new()
	columns.set_anchors_preset(Control.PRESET_FULL_RECT)
	columns.offset_left = 8
	columns.offset_top = 8
	columns.offset_right = -10
	columns.offset_bottom = -8
	columns.add_theme_constant_override("separation", 8)
	columns.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(columns)

	var icon := TextureRect.new()
	icon.texture = entry.data.texture
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	columns.add_child(icon)

	# Revision 2 §3: an item names itself only once the player has earned the
	# name. Until then the card lists what can be observed, so choosing what to
	# inspect is a judgement about properties rather than a look-up by label.
	var known := entry.name_known()
	var label := Label.new()
	label.text = entry.label()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14 if known else 12)
	if not known:
		label.add_theme_color_override("font_color", Color(0.78, 0.84, 0.9))
	columns.add_child(label)

	# Invisible hit area; the visible card is the PNG panel plus the item PNG.
	var button := Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(func() -> void:
		_selected = entry
		Events.sfx_requested.emit(&"ui_click")
		item_selected.emit(entry))
	card.add_child(button)
	return card


func select_first() -> void:
	var entries := Game.unsorted_items()
	_selected = entries[0] if not entries.is_empty() else null
	refresh()
	if _selected != null:
		item_selected.emit(_selected)


## queue_free() alone leaves the old children in the tree for the rest of the
## frame, so a list rebuilt twice in one frame would briefly show both sets.
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
