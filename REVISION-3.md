# Claude Code Brief — Revision 3

> Read `PROGRESS.md` and `WALKTHROUGH.md` first. This revision reacts to a real playtest: after Revision 2, the owner saw almost no difference in actual play.

---

## 0. Why this revision exists

Your own measurement was right, and your diagnosis was honest: the run starts at 100 health — already the top tier — so nothing visibly changes, and everything else is gated behind a blueprint that lands on day 4 of 5. Four-fifths of the game was unchanged.

The response is **not** more polish. This is a prototype. The job is to make each system **testable in normal play**, not to make it look finished.

Two principles for this pass:

1. **Every system must be reachable within the first two days**, or the owner cannot evaluate it.
2. **When choosing between "make it visible" and "make it pretty", always pick visible.** A text label beats a palette shift right now.

Everything from the original brief and Revisions 1–2 still applies: 2D only, exactly two autoloads, content as data, statically typed GDScript, Indonesian player-facing text in `data/strings.gd`, no real-time pressure, and the core tension — *"is this item worth spending shift budget to examine, or do I gamble?"* — stays intact.

Commit per section. Smoke suite green after each.

---

## 1. Asset Rules — Read This Before Writing Any Code

Two designers are producing real art and animation later. The owner will also add lighting and shaders **after** the assets arrive. Everything you build now must be replaceable **file-for-file, with zero code changes**.

The failure mode to avoid is not ugly placeholders — it is **clever code that bakes assumptions about the placeholders into the game**. Keep the visual layer boring and mechanical.

### 1.1 One asset, one file, one node

- **One PNG per asset.** No sprite sheets, no texture atlases, no packed frames. A designer replaces `item_botol.png` with their own `item_botol.png` at the same path and size, and nothing else moves.
- **One node displays one texture.** Do not composite a visual out of several stacked nodes to fake something the art will later contain (do not build a "bottle" from a body sprite plus a separate cap sprite plus a label sprite — one PNG is the bottle).
- **Exception, and only this one:** the hotspot ring overlay is a genuinely separate `Sprite2D` on top of the item, because it is a debug/accessibility layer that real art must not bake in.

### 1.2 No visuals generated in code — ever

Forbidden anywhere in the project:

- `draw_rect`, `draw_circle`, `draw_line`, `draw_polygon`, or any `_draw()` override
- `Polygon2D`, `Line2D`, or `ColorRect` used as a game object or as UI chrome
- `GradientTexture1D` / `GradientTexture2D`, `NoiseTexture2D`, or any texture built at runtime
- `StyleBoxFlat` for panels — panels are `NinePatchRect` over a PNG

If something needs to be visible, it is a PNG on disk.

### 1.3 No shaders, no lighting, no material tricks in this pass

- **No `ShaderMaterial` anywhere.** Not for water, not for glow, not for highlights.
- **No `CanvasModulate`, no `PointLight2D`, no `LightOccluder2D`, no normal maps.**
- **Do not bake lighting or shadows into placeholder PNGs** — flat colour only, so the designers' lit artwork is not fighting a look you invented.

The structure must nonetheless leave room for these later:

- Tank contents stay inside their `SubViewport`, so a water shader can be applied to that one container later without touching a single sprite.
- Keep the `CanvasLayer` numbering from Revision 1 intact (0 water / 10 tank / 20 glass / 30 console / 50 HUD / 100 modals / 200 overlays) so lighting can later be applied per layer.
- Never merge two layers "because it looks the same right now".

### 1.4 Animation: `AnimatedSprite2D` only

- Anything that will ever animate is **already** an `AnimatedSprite2D` backed by a `SpriteFrames` in `data/frames/`, holding one placeholder frame per named animation.
- **Code chooses which animation plays and when. It never describes what the animation looks like.** `sprite.play(&"claim")` is correct. Tweening `position`, `scale`, `rotation`, `modulate`, or `frame` on a game object is not.
- **Do not use `modulate` to express state.** No red tint for wrong, no dimming for disabled, no alpha pulse for "selected" on a game object. State is a named animation, or a separate overlay sprite with its own PNG. Tinting is the first thing that breaks when real art with its own palette arrives.
- Two narrow exceptions remain: **state-driven positional travel** (claw descending, items sinking, camera movement) and **UI feedback** (panel fades, tab switches, counters in the report). UI is not designer art.

