## Turns an item plus the day's active rules into the one correct bin.
##
## Every rule that matches is collected and the highest priority wins, so a
## later rule can override an earlier one. If nothing matches, the item's own
## correct_category stands - that base value is what the item is made of, and
## the rules are what the facility does about it today. This is why day 5 can
## make aluminium recyclable again with a .tres and no code change.
class_name RuleChecker
extends RefCounted


## A rule keys off an ItemData property, but the player learns that property by
## revealing a field, and the two are not always the same name: is_multilayer is
## learned by cutting the item open, which reveals true_material.
const RULE_KEY_TO_REVEAL: Dictionary = {
	"has_residue": "has_residue",
	"residue_type": "residue_type",
	"true_material": "true_material",
	"is_multilayer": "true_material",
	"tag_text": "tag_text",
}

## Properties the player can read for free, so a rule keyed on one of these is
## satisfied the moment it matches.
const SURFACE_KEYS: Array[String] = ["visible_material", "visible_label", "weight",
	"correct_category", "source_batch", "display_name"]


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


## Which reveal each of a rule's conditions depends on. Surface conditions map
## to "" because they cost nothing to know.
static func required_fields(rule: RuleData) -> Array[String]:
	var out: Array[String] = []
	for key: String in rule.applies_when:
		if key in SURFACE_KEYS:
			out.append("")
		elif RULE_KEY_TO_REVEAL.has(key):
			out.append(RULE_KEY_TO_REVEAL[key])
		else:
			out.append(key)
	return out


## True when the rule matches this item AND the player has actually uncovered
## everything it keys on. This is what lets the panel light up the evidence the
## player has earned, without giving away what they have not looked at.
static func evidence_supports(entry: CarriedItem, rule: RuleData) -> bool:
	if not rule.matches(entry.data):
		return false
	for field: String in required_fields(rule):
		if field != "" and not entry.is_revealed(field):
			return false
	return true


## Rules the player has proved apply, highest priority last.
static func supported_rules(entry: CarriedItem, rules: Array[RuleData]) -> Array[RuleData]:
	var out: Array[RuleData] = []
	for rule: RuleData in rules:
		if rule != null and evidence_supports(entry, rule):
			out.append(rule)
	out.sort_custom(func(a: RuleData, b: RuleData) -> bool: return a.priority < b.priority)
	return out


## Records the verdict on the carried entry so the day report can explain it.
static func judge(entry: CarriedItem, chosen: int, rules: Array[RuleData]) -> bool:
	var verdict := resolve(entry.data, rules)
	entry.expected_category = int(verdict["category"])
	entry.broken_rule = verdict["rule"]
	entry.sorted_to = chosen
	entry.was_correct = chosen == entry.expected_category
	return entry.was_correct
