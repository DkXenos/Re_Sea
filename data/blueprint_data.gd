## A technology the player is working toward (revision 2 §2).
##
## This is a progress counter and an unlock, NOT a crafting system: there is no
## combining, no experimenting, no failure state and no recipe to discover. The
## player sorts correctly, the counter fills, the thing gets built.
##
## Adding a fourth blueprint must be one .tres and no code change.
class_name BlueprintData
extends Resource

@export var id: StringName
@export var display_name: String
## Plainly worded. The team must be able to defend every line in a judged Q&A,
## so this claims nothing technical about chemistry.
@export var flavour_text: String

## ItemData.Category -> how many CORRECTLY sorted items of it are needed.
## Wrong sorts contribute nothing; they do not subtract either, because the
## health formula already punishes them.
@export var required: Dictionary = {}

@export var health_gain: int = 0
## Ocean tier this blueprint pushes the art to when it completes, or -1 for
## none. It only applies while the ocean is healthy enough to make it plausible
## - see Game.visual_tier.
@export var forces_tier: int = -1
@export var sort_order: int = 0


## Requirements met, capped, so a partly filled blueprint reads as 7 / 12.
func progress(counts: Dictionary) -> Dictionary:
	var have: int = 0
	var need: int = 0
	for category: int in required:
		var want: int = int(required[category])
		need += want
		have += mini(want, int(counts.get(category, 0)))
	return {"have": have, "need": need}


func is_complete(counts: Dictionary) -> bool:
	for category: int in required:
		if int(counts.get(category, 0)) < int(required[category]):
			return false
	return not required.is_empty()
