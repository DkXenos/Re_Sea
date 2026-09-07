# "what am i working toward" strip. one row per blueprint, nothing clickable,
# crafting is in the Technology tab.
#
# tracks parts assembled, NOT the material pool - the pool goes down when you
# craft and a bar that falls reads as losing progress.
#
# only moves at the day report. a counter ticking up the moment you hit the
# right bin would give the answer away.
extends Control

const ROW_BG := preload("res://assets/ui/panel_slot.png")
const BAR_BG := preload("res://assets/ui/meter_bg.png")
const BAR_FILL := preload("res://assets/ui/meter_fill.png")
# 3 rows + 2 separators have to fit in 702px. they didn't, and the overflow
# ran under the rulebook button.
const ROW_WIDTH := 228.0
const BAR_WIDTH := 88.0

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
	row.custom_minimum_size = Vector2(ROW_WIDTH, 34)

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
	# ORDER MATTERS, same trap as _meter below. a Label's minimum size is its
	# whole text until clip_text says otherwise, so assigning size first just
	# gets clamped straight back up and a long name walks out of the strip and
	# under the rulebook button.
	name_label.clip_text = true
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.position = Vector2(10, 4)
	name_label.size = Vector2(ROW_WIDTH - 72, 26)
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(name_label)

	var count := Label.new()
	count.text = Strings.t("blueprint_done") if done else "%d / %d" % [have, need]
	count.position = Vector2(ROW_WIDTH - 68, 4)
	count.size = Vector2(58, 26)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count.add_theme_font_size_override("font_size", 13)
	count.add_theme_color_override("font_color",
		Color(0.6, 0.94, 0.72) if done else Color(0.86, 0.9, 0.94))
	row.add_child(count)

	# meter png clipped to width, same as the report's meter
	row.add_child(_meter(BAR_BG, Vector2(10, 26), Vector2(BAR_WIDTH, 5)))
	var clip := Control.new()
	clip.clip_contents = true
	clip.position = Vector2(10, 26)
	clip.custom_minimum_size = Vector2.ZERO
	clip.size = Vector2(BAR_WIDTH * float(have) / maxf(1.0, float(need)), 5)
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(clip)
	clip.add_child(_meter(BAR_FILL, Vector2.ZERO, Vector2(BAR_WIDTH, 5)))

	row.tooltip_text = "%s\n%s" % [bp.display_name, _requirement_text(bp)]
	return row


# ORDER MATTERS. a TextureRect clamps size when you assign it and won't go
# below the texture until expand_mode allows it, so size-then-expand silently
# leaves it at the full 320x32. three of these ended up covering the rulebook
# button. don't inline this.
func _meter(texture: Texture2D, at: Vector2, box: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.custom_minimum_size = Vector2.ZERO
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.texture = texture
	rect.position = at
	rect.size = box
	return rect


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
