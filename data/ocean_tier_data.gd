class_name OceanTierData
extends Resource

@export var tier: int = 0
@export var display_name: String = ""
@export var min_health: int = 0
@export var max_health: int = 25

# none of the art fields below are hooked up yet - only display_name is used.
# keeping them filled because it's the spec for the designers.
@export var water_tint: Color = Color.WHITE
@export var seabed: Texture2D

@export var fish_count: int = 0
@export var coral_count: int = 0
@export var coral_frames: SpriteFrames
@export var debris_count: int = 0
@export var debris_frames: SpriteFrames

@export var transition_text: String = ""
