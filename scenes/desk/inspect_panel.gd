## The inspect panel: question, item viewport, tool rack, active-rule checklist
## and evidence log.
##
## Revision 1 §7 rebuilt this for legibility. The systems already worked; what
## was missing was any signal to the player about what game they were playing.
## Five things carry that now:
##
##   1. The active rules sit beside the item, so the rules are never a memory
##      test and the player never has to leave the item to check them.
##   2. Evidence chips light up when they satisfy an active rule, and the bin
##      that rule forces lights up with them - the player watches their own
##      reasoning assemble.
##   3. A question line frames the decision from surface info alone.
##   4. A tool that finds nothing says so, and says what it cost.
##   5. Hotspot rings are a separate overlay that can be switched off.
##
## The zoom and pan are purely tactile - no gameplay depends on zoom level. It
## uses a SubViewport rather than a scaled TextureRect so clipping and pan
## bounds come free.
extends Control

signal reveal_happened(field: String, hit: bool)
## The bin the revealed evidence currently points at, or -1 for none.
signal bin_hint_changed(category: int)

## The one place in the game a sprite is not shown at scale 1. Named here, in
## one file, and quoted in ASSETS.md so a designer knows an item is read at
## 160 x 1.8 = 288 px in this panel (rev 3 §1.5).
const BASE_SCALE := 1.8
const MIN_ZOOM := 1.0
const MAX_ZOOM := 3.0
const CHIP_SURFACE := preload("res://assets/ui/chip_surface.png")
const CHIP_REVEAL := preload("res://assets/ui/chip_reveal.png")
const CHIP_MATCH := preload("res://assets/ui/chip_match.png")
const TOOL_ROW_HEIGHT := 64
## Tools are authored at 96x96 and shown at 60x60 in the rack. Named here and
## quoted in ASSETS.md for the same reason BASE_SCALE is (rev 3 §1.5).
const TOOL_ICON_SCALE := 0.62

@onready var _view: SubViewport = $ViewportBox/ItemViewport
@onready var _item_root: Node2D = $ViewportBox/ItemViewport/ItemRoot
@onready var _item_sprite: Sprite2D = $ViewportBox/ItemViewport/ItemRoot/Sprite
@onready var _hotspot_sprite: Sprite2D = $ViewportBox/ItemViewport/ItemRoot/Hotspots
@onready var _surface: Control = $Surface
@onready var _question: Label = $Question
@onready var _zoom_hint: Label = $ZoomHint
@onready var _rack: VBoxContainer = $ToolRack
@onready var _feedback: Label = $Feedback
@onready var _rules_title: Label = $RulesTitle
@onready var _rules_list: VBoxContainer = $RulesList
@onready var _evidence_title: Label = $EvidenceTitle
@onready var _log: VBoxContainer = $EvidenceScroll/EvidenceLog

var entry: CarriedItem = null

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
	_feedback.text = ""
	_surface.gui_input.connect(_on_surface_input)
	Events.budget_changed.connect(func(_r: int, _m: int) -> void: _refresh_rack())
	Events.hotspots_visible_changed.connect(_set_hotspots_visible)
	_set_hotspots_visible(Game.show_hotspots)
	_build_rack()
	_rebuild_rules()


# ------------------------------------------------------------------ tool rack

func _build_rack() -> void:
	_clear(_rack)
	_tool_nodes.clear()
	for tool_data: ToolData in Game.tools:
		_rack.add_child(_make_tool_entry(tool_data))
	_refresh_rack()


func _make_tool_entry(tool_data: ToolData) -> Control:
	var row := Control.new()
	row.custom_minimum_size = Vector2(0, TOOL_ROW_HEIGHT)

	# The visible tool is an AnimatedSprite2D from the start (idle/using), so
	# animating it later is a matter of adding frames, not replacing the node.
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = tool_data.frames
	sprite.play(&"idle")
	sprite.scale = Vector2.ONE * TOOL_ICON_SCALE
	sprite.position = Vector2(30, 32)
	row.add_child(sprite)

	var name_label := Label.new()
	name_label.text = tool_data.display_name
	name_label.position = Vector2(66, 6)
	name_label.add_theme_font_size_override("font_size", 17)
	row.add_child(name_label)

	var cost_label := Label.new()
	cost_label.text = Strings.tf("tools_cost_label", {"n": Game.cost_of(&"tool")})
	cost_label.position = Vector2(66, 32)
	cost_label.add_theme_font_size_override("font_size", 13)
	cost_label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.85))
	row.add_child(cost_label)

	# Invisible hit area over the artwork. The visible tool is the PNG above;
	# this only carries the click and the focus ring.
	var button := Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(_on_tool_pressed.bind(tool_data.id))
	row.add_child(button)

	_tool_nodes[tool_data.id] = {"sprite": sprite, "cost": cost_label,
		"button": button, "label": name_label}
	return row


