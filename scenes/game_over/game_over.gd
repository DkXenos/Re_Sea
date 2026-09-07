# four endings, one per machine built - nothing else feeds into it.
extends Node2D


func _ready() -> void:
	var tier := Game.ending_tier()
	var root := $UiLayer/Root
	$StillLayer/Still.texture = load(Game.ending_still())
	root.get_node("TitleLabel").text = Strings.t("end_%d_title" % tier)
	root.get_node("BodyLabel").text = Strings.t("end_%d_body" % tier)
	root.get_node("BuiltLabel").text = Strings.tf("end_built",
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
