# Assets

List of every PNG in the game. Everything you see on screen is one of these -
nothing is drawn in code.

## replacing art

Short version: **same path, same pixel size, flat art, no baked lighting.**

1. Drop the PNG at the same path and the same size as the table says. No code
   or scene changes needed.
2. Keep the transparent background. Only the `env/` backgrounds are opaque.
3. Stay inside the canvas. Anchor is the centre, except `ui/` panels which
   stretch from the corners.
4. No baked lighting, shadows or glow. Lighting is a later pass done per
   CanvasLayer, and art with a light direction painted in will fight it.
5. One PNG is one whole thing. A bottle is one file, not body + cap + label.
6. State is a different drawing, not a tint. Locked tool, highlighted bin,
   selected slot - each gets its own PNG. The code never recolours art.
7. Everything is displayed at scale 1 except these three:

   | What | Authored | Displayed | Constant |
   |------|----------|-----------|----------|
   | Item in the inspect panel | 160×160 | 240×240 | `InspectPanel.BASE_SCALE` = 1.5 |
   | Tool icon in the rack | ~72 tall | ~61 tall | `InspectPanel.TOOL_ICON_SCALE` = 0.85 |

   Everywhere else the size in the table is the size on screen.

## UI chrome — buttons, panels, sliders, scrollbars, text fields

These are the parts Godot would otherwise draw itself. They are all PNGs in
`assets/ui/`, wired up in one place: `assets/ui/ui_theme.tres`, which
`project.godot` applies to the whole game. **Replace the PNG and every screen
follows — you never touch a scene.**

| Part | Files |
|------|-------|
| Button | `button_normal` / `button_hover` / `button_pressed` / `button_disabled` |
| Primary button | `primary_button` / `primary_button_hover`. Theme type variation `PrimaryButton`, not the default Button, so only the one call to action per screen wears it. |
| Panels & boxes | `panel_dark`, `panel_slot`, `panel_slot_selected` |
| Volume slider | `slider_track`, `slider_fill`, `slider_grabber`, `slider_grabber_hover` |
| On/off toggle | `toggle_off`, `toggle_on` |
| Scrollbar | `scrollbar_track`, `scrollbar_grabber`, `scrollbar_grabber_hover` |
| Text field | `textfield_normal`, `textfield_focus` |

The stretchy ones (buttons, panels, sliders, scrollbars, text fields) are
**nine-patch**: the corners stay put and the middle stretches. Keep your border
inside the margin the table further down names for that file, or the corners
will smear. The small square PNGs are drawn at the size given; a button is 64×64
art stretched to whatever the button needs.

## animating something

No animation is written in code. Anything that moves is an AnimatedSprite2D
playing a named animation out of a SpriteFrames in `data/frames/`. The code
only picks which one and when.

Every animation already exists with one placeholder frame. To fill it in:

1. Draw the frames, save them next to the existing file numbered
   `claw_closing_01.png`, `claw_closing_02.png` etc
2. Open the matching `data/frames/*.tres` in Godot and drop them in

Don't rename animations or swap the SpriteFrames out, they're looked up by
name. The frame counts in the table are what I'm designing for - fewer is fine,
it just plays shorter.

## hotspots

An item's `hotspots` in `data/items/*.tres` say which tool finds which property
on it, e.g. `{"tool": "swab", "reveals": "stain_type"}`. The rinse is not in there -
it changes the item rather than reading it. There are no
positions and no rings: the whole item is the target, so a tool either has
something to find on it or it does not.

That means nothing has to be drawn at a particular coordinate. Draw the
evidence into the art where it makes sense - the stain, the printed code, the
seam - and it reads as the reason the tool found something.

## no AI art

No image or audio in this project is AI generated, and none may be. Every
illustration is drawn by hand by the project's own artists in Procreate. The
sound effects are plain synthesised tones. The delivery folders of full-size
masters live outside the project, so `assets/` only ever holds what ships.

## how the delivered art is installed

The artists work on a full 2560x1440 canvas with every piece already in place.
That canvas is exactly 2x the game's 1280x720, so a piece's position on it
divides straight into screen coordinates and each piece is cropped to its own
alpha box before install. That is why the desk background can be dropped in
whole and every node just sits in the slot painted for it.

Two consequences worth knowing:

