# Claude Code Brief — Prototype: Underwater Claw + Waste Sorting

> Paste into Claude Code, or save in the project root and say: `Read claude-code-prototype-brief.md and execute it phase by phase.`

---

## 0. What This Is

A **playable prototype**, not a finished game. The owner will refactor this himself during production; real art and animation arrive later from two designers.

Prototype means: correct systems, readable feedback, no polish. No screen transitions, no particles, no juice passes, no audio mixing. If a choice trades polish for clarity, take clarity.

But **one thing must be production-grade: the asset seam.** Every visual is a PNG file swapped in later without touching code. Details in §3 — treat that section as the highest-priority constraint in this document.

---

## 1. The Game

Player operates a claw machine on the seabed. Grab trash from the water, then sort it correctly under a daily quota.

Two alternating phases:

**Phase A — Claw.** Top-down-ish view into the water tank. Move the claw, drop it, grab whatever it closes on. Fish swim around as obstacles/decoys. Grabbed items go to inventory. Limited grabs per day.

**Phase B — Desk.** Open inventory, inspect each item, decide which bin it belongs in. Inspection reveals hidden properties — but **inspection tools have limited charges**, so the player cannot examine everything and must gamble on some items.

At end of day: quota check, accuracy report, ocean-health meter moves.

The core tension is not "which bin" — it's **"is this item worth spending a tool charge on?"** Everything in the design serves that question.

---

## 2. Tech Constraints

- **Godot 4.x, GDScript only**, statically typed. No addons.
- **Viewport 1280×720**, `canvas_items` stretch, `keep` aspect. Text-heavy UI needs the resolution — do not use 640×360.
- **Texture filter: Linear** (this is not pixel art).
- **Exactly two autoloads:** `Events` (signal bus) and `Game` (run/day state). No third.
- **No physics engine for the claw.** No RigidBody2D. Claw movement is lerped position; grabbing is `Area2D` overlap plus a grip-chance roll. Real physics is a multi-day tuning sink and is out of scope.
- **All content is data.** Items, rules, days, and tool definitions are custom `Resource` files. Adding item #40 or rule #12 must require zero code changes.
- **No hardcoded cross-scene node paths.** Groups and signals only.

---

## 2.1 Rendering and Layering — 2D Only

**This is a 2D project. Do not use any 3D node, ever** — no `Node3D`, no `Sprite3D`, no `Camera3D`. The first-person feel comes from a fixed viewpoint facing the machine, not from a 3D camera. Alpha-sorting artifacts with layered transparent sprites in 3D are a known trap and buy nothing here.

`main.tscn` root is a plain `Node` acting as a scene switcher. Phase scenes are `Node2D`. All UI is `CanvasLayer`.

**Depth comes from three tools, in this order of preference:**

1. **`CanvasLayer`** for anything that should not move with a camera and needs its own draw order — console, HUD, overlays, modals.
2. **`SubViewport` + `SubViewportContainer`** for a "screen within a screen". The tank interior renders into its own SubViewport and is displayed inside the machine frame. This gives free clipping at the glass edge and lets the tank zoom or pan independently of the console.
3. **`z_index`** for ordering inside a single layer, and `y_sort_enabled` on the tank world node so items lower on screen draw in front.

**Layer assignment — use exactly these numbers:**

| Layer | Contents |
|-------|----------|
| 0 | water background, far seabed |
| 10 | `SubViewportContainer` holding the tank world (items, fish, claw, cable) |
| 20 | glass overlay: reflection, bubbles, tint |
| 30 | machine frame and console (arrow buttons, joystick) |
| 50 | HUD: grabs remaining, quota, day number |
| 100 | modal panels: inventory, inspect, rulebook |
| 200 | pause and settings |

Inside the tank SubViewport, use `z_index`: seabed `-10`, items `0`, fish `10`, claw and cable `20`.

**Fake parallax for depth:** offset layers 0, 10, and 20 by a few pixels each in response to mouse position, with the nearest layer moving most. Small numbers — 2 to 6 pixels. Enough to read as depth, not enough to distract.

The inspect panel's zoom and pan also use a `SubViewport`, not a scaled `TextureRect` — clipping and pan bounds come free that way.

---

