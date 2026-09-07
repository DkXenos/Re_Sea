# A splash, not a menu. There is nothing to press: click or press Enter to
# start, Esc for the settings screen. Volume also lives in the pause overlay,
# which is reachable from every screen inside a run.
extends Node2D

## Nothing on this screen ever moves on its own, which made a still title card
## look like a loading error. The bay breathes very slowly and the logo rides
## on it. Both are small enough that you read them as "alive", not "animated".
const BREATH_TIME := 9.0
const BREATH_SCALE := 1.03
const BOB_TIME := 2.6
const BOB_PIXELS := 7.0


func _ready() -> void:
	$UiLayer/Root/Hint.text = Strings.t("menu_hint")
	_breathe($BgLayer/Bg, BREATH_SCALE, BREATH_TIME)
	_bob($UiLayer/Root/Logo, BOB_PIXELS, BOB_TIME)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		Events.sfx_requested.emit(&"ui_click")
		Events.scene_change_requested.emit(&"settings")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"advance"):
		_start()
		get_viewport().set_input_as_handled()


func _start() -> void:
	Events.sfx_requested.emit(&"ui_click")
	Game.start_run()
	Events.phase_finished.emit()


func _breathe(node: Control, amount: float, seconds: float) -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(node, "scale", Vector2.ONE * amount, seconds) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, seconds) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _bob(node: Control, pixels: float, seconds: float) -> void:
	var home := node.position
	var tween := create_tween().set_loops()
	tween.tween_property(node, "position", home + Vector2(0, -pixels), seconds) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position", home, seconds) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
