# Progress

Playable prototype of **Cakar Laut** — underwater claw machine plus waste
sorting. Godot 4.7.2, GDScript only, statically typed, 2D only.

---

## How to run

```bash
godot                                    # play it
godot --headless --quit-after 240        # boot check
./tools/smoke/run_all.sh                 # every check (~3 min)
```

Regenerating content (only needed if you change `tools/content.py`):

```bash
python3 tools/gen_placeholders.py        # all PNGs + SpriteFrames + ASSETS.md
python3 tools/gen_sounds.py              # all WAVs
python3 tools/content.py                 # content.json
godot --headless --script tools/gen_data.gd -- --force   # rewrites data/*.tres
```

`gen_data.gd` **refuses to overwrite existing `.tres` without `--force`.** After
the initial bootstrap the `.tres` files are the source of truth — edit them in
the Godot inspector, not in Python.

---

## What is built

| # | Deliverable | State |
|---|-------------|-------|
| 0 | project.godot, folders, autoloads, input map, `CLAUDE.md` | done |
| 1 | `gen_placeholders.py`, 78 PNGs, 11 WAVs, 26 `SpriteFrames`, `ASSETS.md` | done |
| 2 | Data classes + all `.tres` (14 items, 6 rules, 4 tools, 5 days) | done |
| 3 | Claw phase: movement, drop, grip roll, fish, inventory handoff | done |
| 4 | Desk phase: inventory, inspect, zoom/pan, charges, hotspots, evidence log | done |
| 5 | `rule_checker.gd`, bins, day report, ocean meter | done |
| 6 | Menu, settings + persistence, cutscene, day flow, pause, game over, debug overlay | done |
| 7 | `PROGRESS.md`, `WALKTHROUGH.md` | done |

**Definition of Done — all verified, not assumed:**

- Headless run: zero errors, zero orphan/leak warnings (`run_all.sh`, 11 checks)
- Playable start to finish: menu → cutscene → 5 days → report → ending. Both
  endings reached in automated play (`smoke_full.gd`, with and without `--bad`)
- Every visual is a PNG in `assets/`; `grep` confirms zero `ColorRect`, zero
  `draw_*`, zero 3D nodes, zero non-texture `StyleBox`
- Claw, fish, items, bins and tools are already `AnimatedSprite2D` +
  `SpriteFrames` with one frame per animation
- `assets/ASSETS.md` is emitted by the generator, so it cannot go stale
- **Adding an item or rule needs only a `.tres`** — `smoke_extensibility.gd`
  adds item #15, rule #7 and day #6 as `.tres`, drives both phases with them,
  and deletes them, with zero code changes
- Exactly two autoloads (`Events`, `Game`)
- All four settings sliders verified to change something real

---

## Needs Human

Nothing is blocked. These are the items only you can decide or supply.

**Not blocking — already handled:** Godot install (4.7.2 found on PATH), the
input map (written into `project.godot` by hand and verified — all nine actions
parse), `.tscn`/`.tres` authoring, headless verification, git.

### Subjective values — proposed, yours to decide

All of these are starting points from §16 of the brief, not tuned values.

| Knob | Current | Note |
|------|---------|------|
| Claw horizontal speed | 220 px/s | `scenes/claw/claw.gd` |
| Descent / rise speed | 160 / 200 px/s | descent is the commitment, rise is the tension |
| Grip curve | `clamp(1 - weight*0.15, 0.25, 0.95)` | see the balance note below |
| Fish count | 4 per day, drift 40–70 px/s | fixed, not per-day; a `DayData` field would fix that |
| Tool charges | §16 table | in `data/days/*.tres` |
| Quota / max grabs | §16 table | **day 5 needs a look — see below** |
| Item weights | 0.3 – 4.2 | `tools/content.py`, mirrored into `data/items/*.tres` |

### Still yours to supply

- **Real art.** Drop PNGs at the paths and sizes in `assets/ASSETS.md`. Read the
  hotspot section there first — the placeholder rings must become real features
  of the drawing (a stain, a printed code, a seam) at the same positions.
- **Real audio.** Replace `assets/audio/*.wav`, same filenames.
- **Cutscene script.** Three placeholder lines in `data/strings.gd`
  (`cutscene_line_1..3`). Three stills in `assets/env/cutscene_0*.png`.