## 3. The Asset Seam — Highest Priority

The owner swaps in real sprites and `AnimatedSprite2D` animations later. Build for that from the first commit.

**Rules:**

1. **Every visual element is a texture loaded from a PNG in `assets/`.** Never `draw_rect()`, never a `ColorRect` standing in for a game object, never a shape drawn in code. A grey square PNG is correct; a `ColorRect` is not.
2. **Anything that will ever animate uses `AnimatedSprite2D` with a `SpriteFrames` resource — even now, with one frame.** That covers: claw (open/closing/closed/carrying), fish (swim), grabbed items (wobble), bin (idle/accept/reject), tools (idle/using). Swapping later means dropping frames into the existing `SpriteFrames`, not rewriting a node.
3. **Static things use `Sprite2D` or `TextureRect`.**
4. **One PNG per asset, one purpose per PNG.** No atlases, no sheets in the prototype.
5. **Exact filenames and pixel dimensions are fixed by the manifest** you write (see below). Designers drop replacements at the same path and size; nothing else changes.
6. **Placeholder art you generate yourself** with a Python script (`tools/gen_placeholders.py`, Pillow): flat colour shapes, high contrast, a thin outline, and — for anything with a hidden property — a visible marker so it's testable. Do not use AI image generation for any asset in this project.

**Write `assets/ASSETS.md`** listing every PNG: path, pixel size, what it depicts, whether it animates, and how many frames the final version should have. This file is what the designers work from — write it for them, not for you.

**Folder layout:**

```
assets/
├── claw/        claw_open.png, claw_closing.png, claw_closed.png, claw_cable.png
├── items/       item_<id>.png            (one per trash item)
├── fish/        fish_small.png, fish_medium.png, fish_large.png
├── bins/        bin_organic.png, bin_recyclable.png, bin_hazard.png, bin_landfill.png
├── tools/       tool_rinse.png, tool_swab.png, tool_magnifier.png, tool_cutter.png
├── ui/          panel_*.png, button_*.png, icon_*.png, meter_*.png
└── env/         tank_frame.png, water_bg.png, seabed.png, machine_console.png
```

---

## 4. Project Structure

```
res://
├── autoload/    events.gd, game.gd
├── data/
│   ├── item_data.gd, rule_data.gd, day_data.gd, tool_data.gd
│   ├── items/     *.tres   (12–15 items)
│   ├── rules/     *.tres   (6–8 rules)
│   ├── tools/     *.tres   (4 tools)
│   └── days/      day_01.tres … day_05.tres
├── scenes/
│   ├── main_menu/, settings/, cutscene/
│   ├── claw/      claw_phase.tscn, claw.gd, tank_item.gd, fish.gd
│   ├── desk/      desk_phase.tscn, inventory_panel.gd, inspect_panel.gd, bin_row.gd
│   └── report/    day_report.tscn
├── systems/      day_manager.gd, rule_checker.gd, save_settings.gd
├── assets/       (see above)
├── tools/        gen_placeholders.py
└── main.tscn
```

---

## 5. Data Model

**`ItemData`** — one `.tres` per trash item:

```gdscript
class_name ItemData
extends Resource

enum Category { ORGANIC, RECYCLABLE, HAZARD, LANDFILL }

@export var id: StringName
@export var display_name: String
@export var texture: Texture2D
@export var weight: float = 1.0          # affects claw grip chance

# --- Surface info: free, always shown ---
@export var visible_material: String     # what it LOOKS like
@export var visible_label: String        # printed text, may be absent or misleading

# --- Hidden info: only revealed by the matching tool ---
@export var has_residue: bool = false
@export var residue_type: String = ""
@export var true_material: String = ""   # may differ from visible_material
@export var is_multilayer: bool = false
@export var tag_text: String = ""        # care label / recycling code

# Which tool reveals which field
@export var revealed_by_rinse: bool = false
@export var revealed_by_swab: bool = false
@export var revealed_by_magnifier: bool = false
@export var revealed_by_cutter: bool = false

@export var correct_category: Category
@export var source_batch: StringName     # for the later "trace the polluter" arc
```

