## One day of the run. Everything that makes day 5 harder than day 1 lives here.
##
## Revision 1 replaced `max_grabs` and per-tool `tool_charges` with a single
## `budget`: one shift, spent by actions. See Game.ACTION_COST.
class_name DayData
extends Resource

@export var day_number: int = 1
@export var active_rules: Array[RuleData] = []
@export var item_pool: Array[ItemData] = []
@export var quota: int = 5

## The whole shift, spent by dropping the claw, using tools and sorting. Not a
## clock: nothing here ticks in real time.
@export var budget: int = 90

## Which tools exist today. Empty means the desk has no tools at all, which is
## how day 1 stays a surface-info tutorial without a tutorial system.
@export var available_tools: Array[StringName] = []

# --- how the seabed fills up over the shift (revision 1 §4) ---
## Fraction of the pool already resting on the seabed when the shift opens.
## Never start empty.
@export_range(0.0, 1.0) var initial_seed_fraction: float = 0.4
@export var spawn_interval_min: float = 3.0
@export var spawn_interval_max: float = 6.5
## If fewer than this are in the tank, the next item arrives immediately. The
## player must never have a reason to sit and wait.
@export var min_available_items: int = 4

@export var modifier: String = ""
@export var intro_text: String = ""


func tools_enabled() -> bool:
	return not available_tools.is_empty()
