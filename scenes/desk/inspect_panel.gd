# question line, item viewport, tool rack, rule checklist, evidence log.
# zoom/pan is tactile only, nothing depends on the zoom level. SubViewport
# instead of a scaled TextureRect so clipping and pan bounds come free.
extends Control

signal reveal_happened(field: String, hit: bool)
# the inventory list has to rebuild around the contents that just appeared
signal crate_opened()
# bin the revealed evidence points at, -1 for none
signal bin_hint_changed(category: int)

# 160 * 1.5 = 240px, inside the 260px viewport the desk art leaves for it.
# also written down in ASSETS.md, keep them in sync.
const BASE_SCALE := 1.5
const MIN_ZOOM := 1.0
const MAX_ZOOM := 3.0  # 4 looked awful on the 160px placeholders
const CHIP_SURFACE := preload("res://assets/ui/chip_surface.png")
const CHIP_REVEAL := preload("res://assets/ui/chip_reveal.png")
const CHIP_MATCH := preload("res://assets/ui/chip_match.png")
const TOOL_ROW_HEIGHT := 70
# four rows have to fit the rack frame, so the delivered art comes down a notch
const TOOL_ICON_SCALE := 0.85
# the rack has one drawing per tool and no locked/using variants, so "armed" is
# a separate plate slid in behind the row rather than a second drawing
const TOOL_ROW_SELECTED := preload("res://assets/ui/tool_row_selected.png")

@onready var _view: SubViewport = $ViewportBox/ItemViewport
@onready var _item_root: Node2D = $ViewportBox/ItemViewport/ItemRoot
@onready var _item_sprite: Sprite2D = $ViewportBox/ItemViewport/ItemRoot/Sprite
@onready var _surface: Control = $Surface
@onready var _name: Label = $NameLabel
@onready var _question: Label = $Question
@onready var _zoom_hint: Label = $ZoomHint
@onready var _rack: VBoxContainer = $ToolRack
@onready var _feedback: Label = $Feedback
@onready var _rules_title: Label = $RulesTitle
@onready var _rules_list: VBoxContainer = $RulesList
@onready var _evidence_title: Label = $EvidenceTitle
@onready var _log: VBoxContainer = $EvidenceScroll/EvidenceLog

var entry: CarriedItem = null

# FIXME the evidence log doesn't scroll to the bottom when a new chip lands,
# you have to drag it. only noticeable on day 4-5 when there's 4+ chips.
var _zoom: float = 1.0
var _pan: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _armed: StringName = &""
var _tool_nodes: Dictionary = {}


func _ready() -> void:
	_zoom_hint.text = Strings.t("inspect_zoom_hint")
	_evidence_title.text = Strings.t("evidence_title")
	_rules_title.text = Strings.t("inspect_rules_title")
	_question.text = Strings.t("inspect_pick_first")
	_name.text = ""
	_feedback.text = ""
	_surface.gui_input.connect(_on_surface_input)
	Events.budget_changed.connect(func(_r: int, _m: int) -> void: _refresh_rack())
	_build_rack()
	_rebuild_rules()


# tool rack

func _build_rack() -> void:
	_clear(_rack)
	_tool_nodes.clear()
	for tool_data: ToolData in Game.tools:
		_rack.add_child(_make_tool_entry(tool_data))
	_refresh_rack()


func _make_tool_entry(tool_data: ToolData) -> Control:
	var row := Control.new()
	row.custom_minimum_size = Vector2(0, TOOL_ROW_HEIGHT)

	# behind everything, shown only while this tool is the armed one
	var selected := TextureRect.new()
	selected.texture = TOOL_ROW_SELECTED
	selected.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	selected.stretch_mode = TextureRect.STRETCH_SCALE
	selected.set_anchors_preset(Control.PRESET_FULL_RECT)
	selected.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selected.visible = false
	row.add_child(selected)

	# AnimatedSprite2D from the start so adding frames later doesn't mean
	# swapping the node out
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = tool_data.frames
	sprite.play(&"idle")
	sprite.scale = Vector2.ONE * TOOL_ICON_SCALE
	sprite.position = Vector2(40, 35)
	row.add_child(sprite)

	var name_label := Label.new()
	name_label.text = tool_data.display_name
	name_label.position = Vector2(78, 10)
	name_label.add_theme_font_size_override("font_size", 15)
	row.add_child(name_label)

	var cost_label := Label.new()
	cost_label.text = Strings.t("tools_cost_free") if tool_data.opens_containers \
		else Strings.tf("tools_cost_label", {"n": Game.cost_of(&"tool")})
	cost_label.position = Vector2(78, 38)
	cost_label.add_theme_font_size_override("font_size", 13)
	cost_label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.85))
	row.add_child(cost_label)

	# invisible hit area, just carries the click and the focus ring
	var button := Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(_on_tool_pressed.bind(tool_data.id))
	row.add_child(button)

	_tool_nodes[tool_data.id] = {"sprite": sprite, "cost": cost_label,
		"button": button, "label": name_label, "selected": selected}
	return row


