class_name RuleData
extends Resource

@export var id: StringName
@export var text: String  # verbatim in the rulebook
# short version for the checklist next to the item, falls back to text
@export var short_text: String = ""
# ItemData property -> required value. array value means "any of".
@export var applies_when: Dictionary = {}
@export var forces_category: ItemData.Category
@export var priority: int = 0  # higher wins


func label() -> String:
	return short_text if short_text != "" else text


func matches(item: ItemData) -> bool:
	# empty applies_when = rulebook text only, never overrides anything
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


# ints and floats get mixed up depending on how the .tres was saved
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
