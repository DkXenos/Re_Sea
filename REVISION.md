# Claude Code Brief — Revision 1

> The prototype is built and playable. This is a **targeted revision**, not a rebuild. Read `PROGRESS.md` and `WALKTHROUGH.md` first, then work through the changes below in order.

---

## 0. Context

The owner playtested the build. The systems work; the **feel** of the claw phase and the **legibility** of the inspect phase do not. Every change below comes from that session.

Rules for this pass:

- **Do not rebuild working systems.** Rule resolution, the data model, the report, settings, pause, and the debug overlay stay as they are.
- **Keep every guarantee from the original brief:** 2D only, two autoloads, content as data, every visual a PNG, statically typed GDScript, no physics engine.
- **Re-run the smoke suite after every change.** If a smoke script no longer matches the new design, update it — don't delete the check.
- Commit per section.

---

## 1. Animation — Read This Before Anything Else

The owner is waiting on real art from two designers. Everything you build in this pass must be swappable without code changes.

**Rules:**

1. **No animation written in code.** No tweening a sprite's `position`, `scale`, `rotation`, `modulate`, or `frame` to fake motion on any game object. If something visually animates, it is an `AnimatedSprite2D` playing a named animation from a `SpriteFrames`.
2. **New animated things get their `SpriteFrames` now**, with a single placeholder frame, exactly as the existing claw and bins do. Adding real frames later must mean dropping images into the existing resource, never touching a script.
3. **Code decides *which* animation plays and *when*. It never decides what the animation looks like.** `sprite.play(&"drift")` is correct; `tween.tween_property(sprite, "position:y", ...)` on a game object is not.
4. **Two narrow exceptions, and only these:**
   - **Positional travel driven by game state** — the claw descending, an item drifting in on the current, camera movement. That is movement, not animation. The sprite still plays an `AnimatedSprite2D` animation while it travels.
   - **UI feedback** — panel fades, chip highlights, number counters in the report. UI is not designer art.
5. **Every new animation goes in `assets/ASSETS.md`** with its path, pixel size, and the frame count the final version should have. Designers work from that file, so it must stay complete.

New `SpriteFrames` needed this pass: `fish_bg_small` / `fish_bg_medium` / `fish_bg_large` (`swim`), `item_drift` (`sinking`), plus `bubble` (`rise`) if you add ambient bubbles.

---

## 2. Fish Become Background

Currently fish are grabbable objects with a −2 ocean-health penalty. Remove that entirely.

- Fish move to a background layer behind the items. No `Area2D`, no collision shape, no grab interaction, no penalty.
- Delete `fish_grabbed` from the health formula in `Game.end_day_breakdown()`, from the day report display, and from the smoke scripts.
- Keep them cheap: sine drift, `AnimatedSprite2D` playing `swim`, a few at different depths and speeds for parallax.
- Density is an atmosphere knob, not a difficulty knob — expose count and speed range as `@export` on the tank so the owner can tune the vibe.

Reason: punishing the player for something that was never a decision reads as unfair, and the system bought nothing. As background, fish do real work — they carry the underwater feel that the designers' art will live in.

---

## 3. Scrolling Seabed and Camera

The tank currently fits on one screen, so there is nothing to search for.

- Widen the seabed to **2.5× viewport width** (3200px at 1280 wide). Make it an `@export` so it can be tuned; do not exceed 3× — beyond that, searching becomes sweeping, which is boring.
- `Camera2D` inside the tank `SubViewport` follows the claw horizontally with position smoothing, clamped to the seabed bounds via `limit_left` / `limit_right`.
- The claw rail spans the full seabed width. `claw_left` / `claw_right` move the claw; the camera follows.
- Add a **minimap or edge indicator** on the HUD: a thin strip showing seabed width, the claw's position, and item positions as dots. Without it, "where was that heavy thing" becomes tedious rather than tense.
- Parallax on the water background layers scales with camera position, not just mouse.