- **The desk and the cockpit are whole screens.** `assets/ui/desk_bg.png` and
  `assets/ui/machine_frame.png` each carry their own top bar, panel frames and
  button plates. Redraw one and the node offsets in its scene follow the new
  art; nothing is drawn by code. `assets/ui/briefing_bg.png` and
  `assets/ui/report_panels.png` work the same way for the two screens either
  side of a shift, down to a painted socket for the button: the dark octagon at
  the bottom of the briefing sheet is exactly where `primary_button.png` sits.
- **State is an overlay, not a second drawing.** The bins and the tools ship as
  one drawing each, so "this bin is what the evidence points at" is
  `bin_outline.png` moved behind the bin, and "this tool is armed" is
  `tool_row_selected.png` slid behind the row. The art itself never changes and
  is never recoloured.
- **The one exception: the trash in the tank.** Items on the seabed run
  `scenes/claw/trash_outline.gdshader`, which reads the alpha of whatever png
  you delivered and lays a soft dark contact edge just outside the silhouette,
  plus a faint rim light along its top edge. It is not a drawing and it is not
  a recolour - it invents nothing and works on art at any size, which is why it
  sits on the right side of the "no shaders" rule. It draws into the png's
  transparent margin, so **leave a couple of pixels of margin around an item**;
  `box_closed.png` runs to its own bottom edge and loses the edge there. Turn
  `ring_alpha` down on the material in `scenes/claw/tank_item.tscn` if it ever
  reads as an outline rather than as a shadow.

The same trash gets its **grab box measured off the drawing, not off the
frame**. Every item png is the same 160x160 canvas but each drawing fills a
different part of it, so `scenes/claw/tank_item.gd` reads the png's own alpha
box on spawn and cuts the collision shape to it, plus a few pixels of
forgiveness. A flat newspaper is caught where a newspaper looks and a tall
toothbrush where the toothbrush is; nothing here needs to be told a size, so
draw an item at whatever proportions it wants inside the frame.

## the display-size constants

Code never picks a size for a piece of art except through one of these, and the
automated rule check fails on any other `.scale =` in the project:

| Constant | Where | What it sizes |
|---|---|---|
| `BASE_SCALE` | `scenes/desk/inspect_panel.gd` | the item under the magnifier, before the player's own zoom |
| `TOOL_ICON_SCALE` | `scenes/desk/inspect_panel.gd` | the four tool drawings inside the rack's painted slots |
| `BIN_CENTRE_Y` | `scenes/desk/bin_row.gd` | (position, not scale) the bin standing in its painted pedestal |
| `DRIFT_HOME` | `scenes/cutscene/cutscene.gd` | the resting size of the cutscene stills, which drift `DRIFT_SCALE` either side of it |
| `_fit_scale` | `scenes/claw/claw_phase.gd` | the opposite case - it reads the delivered texture and fits it to the window, so parallax art at any resolution lands correctly |

Everything else is installed at the size it is drawn at.

## fonts

`assets/ui/fonts/` holds **Fredoka**, the only third-party asset in the project,
under the SIL Open Font License 1.1 (`OFL.txt` ships beside it). `Fredoka-Medium`
is the theme's `default_font`; `Fredoka-SemiBold` is the Button and PrimaryButton
font. The other 23 weights of the family are kept out of the build - see
`assets/ui/fonts/README.md`.

## which way a fish faces

Every drawing in `assets/fish/` faces **left**. `fish.gd` flips the sprite when
it swims right, so a fish drawn facing the other way will swim backwards. Draw
new ones facing left and nothing has to change.

## animations

Every SpriteFrames in `data/frames/` and the PNG behind it. Frame counts are one
for now - drop numbered frames beside a file and add them to the `.tres` to fill
an animation in without touching code.

## the files

### Trash items

