# runtime wrapper for an ItemData. reveals are per grabbed instance, two
# identical bottles get inspected separately.
class_name CarriedItem
extends RefCounted

## Learning one thing can tell you another for free. Naming the stain
## "engine oil" also tells you it is a chemical; the reverse does not hold,
## because a rinse that refuses proves the stain is chemical without ever
## saying which one.
const IMPLIED_REVEALS: Dictionary = {
	"stain_type": ["stain_hazardous", "is_stained"],
	"stain_hazardous": ["is_stained"],
}

var data: ItemData
var revealed: Dictionary = {}  # field -> true
# found by the coarse scanner but not read yet
var probed: Dictionary = {}
var sorted_to: int = -1
# rinsed clean. the stain is off this particular instance, so every rule that
# keys on the stain has to be judged against the entry, not against the shared
# ItemData - two identical cups get rinsed separately.
var cleaned: bool = false
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
	if field == "":
		return
	revealed[field] = true
	for implied: String in IMPLIED_REVEALS.get(field, []):
		reveal(implied)

func reveal_all() -> void:
	for f: String in ["is_stained", "stain_type", "stain_hazardous", "true_material"]:
		revealed[f] = true


# there is nothing left to wash off
func is_clean() -> bool:
	return cleaned or data == null or not data.is_stained


## What the rules should read instead of the ItemData. A rinsed cup is not a
## stained cup any more, and the residue rule has to stop firing on it - but
## the ItemData is shared between every copy of that item, so the difference
## lives here and is handed to the rule checker.
func rule_overrides() -> Dictionary:
	if not cleaned:
		return {}
	return {"is_stained": false, "stain_type": "", "stain_hazardous": false}
