## A permanent change to how the shift works, unlocked by progress and never
## bought with currency (revision 2 §4). There is no money system anywhere.
##
## Every upgrade must be a genuine TRADE-OFF. One that only makes things easier
## would make the last day flatter than the first, which is exactly the boredom
## this revision exists to prevent - so both fields below are filled in, always.
class_name UpgradeData
extends Resource

@export var id: StringName
@export var display_name: String
## What it gives, and what it costs. Both plainly worded, both shown together
## on the choice screen so the player is never sold a pure improvement.
@export var benefit_text: String
@export var cost_text: String

## Action-cost overrides, or -1 to leave the cost alone.
@export var drop_cost: int = -1
@export var tool_cost: int = -1
## Added to every item's grip chance. Negative is the cost of a cheaper claw.
@export var grip_delta: float = 0.0
## A tool use only reports THAT something is here, not what. The exact reading
## needs a second use at the normal cost.
@export var coarse_readings: bool = false
## Multiplies how fast the claw travels along its rail.
@export var move_speed_multiplier: float = 1.0
## Seconds the rail needs to re-engage after a cycle before it will move again.
## Not a clock and not pressure: nothing is spent while it runs, and thinking,
## panning and reading stay free. It is a delay the player chose to take on.
@export var post_drop_lockout: float = 0.0

## How many blueprints must be claimed before this is available. 0 means it is
## on the table from day 1 - two of the four are, deliberately, so the system is
## testable immediately.
@export var unlock_after_blueprints: int = 0
## Shown on a locked upgrade so the player knows what opens it.
@export var unlock_text: String = ""

@export var sort_order: int = 0


## Which way each field cuts. This lives on the resource rather than in the
## check that reads it, so adding a fifth upgrade is still a .tres - and the
## one place that has to be taught about a genuinely new KIND of effect is
## here, beside the field itself.
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


## An upgrade that only makes things easier makes the last day flatter than the
## first. Every one of them has to give something up.
func is_trade_off(base_drop: int, base_tool: int) -> bool:
	return has_benefit(base_drop, base_tool) and has_cost(base_drop, base_tool)
