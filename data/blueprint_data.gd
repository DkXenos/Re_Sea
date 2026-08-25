class_name BlueprintData
extends Resource

@export var id: StringName
@export var display_name: String
@export var flavour_text: String

@export var components: Array[ComponentData] = []
@export var background: Texture2D

# UpgradeData id this opens in the Peralatan tab
@export var unlocks_upgrade: StringName

@export var health_gain: int = 0
@export var forces_tier: int = -1
@export var sort_order: int = 0


# only used by the tuning checks. crafting pays per component, not all at once.
func total_requirements() -> Dictionary:
	var out: Dictionary = {}
	for component: ComponentData in components:
		for category: int in component.requirements:
			out[category] = int(out.get(category, 0)) + int(component.requirements[category])
	return out


func crafted_count(crafted: Dictionary) -> int:
	var out: int = 0
	for component: ComponentData in components:
		if crafted.get(component.id, false):
			out += 1
	return out


func is_complete(crafted: Dictionary) -> bool:
	# empty check matters, a half-authored .tres would hand out a free tech
	return not components.is_empty() and crafted_count(crafted) == components.size()
