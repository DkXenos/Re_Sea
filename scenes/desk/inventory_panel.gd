# grid of what the claw brought up. built off Game.unsorted_items().
extends Control

signal item_selected(entry: CarriedItem)

const SLOT_BG := preload("res://assets/ui/panel_slot.png")
# selected is a separate png, not a tint
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
	# different png again, not a tint
	bg.texture = SLOT_BG_SELECTED if entry == _selected else SLOT_BG
	for side: String in ["left", "top", "right", "bottom"]:
		bg.set("patch_margin_" + side, 24)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(bg)

	# has to be a container. setting the label size by hand doesn't survive the
	# layout pass and the property line runs off the card mid-word.
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
	icon.texture = entry.display_texture()
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	columns.add_child(icon)

	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	lines.add_theme_constant_override("separation", 2)
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columns.add_child(lines)

	var label := Label.new()
	label.text = entry.data.display_name
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 14)
	lines.add_child(label)

	# a sealed crate has no bin and no evidence - the only thing you can do to
	# it is cut it, so the card says which tool does that
	if entry.is_container() and not entry.opened:
		var opener := Game.container_opener()
		var hint := Label.new()
		hint.text = Strings.t("box_no_tool") if opener == null \
			else Strings.tf("box_needs_tool", {"tool": opener.display_name})
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.add_theme_font_size_override("font_size", 12)
		hint.add_theme_color_override("font_color",
			Color(0.72, 0.78, 0.85) if opener != null else Color(0.95, 0.72, 0.6))
		lines.add_child(hint)

	# invisible hit area over the card
	var button := Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(func() -> void:
		_selected = entry
		Events.sfx_requested.emit(&"ui_click")
		item_selected.emit(entry))
	card.add_child(button)
	return card


# whatever is next to deal with. a sealed crate counts: it is not sortable,
# but cutting it open is the work.
func select_first() -> void:
	var entries := Game.unsorted_items()
	_selected = entries[0] if not entries.is_empty() else null
	refresh()
	item_selected.emit(_selected)


# same deal as the other panels, queue_free isn't enough on its own
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
