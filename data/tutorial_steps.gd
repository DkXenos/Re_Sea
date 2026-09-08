# What the tutorial points at, in order. Two segments: the cockpit runs when
# the shift opens, the desk runs the first time you switch over to it.
#
# A step is:
#   key      - the Strings key stem. "tut_<key>_title" and "tut_<key>_body".
#   targets  - node paths under the shift scene. The spotlight is the union of
#              their rects, so a readout and the plate it sits on can be lit
#              together. Empty = no hole, the screen just dims and the caption
#              sits in the middle.
#   rect     - overrides `targets` when the thing worth pointing at is painted
#              into the background and has no node of its own.
#   pad      - breathing room around that rect.
#   radius   - corner rounding. Half the short side or more reads as a circle.
#
# Adding a step is an entry here plus its two lines in Strings. Nothing else
# knows how many steps there are.
class_name TutorialSteps
extends RefCounted

const CLAW: Array = [
	{"key": "claw_intro", "targets": []},
	# the calendar is background art, the label is only the number on it
	{"key": "claw_day", "rect": Rect2(24, 138, 160, 148), "pad": 8.0, "radius": 16.0},
	# same again: the meter plate is painted, so light the whole plate
	{"key": "claw_power", "rect": Rect2(22, 412, 152, 122), "pad": 8.0, "radius": 16.0},
	{"key": "claw_cost", "rect": Rect2(1118, 424, 132, 122), "pad": 8.0, "radius": 16.0},
	{"key": "claw_quota", "rect": Rect2(1118, 222, 132, 112), "pad": 8.0, "radius": 16.0},
	{"key": "claw_move", "targets": [
		"ClawView/ConsoleLayer/ArrowLeft", "ClawView/ConsoleLayer/ArrowRight"],
		"pad": 10.0, "radius": 24.0},
	{"key": "claw_grab", "targets": ["ClawView/ConsoleLayer/GrabButton"],
		"pad": 10.0, "radius": 70.0},
	{"key": "claw_sorting", "targets": ["ClawView/ConsoleLayer/SortingButton"],
		"pad": 8.0, "radius": 20.0},
]

const DESK: Array = [
	{"key": "desk_intro", "targets": []},
	{"key": "desk_inventory", "targets": ["DeskView/UiLayer/Root/InventoryPanel"],
		"pad": 16.0, "radius": 22.0},
	{"key": "desk_item", "targets": [
		"DeskView/UiLayer/Root/InspectPanel/NameLabel",
		"DeskView/UiLayer/Root/InspectPanel/ViewportBox"], "pad": 10.0, "radius": 18.0},
	{"key": "desk_tools", "targets": ["DeskView/UiLayer/Root/InspectPanel/RackFrame"],
		"pad": 8.0, "radius": 18.0},
	{"key": "desk_outcome", "targets": [
		"DeskView/UiLayer/Root/InspectPanel/EvidenceTitle",
		"DeskView/UiLayer/Root/InspectPanel/EvidenceScroll"], "pad": 10.0, "radius": 16.0},
	{"key": "desk_rules", "targets": [
		"DeskView/UiLayer/Root/InspectPanel/RulesTitle",
		"DeskView/UiLayer/Root/InspectPanel/RulesList"], "pad": 10.0, "radius": 16.0},
	{"key": "desk_rulebook", "targets": ["DeskView/UiLayer/Root/RulebookButton"],
		"pad": 10.0, "radius": 26.0},
	{"key": "desk_bins", "targets": ["DeskView/UiLayer/Root/BinRow"],
		"pad": 10.0, "radius": 20.0},
	{"key": "desk_commit", "targets": ["DeskView/UiLayer/Root/BinRow"],
		"pad": 10.0, "radius": 20.0},
	{"key": "desk_blueprints", "targets": ["DeskView/UiLayer/Root/BlueprintPanel"],
		"pad": 10.0, "radius": 18.0},
	{"key": "desk_end", "targets": []},
]


static func segment(name: StringName) -> Array:
	match name:
		&"claw": return CLAW
		&"desk": return DESK
	return []
