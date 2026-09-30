# one shift, two views. tank and desk are tabs, not phases - same budget,
# same inventory, switching costs nothing.
#
# both views are whole-screen drawings with their own readouts and buttons, so
# this scene draws nothing of its own until the shift ends - then one plate in
# the middle carries the closing line.
extends Node2D

enum View { CLAW, DESK }

const END_DELAY := 1.4  # 0.8 felt abrupt
# a line worth reading needs longer than the plain "time is up" does
const END_DELAY_MESSAGE := 3.0

@onready var _claw_view: Node2D = $ClawView
@onready var _desk_view: Node2D = $DeskView
@onready var _status: Label = $BarLayer/Root/Status
@onready var _bar: CanvasLayer = $BarLayer

var _day: DayData
var _view: View = View.CLAW
var _finished: bool = false


func _ready() -> void:
	_day = Game.current_day()
	_status.text = ""
	# Both screens are now whole cockpits with their own readouts and their own
	# buttons, so the shift bar is only a status line. The buttons on each screen
	# ask for what they need through Events.
	Events.view_switch_requested.connect(_toggle_view)
	Events.shift_end_requested.connect(_on_end_requested)
	Events.tutorial_replay_requested.connect(_on_tutorial_replay)
	# _apply_view asks for the tour half belonging to whichever view it puts up,
	# so the cockpit tour opens the first shift of a tutorial run and the desk
	# half waits there until that tab is first switched to.
	_apply_view()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"switch_view"):
		_toggle_view()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	_check_shift_over()


# Asking for the tour from the pause menu has to start it here, on the view
# being looked at. Segments are only ever requested when a screen opens, so
# without this the desk half waited for a tab switch away and back - the tour
# came back on the claw screen instead, which reads as the button not working.
func _on_tutorial_replay() -> void:
	if _finished:
		return
	Game.request_tutorial(_segment_for_view())


func _segment_for_view() -> StringName:
	return &"claw" if _view == View.CLAW else &"desk"


func _toggle_view() -> void:
	if _finished:
		return
	_view = View.DESK if _view == View.CLAW else View.CLAW
	Events.sfx_requested.emit(&"ui_click")
	_apply_view()


func _apply_view() -> void:
	_claw_view.set_view_active(_view == View.CLAW)
	_desk_view.set_view_active(_view == View.DESK)
	# each half is asked for once, when its view first comes up. after a replay
	# both are owed again, so this is also what hands the second half over on
	# the next tab switch.
	Game.request_tutorial(_segment_for_view())
	# Both screens carry their own frame now, so the bar only ever surfaces to
	# announce that the shift is over.
	_bar.visible = false


## Clocking off is a request, not a switch. The day's quota is the day's work,
## and a shift you can walk out of on the first item is a shift you can skip -
## so the button only answers once the quota is met.
##
## This is the ONLY path that can be refused. Running out of shift time, or
## clearing the water with nothing left to sort, still ends the day through
## _check_shift_over below: that is not leaving early, that is the day being
## over, and refusing it would strand the player on a screen with nothing left
## to do.
func _on_end_requested() -> void:
	if _finished:
		return
	if not Game.quota_met():
		Events.toast_requested.emit(
			Strings.tf("shift_end_locked", {"n": Game.quota_left()}))
		Events.sfx_requested.emit(&"bin_reject")
		return
	_end_shift()


# over when the budget can't buy anything useful. ending early once quota is
# met is fine, that's what the button is for.
func _check_shift_over() -> void:
	if _finished:
		return
	if Game.can_still_act() and (_claw_view.has_work() or not Game.unsorted_items().is_empty()):
		return
	_end_shift()


func _end_shift() -> void:
	if _finished:
		return
	_finished = true
	Events.sfx_requested.emit(&"day_end")
	# the closing line is the one thing the bar still exists for
	_bar.visible = true
	var closing := _closing_line()
	_status.text = closing["text"]
	if closing["sfx"] != &"":
		Events.sfx_requested.emit(closing["sfx"])
	var timer := get_tree().create_timer(
		END_DELAY_MESSAGE if closing["special"] else END_DELAY)
	timer.timeout.connect(func() -> void: Events.phase_finished.emit())


# nothing left in the water, nothing left waiting to drift in, nothing left on
# the desk. the day's whole delivery went through your hands.
func sea_cleared() -> bool:
	return not _claw_view.has_work() and Game.unsorted_items().is_empty()


# The two shifts worth saying something about: one where nothing was sorted at
# all, and one that took every last piece out of the water. Everything between
# those is ordinary, and the report says it better than a flash of text can.
# {"text": String, "sfx": StringName, "special": bool}
func _closing_line() -> Dictionary:
	if int(Game.stats.get("sorted", 0)) == 0:
		return {"text": Strings.t("shift_nothing_sorted"),
			"sfx": &"reveal_nothing", "special": true}
	if sea_cleared():
		return {"text": Strings.t("shift_sea_cleared"),
			"sfx": &"reveal_success", "special": true}
	return {"text": Strings.t("shift_over"), "sfx": &"", "special": false}
