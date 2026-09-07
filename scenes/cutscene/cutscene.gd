# full-screen still + one line in the bubble, click or enter to advance.
#
# a beat is [still index, string key], so a still can hold several lines and the
# picture only changes when the story does. add a row to add a beat.
extends Node2D

const STILLS: Array[String] = [
	"res://assets/env/cutscene_01.png",  # the bay before
	"res://assets/env/cutscene_02.png",  # one cup sinking
	"res://assets/env/cutscene_03.png",  # the daily delivery
	"res://assets/env/cutscene_04.png",  # us, looking at it properly
	"res://assets/env/cutscene_05.png",  # the three sheets
]

const BEATS: Array = [
	[0, "open_1"], [0, "open_2"],
	[1, "open_3"], [1, "open_4"],
	[2, "open_5"], [2, "open_6"],
	[3, "open_7"], [3, "open_8"],
	[4, "open_9"], [4, "open_10"], [4, "open_11"],
]

var _beat: int = 0
var _still: int = -1


func _ready() -> void:
	$UiLayer/Root/SkipButton.text = Strings.t("cutscene_skip")
	$UiLayer/Root/SkipButton.pressed.connect(_finish)
	$UiLayer/Root/AdvanceHint.text = Strings.t("cutscene_advance")
	_show(0)


func _show(beat: int) -> void:
	_beat = beat
	var row: Array = BEATS[beat]
	var want: int = int(row[0])
	# only reload when the picture actually changes
	if want != _still:
		_still = want
		$StillLayer/Still.texture = load(STILLS[want])
	$UiLayer/Root/Line.text = Strings.t(String(row[1]))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		_finish()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"advance"):
		Events.sfx_requested.emit(&"ui_click")
		if _beat + 1 < BEATS.size():
			_show(_beat + 1)
		else:
			_finish()
		get_viewport().set_input_as_handled()


func _finish() -> void:
	Events.phase_finished.emit()
