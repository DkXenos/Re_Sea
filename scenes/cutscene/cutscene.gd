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

## A still holds for several beats. Without any movement at all the opening
## reads as a slideshow of static pictures, so the picture the reader is looking
## at drifts very slowly in and out, and one still dissolves into the next
## rather than cutting. Both are deliberately small - if you notice them
## happening they are too strong.
const FADE_TIME := 0.45
const DRIFT_TIME := 14.0
## The only display size this scene picks, and the size it returns to. Both
## stills sit in one wrapper so the drift is one scale on one node - the
## outgoing picture keeps drifting while it dissolves instead of snapping back.
const DRIFT_HOME := Vector2.ONE
const DRIFT_SCALE := 1.05

var _beat: int = 0
var _still_index: int = -1
var _fade: Tween = null
var _drift: Tween = null

@onready var _stills: Control = $StillLayer/Stills
@onready var _front: TextureRect = $StillLayer/Stills/Still
@onready var _back: TextureRect = $StillLayer/Stills/StillPrev


func _ready() -> void:
	$UiLayer/Root/AdvanceHint.text = Strings.t("cutscene_advance")
	_show(0)


func _show(beat: int) -> void:
	_beat = beat
	var row: Array = BEATS[beat]
	var want: int = int(row[0])
	# only reload when the picture actually changes
	if want != _still_index:
		_still_index = want
		_swap_still(want)
	$UiLayer/Root/Line.text = Strings.t(String(row[1]))


## The outgoing still is parked on the back layer at full opacity and the new
## one fades in over it, so there is never a frame with nothing on screen.
func _swap_still(index: int) -> void:
	_back.texture = _front.texture
	_back.modulate.a = 1.0 if _front.texture != null else 0.0
	_front.texture = load(STILLS[index])
	_front.modulate.a = 0.0 if _back.modulate.a > 0.0 else 1.0
	if _fade != null and _fade.is_valid():
		_fade.kill()
	if _front.modulate.a < 1.0:
		_fade = create_tween().set_parallel()
		_fade.tween_property(_front, "modulate:a", 1.0, FADE_TIME)
		_fade.tween_property(_back, "modulate:a", 0.0, FADE_TIME)
	_start_drift()


func _start_drift() -> void:
	if _drift != null and _drift.is_valid():
		_drift.kill()
	_stills.scale = DRIFT_HOME
	_drift = create_tween().set_loops()
	_drift.tween_property(_stills, "scale", DRIFT_HOME * DRIFT_SCALE, DRIFT_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_drift.tween_property(_stills, "scale", DRIFT_HOME, DRIFT_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


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
