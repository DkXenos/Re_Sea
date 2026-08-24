## Between the day report and the next day. Revision 3's main change.
##
## Every meta system used to be reachable once per run, on a screen that fired
## when a blueprint happened to complete. That meant the owner played four days
## of a five-day game without seeing any of it. This screen is entered EVERY
## day, so the blueprints, the upgrades and the day's result are all in front of
## the player once per day whether anything completed or not.
##
## Three tabs, plain buttons swapping visibility. No transitions, no new
## animation: everything here is a NinePatchRect over an existing UI PNG, text,
## and buttons.
extends Node2D

## EXPERIMENTAL - revision 3 §5 moved the calibration puzzle's entry point here,
## next to the blueprint it belongs to. Delete this line, the marked block in
## _on_claim(), and scenes/puzzle/, and the feature is gone.
const CALIBRATION_PUZZLE := preload("res://scenes/puzzle/calibration_puzzle.tscn")

const SLOT_BG := preload("res://assets/ui/panel_slot.png")
const MARK_CORRECT := preload("res://assets/ui/icon_check.png")
const MARK_WRONG := preload("res://assets/ui/icon_cross.png")
## The table is laid out in item-texture units, read from the texture itself so
## a designer delivering 256px items does not have to touch this (rev 3 §1.5).
const TABLE_COLUMNS := 7
const TABLE_GAP := Vector2(12.0, 30.0)

enum Tab { RESULT, TECH, GEAR }

@onready var _tab_buttons: Array[Button] = [
	$UiLayer/Root/Tabs/ResultTab, $UiLayer/Root/Tabs/TechTab, $UiLayer/Root/Tabs/GearTab]
@onready var _pages: Array[Control] = [
	$UiLayer/Root/ResultPage, $UiLayer/Root/TechPage, $UiLayer/Root/GearPage]

@onready var _title: Label = $UiLayer/Root/TitleLabel
@onready var _next: Button = $UiLayer/Root/NextButton

@onready var _table: Node2D = $UiLayer/Root/ResultPage/Table
@onready var _result_summary: Label = $UiLayer/Root/ResultPage/Summary
@onready var _mistakes: VBoxContainer = $UiLayer/Root/ResultPage/MistakesScroll/Mistakes
@onready var _gear_rows: VBoxContainer = $UiLayer/Root/GearPage/Rows

# --- Teknologi (revision 4 §3) ---
@onready var _tech: Control = $UiLayer/Root/TechPage
@onready var _diagram: Control = $UiLayer/Root/TechPage/Diagram
@onready var _craft_button: Button = $UiLayer/Root/TechPage/CraftButton
@onready var _popup_layer: CanvasLayer = $PopupLayer
@onready var _popup: Control = $PopupLayer/Popup/Panel

var _tab: Tab = Tab.RESULT
## Which blueprint the selector is showing. There is no grid and no tabs inside
## tabs - one sheet at a time, paged with the two arrows.
var _sheet: int = 0
var _popup_component: ComponentData = null


func _ready() -> void:
	var day := Game.current_day()
	_title.text = Strings.tf("after_title", {"n": day.day_number if day != null else 0})
	_next.text = Strings.t("after_last_day") if Game.is_last_day() \
		else Strings.t("after_next_day")
	_next.pressed.connect(_finish)
	var labels: Array[String] = ["after_tab_result", "after_tab_tech", "after_tab_gear"]
	for i in _tab_buttons.size():
		_tab_buttons[i].text = Strings.t(labels[i])
		_tab_buttons[i].pressed.connect(_show_tab.bind(i as Tab))
	_tech.get_node("PrevButton").text = Strings.t("tech_prev")
	_tech.get_node("NextButton").text = Strings.t("tech_next")
	_tech.get_node("PrevButton").pressed.connect(_page_sheet.bind(-1))
	_tech.get_node("NextButton").pressed.connect(_page_sheet.bind(1))
	_craft_button.pressed.connect(_on_craft_blueprint)
	_popup.get_node("CloseButton").text = Strings.t("tech_close")
	_popup.get_node("CloseButton").pressed.connect(_close_popup)
	_popup.get_node("CraftPartButton").pressed.connect(_on_craft_part)
	_build_result()
	_build_tech()
	_build_gear()
	_show_tab(Tab.RESULT)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"advance"):
		_finish()
		get_viewport().set_input_as_handled()


func _show_tab(tab: Tab) -> void:
	_tab = tab
	for i in _pages.size():
		_pages[i].visible = i == int(tab)
		_tab_buttons[i].disabled = i == int(tab)
	Events.sfx_requested.emit(&"ui_click")


