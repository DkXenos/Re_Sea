## The flow graph, kept out of main.gd so the scene switcher stays a switcher.
## Advancing the day is a deliberate state change made here, in one place.
##
##   main_menu -> cutscene -> day_start -> shift -> report -> [unlock] ...
##                                  ^                             |
##                                  +---------- next day ---------+
##
## Revision 2 inserted `unlock`: a blueprint that completed at the report gets
## one screen each before the next day starts.
##
## Revision 1 collapsed `claw` and `desk` into one `shift`: they are sibling
## views inside it, switchable at any time, sharing one budget and one
## inventory. They are no longer phases and no longer appear here.
class_name DayManager
extends RefCounted


static func advance_from(key: StringName) -> StringName:
	match key:
		&"main_menu": return &"cutscene"
		&"cutscene": return &"day_start"
		&"day_start": return &"shift"
		&"shift": return &"report"
		&"report", &"unlock": return _after_report()
	return &"main_menu"


## Every completed blueprint gets its own screen, then the run continues. The
## ocean bottoming out ends the run immediately; otherwise the run ends after
## the last day. Both land on the same scene, which reads Game.ocean_health to
## decide whether it is a loss or a win.
static func _after_report() -> StringName:
	if Game.has_pending_unlock():
		return &"unlock"
	if Game.is_game_over() or Game.is_last_day():
		return &"game_over"
	Game.advance_day()
	return &"day_start"
