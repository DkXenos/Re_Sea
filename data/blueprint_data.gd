class_name BlueprintData
extends Resource

@export var id: StringName
@export var display_name: String
@export var flavour_text: String

@export var components: Array[ComponentData] = []

# The sheet behind the components, in three states. The drone in the middle is
# drawn on the sheet itself, so it reads as locked while parts are missing, wakes
# up when every part is crafted, and is stamped built once the craft is paid for.
# ready/done are optional - a blueprint with only `background` never changes.
@export var background: Texture2D
@export var background_ready: Texture2D
@export var background_done: Texture2D

# UpgradeData id this opens in the Peralatan tab
@export var unlocks_upgrade: StringName

@export var sort_order: int = 0


# only used by the tuning checks. crafting pays per component, not all at once.
func total_requirements() -> Dictionary:
	var out: Dictionary = {}
	for component: ComponentData in components:
		for category: int in component.requirements:
			out[category] = int(out.get(category, 0)) + int(component.requirements[category])
	return out


## Which sheet to show. Falls back to the plain one whenever a state was not
## authored, so a half-finished blueprint still renders.
func sheet(crafted: Dictionary, built: bool) -> Texture2D:
	if built and background_done != null:
		return background_done
	if is_complete(crafted) and background_ready != null:
		return background_ready
	return background


func crafted_count(crafted: Dictionary) -> int:
	var out: int = 0
	for component: ComponentData in components:
		if crafted.get(component.id, false):
			out += 1
	return out


func is_complete(crafted: Dictionary) -> bool:
	# empty check matters, a half-authored .tres would hand out a free tech
	return not components.is_empty() and crafted_count(crafted) == components.size()
