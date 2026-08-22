# Walkthrough

One entry per system: the file that implements it, the Godot concept it
demonstrates, and why it is built that way. Written for the owner, who is going
to refactor all of this during production.

Read in order — each section assumes the ones above it. Sections marked
**(rev 1)** changed in the first revision.

---

## 1. Scene switching — `main.gd`, `main.tscn`

**Godot concept:** a plain `Node` as a scene holder, plus `CanvasLayer` for
anything that must survive a scene change.

`main.tscn` is not a game scene. Its root is a bare `Node` holding exactly one
child scene at a time in `SceneHolder`, plus the pause overlay, the debug
overlay and the pause button on layer 200 so they outlive every swap. Scenes are
addressed by key (`&"shift"`, `&"report"`) through a dictionary, which is why no
scene anywhere contains the path of another scene.

## 2. Flow graph — `systems/day_manager.gd` **(rev 1)**

**Godot concept:** a `RefCounted` static helper — no node, no autoload.

`main_menu → cutscene → day_start → shift → report`, looping back to `day_start`
until the ocean bottoms out or the last day ends. Revision 1 collapsed `claw` and
`desk` into one `shift`; they are views inside it, not phases, so they no longer
appear here. A phase emits `Events.phase_finished` and never decides what comes
next — `main.gd` asks `DayManager.advance_from()`.

## 3. The two autoloads — `autoload/events.gd`, `autoload/game.gd`

**Godot concept:** singletons registered in `project.godot`, and a signal bus.

`Events` is pure signals with no state and no logic; `Game` is pure state with no
knowledge of the scene tree. That split is what keeps the count at two: any third
autoload you feel tempted to add is either state (belongs in `Game`) or a
notification (belongs in `Events`).

## 4. Content as data — `data/*.gd` + `data/**/*.tres` **(rev 1)**

**Godot concept:** `class_name X extends Resource` with `@export` properties, one
`.tres` per instance, and typed arrays (`Array[ItemData]`).

Items, rules, tools and days are resources, so `DayData` holds real references to
its rules and items rather than string ids that need looking up.
`tools/smoke/smoke_extensibility.gd` proves the payoff: it adds a 15th item, a
7th rule and a 6th day as `.tres` files, drives both views with them, and deletes
them again — with no code change.

Revision 1 made the `.tres` the **only** source of truth. The generator that
could rewrite them is gone; schema changes are one-off scripts in
`tools/migrations/`, kept as a record.

## 5. Rule resolution — `systems/rule_checker.gd`, `data/rule_data.gd`

**Godot concept:** data-driven predicates — `applies_when` is a `Dictionary` of
property name to expected value, matched with `Object.get()`.

Every matching rule is collected and the highest `priority` wins, so a later rule
overrides an earlier one; that is how day 5 makes aluminium recyclable again
(priority 70) despite the residue rule (priority 10). An **empty `applies_when`
means rulebook text only, never an override**, which is how day 1's baseline rule
states the default without a special case in code.

`RULE_KEY_TO_REVEAL` lives here because a rule keys off a *property* while the
player uncovers a *field*, and they are not always the same name: `is_multilayer`
is learned by cutting an item open, which reveals `true_material`. The inspect
panel and the day report both read that mapping from here.

## 6. Text — `data/strings.gd`

**Godot concept:** a `const Dictionary` on a `RefCounted` with static accessors.

All player-facing text is Indonesian and lives in one table; item names and rule
text live in their own `.tres` because they are content, not chrome.
`Strings.tf` does `{placeholder}` substitution, which is also how the inspect
panel's question line is generated.

## 7. The shift — `scenes/shift/shift_phase.gd` **(rev 1, new)**

**Godot concept:** two instanced scenes as sibling views, switched by toggling
their `CanvasLayer.visible`.

A day is one shift with two tabs. Each view exposes `set_view_active(bool)`,
which hides its own layers and suspends its input — but not its processing, so
items keep drifting in and a claw cycle already in the air still lands. You left
the machine; you did not stop time.

Neither view decides the day is over. The shift does, when the budget cannot buy
a useful action or there is nothing left to do. Switching is free on purpose: the
decision the game is built around is "grab another, or examine what I have", and
that is only a real decision if looking at the desk costs nothing.

## 8. The shift budget — `autoload/game.gd` (`ACTION_COST`, `spend`) **(rev 1)**

**Godot concept:** a small const dictionary as the economy, plus one signal.

A drop costs 6, a tool use 4, sorting 1. **Nothing is spent by the clock.** There
is no real-time countdown and there must never be one — a ticking timer would
destroy the careful inspection the whole design is built around, while an
action-cost budget creates the intended tension. `can_still_act()` is what stops
the player being stranded: running out of budget for a drop is not the end of the
shift if there is still sorting to do.

## 9. Claw phase composition — `scenes/claw/claw_phase.tscn` **(rev 1)**

