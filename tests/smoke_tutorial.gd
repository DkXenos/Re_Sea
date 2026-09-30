# The guided tour, and in particular the one step that is not narration.
#
# Every other step is read-and-click, so the only thing that can break is a
# string key or a node path that got renamed out from under it - both checked
# here for all three segments. The end-of-day tour also has an interactive
# step, which suspends the two things that make the tour safe: it stops eating
# clicks and it thaws a control while the tree is paused. If that step ever
# stops being answerable the player is stuck on a dimmed screen with no way
# out, so it is checked from both sides - that the right control comes alive,
# and that nothing else does.
#   godot --headless --script tests/smoke_tutorial.gd
extends SceneTree

var failures: int = 0


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	var events: Node = root.get_node("/root/Events")
	game.start_run(777)

	_check_strings()
	_check_still_armed_at_the_end_of_the_day(game, events)
	await _check_after_day_tour(events)

	print("tutorial: %d problem(s)" % failures)
	assert(failures == 0, "%d tutorial problem(s) - see above" % failures)
	quit()


func _fail(message: String) -> void:
	failures += 1
	print("  FAIL  %s" % message)


# a step with no caption is a step that shows the raw key to the player
func _check_strings() -> void:
	for segment: StringName in [&"claw", &"desk", &"after_day"]:
		var steps: Array = TutorialSteps.segment(segment)
		if steps.is_empty():
			_fail("segment %s is empty" % segment)
		for step: Dictionary in steps:
			for suffix: String in ["title", "body"]:
				var key := "tut_%s_%s" % [str(step["key"]), suffix]
				if not Strings.TABLE.has(key):
					_fail("%s: no string %s" % [segment, key])
	print("tour steps: claw %d | desk %d | after_day %d" % [
		TutorialSteps.segment(&"claw").size(),
		TutorialSteps.segment(&"desk").size(),
		TutorialSteps.segment(&"after_day").size()])


# The end-of-day screen is reached AFTER the cockpit and the desk, so the flag
# that switches the tour off must not drop when those two are done. It used to,
# and adding a segment behind them without adding it to that tally is a silent
# way of never showing it.
func _check_still_armed_at_the_end_of_the_day(game: Node, events: Node) -> void:
	game.tutorial_shown_this_launch = false
	game.tutorial_active = true
	game.tutorial_seen = {}
	for segment: StringName in [&"claw", &"desk"]:
		if not game.request_tutorial(segment):
			_fail("segment %s was refused on a fresh run" % segment)
		events.tutorial_segment_finished.emit()
	if not game.tutorial_active:
		_fail("the tour switched itself off before the end-of-day screen")
	if not game.request_tutorial(&"after_day"):
		_fail("the end-of-day screen never gets its tour")
	events.tutorial_segment_finished.emit()
	if game.tutorial_active:
		_fail("the tour never finishes - it will replay on the next run")
	# and a second run in the same sitting is not sat through it again
	game.tutorial_active = not game.tutorial_shown_this_launch
	if game.tutorial_active:
		_fail("a retry in the same launch replays the whole tour")


func _check_after_day_tour(events: Node) -> void:
	var scene: Node = load("res://scenes/after_day/after_day.tscn").instantiate()
	root.add_child(scene)
	for i in 4:
		await process_frame

	var steps: Array = TutorialSteps.segment(&"after_day")
	var waiting_steps: Array = []
	for step: Dictionary in steps:
		# a spotlight that resolves to nothing dims the screen and points at
		# nowhere, which reads as the tour being broken
		for path: String in step.get("targets", []):
			if not scene.has_node(path):
				_fail("after_day step %s points at a missing node: %s"
					% [str(step["key"]), path])
		if step.has("wait_for"):
			waiting_steps.append(step)
	if waiting_steps.size() != 1:
		_fail("expected exactly 1 interactive step, found %d" % waiting_steps.size())

	var overlay: Control = load("res://scenes/tutorial/tutorial_overlay.tscn").instantiate()
	root.add_child(overlay)
	overlay.set_scene_root(scene)
	events.tutorial_requested.emit(&"after_day")
	for i in 4:
		await process_frame
	if not overlay.visible:
		_fail("the after_day tour did not open")
	if not paused:
		_fail("the tour left the tree running")

	# walk up to the interactive step
	var wait_index: int = steps.find(waiting_steps[0])
	while overlay._index < wait_index:
		overlay._advance()
		await process_frame

	var tab: Button = scene.get_node("UiLayer/Root/Tabs/TechTab")
	var elsewhere: Button = scene.get_node("UiLayer/Root/NextButton")
	if overlay.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("the overlay is still swallowing the click the step asks for")
	if overlay._next.visible:
		_fail("the Next button is still there, so the step can be skipped")
	if not tab.can_process():
		_fail("the tab being asked for cannot answer while the tree is paused")
	if elsewhere.can_process():
		_fail("Start-the-Next-Day is live during the tour - the screen is not frozen")

	# only the awaited action moves it on
	var before: int = overlay._index
	events.tutorial_action_performed.emit(&"after_tab_result")
	await process_frame
	if overlay._index != before:
		_fail("an unrelated action advanced the tour")

	# A synthesised mouse click cannot be used here: a headless viewport does no
	# GUI picking at all, so push_input lands on nothing and would pass whatever
	# the overlay did. What actually decides whether the player's click arrives
	# is the three conditions checked just above - overlay transparent, target
	# thawed, everything else frozen - so those are the test, and this only
	# stands in for the press itself.
	tab.emit_signal("pressed")
	await process_frame
	if overlay._index != before + 1:
		_fail("pressing the tab did not advance the tour")
	if scene._tab != 1:
		_fail("pressing the tab did not open the Technology page")
	if overlay.mouse_filter != Control.MOUSE_FILTER_STOP:
		_fail("the overlay never went back to blocking clicks")
	if not overlay._next.visible:
		_fail("the Next button never came back")
	if tab.process_mode != Node.PROCESS_MODE_INHERIT:
		_fail("the thawed tab was left running after the step")

	# and the rest of it still runs to the end
	var guard: int = 0
	while overlay.visible and guard < 40:
		overlay._advance()
		await process_frame
		guard += 1
	if overlay.visible:
		_fail("the tour never finished")
	if paused:
		_fail("the tour left the tree paused")
	scene.queue_free()
	overlay.queue_free()
	await process_frame
