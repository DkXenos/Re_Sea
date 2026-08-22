# Progress

Playable prototype of **Cakar Laut** — underwater claw machine plus waste
sorting. Godot 4.7.2, GDScript only, statically typed, 2D only.

**Revision 1 is applied.** It changed the shape of the game, not just the
polish: see *What revision 1 superseded* at the bottom for which parts of the
original brief no longer describe this build.

---

## How to run

```bash
godot                                    # play it
godot --headless --quit-after 240        # boot check
./tools/smoke/run_all.sh                 # every check (~5 min)

# per-day numbers from a full simulated run
godot --headless --script tools/smoke/smoke_full.gd -- --realtime --verbose-days
```

## Source of truth for content — decided in revision 1

**The `.tres` files in `data/` are canonical.** Items, hotspots, rules, tools
and days are edited in the Godot inspector. There is no longer any generator
that can overwrite them: `tools/gen_data.gd` and `tools/content.json` were
deleted, because two sources of truth diverge.

Schema changes arrive as one-off scripts in `tools/migrations/`, kept in the
repo as a record of what changed and when.

`tools/content.py` survives as **art parameters only** — which shape, which
colour, which code to draw on a placeholder. It holds no game content and
becomes obsolete when the designers deliver real art.

Regenerating placeholders:

```bash
python3 tools/gen_placeholders.py        # all PNGs + SpriteFrames + ASSETS.md
python3 tools/gen_sounds.py              # all WAVs

# Hotspot rings, generated FROM data/items/*.tres so they cannot disagree with
# the coordinates the game checks. Twice, with an import between: Godot cannot
# load a PNG it has not imported yet.
godot --headless --script tools/gen_hotspot_overlays.gd
godot --headless --import
godot --headless --script tools/gen_hotspot_overlays.gd
```

---

## What is built

The original seven phases are complete. Revision 1 then changed:

| § | Change | State |
|---|--------|-------|
| 1 | No code-driven animation; everything animated is `AnimatedSprite2D` + `SpriteFrames` | done |
| 2 | Fish are background only — no collision, no grab, no penalty | done |
| 3 | Seabed scrolls (2600 units), `Camera2D` follows the claw, minimap, targeting fix | done |
| 4 | Items drift in over the shift; the tank never starves | done |
| 5 | One shift budget replaces max grabs and per-tool charges | done |
| 6 | Claw and desk are two tabs of one shift | done |
| 7 | All five inspect-legibility fixes | done |
| 8 | New health formula; a clean day raises the meter | done |
| 9 | One source of truth for content, decision recorded above | done |
| 10 | Smoke suite updated, two new invariant checks added | done |

**Definition of Done — verified, not assumed.** `run_all.sh` runs 17 checks:
4 static rules, 2 boot checks, and 11 simulations.

- Zero code-driven animation on game objects — static-checked every run
- `assets/ASSETS.md` lists every PNG **and** every animation with its target
  frame count, plus the hotspot-overlay rules for final art
- Fish have no `Area2D` and no collision shape — `smoke_claw` asserts it
- Seabed scrolls, camera follows, minimap present, and the grip preview names
  the item the claw actually returns — `smoke_claw` asserts it on the
  discriminating case
- Items drift in and the tank never drops below `min_available_items` while the
  pool is unexhausted — `smoke_shift` samples this every physics frame
- Budget accounting is exact, and idling 60 frames costs nothing —
  `smoke_shift` asserts both
- Claw and desk share one budget and one inventory, switchable at any time
- All five inspect fixes — `smoke_inspect` asserts each one separately
- A clean day raises the meter — `smoke_report` asserts it
- Adding an item, rule or day needs only a `.tres` — `smoke_extensibility`
  creates all three, drives both views with them, and deletes them
- Exactly two autoloads; no `ColorRect`, `draw_*` or 3D nodes anywhere

---

## Needs Human

Nothing is blocked. These are the items only you can decide or supply.

### Tuning — proposed values, yours to decide

Everything below is a starting point from the revision brief, not a tuned value.

| Knob | Current | Where |
|------|---------|-------|
| Action costs | drop 6, tool 4, sort 1 | `Game.ACTION_COST` |
| Daily budget | 90 / 110 / 130 / 150 / 160 | `data/days/*.tres` |
| Quota | 5 / 6 / 8 / 10 / 12 | `data/days/*.tres` |
| Clean-day bonus | +5 | `Game.CLEAN_DAY_BONUS` |
| Seabed width | 2600 units (2.6× the visible tank) | `@export` on `claw_phase` |
| Spawn pacing | seed 40%, every 3.0–6.5 s, floor 4 items | `data/days/*.tres` |
| Fish density | 7–9, drift 25–65 px/s | `@export` on `claw_phase` |
| Claw speeds | 220 / 160 / 200 px/s | `scenes/claw/claw.gd` |
| Grip curve | `clamp(1 - weight*0.15, 0.25, 0.95)` | `scenes/claw/tank_item.gd` |

**Open question the brief asked me to raise:** should unspent budget pay a small
bonus? Ending a shift early with quota met should be a viable strategic choice,
and right now it earns nothing, so there is no reason ever to press *Akhiri
Shift*. A bonus of roughly `unspent / 10` would make it a real decision without
competing with the clean-day bonus. **Not implemented** — §8 gave an exact
formula and I did not want to quietly add a term to it.

### Still yours to supply

- **Real art.** Drop PNGs at the paths and sizes in `assets/ASSETS.md`. Read the
  hotspot section there first: the rings are a separate overlay now, and final
  art must draw the hotspot into the item itself at the authored coordinates.
