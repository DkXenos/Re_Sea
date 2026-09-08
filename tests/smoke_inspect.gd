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
	var tissue = _find(game.inventory, &"tisu_b3")
	inspect.show_entry(tissue)
	await process_frame
	assert(not inspect.has_node("ViewportBox/ItemViewport/ItemRoot/Hotspots"),
		"the hotspot ring overlay is still in the scene")
	# the far corner of the art is as good as the centre now
	inspect._armed = &"swab"
	inspect._use_tool()
	assert(tissue.is_revealed("stain_type"),
		"a click anywhere on the item did not use the tool")
	print("7.5 no aiming: the item is one target, and the rings are gone")

	# --- 7.3 what it looks like is readable without spending anything ---
	# This used to be a "looks like X, do you believe it?" line above the item,
	# which said the same thing as the first two chips in the evidence log. The
	# line is gone; the free surface facts still have to be there.
	var surface := ""
	for chip in inspect.get_node("EvidenceScroll/EvidenceLog").get_children():
		for node in chip.get_children():
			if node is Label:
				surface += (node as Label).text + "\n"
	assert(tissue.data.visible_material in surface,
		"the evidence log does not say what the item looks like")
	# a sealed crate is the one thing that still gets a line of its own, because
	# "cut it open" is not readable anywhere else on the desk
	var crate = _find(game.inventory, &"mystery_box")
	if crate != null:
		inspect.show_entry(crate)
		await process_frame
		assert(inspect.get_node("Question").text != "",
			"a sealed crate should still say that it has to be cut open")
		inspect.show_entry(tissue)
		await process_frame
	assert(inspect.get_node("Question").text == "",
		"an ordinary item should carry no question line any more")
	print("7.3 surface facts live in the evidence log, no question line")

	# --- 7.2 evidence lights up and points at a bin ---
	var hinted: Array[int] = []
	inspect.bin_hint_changed.connect(func(c: int) -> void: hinted.append(c))

	# Naming the stain also proves it is a chemical, so the priority-40 rule
	# beats the plain stain rule and the hint lands on HAZARDOUS.
	inspect.show_entry(tissue)
	assert(tissue.is_revealed("stain_hazardous"),
		"naming the stain should also prove it is a chemical one")
	assert(hinted[-1] == ItemData.Category.HAZARD,
		"a chemical stain should point at HAZARDOUS")
	var lit_chips := 0
	for chip in inspect.get_node("EvidenceScroll/EvidenceLog").get_children():
		if chip.texture == CHIP_MATCH:
			lit_chips += 1
	assert(lit_chips > 0, "no evidence chip lit up for a satisfied rule")
	print("7.2 chemical stain: %d chip(s) lit, bin hint -> %s"
		% [lit_chips, Strings.category_name(hinted[-1])])
	assert(hinted[-1] == int(RuleChecker.resolve(tissue.data, day.active_rules,
		tissue.rule_overrides())["category"]),
		"the hint disagrees with the answer the game will actually judge")

	# --- 7.6 a chemical stain does not rinse off, and the refusal is a finding
	var before_rinse: int = game.budget_left
	inspect._armed = &"rinse"
	inspect._use_tool()
	assert(not tissue.cleaned, "a chemical stain was rinsed off")
	assert(game.budget_left == before_rinse - game.cost_of(&"tool"),
		"a rinse that refuses to work must still cost the shift")
	assert(hinted[-1] == ItemData.Category.HAZARD,
		"a failed rinse should not move the answer")
	print("7.6 chemical stain survived the rinse, and the rinse still cost %d"
		% game.cost_of(&"tool"))

	# --- 7.7 an ordinary stain DOES come off, and that changes the answer ---
	var bag = _find(game.inventory, &"kantong_plastik")
	inspect.show_entry(bag)
	inspect._armed = &"swab"
	inspect._use_tool()
	assert(bag.is_revealed("stain_type"), "the swab found nothing on the bag")
	assert(hinted[-1] == ItemData.Category.RESIDUE,
		"a stain still on it should point at RESIDUE")
	inspect._armed = &"rinse"
	inspect._use_tool()
	assert(bag.cleaned, "an ordinary stain did not wash off")
	assert(int(RuleChecker.resolve(bag.data, day.active_rules,
		bag.rule_overrides())["category"]) == ItemData.Category.RECYCLABLE,
		"a rinsed bag should be judged as the plastic it is made of")
	assert(hinted[-1] != ItemData.Category.RESIDUE,
		"the stain rule is still firing on an item that has been rinsed")
	print("7.7 rinse: RESIDUE -> %s once the stain was off"
		% Strings.category_name(RuleChecker.resolve(bag.data, day.active_rules,
			bag.rule_overrides())["category"]))

	# --- 7.8 the cutter is for crates and nothing else ---
	var before_cut: int = game.budget_left
	inspect._armed = &"cutter"
	inspect._use_tool()
	assert(game.budget_left == before_cut,
		"the cutter charged for refusing to work on something that is not a crate")
	print("7.8 the cutter bounced off a plastic bag, free of charge")

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
