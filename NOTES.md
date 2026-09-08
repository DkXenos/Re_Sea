# notes

Stuff I keep forgetting. Not documentation.

## don't break these

- godot 4.x, gdscript, typed. no addons.
- 1280x720, canvas_items, keep. do NOT drop it to 640x360, the UI is all text.
- linear filtering, this isn't pixel art
- two autoloads: Events (signals) and Game (state). two. not three.
- no RigidBody2D on the claw. it's lerped position + an Area2D overlap + a
  grip roll. physics here is a week I don't have.
- 2D only. no Node3D anywhere.
- no hardcoded paths between scenes, use groups/signals

## animation

Art is coming from two designers later so none of it can be hardcoded.

- don't tween position/scale/rotation/modulate/frame on a game object to fake
  motion. if it animates it's an AnimatedSprite2D playing a named animation.
- code picks WHICH animation and WHEN. `sprite.play(&"sinking")` fine,
  tweening position:y on the sprite not fine.
- exceptions: positional travel (claw descending, items drifting in, camera)
  and UI feedback (panel fades, the report counter). that's it.

tests/run_all.sh greps for the tween case.

## assets

- every visual is a PNG from assets/. no draw_rect, no ColorRect standing in
  for a game object, no StyleBoxFlat on anything that isn't a UI panel.
  a grey square png is fine. a ColorRect is not.
- anything that might animate = AnimatedSprite2D + SpriteFrames, even with one
  frame
- one png, one thing. no atlases.
- paths and sizes are in assets/ASSETS.md, designers drop replacements at the
  same path/size and nothing else changes
- delivered art arrives on a 2560x1440 canvas, exactly 2x the game. crop each
  piece to its alpha box, halve it, done. masters live OUTSIDE the project.
- bins and tools ship as one drawing each. state is an overlay png moved behind
  them (bin_outline, tool_row_selected), never a tint and never a second draw.

## tools

Four tools, three jobs, and they never overlap:

- **magnifier / swab** read the item. Arm one and click it - anywhere on it.
  There is no aiming: `hotspots` in the item's `.tres` says which tool finds
  which field, and that is the whole mechanic. The magnifier answers *what is
  it made of* (`true_material` - the two shirts are identical until you look);
  the swab answers *what is the stain* (`stain_type`).
- **the rinse** changes the item instead of reading it. `cleans_stains` on its
  `.tres`, and it is the only tool that writes to the entry: an ordinary stain
  comes off, `CarriedItem.cleaned` goes true, and every rule keyed on the stain
  stops firing - the cup that was heading for RESIDUE is recyclable again. A
  chemical stain (`stain_hazardous`) never comes off. Because the rules now
  depend on what the player did to *this copy*, `RuleChecker` takes
  `entry.rule_overrides()` alongside the shared `ItemData`.
- **the cutter** opens sealed crates and does nothing else. It is the only way
  to open one, it is free, and it says so in the rack. `opens_containers` on the
  tool's `.tres` is what makes a tool the opener - nothing names the cutter.

A tool that finds nothing still charges, and so does a rinse that refuses to
shift a chemical stain - the refusal *is* the finding, and it is the expensive
way to learn what one swab would have told you. A tool refusing a job it can't
do at all (cutter on an ordinary item, anything but the cutter on a sealed
crate) charges nothing, because that is a mis-click, not an attempt.

The fourth bin is **RESIDUE**, not LANDFILL - what is left when it cannot be
composted, cannot be recycled and is not chemical. A stain is not a verdict,
it is a job: rinse it and the item goes back to being whatever it is made of.

Because the cutter is the only opener, **every day with a crate must list the
cutter in its tools** or the crate is unopenable and the shift can deadlock.

## content is data

Items/rules/days/tools are Resources with one .tres each. Adding item #40
should be zero code. If something needs a new `if` per item I designed it
wrong.

Edit the .tres in the inspector. Nothing generates data/ - the .tres files are
the source.

## layers

```
0    submarine hull (claw phase) / bg plate (everywhere else)
10   tank SubViewportContainer, desk content
20   glass overlay
30   machine frame + console
50   HUD + shift bar
100  rulebook
150  tutorial overlay
200  pause, settings, debug
```

Inventory + inspect panels are 10, not modals. Only the rulebook is modal.

The tutorial overlay sits under pause so a caption can never cover the pause
menu, and above the rulebook so the tour can point at the rulebook button
without the book opening over the top of it. It pauses the tree while it is up,
which is also what stops anything underneath from being clicked.

The tour runs on the first run of every LAUNCH, not once per machine. It used
to write "seen" into user://settings.cfg and never come back, which meant the
second person to sit down at a machine never saw it, playtesting a change to
the tour meant hand-editing a settings file, and a laptop being demoed on
showed it to the first player of the day and nobody after. `Game.tutorial_shown_this_launch` is what stops a retry in the same sitting from
replaying it, and Game.replay_tutorial() (settings screen, pause menu) hands it
to whoever is next.

z_index inside the tank: parallax -20 and down, seabed -10, fish -5, items 0,
claw/cable 20.

The sea only exists inside the tank SubViewport, so the frame really is a
window - outside it is hull. Depth layers are rows in ClawPhase's
PARALLAX_LAYERS; each is sized off its own texture and never stretched. Add a
row to add a layer. They move with the claw and with nothing else - the tank
and the glass used to follow the mouse too and it read as a wobble.

