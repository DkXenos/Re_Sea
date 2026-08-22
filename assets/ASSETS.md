# Asset Manifest

For the designers. **Every visual in the game is one PNG from this list.** The
code never draws a shape and never uses a `ColorRect` - if you can see it on
screen, it came from a file below.

## How to replace an asset

1. Drop your PNG at **exactly the same path** with **exactly the same pixel
   size** as the table says. Nothing else needs to change - no code, no scenes.
2. Keep the transparent background. Items, claw, fish, bins and tools are cut
   out; only the `env/` backgrounds are opaque.
3. Keep the art inside the stated canvas. The anchor point is the centre of the
   canvas for everything except `ui/` panels, which stretch from their corners.

## Animation

Anything marked **animates** is already an `AnimatedSprite2D` driven by a
`SpriteFrames` resource in `data/frames/`, currently holding one frame per
animation. To animate it, add your frames to that existing `SpriteFrames` - do
not replace the node. The **final frames** column is the frame count we are
designing for; fewer works, the animation just plays shorter.

Naming for extra frames: `claw_open_01.png`, `claw_open_02.png`, and so on next
to the existing file.

## Hotspots (items only)

Items carry 2-3 invisible hotspots - a seam, a label corner, a stained patch -
and a tool only reveals its property when clicked on the matching one. The
placeholder PNGs draw these as **thin dashed rings** with a letter (R rinse,
S swab, M magnifier, C cutter) so they can be tested.

**In the final art the ring must disappear** and the hotspot must become a real
feature of the drawing at the same place: draw the stain where the R ring is,
the printed code where the M ring is, the seam where the C ring is. Hotspot
positions live in `data/items/*.tres` and can be nudged there if your artwork
wants them elsewhere.

## No AI generation

No asset in this project - image or audio - may be AI generated. The current
files are drawn programmatically by `tools/gen_placeholders.py` and
`tools/gen_sounds.py`.

---

## Manifest

