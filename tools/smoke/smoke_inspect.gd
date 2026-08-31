# the inspect panel legibility stuff, checked instead of eyeballed
#   godot --headless --script tools/smoke/smoke_inspect.gd
extends SceneTree

const CHIP_MATCH := preload("res://assets/ui/chip_match.png")


func _init() -> void:
	_run()


## Normalized texture coordinate -> point inside the inspect surface, mirroring
## inspect_panel._to_normalized().
func _point_for(n: Vector2) -> Vector2:
	var span := 160.0 * 1.8
	return Vector2(160, 160) + (n - Vector2(0.5, 0.5)) * span


func _find(entries: Array, id: StringName):
	for e in entries:
		if e.data.id == id:
			return e
	return null


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	var events: Node = root.get_node("/root/Events")
	game.start_run(31415)
	for i in 4:
		game.advance_day() # day 5: every rule and every tool
	var day = game.current_day()
	for item in day.item_pool:
		game.add_to_inventory(item)

	var desk: Node = load("res://scenes/desk/desk_phase.tscn").instantiate()
	root.add_child(desk)
	await process_frame
	var inspect: Control = desk.get_node("UiLayer/Root/InspectPanel")
	var bins: Control = desk.get_node("UiLayer/Root/BinRow")

	# --- 7.1 the active rules are beside the item, one line each ---
	var rules_shown: int = inspect.get_node("RulesList").get_child_count()
	assert(rules_shown == day.active_rules.size(),
		"the inspect checklist does not list every active rule")
	print("7.1 rules checklist: %d of %d active rules listed beside the item"
		% [rules_shown, day.active_rules.size()])

	# --- 7.5 hotspot overlay is a separate, switchable sprite ---
	var cup = _find(game.inventory, &"tisu_b3")
	inspect.show_entry(cup)
	await process_frame
	var overlay: Sprite2D = inspect.get_node(
		"ViewportBox/ItemViewport/ItemRoot/Hotspots")
	assert(overlay.texture != null, "hotspot overlay texture missing")
	assert(overlay.texture == cup.data.hotspot_overlay,
		"overlay is not the one the item's data points at")
	assert(overlay.visible, "hotspot rings should be on by default")
	game.apply_toggle("hotspots", false)
	await process_frame
	assert(not overlay.visible, "hotspot rings did not switch off")
	game.apply_toggle("hotspots", true)
	print("7.5 hotspot overlay: separate sprite, toggles off and on")

	# --- 7.3 the question line frames the decision from surface info ---
	var question: String = inspect.get_node("Question").text
	assert(cup.data.visible_material in question,
		"the question line does not mention what the item looks like")
	print("7.3 question line: \"%s\"" % question)

	# --- 7.2 evidence lights up and points at a bin ---
	var hinted: Array[int] = []
	inspect.bin_hint_changed.connect(func(c: int) -> void: hinted.append(c))
	assert(inspect._evidence_state()["bin"] == -1,
		"a bin was hinted before any evidence was revealed")

	# Rinse the grimy patch: residue found -> the residue rule fires -> RESIDU.
	inspect._armed = &"rinse"
	inspect._use_tool_at(_point_for(Vector2(0.38, 0.70)))
	assert(cup.is_revealed("has_residue"), "rinse hotspot did not reveal")
	assert(hinted[-1] == ItemData.Category.LANDFILL,
		"residue evidence should point at RESIDU")
	var lit_chips := 0
	for chip in inspect.get_node("EvidenceScroll/EvidenceLog").get_children():
		if chip.texture == CHIP_MATCH:
			lit_chips += 1
	assert(lit_chips > 0, "no evidence chip lit up for a satisfied rule")
	print("7.2 after rinse: %d chip(s) lit, bin hint -> %s"
		% [lit_chips, Strings.category_name(hinted[-1])])

	# Swab it: the residue is solvent paint, so the chemical rule outranks the
	# residue rule and the hint moves to B3.
	inspect._armed = &"swab"
	inspect._use_tool_at(_point_for(Vector2(0.62, 0.60)))
	assert(cup.is_revealed("residue_type"), "swab hotspot did not reveal")
	assert(hinted[-1] == ItemData.Category.HAZARD,
		"a higher-priority rule should move the hint to B3")
	print("7.2 after swab: bin hint -> %s (higher-priority rule took over)"
		% Strings.category_name(hinted[-1]))
	assert(hinted[-1] == int(RuleChecker.resolve(cup.data, day.active_rules)["category"]),
		"the hint disagrees with the answer the game will actually judge")

	# --- 7.4 a tool that finds nothing says so, and says what it cost ---
	var budget_before: int = game.budget_left
	inspect._armed = &"cutter"
	inspect._use_tool_at(_point_for(Vector2(0.04, 0.04))) # empty corner
	var feedback: String = inspect.get_node("Feedback").text
	assert(game.budget_left == budget_before - game.cost_of(&"tool"),
		"a miss must still cost the shift")
	assert(feedback != "", "a tool that found nothing gave no feedback at all")
	assert(str(game.cost_of(&"tool")) in feedback,
		"the miss feedback does not say what it cost")
	print("7.4 miss feedback: \"%s\"" % feedback)

	# An item with nothing to find must not light anything up.
	var peel = _find(game.inventory, &"banana_peel")
	inspect.show_entry(peel)
	assert(inspect._evidence_state()["bin"] == -1,
		"an item with no revealed evidence should hint at no bin")
	print("obvious item hints at nothing, as it should")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
