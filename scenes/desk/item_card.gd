# One card in the desk inventory grid. Every position, size and font here lives
# in item_card.tscn so the layout is dragged in the editor, not typed in code.
extends Control

signal pressed_card(entry: CarriedItem)

# selected is a separate png, not a tint
const SLOT_BG := preload("res://assets/ui/panel_slot.png")
const SLOT_BG_SELECTED := preload("res://assets/ui/panel_slot_selected.png")

## Hint colour when the crate has an opener on the rack.
@export var hint_color: Color = Color(0.72, 0.78, 0.85)
## Hint colour when nothing on the rack can open it.
@export var hint_blocked_color: Color = Color(0.95, 0.72, 0.6)

@onready var _bg: NinePatchRect = $Bg
@onready var _icon: TextureRect = $Columns/Icon
@onready var _name: Label = $Columns/Lines/NameLabel
@onready var _hint: Label = $Columns/Lines/HintLabel
@onready var _hit: Button = $Hit

var entry: CarriedItem = null


func _ready() -> void:
	_hit.pressed.connect(func() -> void: pressed_card.emit(entry))


func setup(item: CarriedItem) -> void:
	entry = item
	_icon.texture = item.display_texture()
	_name.text = item.data.display_name

	# a sealed crate has no bin and no evidence - the only thing you can do to
	# it is cut it, so the card says which tool does that
	var sealed := item.is_container() and not item.opened
	_hint.visible = sealed
	if sealed:
		var opener := Game.container_opener()
		_hint.text = Strings.t("box_no_tool") if opener == null \
			else Strings.tf("box_needs_tool", {"tool": opener.display_name})
		_hint.add_theme_color_override("font_color",
			hint_color if opener != null else hint_blocked_color)


## One drawing per state, so this swaps the png rather than tinting one.
func set_selected(on: bool) -> void:
	_bg.texture = SLOT_BG_SELECTED if on else SLOT_BG
