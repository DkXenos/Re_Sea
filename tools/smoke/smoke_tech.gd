# material pool + component crafting.
#
# two jobs. the rules that can't bend (pool is spendable, never negative, short
# craft refused with the shortfall named, 4th component is a .tres and no
# code), then the tuning question: does a real 5-day run actually supply what
# the components cost, and by which day.
#   godot --headless --script tools/smoke/smoke_tech.gd
#   godot --headless --script tools/smoke/smoke_tech.gd -- --supply
extends SceneTree

const EXTRA_PATH := "res://data/components/_tmp_fourth_part.tres"

var game: Node


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	game.start_run(9182)

	_check_content()
	_check_pool_is_spendable()
	_check_never_negative()
	_check_shortfall_is_named()
	_check_build_gate()
	_check_unlocks_a_tool()
	await _check_fourth_component_needs_no_code()
	await _check_through_the_tab()
	print("technology tab verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


## Three sheets, three parts each, every part with art for both states and a
## requirement that costs something.
func _check_content() -> void:
	assert(game.blueprints.size() == 3, "expected three blueprints, got %d"
		% game.blueprints.size())
	var ids: Dictionary = {}
	var total: int = 0
	for bp: BlueprintData in game.blueprints:
		assert(bp.background != null, "%s has no schematic sheet" % bp.id)
		assert(bp.components.size() >= 3, "%s has only %d components"
			% [bp.id, bp.components.size()])
		for component: ComponentData in bp.components:
			total += 1
			assert(not ids.has(component.id),
				"component id %s is used twice - Game.crafted is keyed by it"
				% component.id)
			ids[component.id] = true
			assert(component.locked_texture != null and component.done_texture != null,
				"%s is missing one of its two drawings" % component.id)
			assert(component.locked_texture != component.done_texture,
				("%s uses one texture for both states - locked and done must "
				+ "be two PNGs, never one tinted") % component.id)
			var at := component.diagram_position
			assert(at.x >= 0.0 and at.x <= 1.0 and at.y >= 0.0 and at.y <= 1.0,
				"%s sits at %s, outside the normalized sheet" % [component.id, at])
			assert(component.total_required() > 0, "%s costs nothing" % component.id)
	assert(total == 9, "expected nine components, got %d" % total)
	print("  %d sheets, %d components, every one with two drawings" %
		[game.blueprints.size(), total])


## The pool is spent, not accumulated. Crafting takes the materials away.
func _check_pool_is_spendable() -> void:
	game.start_run(9182)
	var component: ComponentData = game.blueprints[0].components[0]
	for category: int in component.requirements:
		game.materials[category] = int(component.requirements[category])
	var before: Dictionary = game.materials.duplicate()
	assert(game.craft_component(component), "an exactly-stocked pool refused a craft")
	for category: int in component.requirements:
		assert(game.material_count(category) ==
			int(before[category]) - int(component.requirements[category]),
			"crafting did not spend %s" % Strings.category_name(category))
		assert(game.material_count(category) == 0, "the pool should be empty now")
	assert(game.component_crafted(component), "the part is not marked crafted")
	assert(not game.craft_component(component), "a crafted part was crafted twice")
	print("  crafting %s spent the pool down to zero" % component.display_name)


## Never below zero, in any order, however hard it is pushed.
func _check_never_negative() -> void:
	game.start_run(9182)
	for bp: BlueprintData in game.blueprints:
		for component: ComponentData in bp.components:
			game.craft_component(component)
	for category in ItemData.Category.values():
		assert(game.material_count(category) >= 0,
			"%s went negative at %d" % [Strings.category_name(category),
			game.material_count(category)])
	assert(game.crafted.is_empty(), "an empty pool paid for a component")

	# A part short on its SECOND material must not silently eat the first.
	game.start_run(9182)
	var greedy: ComponentData = _multi_material_component()
	assert(greedy != null, "no component costs two materials - the check is moot")
	var categories: Array = greedy.requirements.keys()
	game.materials[categories[0]] = int(greedy.requirements[categories[0]])
	assert(not game.craft_component(greedy), "a half-paid craft went through")
	assert(game.material_count(categories[0]) ==
		int(greedy.requirements[categories[0]]),
		"a refused craft still took the material it could pay for")
	print("  refused crafts take nothing; no category ever goes below zero")


## A short craft says what it is short of, rather than only being dead.
func _check_shortfall_is_named() -> void:
	game.start_run(9182)
	var component: ComponentData = _multi_material_component()
	var categories: Array = component.requirements.keys()
	game.materials[categories[0]] = int(component.requirements[categories[0]])
	var short: Dictionary = game.craft_shortfall(component)
	assert(not short.is_empty(), "a craft that cannot be paid for reported no shortfall")
	assert(not short.has(categories[0]), "a category that is covered was reported short")
	assert(not game.can_craft(component), "can_craft disagreed with the shortfall")
	var named: Array[String] = []
	for category: int in short:
		named.append("%d %s" % [int(short[category]), Strings.category_name(category)])
	print("  a short craft names it: kurang %s" % ", ".join(named))


## The CRAFT button is gated on every part, and only on every part.
func _check_build_gate() -> void:
	game.start_run(9182)
	var bp: BlueprintData = game.blueprints[0]
	for category in ItemData.Category.values():
		game.materials[category] = 99
	for index in bp.components.size():
		assert(not game.blueprint_ready(bp),
			"the blueprint was ready with only %d of %d parts crafted"
			% [index, bp.components.size()])
		assert(game.build_blueprint(bp.id) == null,
			"an unfinished blueprint could be assembled")
		game.craft_component(bp.components[index])
	assert(game.blueprint_ready(bp), "every part crafted but the blueprint is not ready")
	var health_before: int = game.ocean_health
	assert(game.build_blueprint(bp.id) != null, "a finished blueprint refused to assemble")
	assert(game.blueprint_unlocked(bp.id), "assembling did not record the blueprint")
	assert(game.ocean_health == mini(100, health_before + bp.health_gain),
		"assembling did not pay its ocean bonus")
	assert(game.build_blueprint(bp.id) == null, "a blueprint was assembled twice")
	print("  CRAFT opens only on the last part, pays +%d, and fires once"
		% bp.health_gain)


## The tool it opens joins the Peralatan list rather than starting a second
## equipment system, and it is locked until the blueprint is built.
func _check_unlocks_a_tool() -> void:
	game.start_run(9182)
	for bp: BlueprintData in game.blueprints:
		assert(bp.unlocks_upgrade != &"", "%s opens no tool" % bp.id)
		var up: UpgradeData = null
		for candidate: UpgradeData in game.upgrades:
			if candidate.id == bp.unlocks_upgrade:
				up = candidate
		assert(up != null, "%s names a tool that is not in data/upgrades/" % bp.id)
		assert(not game.upgrade_unlocked(up),
			"%s is available before its blueprint is built" % up.id)

		for category in ItemData.Category.values():
			game.materials[category] = 99
		for component: ComponentData in bp.components:
			game.craft_component(component)
		game.build_blueprint(bp.id)
		assert(game.upgrade_unlocked(up), "%s stayed locked after its blueprint" % up.id)
		game.equip_upgrade(up.id)
		assert(game.equipped_upgrade == up.id, "%s could not be equipped" % up.id)
		game.equip_upgrade(up.id)
		assert(game.equipped_upgrade == &"", "%s could not be taken off again" % up.id)
	print("  three blueprints open three Peralatan entries, each equippable")


# the whole point of the data model: a fourth part is a .tres, nothing else
func _check_fourth_component_needs_no_code() -> void:
	game.start_run(9182)
	var bp: BlueprintData = game.blueprints[0]
	var before: int = bp.components.size()

	var extra: ComponentData = ComponentData.new()
	extra.id = &"_tmp_fourth_part"
	extra.display_name = "Bagian Uji Keempat"
	extra.locked_texture = load("res://assets/ui/comp_drone_body_locked.png")
	extra.done_texture = load("res://assets/ui/comp_drone_body_done.png")
	extra.diagram_position = Vector2(0.8, 0.5)
	extra.requirements = {ItemData.Category.RECYCLABLE: 2}
	assert(ResourceSaver.save(extra, EXTRA_PATH) == OK)
	bp.components.append(load(EXTRA_PATH))

	for category in ItemData.Category.values():
		game.materials[category] = 99
	for component: ComponentData in bp.components:
		assert(game.craft_component(component), "%s refused to craft" % component.id)
	assert(bp.crafted_count(game.crafted) == before + 1,
		"the fourth part was not counted")
	assert(game.blueprint_ready(bp), "the blueprint ignored its fourth part")

	# And the tab draws it without being told: four parts on the sheet.
	var scene: Node = load("res://scenes/after_day/after_day.tscn").instantiate()
	root.add_child(scene)
	for i in 5:
		await process_frame
	scene._show_tab(1)
	await process_frame
	var buttons: int = 0
	for holder: Node in scene.get_node("UiLayer/Root/TechPage/Diagram").get_children():
		for child: Node in holder.get_children():
			if child is Button:
				buttons += 1
	assert(buttons == before + 1,
		"the diagram drew %d parts, not %d" % [buttons, before + 1])
	print("  a fourth component: %d parts on the sheet, zero code changed"
		% buttons)

	root.remove_child(scene)
	scene.free()
	await process_frame
	bp.components.resize(before)
	extra = null
	DirAccess.remove_absolute(ProjectSettings.globalize_path(EXTRA_PATH))


## The rules above, but through the real tab: page the selector, click a part,
## press Rakit, press CRAFT.
func _check_through_the_tab() -> void:
	game.start_run(9182)
	var scene: Node = load("res://scenes/after_day/after_day.tscn").instantiate()
	root.add_child(scene)
	for i in 5:
		await process_frame
	scene._show_tab(1)
	await process_frame
	var page: Control = scene.get_node("UiLayer/Root/TechPage")

	# The selector pages, and the sheet under it changes.
	var first: String = page.get_node("BlueprintName").text
	page.get_node("NextButton").pressed.emit()
	await process_frame
	assert(page.get_node("BlueprintName").text != first, "the selector did not page")
	page.get_node("PrevButton").pressed.emit()
	await process_frame
	assert(page.get_node("BlueprintName").text == first, "paging back landed elsewhere")

	# The pool is on screen at all times, and CRAFT is shut until the last part.
	assert(not page.get_node("PoolLabel").text.is_empty(), "the pool is not shown")
	assert(page.get_node("CraftButton").disabled, "CRAFT opened with nothing crafted")

	var bp: BlueprintData = scene._current_blueprint()
	# Short: the popup offers Rakit but will not let it be pressed.
	scene._open_popup(bp.components[0])
	await process_frame
	var rakit: Button = scene.get_node("PopupLayer/Popup/Panel/CraftPartButton")
	assert(scene.get_node("PopupLayer").visible, "clicking a part opened nothing")
	assert(rakit.disabled, "Rakit was pressable with an empty pool")
	scene._close_popup()

	for category in ItemData.Category.values():
		game.materials[category] = 99
	for component: ComponentData in bp.components:
		scene._open_popup(component)
		await process_frame
		assert(not rakit.disabled, "Rakit stayed shut with a full pool")
		rakit.pressed.emit()
		await process_frame
		assert(game.component_crafted(component), "Rakit did not craft %s" % component.id)
		scene._close_popup()
	await process_frame
	assert(not page.get_node("CraftButton").disabled,
		"every part crafted but CRAFT stayed shut")
	page.get_node("CraftButton").pressed.emit()
	await process_frame
	assert(game.blueprint_unlocked(bp.id), "CRAFT did not assemble the blueprint")
	print("  through the tab: paged, clicked, Rakit x%d, CRAFT" % bp.components.size())

	root.remove_child(scene)
	scene.free()
	await process_frame


func _multi_material_component() -> ComponentData:
	for bp: BlueprintData in game.blueprints:
		for component: ComponentData in bp.components:
			if component.requirements.size() >= 2:
				return component
	return null
