## Runtime wrapper around an ItemData. Reveals are per grabbed instance, not
## per resource - two identical bottles must be inspected separately.
class_name CarriedItem
extends RefCounted

var data: ItemData
var revealed: Dictionary = {} ## field name -> true
var sorted_to: int = -1
var was_correct: bool = false
var expected_category: int = -1
var broken_rule: RuleData = null

func _init(item_data: ItemData) -> void:
	data = item_data

func is_revealed(field: String) -> bool:
	return revealed.get(field, false)

func reveal(field: String) -> void:
	revealed[field] = true

func reveal_all() -> void:
	for f: String in ["has_residue", "residue_type", "true_material", "tag_text"]:
		revealed[f] = true
