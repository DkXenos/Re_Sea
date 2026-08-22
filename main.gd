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

@onready var _holder: Node = $SceneHolder

var _current: Node = null
var _current_key: StringName = &""


func _ready() -> void:
	Events.scene_change_requested.connect(_on_scene_change_requested)
	Events.phase_finished.connect(_on_phase_finished)
	_on_scene_change_requested(&"main_menu")


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
	_swap.call_deferred(path)


func _swap(path: String) -> void:
	if is_instance_valid(_current):
		_current.queue_free()
		_holder.remove_child(_current)
		_current = null
	var packed: PackedScene = load(path)
	_current = packed.instantiate()
	_holder.add_child(_current)


func current_key() -> StringName:
	return _current_key