| File | Size | Animation | What it is |
|------|------|-----------|------------|
| `assets/items/box_closed.png` | 160x160 | `closed` 2 fr, `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Mystery box, sealed. State `closed`. |
| `assets/items/box_opened.png` | 160x160 | `opened` 2 fr | Mystery box, lid open. State `opened`. |
| `assets/items/item_apel.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `apel` |
| `assets/items/item_baju_b3.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `baju_b3` |
| `assets/items/item_baju_daur_ulang.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `baju_daur_ulang` |
| `assets/items/item_baju_organik.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `baju_organik` |
| `assets/items/item_baju_organik.png` | 160x160 | reused | Trash item `baju_kotor` - **wants its own art**: same shirt with a visible mud patch |
| `assets/items/item_banana_peel.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `banana_peel` |
| `assets/items/item_botol_kaca.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `botol_kaca` |
| `assets/items/item_cangkang_telur.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `cangkang_telur` |
| `assets/items/item_daun.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `daun` |
| `assets/items/item_gelas_kertas_bersih.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `gelas_kertas_bersih` |
| `assets/items/item_kantong_plastik.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `kantong_plastik` |
| `assets/items/item_botol_kaca.png` | 160x160 | reused | Trash item `botol_kaca_kotor` - **wants its own art**: same jar with sauce crust at the rim |
| `assets/items/item_koran.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `koran` |
| `assets/items/item_paper_cup.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `paper_cup` |
| `assets/items/item_pizza.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `pizza` |
| `assets/items/item_tisu_b3.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `tisu_b3` |
| `assets/items/item_tisu_bekas.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `tisu_bekas` |
| `assets/items/item_teddy_bear.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `teddy_bear`. Waterlogged soft toy, plain RESIDUE. |
| `assets/items/item_toothbrush.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `toothbrush`. Reads as recyclable PP; the magnifier finds the nylon and the multilayer rule sends it to RESIDUE. |

### Sorting bins

| File | Size | Animation | What it is |
|------|------|-----------|------------|
| `assets/bins/bin_hazard.png` | 101x116 | `idle` 1 fr | hazard bin, idle state |
| `assets/bins/bin_landfill.png` | 101x115 | `idle` 1 fr | RESIDUE bin, idle state. The file keeps the old name; the category was renamed, the art was not redrawn |
| `assets/bins/bin_organic.png` | 101x116 | `idle` 1 fr | organic bin, idle state |
| `assets/bins/bin_outline.png` | 119x133 | static | Highlight ring shown behind whichever bin the revealed evidence points at. One drawing, moved between the four slots. Sized to the bins - redraw both together. |
| `assets/bins/bin_recyclable.png` | 101x116 | `idle` 1 fr | recyclable bin, idle state |

### The claw

| File | Size | Animation | What it is |
|------|------|-----------|------------|
| `assets/claw/claw_cable.png` | 21x64 | static | Cable, stretched vertically from rail to claw |
| `assets/claw/claw_carrying.png` | 144x101 | `carrying` 1 fr | Claw arm, carrying pose |
| `assets/claw/claw_closed.png` | 144x101 | `closed` 1 fr | Claw arm, closed pose |
| `assets/claw/claw_closing.png` | 144x101 | `closing` 1 fr | Claw arm, closing pose |
| `assets/claw/claw_open.png` | 144x101 | `open` 1 fr | Claw arm, open pose. All four frames share one crop box, so they stay registered; the mouth sits where a carried item hangs. |

### Backgrounds, cutscene stills and scenery