### 1.5 Sizes and transforms

- Every sprite node sits at `scale = 1` with its texture at its authored size. Do not scale sprites in code to make placeholders fit.
- Where scaling is genuinely required — the enlarged item in the inspect panel — use **one named constant in one file**, documented in `ASSETS.md`, so a designer knows the target display size.
- Code must never assume a texture's pixel dimensions. Read them from the texture when a calculation needs them, and centre with anchors/offsets rather than hardcoded pixel maths.
- Hotspots stay in **normalized 0–1 coordinates**, so a designer replacing an item at a different resolution does not move them.

### 1.6 No per-asset special cases

There must be no code shaped like `if item.id == "botol": ...`. Anything that differs between items lives in that item's `.tres`. The same rule applies to blueprints, upgrades, and rules. If you feel a special case is needed, add a field to the resource instead and report it in `PROGRESS.md`.

### 1.7 `assets/ASSETS.md` is the designers' contract

The placeholder generator emits it, so it cannot drift. Every entry must state: path, pixel size, what it depicts, whether it is animated, the animation names, and **how many frames the final version should have**. Add a short section at the top explaining the replacement rule — same path, same size, flat art, no baked lighting, hotspots must become real drawn features (a stain, a printed code, a seam) at the authored coordinates.

---

## 2. Numbers — Do These First, They Are Nearly Free

**2.1 Starting ocean health: 100 → 35.** This single value is what makes the reward loop testable at all. A well-played run should visibly climb; a badly-played one should approach the loss condition. Verify the loss condition is reachable but not trivial.

**2.2 Blueprint requirements down sharply**, so the first lands on **day 1 or 2**, not day 4:

| Blueprint | Was | Now |
|-----------|-----|-----|
| Penyaring Mikroplastik | 12 RECYCLABLE | 5 RECYCLABLE |
| Penetral Limbah B3 | 8 HAZARD + 4 ORGANIC | 4 HAZARD + 2 ORGANIC |
| Pemulih Terumbu | 10 + 6 + 4 | 6 RECYCLABLE + 3 ORGANIC + 2 HAZARD |

Then **verify against a real simulated run** what the item pools actually supply across five days. If a requirement still cannot be met, lower it again and report the actual numbers rather than guessing.

**2.3 Ocean tier ART is deferred — do not build it.** Remove or leave dormant the per-tier seabed swaps, palette shifts, and coral/fish count changes from Revision 2. Replace with a **text label in the HUD**: `Laut: Buruk / Sedang / Baik / Pulih`, driven by the same thresholds.

Keep the tier calculation in `Game` — only the visual treatment is deferred. Record it in `PROGRESS.md` as **deferred, not cancelled**, with the thresholds noted so the designers know how many states to draw.

Reason: four sets of tier art is polish on a system whose value is still unproven. Once the owner confirms that a rising meter feels rewarding, the designers build the visuals.

---

## 3. After-Day Scene — The Main Change

Add a scene between the day report and the next day, so every meta system is seen **every day** instead of once per run.

Flow becomes: `shift → day_report → after_day → next shift`

A desk/table view with **three tabs**.

### Tab 1 — Hasil Hari Ini (default)

- Today's collected items laid out on the table as their own PNGs via `Sprite2D`, **not a text list**. This is where the day's work becomes tangible.
- Correct vs wrong sorts. Each wrong one shows the property that was missed and the rule it broke — reuse the existing report logic, do not rewrite it.
- Shift budget spent vs unspent.
- Ocean health change with the text tier label.

### Tab 2 — Teknologi

- The three blueprints with progress counters (`3/5` style).
- A **Klaim** button on any blueprint whose requirements are met; claiming applies its health bonus and marks it complete.
- **This is not a crafting tab.** No free-form combining, no experimenting, no recipe discovery, no failure state, no material inventory to manage. Progress plus a claim button. Build nothing beyond that.

### Tab 3 — Peralatan

