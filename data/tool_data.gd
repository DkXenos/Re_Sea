## An inspection tool. Each reveals exactly one hidden field.
class_name ToolData
extends Resource

@export var id: StringName
@export var display_name: String
@export var frames: SpriteFrames ## idle / using
@export var icon: Texture2D
@export var reveals_field: String ## field name on ItemData
@export var default_charges: int = 3
@export var description: String
## Display order in the rack. Data rather than code so a new tool slots in
## wherever its .tres says, with no change here.
@export var sort_order: int = 0
