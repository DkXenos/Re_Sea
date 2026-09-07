# inventory, inspect, pick a bin. bins are always clickable and nothing here
# ever says whether you got it right.
#
# the desk art is a whole screen with its own readouts and its own buttons, the
# same way the claw cockpit is, so the shift bar stays hidden and these labels
# sit in the slots painted into the background.
extends Node2D

@onready var _inventory: Control = $UiLayer/Root/InventoryPanel
@onready var _inspect: Control = $UiLayer/Root/InspectPanel
@onready var _bins: Control = $UiLayer/Root/BinRow
@onready var _rulebook: Control = $RulebookLayer/RulebookPanel
@onready var _toast: Label = $UiLayer/Root/Toast
@onready var _rulebook_button: Button = $UiLayer/Root/RulebookButton
@onready var _day_label: Label = $UiLayer/Root/DayLabel
@onready var _quota_label: Label = $UiLayer/Root/QuotaLabel
@onready var _budget_label: Label = $UiLayer/Root/BudgetLabel
@onready var _switch_button: Button = $UiLayer/Root/SwitchButton
@onready var _end_button: Button = $UiLayer/Root/EndButton
@onready var _settings_button: Button = $UiLayer/Root/SettingsButton

var _day: DayData
var _active: bool = true


func _ready() -> void:
	_day = Game.current_day()
	_rulebook_button.text = Strings.t("desk_rulebook_short")
	_rulebook_button.tooltip_text = Strings.t("desk_rulebook_button")
	_switch_button.text = Strings.t("shift_to_claw")
	_end_button.text = Strings.t("shift_end")
	_settings_button.tooltip_text = Strings.t("menu_settings")
	_switch_button.pressed.connect(func() -> void: Events.view_switch_requested.emit())
	_end_button.pressed.connect(func() -> void: Events.shift_end_requested.emit())
	_settings_button.pressed.connect(func() -> void: Events.pause_requested.emit())
	_toast.text = ""
	_inventory.item_selected.connect(_on_item_selected)
	_bins.bin_chosen.connect(_on_bin_chosen)
	_inspect.bin_hint_changed.connect(_bins.highlight)
	_inspect.crate_opened.connect(_on_crate_opened)
	_rulebook_button.pressed.connect(func() -> void: _rulebook.toggle(not _rulebook.visible))
	Events.toast_requested.connect(_show_toast)
	Events.debug_command.connect(_on_debug_command)

	_inventory.refresh()
	_inventory.select_first()
	_refresh_readouts()


func _process(_delta: float) -> void:
	if _active:
		_refresh_readouts()


# the readouts painted into the desk: the day, the target, the shift time left
func _refresh_readouts() -> void:
	if _day == null:
		return
	_day_label.text = Strings.tf("day_label", {"n": _day.day_number})
	_quota_label.text = "%d / %d" % [int(Game.stats.get("sorted", 0)), _day.quota]
	_budget_label.text = "%d" % Game.budget_left


# only the debug command that needs the inspected item
func _on_debug_command(command: StringName, _arg: Variant) -> void:
	match command:
		&"reveal_all":
			if _inspect.entry != null:
				_inspect.entry.reveal_all()
				_inspect.show_entry(_inspect.entry)
		&"fill_inventory":
			_inventory.refresh()
			_inventory.select_first()


# a view inside the shift, not a phase. keeps its state across tab switches.
func set_view_active(active: bool) -> void:
	_active = active
	for child in get_children():
		if child is CanvasLayer:
			child.visible = active
	if not active:
		_rulebook.toggle(false)
		_inspect.disarm()
	else:
		_inventory.refresh()
		if _inspect.entry == null or _inspect.entry.sorted_to != -1:
			_inventory.select_first()


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event.is_action_pressed(&"rulebook"):
		_rulebook.toggle(not _rulebook.visible)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"inventory"):
		# grid is always up, so this jumps to the next unsorted one
		_inventory.select_first()
		get_viewport().set_input_as_handled()


# null = nothing left a bin would take (or only sealed boxes)
func _on_item_selected(entry: CarriedItem) -> void:
	if entry == null:
		_inspect.clear()
	else:
		_inspect.show_entry(entry)


# the contents land in the list under the crate, and the crate stays put as an
# ordinary sortable item
func _on_crate_opened() -> void:
	_inventory.refresh()


func _on_bin_chosen(category: int) -> void:
	var entry: CarriedItem = _inspect.entry
	if entry == null or entry.sorted_to != -1:
		_bins.flash(category, false)
		Events.sfx_requested.emit(&"bin_reject")
		_show_toast(Strings.t("desk_no_selection"))
		return
	if entry.is_container() and not entry.opened:
		_bins.flash(category, false)
		Events.sfx_requested.emit(&"bin_reject")
		_show_toast(Strings.t("box_not_sortable"))
		return
	if not Game.spend(&"sort"):
		_bins.flash(category, false)
		Events.sfx_requested.emit(&"bin_reject")
		_show_toast(Strings.t("budget_too_low"))
		return
	# recorded but not shown. they find out at the day report.
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


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.7)
