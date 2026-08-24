# Progress

Playable prototype of **Cakar Laut** — underwater claw machine plus waste
sorting. Godot 4.7.2, GDScript only, statically typed, 2D only.

**Revisions 1, 2 and 3 are applied.** Revision 1 changed the shape of the game,
revision 2 gave it a reason to play, and revision 3 made that reason visible in
normal play - revision 2's systems all worked and almost none of them fired in
a real run. See *What the revisions superseded* at the bottom.

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

Revision 2 then added the "why":

| § | Change | State |
|---|--------|-------|
| 1 | Four ocean recovery tiers, changing only at the day report | done |
| 2 | Three technology blueprints, progress always visible on the desk | done |
| 3 | Property-first identification: the name is earned, not given | done |
| 4 | Two upgrades, one taken per run, both trade-offs | done |
| 5 | Calibration puzzle, isolated behind a flag — **experimental, may be cut** | done |
| 6 | Smoke suite updated: three new checks and a two-run flag comparison | done |

Revision 3 then made all of it reachable inside two days:

| § | Change | State |
|---|--------|-------|
| 1 | Asset rules audited and enforced by grep; six real violations fixed | done |
| 2 | Starting health 35, blueprint counts cut, tier art deferred for a text label | done |
| 3 | `after_day` screen with three tabs, entered every single day | done |
| 4 | Four upgrades, two on day 1, swappable daily, active one shown in the HUD | done |
| 5 | Puzzle unchanged, entry point moved to the Teknologi tab | done |
| 6 | Every progression check now runs through played runs, not hand-set state | done |

**Definition of Done — verified, not assumed.** `run_all.sh` runs 28 checks:
9 static rules, 2 boot checks, 16 simulations and one two-run comparison.

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
- Four ocean tiers, every health value in exactly one of them, each visibly
  different, and the tier only moving at the report — `smoke_ocean` asserts it
- A run of correct sorting reaches a blueprint **and** a tier rise; a perfect
  day never loses ground; blueprint bonuses cannot pass 100 — `smoke_ocean`
- Neither upgrade can ship with only its benefit filled in, and choosing one
  never touches the shift budget — `smoke_upgrades` asserts both
- The calibration puzzle explains *why* an order is wrong, failing is free, and
  with the flag off a whole run on one seed ends identically — `smoke_puzzle`
  plus the two-run comparison in `run_all.sh`
- **A played run** crosses two tier thresholds, claims at least two blueprints,
  and claims the first by the end of day 2 — asserted in `smoke_full`, from the
  real scenes, on seven seeds checked by hand
- **A played shift** with Cakar Ringan fitted spends measurably less and grips
  measurably worse than the same shift without it, and the coarse scanner
  probes for 2 without reading and reads for 4 — `smoke_upgrade_play`
- No `_draw`, `draw_*`, `Polygon2D`, `Line2D`, `ColorRect`, `ShaderMaterial`,
  `CanvasModulate`, `PointLight2D`, `StyleBoxFlat`, runtime-built texture,
  state-tint on a game object, unnamed sprite scale, or per-asset `if id ==`
  anywhere — six separate static checks

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
| Grip curve | `clamp(1 - weight*0.15 + upgrade, 0.05, 0.95)` | `scenes/claw/tank_item.gd` |
| Starting ocean health | 35 | `Game.STARTING_HEALTH` |
| Tier thresholds | 0–25 / 26–50 / 51–75 / 76–100 | `data/tiers/*.tres` |
| Per-tier fish / coral / debris (deferred art) | 0,5,9 · 2,4,6 · 6,4,3 · 10,7,0 | `data/tiers/*.tres` |
| Fish in the tank | 9 | `@export` on `claw_phase` |
| Blueprint requirements | 2R · 4H+2O · 6R+3O+2H | `data/blueprints/*.tres` |
| Blueprint health gains | +8 / +10 / +12 | `data/blueprints/*.tres` |
| Upgrade trade-offs | drop 4/−15pp · tool 2/coarse · ×1.6 speed/2s lockout · +15pp/drop 8 | `data/upgrades/*.tres` |
| Calibration puzzle bonus | +2 | `scenes/puzzle/calibration_puzzle.gd` |

**Open question the brief asked me to raise:** should unspent budget pay a small
bonus? Ending a shift early with quota met should be a viable strategic choice,
and right now it earns nothing, so there is no reason ever to press *Akhiri
Shift*. A bonus of roughly `unspent / 10` would make it a real decision without
competing with the clean-day bonus. **Not implemented** — §8 gave an exact
formula and I did not want to quietly add a term to it.

