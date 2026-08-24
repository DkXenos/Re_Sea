## A technology the player builds (revision 2 §2, reworked in revision 4 §3).
##
## A blueprint is a diagram made of components. Each is crafted separately by
## spending sorted materials; when every one of them is crafted, one CRAFT
## button assembles the blueprint, pays its ocean-health bonus and opens the
## tool it names in the Peralatan tab.
##
## Revision 3's flat counter - "7 / 12 correctly sorted recyclables" - is gone,
## not kept alongside. Correct sorts now feed a spendable pool instead of a
## running total, so progress is something the player spends rather than
## something that accumulates behind them.
##
## Adding a fourth blueprint, or a fourth component to one of these, must be
## .tres files and no code change.
class_name BlueprintData
extends Resource

@export var id: StringName
@export var display_name: String
## Plainly worded. The team must be able to defend every line in a judged Q&A,
## so this claims nothing technical about chemistry.
@export var flavour_text: String

## The parts, in the order the diagram lists them. Positions are on each part.
@export var components: Array[ComponentData] = []
## The schematic sheet the components are drawn on top of.
@export var background: Texture2D

## The Peralatan entry finishing this blueprint opens, by UpgradeData id. This
## is a reference into the equipment list that already exists - revision 4 §3 is
## explicit that a completed blueprint must not grow a second equipment system.
@export var unlocks_upgrade: StringName

@export var health_gain: int = 0
## Ocean tier this blueprint pushes the art to when it completes, or -1 for
## none. It only applies while the ocean is healthy enough to make it plausible
## - see Game.visual_tier.
@export var forces_tier: int = -1
@export var sort_order: int = 0


## Everything this blueprint costs if every component is crafted from scratch,
## category -> count. Used by the tuning checks, never to gate a craft: parts
## are paid for one at a time.
func total_requirements() -> Dictionary:
	var out: Dictionary = {}
	for component: ComponentData in components:
		for category: int in component.requirements:
			out[category] = int(out.get(category, 0)) + int(component.requirements[category])
	return out


## How many parts are done, so the diagram can read as 2 / 3 without anyone
## recounting it.
func crafted_count(crafted: Dictionary) -> int:
	var out: int = 0
	for component: ComponentData in components:
		if crafted.get(component.id, false):
			out += 1
	return out


## Every part crafted. A blueprint with no components is never complete, so a
## half-authored .tres cannot hand the player a free technology.
func is_complete(crafted: Dictionary) -> bool:
	return not components.is_empty() and crafted_count(crafted) == components.size()
