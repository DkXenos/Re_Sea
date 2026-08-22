# Walkthrough

One entry per system: the file that implements it, the Godot concept it
demonstrates, and why it is built that way. Written for the owner, who is going
to refactor all of this during production.

Read in this order — each section assumes the ones above it.

---

## 1. Scene switching — `main.gd`, `main.tscn`

**Godot concept:** a plain `Node` as a scene holder, plus `CanvasLayer` for
anything that must survive a scene change.

`main.tscn` is not a game scene. Its root is a bare `Node` that holds exactly
one child scene at a time in `SceneHolder`, plus the pause overlay and the debug
overlay on layer 200 so they outlive every swap. Scenes are addressed by key
(`&"claw"`, `&"desk"`) through a dictionary, which is why no scene anywhere in
the project contains the path of another scene.

## 2. Flow graph — `systems/day_manager.gd`

**Godot concept:** a `RefCounted` static helper — no node, no autoload.

A phase scene emits `Events.phase_finished` and never decides what comes next;
`main.gd` asks `DayManager.advance_from(current_key)`. Keeping the graph in one
static function means the whole day loop, including "the ocean bottomed out so
end the run early", is readable in twenty lines instead of being scattered
across six scenes.

## 3. The two autoloads — `autoload/events.gd`, `autoload/game.gd`

**Godot concept:** singletons registered in `project.godot`, and a signal bus.

`Events` is pure signals with no state and no logic; `Game` is pure state with
no knowledge of the scene tree. That split is what keeps the count at two: any
third autoload you feel tempted to add is either state (belongs in `Game`) or a
notification (belongs in `Events`).

## 4. Content as data — `data/*.gd` + `data/**/*.tres`

**Godot concept:** `class_name X extends Resource` with `@export` properties,
one `.tres` per instance, and typed arrays (`Array[ItemData]`).

Items, rules, tools and days are resources, so `DayData` can hold real
references to its rules and items rather than string ids that need looking up.
`tools/smoke/smoke_extensibility.gd` proves the payoff: it adds a 15th item, a
7th rule and a 6th day as `.tres` files, drives both phases with them, and
deletes them again — with no code change anywhere.

## 5. Rule resolution — `systems/rule_checker.gd`, `data/rule_data.gd`

**Godot concept:** data-driven predicates — `applies_when` is a `Dictionary` of
property name to expected value, matched with `Object.get()`.

Every matching rule is collected and the highest `priority` wins, so a later
rule overrides an earlier one; that is how day 5 makes aluminium recyclable
again (priority 70) despite the residue rule (priority 10) saying otherwise. An
**empty `applies_when` means rulebook text only, never an override**, which is
how day 1's baseline rule states the default without a special case in code.

## 6. Text — `data/strings.gd`

**Godot concept:** a `const Dictionary` on a `RefCounted` with static accessors.

All player-facing text is Indonesian and lives in one table; item names and rule
text live in their own `.tres` because they are content, not chrome. `Strings.tf`
does `{placeholder}` substitution so a re-wording never means touching a scene.

## 7. Claw phase composition — `scenes/claw/claw_phase.tscn`

**Godot concept:** `SubViewport` + `SubViewportContainer`, stacked
`CanvasLayer`s, and `y_sort_enabled`.

The tank renders into its own `SubViewport` displayed inside the machine frame,
which gives clipping at the glass edge for free and lets the tank be zoomed or
panned later without touching the console. Layers are 0 water / 10 tank / 20
glass / 30 console / 50 HUD, and `_update_parallax()` offsets the first three by
2–6 pixels from the mouse — that is the entire "3D" effect, and it cost six
lines instead of a `Camera3D` and a week of alpha-sorting bugs.

## 8. The claw — `scenes/claw/claw.gd`

**Godot concept:** an explicit state machine in `_physics_process`, with
`Area2D.get_overlapping_areas()` for contact. **No physics engine.**

`IDLE → DESCEND → CLOSE → RISE` with no player input after the drop: commitment
is the mechanic. Grip is `clamp(1.0 - weight * 0.15, 0.25, 0.95)` rolled once,
and a failed roll still carries the item partway up before dropping it at a
random height — one behaviour that supplies all the risk without a single
`RigidBody2D`.

## 9. Items and fish — `scenes/claw/tank_item.gd`, `scenes/claw/fish.gd`

**Godot concept:** `Area2D` with `collision_layer` / `collision_mask`,
`Node.reparent()`, and `Tween` instead of gravity.

Carrying is reparenting to the claw, and slipping is reparenting back plus a
tween to the item's own resting height — the item remembers its home parent so
it always returns to the item holder rather than wherever the claw happened to
be. Fish are a sine path with no AI at all; they are an obstacle to read, not an
opponent.

## 10. Desk composition — `scenes/desk/desk_phase.tscn`

**Godot concept:** absolute-offset `Control`s on a themed root, with
`NinePatchRect` panels.