func _finish() -> void:
	Events.phase_finished.emit()


# ------------------------------------------------------- tab 1: Hasil Hari Ini

## The day's haul, as the item art itself. A text list of names would say the
## same thing and feel like a receipt; the point of this tab is that the work
## became something.
func _build_result() -> void:
	_clear(_table)
	var size := _item_size()
	var step := size + TABLE_GAP
	var index := 0
	for entry: CarriedItem in Game.inventory:
		if entry.sorted_to == -1:
			continue
		var column := index % TABLE_COLUMNS
		var row := index / TABLE_COLUMNS
		var origin := Vector2(step.x * column, step.y * row) + size * 0.5
		_table.add_child(_make_table_item(entry, origin, size))
		index += 1

	var result := Game.last_breakdown
	var tier := Game.current_tier()
	var unsorted := Game.unsorted_items().size()
	_result_summary.text = "\n".join([
		Strings.tf("after_sorted", {"ok": int(result.get("correct", 0)),
			"bad": int(result.get("wrong", 0)), "left": unsorted}),
		Strings.tf("after_budget", {"spent": int(Game.stats.get("spent", 0)),
			"left": Game.budget_left, "max": Game.budget_max}),
		Strings.tf("after_health", {"before": int(result.get("health_before", 0)),
			"after": int(result.get("health_after", 0)),
			"tier": tier.display_name if tier != null else "?"}),
	])

	_clear(_mistakes)
	var any := false
	for entry: CarriedItem in Game.inventory:
		if entry.sorted_to == -1 or entry.was_correct:
			continue
		any = true
		_mistakes.add_child(MistakeView.build_row(entry, 64))
	if not any:
		MistakeView.add_line(_mistakes, Strings.t("report_perfect"), 17, Color(0.6, 0.9, 0.7))


## Reads the authored size off the texture rather than assuming 160 (rev 3 §1.5).
func _item_size() -> Vector2:
	for entry: CarriedItem in Game.inventory:
		if entry.data.texture != null:
			return entry.data.texture.get_size()
	return Vector2(160.0, 160.0)


func _make_table_item(entry: CarriedItem, origin: Vector2, size: Vector2) -> Node2D:
	var holder := Node2D.new()
	holder.position = origin

	var sprite := Sprite2D.new()
	sprite.texture = entry.data.texture
	holder.add_child(sprite)

	# Right or wrong is its own PNG sitting on top, never a tint on the item -
	# recolouring designer art to mean something is exactly what §1.4 forbids.
	var mark := Sprite2D.new()
	mark.texture = MARK_CORRECT if entry.was_correct else MARK_WRONG
	mark.position = Vector2(size.x * 0.5 - 16.0, -size.y * 0.5 + 16.0)
	holder.add_child(mark)
	return holder


# ------------------------------------------------------------ tab 2: Teknologi

## A blueprint is a diagram of parts, each crafted on its own by spending
## sorted materials, and one CRAFT button that assembles them (revision 4 §3).
##
## This is a FIXED-recipe system. Every requirement is authored in a .tres and
## on screen before the player commits: there is no free-form combining, no
## recipe to discover and no failure state. A craft the pool cannot pay for is
## refused with the shortfall named, never attempted and lost.
func _build_tech() -> void:
	var bp := _current_blueprint()
	var pageable: bool = Game.blueprints.size() > 1
	_tech.get_node("PrevButton").disabled = not pageable
	_tech.get_node("NextButton").disabled = not pageable
	_tech.get_node("BlueprintName").text = bp.display_name if bp != null else ""
	_tech.get_node("Flavour").text = bp.flavour_text if bp != null else ""
	_tech.get_node("PoolLabel").text = _pool_text()
	_tech.get_node("Unlocks").text = _unlocks_text(bp)
	_tech.get_node("PartsLabel").text = "" if bp == null else Strings.tf("tech_parts",
		{"have": bp.crafted_count(Game.crafted), "need": bp.components.size()})
	_build_diagram(bp)
	_refresh_craft_button(bp)


func _current_blueprint() -> BlueprintData:
	if Game.blueprints.is_empty():
		return null
	return Game.blueprints[posmod(_sheet, Game.blueprints.size())]


func _page_sheet(step: int) -> void:
	if Game.blueprints.is_empty():
		return
	_sheet = posmod(_sheet + step, Game.blueprints.size())
	Events.sfx_requested.emit(&"ui_click")
	_build_tech()