- **Export templates** (GUI-only step) if you want a build.

---

## Balance note — read this before tuning anything else

An automated run that sorts **everything correctly** still only finishes at
**92/100**. The pressure in this build is in the claw phase, not the sorting.

Expected grabs needed, from the grip curve and the real item weights:

| Day | Quota | Max grabs | Expected grabs to hit quota (lightest first) | Headroom |
|-----|-------|-----------|---------------------------------------------|----------|
| 1 | 5 | 8 | 5.3 | +2.7 |
| 2 | 6 | 10 | 6.7 | +3.3 |
| 3 | 8 | 12 | 9.2 | +2.8 |
| 4 | 10 | 14 | 11.5 | +2.5 |
| 5 | 12 | 15 | **14.2** | **+0.8** |

Day 5 is the outlier: even playing optimally the quota is barely reachable, and
one mis-aimed grab into a fish blows it. Days 1–4 sit at a comfortable +2.5 to
+3.3. Three options, in the order I would try them:

1. Day 5 `max_grabs` 15 → 18 (`data/days/day_05.tres`), keeping quota 12.
2. Day 5 `quota` 12 → 10.
3. Soften the grip curve for heavy items — the `car_battery` at weight 4.2 sits
   at 37%, which costs ~2.7 grabs on average for one item.

Two smaller observations from the same runs:

- **Correct sorts pay very little.** A perfect day nets +1 or +2 because
  `correct * 1` barely offsets fish and shortfall. The 4× asymmetry on wrong
  sorts is exactly right and should stay; the question is whether a clean day
  should feel like progress rather than treading water.
- **Fish are expensive and easy to hit by accident** (−2 each, and the claw
  closes on whatever it touches first during descent). Consider fewer fish, or
  giving them a lane that does not overlap the seabed items.

---

## Shortcuts taken

Called out so you know where the seams are.

- **Fish count and speed are constants** in `claw_phase.gd`, not `DayData`
  fields. Everything else that varies per day is data.
- **Day 5's seabed is crowded.** 14 items across ~800px means ~57px lanes, so
  items overlap and the grip preview sometimes names a neighbour. Fine at 6–12
  items; a second row or a wider tank would fix it.
- **The inspect item is centred at a fixed 2× base scale.** Items are all
  160×160 so it works, but a non-square asset would need
  `BASE_SCALE` in `inspect_panel.gd` to become per-item.
- **Bin `reject` only plays when you click a bin with nothing selected.** A bin
  taking a wrong item still plays `accept`, deliberately — correctness is
  withheld until the report. The `reject` animation exists and is wired, but is
  a rare state in normal play.
- **The `inventory` action (`I`) is a "jump to next unsorted item" shortcut**,
  not a panel toggle, because the desk grid is always on screen.
- **Placeholder hotspot rings are drawn onto the item PNGs.** That makes the
  search trivial right now, which is correct for testing and wrong for the final
  game. `ASSETS.md` tells the designers to remove them.
- **`tools/content.py` duplicates content that now lives in `.tres`.** It was
  the bootstrap and it keeps the hotspot art in sync with the hotspot data. If
  you start editing `.tres` in the inspector, either keep it updated or delete
  it and regenerate art by hand.

## Known bugs

None outstanding. Fixed during the build, noted in case they resurface:

- Slipped items were reparented to `TankWorld` instead of the item holder, so
  they vanished from the tank and from the item count.
- Rebuilt UI lists used `queue_free()` alone, leaving stale children for the
  rest of the frame and double-counting evidence chips.
- `RuleData.matches()` returned `true` for an empty `applies_when`, which would
  have made the day-1 baseline rule force every item to ORGANIC.
- The multilayer traps never explained themselves in the report, because a rule
  keys off `is_multilayer` while the player reveals `true_material`.
- `pause` had no mouse route, breaking the "every action reachable by mouse"
  rule. There is now a pause button at the top right during a run.

## Deliberately not built

Per §6.4 and §19 of the brief: cleaning minigames, dialogue with senders, item
disassembly, upgrade shop, story mode, **save games** (settings persist in
`user://settings.cfg`; run progress does not), screen transitions, particles,
juice passes, audio mixing.
