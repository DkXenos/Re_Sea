## Phase B. Open the inventory, inspect an item, decide which bin it belongs in.
##
## The tension is not "which bin" - it is "is this item worth spending a tool
## charge on?" Bins are always clickable, tools are always spendable, and
## nothing here tells the player whether they were right.
extends Node2D

@onready var _inventory: Control = $UiLayer/Root/InventoryPanel
@onready var _inspect: Control = $UiLayer/Root/InspectPanel
@onready var _bins: Control = $UiLayer/Root/BinRow
@onready var _rulebook: Control = $RulebookLayer/RulebookPanel
@onready var _toast: Label = $UiLayer/Root/Toast
@onready var _rulebook_button: Button = $UiLayer/Root/RulebookButton

var _day: DayData
var _active: bool = true


func _ready() -> void:
	_day = Game.current_day()
	_rulebook_button.text = Strings.t("desk_rulebook_button")
	_toast.text = ""
	_inventory.item_selected.connect(_on_item_selected)
	_bins.bin_chosen.connect(_on_bin_chosen)
	_inspect.bin_hint_changed.connect(_bins.highlight)
	_rulebook_button.pressed.connect(func() -> void: _rulebook.toggle(not _rulebook.visible))
	Events.toast_requested.connect(_show_toast)
	Events.debug_command.connect(_on_debug_command)

	_inventory.refresh()
	_inventory.select_first()


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


## The desk is a view inside the shift, not a phase: it never decides that the
## day is over, and it keeps its state when the player switches to the tank.
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
		# The grid is always on screen here, so this is a shortcut to the next
		# unsorted item rather than a panel toggle.
		_inventory.select_first()
		get_viewport().set_input_as_handled()


## Null means the inventory holds nothing a bin would take - either everything
## is sorted, or the only things left are sealed boxes waiting to be opened.
func _on_item_selected(entry: CarriedItem) -> void:
	if entry == null:
		_inspect.clear()
	else:
		_inspect.show_entry(entry)


func _on_bin_chosen(category: int) -> void:
	var entry: CarriedItem = _inspect.entry
	if entry == null or entry.sorted_to != -1:
		_bins.flash(category, false)
		Events.sfx_requested.emit(&"bin_reject")
		_show_toast(Strings.t("desk_no_selection"))
		return
	if not Game.spend(&"sort"):
		_bins.flash(category, false)
		Events.sfx_requested.emit(&"bin_reject")
		_show_toast(Strings.t("budget_too_low"))
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


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.7)
