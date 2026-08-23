## One visible state of the ocean (revision 2 §1). The health meter already
## existed; this is what makes it something the player can see.
##
## A tier is deliberately nothing but presentation: a water tint, a seabed
## backdrop, and how many fish, coral and debris sprites the tank holds. It
## never touches the health formula, the budget or the rules.
class_name OceanTierData
extends Resource

@export var tier: int = 0
## Shown in the shift HUD as "Laut: Buruk". Since revision 3 this is the ONLY
## part of a tier the game renders - see the art note below.
@export var display_name: String = ""
## Inclusive health range this tier covers. Tuning knob.
@export var min_health: int = 0
@export var max_health: int = 25

# --- DEFERRED, NOT CANCELLED (revision 3 §2.3) ---
# Nothing below is read by the game right now. Four sets of tier art is polish
# on a system whose value is unproven, so the visual treatment waits until the
# owner confirms that a rising meter feels rewarding. The fields stay here, and
# stay filled, because they are the brief for the designers: four water tints,
# four seabeds, two corals, one debris piece, and the counts each tier wants.

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
