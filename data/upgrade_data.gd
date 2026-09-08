class_name UpgradeData
extends Resource

# What a finished machine bolts onto the claw.
#
# There is no fitting and no choosing any more: a machine that has been built
# is running, and what it does to the claw is on from that moment to the end of
# the run. Several are on at once by the end, so every field here has to
# combine with the same field on another upgrade - Game.active_upgrades and the
# getters under it are where that happens.
@export var id: StringName
@export var display_name: String
# one line, in the player's terms. the blueprint sheet shows it.
@export var benefit_text: String

# -1 = leave the action cost alone
@export var drop_cost: int = -1
@export var tool_cost: int = -1
@export var grip_delta: float = 0.0
@export var move_speed_multiplier: float = 1.0

# The two ways an upgrade can make something WORSE. Nothing sets them any more:
# a machine you built out of five days of sorting should not hand you a
# drawback. The claw and the desk still honour them, so the fields stay
# authorable - a future machine could trade something away on purpose, and
# smoke_upgrades.gd is what would have to be told that is allowed.
@export var coarse_readings: bool = false  ## tool only reports THAT something is there
@export var post_drop_lockout: float = 0.0  ## rail frozen for this long after a drop

@export var sort_order: int = 0


## Does this actually improve anything? An upgrade that changes nothing is a
## reward that reads as a bug.
func has_benefit(base_drop: int, base_tool: int) -> bool:
	return (drop_cost >= 0 and drop_cost < base_drop) \
		or (tool_cost >= 0 and tool_cost < base_tool) \
		or grip_delta > 0.0 \
		or move_speed_multiplier > 1.0


## ...and does it take anything away? See the note on the two fields above.
func has_cost(base_drop: int, base_tool: int) -> bool:
	return drop_cost > base_drop \
		or tool_cost > base_tool \
		or grip_delta < 0.0 \
		or coarse_readings \
		or post_drop_lockout > 0.0 \
		or move_speed_multiplier < 1.0
