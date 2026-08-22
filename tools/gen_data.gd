## Bootstrap generator for every .tres in data/. Run once:
##   godot --headless --script tools/gen_data.gd
## Add -- --force to overwrite existing files.
##
## After bootstrap the .tres files are the source of truth - edit them in the
## Godot inspector, not here. Adding item #40 means adding one .tres, never
## touching code.
extends SceneTree

const SRC := "res://tools/content.json"

var force: bool = false


func _init() -> void:
	force = "--force" in OS.get_cmdline_user_args()
	var text := FileAccess.get_file_as_string(SRC)
	if text.is_empty():
		push_error("Missing %s - run: python3 tools/content.py" % SRC)
		quit(1)
		return
	var data: Dictionary = JSON.parse_string(text)
	var items := _gen_items(data["items"])
	var rules := _gen_rules(data["rules"])
	_gen_tools(data["tools"])
	_gen_days(data["days"], items, rules)
	_gen_theme()
	quit()


func _save(res: Resource, path: String) -> void:
	if FileAccess.file_exists(path) and not force:
		print("  skip (exists): ", path)
		return
	var err := ResourceSaver.save(res, path)
	if err != OK:
		push_error("save failed %s (%d)" % [path, err])
	else:
		print("  wrote ", path)


func _load_if(path: String) -> Resource:
	return load(path) if ResourceLoader.exists(path) else null


func _gen_items(raw: Array) -> Dictionary:
	var out := {}
	for d: Dictionary in raw:
		var id_str: String = d["id"]
		var item := ItemData.new()
		item.id = StringName(id_str)
		item.display_name = d["display_name"]
		item.texture = _load_if("res://assets/items/item_%s.png" % id_str)
		item.frames = _load_if("res://data/frames/item_%s_frames.tres" % id_str)
		item.weight = float(d["weight"])
		item.visible_material = d["visible_material"]
		item.visible_label = d["visible_label"]
		item.has_residue = d["has_residue"]
		item.residue_type = d["residue_type"]
		item.true_material = d["true_material"]
		item.is_multilayer = d["is_multilayer"]
		item.tag_text = d["tag_text"]
		item.correct_category = int(d["correct_category"])
		item.source_batch = StringName(d["source_batch"])
		var spots: Array[Dictionary] = []
		for h: Dictionary in d["hotspots"]:
			var pos: Array = h["pos"]
			spots.append({
				"pos": Vector2(float(pos[0]), float(pos[1])),
				"radius": float(h["radius"]),
				"tool": String(h["tool"]),
				"reveals": String(h["reveals"]),
			})
			# revealed_by_* is derived from the hotspots so the two can never
			# disagree about which tool can learn something here.
			match String(h["tool"]):
				"rinse": item.revealed_by_rinse = true
				"swab": item.revealed_by_swab = true
				"magnifier": item.revealed_by_magnifier = true
				"cutter": item.revealed_by_cutter = true
		item.hotspots = spots
		var path := "res://data/items/%s.tres" % id_str
		_save(item, path)
		out[id_str] = path
	return out


func _gen_rules(raw: Array) -> Dictionary:
	var out := {}
	for d: Dictionary in raw:
		var rule := RuleData.new()
		rule.id = StringName(d["id"])
		rule.text = d["text"]
		rule.applies_when = d["applies_when"]
		rule.forces_category = int(d["forces_category"])
		rule.priority = int(d["priority"])
		var path := "res://data/rules/%s.tres" % d["id"]
		_save(rule, path)
		out[d["id"]] = path
	return out


func _gen_tools(raw: Array) -> void:
	for d: Dictionary in raw:
		var id_str: String = d["id"]
		var t := ToolData.new()
		t.id = StringName(id_str)
		t.display_name = d["display_name"]
		t.reveals_field = d["reveals_field"]
		t.default_charges = int(d["default_charges"])
		t.description = d["description"]
		t.icon = _load_if("res://assets/tools/tool_%s.png" % id_str)
		t.frames = _load_if("res://data/frames/tool_%s_frames.tres" % id_str)
		_save(t, "res://data/tools/%s.tres" % id_str)


func _gen_days(raw: Array, items: Dictionary, rules: Dictionary) -> void:
	for d: Dictionary in raw:
		var day := DayData.new()
		day.day_number = int(d["day_number"])
		day.quota = int(d["quota"])
		day.max_grabs = int(d["max_grabs"])
		day.tools_enabled = d["tools_enabled"]
		day.intro_text = d["intro_text"]
		day.modifier = d["modifier"]
		var charges := {}
		for k: String in d["tool_charges"]:
			charges[StringName(k)] = int(d["tool_charges"][k])
		day.tool_charges = charges
		var rule_list: Array[RuleData] = []
		for rid: String in d["active_rules"]:
			rule_list.append(load(rules[rid]))
		day.active_rules = rule_list
		var pool: Array[ItemData] = []
		for iid: String in d["item_pool"]:
			pool.append(load(items[iid]))
		day.item_pool = pool
		_save(day, "res://data/days/day_%02d.tres" % day.day_number)


## One Theme so every UI scene gets the same PNG-backed buttons and panels.
## Buttons use StyleBoxTexture over assets/ui/*.png - still a PNG on disk that a
## designer can replace, and Button gives us text and focus handling for free.
func _gen_theme() -> void:
	var path := "res://assets/ui/ui_theme.tres"
	if FileAccess.file_exists(path) and not force:
		print("  skip (exists): ", path)
		return
	var theme := Theme.new()
	theme.default_font_size = 18
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		var sb := StyleBoxTexture.new()
		sb.texture = load("res://assets/ui/button_%s.png" % state)
		for side: String in ["left", "top", "right", "bottom"]:
			sb.set("texture_margin_" + side, 20.0)
			sb.set("content_margin_" + side, 14.0 if side in ["left", "right"] else 10.0)
		theme.set_stylebox(state, "Button", sb)
	theme.set_stylebox("focus", "Button", theme.get_stylebox("hover", "Button"))
	theme.set_color("font_color", "Button", Color(0.88, 0.94, 0.98))
	theme.set_color("font_hover_color", "Button", Color(1, 1, 1))
	theme.set_color("font_disabled_color", "Button", Color(0.45, 0.5, 0.55))
	theme.set_font_size("font_size", "Button", 20)
	for type_name: String in ["Panel", "PanelContainer"]:
		var sb := StyleBoxTexture.new()
		sb.texture = load("res://assets/ui/panel_main.png")
		for side: String in ["left", "top", "right", "bottom"]:
			sb.set("texture_margin_" + side, 24.0)
			sb.set("content_margin_" + side, 16.0)
		theme.set_stylebox("panel", type_name, sb)
	theme.set_color("font_color", "Label", Color(0.87, 0.92, 0.96))
	theme.set_color("font_color", "RichTextLabel", Color(0.87, 0.92, 0.96))
	_save(theme, path)
