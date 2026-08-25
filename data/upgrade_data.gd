class_name UpgradeData
extends Resource

@export var id: StringName
@export var display_name: String
# both shown together so nobody gets sold a pure improvement
@export var benefit_text: String
@export var cost_text: String

# -1 = leave the action cost alone
@export var drop_cost: int = -1
@export var tool_cost: int = -1
@export var grip_delta: float = 0.0
# tool only reports THAT something is there. exact reading costs a 2nd use.
@export var coarse_readings: bool = false
@export var move_speed_multiplier: float = 1.0
@export var post_drop_lockout: float = 0.0

@export var unlock_after_blueprints: int = 0
@export var unlock_text: String = ""

@export var sort_order: int = 0


# which way each field cuts. add a new KIND of effect and you have to touch
# these two, everything else is just a .tres
func has_benefit(base_drop: int, base_tool: int) -> bool:
	return (drop_cost >= 0 and drop_cost < base_drop) \
		or (tool_cost >= 0 and tool_cost < base_tool) \
		or grip_delta > 0.0 \
		or move_speed_multiplier > 1.0


func has_cost(base_drop: int, base_tool: int) -> bool:
	return drop_cost > base_drop \
		or tool_cost > base_tool \
		or grip_delta < 0.0 \
		or coarse_readings \
		or post_drop_lockout > 0.0 \
		or move_speed_multiplier < 1.0


func is_trade_off(base_drop: int, base_tool: int) -> bool:
	return has_benefit(base_drop, base_tool) and has_cost(base_drop, base_tool)
