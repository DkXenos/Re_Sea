## Builds the "here is what you got wrong and why" row.
##
## Extracted in revision 3 so the day report and the after-day screen show the
## identical explanation. Two screens that both explain a mis-sort must never be
## able to disagree about what the player missed, and the only way to guarantee
## that is for there to be one of them.
class_name MistakeView
extends RefCounted

const FIELD_LABELS: Dictionary = {
	"has_residue": "chip_residue",
	"residue_type": "chip_residue_type",
	"true_material": "chip_true_material",
	"tag_text": "chip_tag",
}


## The properties that decided this item's bin and that the player never spent
## budget to look at. This is the line that should sting.
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


## A PanelContainer sizes itself to its content, so a two-line rule never gets
## clipped the way a fixed-height row would. Its background is the PNG-backed
## stylebox from the shared theme.
static func build_row(entry: CarriedItem, icon_size: int = 96) -> Control:
	var row := PanelContainer.new()

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 14)
	row.add_child(columns)

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

	add_line(lines, entry.data.display_name, 19, Color(1, 1, 1))
	add_line(lines, Strings.tf("report_you_put",
		{"v": Strings.category_name(entry.sorted_to)}), 15, Color(0.95, 0.55, 0.5))
	add_line(lines, Strings.tf("report_should_be",
		{"v": Strings.category_name(entry.expected_category)}), 15, Color(0.6, 0.9, 0.7))
	for missed: String in missed_properties(entry):
		add_line(lines, Strings.tf("report_missed", {"v": missed}), 14, Color(0.95, 0.83, 0.42))
	if entry.broken_rule != null:
		add_line(lines, Strings.tf("report_rule", {"v": entry.broken_rule.text}), 13,
			Color(0.72, 0.78, 0.85))
	return row


static func add_line(parent: Node, text: String, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
