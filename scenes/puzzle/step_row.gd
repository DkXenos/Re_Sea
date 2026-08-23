## One draggable step in the calibration puzzle.
##
## EXPERIMENTAL - revision 2 §5. Everything in scenes/puzzle/ can be deleted
## without touching the rest of the game.
extends Control

const ROW_BG := preload("res://assets/ui/panel_slot.png")

var index: int = 0
var step_text: String = ""

@onready var _bg: NinePatchRect = $Bg
@onready var _label: Label = $Label


func setup(step_index: int, text: String) -> void:
	index = step_index
	step_text = text
	if _label == null:
		_label = $Label
	_label.text = "%d.  %s" % [step_index + 1, text]


func set_position_number(number: int) -> void:
	_label.text = "%d.  %s" % [number, step_text]


## Godot's own drag and drop: the row hands itself over, and the row it lands
## on asks the puzzle to swap them. No drag maths written by hand.
func _get_drag_data(_at: Vector2) -> Variant:
	var preview := NinePatchRect.new()
	preview.texture = ROW_BG
	for side: String in ["left", "top", "right", "bottom"]:
		preview.set("patch_margin_" + side, 24)
	preview.size = size
	preview.modulate = Color(1.3, 1.3, 1.1, 0.9)
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
	get_parent().get_parent().swap_rows(data, self)


func highlight(on: bool) -> void:
	_bg.modulate = Color(1.4, 1.4, 1.1) if on else Color.WHITE