# greyed out = not available today, or can't afford it. tooltip says which.
func _refresh_rack() -> void:
	for tool_id: StringName in _tool_nodes:
		var parts: Dictionary = _tool_nodes[tool_id]
		var unlocked: bool = Game.tool_unlocked(tool_id)
		# an opener spends nothing, so an empty budget never locks it out
		var free: bool = Game.get_tool(tool_id).opens_containers
		var affordable: bool = free or Game.can_afford(&"tool")
		var usable := unlocked and affordable
		var button: Button = parts["button"]
		button.disabled = not usable
		if not unlocked:
			button.tooltip_text = Strings.t("tools_locked")
		elif not affordable:
			button.tooltip_text = Strings.t("budget_too_low")
		elif free:
			button.tooltip_text = Strings.t("tools_cost_free")
		else:
			button.tooltip_text = Strings.tf("tools_cost_label", {"n": Game.cost_of(&"tool")})
		# one drawing per tool, so the art never changes. what changes is the
		# plate behind it, and the UI text beside it - which is ours to fade.
		parts["selected"].visible = _armed == tool_id and usable
		parts["label"].modulate.a = 1.0 if unlocked else 0.35
		parts["cost"].modulate.a = 1.0 if usable else 0.35
		# a greyed row with no reason on it reads as broken art
		var cost: Label = parts["cost"]
		if not unlocked:
			cost.text = Strings.t("tools_not_today")
		elif free:
			cost.text = Strings.t("tools_cost_free")
		else:
			cost.text = Strings.tf("tools_cost_label", {"n": Game.cost_of(&"tool")})


func _on_tool_pressed(tool_id: StringName) -> void:
	_armed = &"" if _armed == tool_id else tool_id
	Events.tool_armed.emit(_armed)
	if _armed != &"":
		var tool_data := Game.get_tool(_armed)
		Events.toast_requested.emit(Strings.tf("tools_armed",
			{"tool": tool_data.display_name}))
		# cursor becomes the tool's own png
		Input.set_custom_mouse_cursor(tool_data.icon, Input.CURSOR_ARROW, Vector2(12, 12))
	else:
		Input.set_custom_mouse_cursor(null)
	_refresh_rack()


func disarm() -> void:
	_armed = &""
	Input.set_custom_mouse_cursor(null)
	_refresh_rack()


# item display

func show_entry(new_entry: CarriedItem) -> void:
	entry = new_entry
	_zoom = 1.0
	_pan = Vector2.ZERO
	_feedback.text = ""
	_item_sprite.texture = entry.display_texture() if entry != null else null
	_question.text = _question_for(entry)
	_set_identity(entry)
	_apply_transform()
	_rebuild_log()
	_rebuild_rules()
	_refresh_rack()


func clear() -> void:
	entry = null
	_item_sprite.texture = null
	_question.text = Strings.t("inspect_pick_first")
	_name.text = ""
	_feedback.text = ""
	_rebuild_log()
	_rebuild_rules()
	bin_hint_changed.emit(-1)


func _set_identity(target: CarriedItem) -> void:
	_name.text = "" if target == null else target.label()


# the question isn't "which bin", it's "do i believe this"
func _question_for(target: CarriedItem) -> String:
	if target == null:
		return Strings.t("inspect_pick_first")
	if target.is_container() and not target.opened:
		return Strings.t("box_question")
	if target.data.visible_label != "":
		return Strings.tf("inspect_question_labeled",
			{"label": target.data.visible_label, "mat": target.data.visible_material})
	return Strings.tf("inspect_question", {"mat": target.data.visible_material})