**Fix while you are in here — this is a bug, not a nicety:** the grip preview sometimes names a neighbouring item when items overlap. Target selection must pick the item whose centre is nearest the claw's grab point, and the preview must name that exact item. With a moving camera this misfire gets more frequent, and it breaks the core promise that failure is the player's miscalculation.

---

## 4. Items Drift In on the Current

Items are all pre-placed at day start, so there is no reason to keep watching the tank.

- **Seed the seabed with 40% of the day's items** already resting. Never start empty.
- The rest **drift in from a random screen edge**, sink on a gentle curved path (a slow sine sway while descending), and settle on the seabed. `AnimatedSprite2D` plays `sinking` during travel and `idle` once settled.
- Spawn interval randomized within a range, tuned so **at least 3–4 items are always available**. The player must never have a reason to sit and wait — waiting is dead time, and dead time in a timed shift is punishing rather than interesting.
- Spawning stops once the day's item pool is exhausted.
- Items that drift in while the camera is elsewhere are visible on the minimap. That creates the decision you want: chase it, or keep working this side?

Expose `initial_seed_fraction`, `spawn_interval_min`, `spawn_interval_max`, and `min_available_items` on `DayData` so difficulty per day is data, not code.

Reason for drifting rather than popping: it is physically plausible, it shows the player that trash arrives from somewhere, and it sets up the `source_batch` field for a future "trace the polluter" arc.

---

## 5. Unified Shift Time — Replaces Grabs and Tool Charges

This is the largest change. It removes two systems and replaces them with one.

**Delete:** `max_grabs` as a hard limit, and per-tool daily charges.

**Add:** each day is a shift with a **time budget**, spent by actions:

| Action | Cost |
|--------|------|
| One claw drop | 6 |
| One tool use | 4 |
| Sorting one item | 1 |
| Moving the camera, panning, zooming, opening the rulebook, thinking | **0** |

Starting budget per day (tune later, put in `DayData`):

| Day | Budget | Quota |
|-----|--------|-------|
| 1 | 90 | 5 |
| 2 | 110 | 6 |
| 3 | 130 | 8 |
| 4 | 150 | 10 |
| 5 | 160 | 12 |

**Why this shape matters, and you must preserve it:** time is spent by *actions*, never by the clock. There is no real-time countdown. The player may deliberate as long as they want without penalty. This is deliberate — a ticking timer would destroy the careful inspection that the whole game is built around, while an action-cost budget creates the intended tension: *"do I grab another item, or spend that on examining what I already have?"*

**HUD:** show remaining budget prominently and permanently, in both phases. When hovering an action, show its cost. When the budget is too low for an action, disable it and grey it out with the reason.

The shift ends when budget hits zero or the player ends it early. Ending early with quota met should be a viable strategic choice — consider a small bonus for unspent budget, and note it in `PROGRESS.md` as a tuning question for the owner.

---

## 6. Free Movement Between Phases

Currently the desk phase only opens after the claw phase is exhausted.

- Claw and desk become **two tabs of one shift**, switchable at any time with `Tab`, an on-screen toggle, or a button on each screen. Switching costs nothing.
- Inventory persists across switches. Both tabs share the same shift budget and read from the same `Game` state.
- The tab button shows a count of unsorted items so the player knows work is waiting.
- The day ends from either tab.

Restructure `DayManager` so `claw` and `desk` are sibling views inside a single `shift` phase, rather than sequential phases. Keep the flow graph in one readable place, as it is now.

---

## 7. Inspect Panel Legibility — The Most Important Fix

The owner reported not understanding what to do in this phase. Systems work; nothing communicates. Fix all five:

**7.1 Active rules live inside the inspect panel.** A compact always-visible checklist beside the item — "residu → B3", "multilayer → landfill" — printed verbatim from `RuleData.text`. Keep the TAB rulebook as the full reference, but the player must never have to leave the item to know the rules.

**7.2 Evidence chips light up when they match a rule.** When a revealed chip satisfies an active rule's `applies_when`, highlight the chip **and** highlight the bin that rule forces. The player watches their own reasoning assemble. This is the single highest-value change in this section.

