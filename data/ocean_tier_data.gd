class_name OceanTierData
extends Resource

## tier is the index, and the index is how many blueprints have been built.
@export var tier: int = 0
@export var display_name: String = ""

@export var water_tint: Color = Color.WHITE
@export var seabed: Texture2D

@export var fish_count: int = 0
@export var coral_count: int = 0
@export var coral_frames: SpriteFrames
@export var debris_count: int = 0
@export var debris_frames: SpriteFrames

@export var transition_text: String = ""
