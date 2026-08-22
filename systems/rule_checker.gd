## Turns an item plus the day's active rules into the one correct bin.
##
## Every rule that matches is collected and the highest priority wins, so a
## later rule can override an earlier one. If nothing matches, the item's own
## correct_category stands - that base value is what the item is made of, and
## the rules are what the facility does about it today. This is why day 5 can
## make aluminium recyclable again with a .tres and no code change.
class_name RuleChecker
extends RefCounted


## Returns {"category": int, "rule": RuleData or null}
static func resolve(item: ItemData, rules: Array[RuleData]) -> Dictionary:
	var category: int = item.correct_category
	var winner: RuleData = null
	for rule: RuleData in rules:
		if rule == null or not rule.matches(item):
			continue
		if winner == null or rule.priority >= winner.priority:
			winner = rule
			category = rule.forces_category
	return {"category": category, "rule": winner}


## Records the verdict on the carried entry so the day report can explain it.
static func judge(entry: CarriedItem, chosen: int, rules: Array[RuleData]) -> bool:
	var verdict := resolve(entry.data, rules)
	entry.expected_category = int(verdict["category"])
	entry.broken_rule = verdict["rule"]
	entry.sorted_to = chosen
	entry.was_correct = chosen == entry.expected_category
	return entry.was_correct
