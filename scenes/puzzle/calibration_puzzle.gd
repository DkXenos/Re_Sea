# EXPERIMENTAL, might get cut.
#
# put the machine's operating sequence in order. four steps, drag them, one
# button to run. wrong order explains itself, retry is free.
#
# to rip it out: this folder, feature_calibration_puzzle in autoload/game.gd,
# the marked block in after_day.gd, and the marked block in data/strings.gd.
#
# it is a list with an order check. not block programming, no loops, no
# execution engine. don't let it grow into one.
extends CanvasLayer

signal finished()

const STEP_ROW := preload("res://scenes/puzzle/step_row.tscn")
# flat budget bonus, kept outside the day formula so it stays self-contained.
# failing costs nothing.
const BUDGET_BONUS := 4

# reasons are index pairs into the correct order - if `before` ends up ahead
# of `after`, that's the line they get. say what actually goes wrong, not
# "salah urutan".
#
# text lives here and not in strings.gd so deleting the folder kills it all.
const SEQUENCES: Dictionary = {
	&"penyaring_mikroplastik": {
		"steps": ["Sedot air", "Saring partikel", "Kumpulkan residu", "Buang air bersih"],
		"reasons": [
			{"before": 3, "after": 1,
				"text": "Air dibuang sebelum disaring. Residunya ikut keluar."},
			{"before": 1, "after": 0,
				"text": "Belum ada air yang disedot, jadi tidak ada yang bisa disaring."},
			{"before": 3, "after": 2,
				"text": "Air dibuang sebelum residunya dikumpulkan. Residunya hanyut lagi."},
			{"before": 2, "after": 1,
				"text": "Residu dikumpulkan sebelum penyaringan. Belum ada apa pun yang terkumpul."},
		],
	},
	&"penetral_b3": {
		"steps": ["Isolasi wadah", "Netralkan zat", "Uji keasaman", "Segel dan simpan"],
		"reasons": [
			{"before": 1, "after": 0,
				"text": "Wadah belum diisolasi. Zatnya bocor."},
			{"before": 3, "after": 0,
				"text": "Disegel sebelum wadahnya diisolasi. Bahayanya ikut tersegel di tempat yang salah."},
			{"before": 2, "after": 1,
				"text": "Diuji sebelum diproses. Hasilnya hanya menunjukkan keadaan awal."},
			{"before": 3, "after": 2,
				"text": "Disegel sebelum diuji. Tidak ada yang tahu isinya sudah aman atau belum."},
		],
	},
}

@onready var _title: Label = $Root/TitleLabel
@onready var _hint: Label = $Root/HintLabel
@onready var _rows: VBoxContainer = $Root/Rows
@onready var _message: Label = $Root/MessageLabel
@onready var _run: Button = $Root/RunButton
@onready var _skip: Button = $Root/SkipButton

var _steps: Array[String] = []
var _order: Array[int] = []
var _reasons: Array = []
var _solved: bool = false


# false = no sequence for this blueprint, caller skips the puzzle. only 2 exist.
func setup(blueprint_id: StringName) -> bool:
	if not SEQUENCES.has(blueprint_id):
		return false
	var seq: Dictionary = SEQUENCES[blueprint_id]
	_steps.assign(seq["steps"])
	_reasons = seq["reasons"]
	return true


func _ready() -> void:
	_title.text = Strings.t("puzzle_title")
	_hint.text = Strings.t("puzzle_hint")
	_run.text = Strings.t("puzzle_run")
	_skip.text = Strings.t("puzzle_skip")
	_message.text = ""
	_run.pressed.connect(_on_run)
	_skip.pressed.connect(_close)
	_order = _shuffled_order()
	_rebuild()


# never open on the right order, they'd just hit Run and learn nothing
func _shuffled_order() -> Array[int]:
	var order: Array[int] = []
	for i in _steps.size():
		order.append(i)
	for attempt in 8:
		for i in range(order.size() - 1, 0, -1):
			var j := Game.rng.randi_range(0, i)
			var swap: int = order[i]
			order[i] = order[j]
			order[j] = swap
		if not _is_correct(order):
			break
	return order


func _rebuild() -> void:
	for child in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	for position in _order.size():
		var row: Control = STEP_ROW.instantiate()
		_rows.add_child(row)
		row.setup(_order[position], _steps[_order[position]], self)
		row.set_position_number(position + 1)


# called by whichever row got dropped on
func swap_rows(from_row: Control, to_row: Control) -> void:
	if _solved:
		return
	var a := _order.find(from_row.index)
	var b := _order.find(to_row.index)
	if a < 0 or b < 0:
		return
	var swap: int = _order[a]
	_order[a] = _order[b]
	_order[b] = swap
	_message.text = ""
	Events.sfx_requested.emit(&"ui_click")
	_rebuild()


func _is_correct(order: Array[int]) -> bool:
	for i in order.size():
		if order[i] != i:
			return false
	return true


func _on_run() -> void:
	if _solved:
		return
	if _is_correct(_order):
		_solved = true
		_run.disabled = true
		_skip.text = Strings.t("puzzle_continue")
		# health is gone, so a solved machine pays in the resource that is left
		Game.budget_left += BUDGET_BONUS
		Game.budget_max += BUDGET_BONUS
		Events.budget_changed.emit(Game.budget_left, Game.budget_max)
		_message.text = Strings.tf("puzzle_success", {"n": BUDGET_BONUS})
		_message.add_theme_color_override("font_color", Color(0.6, 0.92, 0.72))
		Events.sfx_requested.emit(&"bin_accept")
		return
	_message.text = _failure_line()
	_message.add_theme_color_override("font_color", Color(0.95, 0.72, 0.6))
	Events.sfx_requested.emit(&"bin_reject")


# first thing that breaks, in the order the machine would hit it
func _failure_line() -> String:
	for reason: Dictionary in _reasons:
		if _order.find(int(reason["before"])) < _order.find(int(reason["after"])):
			return String(reason["text"])
	return Strings.t("puzzle_wrong")


func _close() -> void:
	finished.emit()
	queue_free()
