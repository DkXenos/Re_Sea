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

run_all.sh greps for the tween case.

## assets

- every visual is a PNG from assets/. no draw_rect, no ColorRect standing in
  for a game object, no StyleBoxFlat on anything that isn't a UI panel.
  a grey square png is fine. a ColorRect is not.
- anything that might animate = AnimatedSprite2D + SpriteFrames, even with one
  frame
- one png, one thing. no atlases.
- paths and sizes are in assets/ASSETS.md, designers drop replacements at the
  same path/size and nothing else changes
- placeholders come from tools/gen_placeholders.py, sounds from gen_sounds.py
- hotspot rings are NEVER in the item art, they're a separate overlay
  generated from the .tres

## content is data

Items/rules/days/tools are Resources with one .tres each. Adding item #40
should be zero code. If something needs a new `if` per item I designed it
wrong.

Edit the .tres in the inspector. No generator writes to data/. Schema changes
go in tools/migrations/ as one-offs.

## layers

```
0    submarine hull (claw phase) / bg plate (everywhere else)
10   tank SubViewportContainer, desk content
20   glass overlay
30   machine frame + console
50   HUD + shift bar
100  rulebook, calibration puzzle
200  pause, settings, debug
```

Inventory + inspect panels are 10, not modals. Only the rulebook is modal.

z_index inside the tank: parallax -20 and down, seabed -10, fish -5, items 0,
claw/cable 20.

The sea only exists inside the tank SubViewport, so the frame really is a
window - outside it is hull. Depth layers are rows in ClawPhase's
PARALLAX_LAYERS; each is sized off its own texture and never stretched. Add a
row to add a layer.

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

## the shift

One day = one shift = one budget. drop 6, tool 4, sort 1 (Game.ACTION_COST).
**Nothing is spent by the clock.** No real-time countdown, ever - a ticking
timer kills the whole inspection thing. Thinking, panning, reading the rulebook,
switching tabs are all free.

Tank and desk are two views of one shift, Tab between them. shift_phase.gd
decides when the day ends, not either view.

## before committing

```
godot --headless --import        # after adding any class_name script
godot --headless --quit-after 2
godot --headless --quit-after 240
```

Any SCRIPT ERROR / Parse Error / failed load / orphan node = broken. So is a
hang: a failed assert kills the coroutine before quit() so it hangs instead of
failing, which is why run_all.sh has its own timeout.

## not doing

cleaning minigames, dialogue, disassembly, upgrade shop, story mode, save
games (settings persist, runs don't), screen transitions, particles, audio
mixing.
