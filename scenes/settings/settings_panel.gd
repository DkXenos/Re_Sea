# the two volume sliders, one Control, used by both the settings screen and the
# pause overlay. both actually do something.
#
# Master and VFX are still real settings in Game - they are just not on this
# panel any more. The bed music and the sea ambience both sit on the Music bus,
# so "Music" here is the one BGM control.
extends Control

const ROWS: Array = [
	["music", "settings_music"],
	["sfx", "settings_sfx"],
]

# the slider track art is 32px tall, so a shorter row would crop it
const SLIDER_SIZE := Vector2(420, 34)

# The theme's Label colour is near-white, which is right over the dark panels
# and unreadable on the bright blue settings plate this panel now sits on.
const ON_PLATE := Color(0.05, 0.11, 0.32)

@onready var _list: VBoxContainer = $List


func _ready() -> void:
	for row: Array in ROWS:
		_list.add_child(_make_row(row[0], Strings.t(row[1])))


func _make_row(key: String, label_text: String) -> Control:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)

	var header := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = label_text
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 19)
	name_label.add_theme_color_override("font_color", ON_PLATE)
	header.add_child(name_label)
	var value_label := Label.new()
	value_label.add_theme_color_override("font_color", ON_PLATE)
	value_label.custom_minimum_size = Vector2(70, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(value_label)
	row.add_child(header)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = float(Game.settings.get(key, 0.8))
	slider.custom_minimum_size = SLIDER_SIZE
	value_label.text = "%d%%" % int(round(slider.value * 100.0))
	slider.value_changed.connect(func(v: float) -> void:
		value_label.text = "%d%%" % int(round(v * 100.0))
		# straight through to the bus, then saved to user://settings.cfg
		Game.apply_setting(key, v))
	row.add_child(slider)
	return row