## The pool, always on screen. It is what the player spends, so it is never
## more than one glance away from the button that spends it.
func _pool_text() -> String:
	var parts: Array[String] = []
	for category in ItemData.Category.values():
		var held: int = Game.material_count(category)
		if held > 0:
			parts.append("%d %s" % [held, Strings.category_name(category)])
	if parts.is_empty():
		return Strings.t("tech_pool_empty")
	return Strings.tf("tech_pool", {"v": "   ·   ".join(parts)})


func _unlocks_text(bp: BlueprintData) -> String:
	if bp == null or bp.unlocks_upgrade == &"":
		return ""
	for up: UpgradeData in Game.upgrades:
		if up.id == bp.unlocks_upgrade:
			return Strings.tf("tech_unlocks", {"v": up.display_name})
	return ""


## The sheet with its parts on top of it.
##
## Everything is laid out from the rect the background is ACTUALLY drawn at,
## and every part is placed from its normalized 0-1 coordinate, so a designer
## delivering a sheet at a different resolution keeps the parts aligned without
## touching a number here. Part sizes scale with the sheet for the same reason.
func _build_diagram(bp: BlueprintData) -> void:
	_clear(_diagram)
	if bp == null or bp.background == null:
		return
	var sheet := bp.background.get_size()
	var box := _diagram.size
	var scale_factor: float = minf(box.x / sheet.x, box.y / sheet.y)
	var drawn := sheet * scale_factor
	var origin := (box - drawn) * 0.5

	var background := TextureRect.new()
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.custom_minimum_size = Vector2.ZERO
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.texture = bp.background
	background.position = origin
	background.size = drawn
	_diagram.add_child(background)

	for component: ComponentData in bp.components:
		_diagram.add_child(_make_component(component, origin, drawn, scale_factor))


## Crafted or not is two different PNGs, chosen here. Nothing is ever
## greyscaled, tinted or shaded in code - §3 is explicit about it.
func _make_component(component: ComponentData, origin: Vector2, drawn: Vector2,
		scale_factor: float) -> Control:
	var done := Game.component_crafted(component)
	var texture: Texture2D = component.done_texture if done else component.locked_texture
	var display: Vector2 = texture.get_size() * scale_factor if texture != null \
		else Vector2(96, 96)

	var holder := Control.new()
	holder.position = origin + component.diagram_position * drawn - display * 0.5
	holder.size = display

	var art := TextureRect.new()
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.custom_minimum_size = Vector2.ZERO
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.texture = texture
	art.position = Vector2.ZERO
	art.size = display
	holder.add_child(art)

	# Invisible hit area over the art, the same way an inventory card works.
	var button := Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.tooltip_text = "%s\n%s" % [component.display_name,
		_requirement_text(component)]
	button.pressed.connect(_open_popup.bind(component))
	holder.add_child(button)
	return holder


## One large button, and it does not become pressable until every part is on
## the diagram.
func _refresh_craft_button(bp: BlueprintData) -> void:
	if bp == null:
		_craft_button.text = ""
		_craft_button.disabled = true
		return
	if Game.blueprint_unlocked(bp.id):
		_craft_button.text = Strings.t("tech_craft_done")
		_craft_button.disabled = true
	elif Game.blueprint_ready(bp):
		_craft_button.text = Strings.tf("tech_craft",
			{"v": bp.display_name, "n": bp.health_gain})
		_craft_button.disabled = false
	else:
		_craft_button.text = Strings.t("tech_craft_locked")
		_craft_button.disabled = true


## "6 organik, 2 residu" - the fixed recipe, exactly as authored.
func _requirement_text(component: ComponentData) -> String:
	var parts: Array[String] = []
	for category: int in component.requirements:
		parts.append("%d %s" % [int(component.requirements[category]),
			Strings.category_name(category)])
	return Strings.tf("blueprint_requires", {"v": ", ".join(parts)})


# ------------------------------------------------------- the component popup

