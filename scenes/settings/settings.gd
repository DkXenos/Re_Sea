extends Node2D


func _ready() -> void:
	$UiLayer/Root/TitleLabel.text = Strings.t("settings_title")
	# the X is painted into the plate, so the button over it carries no art
	$UiLayer/Root/CloseButton.pressed.connect(_to_menu)
	# The tour runs once on a machine and never again, which is right for the
	# player it was written for and wrong for everybody after them - the second
	# person to sit down at this laptop, and anyone playtesting. This is the way
	# back to it. It is not a skip: pressing it asks for MORE tutorial.
	var tour: Button = $UiLayer/Root/TutorialButton
	tour.text = Strings.t("settings_tutorial")
	tour.pressed.connect(func() -> void:
		Events.sfx_requested.emit(&"ui_click")
		Game.replay_tutorial()
		# say it landed - the tour itself only shows up on the next shift
		tour.text = Strings.t("settings_tutorial_armed")
		tour.disabled = true)

	var back: Button = $UiLayer/Root/BackButton
	back.text = Strings.t("settings_menu")
	back.pressed.connect(_to_menu)
	var exit: Button = $UiLayer/Root/ExitButton
	exit.text = Strings.t("settings_exit")
	exit.pressed.connect(func() -> void:
		Events.sfx_requested.emit(&"ui_click")
		get_tree().quit())


func _to_menu() -> void:
	Events.sfx_requested.emit(&"ui_click")
	Events.scene_change_requested.emit(&"main_menu")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		Events.scene_change_requested.emit(&"main_menu")
		get_viewport().set_input_as_handled()
