# catches UI that overlaps or escapes its box.
#
# wrote this after finding three versions of the same bug on one screen: the
# desk sitting under a shift bar that had got taller, a ninepatch drawing its
# corners over each other, and three progress bars stuck at the png's full
# 320x32 painting over the rulebook button. nothing crashed, it was just
# unreadable, so a normal headless run caught none of it.
#   godot --headless --script tests/smoke_layout.gd
extends SceneTree

# everything above this is the shift bar, drawn over the views
const BAR_BOTTOM := 74.0
const VIEWPORT := Vector2(1280.0, 720.0)

var game: Node
var failures: int = 0


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	game.start_run(4242)
	for i in 3:
		game.advance_day()

	await _check_desk()
	await _check_desk_text_fits()
	await _check_after_day()
	assert(failures == 0, "%d layout problem(s) - see above" % failures)
	print("layout verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


# Wrapped text that needs more height than its box has does not clip - Godot
# draws it straight out the bottom, over whatever is underneath. The MADE OF
# chip on a laminated cup did exactly that, through the plate it sits on and
# over the tool feedback below it.
#
# Item text lives in .tres files and every message here takes a substitution, so
# how tall any of this ends up is not something reading the scene can tell you.
# This asks the screen instead: every item, every field a tool can reveal, every
# message the panel can print, on every day - and fails on anything that needs
# more room than it was given.
func _check_desk_text_fits() -> void:
	var phase: Node = load("res://scenes/desk/desk_phase.tscn").instantiate()
	root.add_child(phase)
	for i in 3:
		await process_frame
	var inspect: Control = phase.get_node("UiLayer/Root/InspectPanel")
	var feedback: Label = inspect.get_node("Feedback")

	for file: String in DirAccess.get_files_at("res://data/items"):
		if not file.ends_with(".tres"):
			continue
		var item: ItemData = load("res://data/items/" + file)
		game.budget_left = game.budget_max
		var carried = game.add_to_inventory(item)
		for field: String in ["is_stained", "stain_type", "stain_hazardous",
				"true_material"]:
			carried.reveal(field)
		inspect.show_entry(carried)
		for i in 3:
			await process_frame

		for named: String in ["NameLabel", "Question", "RulesTitle", "EvidenceTitle"]:
			var label: Label = inspect.get_node(named)
			_check_text_fits(label, label.size.y, "%s on %s" % [named, item.id])
		# A chip's label is anchored to the plate, but an anchored Control is
		# still grown to its own minimum size - so an overlong chip does not
		# clip, it draws a 60px label through a 32px plate. Measuring the label
		# against itself always passes; the plate under it is the real bound.
		for chip: Control in inspect.get_node("EvidenceScroll/EvidenceLog").get_children():
			_check_text_fits(chip.get_child(0) as Label, chip.size.y,
				"evidence chip on %s" % item.id)

		# the transient line under the log, in every shape it can take. the
		# reveal one carries item text, so it is the one that grows.
		for key: String in ["inspect_found", "inspect_coarse", "inspect_nothing",
				"rinse_clean", "rinse_hazard", "rinse_none"]:
			var args := {"n": 4, "v": item.get_field_text("true_material")}
			inspect._set_feedback(Strings.tf(key, args), Color.WHITE)
			await process_frame
			_check_text_fits(feedback, feedback.size.y, "%s on %s" % [key, item.id])
			# it is capped at max_lines_visible so it can never spill onto the
			# desk art below the panel - but a cap silently eats the shift-time
			# cost off the end, so anything that hits it is still a failure
			if feedback.get_line_count() > feedback.max_lines_visible:
				_fail("%s on %s wraps to %d lines and is trimmed at %d: \"%s\""
					% [key, item.id, feedback.get_line_count(),
					feedback.max_lines_visible, feedback.text])

	root.remove_child(phase)
	phase.free()
	await process_frame


func _check_text_fits(label: Label, available: float, what: String) -> void:
	if label.text.strip_edges().is_empty():
		return
	var needed: int = label.get_line_count() * label.get_line_height()
	if float(needed) > available + 1.0:
		_fail("%s needs %dpx of text in a %.0fpx box - it will draw outside it: \"%s\""
			% [what, needed, available, label.text])


func _fail(message: String) -> void:
	failures += 1
	printerr("  LAYOUT: %s" % message)


func _rect(c: Control) -> Rect2:
	return Rect2(c.global_position, c.size)


# two controls that both draw must not sit on top of each other
func _check_no_overlap(a: Control, b: Control, label: String) -> void:
	if _rect(a).intersects(_rect(b)):
		_fail("%s overlap: %s vs %s" % [label, _rect(a), _rect(b)])


# everything that draws stays inside the box it was given. clip_contents is
# the one exception - that's how both progress meters are filled.
func _check_contained(parent: Control, label: String) -> void:
	if parent.clip_contents:
		return
	var bounds := _rect(parent)
	for child: Node in parent.get_children():
		if not (child is Control):
			continue
		var c := child as Control
		if not c.visible:
			continue
		if not bounds.encloses(_rect(c)):
			_fail("%s: %s escapes its box %s with %s" % [label, c.name, bounds, _rect(c)])
		_check_contained(c, label)


func _check_desk() -> void:
	for item: ItemData in game.current_day().item_pool:
		game.add_to_inventory(item)
	# box card is laid out by hand instead of by a container, exactly the kind
	# of thing this check is for
	if game.current_day().box_item != null:
		game.add_to_inventory(game.current_day().box_item)
	var desk: Node = load("res://scenes/desk/desk_phase.tscn").instantiate()
	root.add_child(desk)
	for i in 20:
		await process_frame

	var ui: Control = desk.get_node("UiLayer/Root")
	var named: Array[String] = ["RulebookButton", "BlueprintPanel", "InventoryPanel",
		"InspectPanel", "BinRow"]

	# Nothing on the desk may hide under the shift bar, and nothing may run off
	# the bottom of the screen.
	for name: String in named:
		var c: Control = ui.get_node(name)
		if c.global_position.y < BAR_BOTTOM:
			_fail("%s starts at y=%.0f, under the shift bar (%.0f)"
				% [name, c.global_position.y, BAR_BOTTOM])
		if _rect(c).end.y > VIEWPORT.y or _rect(c).end.x > VIEWPORT.x:
			_fail("%s runs off screen: %s" % [name, _rect(c)])

	# The header row is the one that broke: the strip grew past the panel it was
	# given and painted over the button beside it.
	_check_no_overlap(ui.get_node("BlueprintPanel"), ui.get_node("RulebookButton"),
		"blueprint strip / rulebook button")
	_check_contained(ui.get_node("BlueprintPanel"), "blueprint strip")
	_check_contained(ui.get_node("InspectPanel"), "inspect panel")

	# The item has to be identified on screen somehow, by name or by property.
	var inspect: Control = ui.get_node("InspectPanel")
	var inventory: Control = ui.get_node("InventoryPanel")
	inventory.select_first()
	await process_frame
	var heading: Label = inspect.get_node("NameLabel")
	if heading.text.strip_edges().is_empty():
		_fail("the inspect panel names nothing at all")
	else:
		print("  desk heading reads: %s" % heading.text)

	root.remove_child(desk)
	desk.free()
	await process_frame


func _check_after_day() -> void:
	var scene: Node = load("res://scenes/after_day/after_day.tscn").instantiate()
	root.add_child(scene)
	for i in 20:
		await process_frame
	var ui: Control = scene.get_node("UiLayer/Root")
	var pages: Array[String] = ["ResultPage", "TechPage"]
	for tab in pages.size():
		scene._show_tab(tab)
		await process_frame
		_check_contained(ui.get_node(pages[tab]), "after-day tab %d" % tab)
	_check_no_overlap(ui.get_node("Tabs"), ui.get_node("PageBg"), "tabs / page")
	print("  after-day tabs stay inside their pages")
	root.remove_child(scene)
	scene.free()
	await process_frame
