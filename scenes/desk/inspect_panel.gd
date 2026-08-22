## The inspect panel: item viewport, tool rack, evidence log.
##
## The zoom and pan are purely tactile - no gameplay depends on zoom level. It
## exists so examining feels like examining. It uses a SubViewport rather than a
## scaled TextureRect so clipping and pan bounds come free.
##
## Reveals are hotspot-based. Using a tool on empty area spends the charge and
## reveals nothing, and that is never prevented: the risk is the whole design.
extends Control

signal reveal_happened(field: String, hit: bool)

const BASE_SCALE := 2.0
const MIN_ZOOM := 1.0
const MAX_ZOOM := 3.0
const CHIP_SURFACE := preload("res://assets/ui/chip_surface.png")
const CHIP_REVEAL := preload("res://assets/ui/chip_reveal.png")
const PIP_FULL := preload("res://assets/ui/pip_full.png")
const PIP_EMPTY := preload("res://assets/ui/pip_empty.png")

@onready var _view: SubViewport = $ViewportBox/ItemViewport
@onready var _item_root: Node2D = $ViewportBox/ItemViewport/ItemRoot
@onready var _item_sprite: Sprite2D = $ViewportBox/ItemViewport/ItemRoot/Sprite
@onready var _surface: Control = $Surface
@onready var _zoom_hint: Label = $ZoomHint
@onready var _rack: VBoxContainer = $ToolRack
@onready var _evidence_title: Label = $EvidenceTitle
@onready var _log: VBoxContainer = $EvidenceScroll/EvidenceLog

var entry: CarriedItem = null

var _zoom: float = 1.0
var _pan: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _armed: StringName = &""
var _tool_nodes: Dictionary = {} ## tool id -> {"sprite":…, "pips":…, "button":…}


func _ready() -> void:
	_zoom_hint.text = Strings.t("inspect_zoom_hint")
	_evidence_title.text = Strings.t("evidence_title")
	_surface.gui_input.connect(_on_surface_input)
	_build_rack()


# ------------------------------------------------------------------ tool rack

func _build_rack() -> void:
	_clear(_rack)
	_tool_nodes.clear()
	for tool_data: ToolData in Game.tools:
		_rack.add_child(_make_tool_entry(tool_data))
	_refresh_rack()


func _make_tool_entry(tool_data: ToolData) -> Control:
	var row := Control.new()
	row.custom_minimum_size = Vector2(0, 86)

	# The visible tool is an AnimatedSprite2D from the start (idle/using), so
	# animating it later is a matter of adding frames, not replacing the node.
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = tool_data.frames
	sprite.play(&"idle")
	sprite.position = Vector2(44, 44)
	row.add_child(sprite)

	var name_label := Label.new()
	name_label.text = tool_data.display_name
	name_label.position = Vector2(90, 12)
	name_label.add_theme_font_size_override("font_size", 19)
	row.add_child(name_label)

	var pips := HBoxContainer.new()
	pips.position = Vector2(90, 46)
	pips.add_theme_constant_override("separation", 5)
	row.add_child(pips)

	# Invisible hit area over the artwork. The visible tool is the PNG above;
	# this only carries the click and the focus ring.
	var button := Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(_on_tool_pressed.bind(tool_data.id))
	row.add_child(button)

	_tool_nodes[tool_data.id] = {"sprite": sprite, "pips": pips, "button": button,
		"label": name_label}
	return row


func _refresh_rack() -> void:
	for tool_id: StringName in _tool_nodes:
		var parts: Dictionary = _tool_nodes[tool_id]
		var available: bool = Game.tool_available(tool_id)
		var charges: int = Game.charges_for(tool_id)
		var tool_data := Game.get_tool(tool_id)
		var pips: HBoxContainer = parts["pips"]
		_clear(pips)
		var total: int = tool_data.default_charges if tool_data != null else 0
		if available:
			var day := Game.current_day()
			total = int(day.tool_charges.get(tool_id, total))
		for i in total:
			var pip := TextureRect.new()
			pip.texture = PIP_FULL if i < charges else PIP_EMPTY
			pips.add_child(pip)
		parts["button"].disabled = not available or charges <= 0
		var sprite: AnimatedSprite2D = parts["sprite"]
		sprite.play(&"using" if _armed == tool_id else &"idle")
		sprite.modulate.a = 1.0 if available and charges > 0 else 0.4
		parts["label"].modulate.a = 1.0 if available else 0.4


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
	_item_sprite.texture = entry.data.texture if entry != null else null
	_apply_transform()
	_rebuild_log()
	_refresh_rack()


