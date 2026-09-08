# "what am i working toward" strip. one row per blueprint, nothing clickable,
# crafting is in the Technology tab.
#
# tracks parts assembled, NOT the material pool - the pool goes down when you
# craft and a count that falls reads as losing progress.
#
# only moves at the day report. a counter ticking up the moment you hit the
# right bin would give the answer away.
extends Control

const ROW_BG := preload("res://assets/ui/panel_slot.png")
# 3 rows + 2 separators of 8 have to fit the strip painted into the desk art,
# which is 639px wide. they didn't, and the overflow ran under the info button.
const ROW_WIDTH := 207.0
const ROW_HEIGHT := 34.0

@onready var _rows: HBoxContainer = $Rows


func _ready() -> void:
	Events.blueprints_changed.connect(rebuild)
	rebuild()


func rebuild() -> void:
	_clear(_rows)
	for bp: BlueprintData in Game.blueprints:
		_rows.add_child(_make_row(bp))


func _make_row(bp: BlueprintData) -> Control:
	var done: bool = Game.blueprint_unlocked(bp.id)
	var need: int = bp.components.size()
	var have: int = need if done else bp.crafted_count(Game.crafted)

	var row := Control.new()
	row.custom_minimum_size = Vector2(ROW_WIDTH, ROW_HEIGHT)

	var bg := NinePatchRect.new()
	bg.texture = ROW_BG
	# 14 not 24 - if the ninepatch margins add up to more than the box height
	# the corners draw over each other and you get a doubled edge
	for side: String in ["left", "top", "right", "bottom"]:
		bg.set("patch_margin_" + side, 14)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_child(bg)

	var name_label := Label.new()
	name_label.text = bp.display_name
	# ORDER MATTERS. a Label's minimum size is its whole text until clip_text
	# says otherwise, so assigning size before those two just
	# gets clamped straight back up and a long name walks out of the strip and
	# under the rulebook button.
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.position = Vector2(10, 0)
	name_label.size = Vector2(ROW_WIDTH - 72, ROW_HEIGHT)
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(name_label)

	var count := Label.new()
	count.text = Strings.t("blueprint_done") if done else "%d / %d" % [have, need]
	count.position = Vector2(ROW_WIDTH - 68, 0)
	count.size = Vector2(58, ROW_HEIGHT)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count.add_theme_font_size_override("font_size", 13)
	count.add_theme_color_override("font_color",
		Color(0.6, 0.94, 0.72) if done else Color(0.86, 0.9, 0.94))
	row.add_child(count)

	row.tooltip_text = "%s\n%s" % [bp.display_name, _requirement_text(bp)]
	return row


# whole sheet cost for the tooltip
func _requirement_text(bp: BlueprintData) -> String:
	var parts: Array[String] = []
	var required := bp.total_requirements()
	for category: int in required:
		parts.append("%d %s" % [int(required[category]), Strings.category_name(category)])
	return Strings.tf("blueprint_requires", {"v": ", ".join(parts)})


func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
