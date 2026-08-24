# Asset Manifest

For the designers. **Every visual in the game is one PNG from this list.** The
code never draws a shape and never uses a `ColorRect` — if you can see it on
screen, it came from a file below.

## The replacement rule

**Same path, same pixel size, flat art, no baked lighting.** That is the whole
contract. Everything below expands on it.

1. Drop your PNG at **exactly the same path** with **exactly the same pixel
   size** as the table says. Nothing else needs to change — no code, no scenes.
2. Keep the transparent background. Items, claw, fish, bins and tools are cut
   out; only the `env/` backgrounds are opaque.
3. Keep the art inside the stated canvas. The anchor point is the centre of the
   canvas for everything except `ui/` panels, which stretch from their corners.
4. **Do not bake lighting, shadows or glow into the art.** Lighting and shaders
   are a later pass by the owner, applied per `CanvasLayer` and to the tank's
   `SubViewport` as a whole. Art that already has a light direction painted in
   will fight it.
5. **One PNG is one whole thing.** The game shows one texture per node — a
   bottle is one file, not a body plus a cap plus a label. The only thing ever
   layered on top of an item is the hotspot ring overlay, which is a debug aid
   (see below).
6. **State is a different drawing, never a tint.** A locked tool, a highlighted
   bin, a selected slot — each is its own PNG or its own named animation. The
   code never recolours your art to mean something, because that breaks the
   moment your palette differs from the placeholder's.
7. Every sprite is displayed at **scale 1** at its authored size, with exactly
   three exceptions. Each is one named constant in one file, and this is the
   list — if you need to know the size your art is actually read at, it is here.

   | What | Authored | Displayed | Constant |
   |------|----------|-----------|----------|
   | Item in the inspect panel | 160×160 | 288×288 | `InspectPanel.BASE_SCALE` = 1.8 |
   | Tool icon in the rack | 96×96 | 60×60 | `InspectPanel.TOOL_ICON_SCALE` = 0.62 |
   | Bin on the desk | 200×240 | 144×173 | `BinRow.BIN_DISPLAY_SCALE` = 0.72 |

   Everywhere else, the pixel size in the table below is the size on screen.

## How to animate something

**No animation in this game is written in code.** Anything that moves visually
is an `AnimatedSprite2D` playing a named animation from a `SpriteFrames`
resource in `data/frames/`. Code only decides *which* animation plays and
*when* — never what it looks like.

Every animation already exists with **one placeholder frame**. To animate it:

1. Draw your frames and save them next to the existing file, numbered:
   `claw_closing_01.png`, `claw_closing_02.png`, …
2. Open the matching `data/frames/*.tres` in Godot and drop the frames into
   that animation.

Do not add nodes, rename animations, or replace the `SpriteFrames` — the game
looks animations up by name. The **target frames** column is what we are
designing for; fewer works, the animation just plays shorter.

## Hotspots — read this before drawing any item

Items carry 2–3 invisible hotspots — a seam, a label corner, a stained patch —
and a tool only reveals its property when clicked on the matching one.

Hotspot positions live in `data/items/*.tres`. The rings you see are **not part
of the item art**: they are a separate overlay, `assets/items/hotspots_<id>.png`,
generated from that data by `tools/gen_hotspot_overlays.gd`, and the player can
switch them off.

**In the final art the hotspot must become a real drawn feature of the item at
the same coordinates** — draw the stain where the rinse ring is, the printed
code where the magnifier ring is, the cut seam where the cutter ring is. The
overlay then survives only as an accessibility aid, not as the way the puzzle is
solved. Never edit `hotspots_<id>.png` by hand; move the coordinates in the
`.tres` and re-run the generator.

Ring colours match the tool: rinse blue, swab pink, magnifier yellow, cutter
red. Those come from `ToolData.color` in `data/tools/*.tres`.

## No AI generation

