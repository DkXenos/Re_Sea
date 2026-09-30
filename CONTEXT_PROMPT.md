# Re:Sea: Context for a New Session

> **To the agent reading this:** you're joining an ongoing project partway
> through. Read all of this before you act. It covers what the game is, why it
> exists, where things stand, and the rules for working on it. Everything below
> was checked against the repo, the data files and the submitted proposal on
> **27 Sep 2026**. If the repo is available, file paths are relative to the
> project root (`/Users/jaysn/claw-test`). If you disagree with the code, trust
> the code, and say so.

---

## 1. In one paragraph

**Re:Sea** is a 2D Godot 4 game made by **Team Jetski** (Universitas Ciputra
Surabaya) for **HOLOGY 9.0 · HoloGame** (the game-dev competition,
**Environment** subtheme). You run a claw machine from inside a work submarine
at the bottom of a polluted bay. You pull trash off the seabed, then sort it
into four bins at a sorting desk. The twist: **the detail that decides the
right bin is often invisible, and finding it costs something.** Tools that
reveal hidden properties spend a shared daily budget, and the rules change from
day to day. A wrong bin gives **zero** material, not a smaller amount. Only
correctly sorted material builds the three machines that restore the bay. There
are no lives, no score and no game over. At the end of each day the game shows
every mistake along with the property you **never checked**. Five days, four
endings.

- **Pitch line:** *A claw machine pulls trash off the seabed. At the sorting
  desk, finding out what something really is costs you, and only what goes in
  the right bin becomes material to rebuild the bay.*
