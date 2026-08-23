## The emotional payoff. Every mis-sorted item is shown with the property the
## player did not check and the rule it broke, and only then does the ocean
## meter move.
##
## Every term of the health formula is printed on its own line with its own
## number. Showing only the final figure would make the number feel arbitrary;
## the player has to be able to trace it.
extends Node2D

const FIELD_LABELS: Dictionary = {
	"has_residue": "chip_residue",
	"residue_type": "chip_residue_type",
	"true_material": "chip_true_material",
	"tag_text": "chip_tag",
}
const METER_WIDTH := 320.0

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
	# Committing here, after the numbers are on screen, keeps the report the
	# single place the ocean meter can change - and, since revision 2, the
	# single place the ocean's ART can change.
	var tier_before := Game.visual_tier
	Game.commit_day_result(_result)
	_show_tier_line(tier_before)


## One quiet sentence when the ocean crosses a tier boundary, and nothing at
## all when it does not. The restraint is deliberate: the meter moving a little
## every day is the reward, and a fanfare would cheapen it.
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


# ------------------------------------------------------------------- mistakes

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
	# A PanelContainer sizes itself to its content, so a two-line rule never
	# gets clipped the way a fixed-height row would. Its background is the
	# PNG-backed stylebox from the shared theme.
	var row := PanelContainer.new()

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 14)
	row.add_child(columns)

	var icon := TextureRect.new()
	icon.texture = entry.data.texture
	icon.custom_minimum_size = Vector2(96, 96)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	columns.add_child(icon)

	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.add_theme_constant_override("separation", 2)
	columns.add_child(lines)

	_add_line(lines, entry.data.display_name, 19, Color(1, 1, 1))
	_add_line(lines, Strings.tf("report_you_put",
		{"v": Strings.category_name(entry.sorted_to)}), 15, Color(0.95, 0.55, 0.5))
	_add_line(lines, Strings.tf("report_should_be",
		{"v": Strings.category_name(entry.expected_category)}), 15, Color(0.6, 0.9, 0.7))
	for missed: String in _missed_properties(entry):
		_add_line(lines, Strings.tf("report_missed", {"v": missed}), 14, Color(0.95, 0.83, 0.42))
	if entry.broken_rule != null:
		_add_line(lines, Strings.tf("report_rule", {"v": entry.broken_rule.text}), 13,
			Color(0.72, 0.78, 0.85))
	return row


## The properties that decided this item's bin and that the player never spent a
## charge to look at. This is the line that should sting.
func _missed_properties(entry: CarriedItem) -> Array[String]:
	var out: Array[String] = []
	if entry.broken_rule == null:
		return out
	var seen: Dictionary = {}
	for key: String in entry.broken_rule.applies_when:
		if not RuleChecker.RULE_KEY_TO_REVEAL.has(key):
			continue
		var field: String = RuleChecker.RULE_KEY_TO_REVEAL[key]
		if entry.is_revealed(field) or seen.has(field):
			continue
		seen[field] = true
		out.append(Strings.tf(FIELD_LABELS[field], {"v": entry.data.get_field_text(field)}))
	return out


func _add_line(parent: Node, text: String, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)


# ------------------------------------------------------------------ breakdown

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
