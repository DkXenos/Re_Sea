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
@onready var _tech_rows: VBoxContainer = $UiLayer/Root/TechPage/Rows
@onready var _gear_rows: VBoxContainer = $UiLayer/Root/GearPage/Rows

var _tab: Tab = Tab.RESULT


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

## Progress and a Klaim button. Nothing else: no combining, no experimenting, no
## recipe discovery, no material inventory. §3 was explicit that this is not a
## crafting tab and it is not one.
func _build_tech() -> void:
	_clear(_tech_rows)
	for bp: BlueprintData in Game.blueprints:
		_tech_rows.add_child(_make_tech_row(bp))


func _make_tech_row(bp: BlueprintData) -> Control:
	var done := Game.blueprint_unlocked(bp.id)
	var claimable := Game.blueprint_claimable(bp)
	var progress: Dictionary = bp.progress(Game.correct_by_category)

	var row := _panel_row(96)
	var lines := VBoxContainer.new()
	lines.position = Vector2(16, 10)
	lines.size = Vector2(700, 76)
	lines.add_theme_constant_override("separation", 1)
	row.add_child(lines)

	MistakeView.add_line(lines, "%s   %d / %d" % [bp.display_name,
		int(progress["need"]) if done else int(progress["have"]), int(progress["need"])],
		18, Color(1, 1, 1))
	MistakeView.add_line(lines, _requirement_text(bp), 13, Color(0.78, 0.84, 0.9))
	MistakeView.add_line(lines, bp.flavour_text, 13, Color(0.68, 0.74, 0.82))

	var button := Button.new()
	button.position = Vector2(736, 26)
	button.size = Vector2(180, 44)
	if done:
		button.text = Strings.t("blueprint_done")
		button.disabled = true
	else:
		button.text = Strings.tf("blueprint_claim", {"n": bp.health_gain})
		button.disabled = not claimable
		button.pressed.connect(_on_claim.bind(bp))
	row.add_child(button)
	return row


## Progress counts are per category, so the requirement reads the same way.
func _requirement_text(bp: BlueprintData) -> String:
	var parts: Array[String] = []
	for category: int in bp.required:
		parts.append("%d / %d %s" % [
			mini(int(bp.required[category]), int(Game.correct_by_category.get(category, 0))),
			int(bp.required[category]), Strings.category_name(category)])
	return Strings.tf("blueprint_requires", {"v": ", ".join(parts)})


func _on_claim(bp: BlueprintData) -> void:
	if Game.claim_blueprint(bp.id) == null:
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
