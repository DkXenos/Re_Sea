# one draggable step. experimental, see calibration_puzzle.gd.
extends Control

const ROW_BG := preload("res://assets/ui/panel_slot.png")

var index: int = 0
var step_text: String = ""
# hand it over explicitly. do NOT go get_parent().get_parent() - the script
# is on the CanvasLayer, one further up than you'd think, and every drop just
# silently hits a bare Control and does nothing.
var puzzle: Node = null

@onready var _label: Label = $Label


func setup(step_index: int, text: String, owner_puzzle: Node) -> void:
	index = step_index
	step_text = text
	puzzle = owner_puzzle
	if _label == null:
		_label = $Label
	_label.text = "%d.  %s" % [step_index + 1, text]


func set_position_number(number: int) -> void:
	_label.text = "%d.  %s" % [number, step_text]


# godot's built in drag/drop, no hand-written drag maths
func _get_drag_data(_at: Vector2) -> Variant:
	var preview := NinePatchRect.new()
	preview.texture = ROW_BG
	for side: String in ["left", "top", "right", "bottom"]:
		preview.set("patch_margin_" + side, 24)
	preview.size = size
	var label := Label.new()
	label.text = _label.text
	label.position = Vector2(14, 10)
	label.add_theme_font_size_override("font_size", 16)
	preview.add_child(label)
	set_drag_preview(preview)
	return self


func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	return data is Control and data != self


func _drop_data(_at: Vector2, data: Variant) -> void:
	if puzzle != null:
		puzzle.swap_rows(data, self)
