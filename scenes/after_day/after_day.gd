# between the report and the next day. entered EVERY day - the old version
# only fired when a blueprint happened to finish, which meant you could play
# four days of five and never see any of the meta systems.
#
# three tabs, buttons swapping visibility. no transitions.
extends Node2D

# experimental. to kill the puzzle: this line, the marked block in
# _on_craft_blueprint(), and scenes/puzzle/.
const CALIBRATION_PUZZLE := preload("res://scenes/puzzle/calibration_puzzle.tscn")

const SLOT_BG := preload("res://assets/ui/panel_slot.png")
const MARK_CORRECT := preload("res://assets/ui/icon_check.png")
const MARK_WRONG := preload("res://assets/ui/icon_cross.png")
# laid out in item-texture units, read off the texture so 256px art still works
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
@onready var _gear_rows: VBoxContainer = $UiLayer/Root/GearPage/Scroll/Rows

# technology tab
@onready var _tech: Control = $UiLayer/Root/TechPage
@onready var _diagram: Control = $UiLayer/Root/TechPage/Diagram
@onready var _craft_button: Button = $UiLayer/Root/TechPage/CraftButton
@onready var _popup_layer: CanvasLayer = $PopupLayer
@onready var _popup: Control = $PopupLayer/Popup/Panel

var _tab: Tab = Tab.RESULT
# one sheet at a time, paged with the arrows. no tabs inside tabs.
# TODO no way to tell from the arrows that another sheet is craftable. dot
# indicator or something.
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
	# "advance" carries a mouse click for the click-anywhere screens. this one
	# is a screen you poke around in - a click on dead space between tabs is
	# not a request to start tomorrow. keyboard only here.
	if event is InputEventMouseButton:
		return
	if not event.is_action_pressed(&"advance"):
		return
	# enter belongs to the popup when one is open, else it starts the next day
	# right out from under it
	if _popup_layer.visible:
		_close_popup()
	else:
		_finish()
	get_viewport().set_input_as_handled()


func _show_tab(tab: Tab) -> void:
	_tab = tab
	if _popup_layer.visible:
		_close_popup()
	for i in _pages.size():
		_pages[i].visible = i == int(tab)
		_tab_buttons[i].disabled = i == int(tab)
	Events.sfx_requested.emit(&"ui_click")


func _finish() -> void:
	Events.phase_finished.emit()


# tab 1: today's haul

# the haul as actual art. a list of names says the same thing but feels like
# a receipt.
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
	var unsorted := Game.unsorted_items().size()
	_result_summary.text = "\n".join([
		Strings.tf("after_sorted", {"ok": int(result.get("correct", 0)),
			"bad": int(result.get("wrong", 0)), "left": unsorted}),
		Strings.tf("after_budget", {"spent": int(Game.stats.get("spent", 0)),
			"left": Game.budget_left, "max": Game.budget_max}),
		Strings.tf("after_sea", {"have": Game.unlocked_blueprints.size(),
			"need": Game.blueprints.size()}),
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


# read the size off the texture, don't assume 160
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

	# right/wrong is its own png on top, never a tint on the item
	var mark := Sprite2D.new()
	mark.texture = MARK_CORRECT if entry.was_correct else MARK_WRONG
	mark.position = Vector2(size.x * 0.5 - 16.0, -size.y * 0.5 + 16.0)
	holder.add_child(mark)
	return holder


# tab 2: technology

# fixed recipes. everything is authored in a .tres and on screen before you
# commit - no combining, nothing to discover, no failure state. a craft you
# can't pay for is refused with the shortfall named.
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


# keep the pool next to the button that spends it
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


# laid out from the rect the background is ACTUALLY drawn at, parts placed
# from their 0-1 coords. a sheet at another resolution still lines up.
func _build_diagram(bp: BlueprintData) -> void:
	_clear(_diagram)
	if bp == null or bp.background == null:
		return
	# the centrepiece is part of the sheet, so the sheet is what changes state
	var sheet_texture := bp.sheet(Game.crafted, Game.blueprint_unlocked(bp.id))
	var sheet := sheet_texture.get_size()
	var box := _diagram.size
	var scale_factor: float = minf(box.x / sheet.x, box.y / sheet.y)
	var drawn := sheet * scale_factor
	var origin := (box - drawn) * 0.5

	var background := TextureRect.new()
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.custom_minimum_size = Vector2.ZERO
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.texture = sheet_texture
	background.position = origin
	background.size = drawn
	_diagram.add_child(background)

	for component: ComponentData in bp.components:
		_diagram.add_child(_make_component(component, origin, drawn, scale_factor))


# two pngs, we just pick one. no greyscaling in code.
func _make_component(component: ComponentData, origin: Vector2, drawn: Vector2,
		scale_factor: float) -> Control:
	var done := Game.component_crafted(component)
	var texture: Texture2D = component.done_texture if done else component.locked_texture
	# whole pixels. the fitted scale is never exact and the layout check counts
	# a part 0.000001px wider than its box as escaping it.
	var display: Vector2 = (texture.get_size() * scale_factor).round() \
		if texture != null else Vector2(96, 96)

	var holder := Control.new()
	holder.position = (origin + component.diagram_position * drawn
		- display * 0.5).round()
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

	# invisible hit area, same as the inventory cards
	var button := Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.tooltip_text = "%s\n%s" % [component.display_name,
		_requirement_text(component)]
	button.pressed.connect(_open_popup.bind(component))
	holder.add_child(button)
	return holder


# dead until every part is on the diagram
func _refresh_craft_button(bp: BlueprintData) -> void:
	if bp == null:
		_craft_button.text = ""
		_craft_button.disabled = true
		return
	if Game.blueprint_unlocked(bp.id):
		_craft_button.text = Strings.t("tech_craft_done")
		_craft_button.disabled = true
	elif Game.blueprint_ready(bp):
		_craft_button.text = Strings.tf("tech_craft", {"v": bp.display_name})
		_craft_button.disabled = false
	else:
		_craft_button.text = Strings.t("tech_craft_locked")
		_craft_button.disabled = true


# "6 organic, 2 landfill"
func _requirement_text(component: ComponentData) -> String:
	var parts: Array[String] = []
	for category: int in component.requirements:
		parts.append("%d %s" % [int(component.requirements[category]),
			Strings.category_name(category)])
	return Strings.tf("blueprint_requires", {"v": ", ".join(parts)})


# component popup

# pool repeated here next to the requirement so you don't need a second screen.
# button says what's short instead of just being dead.
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
	# --- experimental puzzle, only call site ---
	if Game.feature_calibration_puzzle:
		var puzzle: CanvasLayer = CALIBRATION_PUZZLE.instantiate()
		if puzzle.setup(bp.id):
			add_child(puzzle)
			return
		puzzle.free()
	# --- end ---


# tab 3: gear

# all four always listed. fitting one is free and reversible, there's no
# currency anywhere in this game.
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
		# benefit and cost together, always
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


# helpers

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


# queue_free on its own isn't enough here
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