Panels are `NinePatchRect` over `assets/ui/panel_*.png` with 24px margins, so a
designer replacing the PNG changes the whole look. The skeleton is in the
`.tscn` and everything repeated — cards, chips, tool rows, bins — is built in
code, because those counts come from data.

## 11. Inspect panel — `scenes/desk/inspect_panel.gd`

**Godot concept:** a second `SubViewport` for zoom and pan, and normalized
coordinate conversion.

Zoom and pan use a `SubViewport` rather than a scaled `TextureRect` so clipping
and pan bounds come free; `_to_normalized()` converts a click into the 0–1
texture space that hotspots are authored in, which is why zooming never changes
where a hotspot is. Using a tool on empty space **spends the charge and reveals
nothing**, and that is deliberately never prevented — the risk is the design.

## 12. Bins — `scenes/desk/bin_row.gd`

**Godot concept:** an `AnimatedSprite2D` for the visual plus a `flat` `Button`
as an invisible hit area.

The bin you see is always the PNG-backed `AnimatedSprite2D`; the `Button` only
carries the click and focus ring, which is how a game object stays a sprite
while still behaving like a control. `accept` plays when a bin *takes* an item,
never when the answer was right — correctness is withheld until the report.

## 13. Rulebook — `scenes/desk/rulebook_panel.gd`

**Godot concept:** building a `VBoxContainer` from data at open time.

Rules are grouped by the bin they force and printed verbatim from
`RuleData.text`. It opens on TAB, pauses nothing, and is always available: the
challenge in this game is hidden properties, never recall.

## 14. Day report — `scenes/report/day_report.gd`

**Godot concept:** `PanelContainer` (sizes to its content) and `tween_method`
for animating a number and a bar together.

Each term of the health formula gets its own line and its own number; showing
only the total would make it feel arbitrary. `RULE_KEY_TO_REVEAL` maps the
property a rule keys off to the field the player would have revealed — they are
not always the same name, since `is_multilayer` is learned by cutting an item
open, which reveals `true_material`.

## 15. Ocean meter — `autoload/game.gd` (`end_day_breakdown`)

**Godot concept:** returning a `Dictionary` of separate terms rather than one
number.

`end_day_breakdown()` computes every term and commits nothing; the report
displays it and calls `commit_day_result()`. Wrong sorts cost four times what
right sorts pay, so sorting carelessly is worse than sorting slowly — and the
player can trace exactly that on screen.

## 16. Settings — `scenes/settings/settings_panel.gd`, `systems/save_settings.gd`

**Godot concept:** `AudioServer` bus indices, `linear_to_db()`, and `ConfigFile`
in `user://`.

One reusable `Control` holds all four sliders and is instanced by both the
settings screen and the pause overlay, so volume can change mid-run without
unloading the scene the player is standing in. Zero mutes its bus rather than
just going quiet, and the VFX slider is not audio at all — it scales
`Game.vfx_intensity`, which the tank reads to decide how many bubbles exist.

## 17. Pause — `main.gd`, `scenes/settings/pause_overlay.gd`

**Godot concept:** `get_tree().paused` with `PROCESS_MODE_ALWAYS`.

`Main`, both overlay layers and the overlay itself are `PROCESS_MODE_ALWAYS`, so
they keep handling input while everything else is frozen. Pause is only offered
in `day_start`, `claw`, `desk` and `report` — on the menu and in the cutscene
Esc already means something else.

## 18. Debug overlay — `scenes/debug/debug_overlay.gd`

**Godot concept:** `OS.is_debug_build()` plus a generic signal
(`Events.debug_command`) instead of debug branches inside game code.

Every button emits a command; `Game` handles the ones about state, `main.gd` the
one that changes scene, and `desk_phase.gd` the one that needs the inspected
item. That is why there is not a single `if debug` inside a phase scene, and why
the overlay can be deleted without touching the game.

## 19. Asset pipeline — `tools/gen_placeholders.py`, `assets/ASSETS.md`

**Godot concept:** `SpriteFrames` resources authored up front, and `.import`
files as the seam between source art and the engine.

Every visual is a PNG; anything that will ever animate is already an
`AnimatedSprite2D` backed by a `SpriteFrames` in `data/frames/` holding one
frame, so animating later means adding frames, not replacing nodes. `ASSETS.md`
is emitted by the generator as it draws, so the document the designers work from
cannot drift from what is actually on disk.

## 20. Verification — `tools/smoke/`

**Godot concept:** `extends SceneTree` scripts run with `--script`, driving real
scenes with `await process_frame` / `await physics_frame`.

`run_all.sh` boots the project, plays a whole run both well and badly, exercises
every tool and debug command, and proves the data model extends without code.
One caveat: a script passed to `--script` is compiled **before** the autoloads
register, so these fetch `Game` and `Events` with `root.get_node("/root/Game")`
— scripts inside scenes compile later and use the names normally.
