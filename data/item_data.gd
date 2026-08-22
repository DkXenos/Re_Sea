## One piece of trash. Every item in the game is one .tres file of this type;
## adding item #40 must never require a code change.
class_name ItemData
extends Resource

enum Category { ORGANIC, RECYCLABLE, HAZARD, LANDFILL }

@export var id: StringName
@export var display_name: String
## Static texture: inventory cards, inspect view, report rows.
@export var texture: Texture2D
## Animated form used inside the tank (wobble). One frame now, more later.
@export var frames: SpriteFrames
@export var weight: float = 1.0 ## affects claw grip chance

# --- Surface info: free, always shown ---
@export var visible_material: String ## what it LOOKS like
@export var visible_label: String ## printed text, may be absent or misleading

# --- Hidden info: only revealed by the matching tool ---
@export var has_residue: bool = false
@export var residue_type: String = ""
@export var true_material: String = "" ## may differ from visible_material
@export var is_multilayer: bool = false
@export var tag_text: String = "" ## care label / recycling code

# Which tool reveals which field
@export var revealed_by_rinse: bool = false
@export var revealed_by_swab: bool = false
@export var revealed_by_magnifier: bool = false
@export var revealed_by_cutter: bool = false

## Normalized hotspots on the texture. Using a tool anywhere else spends the
## charge and reveals nothing - that risk is the point of the whole design.
## [{"pos": Vector2(0.3, 0.7), "radius": 0.12, "tool": "cutter", "reveals": "true_material"}]
@export var hotspots: Array[Dictionary] = []

@export var correct_category: Category
@export var source_batch: StringName ## for the later "trace the polluter" arc

## True if this tool can ever learn anything here (used only for reporting,
## never to block a click).
func tool_can_reveal(tool_id: StringName) -> bool:
	match tool_id:
		&"rinse": return revealed_by_rinse
		&"swab": return revealed_by_swab
		&"magnifier": return revealed_by_magnifier
		&"cutter": return revealed_by_cutter
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
