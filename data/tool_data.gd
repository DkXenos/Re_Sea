class_name ToolData
extends Resource

@export var id: StringName
@export var display_name: String
@export var frames: SpriteFrames  # idle / using
@export var icon: Texture2D
@export var reveals_field: String  # field name on ItemData
# a crate-opener and an inspection tool are different jobs. an opener finds
# nothing on an ordinary item; every other tool bounces off a sealed crate.
@export var opens_containers: bool = false
@export var description: String
@export var sort_order: int = 0
# rings, armed cursor, evidence chips all read this
@export var color: Color = Color.WHITE
