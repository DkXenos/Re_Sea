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


# an opened crate draws its opened art; everything else draws its own texture
func display_texture() -> Texture2D:
	if data == null:
		return null
	if is_container() and opened and data.frames != null \
			and data.frames.has_animation(&"opened"):
		return data.frames.get_frame_texture(&"opened", 0)
	return data.texture

# the item is named from the moment it is on the desk. hiding the name behind a
# reveal made the list unreadable - you cannot plan a shift against seven cards
# that all say "soft, damp".
func label() -> String:
	return data.display_name


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
