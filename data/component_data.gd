class_name ComponentData
extends Resource

@export var id: StringName
@export var display_name: String

@export var locked_texture: Texture2D
@export var done_texture: Texture2D

# 0-1 across the sheet, so art at another resolution still lines up
@export var diagram_position: Vector2 = Vector2(0.5, 0.5)

# ItemData.Category -> how many it costs
@export var requirements: Dictionary = {}


# category -> how many short. empty = go ahead
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
