## Phase B. Open the inventory, inspect an item, decide which bin it belongs in.
##
## The tension is not "which bin" - it is "is this item worth spending a tool
## charge on?" Bins are always clickable, tools are always spendable, and
## nothing here tells the player whether they were right.
extends Node2D

const END_DELAY := 1.0

@onready var _inventory: Control = $UiLayer/Root/InventoryPanel
@onready var _inspect: Control = $UiLayer/Root/InspectPanel
@onready var _bins: Control = $UiLayer/Root/BinRow
@onready var _rulebook: Control = $UiLayer/Root/RulebookPanel
@onready var _title: Label = $UiLayer/Root/TitleLabel
@onready var _day_label: Label = $UiLayer/Root/DayLabel
@onready var _progress: Label = $UiLayer/Root/ProgressLabel
@onready var _toast: Label = $UiLayer/Root/Toast
@onready var _rulebook_button: Button = $UiLayer/Root/RulebookButton
@onready var _finish_button: Button = $UiLayer/Root/FinishButton

var _day: DayData
var _finished: bool = false


func _ready() -> void:
	_day = Game.current_day()
	_title.text = Strings.t("desk_title")
	_rulebook_button.text = Strings.t("desk_rulebook_button")
	_finish_button.text = Strings.t("desk_finish")
	_toast.text = ""
	_inventory.item_selected.connect(_on_item_selected)
	_bins.bin_chosen.connect(_on_bin_chosen)
	_rulebook_button.pressed.connect(func() -> void: _rulebook.toggle(not _rulebook.visible))
	_finish_button.pressed.connect(_finish)
	Events.toast_requested.connect(_show_toast)
	Events.debug_command.connect(_on_debug_command)
	_inventory.refresh()
	_inventory.select_first()
	_refresh_header()


## Only the debug command that needs the currently inspected item lands here.
func _on_debug_command(command: StringName, _arg: Variant) -> void:
	match command:
		&"reveal_all":
			if _inspect.entry != null:
				_inspect.entry.reveal_all()
				_inspect.show_entry(_inspect.entry)
		&"fill_inventory":
			_inventory.refresh()
			_inventory.select_first()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"rulebook"):
		_rulebook.toggle(not _rulebook.visible)
		get_viewport().set_input_as_handled()


func _on_item_selected(entry: CarriedItem) -> void:
	_inspect.show_entry(entry)


func _on_bin_chosen(category: int) -> void:
	if _finished:
		return
	var entry: CarriedItem = _inspect.entry
	if entry == null or entry.sorted_to != -1:
		_bins.flash(category, false)
		Events.sfx_requested.emit(&"bin_reject")
		_show_toast(Strings.t("desk_no_selection"))
		return
	# The verdict is recorded but deliberately not shown. The day report is
	# where the player finds out, and that delay is the point.
	var correct := RuleChecker.judge(entry, category, _day.active_rules)
	Game.stats["sorted"] = int(Game.stats.get("sorted", 0)) + 1
	var key := "correct" if correct else "wrong"
	Game.stats[key] = int(Game.stats.get(key, 0)) + 1
	Events.item_sorted.emit(entry, category, correct)
	_bins.flash(category, true)
	Events.sfx_requested.emit(&"bin_accept")
	_inspect.disarm()
	_inspect.clear()
	_inventory.select_first()
	_refresh_header()
	if Game.unsorted_items().is_empty():
		_finish_after_delay()


func _refresh_header() -> void:
	_day_label.text = Strings.tf("day_label", {"n": _day.day_number})
	_progress.text = Strings.tf("desk_progress",
		{"a": int(Game.stats.get("sorted", 0)), "b": _day.quota})


func _finish_after_delay() -> void:
	if _finished:
		return
	_finished = true
	_show_toast(Strings.t("desk_empty"))
	var timer := get_tree().create_timer(END_DELAY)
	timer.timeout.connect(_emit_finished)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	_emit_finished()


func _emit_finished() -> void:
	_inspect.disarm()
	Events.sfx_requested.emit(&"day_end")
	Events.phase_finished.emit()


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.7)