| File | Size | Animation | What it is |
|------|------|-----------|------------|
| `assets/env/bubble.png` | 24x24 | `rise` 6 fr | Bubble, count scales with the VFX slider |
| `assets/env/coral_dead.png` | 174x140 | `idle` 6 fr | Coral overlay, bleached. Sways in place; count is per ocean tier. |
| `assets/env/coral_healthy.png` | 157x190 | `idle` 6 fr | Coral overlay, in colour. Sways in place; count is per ocean tier. |
| `assets/env/reef_coral_1.png` | 78x150 | static | Tank parallax scenery, planted on the seabed. Sized to the water column above the sand: the tank window is 848x408 and the sand line is at y=268, so nothing here is taller than that. |
| `assets/env/reef_coral_2.png` | 159x170 | static | Tank parallax scenery, planted on the seabed. Sized to the water column above the sand: the tank window is 848x408 and the sand line is at y=268, so nothing here is taller than that. |
| `assets/env/reef_coral_3.png` | 109x205 | static | Tank parallax scenery, planted on the seabed. Sized to the water column above the sand: the tank window is 848x408 and the sand line is at y=268, so nothing here is taller than that. |
| `assets/env/reef_coral_4.png` | 226x120 | static | Tank parallax scenery, planted on the seabed. Nearest depth. |
| `assets/env/reef_fish_1.png` | 423x100 | static | Tank parallax shoal. Hangs in midwater rather than standing on the sand (`base_y` on its row). |
| `assets/env/cutscene_01.png` | 1280x720 | static | Cutscene still 1 (placeholder) |
| `assets/env/cutscene_02.png` | 1280x720 | static | Cutscene still 2 (placeholder) |
| `assets/env/cutscene_03.png` | 1280x720 | static | Cutscene still 3 (placeholder) |
| `assets/env/cutscene_04.png` | 1280x720 | static | Opening beat 4: the diver, face to face with what lives in the bay. |
| `assets/env/cutscene_05.png` | 1280x720 | static | Opening beat 5: the three schematics on the workshop desk. |
| `assets/env/ending_0.png` | 1280x720 | static | Ending still, 0 machines built - the bay left as it was. One file per tier, named by the number of machines running in it: a fourth blueprint needs an `ending_4.png` beside these and no code change. The 2x originals are in `assets/ui/endings/`. |
| `assets/env/ending_1.png` | 1280x720 | static | Ending still, 1 machine built. |
| `assets/env/ending_2.png` | 1280x720 | static | Ending still, 2 machines built. |
| `assets/env/ending_3.png` | 1280x720 | static | Ending still, all three machines built. |
| `assets/env/hull_wall.png` | 128x128 | static | Submarine hull, tiled at native size over everything outside the window. Must tile seamlessly. |
| `assets/env/logo.png` | 541x276 | static | Title logo |
| `assets/env/menu_bg.png` | 1280x720 | static | Main menu backdrop. Full-frame, opaque. |
| `assets/env/seabed.png` | 1000x140 | static | Seabed floor inside the tank SubViewport, z_index -10 |
| `assets/env/water_bg.png` | 1280x720 | static | Deep-water backdrop. The furthest parallax layer inside the tank window - scaled from its own size to cover the window, never stretched. |

### Background sea life

| File | Size | Animation | What it is |
|------|------|-----------|------------|
| `assets/fish/fish_cute_1.png` | 59x52 | `swim` 1 fr | Background fish, round variant 1. Not grabbable. |
| `assets/fish/fish_cute_2.png` | 59x52 | `swim` 1 fr | Background fish, round variant 2. Not grabbable. |
| `assets/fish/fish_cute_3.png` | 59x52 | `swim` 1 fr | Background fish, round variant 3. Not grabbable. |
| `assets/fish/fish_large_1.png` | 167x88 | `swim` 1 fr | Background fish, large. Not grabbable. |
| `assets/fish/fish_medium_1.png` | 187x64 | `swim` 1 fr | Background fish, long variant 1. Not grabbable. |
| `assets/fish/fish_medium_2.png` | 187x64 | `swim` 1 fr | Background fish, long variant 2. Not grabbable. |
| `assets/fish/fish_small_1.png` | 66x48 | `swim` 1 fr | Background fish, small variant 1. Not grabbable. |
| `assets/fish/fish_small_2.png` | 66x48 | `swim` 1 fr | Background fish, small variant 2. Not grabbable. |
| `assets/fish/fish_small_3.png` | 66x48 | `swim` 1 fr | Background fish, small variant 3. Not grabbable. |
| `assets/fish/jellyfish_1.png` | 70x70 | `swim` 1 fr | Background jellyfish 1. Not grabbable. |
| `assets/fish/jellyfish_2.png` | 70x70 | `swim` 1 fr | Background jellyfish 2. Not grabbable. |

### Inspection tools

| File | Size | Animation | What it is |
|------|------|-----------|------------|
| `assets/tools/tool_cutter.png` | 59x72 | `idle` 1 fr | Cutter. Opens a sealed crate, and does nothing else. One drawing per tool - "armed" is a plate behind the row, not a second drawing. |
| `assets/tools/tool_magnifier.png` | 56x72 | `idle` 1 fr | Magnifier. Reveals what the item is really made of. One drawing per tool - "armed" is a plate behind the row, not a second drawing. |
| `assets/tools/tool_rinse.png` | 64x72 | `idle` 1 fr | Rinse. Washes an ordinary stain off for good; a chemical one will not shift. One drawing per tool - "armed" is a plate behind the row, not a second drawing. |
| `assets/tools/tool_swab.png` | 46x72 | `idle` 1 fr | Chem Swab. Names the stain, which is what says whether a rinse will do anything. One drawing per tool - "armed" is a plate behind the row, not a second drawing. |

