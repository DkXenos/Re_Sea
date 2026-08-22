## Pause overlay on layer 200. It embeds the same slider panel the settings
## screen uses, so volume can be changed mid-run without unloading the scene
## the player is standing in.
extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	$Title.text = Strings.t("pause_title")
	var resume: Button = $ResumeButton
	var menu: Button = $MenuButton
	resume.text = Strings.t("pause_resume")
	menu.text = Strings.t("pause_menu")
	resume.pressed.connect(toggle.bind(false))
	menu.pressed.connect(func() -> void:
		toggle(false)
		Events.scene_change_requested.emit(&"main_menu"))


func toggle(open: bool) -> void:
	visible = open
	get_tree().paused = open
	if open:
		$ResumeButton.grab_focus()