# don't assume the png size, designers might hand over 256 or 512
func _item_span() -> float:
	if _item_sprite.texture == null:
		return 0.0
	return float(_item_sprite.texture.get_width())


func _apply_transform() -> void:
	var view_size := Vector2(_view.size)
	var span := _item_span() * BASE_SCALE * _zoom
	var slack := maxf(0.0, (span - view_size.x) * 0.5)
	_pan = _pan.clamp(Vector2(-slack, -slack), Vector2(slack, slack))
	_item_root.position = view_size * 0.5 + _pan
	_item_root.scale = Vector2.ONE * (BASE_SCALE * _zoom)


func _on_surface_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		match mb.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if mb.pressed:
					_zoom = clampf(_zoom + 0.25, MIN_ZOOM, MAX_ZOOM)
					_apply_transform()
			MOUSE_BUTTON_WHEEL_DOWN:
				if mb.pressed:
					_zoom = clampf(_zoom - 0.25, MIN_ZOOM, MAX_ZOOM)
					_apply_transform()
			MOUSE_BUTTON_LEFT:
				if mb.pressed:
					if _armed != &"":
						_use_tool()
					else:
						_dragging = true
				else:
					_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		_pan += (event as InputEventMouseMotion).relative
		_apply_transform()


func _use_tool() -> void:
	if entry == null:
		return
	var tool_id := _armed
	if not Game.tool_unlocked(tool_id):
		Events.toast_requested.emit(Strings.t("tools_locked"))
		return
	var tool_data := Game.get_tool(tool_id)
	var sealed_crate: bool = entry.is_container() and not entry.opened
	# neither of these charges anything - refusing to do the job is not a use
	if tool_data.opens_containers:
		if sealed_crate:
			_open_crate()
		else:
			Events.toast_requested.emit(Strings.tf("tool_only_opens",
				{"tool": tool_data.display_name}))
		return
	if sealed_crate:
		Events.toast_requested.emit(Strings.tf("tool_wrong_for_box",
			{"tool": tool_data.display_name}))
		return
	var field := _reveal_for_tool(tool_id)
	# coarse scanner probes cheap and needs a 2nd use at full price to read
	# properly. working out which click this is costs nothing.
	var second_reading: bool = Game.coarse_readings() and field != "" \
		and entry.is_probed(field)
	var cost: int = Game.base_cost(&"tool") if second_reading else Game.cost_of(&"tool")
	if not Game.spend_amount(cost):
		Events.toast_requested.emit(Strings.t("budget_too_low"))
		return
	Game.stats["tool_uses"] = int(Game.stats.get("tool_uses", 0)) + 1
	Events.sfx_requested.emit(&"tool_use")
	if Game.coarse_readings() and field != "" and not second_reading:
		# found something, can't say what
		entry.probe(field)
		Events.sfx_requested.emit(&"reveal_success")
		_set_feedback(Strings.tf("inspect_coarse", {"n": cost}), Color(0.86, 0.88, 0.6))
		reveal_happened.emit(field, false)
		_refresh_rack()
		return
	if field.is_empty():
		# nothing here for this tool. the charge is gone anyway, that's the
		# risk in picking one - but say so, a dead click reads as a bug.
		Events.sfx_requested.emit(&"reveal_nothing")
		_set_feedback(Strings.tf("inspect_nothing", {"n": cost}), Color(0.95, 0.72, 0.55))
		Events.toast_requested.emit(Strings.t("reveal_nothing"))
		reveal_happened.emit("", false)
	else:
		entry.reveal(field)
		Events.sfx_requested.emit(&"reveal_success")
		_set_feedback(Strings.tf("inspect_found",
			{"v": entry.data.get_field_text(field), "n": cost}), Color(0.6, 0.92, 0.72))
		Events.tool_used.emit(tool_id, field)
		reveal_happened.emit(field, true)
		_set_identity(entry)
		_rebuild_log()
		_rebuild_rules()
	_refresh_rack()


# opening is free, so the whole cost of a crate is having brought the cutter.
# the crate itself stays in the list - it is rubbish too.
func _open_crate() -> void:
	var contents := Game.open_container(entry)
	Events.sfx_requested.emit(&"bin_accept")
	if not contents.is_empty():
		Events.toast_requested.emit(
			Strings.tf("box_opened_toast", {"n": contents.size()}))
	crate_opened.emit()
	_question.text = _question_for(entry)
	_item_sprite.texture = entry.display_texture()
	_refresh_rack()


