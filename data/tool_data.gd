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
## Accent colour for this tool: its hotspot rings, its armed cursor, and the
## evidence chips it produces. Lives here so nothing renders a tool colour that
## the data does not know about.
@export var color: Color = Color.WHITE
