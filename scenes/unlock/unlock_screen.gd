## Shown once when a blueprint completes (revision 2 §2). It is a reward screen
## and nothing more: name, one plainly worded line, the health it gained, and a
## button back to play.
##
## It sits after the day report rather than mid-shift because the counters only
## move at the report - the desk never tells the player whether a sort was right.
extends Node2D

@onready var _title: Label = $UiLayer/Root/TitleLabel
@onready var _name: Label = $UiLayer/Root/NameLabel
@onready var _flavour: Label = $UiLayer/Root/FlavourLabel
@onready var _gain: Label = $UiLayer/Root/GainLabel
@onready var _next: Button = $UiLayer/Root/NextButton

var blueprint: BlueprintData = null


func _ready() -> void:
	blueprint = Game.claim_unlock()
	_title.text = Strings.t("blueprint_unlocked_title")
	_next.text = Strings.t("blueprint_continue")
	_next.pressed.connect(_finish)
	if blueprint == null:
		# Nothing to show - this scene was reached without a pending unlock.
		_finish()
		return
	_name.text = blueprint.display_name
	_flavour.text = blueprint.flavour_text
	_gain.text = Strings.tf("blueprint_health_gain", {"n": blueprint.health_gain})
	Events.sfx_requested.emit(&"day_end")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"advance"):
		_finish()
		get_viewport().set_input_as_handled()


func _finish() -> void:
	Events.phase_finished.emit()
