# every mis-sort with the property they didn't check and the rule it broke,
# then the meter moves. every term of the formula gets its own line - just
# showing the final number makes it feel made up.
extends Node2D

const METER_WIDTH := 320.0  # keep in sync with meter_bg.png

@onready var _title: Label = $UiLayer/Root/TitleLabel
@onready var _quota: Label = $UiLayer/Root/QuotaLabel
@onready var _mistakes_title: Label = $UiLayer/Root/MistakesTitle
@onready var _mistakes: VBoxContainer = $UiLayer/Root/MistakesScroll/Mistakes
@onready var _breakdown: VBoxContainer = $UiLayer/Root/Breakdown
@onready var _health_label: Label = $UiLayer/Root/HealthLabel
@onready var _meter_clip: Control = $UiLayer/Root/MeterClip
@onready var _tier_line: Label = $UiLayer/Root/TierLine
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
	_build_breakdown()
	_animate_meter()
	Events.sfx_requested.emit(&"day_end")
	# commit after the numbers are up. this is the only place the meter moves.
	var tier_before := Game.visual_tier
	Game.commit_day_result(_result)
	_show_tier_line(tier_before)


# one line on a tier change, nothing otherwise. no fanfare.
func _show_tier_line(tier_before: int) -> void:
	_tier_line.text = ""
	if Game.visual_tier == tier_before:
		return
	var tier := Game.current_tier()
	if tier == null:
		return
	_tier_line.text = tier.transition_text
	_tier_line.add_theme_color_override("font_color",
		Color(0.62, 0.9, 0.86) if Game.visual_tier > tier_before else Color(0.9, 0.74, 0.62))


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


func _make_row(entry: CarriedItem) -> Control:
	return MistakeView.build_row(entry)


func _add_line(parent: Node, text: String, font_size: int, color: Color) -> void:
	MistakeView.add_line(parent, text, font_size, color)


# breakdown

func _build_breakdown() -> void:
	_add_term(Strings.t("report_correct"), "%d x (+2)" % _result["correct"],
		2 * int(_result["correct"]))
	_add_term(Strings.t("report_wrong"), "%d x (-4)" % _result["wrong"], -4 * int(_result["wrong"]))
	_add_term(Strings.t("report_shortfall"),
		"%d x (-3)" % maxi(0, int(_result["quota"]) - int(_result["sorted"])),
		-int(_result["shortfall"]))
	_add_term(Strings.t("report_clean_bonus"),
		"" if int(_result["clean_bonus"]) > 0 else "-", int(_result["clean_bonus"]))
	var rule := HSeparator.new()
	_breakdown.add_child(rule)
	_add_term(Strings.t("report_total"), "", int(_result["delta"]), 22)


func _add_term(label_text: String, detail: String, value: int, font_size: int = 18) -> void:
	var row := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = label_text
	name_label.custom_minimum_size = Vector2(230, 0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", font_size)
	row.add_child(name_label)
	var detail_label := Label.new()
	detail_label.text = detail
	detail_label.custom_minimum_size = Vector2(120, 0)
	detail_label.add_theme_font_size_override("font_size", font_size - 3)
	detail_label.add_theme_color_override("font_color", Color(0.68, 0.74, 0.8))
	row.add_child(detail_label)
	var value_label := Label.new()
	value_label.text = "%+d" % value
	value_label.custom_minimum_size = Vector2(100, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", font_size)
	value_label.add_theme_color_override("font_color",
		Color(0.6, 0.9, 0.7) if value >= 0 else Color(0.95, 0.55, 0.5))
	row.add_child(value_label)
	_breakdown.add_child(row)


func _animate_meter() -> void:
	var before: int = int(_result["health_before"])
	var after: int = int(_result["health_after"])
	_meter_clip.size.x = METER_WIDTH * before / 100.0
	_health_label.text = "%s %d" % [Strings.t("report_health"), before]
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_method(func(v: float) -> void:
		_meter_clip.size.x = METER_WIDTH * v / 100.0
		_health_label.text = "%s %d" % [Strings.t("report_health"), int(round(v))],
		float(before), float(after), 0.9)
