## F1 debug overlay, active only in debug builds. Iteration speed is the single
## biggest factor in how good this prototype gets, so this is not optional
## scaffolding - it is the difference between testing day 5 in ten seconds and
## replaying four days to get there.
##
## Everything here goes out as an Events.debug_command so no debug code has to
## live inside the game scenes.
extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if not OS.is_debug_build():
		queue_free()
		return
	_build()


func toggle(open: bool) -> void:
	visible = open
	if open:
		_refresh_seed()


func _build() -> void:
	var list: VBoxContainer = $Panel/List
	_button(list, "Skip to next day", func() -> void: Events.debug_command.emit(&"skip_day", null))
	_button(list, "Refill shift budget",
		func() -> void: Events.debug_command.emit(&"refill_budget", null))
	_button(list, "Reveal all on current item",
		func() -> void: Events.debug_command.emit(&"reveal_all", null))
	_button(list, "Fill inventory with 6 items",
		func() -> void: Events.debug_command.emit(&"fill_inventory", 6))
	_button(list, "Grip: always succeed",
		func() -> void: Events.debug_command.emit(&"force_grip", 1))
	_button(list, "Grip: always fail",
		func() -> void: Events.debug_command.emit(&"force_grip", -1))
	_button(list, "Toggle hotspot rings",
		func() -> void: Events.debug_command.emit(&"toggle_hotspots", null))
	_button(list, "Grip: roll normally",
		func() -> void: Events.debug_command.emit(&"force_grip", 0))

	var health_row := HBoxContainer.new()
	var health_field := LineEdit.new()
	health_field.placeholder_text = "ocean health 0-100"
	health_field.custom_minimum_size = Vector2(180, 0)
	health_row.add_child(health_field)
	var health_apply := Button.new()
	health_apply.text = "Set"
	health_apply.pressed.connect(func() -> void:
		Events.debug_command.emit(&"set_health", int(health_field.text)))
	health_row.add_child(health_apply)
	list.add_child(health_row)

	var seed_row := HBoxContainer.new()
	var seed_field: LineEdit = LineEdit.new()
	seed_field.name = "SeedField"
	seed_field.custom_minimum_size = Vector2(180, 0)
	seed_row.add_child(seed_field)
	var seed_apply := Button.new()
	seed_apply.text = "Set seed"
	seed_apply.pressed.connect(func() -> void:
		Events.debug_command.emit(&"set_seed", int(seed_field.text)))
	seed_row.add_child(seed_apply)
	list.add_child(seed_row)
	_refresh_seed()


func _refresh_seed() -> void:
	var field: LineEdit = $Panel/List.find_child("SeedField", true, false)
	if field != null:
		field.text = str(Game.run_seed)


func _button(parent: Node, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	parent.add_child(button)