A tank item's collision shape is cut to its own drawing's alpha box in
tank_item.gd, not to the 160x160 png frame, so a flat item stops having a
hitbox taller than it looks. claw.gd asks the item for that box (grab_box) so
the grip preview and the descent agree.

## the two cockpits

Both the claw screen and the sorting desk are whole-screen drawings that carry
their own readouts and buttons, so `shift_phase`'s bar stays hidden and only
surfaces to announce the shift is over. Each screen's buttons ask for what they
need through Events (view_switch_requested, shift_end_requested,
pause_requested) rather than reaching for shift_phase.

## the machine cockpit

`assets/ui/machine_frame.png` is the whole claw screen - hull, window surround,
glass streaks, the calendar and the panels. The window is the transparent
rect in it, (216,122) 848x408, and TankContainer + ClawPhase.TANK_VIEW are set
to exactly that. Redraw the frame with a different opening and those three
numbers move together.

The designer works on a full 2560x1440 canvas with each piece already in place;
each console piece is cropped to its alpha box and installed at the path
ASSETS.md gives, which is why every console node has plain offsets and can just
be dragged in the editor.

The keys and the buttons are the same control: A/D/Space swap the button's
texture_normal for its pressed art, held briefly so a tap still reads.

The claw screen hides the shift bar - it has its own readouts and its own
SORTING and cog buttons, which ask for what they need through
Events.view_switch_requested / pause_requested. The desk still has the bar.

## text

Player-facing text is English, lives in data/strings.gd. Item names and rule
text are in the .tres. No string literals in scenes. Internal ids and the
data/ filenames are still the old Indonesian ones - nothing shows them, and
renaming them means touching every day .tres and every asset path.

## scoring

There isn't any. No day score, no points, no penalty arithmetic. A day pays out
exactly the items that went in the RIGHT bin - those become blueprint material,
a wrong bin loses the item outright. Game.day_recovered() is the only door into
the material store; don't add a second one.

## machines and what they fit

One blueprint = one machine = one upgrade, and building it IS fitting it. There
is no gear tab and nothing to equip: the upgrade switches on the moment the
machine is built and stays on, so by the last day all three are running
together. Game.active_upgrades reads them off the built blueprints, and the
getters under it COMBINE - cheapest price wins, grip adds up, rail speed
multiplies. Add a fourth machine and its upgrade joins them; nothing else moves.

Every upgrade is a straight improvement. The old ones each charged for what
they gave (a faster rail that froze after every drop, a cheaper claw that
dropped things) and you could only wear one, which made a finished machine feel
like a bill. UpgradeData still has the two fields that make something worse -
coarse_readings and post_drop_lockout - and the claw and the desk still honour
them, but nothing sets them and tests/smoke_upgrades.gd fails if anything does.

## the shift

One day = one shift = one budget. drop 6, tool 4, sort 1 (Game.ACTION_COST).
**Nothing is spent by the clock.** No real-time countdown, ever - a ticking
timer kills the whole inspection thing. Thinking, panning, reading the rulebook,
switching tabs are all free.

Tank and desk are two views of one shift, Tab between them. shift_phase.gd
decides when the day ends, not either view.

END SHIFT only answers once the day's quota is sorted, and sorted means sorted:
a wrong bin counts. It has to - the desk never says which bin was right, so a
quota that only counted correct ones would be a hidden score, and the number
failing to move would leak the answer. The quota is the day's work; without the
gate a shift could be walked out of on the first item and the run speedrun. The
other two ways a shift ends are not requests and are never refused: running out
of shift time, and clearing the water with nothing left unsorted.

A late shift buys about ten items once two tools are going on each one, out of
a pool of twenty-something, so how often a kind of item comes up is a fraction
of the pool, not of the day. Days 4 and 5 carry roughly one hazardous item in
four (the pesticide shirt and the solvent tissue, repeated in the pool) and
carry the extra shift time to work them: at the old one-in-seven there were
whole shifts where the swab and the HAZARD bin never came up, and the seeding
arm's five HAZARDOUS parts were unreachable, so the third machine could not be
built. Day 3 is deliberately left thin - it is where the swab is introduced and
where the first machine has to be affordable.

Density is per-day data, never a spawn rule. Two items added to a pool the
shift can nearly exhaust are two items of something else not sorted, which is
why the two days that got more items also got the budget to pay for them
(2 items x drop 6 + sort 1). tests/smoke_full.gd is the guard: it plays five
days and asserts a well-played run still builds two machines.

Two endings get their own line instead of "Shift time is up": sorting nothing
at all, and clearing the water (nothing left in the tank, nothing pending,
nothing unsorted). Both are picked in `_closing_line()` at the moment the shift
ends - the state they read has moved on by the time the report draws, so it
cannot be worked out later.

## before committing

```
godot --headless --import        # after adding any class_name script
godot --headless --quit-after 2
godot --headless --quit-after 240
```

Any SCRIPT ERROR / Parse Error / failed load / orphan node = broken. So is a
hang: a failed assert kills the coroutine before quit() so it hangs instead of
failing, which is why tests/run_all.sh has its own timeout.

## not doing

cleaning minigames, dialogue, disassembly, upgrade shop, story mode, save
games (settings persist, runs don't), screen transitions, particles, audio
mixing.
