## The flow graph, kept out of main.gd so the scene switcher stays a switcher.
## Advancing the day is a deliberate state change made here, in one place.
##
##   main_menu -> cutscene -> day_start -> claw -> desk -> report
##                                            ^                |
##                                            +-- next day ----+
class_name DayManager
extends RefCounted


static func advance_from(key: StringName) -> StringName:
	match key:
		&"main_menu": return &"cutscene"
		&"cutscene": return &"day_start"
		&"day_start": return &"claw"
		&"claw": return &"desk"
		&"desk": return &"report"
		&"report":
			# The ocean bottoming out ends the run immediately; otherwise the
			# run ends after the last day. Both land on the same scene, which
			# reads Game.ocean_health to decide whether it is a loss or a win.
			if Game.is_game_over() or Game.is_last_day():
				return &"game_over"
			Game.advance_day()
			return &"day_start"
	return &"main_menu"
