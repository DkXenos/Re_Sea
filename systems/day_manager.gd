# flow graph. kept out of main.gd so that stays a plain scene switcher.
# menu -> cutscene -> day_start -> shift -> report -> after_day -> day_start...
class_name DayManager
extends RefCounted


static func advance_from(key: StringName) -> StringName:
	match key:
		&"main_menu": return &"cutscene"
		&"cutscene": return &"day_start"
		&"day_start": return &"shift"
		&"shift": return &"report"
		&"report": return &"after_day"
		&"after_day": return _after_day()
	return &"main_menu"


# same scene for win and lose, it reads ocean_health to work out which
static func _after_day() -> StringName:
	if Game.is_game_over() or Game.is_last_day():
		return &"game_over"
	Game.advance_day()
	return &"day_start"
