## One visible state of the ocean (revision 2 §1). The health meter already
## existed; this is what makes it something the player can see.
##
## A tier is deliberately nothing but presentation: a water tint, a seabed
## backdrop, and how many fish, coral and debris sprites the tank holds. It
## never touches the health formula, the budget or the rules.
class_name OceanTierData
extends Resource

@export var tier: int = 0
## Inclusive health range this tier covers. Tuning knob.
@export var min_health: int = 0
@export var max_health: int = 25

## Multiplied onto the water background and the seabed.
@export var water_tint: Color = Color.WHITE
@export var seabed: Texture2D

@export var fish_count: int = 0
@export var coral_count: int = 0
@export var coral_frames: SpriteFrames
@export var debris_count: int = 0
@export var debris_frames: SpriteFrames

## Shown once on the day report when the ocean crosses into this tier, going
## up. One quiet sentence - no fanfare. Text lives here rather than in
## strings.gd for the same reason rule text does: it is content, one line per
## .tres, and a fifth tier must not need a code or table change.
@export var transition_text: String = ""
