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
## Three rows plus two 8px separators have to fit the 702px the desk gives this
## strip. They did not, and the overflow ran underneath the rulebook button.
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
	var progress: Dictionary = bp.progress(Game.correct_by_category)
	var have: int = int(progress["need"]) if done else int(progress["have"])
	var need: int = int(progress["need"])

	var row := Control.new()
	row.custom_minimum_size = Vector2(ROW_WIDTH, 34)

	var bg := NinePatchRect.new()
	bg.texture = ROW_BG
	# 14, not the usual 24: a NinePatch whose top and bottom margins add up to
	# more than the box is tall draws its corners on top of each other, which is
	# what put a doubled edge under every row in this strip.
	for side: String in ["left", "top", "right", "bottom"]:
		bg.set("patch_margin_" + side, 14)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_child(bg)

	var name_label := Label.new()
	name_label.text = bp.display_name
	name_label.position = Vector2(10, 4)
	name_label.size = Vector2(ROW_WIDTH - 72, 26)
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
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

	# The bar is the meter PNG clipped to width, the same way the report's ocean
	# meter is drawn - no shape is ever drawn in code.
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


## A TextureRect refuses to shrink below its texture until expand_mode says it
## may, and it clamps `size` at the moment you assign it - so setting the size
## first and the expand mode afterwards silently leaves the rect at the PNG's
## full 320x32. Three of these sat on top of the rulebook button and cut its
## label in half. Order matters here; keep the assignment in this function.
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


func _requirement_text(bp: BlueprintData) -> String:
	var parts: Array[String] = []
	for category: int in bp.required:
		parts.append("%d %s" % [int(bp.required[category]), Strings.category_name(category)])
	return Strings.tf("blueprint_requires", {"v": ", ".join(parts)})


func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
