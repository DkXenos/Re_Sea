## A sorting rule. Rules are evaluated by priority so a later, higher-priority
## rule can override an earlier one - that is how difficulty grows with zero
## new code.
class_name RuleData
extends Resource

@export var id: StringName
@export var text: String ## shown verbatim in the rulebook
## Property name on ItemData -> required value. An Array value means "any of".
## e.g. {"has_residue": true}
@export var applies_when: Dictionary = {}
@export var forces_category: ItemData.Category
@export var priority: int = 0 ## higher wins on conflict

func matches(item: ItemData) -> bool:
	for key: String in applies_when:
		var expected: Variant = applies_when[key]
		var actual: Variant = item.get(key)
		if actual == null:
			return false
		if expected is Array:
			if not (actual in expected):
				return false
		elif actual != expected:
			return false
	return true
