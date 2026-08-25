# item + today's rules -> the correct bin. highest priority match wins, and if
# nothing matches the item's own correct_category stands.
class_name RuleChecker
extends RefCounted


# rule key -> the field the player has to reveal to know it. not always the
# same name: is_multilayer comes from cutting the thing open.
const RULE_KEY_TO_REVEAL: Dictionary = {
	"has_residue": "has_residue",
	"residue_type": "residue_type",
	"true_material": "true_material",
	"is_multilayer": "true_material",
	"tag_text": "tag_text",
}

# readable for free
const SURFACE_KEYS: Array[String] = ["visible_material", "visible_label", "weight",
	"correct_category", "source_batch", "display_name"]


# {"category": int, "rule": RuleData or null}
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


# surface conditions come back as "" since they cost nothing to know
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


# rule matches AND the player actually uncovered what it keys on
static func evidence_supports(entry: CarriedItem, rule: RuleData) -> bool:
	if not rule.matches(entry.data):
		return false
	for field: String in required_fields(rule):
		if field != "" and not entry.is_revealed(field):
			return false
	return true


static func supported_rules(entry: CarriedItem, rules: Array[RuleData]) -> Array[RuleData]:
	var out: Array[RuleData] = []
	for rule: RuleData in rules:
		if rule != null and evidence_supports(entry, rule):
			out.append(rule)
	out.sort_custom(func(a: RuleData, b: RuleData) -> bool: return a.priority < b.priority)
	return out


# writes the verdict onto the entry so the report can explain it later
static func judge(entry: CarriedItem, chosen: int, rules: Array[RuleData]) -> bool:
	var verdict := resolve(entry.data, rules)
	entry.expected_category = int(verdict["category"])
	entry.broken_rule = verdict["rule"]
	entry.sorted_to = chosen
	entry.was_correct = chosen == entry.expected_category
	return entry.was_correct