| Path | Size | What it is | Animates | Final frames |
|------|------|-----------|----------|--------------|
| `assets/items/item_banana_peel.png` | 160x160 | Kulit Pisang - kulit buah. Hotspots: none | yes (wobble in tank) | 4 |
| `assets/items/item_fish_bone.png` | 160x160 | Tulang Ikan - tulang. Hotspots: none | yes (wobble in tank) | 4 |
| `assets/items/item_pet_bottle.png` | 160x160 | Botol Air Bening - PET bening. Hotspots: has_residue, tag_text | yes (wobble in tank) | 4 |
| `assets/items/item_alu_can.png` | 160x160 | Kaleng Minuman - aluminium. Hotspots: has_residue, tag_text | yes (wobble in tank) | 4 |
| `assets/items/item_styrofoam_tray.png` | 160x160 | Wadah Styrofoam - styrofoam. Hotspots: tag_text | yes (wobble in tank) | 4 |
| `assets/items/item_car_battery.png` | 160x160 | Aki Bekas - logam dan plastik tebal. Hotspots: tag_text, true_material | yes (wobble in tank) | 4 |
| `assets/items/item_oil_jerrycan.png` | 160x160 | Jeriken Bening - HDPE bening. Hotspots: has_residue, residue_type, tag_text | yes (wobble in tank) | 4 |
| `assets/items/item_paint_bottle.png` | 160x160 | Botol Bening Bekas - PET bening. Hotspots: has_residue, residue_type, tag_text | yes (wobble in tank) | 4 |
| `assets/items/item_juice_carton.png` | 160x160 | Kotak Jus - kertas karton. Hotspots: tag_text, true_material | yes (wobble in tank) | 4 |
| `assets/items/item_eco_tote.png` | 160x160 | Tas Kain Ramah Lingkungan - kain katun. Hotspots: tag_text, true_material | yes (wobble in tank) | 4 |
| `assets/items/item_paper_cup.png` | 160x160 | Gelas Kertas - kertas. Hotspots: has_residue, tag_text, true_material | yes (wobble in tank) | 4 |
| `assets/items/item_spray_can.png` | 160x160 | Kaleng Semprot - kaleng baja. Hotspots: tag_text, true_material | yes (wobble in tank) | 4 |
| `assets/items/item_glass_jar.png` | 160x160 | Toples Kaca - kaca. Hotspots: has_residue, residue_type, tag_text | yes (wobble in tank) | 4 |
| `assets/items/item_fishing_net.png` | 160x160 | Jaring Nilon Sobek - nilon. Hotspots: tag_text, true_material | yes (wobble in tank) | 4 |
| `assets/claw/claw_open.png` | 160x160 | Claw arm, open pose | yes (one SpriteFrames animation per pose) | 6 |
| `assets/claw/claw_closing.png` | 160x160 | Claw arm, closing pose | yes (one SpriteFrames animation per pose) | 6 |
| `assets/claw/claw_closed.png` | 160x160 | Claw arm, closed pose | yes (one SpriteFrames animation per pose) | 6 |
| `assets/claw/claw_carrying.png` | 160x160 | Claw arm, carrying pose | yes (one SpriteFrames animation per pose) | 6 |
| `assets/claw/claw_cable.png` | 8x64 | Cable segment, tiled vertically from rail to claw | no | 1 |
| `assets/fish/fish_small.png` | 96x48 | Decoy fish, swims left to right | yes (swim) | 6 |
| `assets/fish/fish_medium.png` | 128x64 | Decoy fish, swims left to right | yes (swim) | 6 |
| `assets/fish/fish_large.png` | 176x88 | Decoy fish, swims left to right | yes (swim) | 6 |
| `assets/bins/bin_organic.png` | 200x240 | organic bin, idle state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_organic_accept.png` | 200x240 | organic bin, accept state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_organic_reject.png` | 200x240 | organic bin, reject state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_recyclable.png` | 200x240 | recyclable bin, idle state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_recyclable_accept.png` | 200x240 | recyclable bin, accept state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_recyclable_reject.png` | 200x240 | recyclable bin, reject state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_hazard.png` | 200x240 | hazard bin, idle state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_hazard_accept.png` | 200x240 | hazard bin, accept state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_hazard_reject.png` | 200x240 | hazard bin, reject state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_landfill.png` | 200x240 | landfill bin, idle state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_landfill_accept.png` | 200x240 | landfill bin, accept state | yes (idle/accept/reject) | 6 |
| `assets/bins/bin_landfill_reject.png` | 200x240 | landfill bin, reject state | yes (idle/accept/reject) | 6 |
| `assets/tools/tool_rinse.png` | 96x96 | Bilas tool, idle | yes (idle/using) | 4 |
| `assets/tools/tool_rinse_using.png` | 96x96 | Bilas tool, using | yes (idle/using) | 4 |
| `assets/tools/tool_swab.png` | 96x96 | Usap Kimia tool, idle | yes (idle/using) | 4 |
| `assets/tools/tool_swab_using.png` | 96x96 | Usap Kimia tool, using | yes (idle/using) | 4 |
| `assets/tools/tool_magnifier.png` | 96x96 | Kaca Pembesar tool, idle | yes (idle/using) | 4 |
| `assets/tools/tool_magnifier_using.png` | 96x96 | Kaca Pembesar tool, using | yes (idle/using) | 4 |
| `assets/tools/tool_cutter.png` | 96x96 | Pemotong tool, idle | yes (idle/using) | 4 |
| `assets/tools/tool_cutter_using.png` | 96x96 | Pemotong tool, using | yes (idle/using) | 4 |
| `assets/ui/panel_main.png` | 96x96 | Main UI panel. NinePatchRect, 24px margins. | no | 1 |
| `assets/ui/panel_dark.png` | 96x96 | Modal / overlay panel. NinePatchRect, 24px margins. | no | 1 |
| `assets/ui/panel_slot.png` | 96x96 | Inventory slot background. NinePatchRect, 24px margins. | no | 1 |
| `assets/ui/chip_surface.png` | 64x40 | Evidence chip, free surface info (grey). NinePatchRect, 24px margins. | no | 1 |
| `assets/ui/chip_reveal.png` | 64x40 | Evidence chip, tool reveal (gold). NinePatchRect, 24px margins. | no | 1 |
| `assets/ui/button_normal.png` | 64x64 | Button normal state. NinePatch, 20px margins. | no | 1 |
| `assets/ui/button_hover.png` | 64x64 | Button hover state. NinePatch, 20px margins. | no | 1 |
| `assets/ui/button_pressed.png` | 64x64 | Button pressed state. NinePatch, 20px margins. | no | 1 |
| `assets/ui/button_disabled.png` | 64x64 | Button disabled state. NinePatch, 20px margins. | no | 1 |
| `assets/ui/icon_day.png` | 48x48 | HUD icon (H) | no | 1 |
| `assets/ui/icon_quota.png` | 48x48 | HUD icon (T) | no | 1 |
| `assets/ui/icon_grab.png` | 48x48 | HUD icon (C) | no | 1 |
| `assets/ui/icon_health.png` | 48x48 | HUD icon (L) | no | 1 |
| `assets/ui/icon_book.png` | 48x48 | HUD icon (A) | no | 1 |
| `assets/ui/icon_close.png` | 48x48 | HUD icon (X) | no | 1 |
| `assets/ui/icon_check.png` | 48x48 | HUD icon (V) | no | 1 |
| `assets/ui/icon_cross.png` | 48x48 | HUD icon (X) | no | 1 |
| `assets/ui/icon_pause.png` | 48x48 | HUD icon (II) | no | 1 |
| `assets/ui/meter_bg.png` | 320x32 | Ocean health meter bg. Fill is clipped by width. | no | 1 |
| `assets/ui/meter_fill.png` | 320x32 | Ocean health meter fill. Fill is clipped by width. | no | 1 |
| `assets/ui/pip_full.png` | 16x16 | Tool charge pip (full) | no | 1 |
| `assets/ui/pip_empty.png` | 16x16 | Tool charge pip (empty) | no | 1 |
| `assets/ui/arrow_left.png` | 96x96 | Console arrow button (left) | no | 1 |
| `assets/ui/arrow_right.png` | 96x96 | Console arrow button (right) | no | 1 |
| `assets/ui/joystick_base.png` | 128x128 | Console joystick base | no | 1 |
| `assets/ui/joystick_knob.png` | 72x72 | Console joystick knob, offsets with claw | no | 1 |
| `assets/env/water_bg.png` | 1280x720 | Full-screen water background, layer 0 | no | 1 |
| `assets/env/seabed.png` | 1000x140 | Seabed floor inside the tank SubViewport, z_index -10 | no | 1 |
| `assets/env/tank_frame.png` | 1040x460 | Machine frame around the tank. Centre is transparent. | no | 1 |
| `assets/env/glass_overlay.png` | 1000x420 | Glass reflection and tint, layer 20 | no | 1 |
| `assets/env/machine_console.png` | 1280x220 | Console backing plate under the tank, layer 30 | no | 1 |
| `assets/env/bubble.png` | 24x24 | Bubble, count scales with the VFX slider | no | 1 |
| `assets/env/cutscene_01.png` | 960x540 | Cutscene still 1 (placeholder) | no | 1 |
| `assets/env/cutscene_02.png` | 960x540 | Cutscene still 2 (placeholder) | no | 1 |
| `assets/env/cutscene_03.png` | 960x540 | Cutscene still 3 (placeholder) | no | 1 |
| `assets/env/logo.png` | 640x200 | Title logo | no | 1 |

_78 files. Regenerate placeholders with_ `python3 tools/gen_placeholders.py`.
