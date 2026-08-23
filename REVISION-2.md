# Claude Code Brief — Revision 2

> **Prerequisite: Revision 1 must be finished and verified first.** If any part of it is incomplete, finish that before starting here and say so in `PROGRESS.md`. Read `PROGRESS.md` and `WALKTHROUGH.md` before touching anything.

---

## 0. What this revision is for

The prototype has systems but no **reason to play**. The player sorts correctly and nothing happens; the ocean meter never meaningfully rises. This revision adds the "why".

**What must not change:** the core tension is still *"is this item worth spending shift budget to examine, or do I gamble?"* Nothing here may weaken that. No new resource competes with shift budget. No real-time pressure anywhere — thinking stays free.

**Scope discipline:** this is deliberately small. Three cheap systems plus one experiment. The team considered a full crafting/combination system and a robot programming minigame; both were rejected as out of scope for the 7 September deadline. Do not reintroduce them, and do not "helpfully" expand what is specified below.

Sections 1–4 are approved and ship. Section 5 is an **experiment that may be deleted** — build it last and build it isolated.

All rules from the original brief and Revision 1 still apply: 2D only, two autoloads, content as data, every visual a PNG, statically typed GDScript, **no code-driven animation on game objects** (`AnimatedSprite2D` + `SpriteFrames` only; exceptions remain state-driven positional travel and UI feedback), Indonesian player-facing text in `data/strings.gd`.

Commit per section. Re-run the smoke suite after each.

---

## 1. Ocean Recovery Tiers — Build This First

The highest-value and cheapest change in this revision. The ocean health meter already exists; this makes it **visible**.

**Four tiers**, driven by `Game.ocean_health`:

| Tier | Health | Feel |
|------|--------|------|
| 0 | 0–25 | murky water, no fish, dead coral, heavy debris |
| 1 | 26–50 | slightly clearer, one or two small fish |
| 2 | 51–75 | clear water, coral beginning to grow, more fish |
| 3 | 76–100 | bright water, coral in colour, fish schooling |

**Implementation — no new systems:**
- Tier changes only at the **day report**, never mid-shift. Stability matters more than responsiveness here.
- Each tier is: a water tint/palette shift on the background layers, a swap of the seabed backdrop sprite, and a count of background fish and coral overlay sprites. That is all.
- Coral and debris overlays are `AnimatedSprite2D` with `SpriteFrames` (`idle` sway), one placeholder frame each, per the animation rule.
- Expose tier thresholds and per-tier fish counts as data so they can be tuned without code.
- On the report screen, when a tier boundary is crossed, show a single quiet line — e.g. *"Airnya mulai jernih."* No fanfare, no fireworks, no "YOU SAVED THE WORLD". Restraint is the point.

New assets: `seabed_tier_0..3.png`, `coral_healthy.png`, `coral_dead.png`, `debris_overlay.png`. Add all to `assets/ASSETS.md` with sizes and intended frame counts — the designers will replace these, and this is the single best-looking part of the game for them to work on.

---

## 2. Technology Blueprints — The Goal

Gives the player something to work toward. **This is a progress counter and an unlock screen, not a crafting system.** There is no combining, no experimenting, no failure state, no recipe discovery.

**Three blueprints**, each with a material requirement met by *correctly sorted* items:

| Blueprint | Requires | Effect on unlock |
|-----------|----------|------------------|
| Penyaring Mikroplastik | 12 correct RECYCLABLE | ocean health +8 immediately |
| Penetral Limbah B3 | 8 correct HAZARD + 4 correct ORGANIC | ocean health +10 immediately |
| Pemulih Terumbu | 10 correct RECYCLABLE + 6 correct ORGANIC + 4 correct HAZARD | ocean health +12, forces tier 3 art if health allows |

- Counts accumulate **across the whole run**, not per day. Wrong sorts contribute nothing (they do not subtract here — the health formula already punishes them).
- A compact progress panel is visible on the desk screen: blueprint name and `7/12` style counters. The player must always be able to see what they are working toward.
- On completion: an unlock screen showing the blueprint name, a short line of flavour text, and the health gain. Then back to play.
- Make these `BlueprintData` resources (`data/blueprints/*.tres`) with `required: Dictionary` of category → count. A fourth blueprint must be addable as a `.tres` with zero code changes.

Flavour text should be plainly worded and avoid technical chemistry claims. The team has no chemist and must be able to defend every line in a judged Q&A.

---

## 3. Property-First Identification — Presentation Only

The data already supports this; only the presentation changes. **No new fields, no new systems.**

In the inspect panel, before any tool is used, present surface information as **observed properties** rather than a guessed name:

```
tembus pandang · lentur · mengapung · ada noda
```