**7.3 A question line above the item.** One sentence framing the decision from surface info, e.g. *"Terlihat seperti plastik PET. Percaya?"*. Generate it from `visible_material` and `visible_label` via a template in `strings.gd`. It tells the player what game they are playing.

**7.4 A tool that finds nothing must say so.** Currently it reads as a dead click. Show explicit feedback — *"Bersih di titik ini."* — plus the budget cost that was spent. Spending for nothing is the design; feeling like nothing happened is a bug.

**7.5 Hotspot rings become toggleable.** They are currently drawn into the item PNGs, which makes the search trivial and means the owner is testing an easier game than the real one. Move them to a separate overlay `Sprite2D` per item, on by default, toggleable from the debug overlay (`F1`) and from settings as an accessibility option. Note in `ASSETS.md` that final art must integrate the hotspot as a real drawn feature — a stain, a printed code, a seam — at the authored coordinates.

---

## 8. Health Formula — Clean Days Must Feel Like Progress

Currently a perfect run ends at 92/100: the ocean never recovers no matter how well the player performs. That contradicts the game's own subject matter.

New formula:

```
health += (correct_sorts * 2)
        - (wrong_sorts * 4)
        - quota_shortfall_penalty
        + clean_day_bonus          # +5 if wrong_sorts == 0 and quota met
```

- `quota_shortfall_penalty = max(0, quota - items_sorted) * 3`
- The `fish_grabbed` term is gone (§2)
- Clamp `[0, 100]`
- The report shows every term on its own line, including the clean-day bonus, as it does now

Keep the 4× asymmetry on wrong sorts — that part is correct and stays. The point is that a well-played day should visibly **raise** the meter.

---

## 9. Single Source of Truth for Content

`tools/content.py` duplicates content that now lives in `.tres`. Two sources of truth will diverge.

Pick one and record the decision in `PROGRESS.md`:
- **Preferred:** `.tres` files are canonical, edited in the Godot inspector. Reduce `content.py` to art generation only — it keeps hotspot art aligned with hotspot data and nothing else.
- Or: `content.py` is canonical and `.tres` are always regenerated, never hand-edited.

Do not leave both live.

---

## 10. Verification

- Update the smoke scripts for the new model: no `max_grabs`, no per-tool charges, no fish penalty, shift budget instead, and phase switching mid-shift.
- Add a check that **budget accounting is exact**: sum of action costs equals budget spent, across a full simulated day.
- Add a check that **an item is always reachable**: at no point during a simulated day are fewer than `min_available_items` items present in the tank while the pool is unexhausted.
- Re-verify the extensibility test still passes with the new `DayData` fields.
- `godot --headless --quit-after 240` — zero errors, zero orphan/leak warnings.

## 11. Definition of Done

- [ ] Zero code-driven animation on game objects; every animated object is `AnimatedSprite2D` + `SpriteFrames` (§1)
- [ ] `assets/ASSETS.md` updated with every new asset and animation, including hotspot-overlay guidance
- [ ] Fish are background only — no collision, no penalty, no grab
- [ ] Seabed scrolls; camera follows; minimap present; grip preview names the correct item
- [ ] Items drift in over the shift; at least `min_available_items` always available
- [ ] One shift budget replaces grabs and tool charges; thinking is free; no real-time timer anywhere
- [ ] Claw and desk switchable at any time, sharing one budget and one inventory
- [ ] All five inspect legibility fixes present
- [ ] New health formula; a perfect day visibly raises the meter
- [ ] One source of truth for content, decision recorded
- [ ] Smoke suite green, including the two new checks
- [ ] `PROGRESS.md` and `WALKTHROUGH.md` updated — including which sections of the original brief this revision supersedes

## 12. Stop and Ask For

As before: write into `PROGRESS.md` under `## Needs Human` and keep working on whatever is unblocked.

- Subjective tuning: budget values, action costs, seabed width, spawn pacing, fish density. Propose numbers, flag them as proposals.
- Real art, audio, cutscene script, export templates.

Anything you can verify yourself — `.tscn`/`.tres` authoring, placeholder generation, headless runs, git — remains yours.