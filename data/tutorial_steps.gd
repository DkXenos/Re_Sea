# What the tutorial points at, in order. Two segments: the cockpit runs when
# the shift opens, the desk runs the first time you switch over to it.
#
# A step is:
#   key      - the Strings key stem. "tut_<key>_title" and "tut_<key>_body".
#   wait_for - an Events.tutorial_action_performed name. A step carrying one
#              does not advance on a click: the caption's Next button goes away
#              and the tour sits there until the player performs that action on
#              the lit control for real. Everything else stays frozen, so the
#              only thing they can do is the thing being asked for.
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


# The end-of-day screen. Two tabs that do completely different jobs - one
# reads today's books, the other spends what they paid out - and a player who
# only ever sees the one that opens by default never learns the run has a goal.
# So the two halves are separated by the one step that makes them press the
# tab themselves; being made to do it once is what makes it a place they know
# how to get back to.
const AFTER_DAY: Array = [
	{"key": "after_intro", "targets": ["UiLayer/Root/TitleLabel"],
		"pad": 12.0, "radius": 14.0},
	{"key": "after_missed", "targets": [
		"UiLayer/Root/ResultPage/MistakesTitle",
		"UiLayer/Root/ResultPage/MistakesScroll"], "pad": 12.0, "radius": 18.0},
	{"key": "after_recovered", "targets": [
		"UiLayer/Root/ResultPage/RecoveredTitle",
		"UiLayer/Root/ResultPage/Recovered"], "pad": 12.0, "radius": 18.0},
	{"key": "after_summary", "targets": ["UiLayer/Root/ResultPage/Summary"],
		"pad": 12.0, "radius": 14.0},
	# the one step the player has to answer with a press
	{"key": "after_switch", "targets": ["UiLayer/Root/Tabs/TechTab"],
		"pad": 10.0, "radius": 18.0, "wait_for": &"after_tab_tech"},
	{"key": "after_tech_sheet", "targets": [
		"UiLayer/Root/TechPage/BlueprintName",
		"UiLayer/Root/TechPage/Diagram"], "pad": 12.0, "radius": 18.0},
	{"key": "after_tech_paging", "targets": [
		"UiLayer/Root/TechPage/PrevButton",
		"UiLayer/Root/TechPage/NextButton"], "pad": 10.0, "radius": 18.0},
	{"key": "after_tech_parts", "targets": [
		"UiLayer/Root/TechPage/PartsLabel",
		"UiLayer/Root/TechPage/PartsScroll"], "pad": 12.0, "radius": 18.0},
	{"key": "after_tech_pool", "targets": ["UiLayer/Root/TechPage/PoolLabel"],
		"pad": 10.0, "radius": 14.0},
	{"key": "after_tech_build", "targets": [
		"UiLayer/Root/TechPage/CraftButton",
		"UiLayer/Root/TechPage/Unlocks"], "pad": 12.0, "radius": 18.0},
	{"key": "after_next", "targets": ["UiLayer/Root/NextButton"],
		"pad": 10.0, "radius": 20.0},
]


static func segment(name: StringName) -> Array:
	match name:
		&"claw": return CLAW
		&"desk": return DESK
		&"after_day": return AFTER_DAY
	return []
