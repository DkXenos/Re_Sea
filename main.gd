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

# The pointer is drawn art like everything else on screen. It is set once here
# because it belongs to the whole game rather than to any scene, and Input
# keeps it until something else takes it off.
#
# A custom cursor is handed to the OS at the png's own pixel size - it does not
# scale with the game's 1280x720 or with the display, so cursor.png is
# installed at the size it is meant to appear at and nothing here resizes it.
const CURSOR := preload("res://assets/ui/cursor.png")
# the point of the arrow inside its own drawing
const CURSOR_HOTSPOT := Vector2(1, 0)

@onready var _holder: Node = $SceneHolder
@onready var _pause: Control = $PauseLayer/PauseOverlay
@onready var _debug: Control = $DebugLayer/DebugOverlay
@onready var _tutorial: Control = $TutorialLayer/TutorialOverlay

var _current: Node = null
var _current_key: StringName = &""


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR, Input.CURSOR_ARROW, CURSOR_HOTSPOT)
	Events.scene_change_requested.connect(_on_scene_change_requested)
	Events.phase_finished.connect(_on_phase_finished)
	Events.debug_command.connect(_on_debug_command)
	# the cockpit and the desk each draw their own cog, and ask for this overlay.
	# there is no floating pause button any more - it was a placeholder icon
	# that landed on top of the desk's own cog.
	Events.pause_requested.connect(func() -> void: _pause.toggle(not _pause.visible))
	_on_scene_change_requested(&"main_menu")


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
