# grid of what the claw brought up. built off Game.unsorted_items().
extends Control

signal item_selected(entry: CarriedItem)

# the card's whole layout - size, padding, icon, font sizes - is the scene's,
# so it is dragged in the editor instead of typed here
const CARD := preload("res://scenes/desk/item_card.tscn")


@onready var _grid: GridContainer = $Scroll/Grid
@onready var _title: Label = $Title
@onready var _empty: Label = $Empty

var _selected: CarriedItem = null
# every card on screen, so picking a different item can repaint the two that
# changed instead of rebuilding the list. Rebuilding from inside a card's own
# `pressed` would free the button that is still emitting.
var _cards: Array[Control] = []


func _ready() -> void:
	_title.text = Strings.t("desk_inventory")
	_empty.text = Strings.t("desk_empty")


func refresh() -> void:
	_clear(_grid)
	_cards.clear()
	var entries := Game.unsorted_items()
	_empty.visible = entries.is_empty()
	for entry: CarriedItem in entries:
		var card: Control = CARD.instantiate()
		_grid.add_child(card)
		card.setup(entry)
		card.set_selected(entry == _selected)
		card.pressed_card.connect(_on_card_pressed)
		_cards.append(card)


func _on_card_pressed(entry: CarriedItem) -> void:
	_selected = entry
	# without this the plate stayed on whatever was picked first
	_apply_selection()
	Events.sfx_requested.emit(&"ui_click")
	item_selected.emit(entry)


func _apply_selection() -> void:
	for card: Control in _cards:
		card.set_selected(card.entry == _selected)


# whatever is next to deal with. a sealed crate counts: it is not sortable,
# but cutting it open is the work.
func select_first() -> void:
	var entries := Game.unsorted_items()
	_selected = entries[0] if not entries.is_empty() else null
	refresh()
	item_selected.emit(_selected)


# same deal as the other panels, queue_free isn't enough on its own
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
