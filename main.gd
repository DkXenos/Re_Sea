## Root scene switcher. A plain Node - this project is 2D only and main.tscn
## never renders anything itself. Scenes are addressed by key through Events,
## so no scene ever holds a path to another scene.
extends Node

const SCENES: Dictionary = {
	&"main_menu": "res://scenes/main_menu/main_menu.tscn",
	&"settings": "res://scenes/settings/settings.tscn",
	&"cutscene": "res://scenes/cutscene/cutscene.tscn",
	&"day_start": "res://scenes/day_start/day_start.tscn",
	&"claw": "res://scenes/claw/claw_phase.tscn",
	&"desk": "res://scenes/desk/desk_phase.tscn",
	&"report": "res://scenes/report/day_report.tscn",
	&"game_over": "res://scenes/game_over/game_over.tscn",
}

## Pausing only makes sense inside a run; on the menu and in the cutscene Esc
## already means something else.
const PAUSABLE_KEYS: Array[StringName] = [&"day_start", &"claw", &"desk", &"report"]

@onready var _holder: Node = $SceneHolder
@onready var _pause: Control = $PauseLayer/PauseOverlay
@onready var _debug: Control = $DebugLayer/DebugOverlay
@onready var _pause_button: TextureButton = $PauseLayer/PauseButton

var _current: Node = null
var _current_key: StringName = &""


func _ready() -> void:
	Events.scene_change_requested.connect(_on_scene_change_requested)
	Events.phase_finished.connect(_on_phase_finished)
	Events.debug_command.connect(_on_debug_command)
	# Every action has to be reachable by mouse - the competition build gets
	# demoed by strangers who will not read a control list.
	_pause_button.pressed.connect(func() -> void: _pause.toggle(not _pause.visible))
	_on_scene_change_requested(&"main_menu")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and _current_key in PAUSABLE_KEYS:
		_pause.toggle(not _pause.visible)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"debug_overlay") and OS.is_debug_build():
		if is_instance_valid(_debug):
			_debug.toggle(not _debug.visible)
			get_viewport().set_input_as_handled()


## Only the commands that need the scene tree land here; the rest are handled
## by Game, which owns the state they touch.
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
	_pause_button.visible = scene_key in PAUSABLE_KEYS
	_swap.call_deferred(path)


func _swap(path: String) -> void:
	# A scene change always leaves the tree unpaused, whatever paused it.
	get_tree().paused = false
	if is_instance_valid(_pause):
		_pause.visible = false
	if is_instance_valid(_current):
		_holder.remove_child(_current)
		_current.queue_free()
		_current = null
	var packed: PackedScene = load(path)
	_current = packed.instantiate()
	_holder.add_child(_current)


func current_key() -> StringName:
	return _current_key