### What a played run actually produces — tune from these

Every number here came from driving the real scenes, not from arithmetic on the
data. Seed 777, a run that sorts everything correctly:

| Day | Health | Tier | Blueprints claimed |
|-----|--------|------|--------------------|
| 1 | 35 → 52 | Sedang | Penyaring Mikroplastik |
| 2 | 52 → 73 | Sedang | — |
| 3 | 81 → 100 | Pulih | Penetral Limbah B3 |
| 4 | 100 → 100 | Pulih | — |
| 5 | 100 → 100 | Pulih | Pemulih Terumbu |

Seven seeds checked: every one crosses two tier thresholds, claims all three
blueprints, and claims the first on day 1 or 2. A run that sorts everything
wrong reaches the loss condition on day 2.

**The one thing I would look at:** the meter reaches 100 on day 3 and then has
nowhere to go, so days 4 and 5 show no movement — the same complaint as before,
just moved later in the run. Options are a lower starting health, a smaller
`correct × 2`, or five days of content where the last two are hard enough to
lose ground on. I did not pick one because it is a difficulty decision, not a
bug.

Blueprint requirements: the brief proposed 5 / 4+2 / 6+3+2. Measured against
what days 1–2 actually supply, 5 RECYCLABLE lands on day 3, so Penyaring
Mikroplastik is **2**. The other two are as the brief specified. The ceiling
for a flawless five-day run is ORGANIC 10, RECYCLABLE 7, HAZARD 15,
LANDFILL 18 — recyclables are the scarce material, and days 1–2 hold only three
of them between them.

### Both claw upgrades are mistuned, and here is the table

Budget spent per **successful** grab, computed from the real item weights and
the grip curve. Lower is better:

| Item | Weight | Grip | Plain (6) | Cakar Ringan (4, −15pp) | Cengkeraman Kuat (8, +15pp) |
|------|--------|------|-----------|--------------------------|------------------------------|
| banana_peel | 0.3 | 0.95 | 6.32 | **5.00** | 8.42 |
| pet_bottle | 0.6 | 0.91 | 6.59 | **5.26** | 8.42 |
| glass_jar | 2.0 | 0.70 | 8.57 | **7.27** | 9.41 |
| fishing_net | 2.6 | 0.61 | 9.84 | **8.70** | 10.53 |
| car_battery | 4.2 | 0.37 | 16.22 | 18.18 | **15.38** |

Across all fourteen items: **Cakar Ringan is the best claw for thirteen of
them, and the plain claw is never the best for any.** Cengkeraman Kuat only
pays on the car battery. So one upgrade is close to mandatory and the other is
close to useless.

The arithmetic: Cakar Ringan breaks even at a **−27pp** grip penalty, not −15.
Cengkeraman Kuat breaks even at a drop cost of **7**, not 8. Their crossover
sits at grip 0.45, which is weight 3.67 — and only one item in the game is
heavier than that.

**Proposals:** Cakar Ringan **−30pp**, Cengkeraman Kuat **cost 7**. But the
deeper cause is the weight spread: thirteen of fourteen items weigh under 2.6,
so grip is almost never the binding constraint and a claw upgrade has little to
bite on. Widening the weights would fix both upgrades at once and is probably
the better lever.

I have shipped the values the brief specified, as §8 asked, and each is one
number in one `.tres` if you want them changed.

### Does the calibration puzzle earn its place? — my honest read

**What it cost:** about 300 lines across `scenes/puzzle/`, two scenes, seven
strings, one flag, one call site and one smoke check. Revision 3 moved its
entry point into the Teknologi tab for the cost of deleting three lines and
adding four. Isolation stayed cheap because it touches nothing — no health
formula, no budget, no counters.

**What it adds:** the failure lines. *"Air dibuang sebelum disaring. Residunya
ikut keluar."* is the only place in the game that explains a process rather
than a category, and in a judged Q&A that is worth having.

**What it does not add:** any decision. Four items reorder in seconds, failure
costs nothing, and there is a skip button. It is a reading exercise wearing a
puzzle's clothes. Revision 3 made this worse rather than better: blueprints now
complete on day 1 and land three times a run instead of once, so the same
four-step reorder interrupts three times.

