class_name ItemData
extends Resource

# RESIDUE is the fourth bin: what is left once you cannot compost it, cannot
# recycle it and it is not chemical. It was briefly called LANDFILL, which is
# a place rather than a category - the bins on the desk are the Indonesian
# four, and the fourth one is Residu.
enum Category { ORGANIC, RECYCLABLE, HAZARD, RESIDUE }

@export var id: StringName
@export var display_name: String
@export var texture: Texture2D
@export var frames: SpriteFrames
@export var weight: float = 1.0  # grip chance

# sealed box. never sorted, the desk gives it an Open button instead.
@export var is_container: bool = false

# what it looks/feels like before any tool. free info.
@export var surface_properties: Array[String] = []

# free, always shown
@export var visible_material: String
@export var visible_label: String  # may be absent or a lie

# --- what is on it ---
# A stain is not a verdict, it is a job. Rinse takes an ordinary stain off and
# the item goes back to being whatever it is made of; a chemical stain never
# comes off, and drags the whole item into HAZARD with it. Which of the two
# this is costs a swab to find out - or a wasted rinse.
@export var is_stained: bool = false
@export var stain_type: String = ""
@export var stain_hazardous: bool = false

# --- what it is made of ---
# the magnifier's job. two shirts look identical and one of them is plastic.
@export var true_material: String = ""
@export var is_multilayer: bool = false

# which tool finds what on this item. no position: the whole item is the
# target, so a tool either has something to find here or it does not.
# rinse is not in here - it does not read the item, it changes it.
# [{"tool": "swab", "reveals": "stain_type"}]
@export var hotspots: Array[Dictionary] = []

# the bin it belongs in once nothing is on it. the day's rules push it
# somewhere else while it is still stained or still laminated.
@export var correct_category: Category
@export var source_batch: StringName


func surface_label() -> String:
	if surface_properties.is_empty():
		return visible_material
	return "  ·  ".join(surface_properties)


func tool_can_reveal(tool_id: StringName) -> bool:
	for spot: Dictionary in hotspots:
		if StringName(spot["tool"]) == tool_id:
			return true
	return false

func get_field_text(field: String) -> String:
	match field:
		"is_stained":
			return Strings.t("field_stain_yes") if is_stained else Strings.t("field_stain_no")
		"stain_type":
			return stain_type if stain_type != "" else Strings.t("field_none")
		"stain_hazardous":
			return Strings.t("field_stain_hazard") if stain_hazardous \
				else Strings.t("field_stain_washable")
		"true_material":
			var txt := true_material if true_material != "" else visible_material
			if is_multilayer:
				txt += Strings.t("field_multilayer_suffix")
			return txt
	return ""
