## One piece of trash. Every item in the game is one .tres file of this type;
## adding item #40 must never require a code change.
class_name ItemData
extends Resource

enum Category { ORGANIC, RECYCLABLE, HAZARD, LANDFILL }

@export var id: StringName
@export var display_name: String
## Static texture: inventory cards, inspect view, report rows.
@export var texture: Texture2D
## Animated form used inside the tank: idle / wobble / sinking. One frame each
## now, more later.
@export var frames: SpriteFrames
## Ring overlay marking this item's hotspots, drawn on top of the item in the
## inspect panel and toggleable. Generated from `hotspots` below by
## tools/gen_hotspot_overlays.gd - never hand-drawn, so the two cannot disagree.
## Final art should integrate the hotspot into the item drawing itself and this
## overlay becomes an accessibility aid only.
@export var hotspot_overlay: Texture2D
@export var weight: float = 1.0 ## affects claw grip chance

## What the item LOOKS and FEELS like, before any tool is used (revision 2 §3).
## Shown in place of the name, so the phase reads as identification rather than
## label-matching: "tembus pandang - lentur - mengapung", not "Botol Plastik".
## Free information, like visible_material - these cost nothing to observe.
@export var surface_properties: Array[String] = []

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

## The property line shown while the item is still unidentified. Falls back to
## what it looks like, so an item whose .tres has no properties yet still reads
## as an observation rather than as a blank.
func surface_label() -> String:
	if surface_properties.is_empty():
		return visible_material
	return "  ·  ".join(surface_properties)


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