**My recommendation, unchanged and now stronger: cut the interaction, keep the
words.** Show the ordered sequence and its explanation as a panel in the
Teknologi tab and you keep all of the educational value and lose none of the
pacing. If you would rather keep
it playable, keep it — it is genuinely free to leave in, and `run_all.sh`
proves the game is identical with the flag off. That check is there so this
stays your decision rather than mine.

### How to reach the upgrades — this was not obvious in the playtest

Upgrades are not bought and there is no shop. Finish a day, and the **after-day
screen** appears after the report. It has three tabs:

- **Hasil Hari Ini** — the day's haul.
- **Teknologi** — the three blueprints. When one has its materials, its
  **Klaim** button lights up. Claiming applies its health bonus (and, if the
  calibration puzzle is still switched on, opens it).
- **Peralatan** — the upgrades. Press **Pakai** on any unlocked one. Two are
  available from day 1; Rel Cepat opens after the first claimed blueprint and
  Cengkeraman Kuat after the second. Pressing Pakai on the fitted one takes it
  off again, and the choice can be changed every night.

The fitted upgrade and the costs it changes are shown in the shift bar while
playing, so its effect is legible without opening a menu.

### Still yours to supply

- **Real art for the ocean tiers first.** `seabed_tier_0..3.png`,
  `coral_healthy.png`, `coral_dead.png`, `debris_overlay.png`. This is the
  single best-looking part of the game and the cheapest place for a designer to
  make a difference — four seabeds and two corals carry the whole "the ocean is
  recovering" idea.
- **Real art.** Drop PNGs at the paths and sizes in `assets/ASSETS.md`. Read the
  hotspot section there first: the rings are a separate overlay now, and final
  art must draw the hotspot into the item itself at the authored coordinates.
- **Real audio.** Replace `assets/audio/*.wav`, same filenames.
- **Cutscene script.** Three placeholder lines in `data/strings.gd`.
- **Flavour text review.** Three blueprint lines and two upgrade descriptions
  in `data/blueprints/*.tres` and `data/upgrades/*.tres`. They are deliberately
  plain and claim nothing technical about chemistry, since the team has no
  chemist and has to defend every line.
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
- **Item placeholders no longer carry a material code.** They used to be
  stamped `PET`, `ORG`, `B3` and so on, which made them easy to tell apart in a
  screenshot and quietly answered the question the inspect phase exists to ask.
  Placeholders are now shape and colour only. Fourteen distinct shapes is enough
  to tell them apart, and it is a stamp no designer was going to reproduce.
- **Placeholder hotspot rings are visible by default.** They now live in a
  separate overlay and can be switched off in settings or with F1, so the owner
  can test the real difficulty. Final art must integrate them.
- **Fish count and speed are `@export` on the tank, not `DayData`.** Density is
  an atmosphere knob, not a difficulty one, so it is deliberately not per-day.
- **Tier art is deferred, not cancelled.** The four seabeds, the water tints,
  the coral and the debris counts are all still authored in `data/tiers/*.tres`
  and the placeholder PNGs still exist — nothing reads them. The thresholds are
  0–25 **Buruk**, 26–50 **Sedang**, 51–75 **Baik**, 76–100 **Pulih**, and the
  shift bar shows that name. Re-enabling means restoring `_apply_tier()` and
  `_spawn_decor()` in `claw_phase.gd` and hanging the coral off the `Decor`
  node, which is still in the scene and still empty. That is the whole cost.
- **The ocean tier's transition line lives in the `.tres`, not `strings.gd`.**
  Same reasoning as rule text: it is content, one line per tier, and a fifth
  tier must not need a code or table change to say something.
- **The calibration puzzle keeps its own step and failure text.** §5 required
  that deleting `scenes/puzzle/` remove the feature completely, which a
  `strings.gd` dependency would break. Only its UI chrome is in `strings.gd`,
  in a block marked for deletion with it.
- **The puzzle has a skip button, which the brief did not ask for.** An
  experimental feature must never be able to block a run in a demo. It is one
  button and it goes with the folder.
- **"Forces tier 3 art if health allows" reads as: not below the tier under
  it.** Pemulih Terumbu pushes the art to tier 3, but the push is withdrawn if
  the ocean falls under 51. Painting a healed reef over a dying ocean would be
  a lie, and that is the most defensible reading of "if health allows".
- **The claw view still owns the tank's spawning.** If the tank ever needs to
  keep running while unloaded, that logic moves to `Game`.

## Known bugs

None outstanding. Fixed after the revision 3 playtest:

