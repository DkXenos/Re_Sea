# reuses the settings slider panel so volume works mid-run
extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	$Title.text = Strings.t("pause_title")
	var resume: Button = $ResumeButton
	var menu: Button = $MenuButton
	var exit: Button = $ExitButton
	resume.text = Strings.t("pause_resume")
	menu.text = Strings.t("pause_menu")
	exit.text = Strings.t("settings_exit")
	resume.pressed.connect(toggle.bind(false))
	# The tour runs once a launch, and this is the only way back to it without
	# leaving the run - which is what somebody handing the machine to a friend
	# mid-shift actually needs. Not a skip: it asks for MORE tutorial.
	var tour: Button = $TutorialButton
	tour.text = Strings.t("settings_tutorial")
	tour.pressed.connect(func() -> void:
		Events.sfx_requested.emit(&"ui_click")
		Game.replay_tutorial()
		tour.text = Strings.t("settings_tutorial_armed")
		tour.disabled = true
		# the overlay pauses the tree itself, so get out of its way first
		toggle(false))
	# the X is painted into the plate, so the button over it carries no art
	$CloseButton.pressed.connect(toggle.bind(false))
	menu.pressed.connect(func() -> void:
		toggle(false)
		Events.scene_change_requested.emit(&"main_menu"))
	exit.pressed.connect(func() -> void:
		Events.sfx_requested.emit(&"ui_click")
		get_tree().quit())


func toggle(open: bool) -> void:
	visible = open
	get_tree().paused = open
	if open:
		$ResumeButton.grab_focus()
