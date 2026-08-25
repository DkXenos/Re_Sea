# four sliders, one Control, used by both the settings screen and the pause
# overlay. all four actually do something.
extends Control

const ROWS: Array = [
	["master", "settings_master"],
	["music", "settings_music"],
	["sfx", "settings_sfx"],
	["vfx", "settings_vfx"],
]

@onready var _list: VBoxContainer = $List


func _ready() -> void:
	for row: Array in ROWS:
		_list.add_child(_make_row(row[0], Strings.t(row[1])))
	_list.add_child(_make_toggle("hotspots", Strings.t("settings_hotspots")))


# accessibility, not difficulty - final art draws the hotspot into the item
func _make_toggle(key: String, label_text: String) -> Control:
	var row := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = label_text
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 19)
	row.add_child(name_label)
	var toggle := CheckButton.new()
	toggle.button_pressed = bool(Game.settings.get(key, true))
	toggle.toggled.connect(func(on: bool) -> void: Game.apply_toggle(key, on))
	row.add_child(toggle)
	return row


func _make_row(key: String, label_text: String) -> Control:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)

	var header := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = label_text
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 19)
	header.add_child(name_label)
	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(70, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(value_label)
	row.add_child(header)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = float(Game.settings.get(key, 0.8))
	slider.custom_minimum_size = Vector2(420, 28)
	value_label.text = "%d%%" % int(round(slider.value * 100.0))
	slider.value_changed.connect(func(v: float) -> void:
		value_label.text = "%d%%" % int(round(v * 100.0))
		# straight through to the bus, then saved to user://settings.cfg
		Game.apply_setting(key, v))
	row.add_child(slider)
	return row
