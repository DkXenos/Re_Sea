# THE end of the day. there used to be a separate `report` scene in front of
# this one showing the same mistakes over again in a different style, so every
# day ended with two screens saying the same thing. that scene is gone and its
# two jobs moved here: closing the day's books, and explaining what went wrong.
#
# three tabs, buttons swapping visibility. no transitions.
extends Node2D

const SLOT_BG := preload("res://assets/ui/panel_slot.png")
const MARK_CORRECT := preload("res://assets/ui/icon_check.png")
const MARK_WRONG := preload("res://assets/ui/icon_cross.png")

const REQUIREMENT_ROW_HEIGHT := 30.0
# one readable row per part of the blueprint. the sheet shows what the machine
# will look like; this is what you can actually press.
const PART_ROW_HEIGHT := 84
const PART_ICON := 56.0
# the mistake rows carry the whole explanation now, so the art can be small -
# the reading is the point, not the picture.
const MISTAKE_ICON := 56

# The Technology page sits on panel_dark.png, which is a cream page whatever its
# name says, so its text is dark. The Result page is not on it - that one is the
# blue paper art and keeps its pale text.
const PAGE_HEADING := Color(0.09, 0.30, 0.47)
const PAGE_BODY := Color(0.16, 0.18, 0.21)
const PAGE_NOTE := Color(0.30, 0.31, 0.32)
# still readable against cream, unlike the originals
const PAGE_GOOD := Color(0.11, 0.42, 0.22)
const PAGE_BAD := Color(0.65, 0.20, 0.12)

# There used to be a third tab, Gear, where you fitted one upgrade at a time and
# every one of them charged you for what it gave. It is gone: a machine built
# out of five days of sorting now switches itself on and stays on, so there is
# nothing left on that page to press. See Game.active_upgrades.
enum Tab { RESULT, TECH }

@onready var _tab_buttons: Array[Button] = [
	$UiLayer/Root/Tabs/ResultTab, $UiLayer/Root/Tabs/TechTab]
@onready var _pages: Array[Control] = [
	$UiLayer/Root/ResultPage, $UiLayer/Root/TechPage]

# the result page is drawn art, the other two are a plain dark plate
@onready var _report_art: TextureRect = $UiLayer/Root/ReportArt
@onready var _page_bg: NinePatchRect = $UiLayer/Root/PageBg

@onready var _title: Label = $UiLayer/Root/TitleLabel
@onready var _next: Button = $UiLayer/Root/NextButton

@onready var _mistakes_title: Label = $UiLayer/Root/ResultPage/MistakesTitle
@onready var _mistakes: VBoxContainer = $UiLayer/Root/ResultPage/MistakesScroll/Mistakes
@onready var _result_summary: Label = $UiLayer/Root/ResultPage/Summary
@onready var _recovered_title: Label = $UiLayer/Root/ResultPage/RecoveredTitle
@onready var _recovered: VBoxContainer = $UiLayer/Root/ResultPage/Recovered

# technology tab
@onready var _tech: Control = $UiLayer/Root/TechPage
@onready var _diagram: Control = $UiLayer/Root/TechPage/Diagram
@onready var _craft_button: Button = $UiLayer/Root/TechPage/CraftButton
@onready var _parts_list: VBoxContainer = $UiLayer/Root/TechPage/PartsScroll/PartsList
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
	# closing the books is this screen's job now, and it has to happen before
	# anything reads the numbers. `_credit_materials` is not idempotent - the
	# day may be committed exactly once.
	if not Game.day_committed:
		Game.commit_day_result(Game.end_day_breakdown())
		Events.sfx_requested.emit(&"day_end")
	_title.text = Strings.tf("after_title", {"n": day.day_number if day != null else 0})
	_next.text = Strings.t("after_last_day") if Game.is_last_day() \
		else Strings.t("after_next_day")
	_next.pressed.connect(_finish)
	var labels: Array[String] = ["after_tab_result", "after_tab_tech"]
	for i in _tab_buttons.size():
		_tab_buttons[i].text = Strings.t(labels[i])
		_tab_buttons[i].pressed.connect(_show_tab.bind(i as Tab))
	_tech.get_node("PrevButton").text = Strings.t("tech_prev")
	_tech.get_node("NextButton").text = Strings.t("tech_next")
	_tech.get_node("PrevButton").pressed.connect(_page_sheet.bind(-1))
	_tech.get_node("NextButton").pressed.connect(_page_sheet.bind(1))
	_craft_button.pressed.connect(_on_craft_blueprint)
	_paint_cream_pages()
	_popup.get_node("CloseButton").text = Strings.t("tech_close")
	_popup.get_node("CloseButton").pressed.connect(_close_popup)
	_popup.get_node("CraftPartButton").pressed.connect(_on_craft_part)
	_build_result()
	_build_tech()
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
	_report_art.visible = tab == Tab.RESULT
	_page_bg.visible = tab != Tab.RESULT
	Events.sfx_requested.emit(&"ui_click")


