# every mis-sort with the property they didn't check and the rule it broke,
# and what the day put in the store. no points and no progress bar - what the
# day is worth is the material, and how far the machines have got is the
# Technology tab's job on the next screen.
extends Node2D

@onready var _title: Label = $UiLayer/Root/TitleLabel
@onready var _quota: Label = $UiLayer/Root/QuotaLabel
@onready var _mistakes_title: Label = $UiLayer/Root/MistakesTitle
@onready var _mistakes: VBoxContainer = $UiLayer/Root/MistakesScroll/Mistakes
@onready var _recovered_title: Label = $UiLayer/Root/RecoveredTitle
@onready var _recovered: VBoxContainer = $UiLayer/Root/Recovered
@onready var _next: Button = $UiLayer/Root/NextButton

var _result: Dictionary


func _ready() -> void:
	var day := Game.current_day()
	_result = Game.end_day_breakdown()
	_title.text = Strings.tf("report_title", {"n": day.day_number if day else 0})
	_quota.text = Strings.t("report_quota_met") if _result["quota_met"] \
		else Strings.t("report_quota_failed")
	_mistakes_title.text = Strings.t("report_mistakes")
	_next.text = Strings.t("report_next")
	_next.pressed.connect(func() -> void: Events.phase_finished.emit())
	_build_mistakes()
	_build_recovered()
	Events.sfx_requested.emit(&"day_end")
	# commit after the numbers are up
	Game.commit_day_result(_result)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"advance"):
		Events.phase_finished.emit()
		get_viewport().set_input_as_handled()


# mistakes

func _build_mistakes() -> void:
	var any := false
	for entry: CarriedItem in Game.inventory:
		if entry.sorted_to == -1 or entry.was_correct:
			continue
		any = true
		_mistakes.add_child(_make_row(entry))
	if not any:
		var label := Label.new()
		label.text = Strings.t("report_perfect")
		label.add_theme_font_size_override("font_size", 19)
		_mistakes.add_child(label)


# what the day actually paid out. a wrong bin is not a smaller payout, it is
# no payout - the item is gone, so it never shows up here.
func _build_recovered() -> void:
	_recovered_title.text = Strings.t("report_recovered")
	var recovered := Game.day_recovered()
	if recovered.is_empty():
		_add_line(_recovered, Strings.t("report_recovered_none"), 16,
			Color(0.95, 0.72, 0.6))
	else:
		for category in ItemData.Category.values():
			if not recovered.has(category):
				continue
			_add_line(_recovered, Strings.tf("report_recovered_line",
				{"n": int(recovered[category]), "v": Strings.category_name(category)}),
				19, Color(0.6, 0.9, 0.7))
	var wrong: int = int(_result["wrong"])
	if wrong > 0:
		_add_line(_recovered, Strings.tf("report_wasted", {"n": wrong}), 15,
			Color(0.95, 0.55, 0.5))
	_add_line(_recovered, Strings.t("report_recovered_note"), 13,
		Color(0.72, 0.78, 0.85))


func _make_row(entry: CarriedItem) -> Control:
	return MistakeView.build_row(entry)


func _add_line(parent: Node, text: String, font_size: int, color: Color) -> void:
	MistakeView.add_line(parent, text, font_size, color)
