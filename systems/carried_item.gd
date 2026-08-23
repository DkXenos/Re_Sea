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

## The item names itself once the player has learned something about it with a
## tool, or once they have committed it to a bin (revision 2 §3). Until then the
## panel shows observed properties instead - the name is a conclusion, and
## handing it over for free is what made the phase feel like label-matching.
func name_known() -> bool:
	return sorted_to != -1 or not revealed.is_empty()


## The name if it has been earned, the observed properties if it has not.
func label() -> String:
	return data.display_name if name_known() else data.surface_label()


func is_revealed(field: String) -> bool:
	return revealed.get(field, false)

func reveal(field: String) -> void:
	revealed[field] = true

func reveal_all() -> void:
	for f: String in ["has_residue", "residue_type", "true_material", "tag_text"]:
		revealed[f] = true