- **Thesis / closing line** (the cutscene's last line): *"Lower the claw. Look
  before you decide."*
- **Key differentiator** (proposal §2.2.7): *"A quiz tells you the right
  answer. Re:Sea tells you what you should have checked."*

---

## 2. Who you're working with

| Person | Role |
|---|---|
| **Jason Tio** (git user `DkXenos`), **the user you're talking to** | Developer: all code and game logic |
| Yumiko Jeanette Japari (team lead) | Designer: cutscenes, backgrounds, items, blueprints |
| Nathanova Yvonne Fridany | Designer: UI, sorting desk, buttons, panels, claw, fish |

All three are undergraduate (S1) students at Universitas Ciputra Surabaya,
Indonesia. Jason usually writes to the AI in English. The proposal and
`BUILD.md` are in **Bahasa Indonesia**. All in-game text is **English**.

(itch.io misspells Nathanova's surname as "Friday". The correct spelling is
**Fridany**.)

---

## 3. Why this game exists

### The competition
- **Event:** HOLOGY 9.0, HoloGame branch, subtheme **Lingkungan (Environment)**.
- **Theme:** *"Bloom Beyond: Where Ideas Take Root and Reach Further"*
- **Subtheme wording:** *"Menciptakan solusi teknologi yang mendukung
  keberlanjutan lingkungan, ketahanan iklim, serta pengelolaan sumber daya alam
  secara bertanggung jawab."*
- **Submitted:** 8 Sep 2026. That covers the proposal PDF, the itch.io page
  (https://jayznt.itch.io/resea) with Windows and macOS downloads, and a demo
  video (https://youtu.be/B8MtRwUGphM).
- **Now:** the team reached the **final stage**, a **live presentation and demo
  at Universitas Brawijaya**. The final's date, the time slot and the judging
  rubric are **not recorded anywhere in the repo**, so ask Jason for them. The
  proposal notes mention Gameplay 25% and Aesthetics 15%.

### The problem the game argues
1. Indonesia is estimated as the 2nd-largest source of marine plastic
   (Jambeck et al., 2015, *Science*).
2. A lot of that waste is still valuable material. **Sorting errors** destroy
   its value, not the amount of waste. A contaminated batch gets rejected, not
   discounted.
3. People mostly sort wrongly because of **missing information**, not bad
   intent. A cotton shirt and a polyester shirt feel the same, but one rots and
   the other is woven plastic. Mud and pesticide stains look alike, but one
   washes off and the other makes the item hazardous.
4. Campaigns tell people *what* the answer is. Re:Sea puts players in the same
   state of not knowing and lets them feel that **guessing is expensive and
   checking pays off**.

### Problem → mechanic (proposal §1.1.3, the core of the pitch)
| Real-world problem | How the game answers it |
|---|---|
| The deciding detail can't be seen from outside | Hidden properties, revealed only by tools that cost shift time |
| People sort without checking because checking is a hassle | Guessing is allowed, but a wrong guess yields zero |
| People don't know where their reasoning went wrong | The end-of-day report shows which property was never checked |
| Some waste can still be saved | Rinse recovers stained items, but not all of them, and not always |

### Pedagogical choices (keep these intact if you touch design)
- **No punishment, only lost opportunity.** Fines and lives make players play it
  safe and sort as little as possible. Lost material makes them check more.
- **Delayed feedback.** A bin never says whether you were right. If it did,
  players would learn by trial and error, and the evidence log and rulebook
  would become decoration.
- **No numeric score anywhere.** Only saved material matters.
- **Plain language.** Markings say "paper" and "cotton", not resin codes, so
  anyone can play from minute one. Resin codes were removed during
  development.
- **The quota counts wrong sorts too, on purpose.** It's satire: meeting a
  number isn't the same as doing the job well (proposal §2.1.3).

---

## 4. Current state and what's frozen

**Phase: post-submission, preparing for the final pitch.** The deck is in
progress. `pitchdeckppt.pdf` is an 8-page draft with placeholder text, and
`PITCH_DECK.md` is the full brief for building it.

**Frozen:** the submitted game, the proposal and the itch.io page can't change.
What the team still controls is the deck, the demo route, what they say on
stage, and new evidence (for example a playtest of the submitted build). Every
known flaw is handled through one of those, plus a "v1.1 patch list" slide.

### Critical: build and git state
- The **submitted builds** are `build/Re-Sea-windows.zip` (≈57 MB) and
  `build/Re-Sea-macos.zip` (≈78 MB), exported 8 Sep 2026 at 22:52. `build/`
  is gitignored.
- **Don't run the export commands in `BUILD.md`.** They overwrite `build/`, and
  the working tree has two files edited *after* the build
  (`assets/ui/ui_theme.tres` and `scenes/desk/desk_phase.tscn`, at 23:04 on 8
  Sep), so a fresh export would not be the judged game.
- The last commit (`ffc2552`, 8 Sep 17:41) is **older than the build**. The
  source of the judged build is `HEAD` plus about 30 **uncommitted**
  modifications (the tutorial's end-of-day segment, plain-language item
  markings, the Twin Arms text, layout tests and more), minus those two
  post-build edits. `project.godot`'s diff is only an editor re-save
  (reordered keys, one comment dropped). Committing this work, with a note
  about the two post-build files, is on the to-do list. **Ask before
  committing** anything.
- Untracked files: `PITCH_DECK.md`, `pitchdeckppt.pdf`, the proposal PDF,
  `tests/smoke_tutorial.gd` (+ `.uid`), and this file.

---

## 5. The game in detail

### Premise and setting
The player sits in the hull of a work submarine on the floor of a bay. The sea
exists only inside the window frame, and the rest of the screen is the hull.
That's also why the player never touches trash directly: the claw and tools are
the only way to interact with it. The opening cutscene has 11 lines of
narration over 5 stills: a lively bay, one cup sinking, a daily flood of
trash, "none of it arrives labelled", and three machines as the answer.

### Screen flow
`main_menu` (a splash: click to start, Esc for settings) → `cutscene` →
`day_start` (briefing: rules, quota, shift time, tools) → `shift` → `after_day`
→ the next `day_start`, or `game_over` (the ending) after Day 5.

The **shift** is one scene with **two views of the same shift**: the claw
machine and the sorting desk. They share one budget and one inventory, and
switching between them (Tab) is free. Items keep drifting onto the seabed while
you're at the desk.

### Shift time (the single budget)
There's no real-time timer anywhere. The budget drops **only through actions**:

| Drop the claw | Use a tool | Sort an item | Open a crate (Cutter) |
|:-:|:-:|:-:|:-:|
| 6 | 4 | 1 | free |

Thinking, reading, zooming, the rulebook, switching views and crafting are all
free. **A tool that finds nothing still costs 4** ("Nothing on this one for
that tool. The shift time is spent anyway -4."). A tool used on the wrong
*kind* of target (for example a Magnifier on a sealed crate) costs nothing,
because that's a misclick, not an attempt.

A shift ends when the player presses **End Shift**, when the budget can't cover
any meaningful action, or when everything is sorted ("Every last piece out of
the water and into a bin. The seabed is clear."). **End Shift is locked**
("Sort {n} more") until the day's quota is sorted, right or wrong.

### Claw machine
The claw moves along a rail (A/D or ←/→) and drops (Space, S or ↓). It falls
straight down, grabs the first thing it touches and rises. Grip chance is
`clamp(1 − weight × 0.15 + upgrade bonus, 0.05, 0.95)`: 70% for a 2 kg glass
bottle, 95% for dry leaves. It never reaches 100%. On a failed grip the item
slips at a random height and the drop cost isn't refunded. The seabed scrolls
wider than the window, with a camera and a minimap. Fish are background only
and can't be grabbed.

**Sealed Crate** (from Day 2): can't be binned until the Cutter opens it
(free). It holds 2–3 extra items, and the empty crate stays behind as RESIDUE
to sort. One drop can turn into four items to sort, so success can wreck your
budget plan.

### Sorting desk
- **Free info for every item:** its name, a zoomable image, `LOOKS LIKE:`
  (visible material), `MARKING:` (printed label, which may be absent or
  misleading), `WEIGHT:`, and three surface details.
- **Tools** (unlocked by day):
  - **Rinse:** the one tool that *changes* the item. It washes off food, drink
    or mud, and the item goes back to its base material's bin. Chemical stains
    won't come off.
  - **Chem Swab:** names the stain (ketchup, river mud, pesticide...), which
    implies whether it's hazardous.
  - **Magnifier:** reads what the item is really made of (cotton vs polyester,
    a hidden plastic liner, bristles stapled into a handle).
  - **Cutter:** opens sealed crates only.
- Each finding becomes a chip in the **EVIDENCE LOG**. The day's rules sit next
  to the item: a green plus when your *revealed* evidence proves a rule applies,
  a grey minus otherwise. When evidence proves a rule, the bin it points to
  gets an outline ring. That ring means "the evidence points here", never
  "correct".
- **Four bins, always clickable, even with zero evidence:**
  - `ORGANIC`: things that rot, including natural fibres like cotton.
  - `RECYCLABLE`: clean paper, glass and plastic, including polyester.
  - `HAZARDOUS`: anything soaked in a chemical that won't wash out. This beats
    the base material.
  - `RESIDUE`: still stained, laminated, multi-material, used tissue.
    (In code the enum is `HAZARD` and the RESIDUE bin's PNG is still named
    `bin_landfill.png`. The category was once called LANDFILL.)
- **Rulebook** (R): today's rules grouped by bin, plus a plain-language "WHERE
  THINGS GO" guide. Free, and it doesn't pause the game.

### Rules (priority: higher wins, base material decides if nothing matches)
| Rule | On-screen short text | Forces | Priority | From day |
|---|---|---|---|---|
| Baseline | What it is made of decides where it goes | (base material) | 0 | 1 |
| Stain | Still stained → RESIDUE | RESIDUE | 10 | 2 |
| Laminated | Laminated packaging → RESIDUE | RESIDUE | 30 | 4 |
| Chemical | Chemical stain, will not rinse → HAZARDOUS | HAZARDOUS | 40 | 3 |

### Days
| Day | Quota | Shift time | Items in pool | Crates | Hazardous items | New this day |
|---|---|---|---|---|---|---|
| 1 | 5 | 90 | 8 | 0 | 0 | Baseline only, no tools (a "tutorial without a tutorial": nothing stained or laminated) |
| 2 | 6 | 110 | 14 | 1 | 0 | Stain rule; Rinse, Magnifier, Cutter |
| 3 | 8 | 130 | 19 | 1 | 2 | Chemical rule; Chem Swab |
| 4 | 10 | 164 | 23 | 2 | 5 | Laminated rule |
| 5 | 12 | 174 | 26 | 2 | 6 | No new rule, more items |

The quota rises 140% from Day 1 to Day 5, while shift time rises only 93%.
Items arrive every 8–14 real seconds from each day's fixed pool, and the order
is shuffled by a per-run seed.

### Items and their correct bins
| Item (`id`) | Free info says | Hidden truth | Correct bin |
|---|---|---|---|
| Apple Core, Banana Peel, Eggshells, Dry Leaves, Pizza Slice | food/garden | none | ORGANIC |
| Stack of Newspapers, Glass Bottle | paper / glass | none | RECYCLABLE |
| Clean Paper Cup (`gelas_kertas_bersih`) | paper | plain paper | RECYCLABLE (Days 1–3 only) |
| Frayed Shirt (`baju_organik`) | woven fabric, 0.6 kg, label washed out | cotton | ORGANIC (Magnifier needed) |
| Faded Shirt (`baju_daur_ulang`) | identical free info | polyester | RECYCLABLE (Magnifier needed) |
| Muddy Shirt (`baju_kotor`) | woven fabric, brown patch | cotton + river mud | RESIDUE, or ORGANIC once rinsed |
| Stained Shirt (`baju_b3`) | "stained woven fabric", sharp smell | cotton + pesticide | HAZARDOUS (can't be rinsed; Day 3+) |
| Sauce Jar (`botol_kaca_kotor`) | glass | chilli sauce stain | RESIDUE, or RECYCLABLE once rinsed |
| Plastic Bag (`kantong_plastik`) | plastic, red smears | ketchup stain | RESIDUE, or RECYCLABLE once rinsed |
| Paper Cup (`paper_cup`) | paper, "slick surface" | coffee stain + plastic liner | Days 2–3: RESIDUE, or RECYCLABLE once rinsed. Days 4–5: RESIDUE even if rinsed (laminated beats stain) |
| Used Toothbrush | plastic | handle + nylon bristles + staples (multilayer) | Day 3: RECYCLABLE. Days 4–5: RESIDUE |
| Used Teddy Bear | fabric and stuffing | plush over polyester, not separable | RESIDUE |
| Used Tissue (`tisu_bekas`) | used tissue | none | RESIDUE |
| Chemical-Soaked Tissue (`tisu_b3`) | tissue, green stains, acrid smell | solvent paint | HAZARDOUS |
| Sealed Crate (`mystery_box`) | sealed crate | holds 2–3 items | open with Cutter; the empty crate is RESIDUE |

That's 19 trash items plus the crate. The proposal counts 20 "items". Item IDs
are mostly Indonesian (`apel`, `baju_b3` where B3 = *bahan berbahaya dan
beracun*, meaning hazardous), and display names are English.

**Best teaching examples:** Frayed vs Faded Shirt (no free info tells them
apart), Muddy vs Stained Shirt (one can be saved, one can't), the Paper Cup
(Rinse saves it on Days 2–3 but not on Days 4–5), and the Toothbrush (the
answer changes between Day 3 and Day 4).

### Technology: materials → components → machines → upgrades
Only correctly sorted items become material, credited at the end of the day,
one material per item, in the category of the bin it *should* go in. Material
carries across days. Crafting is free. **Upgrades can't be bought.** A machine
switches its upgrade on permanently once built, and upgrades stack.

| Machine | Parts (material cost) | Upgrade it switches on |
|---|---|---|
| Ocean Cleaning Drone | Drone Shell (1 ORG + 2 REC), Rotor Skid (2 ORG + 1 RES) | **Fast Rail**: claw moves 60% faster |
| Recycling Station | Intake Arm (2 REC), Sorting Belt (3 RES), Press Housing (2 ORG + 2 REC) | **Strong Grip**: +15 points of grip chance |
| Reef Restoration Pod | Pod Shell (2 ORG + 3 RES), Seeding Arm (5 HAZ) | **Twin Arms**: tools cost 3 instead of 4 |

Building all three takes 25 correct sorts (7 ORG, 6 REC, 5 HAZ, 7 RES). The
quotas add up to 41, so **more than 6 in 10 sorts must be right**, which rules
out guessing your way to the best ending.

### End of day (`after_day`)
One screen with two tabs:
- **The Day** has a card for every mistake: `You put it in:`,
  `Should have been:`, **`Never checked: <property>`** (worked out from the
  broken rule's key properties, minus whatever the player revealed), and
  `Broke: <rule text>`. It also shows material recovered per bin, "Only what
  goes in the right bin becomes blueprint material", "{n} sorted wrongly - lost,
  not stored", and counts (correct, wrong, unsorted, shift time used).
- **Technology** has the blueprint sheets, per-part Build buttons, the material
  store and the machine build button.

### Endings (after Day 5, chosen only by machines built)
0 · *THE BAY WAS LEFT AS IT WAS* · 1 · *A FIRST MACHINE* · 2 · *THE WATER IS
TURNING* · 3 · *THE BAY CAME BACK*. Each has its own painting,
`assets/env/ending_N.png`.

### Guided tour
30 steps: 8 cockpit, 11 desk, and 11 end of day, including one step that waits
for the player to actually press the Technology tab. It darkens the screen and
cuts a spotlight hole around the control being explained. It **runs on the first
run of every launch**, can't be skipped, and can be replayed from pause or
settings. (The proposal says 19 steps because the end-of-day segment was added
on submission day.)

### Controls
A/D or ←/→ move the claw · Space/S/↓ drop · Tab switches view · R opens the
rulebook · I selects the first unsorted item · scroll/drag zooms and pans the
item · Esc pauses · Enter/click advances · **F1** opens a debug overlay (debug
builds only: skip day, refill budget, force grip, fill inventory). Every key
also has a clickable button on the console.

### Audio and art
- About 120 hand-drawn PNGs made in **Procreate** by the two designers.
  **No AI-generated art or audio, and none may be added** (declared in the
  proposal §3.3).
- 11 synthesized WAV sound effects.
- Music: *"Relaxing Chiptune Music (Traveling in the Sea)"* by Migfus20,
  Freesound #683268, **CC BY 4.0** (needs attribution; it's credited only in
  the proposal PDF).
- Ambience: sea waves by soundandmelodies, Freesound #784465, CC0.
- Font: **Fredoka** (Medium and SemiBold), SIL OFL 1.1.
- 1280×720 viewport, `canvas_items` stretch. The tone is calm and hopeful, not
  preachy. The briefing and report screens look like blueprint sheets taped to
  a desk.

---

## 6. Known flaws and loopholes (can't be fixed in the judged build)

These come from `PITCH_DECK.md` §5. Each has a plan for the final and a slot on
the v1.1 list.

| # | Flaw | How it's handled |
|---|---|---|
| A1 | The proposal says to play in the browser ("Run game"), but itch.io only has Windows and macOS downloads | Own it in one sentence if asked |
| A2 | The CC BY music credit exists only in the proposal PDF, not in the game or on itch.io | Put it on the deck's closing slide; v1.1 adds a credits screen |
| A3 | itch.io misspells "Fridany" | Spell it correctly on the team slide |
| A4 | Three day briefings describe mechanics that no longer exist (Day 2 "magnifier reads codes", Day 4 "the code printed on it", Day 5 "new foil rule" that never arrives) | Keep briefing screens out of the demo; v1.1 rewrite |
| A5 | The bibliography cites ASTM D7611 resin codes, which the game dropped | "Removed so anyone can play" |
| B1 | Some names give the answer away ("Chemical-Soaked Tissue", "Clean Paper Cup") | Don't demo those items; v1.1 uses neutral names |
| B2 | Few items truly *need* a tool (the shirts, the Paper Cup, the Toothbrush from Day 4) | Say "often hidden", never "always" |
| B3 | "When in doubt, RESIDUE" is always right for stained non-chemical items, so Rinse is never needed to be correct, and clean items alone cover the ORG and REC needs | It's real-world advice too; what you lose is recoverable material; v1.1 rebalance |
| B4 | The Reef Pod needs 5 HAZ, so it can't be built before the end of Day 4, and Twin Arms helps on Day 5 at most | Sell the Pod's reward as the best ending, not Twin Arms |
| B5 | Waiting is free and each day's pool is finite | "We price decisions, not reflexes" |
| B6 | Once evidence is revealed, the rule lights up and a ring points at the bin | "We train *what to check* and whether it's worth it" |
| B7 | The quota can be met by guessing | Intentional satire (§2.1.3) |
| B8 | A crate left unopened at the end of a shift silently vanishes (there's a `TODO` in `Game.sealed_containers()`) | Open every crate in the demo; v1.1 reports it |

Argument weak spots to avoid in the deck:
- The proposal's "most people already care" has no source, and BPS 2018 says
  otherwise.
- The BPS 0.72 figure is an **index from 0 to 1**, not "72%".
- Don't subtract Jambeck 2015 (2010 data) from the government's 2023 figure;
  they measure different things.

Vetted real-world cases (sources are in `PITCH_DECK.md`):
- Surabaya, 2019: 8 containers of "waste paper" from Australia were sent back
  whole because of contamination. It happened in the team's own city.
- China's National Sword: a 0.5% contamination limit from 1 Mar 2018.
- Indonesian government: marine plastic leakage fell 41.68% from 2018 to 2023,
  against a 70% target for 2025.

Small accuracy note: the deck brief says "19 headless test scripts". `tests/`
has 18 `smoke_*.gd` tests plus `screenshot.gd`, which is a utility that renders
a scene to PNG. "18 test scripts, 34 automated checks" is the precise claim.

---

## 7. Codebase

### Stack
- **Godot 4.7.2 stable** (`godot` is on PATH on Jason's Mac), GL Compatibility
  renderer.
- **Statically typed GDScript**, no third-party add-ons.
- Export presets: Windows Desktop (`.pck` embedded in the `.exe`), macOS
  (universal binary, ad-hoc signed), and Web (built but never uploaded).
- `*.md`, `*.pdf`, `tests/*`, `*.sh` and `*.py` are excluded from exports.

### Layout
```
main.gd / main.tscn   scene switcher (scenes addressed by key), pause/debug/tutorial layers, cursor scaling
autoload/events.gd    signal bus only: no state, no logic
autoload/game.gd      all run and day state: budget, inventory, materials, crafting, upgrades, tutorial flags, audio
systems/              rule_checker (item + rules → bin), carried_item (per-instance reveals and rinse),
                      day_manager (flow graph), mistake_view (report rows + "Never checked"), bin_icons, save_settings
data/*.gd             Resource classes: ItemData, RuleData, DayData, ToolData, ComponentData, BlueprintData, UpgradeData
data/{items,rules,days,tools,components,blueprints,upgrades}/*.tres   ALL content
data/frames/*.tres    SpriteFrames for every animated thing
data/strings.gd       every player-facing string (except item names and rule text, which live in the .tres files)
data/tutorial_steps.gd  tour steps (CLAW / DESK / AFTER_DAY arrays)
scenes/               main_menu, cutscene, day_start, shift (hosts claw + desk), claw, desk, after_day,
                      game_over, settings, tutorial, debug
assets/               art and audio; see assets/ASSETS.md
tests/                run_all.sh + headless smoke tests
```

### Architecture principles (enforced; don't break them)
- **Exactly two autoloads**, `Events` and `Game`. Scenes talk through `Events`
  signals and never hold paths to each other.
- **Content is data.** A new item, rule or day is a `.tres` file, not code.
  The correct bin is always *computed* by `RuleChecker.resolve()` from the item
  and the day's rules; it's never hard-coded. **No per-item special cases**:
  `.id == "..."` in code fails the tests.
- **The only door into the material store** is
  `Game.day_recovered()`/`_credit_materials()`, called once per day and guarded
  by `day_committed`.
- **Determinism:** one run seed, re-derived per day; crate contents use their
  own seed stream.
- **Save:** only settings (`user://settings.cfg`). Run progress isn't saved, by
  design (one sitting).

### Art rules (checked by `tests/run_all.sh`)
- Every visual is a **PNG loaded from a fixed path**. No `_draw()`,
  `ColorRect`, `Polygon2D`, `Line2D`, 3D, `StyleBoxFlat`, gradients, noise or
  lights.
- **Two sanctioned shader exceptions:** `trash_outline.gdshader` on tank items
  (a contact shadow from the PNG's alpha) and the tutorial spotlight mask.
- Game objects (claw, items, fish, bins) animate **only through SpriteFrames**:
  no tweens or `modulate` to express state. State is a separate PNG or overlay,
  never a tint. The cutscene and main-menu drift are the allowed exceptions.
- Code scales sprites only through **named display constants** (`BASE_SCALE`,
  `TOOL_ICON_SCALE`, `BIN_DISPLAY_SCALE`, `DRIFT_HOME`, `_fit_scale`).
- UI chrome is all in `assets/ui/ui_theme.tres`, applied project-wide. Every
  themeable Control class used must have a theme entry. Panels are
  NinePatchRect over PNGs.
  - `panel_dark.png` is the **panel** plate (a cream page, despite the name).
  - `panel_main.png` is the plate behind **every non-primary Button** (texture
    margins 14); state shows through font colour plus a 2px shift on pressed.
  - `primary_button.png` is only for the `PrimaryButton` theme variation (the
    "Next" buttons).
  - Don't bring back the unused `button_*.png` set.
- **The art pipeline adapts to the designers, not the other way round.** Never
  hand the designers a pixel spec. Deliveries arrive as full-canvas exports
  (2560×1440 UI, 3840×2160 scenery, 2048×2048 items) with the art in a small
  region. Crop to the alpha bbox (`Image.getbbox()`), then scale to fit the
  destination in code. Choose nine-patch margins from what the art actually
  contains. Install with a throwaway Python/PIL script per delivery (there's no
  permanent install tool).
- Full-size art masters live **outside the repo** at `~/Re-Sea-art-masters/`
  (plus 23 unused Fredoka weights). **Never move them into `assets/`.** The
  export uses `all_resources`, so anything in `assets/` gets packed into the
  build.

### Tests
```
./tests/run_all.sh          # 34 checks: 11 static rules, 2 boots, 18 smoke scripts + 3 variants
godot --headless --import   # run first after adding or changing a script with class_name
```
`smoke_full.gd` plays the whole game headlessly through `main.tscn` (menu → 5
days → ending). `-- --bad` plays a deliberately bad run. Every check must PASS
before any build. The script treats `SCRIPT ERROR`, parse errors, leaks and
timeouts (180 s) as failures. `tests/screenshot.gd` renders a scene to a PNG
for layout checks.

### Code style (match it)
- Comments are lowercase, conversational, and explain **why**. Longer `##` doc
  comments often record a design decision and what it replaced. The comment
  density is high where the reasoning isn't obvious.
- Typed everything (`var x: int`, `-> void`, typed arrays), `StringName`
  literals (`&"drop"`), and `Strings.t("key")` / `Strings.tf("key", {...})`
  for text.
- Data IDs are Indonesian-ish snake_case (`rel_cepat` = Fast Rail,
  `cengkeraman_kuat` = Strong Grip, `lengan_ganda` = Twin Arms). Player-facing
  text is English.

---

## 8. Document map

| File | What it is | Trust level |
|---|---|---|
| `HoloGame-Proposal_Re_Sea_Jetski_HOLOGY-9.0.pdf` | **The submitted proposal** (Indonesian, 29 pp). The judges' reference; the deck must build on it and never contradict it | Authoritative for claims |
| `PITCH_DECK.md` | Slide-by-slide brief for the final: fact sheet, vetted real-world cases, flaws, demo script, Q&A prep, deck design rules | Current, detailed; read it for anything pitch-related |
| `pitchdeckppt.pdf` | The in-progress deck (8 pages: Game Loop, Progression ×2, References, Live Demo, Strengths, Current State, Future Dev), mostly placeholder text | Work in progress |
| `README.md` | Short English overview of the game and the repo | Current |
| `BUILD.md` | Build and export guide (Indonesian): templates, icons, sizes, release checklist | Current, but **don't run the exports** (§4) |
| `assets/ASSETS.md` | Every PNG, its size and purpose, art-replacement rules, display constants | Current |
| `assets/ui/fonts/README.md` | Fredoka licensing and which weights ship | Current |
| `PROPOSAL_ISI.md` | An **older proposal draft** with outdated numbers and `[BUTUH INPUT]` placeholders | **Don't use it** |

---

## 9. The pitch plan (summary; details in `PITCH_DECK.md`)

- **15 slides:** Title → Problem (open with the Surabaya 2019 story) → Game
  info → Core mechanics → Loop → Upgrades and progression → Impact → Theme and
  references → **Live demo** → Strengths → Weaknesses ("What we found after
  submitting") → Future and v1.1 → Delivery → Team → Close.
- **Timing for a 10-minute slot:** about 3 minutes of demo. Cut slides before
  cutting the demo.
- **Demo:** use only the submitted build, **pre-played to Day 4 at 8/10
  sorted** with the Muddy Shirt, the Stained Shirt and a Paper Cup unsorted and
  all crates opened, paused and never closed (the tour can't be skipped and
  there's no save). Keep a second laptop ready, and the YouTube video as a
  fallback.
  - Route: swab the Stained Shirt → HAZARDOUS; rinse the Muddy Shirt → ORGANIC
    (quota met); put the Paper Cup in RECYCLABLE on purpose; End Shift; show the
    `Never checked:` card; build a part on the Technology tab.
  - **Stop before "Start the Next Day"**, because the Day 5 briefing has the
    stale "foil rule" text.
- **Design:** use the game's own art (from `~/Re-Sea-art-masters/`), set type
  in Fredoka, put one idea on each slide, source every statistic on the slide,
  and take every game number from the fact sheet.
- **Before the final:** playtest the submitted build with 5–10 new players
  (run length, ending reached, the most common `Never checked:` property,
  whether anyone rinses, a before/after quiz); back up the build zips; commit
  the source; ask the committee whether post-submission work may be mentioned.

---

## 10. How to work with Jason on this project

- **Ask before** committing, pushing, exporting builds, or anything that touches
  `build/`.
- **Don't change the judged game's behaviour** unless Jason explicitly says the
  work is post-final (v1.1). Pitch work goes in the deck and docs.
- Verify numbers against `data/*.tres` rather than memory. If a number in this
  file disagrees with the data, the data wins; say so and update
  `PITCH_DECK.md` §4.
- Keep claims honest: say "often hidden", not "always"; don't promise Twin
  Arms changes play; don't repeat unsourced claims.
- In-game terms stay in English exactly as shown on screen (`Shift time`,
  `RESIDUE`, `Never checked:`), even in Indonesian-language material.
- For art problems, fix the code and install step, not the designers' files or
  sizes.

---

## 11. Open questions (not known as of 27 Sep 2026)

- The date and time of the final, the presentation length and Q&A length.
- The judging rubric weights beyond Gameplay 25% and Aesthetics 15% (they're
  in the HoloGame guidebook, a Drive link on the itch.io jam page).
- Whether the final demo must use the submitted build, and whether
  post-submission work may be mentioned.
- Playtest results for the submitted build (not done yet).
- The measured length of a full run in minutes (slide 3 needs it).
- The presenting language (Indonesian or English).
