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

# --- sealed boxes (revision 4 §2) ---
## The container resource this day spawns, or null for none. A day with a box
## item but a count of 0 simply spawns none, which is how day 1 stays a clean
## tutorial.
@export var box_item: ItemData
@export var box_spawn_count: int = 0
## How many items come out of one box. Contents may repeat.
@export var box_contents_min: int = 2
@export var box_contents_max: int = 3

@export var modifier: String = ""
@export var intro_text: String = ""


func tools_enabled() -> bool:
	return not available_tools.is_empty()


## What drifts in today: the day's items, plus its sealed boxes. A box is
## grabbed exactly like anything else, so it simply joins the pool the tank
## already spawns from - the tank never learns what a box is.
func spawn_pool() -> Array[ItemData]:
	var out: Array[ItemData] = item_pool.duplicate()
	if box_item == null:
		return out
	for i in maxi(0, box_spawn_count):
		out.append(box_item)
	return out


## What a box may contain. Filtering containers out HERE is the only thing that
## stops a box ever containing another box, and it holds for any container a
## later day adds without a line of code changing.
func content_pool() -> Array[ItemData]:
	var out: Array[ItemData] = []
	for entry: ItemData in item_pool:
		if not entry.is_container:
			out.append(entry)
	return out


## How many items this box yields, clamped so bad data can never produce zero.
func contents_count(stream: RandomNumberGenerator) -> int:
	var low: int = maxi(1, box_contents_min)
	return stream.randi_range(low, maxi(low, box_contents_max))
