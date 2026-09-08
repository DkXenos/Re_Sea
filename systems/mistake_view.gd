# the "here's what you got wrong" row. shared by the day report and the
# after-day screen so the two can't disagree.
class_name MistakeView
extends RefCounted

const FIELD_LABELS: Dictionary = {
	"is_stained": "chip_stain",
	"stain_type": "chip_stain_type",
	"stain_hazardous": "chip_stain_hazardous",
	"true_material": "chip_true_material",
}


# what decided the bin that they never bothered to look at
static func missed_properties(entry: CarriedItem) -> Array[String]:
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


# No plate behind the row: this is written on the end-of-day sheet, and a dark
# panel per mistake would bury the paper. Height comes from the text, so a
# two-line rule is never clipped.
static func build_row(entry: CarriedItem, icon_size: int = 96) -> Control:
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 12)

	var icon := TextureRect.new()
	icon.texture = entry.data.texture
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	columns.add_child(icon)

	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.add_theme_constant_override("separation", 2)
	columns.add_child(lines)

	add_line(lines, entry.data.display_name, 17, Color(1, 1, 1))
	add_line(lines, Strings.tf("report_you_put",
		{"v": Strings.category_name(entry.sorted_to)}), 14, Color(1, 0.76, 0.7))
	add_line(lines, Strings.tf("report_should_be",
		{"v": Strings.category_name(entry.expected_category)}), 14, Color(0.75, 1, 0.82))
	for missed: String in missed_properties(entry):
		add_line(lines, Strings.tf("report_missed", {"v": missed}), 13, Color(1, 0.93, 0.6))
	if entry.broken_rule != null:
		add_line(lines, Strings.tf("report_rule", {"v": entry.broken_rule.text}), 13,
			Color(0.85, 0.92, 1))
	return columns


static func add_line(parent: Node, text: String, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
