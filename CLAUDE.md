# Cakar Laut — working rules for this repo

Underwater claw machine + waste sorting. This is a **playable prototype**, not a
finished game: correct systems, readable feedback, no polish. If a choice trades
polish for clarity, take clarity.

## Hard constraints

- **Godot 4.x, GDScript only, statically typed.** No addons.
- **Viewport 1280×720**, `canvas_items` stretch, `keep` aspect. Never 640×360 —
  the UI is text-heavy and needs the resolution.
- **Texture filter Linear.** This is not pixel art.
- **Exactly two autoloads:** `Events` (signal bus, no state) and `Game` (run/day
  state, no scene tree knowledge). Never add a third.
- **No physics engine for the claw.** No `RigidBody2D`. Claw movement is lerped
  position; grabbing is `Area2D` overlap plus a grip-chance roll.
- **No hardcoded cross-scene node paths.** Groups and signals only.
- **2D only. Never use a 3D node** — no `Node3D`, `Sprite3D`, `Camera3D`. The
  first-person feel comes from a fixed viewpoint, not a camera.

## Animation — no animation is written in code

Real art arrives from two designers, so everything must be swappable without
code changes.

1. **No animation written in code.** Never tween a game object's `position`,
   `scale`, `rotation`, `modulate` or `frame` to fake motion. If something
   animates, it is an `AnimatedSprite2D` playing a named animation from a
   `SpriteFrames`.
2. **Code decides *which* animation plays and *when*. It never decides what the
   animation looks like.** `sprite.play(&"sinking")` is correct;
   `tween.tween_property(sprite, "position:y", …)` on a game object is not.
3. **New animated things get their `SpriteFrames` immediately**, with one
   placeholder frame, and every animation is listed in `assets/ASSETS.md`.
4. **Two narrow exceptions, and only these:**
   - **Positional travel driven by game state** — the claw descending, an item
     drifting in on the current, the camera following. That is movement, not
     animation, and the sprite still plays an animation while it travels.
   - **UI feedback** — panel fades, chip highlights, the report's number
     counter. UI is not designer art.

`tools/smoke/run_all.sh` static-checks rules 1 and 2 on every run.

## The asset seam — highest priority

Real sprites arrive later from designers and must drop in without code changes.

1. **Every visual element is a texture loaded from a PNG in `assets/`.** Never
   `draw_rect()`, never a `ColorRect` standing in for a game object, never a
   shape drawn in code. A grey square PNG is correct; a `ColorRect` is not.
   (`StyleBox` on a UI panel is also not acceptable for game objects — use the
   panel PNGs in `assets/ui/`.)
2. **Anything that will ever animate is an `AnimatedSprite2D` with a
   `SpriteFrames`** — even now, with one frame. Claw, fish, items, bins, tools.
3. Static things use `Sprite2D` or `TextureRect`.
4. **One PNG per asset, one purpose per PNG.** No atlases, no sheets.
5. Filenames and pixel sizes are fixed by `assets/ASSETS.md`. Designers drop
   replacements at the same path and size; nothing else changes. Update that
   file whenever an asset is added.
6. Placeholders come from `tools/gen_placeholders.py` (Pillow) and sounds from
   `tools/gen_sounds.py` (stdlib `wave`).
   **Never use AI image or audio generation for any asset in this project.**
7. **Hotspot rings are never drawn into item art.** They are a separate overlay
   per item, generated from `data/items/*.tres` by
   `tools/gen_hotspot_overlays.gd`, and switchable by the player.

## Content is data — and the `.tres` files are the only source of truth

Items, rules, days and tools are custom `Resource` classes in `data/*.gd` with
one `.tres` per instance. **Adding item #40 or rule #12 must require zero code
changes.** If a feature would need a new `if` per item, it is designed wrong.
`tools/smoke/smoke_extensibility.gd` proves this on every run.

There is **no generator that can rewrite `data/`**. Edit the `.tres` in the
Godot inspector. Schema changes are one-off scripts in `tools/migrations/`,
kept in the repo as a record. `tools/content.py` holds drawing parameters for
the placeholder art and **no game content**.

## Layers — use exactly these numbers

| Layer | Contents |
|-------|----------|
| 0 | water background, far seabed |
| 10 | tank `SubViewportContainer`; desk view content |
| 20 | glass overlay: reflection, bubbles, tint |
| 30 | machine frame and console |
| 50 | HUD, and the shift bar shared by both views |
| 100 | modal panels: the rulebook, and the experimental calibration puzzle |
| 200 | pause, settings, debug overlay |

The desk's inventory and inspect panels are **view content, not modals**, so
they sit at 10 alongside the tank. Only the rulebook is genuinely modal.

Inside the tank SubViewport, `z_index`: seabed `-10`, **fish `-5`**, items `0`,
claw and cable `20`. Fish are background only and sit behind the items.

## Text

All player-facing text is **Indonesian** and lives in `data/strings.gd` as
`key → text`. Item names and rule text live in their `.tres` files. No string
literals in scenes. Code, comments, filenames and docs stay English.

## The shift model

A day is one shift with a single `budget`, spent by actions: a drop costs 6, a
tool use 4, sorting 1 (`Game.ACTION_COST`). **Nothing is spent by the clock.**
There is no real-time countdown anywhere and there must never be one — a ticking
timer would destroy the careful inspection the whole game is built around.
Thinking, panning, zooming, moving the camera, reading the rulebook and
switching views are all free.

The tank and the desk are two views of one shift, switchable at any time with
`Tab`. Neither decides the day is over; `shift_phase.gd` does.

## Workflow — verify, then commit

Work phase by phase and commit each phase. Verify yourself; never hand errors to
the human.

```bash
godot --headless --import        # run this after adding any class_name script
godot --headless --quit-after 2
godot --headless --quit-after 240
```

Any `SCRIPT ERROR`, `Parse Error`, `Failed loading resource`, or orphan-node
warning is a failed gate. So is a check that times out: **a failed GDScript
`assert` aborts the coroutine without reaching `quit()`**, which hangs the
harness rather than failing it, so `run_all.sh` enforces a per-check limit. `--import` must be run before booting after new
scripts are added, or `class_name` types will not resolve.

## Out of scope for the prototype

Cleaning minigames, dialogue, item disassembly, upgrade shop, story mode, save
games (settings persist, run progress does not), screen transitions, particles,
juice passes, audio mixing.