## A tool is greyed out either because today has no such tool, or because the
## shift budget cannot pay for it - and the tooltip says which.
func _refresh_rack() -> void:
	for tool_id: StringName in _tool_nodes:
		var parts: Dictionary = _tool_nodes[tool_id]
		var unlocked: bool = Game.tool_unlocked(tool_id)
		var affordable: bool = Game.can_afford(&"tool")
		var usable := unlocked and affordable
		var button: Button = parts["button"]
		button.disabled = not usable
		if not unlocked:
			button.tooltip_text = Strings.t("tools_locked")
		elif not affordable:
			button.tooltip_text = Strings.t("budget_too_low")
		else:
			button.tooltip_text = Strings.tf("tools_cost_label", {"n": Game.cost_of(&"tool")})
		# A locked tool is a different drawing, never a dimmed one - code must
		# not express state by tinting designer art (rev 3 §1.4). The labels
		# beside it are UI text and may fade.
		var sprite: AnimatedSprite2D = parts["sprite"]
		if not usable:
			sprite.play(&"locked")
		else:
			sprite.play(&"using" if _armed == tool_id else &"idle")
		parts["label"].modulate.a = 1.0 if unlocked else 0.35
		parts["cost"].modulate.a = 1.0 if usable else 0.35


func _on_tool_pressed(tool_id: StringName) -> void:
	_armed = &"" if _armed == tool_id else tool_id
	Events.tool_armed.emit(_armed)
	if _armed != &"":
		var tool_data := Game.get_tool(_armed)
		Events.toast_requested.emit(Strings.tf("tools_armed",
			{"tool": tool_data.display_name}))
		# The cursor is the tool's own PNG, so arming is unmistakable.
		Input.set_custom_mouse_cursor(tool_data.icon, Input.CURSOR_ARROW, Vector2(12, 12))
	else:
		Input.set_custom_mouse_cursor(null)
	_refresh_rack()


func disarm() -> void:
	_armed = &""
	Input.set_custom_mouse_cursor(null)
	_refresh_rack()


# --------------------------------------------------------------- item display

func show_entry(new_entry: CarriedItem) -> void:
	entry = new_entry
	_zoom = 1.0
	_pan = Vector2.ZERO
	_feedback.text = ""
	_item_sprite.texture = entry.data.texture if entry != null else null
	_hotspot_sprite.texture = entry.data.hotspot_overlay if entry != null else null
	_question.text = _question_for(entry)
	_apply_transform()
	_rebuild_log()
	_rebuild_rules()
	_refresh_rack()


func clear() -> void:
	entry = null
	_item_sprite.texture = null
	_hotspot_sprite.texture = null
	_question.text = Strings.t("inspect_pick_first")
	_feedback.text = ""
	_rebuild_log()
	_rebuild_rules()
	bin_hint_changed.emit(-1)


func _set_hotspots_visible(value: bool) -> void:
	if _hotspot_sprite != null:
		_hotspot_sprite.visible = value


## One sentence framing the decision from surface info alone. It tells the
## player what game they are playing: not "which bin" but "do I believe this?".
func _question_for(target: CarriedItem) -> String:
	if target == null:
		return Strings.t("inspect_pick_first")
	if target.data.visible_label != "":
		return Strings.tf("inspect_question_labeled",
			{"label": target.data.visible_label, "mat": target.data.visible_material})
	return Strings.tf("inspect_question", {"mat": target.data.visible_material})


