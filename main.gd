# scene switcher. scenes are addressed by key through Events so nothing holds
# a path to anything else.
extends Node

const SCENES: Dictionary = {
	&"main_menu": "res://scenes/main_menu/main_menu.tscn",
	&"settings": "res://scenes/settings/settings.tscn",
	&"cutscene": "res://scenes/cutscene/cutscene.tscn",
	&"day_start": "res://scenes/day_start/day_start.tscn",
	&"shift": "res://scenes/shift/shift_phase.tscn",
	&"after_day": "res://scenes/after_day/after_day.tscn",
	&"game_over": "res://scenes/game_over/game_over.tscn",
}

# esc means something else on the menu / in the cutscene
const PAUSABLE_KEYS: Array[StringName] = [&"day_start", &"shift", &"after_day"]

# The pointer is drawn art like everything else on screen. It is set here
# because it belongs to the whole game rather than to any scene, and Input
# keeps it until something else takes it off.
#
# It is also the one drawing the canvas_items stretch cannot reach: the OS
# draws the cursor itself, at the png's own pixel size, whatever the window is
# doing. cursor.png is drawn for the same 1280x720 as the rest of the art, so
# in a smaller window it was the only thing that did not shrink with it and it
# read as enormous. _fit_cursor puts the delivered drawing back in step with
# the window, which is the same move _fit_scale makes for the tank backdrop.
const CURSOR := preload("res://assets/ui/cursor.png")
# the point of the arrow inside its own drawing, in the png's own pixels
const CURSOR_HOTSPOT := Vector2(1, 0)
# a cursor past this is refused and the player is left with no pointer at all
const CURSOR_MAX_PX := 256.0

@onready var _holder: Node = $SceneHolder
@onready var _pause: Control = $PauseLayer/PauseOverlay
@onready var _debug: Control = $DebugLayer/DebugOverlay
@onready var _tutorial: Control = $TutorialLayer/TutorialOverlay

var _current: Node = null
var _current_key: StringName = &""


func _ready() -> void:
	get_window().size_changed.connect(_fit_cursor)
	_fit_cursor()
	Events.scene_change_requested.connect(_on_scene_change_requested)
	Events.phase_finished.connect(_on_phase_finished)
	Events.debug_command.connect(_on_debug_command)
	# the cockpit and the desk each draw their own cog, and ask for this overlay.
	# there is no floating pause button any more - it was a placeholder icon
	# that landed on top of the desk's own cog.
	Events.pause_requested.connect(func() -> void: _pause.toggle(not _pause.visible))
	_on_scene_change_requested(&"main_menu")


# Godot is asked what the stretch actually came out as rather than that being
# worked out again from the window size here - the letterboxing rounds, and a
# second copy of that sum is a second thing to keep in step with the aspect
# setting.
#
# The OS then measures the cursor in points rather than pixels, so on a 2x
# retina screen it paints a 42px drawing across 84 of them. That doubling is on
# top of the stretch and it is what made the pointer enormous, so it is taken
# back out here: screen_get_scale is exactly the pixels-per-point the cursor is
# about to be drawn at, and it reports 1.0 on the platforms that have no such
# notion. Both together are what keeps the pointer the size of the art it is
# standing on, in a window of any size on a display of any density.
func _fit_cursor() -> void:
	var factor: float = get_window().get_final_transform().get_scale().x
	# minimised, or between modes: no window to fit anything to yet
	if factor <= 0.0:
		return
	factor /= maxf(DisplayServer.screen_get_scale(
		DisplayServer.window_get_current_screen()), 1.0)
	factor = minf(factor, CURSOR_MAX_PX / maxf(CURSOR.get_width(), CURSOR.get_height()))
	if is_equal_approx(factor, 1.0):
		Input.set_custom_mouse_cursor(CURSOR, Input.CURSOR_ARROW, CURSOR_HOTSPOT)
		return
	var image := Image.new()
	image.copy_from(CURSOR.get_image())
	image.resize(maxi(1, int(round(CURSOR.get_width() * factor))),
		maxi(1, int(round(CURSOR.get_height() * factor))), Image.INTERPOLATE_LANCZOS)
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(image),
		Input.CURSOR_ARROW, CURSOR_HOTSPOT * factor)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and _current_key in PAUSABLE_KEYS:
		_pause.toggle(not _pause.visible)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"debug_overlay") and OS.is_debug_build():
		if is_instance_valid(_debug):
			_debug.toggle(not _debug.visible)
			get_viewport().set_input_as_handled()


# only the ones that need the tree, Game handles the rest
func _on_debug_command(command: StringName, _arg: Variant) -> void:
	if command != &"skip_day":
		return
	_pause.toggle(false)
	if Game.is_last_day():
		Events.scene_change_requested.emit(&"game_over")
		return
	Game.advance_day()
	_on_scene_change_requested(&"day_start")


func _on_phase_finished() -> void:
	_on_scene_change_requested(DayManager.advance_from(_current_key))


func _on_scene_change_requested(scene_key: StringName) -> void:
	if not SCENES.has(scene_key):
		push_warning("Unknown scene key: %s" % scene_key)
		return
	var path: String = SCENES[scene_key]
	if not ResourceLoader.exists(path):
		print("[Main] scene not built yet: %s" % path)
		return
	_current_key = scene_key
	#print("[Main] -> ", scene_key)
	_swap.call_deferred(path)


func _swap(path: String) -> void:
	# always unpause, whatever paused it
	get_tree().paused = false
	if is_instance_valid(_pause):
		_pause.visible = false
	# a tour that was still running belonged to the screen we just left
	if is_instance_valid(_tutorial):
		_tutorial.cancel()
	if is_instance_valid(_current):
		_holder.remove_child(_current)
		_current.queue_free()
		_current = null
	var packed: PackedScene = load(path)
	_current = packed.instantiate()
	_holder.add_child(_current)
	# the tour resolves its node paths against whatever is on screen, so it has
	# to be handed the new scene before any of it asks for a segment
	_tutorial.set_scene_root(_current)


func current_key() -> StringName:
	return _current_key
