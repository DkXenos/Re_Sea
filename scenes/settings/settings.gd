## Settings screen, reachable from the main menu. The same slider panel is
## embedded in the pause overlay, so there is one implementation.
extends Node2D


func _ready() -> void:
	$UiLayer/Root/TitleLabel.text = Strings.t("settings_title")
	var back: Button = $UiLayer/Root/BackButton
	back.text = Strings.t("settings_back")
	back.pressed.connect(func() -> void:
		Events.sfx_requested.emit(&"ui_click")
		Events.scene_change_requested.emit(&"main_menu"))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		Events.scene_change_requested.emit(&"main_menu")
		get_viewport().set_input_as_handled()
