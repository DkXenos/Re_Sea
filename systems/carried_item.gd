# runtime wrapper for an ItemData. reveals are per grabbed instance, two
# identical bottles get inspected separately.
class_name CarriedItem
extends RefCounted

var data: ItemData
var revealed: Dictionary = {}  # field -> true
# found by the coarse scanner but not read yet
var probed: Dictionary = {}
var sorted_to: int = -1
# boxes only
var container_seed: int = 0
var opened: bool = false
var was_correct: bool = false
var expected_category: int = -1
var broken_rule: RuleData = null

func _init(item_data: ItemData) -> void:
	data = item_data


func is_container() -> bool:
	return data != null and data.is_container

# the name is a conclusion - you get it once you've learned something or
# committed it to a bin. before that the panel shows properties instead.
func name_known() -> bool:
	return sorted_to != -1 or not revealed.is_empty()


func label() -> String:
	return data.display_name if name_known() else data.surface_label()


func is_probed(field: String) -> bool:
	return probed.get(field, false)


func probe(field: String) -> void:
	probed[field] = true


func is_revealed(field: String) -> bool:
	return revealed.get(field, false)

func reveal(field: String) -> void:
	revealed[field] = true

func reveal_all() -> void:
	for f: String in ["has_residue", "residue_type", "true_material", "tag_text"]:
		revealed[f] = true