### Interface chrome, schematics and parts

| File | Size | Animation | What it is |
|------|------|-----------|------------|
| `assets/ui/blueprint_ocean_cleaning_drone.png` | 810x590 | static | Ocean Cleaning Drone schematic, unbuilt: the sheet plus the faint lineart of every part. |
| `assets/ui/blueprint_ocean_cleaning_drone_done.png` | 810x590 | static | Ocean Cleaning Drone schematic, fully inked. Shown once the machine is built. |
| `assets/ui/blueprint_recycling_station.png` | 810x590 | static | Recycling Station schematic, unbuilt: the sheet plus the faint lineart of every part. |
| `assets/ui/blueprint_recycling_station_done.png` | 810x590 | static | Recycling Station schematic, fully inked. Shown once the machine is built. |
| `assets/ui/blueprint_reef_restoration_pod.png` | 810x590 | static | Reef Restoration Pod schematic, unbuilt: the sheet plus the faint lineart of every part. |
| `assets/ui/blueprint_reef_restoration_pod_done.png` | 810x590 | static | Reef Restoration Pod schematic, fully inked. Shown once the machine is built. |
| `assets/ui/briefing_bg.png` | 1280x720 | static | The before-shift briefing: desk, taped blueprint sheet, stickers, and the painted socket the Lower the Claw button drops into. Full-frame, opaque. |
| `assets/ui/button_disabled.png` | 64x64 | static | Button disabled state. NinePatch, 20px margins. |
| `assets/ui/button_hover.png` | 64x64 | static | Button hover state. NinePatch, 20px margins. |
| `assets/ui/button_normal.png` | 64x64 | static | Button normal state. NinePatch, 20px margins. |
| `assets/ui/button_pressed.png` | 64x64 | static | Button pressed state. NinePatch, 20px margins. |
| `assets/ui/chat_bubble.png` | 907x178 | static | Dialogue plate for the cutscene and the ending screen. White inside, so text on it is dark. |
| `assets/ui/chip_match.png` | 64x40 | static | Evidence chip that satisfies an active rule (green). NinePatchRect, 24px margins. |
| `assets/ui/chip_reveal.png` | 64x40 | static | Evidence chip, tool reveal (gold). NinePatchRect, 24px margins. |
| `assets/ui/chip_surface.png` | 64x40 | static | Evidence chip, free surface info (grey). NinePatchRect, 24px margins. |
| `assets/ui/comp_drone_shell.png` | 393x360 | static | Ocean Cleaning Drone part `drone_shell`, inked. Drawn over the sheet once crafted; before that the sheet's own lineart shows through, so there is no locked variant. |
| `assets/ui/comp_intake_arm.png` | 151x121 | static | Recycling Station part `intake_arm`, inked. Drawn over the sheet once crafted; before that the sheet's own lineart shows through, so there is no locked variant. |
| `assets/ui/comp_pod_shell.png` | 398x370 | static | Reef Restoration Pod part `pod_shell`, inked. Drawn over the sheet once crafted; before that the sheet's own lineart shows through, so there is no locked variant. |
| `assets/ui/comp_press_housing.png` | 381x351 | static | Recycling Station part `press_housing`, inked. Drawn over the sheet once crafted; before that the sheet's own lineart shows through, so there is no locked variant. |
| `assets/ui/comp_rotor_skid.png` | 460x186 | static | Ocean Cleaning Drone part `rotor_skid`, inked. Drawn over the sheet once crafted; before that the sheet's own lineart shows through, so there is no locked variant. |
| `assets/ui/comp_seeding_arm.png` | 90x189 | static | Reef Restoration Pod part `seeding_arm`, inked. Drawn over the sheet once crafted; before that the sheet's own lineart shows through, so there is no locked variant. |
| `assets/ui/comp_sorting_belt.png` | 206x132 | static | Recycling Station part `sorting_belt`, inked. Drawn over the sheet once crafted; before that the sheet's own lineart shows through, so there is no locked variant. |
| `assets/ui/desk_bg.png` | 1280x720 | static | The whole sorting desk - top bar, panel frames, bin slots. Full-frame, opaque. Every desk node is positioned into a slot painted in here. |
| `assets/ui/desk_meter_frame.png` | 703x48 | static | Frame around the blueprint progress strip at the top of the desk. |
| `assets/ui/icon_check.png` | 48x48 | static | HUD icon (V) |
| `assets/ui/icon_cross.png` | 48x48 | static | HUD icon (X) |
| `assets/ui/icon_pause.png` | 48x48 | static | HUD icon (II) |
| `assets/ui/icon_pause_pressed.png` | 48x48 | static | Pause button, pressed state. |
| `assets/ui/machine_frame.png` | 1280x720 | static | The whole cockpit: hull, window surround, glass streaks, panels. Drawn over the tank; the window opening is the transparent rect at (216,122) 848x408. |
| `assets/ui/machine_grab.png` | 128x122 | static | GRAB button, resting. Drops the claw. |
| `assets/ui/machine_grab_pressed.png` | 128x122 | static | GRAB button, pushed. Same crop as the resting state so it does not jump. |
| `assets/ui/machine_left.png` | 142x116 | static | Left arrow button, resting. |
| `assets/ui/machine_left_pressed.png` | 142x116 | static | Left arrow button, pushed. |
| `assets/ui/machine_right.png` | 140x116 | static | Right arrow button, resting. |
| `assets/ui/machine_right_pressed.png` | 140x116 | static | Right arrow button, pushed. |
| `assets/ui/machine_settings.png` | 44x46 | static | Settings cog, resting. Opens the pause menu. |
| `assets/ui/machine_settings_hover.png` | 44x46 | static | Settings cog, hovered. |
| `assets/ui/machine_slider.png` | 322x64 | static | The marker that slides along the top rail, showing which slice of the seabed the window is on. Moves in code; the rail behind it is part of machine_frame. |
| `assets/ui/machine_sorting.png` | 216x135 | static | SORTING folder button, resting. Switches to the desk. |
| `assets/ui/machine_sorting_hover.png` | 216x135 | static | SORTING folder button, hovered. |
| `assets/ui/meter_bg.png` | 320x32 | static | Track behind a blueprint's progress strip on the desk. Fill is clipped by width. |
| `assets/ui/meter_fill.png` | 320x32 | static | Fill of a blueprint's progress strip on the desk. Clipped by width, never scaled. |
| `assets/ui/minimap_item.png` | 10x10 | static | Minimap dot for one item on the seabed |
| `assets/ui/cursor.png` | 42x64 | static | The mouse pointer, set once in `main.gd`. A custom cursor goes to the OS at the png's own pixel size - it does not scale with the game or the display, so this file IS the size it appears at, and the arrow's point must stay at the top-left (`main.gd` CURSOR_HOTSPOT). |
| `assets/ui/panel_dark.png` | 261x261 | static | Modal / overlay panel: the rulebook and the blueprint component popup. NinePatchRect, 24px margins. Square 1:1 plate, so it stretches to any rectangle. |
| `assets/ui/panel_main.png` | 261x261 | static | Main UI panel, and the theme's Panel/PanelContainer. NinePatchRect, 24px margins. Same 1:1 plate, lighter. |
| `assets/ui/panel_settings.png` | 636x366 | static | The settings dialog plate, used by the settings screen and the pause overlay. NinePatch margins 60 left / 100 top / 110 right / 60 bottom - the close X is painted into the art, and those margins are what keep it pinned in the top-right corner at any panel size. The button over it is a `CloseButton` theme variation, which draws nothing of its own. |
| `assets/ui/panel_slot.png` | 173x83 | static | Inventory slot background. NinePatchRect, 24px margins. |
| `assets/ui/panel_slot_selected.png` | 173x83 | static | Inventory slot, selected. A different PNG rather than a tint. NinePatchRect, 24px margins. |
| `assets/ui/primary_button.png` | 422x121 | static | The one call to action on a screen - Start, Lower the Claw, Start the Next Day. Plate drawn at 408x108 inside the box; the padding is the room the hover state grows into. |
| `assets/ui/primary_button_hover.png` | 422x121 | static | Same plate, larger, same box, so hover reads as a pop and nothing reflows. Also the focus state. |
| `assets/ui/report_panels.png` | 1280x720 | static | The two taped sheets of the end-of-day report - tall one for the haul, wide one for the mistakes. Transparent outside the paper, so it lays over the desk still. |
| `assets/ui/scrollbar_grabber.png` | 16x64 | static | Scrollbar grabber. NinePatch, 8px margins, stretched to length. |
| `assets/ui/scrollbar_grabber_hover.png` | 16x64 | static | Scrollbar grabber, hovered/dragged. |
| `assets/ui/scrollbar_track.png` | 16x64 | static | Scrollbar track. NinePatch, 8px margins, stretched to length. |
| `assets/ui/slider_fill.png` | 519x26 | static | Volume slider fill, the part left of the knob. NinePatch, 8px margins. |
| `assets/ui/slider_grabber.png` | 32x30 | static | Volume slider knob. |
| `assets/ui/slider_grabber_hover.png` | 32x30 | static | Volume slider knob, hovered/held. |
| `assets/ui/slider_track.png` | 519x32 | static | Volume slider track. NinePatch, 8px margins, stretched to width. The row height comes from `SettingsPanel.SLIDER_SIZE`, which is set from this art. |
| `assets/ui/textfield_focus.png` | 64x40 | static | Text field, focused. NinePatch, 12px margins. |
| `assets/ui/textfield_normal.png` | 64x40 | static | Text field. NinePatch, 12px margins, stretched. |
| `assets/ui/toggle_off.png` | 64x32 | static | Settings toggle, off state. Own drawing, not a tint of the on state. |
| `assets/ui/toggle_on.png` | 64x32 | static | Settings toggle, on state. |
| `assets/ui/tool_rack_frame.png` | 187x287 | static | Frame around the four-tool rack in the inspect panel. |
| `assets/ui/tool_row_selected.png` | 187x67 | static | Plate slid in behind the armed tool. The tool art itself never changes. |

