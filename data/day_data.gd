## One day of the run. Everything that makes day 5 harder than day 1 lives here.
class_name DayData
extends Resource

@export var day_number: int = 1
@export var active_rules: Array[RuleData] = []
@export var item_pool: Array[ItemData] = []
@export var quota: int = 5
@export var max_grabs: int = 8
@export var tools_enabled: bool = false
## tool id -> charges for this day. Missing tool = unavailable today.
@export var tool_charges: Dictionary = {}
@export var modifier: String = ""
@export var intro_text: String = ""