No asset in this project — image or audio — may be AI generated. The current
files are drawn programmatically by `tools/gen_placeholders.py` and
`tools/gen_sounds.py`.

---

## Animations

| SpriteFrames | Animation | Placeholder frame | Target frames |
|--------------|-----------|-------------------|---------------|
| `data/frames/claw_frames.tres` | `open` | `assets/claw/claw_open.png` | 4 |
| `data/frames/claw_frames.tres` | `closing` | `assets/claw/claw_closing.png` | 6 |
| `data/frames/claw_frames.tres` | `closed` | `assets/claw/claw_closed.png` | 2 |
| `data/frames/claw_frames.tres` | `carrying` | `assets/claw/claw_carrying.png` | 6 |
| `data/frames/fish_bg_small_frames.tres` | `swim` | `assets/fish/fish_bg_small.png` | 6 |
| `data/frames/fish_bg_medium_frames.tres` | `swim` | `assets/fish/fish_bg_medium.png` | 6 |
| `data/frames/fish_bg_large_frames.tres` | `swim` | `assets/fish/fish_bg_large.png` | 6 |
| `data/frames/item_banana_peel_frames.tres` | `idle` | `assets/items/item_banana_peel.png` | 2 |
| `data/frames/item_banana_peel_frames.tres` | `wobble` | `assets/items/item_banana_peel.png` | 4 |
| `data/frames/item_banana_peel_frames.tres` | `sinking` | `assets/items/item_banana_peel.png` | 6 |
| `data/frames/item_fish_bone_frames.tres` | `idle` | `assets/items/item_fish_bone.png` | 2 |
| `data/frames/item_fish_bone_frames.tres` | `wobble` | `assets/items/item_fish_bone.png` | 4 |
| `data/frames/item_fish_bone_frames.tres` | `sinking` | `assets/items/item_fish_bone.png` | 6 |
| `data/frames/item_pet_bottle_frames.tres` | `idle` | `assets/items/item_pet_bottle.png` | 2 |
| `data/frames/item_pet_bottle_frames.tres` | `wobble` | `assets/items/item_pet_bottle.png` | 4 |
| `data/frames/item_pet_bottle_frames.tres` | `sinking` | `assets/items/item_pet_bottle.png` | 6 |
| `data/frames/item_alu_can_frames.tres` | `idle` | `assets/items/item_alu_can.png` | 2 |
| `data/frames/item_alu_can_frames.tres` | `wobble` | `assets/items/item_alu_can.png` | 4 |
| `data/frames/item_alu_can_frames.tres` | `sinking` | `assets/items/item_alu_can.png` | 6 |
| `data/frames/item_styrofoam_tray_frames.tres` | `idle` | `assets/items/item_styrofoam_tray.png` | 2 |
| `data/frames/item_styrofoam_tray_frames.tres` | `wobble` | `assets/items/item_styrofoam_tray.png` | 4 |
| `data/frames/item_styrofoam_tray_frames.tres` | `sinking` | `assets/items/item_styrofoam_tray.png` | 6 |
| `data/frames/item_car_battery_frames.tres` | `idle` | `assets/items/item_car_battery.png` | 2 |
| `data/frames/item_car_battery_frames.tres` | `wobble` | `assets/items/item_car_battery.png` | 4 |
| `data/frames/item_car_battery_frames.tres` | `sinking` | `assets/items/item_car_battery.png` | 6 |
| `data/frames/item_oil_jerrycan_frames.tres` | `idle` | `assets/items/item_oil_jerrycan.png` | 2 |
| `data/frames/item_oil_jerrycan_frames.tres` | `wobble` | `assets/items/item_oil_jerrycan.png` | 4 |
| `data/frames/item_oil_jerrycan_frames.tres` | `sinking` | `assets/items/item_oil_jerrycan.png` | 6 |
| `data/frames/item_paint_bottle_frames.tres` | `idle` | `assets/items/item_paint_bottle.png` | 2 |
| `data/frames/item_paint_bottle_frames.tres` | `wobble` | `assets/items/item_paint_bottle.png` | 4 |
| `data/frames/item_paint_bottle_frames.tres` | `sinking` | `assets/items/item_paint_bottle.png` | 6 |
| `data/frames/item_juice_carton_frames.tres` | `idle` | `assets/items/item_juice_carton.png` | 2 |
| `data/frames/item_juice_carton_frames.tres` | `wobble` | `assets/items/item_juice_carton.png` | 4 |
| `data/frames/item_juice_carton_frames.tres` | `sinking` | `assets/items/item_juice_carton.png` | 6 |
| `data/frames/item_eco_tote_frames.tres` | `idle` | `assets/items/item_eco_tote.png` | 2 |
| `data/frames/item_eco_tote_frames.tres` | `wobble` | `assets/items/item_eco_tote.png` | 4 |
| `data/frames/item_eco_tote_frames.tres` | `sinking` | `assets/items/item_eco_tote.png` | 6 |
| `data/frames/item_paper_cup_frames.tres` | `idle` | `assets/items/item_paper_cup.png` | 2 |
| `data/frames/item_paper_cup_frames.tres` | `wobble` | `assets/items/item_paper_cup.png` | 4 |
| `data/frames/item_paper_cup_frames.tres` | `sinking` | `assets/items/item_paper_cup.png` | 6 |
| `data/frames/item_spray_can_frames.tres` | `idle` | `assets/items/item_spray_can.png` | 2 |
| `data/frames/item_spray_can_frames.tres` | `wobble` | `assets/items/item_spray_can.png` | 4 |
| `data/frames/item_spray_can_frames.tres` | `sinking` | `assets/items/item_spray_can.png` | 6 |
| `data/frames/item_glass_jar_frames.tres` | `idle` | `assets/items/item_glass_jar.png` | 2 |
| `data/frames/item_glass_jar_frames.tres` | `wobble` | `assets/items/item_glass_jar.png` | 4 |
| `data/frames/item_glass_jar_frames.tres` | `sinking` | `assets/items/item_glass_jar.png` | 6 |
| `data/frames/item_fishing_net_frames.tres` | `idle` | `assets/items/item_fishing_net.png` | 2 |
| `data/frames/item_fishing_net_frames.tres` | `wobble` | `assets/items/item_fishing_net.png` | 4 |
| `data/frames/item_fishing_net_frames.tres` | `sinking` | `assets/items/item_fishing_net.png` | 6 |
| `data/frames/bin_organic_frames.tres` | `idle` | `assets/bins/bin_organic.png` | 2 |
| `data/frames/bin_organic_frames.tres` | `accept` | `assets/bins/bin_organic_accept.png` | 6 |
| `data/frames/bin_organic_frames.tres` | `reject` | `assets/bins/bin_organic_reject.png` | 6 |
| `data/frames/bin_organic_frames.tres` | `highlight` | `assets/bins/bin_organic_highlight.png` | 4 |
| `data/frames/bin_recyclable_frames.tres` | `idle` | `assets/bins/bin_recyclable.png` | 2 |
| `data/frames/bin_recyclable_frames.tres` | `accept` | `assets/bins/bin_recyclable_accept.png` | 6 |
| `data/frames/bin_recyclable_frames.tres` | `reject` | `assets/bins/bin_recyclable_reject.png` | 6 |
| `data/frames/bin_recyclable_frames.tres` | `highlight` | `assets/bins/bin_recyclable_highlight.png` | 4 |
| `data/frames/bin_hazard_frames.tres` | `idle` | `assets/bins/bin_hazard.png` | 2 |
| `data/frames/bin_hazard_frames.tres` | `accept` | `assets/bins/bin_hazard_accept.png` | 6 |
| `data/frames/bin_hazard_frames.tres` | `reject` | `assets/bins/bin_hazard_reject.png` | 6 |
| `data/frames/bin_hazard_frames.tres` | `highlight` | `assets/bins/bin_hazard_highlight.png` | 4 |
| `data/frames/bin_landfill_frames.tres` | `idle` | `assets/bins/bin_landfill.png` | 2 |
| `data/frames/bin_landfill_frames.tres` | `accept` | `assets/bins/bin_landfill_accept.png` | 6 |
| `data/frames/bin_landfill_frames.tres` | `reject` | `assets/bins/bin_landfill_reject.png` | 6 |
| `data/frames/bin_landfill_frames.tres` | `highlight` | `assets/bins/bin_landfill_highlight.png` | 4 |
| `data/frames/tool_rinse_frames.tres` | `idle` | `assets/tools/tool_rinse.png` | 2 |
| `data/frames/tool_rinse_frames.tres` | `using` | `assets/tools/tool_rinse_using.png` | 4 |
| `data/frames/tool_rinse_frames.tres` | `locked` | `assets/tools/tool_rinse_locked.png` | 1 |
| `data/frames/tool_swab_frames.tres` | `idle` | `assets/tools/tool_swab.png` | 2 |
| `data/frames/tool_swab_frames.tres` | `using` | `assets/tools/tool_swab_using.png` | 4 |
| `data/frames/tool_swab_frames.tres` | `locked` | `assets/tools/tool_swab_locked.png` | 1 |
| `data/frames/tool_magnifier_frames.tres` | `idle` | `assets/tools/tool_magnifier.png` | 2 |
| `data/frames/tool_magnifier_frames.tres` | `using` | `assets/tools/tool_magnifier_using.png` | 4 |
| `data/frames/tool_magnifier_frames.tres` | `locked` | `assets/tools/tool_magnifier_locked.png` | 1 |
| `data/frames/tool_cutter_frames.tres` | `idle` | `assets/tools/tool_cutter.png` | 2 |
| `data/frames/tool_cutter_frames.tres` | `using` | `assets/tools/tool_cutter_using.png` | 4 |
| `data/frames/tool_cutter_frames.tres` | `locked` | `assets/tools/tool_cutter_locked.png` | 1 |
| `data/frames/bubble_frames.tres` | `rise` | `assets/env/bubble.png` | 6 |
| `data/frames/coral_healthy_frames.tres` | `idle` | `assets/env/coral_healthy.png` | 6 |
| `data/frames/coral_dead_frames.tres` | `idle` | `assets/env/coral_dead.png` | 6 |
| `data/frames/debris_overlay_frames.tres` | `idle` | `assets/env/debris_overlay.png` | 6 |

