## Skippable intro: static PNG plus a line of text, click or Enter to advance.
## Placeholder text - the owner writes the real script later.
extends Node2D

const STILLS: Array[String] = [
	"res://assets/env/cutscene_01.png",
	"res://assets/env/cutscene_02.png",
	"res://assets/env/cutscene_03.png",
]
const LINE_KEYS: Array[String] = ["cutscene_line_1", "cutscene_line_2", "cutscene_line_3"]

var _index: int = 0


func _ready() -> void:
	$UiLayer/Root/SkipButton.text = Strings.t("cutscene_skip")
	$UiLayer/Root/SkipButton.pressed.connect(_finish)
	$UiLayer/Root/AdvanceHint.text = Strings.t("cutscene_advance")
	_show(0)


func _show(index: int) -> void:
	_index = index
	$UiLayer/Root/Still.texture = load(STILLS[index])
	$UiLayer/Root/Line.text = Strings.t(LINE_KEYS[index])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		_finish()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"advance"):
		Events.sfx_requested.emit(&"ui_click")
		if _index + 1 < STILLS.size():
			_show(_index + 1)
		else:
			_finish()
		get_viewport().set_input_as_handled()


func _finish() -> void:
	Events.phase_finished.emit()
