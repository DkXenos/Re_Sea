## The grid of everything the claw brought up today. Cards are built from
## Game.unsorted_items() so nothing here knows how items got into the tank.
extends Control

signal item_selected(entry: CarriedItem)

const SLOT_BG := preload("res://assets/ui/panel_slot.png")
## Selection is a different PNG, not a tint on the plain one (rev 3 §1.4).
const SLOT_BG_SELECTED := preload("res://assets/ui/panel_slot_selected.png")

## The box is authored at 160x160 like every item and read at 64x64 on its card.
## One named constant, quoted in ASSETS.md, the way the other three display
## scales are (rev 3 §1.5).
const BOX_CARD_SCALE := 0.4
## How long the opened crate is on screen before the card fades, and how long
## the fade takes. UI feedback only - revision 4 §1 allows a fade on the card
## and on nothing in the tank.
const OPEN_HOLD := 0.35
const OPEN_FADE := 0.35

@onready var _grid: GridContainer = $Scroll/Grid
@onready var _title: Label = $Title
@onready var _empty: Label = $Empty

var _selected: CarriedItem = null


func _ready() -> void:
	_title.text = Strings.t("desk_inventory")
	_empty.text = Strings.t("desk_empty")


func refresh() -> void:
	_clear(_grid)
	var entries := Game.unsorted_items()
	_empty.visible = entries.is_empty()
	for entry: CarriedItem in entries:
		_grid.add_child(_make_box_card(entry) if entry.is_container()
			else _make_card(entry))


func _make_card(entry: CarriedItem) -> Control:
	var card := Control.new()
	card.custom_minimum_size = Vector2(250, 84)

	var bg := NinePatchRect.new()
	# Selection is a different PNG, not a tint (rev 3 §1.4).
	bg.texture = SLOT_BG_SELECTED if entry == _selected else SLOT_BG
	for side: String in ["left", "top", "right", "bottom"]:
		bg.set("patch_margin_" + side, 24)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(bg)

	# The icon and the text live in a container. Setting a Label's size by hand
	# does not survive contact with the layout: it kept one line and ran off the
	# card, so a three-word property line was cut mid-word.
	var columns := HBoxContainer.new()
	columns.set_anchors_preset(Control.PRESET_FULL_RECT)
	columns.offset_left = 8
	columns.offset_top = 8
	columns.offset_right = -10
	columns.offset_bottom = -8
	columns.add_theme_constant_override("separation", 8)
	columns.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(columns)

	var icon := TextureRect.new()
	icon.texture = entry.data.texture
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	columns.add_child(icon)

	# Revision 2 §3: an item names itself only once the player has earned the
	# name. Until then the card lists what can be observed, so choosing what to
	# inspect is a judgement about properties rather than a look-up by label.
	var known := entry.name_known()
	var label := Label.new()
	label.text = entry.label()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14 if known else 12)
	if not known:
		label.add_theme_color_override("font_color", Color(0.78, 0.84, 0.9))
	columns.add_child(label)

	# Invisible hit area; the visible card is the PNG panel plus the item PNG.
	var button := Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(func() -> void:
		_selected = entry
		Events.sfx_requested.emit(&"ui_click")
		item_selected.emit(entry))
	card.add_child(button)
	return card


## A sealed box (revision 4 §2). It is a card like any other, but it has no bin
## buttons and no inspect tools: its one interaction is Buka.
##
## The crate is an AnimatedSprite2D from the start, playing `closed` and then
## `opened`, so the two states are two drawings and the designers add frames
## without touching this scene. Nothing here tints anything.
func _make_box_card(entry: CarriedItem) -> Control:
	var card := Control.new()
	card.custom_minimum_size = Vector2(250, 84)

	var bg := NinePatchRect.new()
	bg.texture = SLOT_BG
	for side: String in ["left", "top", "right", "bottom"]:
		bg.set("patch_margin_" + side, 24)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(bg)

	var crate := AnimatedSprite2D.new()
	crate.sprite_frames = entry.data.frames
	crate.play(&"closed")
	crate.scale = Vector2.ONE * BOX_CARD_SCALE
	crate.position = Vector2(42, 42)
	card.add_child(crate)

	var label := Label.new()
	label.text = entry.data.display_name
	label.position = Vector2(80, 10)
	label.size = Vector2(84, 64)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 13)
	card.add_child(label)

	var button := Button.new()
	button.text = Strings.t("box_open")
	button.tooltip_text = Strings.t("box_sealed")
	button.position = Vector2(170, 22)
	button.size = Vector2(70, 40)
	button.pressed.connect(_on_open_pressed.bind(entry, card, crate, button))
	card.add_child(button)
	return card


## Buka. The crate swaps to its opened drawing, the card fades out, and the
## contents take its place in the list.
##
## The state change hangs off a SceneTree timer rather than off the tween: the
## panel rebuilds itself whenever the player switches back to the desk, and a
## tween whose target had been freed would leave the box open on screen and
## unopened in the inventory.
func _on_open_pressed(entry: CarriedItem, card: Control, crate: AnimatedSprite2D,
		button: Button) -> void:
	if entry.opened:
		return
	button.disabled = true
	crate.play(&"opened")
	Events.sfx_requested.emit(&"bin_accept")
	var fade := create_tween()
	fade.tween_interval(OPEN_HOLD)
	fade.tween_property(card, "modulate:a", 0.0, OPEN_FADE)
	get_tree().create_timer(OPEN_HOLD + OPEN_FADE).timeout.connect(
		_finish_open.bind(entry))


func _finish_open(entry: CarriedItem) -> void:
	var contents := Game.open_container(entry)
	if not contents.is_empty():
		Events.toast_requested.emit(
			Strings.tf("box_opened_toast", {"n": contents.size()}))
	refresh()
	if _selected == null:
		select_first()


## The first thing a bin would actually take. A sealed box sits in the list but
## can never be sorted, so the desk never opens on one.
func select_first() -> void:
	var entries := Game.sortable_items()
	_selected = entries[0] if not entries.is_empty() else null
	refresh()
	item_selected.emit(_selected)


## queue_free() alone leaves the old children in the tree for the rest of the
## frame, so a list rebuilt twice in one frame would briefly show both sets.
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
