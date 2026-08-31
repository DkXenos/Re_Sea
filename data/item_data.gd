class_name ItemData
extends Resource

enum Category { ORGANIC, RECYCLABLE, HAZARD, LANDFILL }

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

# needs the matching tool
@export var has_residue: bool = false
@export var residue_type: String = ""
@export var true_material: String = ""
@export var is_multilayer: bool = false
@export var tag_text: String = ""

# which tool finds what on this item. no position: the whole item is the
# target, so a tool either has something to find here or it does not.
# [{"tool": "swab", "reveals": "residue_type"}]
@export var hotspots: Array[Dictionary] = []

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
		"has_residue":
			return Strings.t("field_residue_yes") if has_residue else Strings.t("field_residue_no")
		"residue_type":
			return residue_type if residue_type != "" else Strings.t("field_none")
		"true_material":
			var txt := true_material if true_material != "" else visible_material
			if is_multilayer:
				txt += Strings.t("field_multilayer_suffix")
			return txt
		"tag_text":
			return tag_text if tag_text != "" else Strings.t("field_no_tag")
	return ""
