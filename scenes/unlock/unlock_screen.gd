## Shown once when a blueprint completes (revision 2 §2). It is a reward screen
## and nothing more: name, one plainly worded line, the health it gained, and a
## button back to play.
##
## It sits after the day report rather than mid-shift because the counters only
## move at the report - the desk never tells the player whether a sort was right.
extends Node2D

const CARD_BG := preload("res://assets/ui/panel_slot.png")
## EXPERIMENTAL - revision 2 §5. Delete this line, the marked block in
## _finish(), and scenes/puzzle/, and the feature is gone.
const CALIBRATION_PUZZLE := preload("res://scenes/puzzle/calibration_puzzle.tscn")

@onready var _title: Label = $UiLayer/Root/TitleLabel
@onready var _name: Label = $UiLayer/Root/NameLabel
@onready var _flavour: Label = $UiLayer/Root/FlavourLabel
@onready var _gain: Label = $UiLayer/Root/GainLabel
@onready var _panel_bg: NinePatchRect = $UiLayer/Root/PanelBg
@onready var _choice: Control = $UiLayer/Root/UpgradeChoice
@onready var _cards: HBoxContainer = $UiLayer/Root/UpgradeChoice/Cards
@onready var _next: Button = $UiLayer/Root/NextButton

var blueprint: BlueprintData = null
var _puzzle_shown: bool = false


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
	_build_upgrade_choice()


## Revision 2 §4. Both upgrades unlock with the first blueprint, the player
## takes exactly one, and the other stays locked for the rest of the run. That
## single choice is the whole system - there is no shop and no currency.
##
## Every card shows what it gives AND what it costs, together, so the player is
## never offered a pure improvement.
func _build_upgrade_choice() -> void:
	_choice.visible = Game.upgrade_choice_pending()
	if not _choice.visible:
		return
	# The panel grows to hold the cards; the button waits below them until the
	# player has actually chosen. UI layout, not game-object animation.
	_panel_bg.offset_bottom = 664.0
	_next.offset_top = 610.0
	_next.offset_bottom = 662.0
	_next.disabled = true
	$UiLayer/Root/UpgradeChoice/ChoiceTitle.text = Strings.t("upgrade_choose_title")
	$UiLayer/Root/UpgradeChoice/ChoiceHint.text = Strings.t("upgrade_choose_hint")
	for up: UpgradeData in Game.upgrades:
		_cards.add_child(_make_card(up))


func _make_card(up: UpgradeData) -> Control:
	var card := Control.new()
	card.custom_minimum_size = Vector2(350, 106)

	var bg := NinePatchRect.new()
	bg.texture = CARD_BG
	for side: String in ["left", "top", "right", "bottom"]:
		bg.set("patch_margin_" + side, 24)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.add_child(bg)

	var lines := VBoxContainer.new()
	lines.position = Vector2(14, 8)
	lines.size = Vector2(322, 90)
	lines.add_theme_constant_override("separation", 2)
	card.add_child(lines)
	_add_line(lines, up.display_name, 18, Color(1, 1, 1))
	_add_line(lines, Strings.tf("upgrade_benefit", {"v": up.benefit_text}), 13,
		Color(0.6, 0.92, 0.72))
	_add_line(lines, Strings.tf("upgrade_cost", {"v": up.cost_text}), 13,
		Color(0.95, 0.72, 0.6))

	var button := Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.tooltip_text = Strings.t("upgrade_take")
	button.pressed.connect(_on_upgrade_chosen.bind(up, bg))
	card.add_child(button)
	return card


func _add_line(parent: Node, text: String, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)


func _on_upgrade_chosen(up: UpgradeData, card_bg: NinePatchRect) -> void:
	if Game.chosen_upgrade != &"":
		return
	Game.choose_upgrade(up.id)
	Events.sfx_requested.emit(&"ui_click")
	card_bg.modulate = Color(1.5, 1.5, 1.1)
	for other: Control in _cards.get_children():
		other.modulate.a = 1.0 if other == card_bg.get_parent() else 0.4
	$UiLayer/Root/UpgradeChoice/ChoiceHint.text = Strings.tf("upgrade_chosen",
		{"v": up.display_name})
	_next.disabled = false


func _unhandled_input(event: InputEvent) -> void:
	if _next.disabled:
		return
	if event.is_action_pressed(&"advance"):
		_finish()
		get_viewport().set_input_as_handled()


func _finish() -> void:
	if _next.disabled:
		return
	# --- revision 2 §5 (EXPERIMENTAL), the only call site ---
	if Game.feature_calibration_puzzle and blueprint != null and not _puzzle_shown:
		_puzzle_shown = true
		var puzzle: CanvasLayer = CALIBRATION_PUZZLE.instantiate()
		if puzzle.setup(blueprint.id):
			puzzle.finished.connect(_finish)
			add_child(puzzle)
			return
		puzzle.free()
	# --- end §5 ---
	Events.phase_finished.emit()
