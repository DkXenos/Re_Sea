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

## Content is data

Items, rules, days and tools are custom `Resource` classes in `data/*.gd` with
one `.tres` per instance. **Adding item #40 or rule #12 must require zero code
changes.** If a feature would need a new `if` per item, it is designed wrong.

## Layers — use exactly these numbers

| Layer | Contents |
|-------|----------|
| 0 | water background, far seabed |
| 10 | `SubViewportContainer` holding the tank world |
| 20 | glass overlay: reflection, bubbles, tint |
| 30 | machine frame and console |
| 50 | HUD |
| 100 | modal panels: inventory, inspect, rulebook |
| 200 | pause, settings, debug overlay |

Inside the tank SubViewport, `z_index`: seabed `-10`, items `0`, fish `10`,
claw and cable `20`.

## Text

All player-facing text is **Indonesian** and lives in `data/strings.gd` as
`key → text`. Item names and rule text live in their `.tres` files. No string
literals in scenes. Code, comments, filenames and docs stay English.

## Workflow — verify, then commit

Work phase by phase and commit each phase. Verify yourself; never hand errors to
the human.

```bash
godot --headless --import        # run this after adding any class_name script
godot --headless --quit-after 2
godot --headless --quit-after 240
```

Any `SCRIPT ERROR`, `Parse Error`, `Failed loading resource`, or orphan-node
warning is a failed gate. `--import` must be run before booting after new
scripts are added, or `class_name` types will not resolve.

## Out of scope for the prototype

Cleaning minigames, dialogue, item disassembly, upgrade shop, story mode, save
games (settings persist, run progress does not), screen transitions, particles,
juice passes, audio mixing.
