## A sorting rule. Rules are evaluated by priority so a later, higher-priority
## rule can override an earlier one - that is how difficulty grows with zero
## new code.
class_name RuleData
extends Resource

@export var id: StringName
@export var text: String ## shown verbatim in the rulebook
## Compact form for the always-visible checklist in the inspect panel, e.g.
## "Ada sisa kotoran -> RESIDU". The rulebook still shows `text` verbatim; this
## exists because a six-sentence list will not fit beside the item, and it is
## data rather than a truncation rule in code. Falls back to `text`.
@export var short_text: String = ""
## Property name on ItemData -> required value. An Array value means "any of".
## e.g. {"has_residue": true}
@export var applies_when: Dictionary = {}
@export var forces_category: ItemData.Category
@export var priority: int = 0 ## higher wins on conflict

## An empty applies_when means this rule is rulebook text only and never
## overrides anything - that is how the day 1 baseline rule states the default
## without special-casing it in code.
func label() -> String:
	return short_text if short_text != "" else text


func matches(item: ItemData) -> bool:
	if applies_when.is_empty():
		return false
	for key: String in applies_when:
		var expected: Variant = applies_when[key]
		var actual: Variant = item.get(key)
		if actual == null:
			return false
		if expected is Array:
			if not _contains(expected, actual):
				return false
		elif not _same(actual, expected):
			return false
	return true


## Numbers may arrive as int or float depending on how the .tres was authored,
## so compare them numerically rather than by exact type.
static func _same(a: Variant, b: Variant) -> bool:
	var a_num := typeof(a) == TYPE_INT or typeof(a) == TYPE_FLOAT
	var b_num := typeof(b) == TYPE_INT or typeof(b) == TYPE_FLOAT
	if a_num and b_num:
		return is_equal_approx(float(a), float(b))
	return a == b


static func _contains(list: Array, value: Variant) -> bool:
	for entry: Variant in list:
		if _same(entry, value):
			return true
	return false
