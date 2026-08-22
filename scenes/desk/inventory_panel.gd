## The grid of everything the claw brought up today. Cards are built from
## Game.unsorted_items() so nothing here knows how items got into the tank.
extends Control

signal item_selected(entry: CarriedItem)

const SLOT_BG := preload("res://assets/ui/panel_slot.png")

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
	card.custom_minimum_size = Vector2(202, 76)

	var bg := NinePatchRect.new()
	bg.texture = SLOT_BG
	for side: String in ["left", "top", "right", "bottom"]:
		bg.set("patch_margin_" + side, 24)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.add_child(bg)

	var icon := TextureRect.new()
	icon.texture = entry.data.texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2(8, 6)
	icon.size = Vector2(64, 64)
	card.add_child(icon)

	var label := Label.new()
	label.text = entry.data.display_name
	label.position = Vector2(78, 8)
	label.size = Vector2(116, 60)
	label.add_theme_font_size_override("font_size", 14)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(label)

	# Invisible hit area; the visible card is the PNG panel plus the item PNG.
	var button := Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(func() -> void:
		_selected = entry
		Events.sfx_requested.emit(&"ui_click")
		item_selected.emit(entry))
	card.add_child(button)

	if entry == _selected:
		bg.modulate = Color(1.4, 1.4, 1.1)
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