- **Real audio.** Replace `assets/audio/*.wav`, same filenames.
- **Cutscene script.** Three placeholder lines in `data/strings.gd`.
- **Export templates** (GUI-only step) if you want a build.

---

## Balance note — the shape of the shift

The budget question is "grab another item, or examine the one already in hand?".
Here is what each day actually affords, using the real item weights and grip
curve, assuming the player targets the lightest items first:

| Day | Quota | Budget | Drops needed | Sorts | Left for tools | Tool uses affordable |
|-----|-------|--------|--------------|-------|----------------|----------------------|
| 1 | 5 | 90 | 5.3 (32) | 5 | 53 | 13.2 |
| 2 | 6 | 110 | 6.7 (40) | 6 | 64 | 16.0 |
| 3 | 8 | 130 | 9.2 (55) | 8 | 67 | 16.7 |
| 4 | 10 | 150 | 11.5 (69) | 10 | 71 | 17.8 |
| 5 | 12 | 160 | 14.2 (85) | 12 | 63 | 15.7 |

Two things to look at:

1. **Day 1 has 53 spare budget and no tools to spend it on.** It only needs 37
   of its 90. That makes the tutorial completely slack. I would cut day 1 to
   **60** — still comfortable, but the number starts meaning something on the
   day the player first learns to read it.
2. **The scarcity lands about right from day 2 on.** ~16 tool uses against 8–14
   items, each with 2–3 hotspots, means the player can thoroughly examine
   roughly half of what they collect. That is the intended pressure. Day 5 is
   the tightest at 15.7 uses for 14 items, which is correct for the last day.

A run that sorts everything correctly now finishes at **100/100**: the clean-day
bonus plus `correct × 2` outruns the shortfall penalty, so playing well visibly
heals the ocean. Sorting everything wrong still bottoms the meter out on day 4.

---

## Shortcuts taken

- **`min_available_items` overrides `initial_seed_fraction` on small pools.**
  Day 1 would otherwise open with 2 items against a floor of 4 and the player
  would start by waiting. The fraction is the intent; the floor wins.
- **Rules carry a `short_text` as well as `text`.** The inspect checklist needs
  one line per rule and the rulebook shows the full sentence verbatim. Authoring
  the short form as data beats truncating in code, but it is one more field to
  keep in sync when you write a new rule.
- **The bin hint solves the puzzle once the evidence is revealed.** That is
  deliberate — §7.2 asked for exactly this — but it does mean a player who
  inspects thoroughly is told the answer. The cost of inspecting is what keeps
  that honest.
- **Placeholder hotspot rings are visible by default.** They now live in a
  separate overlay and can be switched off in settings or with F1, so the owner
  can test the real difficulty. Final art must integrate them.
- **Fish count and speed are `@export` on the tank, not `DayData`.** Density is
  an atmosphere knob, not a difficulty one, so it is deliberately not per-day.
- **The claw view still owns the tank's spawning.** If the tank ever needs to
  keep running while unloaded, that logic moves to `Game`.

## Known bugs

None outstanding. Fixed during revision 1:

- The grip preview named a neighbouring item when items overlapped: it measured
  horizontal distance to the claw origin while the grab measured distance to the
  grab point. Both now come from `claw.predict_target()`, and the claw honours
  the prediction at resolve time.
- Slipped items were reparented to `TankWorld` instead of the item holder.
- Rebuilt UI lists left stale children for the rest of the frame.
- A failed `assert` in a smoke script left the SceneTree running forever instead
  of failing, which looked like a hang. `run_all.sh` now enforces a time limit
  per check and reports an overrun as a failure.
- The claw phase would not end when the budget could afford a sort but not a
  drop, stranding the player at a tank they could not use. Moot now that the
  shift owns the ending, but it was real.
- The desk only refreshed its inventory when it became the active view, so a
  harness that sorted without switching tabs saw an empty selection forever.

## Deliberately not built

Cleaning minigames, dialogue with senders, item disassembly, upgrade shop, story
mode, **save games** (settings persist in `user://settings.cfg`; run progress
does not), screen transitions, particles, juice passes, audio mixing.

---

## What revision 1 superseded

These parts of the original brief no longer describe this build:

| Original | Now |
|----------|-----|
| §7 — fish are grabbable obstacles, grabbing one costs ocean health | Fish are background only: no collision, no grab, no penalty (rev §2) |
| §7 — `max_grabs` per day ends the claw phase | One shift budget; a drop costs 6 (rev §5) |
| §5 / §6.1 — per-tool daily charges | Tools cost budget like everything else (rev §5) |
| §8 — `claw_phase → desk_phase` are sequential | Two tabs of one `shift` phase (rev §6) |
| §15 — `correct*1 … − fish*2 …` | `correct*2 − wrong*4 − shortfall + clean bonus` (rev §8) |
| §13 — `rulebook → Tab` | `Tab` switches views; the rulebook is `R` (rev §6) |
| §3 — hotspot markers drawn into the item PNGs | A separate, switchable overlay generated from the `.tres` (rev §7.5) |
| §16 — quota / max grabs / tool charge tables | Budget and quota tables above |
| The layer table's "100 = inventory, inspect, rulebook" | Desk view content is at 10; only the rulebook is modal at 100 |

Sections **not** touched and still accurate: the data model (§5), rule
resolution, the day report's structure (§8), settings and audio (§14), the
debug overlay (§18), no save game (§19), and every constraint in §2 and §2.1.
