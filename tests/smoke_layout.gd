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
	await _check_after_day()
	assert(failures == 0, "%d layout problem(s) - see above" % failures)
	print("layout verified")

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


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