## Never assumes how big an item PNG is: a designer may deliver 256 or 512 and
## the panel has to keep working (rev 3 §1.5).
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
						_use_tool_at(mb.position)
					else:
						_dragging = true
				else:
					_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		_pan += (event as InputEventMouseMotion).relative
		_apply_transform()


## Screen point inside the inspect surface -> normalized texture coordinates,
## which is the space hotspots are authored in. Zooming therefore never moves a
## hotspot relative to the artwork.
func _to_normalized(point: Vector2) -> Vector2:
	var span := _item_span() * BASE_SCALE * _zoom
	if span <= 0.0:
		return Vector2(-1.0, -1.0)
	var origin := Vector2(_view.size) * 0.5 + _pan
	return (point - origin) / span + Vector2(0.5, 0.5)


func _use_tool_at(point: Vector2) -> void:
	if entry == null:
		return
	var tool_id := _armed
	if not Game.tool_unlocked(tool_id):
		Events.toast_requested.emit(Strings.t("tools_locked"))
		return
	var field := _hotspot_field(_to_normalized(point), tool_id)
	# The coarse scanner (revision 2 §4) probes cheaply and reads properly only
	# on a second use, which is charged at the normal price. Working out which
	# of the two this click is costs nothing - paying for it always does.
	var second_reading: bool = Game.coarse_readings() and field != "" \
		and entry.is_probed(field)
	var cost: int = Game.base_cost(&"tool") if second_reading else Game.cost_of(&"tool")
	if not Game.spend_amount(cost):
		Events.toast_requested.emit(Strings.t("budget_too_low"))
		return
	Game.stats["tool_uses"] = int(Game.stats.get("tool_uses", 0)) + 1
	Events.sfx_requested.emit(&"tool_use")
	if Game.coarse_readings() and field != "" and not second_reading:
		# Found something, cannot say what. Cheap, and deliberately unfinished.
		entry.probe(field)
		Events.sfx_requested.emit(&"reveal_success")
		_set_feedback(Strings.tf("inspect_coarse", {"n": cost}), Color(0.86, 0.88, 0.6))
		reveal_happened.emit(field, false)
		_refresh_rack()
		return
	if field.is_empty():
		# Missed. The charge is gone anyway - that is the risk, and it must
		# never be prevented. But spending for nothing has to *read* as an
		# outcome; a dead click reads as a bug.
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
		_rebuild_log()
		_rebuild_rules()
	_refresh_rack()


func _set_feedback(text: String, color: Color) -> void:
	_feedback.text = text
	_feedback.add_theme_color_override("font_color", color)


func _hotspot_field(normalized: Vector2, tool_id: StringName) -> String:
	for spot: Dictionary in entry.data.hotspots:
		if StringName(spot["tool"]) != tool_id:
			continue
		if normalized.distance_to(spot["pos"]) <= float(spot["radius"]):
			return String(spot["reveals"])
	return ""


# ------------------------------------------------------- rules and evidence

func _active_rules() -> Array[RuleData]:
	var day := Game.current_day()
	return day.active_rules if day != null else [] as Array[RuleData]


## Which evidence the player has actually proved, and where it points.
## Returns {"lit": {chip_key: true}, "bin": int, "rules": {rule_id: true}}
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


## Today's rules, always visible beside the item. The ones the player has proved
## apply are picked out, so the list doubles as a record of their reasoning.
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
	# Surface info is free and always shown. The property line comes first
	# because, until a tool has been spent, it is the whole of what is known
	# about this item (revision 2 §3).
	_add_chip("surface_properties", Strings.tf("chip_properties",
		{"v": item.surface_label()}), false, lit)
	_add_chip("visible_material", Strings.tf("chip_material", {"v": item.visible_material}),
		false, lit)
	_add_chip("visible_label", Strings.tf("chip_label",
		{"v": item.visible_label if item.visible_label != "" else Strings.t("chip_no_label")}),
		false, lit)
	_add_chip("weight", Strings.tf("chip_weight", {"v": "%.1f" % item.weight}), false, lit)
	# Everything below cost part of the shift.
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
	# A chip that satisfies an active rule is the whole point of this panel, so
	# it gets its own colour rather than a subtler tint.
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


## queue_free() alone leaves the old children in the tree for the rest of the
## frame, so a list rebuilt twice in one frame would briefly show both sets.
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