**Design the 12–15 items so the set is interesting**, not just varied:
- 5–6 **obvious** items, correctly sortable from surface info alone. These set the rhythm and let the player move fast.
- 4–5 **traps**: look clean, hide residue or a false material. A bottle that looks like plain PET but is multilayer. A tote bag that reads eco but has a plastic coating.
- 3–4 **honest-but-ambiguous**: genuinely need a tool, and the player should feel the charge was well spent.

`visible_material` differing from `true_material` is the single most important lever in the whole design. Use it deliberately.

**`RuleData`** — active sorting rules, introduced progressively:

```gdscript
@export var id: StringName
@export var text: String                    # shown verbatim in the rulebook
@export var applies_when: Dictionary        # e.g. {"has_residue": true}
@export var forces_category: ItemData.Category
@export var priority: int = 0               # higher wins on conflict
```

Rules are evaluated by priority so later rules can override earlier ones — that's how difficulty grows without new code.

**`ToolData`** — 4 tools, each reveals one field:

| Tool | Reveals | Charges/day |
|------|---------|-------------|
| Rinse | residue under grime | 4 |
| Chem swab | residue type | 3 |
| Magnifier | tag text / recycling code | 5 |
| Cutter | true material, multilayer | 2 |

**`DayData`** — `day_number`, `active_rules`, `item_pool`, `quota`, `max_grabs`, per-tool charge overrides, `modifier` (optional).

---

## 6. Detective UI — Design Spec

This is the part the owner is unsure about, so build it exactly as described.

### 6.1 Inspect panel layout

Three columns:

**Left — item viewport.** Item texture large and centred. Mouse wheel zooms (1×–3×), drag pans. Purely tactile; no gameplay depends on zoom level. It exists so examining *feels* like examining.

**Centre — tool rack.** Four tool buttons, each showing remaining charges as pips. Clicking arms a tool (cursor changes). Clicking the item with a tool armed spends one charge and runs the reveal. If a tool would reveal nothing on this item, **it still spends the charge** — that's the risk, and it must never be prevented.

**Right — evidence log.** Starts with surface info as grey chips (material, label, weight). Each successful reveal appends a coloured chip: `RESIDUE: oil`, `TRUE MATERIAL: multilayer PET`. Chips are the player's reasoning made visible, and they're what the end-of-day report refers back to.

Below the columns: **four bin buttons**. Always clickable — the player may sort with zero evidence at any time.

### 6.2 The interaction that carries the whole design

Reveals are **hotspot-based, not whole-item**. Each item has 2–3 invisible hotspots (a seam, a label corner, a stained patch). Using a tool on the correct hotspot reveals the property; using it on empty area spends the charge and reveals nothing.

Store hotspots on `ItemData` as normalized coordinates:

```gdscript
@export var hotspots: Array[Dictionary]
# [{"pos": Vector2(0.3, 0.7), "radius": 0.12, "tool": "cutter", "reveals": "true_material"}]
```

This one mechanic converts passive inspection into an active search, and it costs very little code. It's the difference between a quiz and a game.

### 6.3 Rulebook

Toggleable overlay (`TAB`), open any time, pauses nothing. Lists currently active rules verbatim from `RuleData.text`, grouped by category. **Never require the player to memorize rules** — the challenge is hidden properties, not recall.

### 6.4 What is deliberately NOT in the prototype

Minigames for cleaning items, dialogue with senders, item disassembly, an upgrade shop, a story mode. Every one is a week of work and none raises the score.

---

## 7. Claw Phase Spec

- Console layout follows the reference: two arrow buttons (left/right) and a joystick knob, drawn as UI over the tank. Keyboard works too: `A`/`D` or arrows to move, `Space`/`S` to drop.
- Claw moves horizontally along a rail at the top. Pressing drop lowers it at constant speed, closes at the bottom, rises again. **No player control during descent** — commitment is the point.
- On close, check `Area2D` overlap. If an item overlaps, roll grip: `grip_chance = clamp(1.0 - item.weight * 0.15, 0.25, 0.95)`. Show the percentage on hover **before** the drop, so failure is the player's judgement rather than a surprise.
- On failed grip, the item slips at a random point during the rise and falls back. That single behaviour supplies all the roguelite risk this prototype needs.
- Fish drift back and forth on simple sine paths. Grabbing a fish wastes the grab and costs a small ocean-health penalty. No fish AI, no pathfinding.
- `max_grabs` per day from `DayData`. When grabs run out, phase ends automatically.