- **Dragging a step in the calibration puzzle did nothing and printed an error.**
  `step_row.gd` walked up a fixed number of parents to find the puzzle, and the
  script sits on the `CanvasLayer`, one level further up than the count assumed.
  Every drop landed on a bare `Control`. The puzzle is now handed to each row
  explicitly. `smoke_puzzle` had set `_order` directly, so it passed while the
  only way a player can reorder was broken — it now drives `_drop_data`.
- **The desk sat underneath the shift bar.** Revision 3 grew the bar from 46 to
  74 pixels for the ocean and upgrade labels and nothing below it moved, so the
  inventory title, the blueprint strip and the rulebook button were all partly
  covered.
- **Three blueprint progress bars were 320x32 instead of 88x5**, painting over
  the rulebook button and cutting its label in half. `TextureRect` clamps `size`
  against its texture at the moment you assign it, and `expand_mode` was being
  set on the line after. Order matters; `_meter()` now holds it in one place.
- **A NinePatch drew its corners on top of each other** in the 38px blueprint
  rows, because the patch margins were 24 top and bottom. They are 14 now.
- **Inventory card text was cut mid-word.** A `Label` sized by hand kept one
  line and overflowed; the card is an `HBoxContainer` now, so autowrap works.

`smoke_layout.gd` was written for this class of bug and asserts geometry: that
nothing on the desk hides under the shift bar or runs off screen, that the
blueprint strip stays inside its panel and clear of the rulebook button, that
every control stays in the box it was given, and that the inspect panel always
identifies the item somehow.

Fixed during revision 3:

- **Items could spawn where the claw could never reach them.** The jitter on the
  first lane of `_spawn_items` could place an item at negative x, outside the
  claw's rail limits. It still counted as work waiting in the tank, so a player
  aiming at it burned drop after drop on nothing — on seed 5, day 1 ended with
  fifteen drops, the entire 90 budget, and zero items collected. Spawns are now
  clamped to the claw's own limits, so the two cannot drift apart. This was
  found only because revision 3 required the progression checks to run through
  real play; every previous check set state by hand and never saw it.

Fixed during revision 1:

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

## What the revisions superseded

These parts of the earlier briefs no longer describe this build.

**Revision 3 over revision 2:**

| Was | Now |
|-----|-----|
| The run starts at 100 health, already the top tier | Starts at 35, and a good run climbs through two thresholds (rev 3 §2.1) |
| Four sets of tier art: seabed swap, water tint, coral, fish counts | One text label, `Laut: Buruk / Sedang / Baik / Pulih`. The art is deferred, the data kept (rev 3 §2.3) |
| A blueprint auto-claims on an unlock screen that fires once a run | The player claims it in the Teknologi tab, on a screen entered every day (rev 3 §3) |
| One upgrade chosen for the whole run, offered once | Four upgrades, two from day 1, swapped freely between days (rev 3 §3, §4) |
| `… → report → [unlock] → day_start` | `… → report → after_day → day_start` |
| ItemData carries `revealed_by_<tool>` booleans | The hotspot's own `tool` key, which was always what the game checked (rev 3 §1.6) |
| Fish scale and fade by depth; bubbles scale randomly | Depth picks which fish PNG, and nothing scales or tints designer art (rev 3 §1.4, §1.5) |
| A locked tool is dimmed; a selected slot is tinted | Each is its own PNG or its own named animation (rev 3 §1.4) |
| Progression asserted from hand-set health and stats | Asserted from runs played through the real scenes (rev 3 §6) |

**Revision 2 over revision 1:**

| Was | Now |
|-----|-----|
| Fish count and speed are both `@export` on the tank | Count comes from the ocean tier; only speed is an `@export` (rev 2 §1) |
| The seabed is one fixed backdrop | Four tier backdrops, swapped at the day report (rev 2 §1) |
| `main_menu → cutscene → day_start → shift → report` | `… → report → [unlock] → …`, one unlock screen per completed blueprint (rev 2 §2) |
| The inventory card and the claw readout name the item | They describe it until the name has been earned (rev 2 §3) |
| `Game.cost_of()` is the action cost | `base_cost()` is the action cost; `cost_of()` applies the run's upgrade (rev 2 §4) |
| Layer 100 is the rulebook | The rulebook and the experimental calibration puzzle (rev 2 §5) |

Nothing revision 1 built was removed. The shift model, the budget, the rule
resolver, the health formula and the inspect panel are all untouched — the
health formula in particular, since blueprint and puzzle bonuses are applied
outside it precisely so the report's arithmetic stays traceable.

**Revision 1 over the original brief:**

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
