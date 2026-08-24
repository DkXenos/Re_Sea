## One part of a blueprint diagram (revision 4 §3).
##
## A component is crafted on its own, by spending sorted materials out of
## Game.materials. This is a FIXED recipe: the requirement is authored here and
## shown to the player before they commit. There is no combining, no discovery,
## no failure state and no "what happens if I mix these" - a craft either has
## the materials or its button is disabled and says what is short.
##
## Adding a fourth component to a blueprint is one more .tres in the
## blueprint's `components` array and no code change.
class_name ComponentData
extends Resource

@export var id: StringName
@export var display_name: String

## The two states are two drawings, never one of them tinted in code (§3). The
## greyscale sheet is authored greyscale; the code only chooses which to show.
@export var locked_texture: Texture2D
@export var done_texture: Texture2D

## Where this part sits on the blueprint sheet, 0-1 across its width and height.
## Normalized so that art delivered at a different resolution still lines up -
## the diagram is laid out from the size the background is actually drawn at.
@export var diagram_position: Vector2 = Vector2(0.5, 0.5)

## ItemData.Category -> how many of that material crafting this part spends.
@export var requirements: Dictionary = {}


## What is missing from a pool, category -> how many short. Empty means the
## craft can go ahead. Returned rather than a bool so the button can say what
## is short instead of just refusing.
func shortfall(pool: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for category: int in requirements:
		var missing: int = int(requirements[category]) - int(pool.get(category, 0))
		if missing > 0:
			out[category] = missing
	return out


func affordable(pool: Dictionary) -> bool:
	return shortfall(pool).is_empty()


func total_required() -> int:
	var out: int = 0
	for category: int in requirements:
		out += int(requirements[category])
	return out