func _set_feedback(text: String, color: Color) -> void:
	_feedback.text = text
	_feedback.add_theme_color_override("font_color", color)


# The whole item is the target. There is no aiming any more: the question a
# tool answers is "does this thing have anything you can find", not "can you
# click a 22px circle", and hunting for the circle was never the interesting
# part of the decision.
func _reveal_for_tool(tool_id: StringName) -> String:
	for spot: Dictionary in entry.data.hotspots:
		if StringName(spot["tool"]) == tool_id:
			return String(spot["reveals"])
	return ""


# rules + evidence

func _active_rules() -> Array[RuleData]:
	var day := Game.current_day()
	return day.active_rules if day != null else [] as Array[RuleData]


# {"lit": {chip_key: true}, "bin": int, "rules": {rule_id: true}}
func _evidence_state() -> Dictionary:
	var lit := {}
	var fired := {}
	var bin := -1
	if entry == null:
		return {"lit": lit, "bin": bin, "rules": fired}
	for rule: RuleData in RuleChecker.supported_rules(entry, _active_rules()):
		fired[rule.id] = true
		bin = rule.forces_category  # sorted by priority, so the last one wins
		for key: String in rule.applies_when:
			if key in RuleChecker.SURFACE_KEYS:
				lit[key] = true
			elif RuleChecker.RULE_KEY_TO_REVEAL.has(key):
				lit[RuleChecker.RULE_KEY_TO_REVEAL[key]] = true
	return {"lit": lit, "bin": bin, "rules": fired}


# always visible beside the item, never a memory test
func _rebuild_rules() -> void:
	_clear(_rules_list)
	var state := _evidence_state()
	var fired: Dictionary = state["rules"]
	for rule: RuleData in _active_rules():
		var label := Label.new()
		var active: bool = fired.has(rule.id)
		label.text = ("+  " if active else "-  ") + rule.label()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color",
			Color(0.55, 0.95, 0.72) if active else Color(0.62, 0.68, 0.76))
		_rules_list.add_child(label)
	bin_hint_changed.emit(int(state["bin"]))


func _rebuild_log() -> void:
	_clear(_log)
	if entry == null:
		return
	var lit: Dictionary = _evidence_state()["lit"]
	var item := entry.data
	# free stuff. properties aren't repeated, they're already the heading.
	_add_chip("visible_material", Strings.tf("chip_material", {"v": item.visible_material}),
		false, lit)
	_add_chip("visible_label", Strings.tf("chip_label",
		{"v": item.visible_label if item.visible_label != "" else Strings.t("chip_no_label")}),
		false, lit)
	_add_chip("weight", Strings.tf("chip_weight", {"v": "%.1f" % item.weight}), false, lit)
	# everything below cost budget
	if entry.is_revealed("has_residue"):
		_add_chip("has_residue", Strings.tf("chip_residue",
			{"v": item.get_field_text("has_residue")}), true, lit)
	if entry.is_revealed("residue_type"):
		_add_chip("residue_type", Strings.tf("chip_residue_type",
			{"v": item.get_field_text("residue_type")}), true, lit)
	if entry.is_revealed("true_material"):
		_add_chip("true_material", Strings.tf("chip_true_material",
			{"v": item.get_field_text("true_material")}), true, lit)
	if entry.is_revealed("tag_text"):
		_add_chip("tag_text", Strings.tf("chip_tag", {"v": item.get_field_text("tag_text")}),
			true, lit)


func _add_chip(key: String, text: String, revealed: bool, lit: Dictionary) -> void:
	var chip := NinePatchRect.new()
	# chip that satisfies a rule gets its own colour, not a subtle tint
	if lit.has(key):
		chip.texture = CHIP_MATCH
	else:
		chip.texture = CHIP_REVEAL if revealed else CHIP_SURFACE
	for side: String in ["left", "top", "right", "bottom"]:
		chip.set("patch_margin_" + side, 12)
	chip.custom_minimum_size = Vector2(0, 32)
	var label := Label.new()
	label.text = text
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 12
	label.offset_right = -10
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 14)
	chip.add_child(label)
	_log.add_child(chip)


# queue_free alone leaves them in the tree for the rest of the frame
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
