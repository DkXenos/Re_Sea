# three endings, decided by how many machines were built - nothing else.
extends Node2D


func _ready() -> void:
	var kind := Game.ending_kind()
	var root := $UiLayer/Root
	root.get_node("TitleLabel").text = Strings.t("end_%s_title" % kind)
	root.get_node("BodyLabel").text = Strings.tf("end_%s_body" % kind,
		{"have": Game.unlocked_blueprints.size(), "need": Game.blueprints.size()})
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
