class_name DayData
extends Resource

@export var day_number: int = 1
@export var active_rules: Array[RuleData] = []
@export var item_pool: Array[ItemData] = []
@export var quota: int = 5

# whole shift. spent by actions, nothing ticks in real time.
@export var budget: int = 90

# empty = desk has no tools today
@export var available_tools: Array[StringName] = []

# how the seabed fills up over the shift
@export_range(0.0, 1.0) var initial_seed_fraction: float = 0.4
@export var spawn_interval_min: float = 3.0
@export var spawn_interval_max: float = 6.5
# below this, next item comes in immediately. don't make people wait.
@export var min_available_items: int = 4

@export var box_item: ItemData
@export var box_spawn_count: int = 0
@export var box_contents_min: int = 2
@export var box_contents_max: int = 3

@export var intro_text: String = ""


func tools_enabled() -> bool:
	return not available_tools.is_empty()


func spawn_pool() -> Array[ItemData]:
	var out: Array[ItemData] = item_pool.duplicate()
	if box_item == null:
		return out
	for i in maxi(0, box_spawn_count):
		out.append(box_item)
	return out


# filtering containers out here is the only thing stopping box-inside-a-box
func content_pool() -> Array[ItemData]:
	var out: Array[ItemData] = []
	for entry: ItemData in item_pool:
		if not entry.is_container:
			out.append(entry)
	return out


func contents_count(stream: RandomNumberGenerator) -> int:
	var low: int = maxi(1, box_contents_min)
	return stream.randi_range(low, maxi(low, box_contents_max))