## Name, requirement, what the player actually holds, and Rakit. The pool is
## repeated here beside the requirement so the decision never needs a second
## screen, and the button says what is short rather than only being dead.
func _open_popup(component: ComponentData) -> void:
	_popup_component = component
	var done := Game.component_crafted(component)
	var shortfall := Game.craft_shortfall(component)

	_popup.get_node("Icon").texture = component.done_texture if done \
		else component.locked_texture
	_popup.get_node("TitleLabel").text = component.display_name
	_popup.get_node("StatusLabel").text = Strings.t("tech_part_done") if done \
		else Strings.t("tech_part_todo")

	var lines: VBoxContainer = _popup.get_node("Lines")
	_clear(lines)
	for category: int in component.requirements:
		var need: int = int(component.requirements[category])
		var held: int = Game.material_count(category)
		MistakeView.add_line(lines, "%s   (%s)" % [
			Strings.tf("tech_needs", {"n": need, "v": Strings.category_name(category)}),
			Strings.tf("tech_have", {"n": held})],
			15, Color(0.86, 0.9, 0.94) if held >= need else Color(0.95, 0.72, 0.6))
	for category: int in shortfall:
		MistakeView.add_line(lines, Strings.tf("tech_short",
			{"n": int(shortfall[category]), "v": Strings.category_name(category)}),
			14, Color(0.95, 0.72, 0.6))

	var button: Button = _popup.get_node("CraftPartButton")
	button.text = Strings.t("tech_rakit_done") if done else Strings.t("tech_rakit")
	button.disabled = done or not shortfall.is_empty()
	_popup_layer.visible = true
	Events.sfx_requested.emit(&"ui_click")


func _on_craft_part() -> void:
	if _popup_component == null or not Game.craft_component(_popup_component):
		return
	Events.sfx_requested.emit(&"bin_accept")
	_build_tech()
	_open_popup(_popup_component)


func _close_popup() -> void:
	_popup_layer.visible = false
	_popup_component = null
	Events.sfx_requested.emit(&"ui_click")


func _on_craft_blueprint() -> void:
	var bp := _current_blueprint()
	if bp == null or Game.build_blueprint(bp.id) == null:
		return
	Events.sfx_requested.emit(&"bin_accept")
	_build_tech()
	_build_gear()
	_build_result()
	# --- revision 3 §5 (EXPERIMENTAL), the only call site ---
	if Game.feature_calibration_puzzle:
		var puzzle: CanvasLayer = CALIBRATION_PUZZLE.instantiate()
		if puzzle.setup(bp.id):
			add_child(puzzle)
			return
		puzzle.free()
	# --- end §5 ---


# ------------------------------------------------------------ tab 3: Peralatan

## All four, always listed, so the player can see what they are working toward.
## Fitting one is free and reversible - there is no currency in this game and an
## upgrade is never bought.
func _build_gear() -> void:
	_clear(_gear_rows)
	for up: UpgradeData in Game.upgrades:
		_gear_rows.add_child(_make_gear_row(up))


func _make_gear_row(up: UpgradeData) -> Control:
	var unlocked := Game.upgrade_unlocked(up)
	var equipped := Game.equipped_upgrade == up.id

	var row := _panel_row(92)
	var lines := VBoxContainer.new()
	lines.position = Vector2(16, 8)
	lines.size = Vector2(700, 76)
	lines.add_theme_constant_override("separation", 1)
	row.add_child(lines)

	MistakeView.add_line(lines, up.display_name, 18, Color(1, 1, 1))
	if unlocked:
		# Benefit and cost always appear together, so no upgrade can ever read
		# as a pure improvement.
		MistakeView.add_line(lines, Strings.tf("upgrade_benefit", {"v": up.benefit_text}),
			13, Color(0.6, 0.92, 0.72))
		MistakeView.add_line(lines, Strings.tf("upgrade_cost", {"v": up.cost_text}),
			13, Color(0.95, 0.72, 0.6))
	else:
		MistakeView.add_line(lines, up.unlock_text, 14, Color(0.72, 0.78, 0.85))

	var button := Button.new()
	button.position = Vector2(736, 24)
	button.size = Vector2(180, 44)
	button.disabled = not unlocked
	if not unlocked:
		button.text = Strings.t("upgrade_locked")
	else:
		button.text = Strings.t("upgrade_equipped") if equipped else Strings.t("upgrade_equip")
		button.pressed.connect(_on_equip.bind(up))
	row.add_child(button)
	return row


func _on_equip(up: UpgradeData) -> void:
	Game.equip_upgrade(up.id)
	Events.sfx_requested.emit(&"ui_click")
	_build_gear()


# ------------------------------------------------------------------- helpers

func _panel_row(height: int) -> Control:
	var row := Control.new()
	row.custom_minimum_size = Vector2(936, height)
	var bg := NinePatchRect.new()
	bg.texture = SLOT_BG
	for side: String in ["left", "top", "right", "bottom"]:
		bg.set("patch_margin_" + side, 24)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(bg)
	return row


## queue_free() alone leaves the old children in the tree for the rest of the
## frame, so a list rebuilt twice in one frame would briefly show both sets.
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