instead of `Botol Plastik`. The item's real name appears only after the relevant property is revealed, or when the player sorts it.

This makes the phase feel like identification rather than label-matching, and costs a text template in `strings.gd` plus a display change. Derive the property strings from existing `ItemData` fields — add a `surface_properties: Array[String]` export to `ItemData` if the existing fields cannot express it, and fill it in the existing `.tres` files.

---

## 4. Upgrades — Two, Both Trade-Offs

Unlocked by progress, **not bought with currency**. No money system, no shop economy.

Both unlock after the first blueprint completes. The player picks **one** — the other stays locked for that run. That single choice is the whole system.

| Upgrade | Benefit | Cost |
|---------|---------|------|
| **Cakar Ringan** | claw drop costs 4 budget instead of 6 | grip chance −15 percentage points |
| **Pemindai Kasar** | tool use costs 2 budget instead of 4 | returns a coarse result only — *"ada sesuatu di titik ini"* — without the specific value; the exact reading needs a second use at normal cost |

**Both must be genuine trade-offs, never pure improvements.** An upgrade that only makes things easier makes day 8 feel flatter than day 2, which is exactly the boredom this revision is trying to prevent. If a proposed tuning value turns either of these into a strict win, flag it in `PROGRESS.md` rather than shipping it.

`UpgradeData` as a resource so a third is addable as data. Choice is shown once, on the unlock screen, and persists for the run.

---

## 5. EXPERIMENTAL — Calibration Puzzle

**This may be cut. Build it last, build it isolated, and make deletion trivial.**

- Gate it behind `Game.feature_calibration_puzzle: bool = true`. When false, the game must play exactly as it does without this section.
- All code lives in `scenes/puzzle/`. No calibration logic anywhere else. Removing that folder plus one flag and one call site must leave a working game.
- Do not let it touch the health formula, the budget, or the blueprint counters. Success gives at most a small flat health bonus; failure costs nothing and is retryable for free.

**What it is:** after a blueprint unlocks, the machine needs its operating sequence put in order. The player drags 4 steps into the correct sequence and presses run. Wrong order gives a readable failure line and can be retried immediately.

**Build exactly two instances:**

1. **Penyaring Mikroplastik** — steps: `Sedot air` → `Saring partikel` → `Kumpulkan residu` → `Buang air bersih`. Failure example: *"Air dibuang sebelum disaring. Residunya ikut keluar."*
2. **Penetral Limbah B3** — steps: `Isolasi wadah` → `Netralkan zat` → `Uji keasaman` → `Segel dan simpan`. Failure example: *"Wadah belum diisolasi. Zatnya bocor."*

**Deliberately not built:** block-based visual programming, loops, conditionals, an execution engine, or any puzzle authoring system. This is a drag-to-reorder list with an order check — nothing more. If the implementation starts growing past that, stop and report in `PROGRESS.md` instead of pushing through.

The failure messages carry the whole educational value here, so write them so a player understands *why* the order was wrong.

---

## 6. Verification

- Smoke suite updated and green, including the new systems.
- Add a check that a full simulated run reaches at least one blueprint and one tier increase.
- Add a check that with `feature_calibration_puzzle = false`, a full run still completes with identical health results.
- Confirm a **perfect day visibly raises the meter** (this was the Revision 1 fix; verify it still holds with blueprint bonuses added, and that health cannot exceed 100).
- `godot --headless --quit-after 240` — zero errors, zero orphan/leak warnings.

## 7. Definition of Done

- [ ] Four ocean tiers, changing only at the day report, with quiet transition lines
- [ ] Three blueprints as `.tres`; a fourth addable with zero code changes; progress always visible on the desk
- [ ] Surface info presented as properties, real name withheld until revealed or sorted
- [ ] Two upgrades, both genuine trade-offs, one chosen per run, no currency anywhere
- [ ] Calibration puzzle isolated in `scenes/puzzle/` behind a flag; game plays correctly with the flag off
- [ ] No new resource competes with shift budget; no real-time pressure added
- [ ] All new visuals are PNGs; all new animated objects are `AnimatedSprite2D` + `SpriteFrames`; `ASSETS.md` updated
- [ ] `PROGRESS.md` and `WALKTHROUGH.md` updated, including which parts of Revision 1 this supersedes

## 8. Stop and Ask For

Into `PROGRESS.md` under `## Needs Human`, then continue with what is unblocked:

- Tuning: tier thresholds, blueprint requirement counts, upgrade trade-off values, health bonuses. Propose numbers and mark them as proposals.
- Whether the calibration puzzle earns its place — give an honest assessment of what it cost to build and whether it adds anything, so the owner can decide to keep or cut it.
- Real art and audio for the new assets, flavour text review, export templates.