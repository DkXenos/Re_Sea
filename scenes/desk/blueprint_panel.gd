## The compact "what am I working toward" strip on the desk (revision 2 §2).
##
## One row per blueprint: name, a 7 / 12 counter and a bar. Nothing here is
## clickable and nothing here is a crafting system - the player never combines
## anything, they just sort correctly and watch this fill.
##
## The counts are run-wide and only move at the day report. That is deliberate:
## the desk never tells the player whether a sort was right, and a counter that
## ticked up the moment they hit the correct bin would give the answer away.
extends Control

const ROW_BG := preload("res://assets/ui/panel_slot.png")
const BAR_BG := preload("res://assets/ui/meter_bg.png")
const BAR_FILL := preload("res://assets/ui/meter_fill.png")
const ROW_WIDTH := 244.0
const BAR_WIDTH := 96.0

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
	var progress: Dictionary = bp.progress(Game.correct_by_category)
	var have: int = int(progress["need"]) if done else int(progress["have"])
	var need: int = int(progress["need"])

	var row := Control.new()
	row.custom_minimum_size = Vector2(ROW_WIDTH, 34)

	var bg := NinePatchRect.new()
	bg.texture = ROW_BG
	for side: String in ["left", "top", "right", "bottom"]:
		bg.set("patch_margin_" + side, 24)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_child(bg)

	var name_label := Label.new()
	name_label.text = bp.display_name
	name_label.position = Vector2(10, 4)
	name_label.size = Vector2(ROW_WIDTH - 78, 26)
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(name_label)

	var count := Label.new()
	count.text = Strings.t("blueprint_done") if done else "%d / %d" % [have, need]
	count.position = Vector2(ROW_WIDTH - 74, 4)
	count.size = Vector2(64, 26)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count.add_theme_font_size_override("font_size", 13)
	count.add_theme_color_override("font_color",
		Color(0.6, 0.94, 0.72) if done else Color(0.86, 0.9, 0.94))
	row.add_child(count)

	# The bar is the meter PNG clipped to width, the same way the report's ocean
	# meter is drawn - no shape is ever drawn in code.
	var bar_bg := TextureRect.new()
	bar_bg.texture = BAR_BG
	bar_bg.position = Vector2(10, 26)
	bar_bg.size = Vector2(BAR_WIDTH, 5)
	bar_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bar_bg.stretch_mode = TextureRect.STRETCH_SCALE
	row.add_child(bar_bg)

	var clip := Control.new()
	clip.clip_contents = true
	clip.position = Vector2(10, 26)
	clip.size = Vector2(BAR_WIDTH * float(have) / maxf(1.0, float(need)), 5)
	row.add_child(clip)
	var fill := TextureRect.new()
	fill.texture = BAR_FILL
	fill.size = Vector2(BAR_WIDTH, 5)
	fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fill.stretch_mode = TextureRect.STRETCH_SCALE
	clip.add_child(fill)

	row.tooltip_text = "%s\n%s" % [bp.display_name, _requirement_text(bp)]
	return row


func _requirement_text(bp: BlueprintData) -> String:
	var parts: Array[String] = []
	for category: int in bp.required:
		parts.append("%d %s" % [int(bp.required[category]), Strings.category_name(category)])
	return Strings.tf("blueprint_requires", {"v": ", ".join(parts)})


func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