func _finish() -> void:
	Events.phase_finished.emit()


# tab 1: how the day went

# The left sheet explains every mis-sort: what it was, where it went, where it
# belonged, the property that decided it and was never checked, and the rule
# that decided it. The right sheet is what the day actually paid out.
func _build_result() -> void:
	_mistakes_title.text = Strings.t("report_mistakes")
	_clear(_mistakes)
	var any := false
	for entry: CarriedItem in Game.inventory:
		if entry.sorted_to == -1 or entry.was_correct:
			continue
		any = true
		_mistakes.add_child(MistakeView.build_row(entry, MISTAKE_ICON))
	if not any:
		MistakeView.add_line(_mistakes, Strings.t("report_perfect"), 17,
			Color(0.75, 1, 0.82))

	_build_recovered()

	var result := Game.last_breakdown
	var unsorted := Game.unsorted_items().size()
	# machines built is the Technology tab's whole job - repeating the count
	# here just put a second progress read-out on a page about today
	_result_summary.text = "\n".join([
		Strings.t("report_quota_met") if bool(result.get("quota_met", false)) \
			else Strings.t("report_quota_failed"),
		Strings.tf("after_sorted", {"ok": int(result.get("correct", 0)),
			"bad": int(result.get("wrong", 0)), "left": unsorted}),
		Strings.tf("after_budget", {"spent": int(Game.stats.get("spent", 0)),
			"left": Game.budget_left, "max": Game.budget_max}),
	])


# what the day actually paid out. a wrong bin is not a smaller payout, it is
# no payout - the item is gone, so it never shows up here.
func _build_recovered() -> void:
	_recovered_title.text = Strings.t("report_recovered")
	_clear(_recovered)
	var recovered := Game.day_recovered()
	if recovered.is_empty():
		MistakeView.add_line(_recovered, Strings.t("report_recovered_none"), 16,
			Color(1, 0.82, 0.72))
	else:
		for category in ItemData.Category.values():
			if not recovered.has(category):
				continue
			MistakeView.add_line(_recovered, Strings.tf("report_recovered_line",
				{"n": int(recovered[category]), "v": Strings.category_name(category)}),
				19, Color(0.78, 1, 0.85))
	var wrong: int = int(Game.last_breakdown.get("wrong", 0))
	if wrong > 0:
		MistakeView.add_line(_recovered, Strings.tf("report_wasted", {"n": wrong}), 15,
			Color(1, 0.76, 0.7))
	MistakeView.add_line(_recovered, Strings.t("report_recovered_note"), 13,
		Color(0.85, 0.92, 1))


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
	_build_parts_list(bp)
	_refresh_craft_button(bp)


# The labels authored in the scene inherit the theme's pale Label colour, which
# is meant for the navy panels everywhere else in the game.
func _paint_cream_pages() -> void:
	for path: String in ["BlueprintName", "PartsLabel"]:
		_tech.get_node(path).add_theme_color_override("font_color", PAGE_HEADING)
	for path: String in ["PoolLabel", "Flavour", "Unlocks"]:
		_tech.get_node(path).add_theme_color_override("font_color", PAGE_NOTE)


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


# What the machine does for you, on the sheet, before and after it is built.
# Nothing to fit and nothing to choose, so this line is the whole story - it
# says what building this changes about the claw, and then says it is on.
func _unlocks_text(bp: BlueprintData) -> String:
	var up := Game.upgrade_for(bp)
	if up == null:
		return ""
	var key := "tech_fitted" if Game.blueprint_unlocked(bp.id) else "tech_unlocks"
	return Strings.tf(key, {"v": up.display_name, "effect": up.benefit_text})


# The sheet only ever showed a part once it was built, so an unbuilt blueprint
# was a picture with nothing on it and no clue that any of it could be clicked.
# The list says what the parts ARE, what each one costs, and carries the button.
func _build_parts_list(bp: BlueprintData) -> void:
	_clear(_parts_list)
	if bp == null:
		return
	for component: ComponentData in bp.components:
		_parts_list.add_child(_make_part_row(component))


func _make_part_row(component: ComponentData) -> Control:
	var done := Game.component_crafted(component)
	var shortfall := Game.craft_shortfall(component)

	var row := _panel_row(PART_ROW_HEIGHT)
	row.custom_minimum_size = Vector2(506, PART_ROW_HEIGHT)

	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = component.done_texture
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.position = Vector2(14, (PART_ROW_HEIGHT - PART_ICON) * 0.5)
	icon.size = Vector2(PART_ICON, PART_ICON)
	row.add_child(icon)

	var lines := VBoxContainer.new()
	lines.position = Vector2(84, 14)
	lines.size = Vector2(238, 56)
	lines.add_theme_constant_override("separation", 2)
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(lines)
	MistakeView.add_line(lines, component.display_name, 16, Color(1, 1, 1))
	MistakeView.add_line(lines, _requirement_text(component), 13,
		Color(0.6, 0.9, 0.7) if shortfall.is_empty() or done else Color(0.95, 0.72, 0.6))

	var button := Button.new()
	button.position = Vector2(334, 20)
	button.size = Vector2(156, 44)
	button.text = _craft_part_label(done, shortfall)
	button.add_theme_font_size_override("font_size", 15)
	button.disabled = done or not shortfall.is_empty()
	if not button.disabled:
		button.pressed.connect(_on_craft_part_row.bind(component))
	row.add_child(button)
	return row