- The upgrade list, each stating its benefit and its cost in plain words.
- **Upgrades are equippable and swappable every day**, not locked for the run — the owner must be able to try both within one session. Locking is a balancing decision for later.
- One upgrade active at a time. Locked upgrades show what unlocks them.

Keep the presentation plain: `NinePatchRect` panels over existing UI PNGs, text, and buttons. No transitions, no new animation. Tabs are a standard `TabContainer` or plain buttons swapping visibility — whichever is simpler to read.

---

## 4. Upgrades — Expand to Four

Two was too few for the Peralatan tab to be worth opening. All four are trade-offs; none is a pure improvement.

| Upgrade | Benefit | Cost | Unlocks |
|---------|---------|------|---------|
| **Cakar Ringan** | claw drop costs 4 budget instead of 6 | grip chance −15 points | day 1 |
| **Pemindai Kasar** | tool use costs 2 instead of 4 | coarse result only — *"ada sesuatu di titik ini"*; the exact reading needs a second use at normal cost | day 1 |
| **Rel Cepat** | claw moves 60% faster horizontally | after each drop the rail needs ~2s to re-engage before it can move again | 1st blueprint |
| **Cengkeraman Kuat** | grip chance +15 points | claw drop costs 8 budget instead of 6 | 2nd blueprint |

Two available on day 1 is deliberate: the system must be testable immediately.

`UpgradeData` resources — a fifth must be addable as a `.tres` with zero code changes. The active upgrade's effect must be **visible in the HUD during the shift** (name plus its modified action costs), so its influence is legible while playing rather than only in the menu.

---

## 5. Calibration Puzzle

Keep it exactly as built, behind its flag. Move its entry point into the **Teknologi tab**, triggered by claiming a blueprint, so it sits with what it relates to.

Still experimental. Deleting `scenes/puzzle/` plus the flag and its call site must leave a fully working game. Do not expand it.

---

## 6. Verification

Every check here must run through **normal play**, not by setting state directly. The tier system passed its smoke check only because the check set health by hand — which hid that it never fired in a real run. Do not repeat that.

- A simulated well-played run crosses **at least two tier thresholds** and claims at least two blueprints.
- A simulated badly-played run reaches the loss condition.
- The first blueprint is claimable by **end of day 2** in a competent run.
- Both day-1 upgrades are equippable, and their effects measurably change budget spend and grip outcomes.
- With `feature_calibration_puzzle = false`, a full run completes with identical health results.
- A grep-style check that the asset rules hold: no `_draw`, no `draw_*`, no `Polygon2D`/`Line2D`/`ColorRect`, no `ShaderMaterial`, no `CanvasModulate`/`PointLight2D`, no `StyleBoxFlat`, no `modulate` assignments on game objects, no `if item.id ==` special cases.
- `godot --headless --quit-after 240` — zero errors, zero orphan/leak warnings.

---

## 7. Definition of Done

- [ ] All §1 asset rules hold, verified by the grep check
- [ ] `assets/ASSETS.md` regenerated, with the replacement-rule section at the top
- [ ] Starting health 35; a well-played run visibly climbs; loss condition reachable
- [ ] Blueprint requirements verified against what the pools actually supply
- [ ] Tier art deferred with thresholds recorded; text tier label in the HUD; tier logic retained in `Game`
- [ ] `after_day` scene with three tabs, entered every day
- [ ] Today's items shown as sprites on the table, not a text list
- [ ] Teknologi tab is progress + claim only
- [ ] Four upgrades, all trade-offs, two on day 1, swappable daily, active effect visible in the HUD
- [ ] Puzzle unchanged, flagged, entered from the Teknologi tab
- [ ] Every new check exercises normal play rather than hand-set state
- [ ] `PROGRESS.md` and `WALKTHROUGH.md` updated, tier art listed as deferred

## 8. Stop and Ask For

Into `PROGRESS.md` under `## Needs Human`, then continue with whatever is unblocked:

- All tuning values here are proposals — starting health, blueprint counts, upgrade trade-offs. Report what a real run actually produces so the owner tunes from data rather than guesses.
- An honest assessment of whether the calibration puzzle earns its place, including what it cost to build.
- Real art and audio, export templates.