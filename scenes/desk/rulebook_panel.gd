# open any time, pauses nothing. the challenge is hidden properties, not
# remembering rules. also holds the PET/HDPE/PS glossary since nobody who
# hasn't sorted waste before knows what those mean.
extends Control

@onready var _title: Label = $Title
@onready var _list: VBoxContainer = $Scroll/List
@onready var _close: Button = $CloseButton


func _ready() -> void:
	_title.text = Strings.t("rulebook_title")
	_close.text = Strings.t("rulebook_close")
	_close.pressed.connect(toggle.bind(false))
	visible = false


func toggle(open: bool) -> void:
	visible = open
	if open:
		_rebuild()
	Events.rulebook_toggled.emit(open)


func _rebuild() -> void:
	_clear(_list)
	var day := Game.current_day()
	if day == null or day.active_rules.is_empty():
		_add_line(Strings.t("rulebook_empty"), 18, Color(0.7, 0.75, 0.8))
		_add_glossary()
		return
	# grouped by forced bin, rulebook-only ones go under UMUM
	var groups: Dictionary = {}
	for rule: RuleData in day.active_rules:
		var key: String = Strings.t("rulebook_general") if rule.applies_when.is_empty() \
			else Strings.category_name(rule.forces_category)
		if not groups.has(key):
			groups[key] = []
		groups[key].append(rule)
	for group_name: String in groups:
		_add_line(group_name, 21, Color(0.95, 0.83, 0.42))
		for rule: RuleData in groups[group_name]:
			_add_line("-  " + rule.text, 17, Color(0.86, 0.91, 0.95))
		_add_line("", 8, Color.WHITE)
	_add_glossary()


# what the codes on the items mean
func _add_glossary() -> void:
	_add_line(Strings.t("rulebook_codes"), 21, Color(0.95, 0.83, 0.42))
	_add_line(Strings.t("rulebook_codes_note"), 15, Color(0.72, 0.78, 0.85))
	for entry: Array in Strings.CODES:
		_add_line("%s  -  %s" % [entry[0], entry[1]], 16, Color(0.86, 0.91, 0.95))


func _add_line(text: String, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	_list.add_child(label)


# see the other panels
func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
