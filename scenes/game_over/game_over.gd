## One scene for both endings: the ocean meter decides which. Losing means the
## meter bottomed out; surviving all five days is the win.
extends Node2D


func _ready() -> void:
	var lost := Game.is_game_over()
	var root := $UiLayer/Root
	root.get_node("TitleLabel").text = Strings.t("over_title") if lost else Strings.t("win_title")
	root.get_node("BodyLabel").text = Strings.t("over_body") if lost \
		else Strings.tf("win_body", {"n": Game.ocean_health})
	var retry: Button = root.get_node("Buttons/RetryButton")
	var menu: Button = root.get_node("Buttons/MenuButton")
	retry.text = Strings.t("over_retry")
	menu.text = Strings.t("over_menu")
	retry.pressed.connect(func() -> void:
		Events.sfx_requested.emit(&"ui_click")
		Game.start_run()
		Events.scene_change_requested.emit(&"day_start"))
	menu.pressed.connect(func() -> void:
		Events.sfx_requested.emit(&"ui_click")
		Events.scene_change_requested.emit(&"main_menu"))
	retry.grab_focus()
	Events.sfx_requested.emit(&"day_end")
