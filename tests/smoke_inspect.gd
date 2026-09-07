# the inspect panel legibility stuff, checked instead of eyeballed
#   godot --headless --script tests/smoke_inspect.gd
extends SceneTree

const CHIP_MATCH := preload("res://assets/ui/chip_match.png")


func _init() -> void:
	_run()


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

	# --- 7.5 the whole item is the target, wherever you click ---
	var cup = _find(game.inventory, &"tisu_b3")
	inspect.show_entry(cup)
	await process_frame
	assert(not inspect.has_node("ViewportBox/ItemViewport/ItemRoot/Hotspots"),
		"the hotspot ring overlay is still in the scene")
	# the far corner of the art is as good as the centre now
	inspect._armed = &"rinse"
	inspect._use_tool()
	assert(cup.is_revealed("has_residue"),
		"a click anywhere on the item did not use the tool")
	print("7.5 no aiming: the item is one target, and the rings are gone")

	# --- 7.3 the question line frames the decision from surface info ---
	var question: String = inspect.get_node("Question").text
	assert(cup.data.visible_material in question,
		"the question line does not mention what the item looks like")
	print("7.3 question line: \"%s\"" % question)

	# --- 7.2 evidence lights up and points at a bin ---
	var hinted: Array[int] = []
	inspect.bin_hint_changed.connect(func(c: int) -> void: hinted.append(c))

	# The residue is already found, so re-showing it fires the rule -> LANDFILL.
	inspect.show_entry(cup)
	assert(hinted[-1] == ItemData.Category.LANDFILL,
		"residue evidence should point at LANDFILL")
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
	inspect._use_tool()
	assert(cup.is_revealed("residue_type"), "the swab revealed nothing")
	assert(hinted[-1] == ItemData.Category.HAZARD,
		"a higher-priority rule should move the hint to B3")
	print("7.2 after swab: bin hint -> %s (higher-priority rule took over)"
		% Strings.category_name(hinted[-1]))
	assert(hinted[-1] == int(RuleChecker.resolve(cup.data, day.active_rules)["category"]),
		"the hint disagrees with the answer the game will actually judge")

	# --- 7.4 a tool that finds nothing says so, and says what it cost ---
	# the peel has nothing for any tool, so any inspection tool misses on it
	var peel = _find(game.inventory, &"banana_peel")
	inspect.show_entry(peel)
	var budget_before: int = game.budget_left
	inspect._armed = &"magnifier"
	inspect._use_tool()
	var feedback: String = inspect.get_node("Feedback").text
	assert(game.budget_left == budget_before - game.cost_of(&"tool"),
		"a miss must still cost the shift")
	assert(feedback != "", "a tool that found nothing gave no feedback at all")
	assert(str(game.cost_of(&"tool")) in feedback,
		"the miss feedback does not say what it cost")
	print("7.4 miss feedback: \"%s\"" % feedback)

	# An item with nothing to find must not light anything up.
	assert(inspect._evidence_state()["bin"] == -1,
		"an item with no revealed evidence should hint at no bin")
	print("obvious item hints at nothing, as it should")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
