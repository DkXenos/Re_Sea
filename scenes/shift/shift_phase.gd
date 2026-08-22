## One shift, two views. The tank and the desk are tabs of the same day rather
## than sequential phases: they share one budget and one inventory, and the
## player moves between them freely at no cost.
##
## Switching is free on purpose. The decision this game is built around is "grab
## another item or examine the one already in hand", and that decision is only
## real if looking at the desk does not itself cost anything.
extends Node2D

enum View { CLAW, DESK }

const END_DELAY := 1.4

@onready var _claw_view: Node2D = $ClawView
@onready var _desk_view: Node2D = $DeskView
@onready var _day_label: Label = $BarLayer/Root/DayLabel
@onready var _quota_label: Label = $BarLayer/Root/QuotaLabel
@onready var _budget_label: Label = $BarLayer/Root/BudgetLabel
@onready var _status: Label = $BarLayer/Root/Status
@onready var _switch_button: Button = $BarLayer/Root/SwitchButton
@onready var _end_button: Button = $BarLayer/Root/EndButton

var _day: DayData
var _view: View = View.CLAW
var _finished: bool = false


func _ready() -> void:
	_day = Game.current_day()
	_end_button.text = Strings.t("shift_end")
	_status.text = ""
	_switch_button.pressed.connect(_toggle_view)
	_end_button.pressed.connect(_end_shift)
	_apply_view()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"switch_view"):
		_toggle_view()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	_refresh_bar()
	_check_shift_over()


func _toggle_view() -> void:
	if _finished:
		return
	_view = View.DESK if _view == View.CLAW else View.CLAW
	Events.sfx_requested.emit(&"ui_click")
	_apply_view()


func _apply_view() -> void:
	_claw_view.set_view_active(_view == View.CLAW)
	_desk_view.set_view_active(_view == View.DESK)


func _refresh_bar() -> void:
	if _day == null:
		return
	_day_label.text = Strings.tf("day_label", {"n": _day.day_number})
	_quota_label.text = "%s %d / %d" % [Strings.t("day_quota"),
		int(Game.stats.get("sorted", 0)), _day.quota]
	_budget_label.text = "%s %d / %d" % [Strings.t("budget_label"),
		Game.budget_left, Game.budget_max]
	# The tab button says where it goes, how much work is waiting there, and
	# which key does it - strangers demoing this will not read a control list.
	var unsorted := Game.unsorted_items().size()
	if _view == View.CLAW:
		_switch_button.text = "%s (%d)  ·  TAB" % [Strings.t("shift_to_desk"), unsorted]
		_switch_button.tooltip_text = Strings.tf("shift_unsorted", {"n": unsorted})
	else:
		_switch_button.text = "%s  ·  TAB" % Strings.t("shift_to_claw")
		_switch_button.tooltip_text = ""


## The shift is over when the budget can no longer buy any useful action, or
## when there is genuinely nothing left to do. Ending early with quota met is a
## legitimate strategic choice, which is what the End Shift button is for.
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
	_switch_button.disabled = true
	_end_button.disabled = true
	_status.text = Strings.t("shift_over")
	Events.sfx_requested.emit(&"day_end")
	var timer := get_tree().create_timer(END_DELAY)
	timer.timeout.connect(func() -> void: Events.phase_finished.emit())
