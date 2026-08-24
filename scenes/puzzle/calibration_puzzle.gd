## EXPERIMENTAL - revision 2 §5. This may be cut.
##
## After a blueprint is built, the machine needs its operating sequence put in
## order. Four steps, dragged into place, one button to run them. A wrong order
## explains itself and can be retried immediately at no cost.
##
## Everything about it lives in this folder. To remove it entirely: delete
## scenes/puzzle/, the `feature_calibration_puzzle` flag in autoload/game.gd,
## the marked block in scenes/unlock/unlock_screen.gd, the marked block in
## data/strings.gd, and its line in the layer table in CLAUDE.md. Nothing else
## in the game knows it exists.
##
## Deliberately NOT built: block programming, loops, conditionals, an execution
## engine, or a puzzle authoring system. This is a list with an order check.
extends CanvasLayer

signal finished()

const STEP_ROW := preload("res://scenes/puzzle/step_row.tscn")
## The whole reward. It is a flat bonus applied outside the day's formula, so
## the puzzle cannot touch the health arithmetic, the budget or the blueprint
## counters. Failing costs nothing.
const HEALTH_BONUS := 2

## The two machines, and why each wrong order is wrong.
##
## `reasons` are pairs of indices into the correct order: if `before` ends up
## ahead of `after`, that line is what the player is told. The lines carry the
## whole educational value here, so each one says what actually goes wrong
## rather than "salah urutan".
##
## This is content and it lives here rather than in strings.gd on purpose: §5
## requires that deleting this folder removes the feature completely.
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


## Returns false when this blueprint has no sequence built, which is how the
## caller knows to skip the puzzle entirely. Only two exist.
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


## Never opens on the correct order - the player would press Run and learn
## nothing.
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


## Called by a row that had another row dropped on it.
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
		_message.text = Strings.tf("puzzle_success", {"n": HEALTH_BONUS})
		_message.add_theme_color_override("font_color", Color(0.6, 0.92, 0.72))
		Game.set_ocean_health(Game.ocean_health + HEALTH_BONUS)
		Events.sfx_requested.emit(&"bin_accept")
		return
	_message.text = _failure_line()
	_message.add_theme_color_override("font_color", Color(0.95, 0.72, 0.6))
	Events.sfx_requested.emit(&"bin_reject")


## The first thing that actually goes wrong, in the order the machine would hit
## it. Retrying is free and immediate.
func _failure_line() -> String:
	for reason: Dictionary in _reasons:
		if _order.find(int(reason["before"])) < _order.find(int(reason["after"])):
			return String(reason["text"])
	return Strings.t("puzzle_wrong")


func _close() -> void:
	finished.emit()
	queue_free()
