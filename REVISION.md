# Claude Code Brief — Revision 4

> Read `PROGRESS.md` and `WALKTHROUGH.md` first. Two features. Work them in the order given.

---

## 0. How to work this revision

The last passes produced a lot of output for a small amount of visible change. Tighten the loop:

- **Two steps, two commits.** Step A is the mystery box (§2). Step B is the blueprint rework (§3). Finish, verify, and commit A before starting B.
- **Report in under 15 lines per step.** What changed, what the owner should click to see it, what needs his decision. No essays, no restating the brief back, no narrating what you are about to do.
- **Run the full smoke suite once per step, not per edit.** While iterating, run only the check that covers what you just touched.
- **Do not regenerate all placeholders.** Only generate the new PNGs listed here; leave existing assets alone.
- **Do not print file contents, diffs, or directory trees** unless something is broken and it explains the break.
- **Do not refactor anything not named in this brief.** If you think something adjacent needs changing, put one line in `PROGRESS.md` and keep going — do not act on it.
- If a spec here conflicts with something already built, stop and ask in one sentence rather than picking for yourself.

All standing rules still apply: 2D only, exactly two autoloads, content as data, statically typed GDScript, Indonesian player-facing text in `data/strings.gd`, no real-time pressure, and the asset rules in §1 below.

---

## 1. Asset rules for everything new here

The designers replace all of this later. Keep the visual layer mechanical.

- **Every new visual is a flat PNG placeholder** — solid shapes, thin outline, no gradients, no baked lighting or shadow, no texture.
- **No animation on any new asset.** Where a thing has two visual states, that is **two separate PNGs**, not a tint and not a shader.
- Still no `modulate` to express state on world/game objects, no `ColorRect`, no `draw_*`, no `Polygon2D`, no `StyleBoxFlat`, no `ShaderMaterial`, no lighting nodes.
- Objects that live in the tank or on the table use `AnimatedSprite2D` with a `SpriteFrames` holding **one frame per named state** — this costs nothing now and means the designers add frames later without touching a node. The box gets animations `closed` and `opened`.
- **UI-only fade is allowed** — the inventory card fading out after a box is opened is UI feedback, not object animation. Do not extend that permission to anything in the tank.
- Every new PNG goes in `assets/ASSETS.md` with path, pixel size, what it depicts, and the frame count the final version should have.

---

## 2. Step A — Mystery Box

**Before:** every claw grab yields exactly one item. Grab count and sorting load are the same number.

**After:** some spawns are a sealed box. Grabbing it costs one drop like anything else, but it yields 2–3 items. More value per grab, more sorting work per grab.

### Behaviour

1. **Spawn.** Boxes drift in with the current exactly like normal items (Revision 1 §4) and rest on the seabed. One box asset only — no variants, no rarity tiers.
2. **Grab.** Identical to a normal item: same grip roll, same budget cost. Give the box a weight in the middle of the item range so grip chance is unremarkable.
3. **In inventory.** The box appears as a card like any other item, using `box_closed.png`. It is **not sortable** — no bin buttons, no inspect tools. Its only interaction is a **Buka** button.
4. **Open.** Clicking swaps the sprite to `box_opened.png`, waits briefly, then the card fades out (UI fade, allowed) and is removed. In its place, **2–3 normal item cards** are inserted into the inventory list.
5. **From then on** those items behave exactly like grabbed items — inspect, tools, hotspots, sorting, all unchanged.

### Rules and data

- Opening costs **0 shift budget**. The cost is the sorting time of the extra items. Mark this as a tuning question in `PROGRESS.md`, don't invent a cost.
- Contents are drawn from the same day's item pool, using `Run`'s seeded RNG so runs stay reproducible.
- Contents may repeat within a box.
- Add to `DayData`: `box_spawn_count: int` (how many boxes appear that day) and `box_contents_min` / `box_contents_max`. Suggested starting values: day 1 → 0 boxes (keep the tutorial clean), days 2–5 → 1, 1, 2, 2. Contents 2–3.
- The box must never contain another box.

### Assets

| Path | Size | Notes |
|---|---|---|
| `assets/items/box_closed.png` | 160×160 | sealed crate, flat |
| `assets/items/box_opened.png` | 160×160 | same crate, lid open, flat |

One `SpriteFrames` at `data/frames/box.tres` with `closed` and `opened`, one frame each.

### Verify

- A simulated run grabs a box, opens it, and the contents land in inventory and can be sorted normally.
- Box contents are deterministic for a given run seed.
- Budget accounting still balances exactly (opening spends nothing).

---

## 3. Step B — Technology Tab Rework

**Before:** three blueprints, each a flat counter of correctly-sorted categories, with a Klaim button.

**After:** each blueprint is a diagram made of **components**. Each component is crafted separately by spending sorted materials. When every component is crafted, one large button assembles the blueprint into an equippable tool.

This is a **fixed-recipe system**, not an experimental one. There is no free-form combining, no discovering recipes, no failure state, no "what happens if I mix these". Every requirement is authored in data and visible to the player before they commit. Do not add anything beyond that.

### Material pool — the important change