---

## 8. Screens and Flow

```
main_menu → [Play] → cutscene (skippable) → day_start
                   → [Settings] → 4 sliders (master, music, sfx, vfx)
                                  saved to user://settings.cfg

day_start (rules-for-today card)
  → claw_phase   (grab until max_grabs spent)
  → desk_phase   (inspect + sort until inventory empty)
  → day_report   (quota met? accuracy? ocean meter moves)
  → next day, or game_over if the ocean meter bottoms out
```

**Day 1 is the tutorial** — surface info only, one rule, tools disabled. Tools unlock on day 2 with a one-line explanation. No separate tutorial system.

**Cutscene:** static PNG + text, click to advance, skippable. Placeholder text is fine — the owner writes the real script later.

**Day report is the emotional payoff.** For each mis-sorted item, show it with the property the player missed and the rule it broke. Then move the ocean-health meter. This delayed feedback is deliberate: it is why individual decisions feel weighty.

---

## 9. Phases — Verify and Commit After Each

Run `git init` if needed. Commit per phase. `.gitignore`: `.godot/`, `export/`.

| # | Deliverable | Gate |
|---|-------------|------|
| 0 | project.godot, folders, autoloads, input map, `CLAUDE.md` | boots headless, no errors |
| 1 | `gen_placeholders.py`, all PNGs, `SpriteFrames`, `ASSETS.md` | every PNG has an `.import` |
| 2 | Data classes + all `.tres` (items, rules, tools, 5 days) | loads, printable |
| 3 | Claw phase: movement, drop, grip roll, fish, inventory handoff | grabbing works end to end |
| 4 | Desk phase: inventory grid, inspect panel, zoom/pan, tool charges, hotspot reveals, evidence log | full inspect loop works |
| 5 | `rule_checker.gd`, bins, day report, ocean meter | a full day completes |
| 6 | Menu, settings + persistence, cutscene, day flow, game over | full loop, menu to game over |
| 7 | `PROGRESS.md`, `WALKTHROUGH.md`, cleanup | see §10 |

Verify yourself, don't hand errors to the human:

```bash
godot --version
godot --headless --quit-after 2
godot --headless --quit-after 240
```

Any `SCRIPT ERROR`, `Parse Error`, `Failed loading resource`, or orphan-node warning is a failed gate.

## 10. Definition of Done

- [ ] Headless run: zero errors, zero orphan warnings
- [ ] Playable start to finish: menu → cutscene → 5 days → report → game over
- [ ] **Every visual comes from a PNG in `assets/`; zero `ColorRect` or `draw_*` game objects**
- [ ] Everything that will animate is already an `AnimatedSprite2D` with a `SpriteFrames`
- [ ] `assets/ASSETS.md` is complete and written for a designer
- [ ] Adding an item or rule needs only a new `.tres`
- [ ] Exactly two autoloads
- [ ] `PROGRESS.md` lists what's built, what needs the human, known bugs, shortcuts taken

## 11. Stop and Ask For

Write into `PROGRESS.md` under `## Needs Human`, then continue with whatever is unblocked:

- Godot install / PATH
- Export templates (GUI-only)
- Input map, if writing `[input]` into `project.godot` breaks the file — back it up first and verify it still opens
- Anything subjective: claw speed, grip curve, quota difficulty, tool charge counts. Propose values; the owner decides
- Real art, audio, and the cutscene script

Not human-only — do these yourself: writing `.tscn`/`.tres` by hand, editing `project.godot`, generating placeholder PNGs, running Godot headless, git, fixing your own errors.

## 12. Also Write

- `CLAUDE.md` — constraints from §2, the asset-seam rules from §3, the content-is-data rule, the phase-and-verify workflow
- `WALKTHROUGH.md` — per system: which file implements it, which Godot concept it demonstrates, and two sentences on why it's built that way. The owner is refactoring this himself later and needs to understand every piece.

---

## 13. Input Map

Create these actions. Do not use `ui_*` actions for gameplay — they belong to the UI system and will conflict.

