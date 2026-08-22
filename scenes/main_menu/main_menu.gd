## Title screen. Play starts a fresh run and hands control to the flow graph.
extends Node2D


func _ready() -> void:
	$UiLayer/Root/Subtitle.text = Strings.t("game_subtitle")
	$UiLayer/Root/Hint.text = Strings.t("menu_hint")
	var play: Button = $UiLayer/Root/Buttons/PlayButton
	var settings: Button = $UiLayer/Root/Buttons/SettingsButton
	var quit: Button = $UiLayer/Root/Buttons/QuitButton
	play.text = Strings.t("menu_play")
	settings.text = Strings.t("menu_settings")
	quit.text = Strings.t("menu_quit")
	play.pressed.connect(_start)
	settings.pressed.connect(func() -> void:
		Events.sfx_requested.emit(&"ui_click")
		Events.scene_change_requested.emit(&"settings"))
	quit.pressed.connect(func() -> void: get_tree().quit())
	play.grab_focus()


func _start() -> void:
	Events.sfx_requested.emit(&"ui_click")
	Game.start_run()
	Events.phase_finished.emit()