## Every PNG

`Animated` names the `SpriteFrames` animations this PNG is the placeholder
frame for, with the frame count the final version should have. `static` means
the file is displayed as-is and never animates.

| Path | Size | Animated | What it is |
|------|------|----------|-----------|
| `assets/items/item_banana_peel.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `banana_peel` |
| `assets/items/item_fish_bone.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `fish_bone` |
| `assets/items/item_pet_bottle.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `pet_bottle` |
| `assets/items/item_alu_can.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `alu_can` |
| `assets/items/item_styrofoam_tray.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `styrofoam_tray` |
| `assets/items/item_car_battery.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `car_battery` |
| `assets/items/item_oil_jerrycan.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `oil_jerrycan` |
| `assets/items/item_paint_bottle.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `paint_bottle` |
| `assets/items/item_juice_carton.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `juice_carton` |
| `assets/items/item_eco_tote.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `eco_tote` |
| `assets/items/item_paper_cup.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `paper_cup` |
| `assets/items/item_spray_can.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `spray_can` |
| `assets/items/item_glass_jar.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `glass_jar` |
| `assets/items/item_fishing_net.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `fishing_net` |
| `assets/claw/claw_open.png` | 160x160 | `open` 4 fr | Claw arm, open pose |
| `assets/claw/claw_closing.png` | 160x160 | `closing` 6 fr | Claw arm, closing pose |
| `assets/claw/claw_closed.png` | 160x160 | `closed` 2 fr | Claw arm, closed pose |
| `assets/claw/claw_carrying.png` | 160x160 | `carrying` 6 fr | Claw arm, carrying pose |
| `assets/claw/claw_cable.png` | 8x64 | static | Cable, stretched vertically from rail to claw |
| `assets/fish/fish_bg_small.png` | 96x48 | `swim` 6 fr | Background fish. Not grabbable - atmosphere only |
| `assets/fish/fish_bg_medium.png` | 128x64 | `swim` 6 fr | Background fish. Not grabbable - atmosphere only |
| `assets/fish/fish_bg_large.png` | 176x88 | `swim` 6 fr | Background fish. Not grabbable - atmosphere only |
| `assets/bins/bin_organic.png` | 200x240 | `idle` 2 fr | organic bin, idle state |
| `assets/bins/bin_organic_accept.png` | 200x240 | `accept` 6 fr | organic bin, accept state |
| `assets/bins/bin_organic_reject.png` | 200x240 | `reject` 6 fr | organic bin, reject state |
| `assets/bins/bin_organic_highlight.png` | 200x240 | `highlight` 4 fr | organic bin, highlight state |
| `assets/bins/bin_recyclable.png` | 200x240 | `idle` 2 fr | recyclable bin, idle state |
| `assets/bins/bin_recyclable_accept.png` | 200x240 | `accept` 6 fr | recyclable bin, accept state |
| `assets/bins/bin_recyclable_reject.png` | 200x240 | `reject` 6 fr | recyclable bin, reject state |
| `assets/bins/bin_recyclable_highlight.png` | 200x240 | `highlight` 4 fr | recyclable bin, highlight state |
| `assets/bins/bin_hazard.png` | 200x240 | `idle` 2 fr | hazard bin, idle state |
| `assets/bins/bin_hazard_accept.png` | 200x240 | `accept` 6 fr | hazard bin, accept state |
| `assets/bins/bin_hazard_reject.png` | 200x240 | `reject` 6 fr | hazard bin, reject state |
| `assets/bins/bin_hazard_highlight.png` | 200x240 | `highlight` 4 fr | hazard bin, highlight state |
| `assets/bins/bin_landfill.png` | 200x240 | `idle` 2 fr | landfill bin, idle state |
| `assets/bins/bin_landfill_accept.png` | 200x240 | `accept` 6 fr | landfill bin, accept state |
| `assets/bins/bin_landfill_reject.png` | 200x240 | `reject` 6 fr | landfill bin, reject state |
| `assets/bins/bin_landfill_highlight.png` | 200x240 | `highlight` 4 fr | landfill bin, highlight state |
| `assets/tools/tool_rinse.png` | 96x96 | `idle` 2 fr | Bilas tool, idle |
| `assets/tools/tool_rinse_using.png` | 96x96 | `using` 4 fr | Bilas tool, using |
| `assets/tools/tool_rinse_locked.png` | 96x96 | `locked` 1 fr | Bilas tool, locked |
| `assets/tools/tool_swab.png` | 96x96 | `idle` 2 fr | Usap Kimia tool, idle |
| `assets/tools/tool_swab_using.png` | 96x96 | `using` 4 fr | Usap Kimia tool, using |
| `assets/tools/tool_swab_locked.png` | 96x96 | `locked` 1 fr | Usap Kimia tool, locked |
| `assets/tools/tool_magnifier.png` | 96x96 | `idle` 2 fr | Kaca Pembesar tool, idle |
| `assets/tools/tool_magnifier_using.png` | 96x96 | `using` 4 fr | Kaca Pembesar tool, using |
| `assets/tools/tool_magnifier_locked.png` | 96x96 | `locked` 1 fr | Kaca Pembesar tool, locked |
| `assets/tools/tool_cutter.png` | 96x96 | `idle` 2 fr | Pemotong tool, idle |
| `assets/tools/tool_cutter_using.png` | 96x96 | `using` 4 fr | Pemotong tool, using |
| `assets/tools/tool_cutter_locked.png` | 96x96 | `locked` 1 fr | Pemotong tool, locked |
| `assets/ui/panel_main.png` | 96x96 | static | Main UI panel. NinePatchRect, 24px margins. |
| `assets/ui/panel_dark.png` | 96x96 | static | Modal / overlay panel. NinePatchRect, 24px margins. |
| `assets/ui/panel_slot.png` | 96x96 | static | Inventory slot background. NinePatchRect, 24px margins. |
| `assets/ui/panel_slot_selected.png` | 96x96 | static | Inventory slot, selected. A different PNG rather than a tint. NinePatchRect, 24px margins. |
| `assets/ui/chip_surface.png` | 64x40 | static | Evidence chip, free surface info (grey). NinePatchRect, 24px margins. |
| `assets/ui/chip_reveal.png` | 64x40 | static | Evidence chip, tool reveal (gold). NinePatchRect, 24px margins. |
| `assets/ui/button_normal.png` | 64x64 | static | Button normal state. NinePatch, 20px margins. |
| `assets/ui/button_hover.png` | 64x64 | static | Button hover state. NinePatch, 20px margins. |
| `assets/ui/button_pressed.png` | 64x64 | static | Button pressed state. NinePatch, 20px margins. |
| `assets/ui/button_disabled.png` | 64x64 | static | Button disabled state. NinePatch, 20px margins. |
| `assets/ui/icon_day.png` | 48x48 | static | HUD icon (H) |
| `assets/ui/icon_quota.png` | 48x48 | static | HUD icon (T) |
| `assets/ui/icon_grab.png` | 48x48 | static | HUD icon (C) |
| `assets/ui/icon_health.png` | 48x48 | static | HUD icon (L) |
| `assets/ui/icon_book.png` | 48x48 | static | HUD icon (A) |
| `assets/ui/icon_close.png` | 48x48 | static | HUD icon (X) |
| `assets/ui/icon_check.png` | 48x48 | static | HUD icon (V) |
| `assets/ui/icon_cross.png` | 48x48 | static | HUD icon (X) |
| `assets/ui/icon_pause.png` | 48x48 | static | HUD icon (II) |
| `assets/ui/chip_match.png` | 64x40 | static | Evidence chip that satisfies an active rule (green). NinePatchRect, 24px margins. |
| `assets/ui/minimap_bg.png` | 960x28 | static | Minimap strip background. Stretched to width. |
| `assets/ui/minimap_view.png` | 64x28 | static | Minimap window showing the visible slice. Stretched. |
| `assets/ui/minimap_item.png` | 10x10 | static | Minimap dot for one item on the seabed |
| `assets/ui/minimap_claw.png` | 12x20 | static | Minimap marker for the claw |
| `assets/ui/meter_bg.png` | 320x32 | static | Ocean health meter bg. Fill is clipped by width. |
| `assets/ui/meter_fill.png` | 320x32 | static | Ocean health meter fill. Fill is clipped by width. |
| `assets/ui/arrow_left.png` | 96x96 | static | Console arrow button (left) |
| `assets/ui/arrow_right.png` | 96x96 | static | Console arrow button (right) |
| `assets/ui/joystick_base.png` | 128x128 | static | Console joystick base |
| `assets/ui/joystick_knob.png` | 72x72 | static | Console joystick knob, offsets with claw |
| `assets/env/water_bg.png` | 1280x720 | static | Full-screen water background, layer 0 |
| `assets/env/seabed.png` | 1000x140 | static | Seabed floor inside the tank SubViewport, z_index -10 |
| `assets/env/tank_frame.png` | 1040x460 | static | Machine frame around the tank. Centre is transparent. |
| `assets/env/glass_overlay.png` | 1000x420 | static | Glass reflection and tint, layer 20 |
| `assets/env/machine_console.png` | 1280x220 | static | Console backing plate under the tank, layer 30 |
| `assets/env/bubble.png` | 24x24 | `rise` 6 fr | Bubble, count scales with the VFX slider |
| `assets/env/cutscene_01.png` | 960x540 | static | Cutscene still 1 (placeholder) |
| `assets/env/cutscene_02.png` | 960x540 | static | Cutscene still 2 (placeholder) |
| `assets/env/cutscene_03.png` | 960x540 | static | Cutscene still 3 (placeholder) |
| `assets/env/logo.png` | 640x200 | static | Title logo |
| `assets/env/seabed_tier_0.png` | 1000x140 | static | Seabed backdrop for ocean tier 0. Tiled across the seabed width. |
| `assets/env/seabed_tier_1.png` | 1000x140 | static | Seabed backdrop for ocean tier 1. Tiled across the seabed width. |
| `assets/env/seabed_tier_2.png` | 1000x140 | static | Seabed backdrop for ocean tier 2. Tiled across the seabed width. |
| `assets/env/seabed_tier_3.png` | 1000x140 | static | Seabed backdrop for ocean tier 3. Tiled across the seabed width. |
| `assets/env/coral_healthy.png` | 120x140 | `idle` 6 fr | Coral overlay, in colour. Sways in place; count is per ocean tier. |
| `assets/env/coral_dead.png` | 120x140 | `idle` 6 fr | Coral overlay, bleached. Sways in place; count is per ocean tier. |
| `assets/env/debris_overlay.png` | 96x96 | `idle` 6 fr | Debris clutter on the seabed. Count falls as the ocean recovers. |
| `assets/items/hotspots_banana_peel.png` | 160x160 | static | Hotspot rings for `banana_peel`. **Generated from `data/items/banana_peel.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_fish_bone.png` | 160x160 | static | Hotspot rings for `fish_bone`. **Generated from `data/items/fish_bone.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_pet_bottle.png` | 160x160 | static | Hotspot rings for `pet_bottle`. **Generated from `data/items/pet_bottle.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_alu_can.png` | 160x160 | static | Hotspot rings for `alu_can`. **Generated from `data/items/alu_can.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_styrofoam_tray.png` | 160x160 | static | Hotspot rings for `styrofoam_tray`. **Generated from `data/items/styrofoam_tray.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_car_battery.png` | 160x160 | static | Hotspot rings for `car_battery`. **Generated from `data/items/car_battery.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_oil_jerrycan.png` | 160x160 | static | Hotspot rings for `oil_jerrycan`. **Generated from `data/items/oil_jerrycan.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_paint_bottle.png` | 160x160 | static | Hotspot rings for `paint_bottle`. **Generated from `data/items/paint_bottle.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_juice_carton.png` | 160x160 | static | Hotspot rings for `juice_carton`. **Generated from `data/items/juice_carton.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_eco_tote.png` | 160x160 | static | Hotspot rings for `eco_tote`. **Generated from `data/items/eco_tote.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_paper_cup.png` | 160x160 | static | Hotspot rings for `paper_cup`. **Generated from `data/items/paper_cup.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_spray_can.png` | 160x160 | static | Hotspot rings for `spray_can`. **Generated from `data/items/spray_can.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_glass_jar.png` | 160x160 | static | Hotspot rings for `glass_jar`. **Generated from `data/items/glass_jar.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |
| `assets/items/hotspots_fishing_net.png` | 160x160 | static | Hotspot rings for `fishing_net`. **Generated from `data/items/fishing_net.tres`** by `tools/gen_hotspot_overlays.gd` - never edit by hand, and do not draw it into the item art. |

_111 PNGs, 81 animations across 30 SpriteFrames resources._
_Hotspot overlays are generated separately — see above._
_Regenerate with_ `python3 tools/gen_placeholders.py`.