Correctly sorted items now feed a **spendable pool**, not a running total.

- Add `Game.materials: Dictionary` — category → count. A correct sort adds 1 to its category. A wrong sort adds nothing.
- Crafting a component **subtracts** from the pool.
- The pool persists across days within a run.
- The current pool is visible at all times in the Teknologi tab.
- If a craft would take the pool below zero, the button is disabled and shows what is short. Never allow a negative balance.

Blueprint progress from Revision 3 (the flat counters) is replaced by this — remove it rather than keeping both.

### Tab layout

- **Blueprint selector:** `‹` and `›` buttons to page between blueprints, with the name shown between them. No grid, no tabs-in-tabs.
- **Diagram area:** the blueprint background PNG, with each component's PNG positioned on top of it.
  - Uncrafted component → `comp_<id>_locked.png` (greyscale version)
  - Crafted component → `comp_<id>_done.png` (colour version)
  - **Two separate PNGs. Do not greyscale by tinting in code.**
  - Component positions are normalized 0–1 coordinates stored in the blueprint's `.tres`, so replacement art at a different resolution keeps them aligned.
- **Click a component** → popup showing its name, its requirement (e.g. `6 organik, 2 residu`), the player's current pool for those categories, and a **Rakit** button, disabled if short.
- **Bottom of screen:** one large **CRAFT** button, disabled until every component of the current blueprint is crafted. Pressing it completes the blueprint, applies its ocean-health bonus, and unlocks the resulting tool for the Peralatan tab.

### Content — three blueprints, three components each

Nine components total. Keep requirements small enough that the first blueprint completes around day 2.

**Cleaner Drone** *(reuse the owner's sketch)*
| Component | Requires |
|---|---|
| Drone Body | 3 daur ulang |
| Bio Energy Core | 4 organik, 1 residu |
| Intake Fin | 2 daur ulang, 1 organik |

**Penyaring Mikroplastik**
| Component | Requires |
|---|---|
| Filter Mesh | 4 daur ulang |
| Pump Housing | 3 daur ulang, 1 residu |
| Collection Tank | 2 daur ulang, 2 organik |

**Penetral Limbah B3**
| Component | Requires |
|---|---|
| Sealed Chamber | 3 residu |
| Neutralizer Cell | 2 residu, 3 organik |
| Safety Valve | 2 daur ulang, 1 residu |

**Verify these against a real simulated run.** If the pools across five days cannot supply them, lower the numbers and report the actual figures rather than guessing.

### Data model

- `BlueprintData` gains `components: Array[ComponentData]`, a background texture, and its unlocked tool reference. Replace the old `required: Dictionary`.
- New `ComponentData` resource: `id`, `display_name`, `locked_texture`, `done_texture`, `diagram_position: Vector2` (normalized), `requirements: Dictionary` (category → count).
- A fourth blueprint or a fourth component must be addable as `.tres` files with **zero code changes**. Verify this the way the existing extensibility check does.
- Crafted state lives in `Game`, is per-run, and resets with the run.

### Peralatan tab

Unchanged in behaviour: completed blueprints become equippable tools, one active at a time, swappable daily. They join the four upgrades from Revision 3 in the same list — do not build a second equipment system.

### Assets

| Path | Size | Notes |
|---|---|---|
| `assets/ui/blueprint_bg_<id>.png` | 960×540 | flat blue schematic sheet, per blueprint (3 files) |
| `assets/ui/comp_<id>_locked.png` | 128×128 | greyscale placeholder, 9 files |
| `assets/ui/comp_<id>_done.png` | 128×128 | colour placeholder, 9 files |
| `assets/ui/popup_panel.png` | ninepatch | reuse the existing panel if one fits |

### Verify

- A well-played run crafts all three components of one blueprint and presses CRAFT by end of day 3.
- Material pool never goes negative; a short craft is blocked with the shortfall shown.
- Adding a fourth component to a blueprint as a `.tres` requires no code change.
- With everything crafted, the resulting tool appears in Peralatan and can be equipped and unequipped.

---

## 4. Definition of Done

- [ ] Step A and Step B committed separately, each verified before the next
- [ ] Boxes spawn, grab like items, open into 2–3 items, are never sortable themselves
- [ ] Box contents deterministic per run seed; opening costs no budget
- [ ] Material pool spendable, never negative, always visible in Teknologi
- [ ] Blueprint diagram with clickable components; locked/done are two PNGs, no code tinting
- [ ] Component positions in normalized coordinates in `.tres`
- [ ] CRAFT button gated on all components; completed tool equippable in Peralatan
- [ ] Old flat blueprint counters removed, not left alongside
- [ ] All new assets flat, unanimated, in `ASSETS.md` with target frame counts
- [ ] Requirements verified against a real simulated run, actual numbers reported
- [ ] Smoke suite green; `godot --headless --quit-after 240` clean

## 5. Needs Human

Into `PROGRESS.md`, one line each:

- Whether opening a box should cost budget
- Box spawn counts per day
- Component requirement numbers, with what a real run actually supplies
- Real art for boxes, blueprint sheets, and the nine components