```
claw_left    → A, Arrow Left
claw_right   → D, Arrow Right
claw_drop    → Space, S, Arrow Down
inspect_use  → Mouse Button Left
rulebook     → Tab
inventory    → I
pause        → Escape
advance      → Enter, Mouse Button Left   (cutscene / report screens)
```

Every action must also be reachable by mouse — the competition build will be demoed by strangers who won't read a control list.

## 14. Audio — Sliders Must Actually Do Something

The settings screen has four sliders. A slider wired to nothing is a broken feature, so set this up properly even in the prototype.

- Create audio buses in `default_bus_layout.tres`: `Master`, `Music`, `SFX`. Route accordingly.
- Sliders write to `AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))`, clamped, with `value == 0` muting the bus.
- The **VFX slider** is not audio — it scales a global intensity float in `Game` (screen shake, bubble particle count). Wire it to at least one visible thing so it's testable.
- Generate placeholder sounds yourself with a Python script (`tools/gen_sounds.py`, raw WAV via the `wave` module): short blips and clicks, plain sine or square with a quick fade. Needed: claw move, claw drop, grab success, grab fail, tool use, reveal success, reveal nothing, bin accept, bin reject, day end. No AI audio generation in this project, ever.
- Settings persist to `user://settings.cfg` via `ConfigFile` and load on boot.

## 15. Ocean Health Meter — Exact Formula

Do not invent this. It drives the ending, so it must be legible to the player.

- Starts at `100`. Game over at `0`.
- End of day: `health += (correct_sorts * 1) - (wrong_sorts * 4) - (fish_grabbed * 2) - quota_shortfall_penalty`
- `quota_shortfall_penalty = max(0, quota - items_sorted) * 3`
- Clamp to `[0, 100]`.
- The day report shows each term as a separate line with its own number, then the total. Never show only the final figure — the player must be able to trace it.

Wrong sorts hurt four times more than right sorts help. That asymmetry is the whole point: the player should feel that sorting carelessly is worse than sorting slowly.

## 16. Starting Balance Values

Use these as the initial numbers so the game is playable on first run. They are starting points for the owner to tune, not final values — note them in `PROGRESS.md` as tuning candidates.

| Day | Active rules | Items in pool | Quota | Max grabs | Tool charges |
|-----|--------------|---------------|-------|-----------|--------------|
| 1 | 1 | 6 | 5 | 8 | none (tools locked) |
| 2 | 2 | 8 | 6 | 10 | rinse 3, magnifier 3 |
| 3 | 3 | 10 | 8 | 12 | rinse 3, magnifier 4, swab 2 |
| 4 | 4 | 12 | 10 | 14 | rinse 4, magnifier 4, swab 3, cutter 2 |
| 5 | 6 | 14 | 12 | 15 | rinse 3, magnifier 3, swab 2, cutter 1 |

Note day 5: charges go **down** while rules and items go up. Difficulty comes from scarcity, not from complexity.

Claw: horizontal speed `220 px/s`, descent `160 px/s`, rise `200 px/s`. Fish drift `40–70 px/s`.

## 17. Text and Language

**All player-facing text in Indonesian.** The judging panel is Indonesian, and the demo video will be too.

Put every string in **one file** — `data/strings.gd`, a dictionary of `key → text`. No string literals scattered across scenes. Item names and rule text live in their `.tres` files; everything else lives in `strings.gd`. This costs nothing now and means changing wording later is one file, not a hunt.

Code, comments, filenames, and documentation stay in English.

## 18. Debug Tools — Build These, They Save Hours

The owner will playtest this constantly. Add a debug overlay toggled by `F1`, active only when `OS.is_debug_build()`:

- Skip to next day
- Refill all tool charges
- Reveal all hidden properties on the current item
- Instantly fill inventory with N random items (skip the claw phase)
- Force grip success / force grip failure
- Set ocean health directly
- Show the current run seed, and let it be re-entered

Also: seed the run RNG from `Game.run_seed` and print it at day start. When something breaks, the owner can reproduce it exactly instead of replaying blind.

Do not skip this section as "not part of the game." Iteration speed is the single biggest factor in how good the prototype gets.

## 19. No Save Game

Settings persist. Run progress does not — closing the game loses the run, and that is correct for a prototype. Do not build a save system.