func _on_craft_part_row(component: ComponentData) -> void:
	if not Game.craft_component(component):
		return
	Events.sfx_requested.emit(&"bin_accept")
	_build_tech()


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
	# The sheet already carries the faint lineart of every part, so an uncrafted
	# component draws nothing and lets that show through. Its box still comes
	# from the finished drawing, or the click target would move once it is built.
	var texture: Texture2D = component.done_texture if done else component.locked_texture
	var sized: Texture2D = component.done_texture if component.done_texture != null \
		else component.locked_texture
	# whole pixels. the fitted scale is never exact and the layout check counts
	# a part 0.000001px wider than its box as escaping it.
	var display: Vector2 = (sized.get_size() * scale_factor).round() \
		if sized != null else Vector2(96, 96)

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


# "6 organic, 2 residue"
func _requirement_text(component: ComponentData) -> String:
	var parts: Array[String] = []
	for category: int in component.requirements:
		parts.append("%d %s" % [int(component.requirements[category]),
			Strings.category_name(category)])
	return Strings.tf("blueprint_requires", {"v": ", ".join(parts)})


# component popup

# ONE row per material: the bin it comes out of, how many you have, how many it
# takes. The old version printed a "Needs 2 RESIDUE (have 0)" line and then a
# second "Short 2 RESIDUE" line under it - two lines saying the same thing,
# and neither said where RESIDUE comes from, which is the actual question a
# player has. The shortfall now lives on the button, which is where it changes
# what you can do.
func _open_popup(component: ComponentData) -> void:
	_popup_component = component
	var done := Game.component_crafted(component)
	var shortfall := Game.craft_shortfall(component)

	_popup.get_node("Icon").texture = component.done_texture if done \
		else component.locked_texture
	var popup_title: Label = _popup.get_node("TitleLabel")
	popup_title.text = component.display_name
	popup_title.add_theme_color_override("font_color", PAGE_HEADING)
	var popup_status: Label = _popup.get_node("StatusLabel")
	popup_status.text = Strings.t("tech_part_done") if done \
		else Strings.t("tech_part_todo")
	popup_status.add_theme_color_override("font_color", PAGE_NOTE)

	var lines: VBoxContainer = _popup.get_node("Lines")
	_clear(lines)
	for category: int in component.requirements:
		lines.add_child(_requirement_row(category,
			int(component.requirements[category])))
	MistakeView.add_line(lines, "", 6, Color.WHITE)
	# names the door the material comes through. without it a part that wants a
	# category the day never spawns reads as a bug.
	MistakeView.add_line(lines, Strings.t("tech_material_source"), 12, PAGE_NOTE)

	var button: Button = _popup.get_node("CraftPartButton")
	button.text = _craft_part_label(done, shortfall)
	button.disabled = done or not shortfall.is_empty()
	_popup_layer.visible = true
	Events.sfx_requested.emit(&"ui_click")


# bin plate, the bin's name, have / need, and a tick or a cross. green once the
# store covers it, so the row is readable without doing the subtraction.
func _requirement_row(category: int, need: int) -> Control:
	var held: int = Game.material_count(category)
	var enough: bool = held >= need
	var colour := PAGE_GOOD if enough else PAGE_BAD

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.custom_minimum_size = Vector2(0, REQUIREMENT_ROW_HEIGHT)
	row.add_child(BinIcons.make_icon(category, REQUIREMENT_ROW_HEIGHT))

	var name_label := Label.new()
	name_label.text = Strings.category_name(category)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", PAGE_BODY)
	row.add_child(name_label)

	var count := Label.new()
	count.text = Strings.tf("tech_progress", {"have": held, "need": need})
	count.custom_minimum_size = Vector2(72, 0)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count.add_theme_font_size_override("font_size", 16)
	count.add_theme_color_override("font_color", colour)
	row.add_child(count)

	var mark := TextureRect.new()
	mark.texture = MARK_CORRECT if enough else MARK_WRONG
	mark.custom_minimum_size = Vector2.ONE * 20.0
	mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(mark)
	return row


# Just "Build", greyed out when it cannot be pressed. The shortfall used to be
# written on the button itself, and "Short 2 RECYCLABLE" is wider than the
# button is - it ran out over both ends of it. The requirement line right next
# to the button already turns red and names what is missing, and so does the
# popup, so nothing was lost by taking it off.
func _craft_part_label(done: bool, _shortfall: Dictionary) -> String:
	return Strings.t("tech_rakit_done") if done else Strings.t("tech_rakit")


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
	_build_result()


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