func clear() -> void:
	entry = null
	_item_sprite.texture = null
	_rebuild_log()


func _apply_transform() -> void:
	var view_size := Vector2(_view.size)
	var span := 160.0 * BASE_SCALE * _zoom
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
## which is the space hotspots are authored in.
func _to_normalized(point: Vector2) -> Vector2:
	var span := 160.0 * BASE_SCALE * _zoom
	var origin := Vector2(_view.size) * 0.5 + _pan
	return (point - origin) / span + Vector2(0.5, 0.5)


func _use_tool_at(point: Vector2) -> void:
	if entry == null:
		return
	var tool_id := _armed
	if not Game.tool_available(tool_id):
		Events.toast_requested.emit(Strings.t("tools_locked"))
		return
	var tool_data := Game.get_tool(tool_id)
	if not Game.spend_charge(tool_id):
		Events.toast_requested.emit(Strings.tf("tools_no_charge",
			{"tool": tool_data.display_name}))
		return
	Events.sfx_requested.emit(&"tool_use")
	var normalized := _to_normalized(point)
	var field := _hotspot_field(normalized, tool_id)
	if field.is_empty():
		# Missed. The charge is gone anyway - that is the risk, and it must
		# never be prevented.
		Events.sfx_requested.emit(&"reveal_nothing")
		Events.toast_requested.emit(Strings.t("reveal_nothing"))
		reveal_happened.emit("", false)
	else:
		entry.reveal(field)
		Events.sfx_requested.emit(&"reveal_success")
		Events.toast_requested.emit(Strings.t("reveal_success"))
		Events.tool_used.emit(tool_id, field)
		reveal_happened.emit(field, true)
		_rebuild_log()
	_refresh_rack()


func _hotspot_field(normalized: Vector2, tool_id: StringName) -> String:
	for spot: Dictionary in entry.data.hotspots:
		if StringName(spot["tool"]) != tool_id:
			continue
		if normalized.distance_to(spot["pos"]) <= float(spot["radius"]):
			return String(spot["reveals"])
	return ""


# --------------------------------------------------------------- evidence log

func _rebuild_log() -> void:
	_clear(_log)
	if entry == null:
		return
	var item := entry.data
	# Surface info is free and always shown.
	_add_chip(Strings.tf("chip_material", {"v": item.visible_material}), false)
	_add_chip(Strings.tf("chip_label", {"v": item.visible_label if item.visible_label != ""
		else Strings.t("chip_no_label")}), false)
	_add_chip(Strings.tf("chip_weight", {"v": "%.1f" % item.weight}), false)
	# Everything below cost a tool charge.
	if entry.is_revealed("has_residue"):
		_add_chip(Strings.tf("chip_residue", {"v": item.get_field_text("has_residue")}), true)
	if entry.is_revealed("residue_type"):
		_add_chip(Strings.tf("chip_residue_type", {"v": item.get_field_text("residue_type")}), true)
	if entry.is_revealed("true_material"):
		_add_chip(Strings.tf("chip_true_material", {"v": item.get_field_text("true_material")}), true)
	if entry.is_revealed("tag_text"):
		_add_chip(Strings.tf("chip_tag", {"v": item.get_field_text("tag_text")}), true)


func _add_chip(text: String, revealed: bool) -> void:
	var chip := NinePatchRect.new()
	chip.texture = CHIP_REVEAL if revealed else CHIP_SURFACE
	for side: String in ["left", "top", "right", "bottom"]:
		chip.set("patch_margin_" + side, 12)
	chip.custom_minimum_size = Vector2(0, 38)
	var label := Label.new()
	label.text = text
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 12
	label.offset_right = -10
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 16)
	chip.add_child(label)
	_log.add_child(chip)


## queue_free() alone leaves the old children in the tree for the rest of the
## frame, so a list rebuilt twice in one frame would briefly show both sets.
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