---

## audio

Eleven sound effects, played through the `SFX` bus by `Game.play_sfx()`. Each is
requested by name, e.g. `Events.sfx_requested.emit(&"bin_accept")`, so replacing
a sound is dropping a new `.wav` at the same path. There is no music yet; the
`Music` bus and its volume slider exist and are wired, but nothing plays on it.

| File | Length | Format | Played when |
|------|--------|--------|-------------|
| `assets/audio/bin_accept.wav` | 0.20 s | 22 kHz 16-bit mono | Bin takes the item (does NOT mean the answer was right). |
| `assets/audio/bin_reject.wav` | 0.34 s | 22 kHz 16-bit mono | Bin refuses: nothing selected, sealed crate, or no shift time. |
| `assets/audio/claw_drop.wav` | 0.22 s | 22 kHz 16-bit mono | Claw begins its descent. |
| `assets/audio/claw_move.wav` | 0.05 s | 22 kHz 16-bit mono | Claw slides along the rail (retriggers every 0.22 s while held). |
| `assets/audio/day_end.wav` | 0.54 s | 22 kHz 16-bit mono | Shift ends, and the day report opens. |
| `assets/audio/grab_fail.wav` | 0.27 s | 22 kHz 16-bit mono | Grip roll failed, or the claw closed on nothing. |
| `assets/audio/grab_success.wav` | 0.19 s | 22 kHz 16-bit mono | Grip roll succeeded, item is coming up. |
| `assets/audio/reveal_nothing.wav` | 0.24 s | 22 kHz 16-bit mono | A tool was spent and found nothing on this item. |
| `assets/audio/reveal_success.wav` | 0.26 s | 22 kHz 16-bit mono | A tool revealed a hidden property. |
| `assets/audio/tool_use.wav` | 0.11 s | 22 kHz 16-bit mono | A tool is used on an item. |
| `assets/audio/ui_click.wav` | 0.03 s | 22 kHz 16-bit mono | Any button, tab switch, or menu press. |
| `assets/audio/music_game.mp3` | loops | mp3 stereo | The song. Started by `Game` for the whole session, Music bus at -8 dB. |
| `assets/audio/amb_sea.mp3` | loops | mp3 stereo | Sea ambience, the room the song plays in. Started by `Game` for the whole session, Music bus at -4 dB. Both beds sit on the Music bus, so the one Music slider covers all of it. |