**Godot concept:** `SubViewport` + `SubViewportContainer`, a `Camera2D` inside
it, stacked `CanvasLayer`s, and `y_sort_enabled`.

The tank renders into its own `SubViewport`, which clips it at the glass edge for
free. Revision 1 made the seabed 2600 units against a 1000-wide window, so a
`Camera2D` follows the claw with position smoothing between `limit_left` and
`limit_right`. The seabed is one PNG tiled by `region_rect` plus
`texture_repeat`, so the width stays a tuning knob instead of an asset the
designers must redraw.

Layers are 0 water / 10 tank / 20 glass / 30 console / 50 HUD, and the water
slides against both the mouse and the camera. That is the entire "3D" effect, and
it cost a few lines instead of a `Camera3D` and a week of alpha-sorting bugs.

## 10. The minimap — `claw_phase.gd` (`_update_minimap`) **(rev 1, new)**

**Godot concept:** `TextureRect`s repositioned from world coordinates — layout,
not animation.

A strip under the tank showing the whole seabed, every item as a dot, the claw,
and the slice currently on screen. Without it, "where was that heavy thing"
becomes tedious rather than tense, and an item that drifts in off-camera would
simply be invisible.

## 11. The claw — `scenes/claw/claw.gd` **(rev 1)**

**Godot concept:** an explicit state machine in `_physics_process`, with
`Area2D.get_overlapping_areas()` for contact. **No physics engine.**

`IDLE → DESCEND → CLOSE → RISE`, with no player input after the drop:
commitment is the mechanic. Grip is `clamp(1 - weight*0.15, 0.25, 0.95)` rolled
once, and a failed roll still carries the item partway up before dropping it.

`predict_target()` is the important part. The claw stops at the **first** contact
during descent, so the item a drop will hit is the one whose circle the
descending grab circle touches earliest — not the nearest in x. The preview and
the grab both use this function, and the claw honours the prediction at resolve
time, which makes the percentage a promise rather than a hint. It used to be two
different rules, and with overlapping items the preview named a neighbour.

## 12. Items and fish — `scenes/claw/tank_item.gd`, `fish.gd` **(rev 1)**

**Godot concept:** `Area2D` with collision layers, `Node.reparent()`, and a
state machine instead of tweens.

An item is `SETTLED`, `CARRIED`, `FALLING` or `DRIFTING`. Carrying is reparenting
to the claw; slipping is reparenting back and sinking to its own resting height;
drifting in is the same motion from above with a sine sway. Each state plays a
named animation (`idle` / `wobble` / `sinking`) and **nothing here decides what
the motion looks like** — the old version tweened position and rotation, which
was code doing the designer's job.

Fish lost their `Area2D`, collision shape, grab interaction and penalty entirely.
Punishing the player for something that was never a decision read as unfair; as
background they do real work carrying the underwater feel.

## 13. Drift-in spawning — `claw_phase.gd` (`_update_spawning`) **(rev 1, new)**

**Godot concept:** a shuffled queue plus a randomized timer, parameterised by
`DayData`.

The seabed opens partly seeded and fills over the shift. Starting empty means
waiting; starting full means no reason to keep watching the tank. The next item
arrives on its timer *or* immediately when the tank falls below the day's floor,
so the player never has a reason to sit still. The floor beats the seed fraction
on small pools, otherwise day 1 would open below its own floor.

## 14. Desk composition — `scenes/desk/desk_phase.tscn` **(rev 1)**

**Godot concept:** absolute-offset `Control`s on a themed root, with
`NinePatchRect` panels.

The desk's UI dropped from layer 100 to 10 in revision 1: it is view content, not
a modal, and the shift bar at 50 has to sit above it. Only the rulebook is
genuinely modal, and it moved to its own layer at 100. The skeleton is in the
`.tscn`; everything repeated — cards, chips, tool rows, bins — is built in code,
because those counts come from data.

## 15. Inspect panel — `scenes/desk/inspect_panel.gd` **(rev 1, rebuilt)**

**Godot concept:** a second `SubViewport` for zoom and pan, normalized coordinate
conversion, and a `Sprite2D` overlay.

Zoom and pan use a `SubViewport` rather than a scaled `TextureRect` so clipping
and pan bounds come free. `_to_normalized()` converts a click into the 0–1
texture space hotspots are authored in, so zooming never moves a hotspot relative
to the artwork. Using a tool on empty space **spends the budget and reveals
nothing**, and that is never prevented — the risk is the design.

Revision 1 rebuilt everything around it, because the systems worked and nothing
communicated:

- the day's rules sit beside the item, from `RuleData.short_text`;
- `_evidence_state()` asks `RuleChecker.supported_rules()` which rules the player
  has actually *proved*, lights those chips, marks those rules, and points at the
  bin the winning rule forces — the player watches their own reasoning assemble;
- a question line frames the decision from surface info alone;
- a miss reports what it found and what it cost, because a dead click reads as a
  bug;
- hotspot rings are a separate overlay sprite that can be switched off.

## 16. Bins — `scenes/desk/bin_row.gd` **(rev 1)**

**Godot concept:** an `AnimatedSprite2D` for the visual plus a `flat` `Button` as
an invisible hit area.

The bin you see is always the PNG-backed `AnimatedSprite2D`; the `Button` only
carries the click. `accept` plays when a bin *takes* an item, never when the
answer was right — correctness is withheld until the report. `highlight` is the
other half of the chip lighting: the reasoning and its conclusion light together.

## 17. Rulebook — `scenes/desk/rulebook_panel.gd`

**Godot concept:** building a `VBoxContainer` from data at open time.

Rules grouped by the bin they force, printed verbatim from `RuleData.text`. Opens
on `R` (revision 1 gave `Tab` to view switching), pauses nothing, always
available: the challenge is hidden properties, never recall.

## 18. Day report — `scenes/report/day_report.gd` **(rev 1)**

**Godot concept:** `PanelContainer` (sizes to its content) and `tween_method` for
animating a number and a bar together — UI, which the animation rules allow.

Each term of the health formula gets its own line and its own number; showing
only the total would make it feel arbitrary. Each mis-sorted item is shown with
the bin it went to, the bin it belonged in, the rule it broke, and the property
the player never spent budget to look at.

## 19. Ocean meter — `autoload/game.gd` (`end_day_breakdown`) **(rev 1)**

`correct*2 − wrong*4 − shortfall*3 + 5 for a clean day that met quota`, clamped.
The 4× asymmetry on wrong sorts is the point and stays. The revision doubled the
correct-sort payment and added the bonus because a perfect run previously drifted
down to 92/100 — a game about healing the ocean where the ocean never heals.
`end_day_breakdown()` computes and commits nothing; the report displays it and
calls `commit_day_result()`.

## 20. Settings — `scenes/settings/settings_panel.gd`, `systems/save_settings.gd`

**Godot concept:** `AudioServer` bus indices, `linear_to_db()`, and `ConfigFile`
in `user://`.

One reusable `Control` holds the sliders and is instanced by both the settings
screen and the pause overlay, so volume can change mid-run without unloading the
scene the player is in. Zero mutes its bus rather than going quiet; the VFX
slider scales `Game.vfx_intensity`, which the tank reads for bubble count.
Revision 1 added the hotspot-ring toggle, kept in a separate `TOGGLES` dictionary
so a bool never gets clamped into a float.

## 21. Pause — `main.gd`, `scenes/settings/pause_overlay.gd`

**Godot concept:** `get_tree().paused` with `PROCESS_MODE_ALWAYS`.

`Main`, both overlay layers and the overlay itself are `PROCESS_MODE_ALWAYS`, so
they keep handling input while everything else is frozen. Pause is offered in
`day_start`, `shift` and `report` only — on the menu and in the cutscene `Esc`
already means something else.

## 22. Debug overlay — `scenes/debug/debug_overlay.gd`

**Godot concept:** `OS.is_debug_build()` plus a generic signal
(`Events.debug_command`) instead of debug branches inside game code.

Every button emits a command; `Game` handles the ones about state, `main.gd` the
one that changes scene, the desk the one that needs the inspected item. That is
why there is not a single `if debug` inside a phase scene.

## 23. Asset pipeline — `tools/gen_placeholders.py`, `assets/ASSETS.md` **(rev 1)**

**Godot concept:** `SpriteFrames` authored up front, and `.import` files as the
seam between source art and the engine.

Every visual is a PNG; anything that will ever animate is already an
`AnimatedSprite2D` backed by a `SpriteFrames` holding one frame per animation, so
animating later means adding frames, not replacing nodes. `ASSETS.md` is emitted
by the generator, so it cannot drift.

`tools/gen_hotspot_overlays.gd` is the one generator written in GDScript rather
than Python, because it reads `data/items/*.tres` — the rings are drawn *from the
same coordinates the game checks against*, so they can never disagree. It must be
run twice with an import between: Godot cannot load a PNG it has not imported.

## 24. Verification — `tools/smoke/` **(rev 1)**

**Godot concept:** `extends SceneTree` scripts run with `--script`, driving real
scenes with `await process_frame` / `await physics_frame`.

`run_all.sh` runs four static rule checks, two boot checks and eleven
simulations. Two caveats worth knowing:

- A script passed to `--script` is compiled **before** the autoloads register, so
  these fetch `Game` and `Events` with `root.get_node("/root/Game")`. Scripts
  inside scenes compile later and use the names normally.
- A failed GDScript `assert` aborts the coroutine without ever reaching `quit()`,
  so a broken check hangs instead of failing. `run_all.sh` enforces a per-check
  time limit and treats an overrun as a failure.

`smoke_shift.gd` holds the two invariants the shift model must never break:
budget spent equals the sum of the actions taken, and the tank never starves
while the pool still has items. `smoke_inspect.gd` asserts each of the five
legibility fixes separately, including that the bin hint always agrees with the
answer the game will actually judge.
