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
7. Everything is displayed at scale 1 except these three (four now, with the
   box):

   | What | Authored | Displayed | Constant |
   |------|----------|-----------|----------|
   | Item in the inspect panel | 160×160 | 288×288 | `InspectPanel.BASE_SCALE` = 1.8 |
   | Tool icon in the rack | 96×96 | 60×60 | `InspectPanel.TOOL_ICON_SCALE` = 0.62 |
   | Bin on the desk | 200×240 | 144×173 | `BinRow.BIN_DISPLAY_SCALE` = 0.72 |
   | Box on its inventory card | 160×160 | 64×64 | `InventoryPanel.BOX_CARD_SCALE` = 0.4 |

   Everywhere else the size in the table is the size on screen.

## UI chrome — buttons, panels, sliders, scrollbars, text fields

These are the parts Godot would otherwise draw itself. They are all PNGs in
`assets/ui/`, wired up in one place: `assets/ui/ui_theme.tres`, which
`project.godot` applies to the whole game. **Replace the PNG and every screen
follows — you never touch a scene.**

| Part | Files |
|------|-------|
| Button | `button_normal` / `button_hover` / `button_pressed` / `button_disabled` |
| Panels & boxes | `panel_main`, `panel_dark`, `panel_slot`, `panel_slot_selected` |
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

Items have 2-3 invisible hotspots (a seam, a label corner, a stain) and a tool
only reveals its property if you click the right one. Positions are in
`data/items/*.tres`.

The rings are NOT part of the item art. They're a separate overlay,
`assets/items/hotspots_<id>.png`, generated from the .tres by
`tools/gen_hotspot_overlays.gd`. Don't edit those by hand - move the coords in
the .tres and re-run it.

In the final art the hotspot should be an actual drawn feature at the same
coords: the stain where the rinse ring is, the printed code where the magnifier
ring is, the seam where the cutter ring is. Then the overlay is just an
accessibility toggle instead of how you solve it.

Ring colours come from `ToolData.color` - rinse blue, swab pink, magnifier
yellow, cutter red.

## no AI art

Nothing here, image or audio, is AI generated and nothing should be. The
current files come out of `tools/gen_placeholders.py` and `gen_sounds.py`.

---

## animations

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
| `data/frames/item_paper_cup_frames.tres` | `idle` | `assets/items/item_paper_cup.png` | 2 |
| `data/frames/item_paper_cup_frames.tres` | `wobble` | `assets/items/item_paper_cup.png` | 4 |
| `data/frames/item_paper_cup_frames.tres` | `sinking` | `assets/items/item_paper_cup.png` | 6 |
| `data/frames/item_baju_organik_frames.tres` | `idle` | `assets/items/item_baju_organik.png` | 2 |
| `data/frames/item_baju_organik_frames.tres` | `wobble` | `assets/items/item_baju_organik.png` | 4 |
| `data/frames/item_baju_organik_frames.tres` | `sinking` | `assets/items/item_baju_organik.png` | 6 |
| `data/frames/item_baju_daur_ulang_frames.tres` | `idle` | `assets/items/item_baju_daur_ulang.png` | 2 |
| `data/frames/item_baju_daur_ulang_frames.tres` | `wobble` | `assets/items/item_baju_daur_ulang.png` | 4 |
| `data/frames/item_baju_daur_ulang_frames.tres` | `sinking` | `assets/items/item_baju_daur_ulang.png` | 6 |
| `data/frames/item_baju_b3_frames.tres` | `idle` | `assets/items/item_baju_b3.png` | 2 |
| `data/frames/item_baju_b3_frames.tres` | `wobble` | `assets/items/item_baju_b3.png` | 4 |
| `data/frames/item_baju_b3_frames.tres` | `sinking` | `assets/items/item_baju_b3.png` | 6 |
| `data/frames/item_gelas_kertas_bersih_frames.tres` | `idle` | `assets/items/item_gelas_kertas_bersih.png` | 2 |
| `data/frames/item_gelas_kertas_bersih_frames.tres` | `wobble` | `assets/items/item_gelas_kertas_bersih.png` | 4 |
| `data/frames/item_gelas_kertas_bersih_frames.tres` | `sinking` | `assets/items/item_gelas_kertas_bersih.png` | 6 |
| `data/frames/item_tisu_bekas_frames.tres` | `idle` | `assets/items/item_tisu_bekas.png` | 2 |
| `data/frames/item_tisu_bekas_frames.tres` | `wobble` | `assets/items/item_tisu_bekas.png` | 4 |
| `data/frames/item_tisu_bekas_frames.tres` | `sinking` | `assets/items/item_tisu_bekas.png` | 6 |
| `data/frames/item_tisu_b3_frames.tres` | `idle` | `assets/items/item_tisu_b3.png` | 2 |
| `data/frames/item_tisu_b3_frames.tres` | `wobble` | `assets/items/item_tisu_b3.png` | 4 |
| `data/frames/item_tisu_b3_frames.tres` | `sinking` | `assets/items/item_tisu_b3.png` | 6 |
| `data/frames/item_apel_frames.tres` | `idle` | `assets/items/item_apel.png` | 2 |
| `data/frames/item_apel_frames.tres` | `wobble` | `assets/items/item_apel.png` | 4 |
| `data/frames/item_apel_frames.tres` | `sinking` | `assets/items/item_apel.png` | 6 |
| `data/frames/item_botol_kaca_frames.tres` | `idle` | `assets/items/item_botol_kaca.png` | 2 |
| `data/frames/item_botol_kaca_frames.tres` | `wobble` | `assets/items/item_botol_kaca.png` | 4 |
| `data/frames/item_botol_kaca_frames.tres` | `sinking` | `assets/items/item_botol_kaca.png` | 6 |
| `data/frames/item_cangkang_telur_frames.tres` | `idle` | `assets/items/item_cangkang_telur.png` | 2 |
| `data/frames/item_cangkang_telur_frames.tres` | `wobble` | `assets/items/item_cangkang_telur.png` | 4 |
| `data/frames/item_cangkang_telur_frames.tres` | `sinking` | `assets/items/item_cangkang_telur.png` | 6 |
| `data/frames/item_daun_frames.tres` | `idle` | `assets/items/item_daun.png` | 2 |
| `data/frames/item_daun_frames.tres` | `wobble` | `assets/items/item_daun.png` | 4 |
| `data/frames/item_daun_frames.tres` | `sinking` | `assets/items/item_daun.png` | 6 |
| `data/frames/item_kantong_plastik_frames.tres` | `idle` | `assets/items/item_kantong_plastik.png` | 2 |
| `data/frames/item_kantong_plastik_frames.tres` | `wobble` | `assets/items/item_kantong_plastik.png` | 4 |
| `data/frames/item_kantong_plastik_frames.tres` | `sinking` | `assets/items/item_kantong_plastik.png` | 6 |
| `data/frames/item_koran_frames.tres` | `idle` | `assets/items/item_koran.png` | 2 |
| `data/frames/item_koran_frames.tres` | `wobble` | `assets/items/item_koran.png` | 4 |
| `data/frames/item_koran_frames.tres` | `sinking` | `assets/items/item_koran.png` | 6 |
| `data/frames/item_pizza_frames.tres` | `idle` | `assets/items/item_pizza.png` | 2 |
| `data/frames/item_pizza_frames.tres` | `wobble` | `assets/items/item_pizza.png` | 4 |
| `data/frames/item_pizza_frames.tres` | `sinking` | `assets/items/item_pizza.png` | 6 |
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
| `data/frames/box.tres` | `closed` | `assets/items/box_closed.png` | 2 |
| `data/frames/box.tres` | `opened` | `assets/items/box_opened.png` | 2 |
| `data/frames/box.tres` | `idle` | `assets/items/box_closed.png` | 2 |
| `data/frames/box.tres` | `wobble` | `assets/items/box_closed.png` | 4 |
| `data/frames/box.tres` | `sinking` | `assets/items/box_closed.png` | 6 |
| `data/frames/coral_healthy_frames.tres` | `idle` | `assets/env/coral_healthy.png` | 6 |
| `data/frames/coral_dead_frames.tres` | `idle` | `assets/env/coral_dead.png` | 6 |
| `data/frames/debris_overlay_frames.tres` | `idle` | `assets/env/debris_overlay.png` | 6 |

## every PNG

`Animated` = which SpriteFrames animations this PNG is the placeholder frame
for, and the frame count the real thing should have. `static` = shown as-is.

| Path | Size | Animated | What it is |
|------|------|----------|-----------|
| `assets/items/item_banana_peel.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `banana_peel` |
| `assets/items/item_paper_cup.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `paper_cup` |
| `assets/items/item_baju_organik.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `baju_organik` |
| `assets/items/item_baju_daur_ulang.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `baju_daur_ulang` |
| `assets/items/item_baju_b3.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `baju_b3` |
| `assets/items/item_gelas_kertas_bersih.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `gelas_kertas_bersih` |
| `assets/items/item_tisu_bekas.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `tisu_bekas` |
| `assets/items/item_tisu_b3.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `tisu_b3` |
| `assets/items/item_apel.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `apel` |
| `assets/items/item_botol_kaca.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `botol_kaca` |
| `assets/items/item_cangkang_telur.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `cangkang_telur` |
| `assets/items/item_daun.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `daun` |
| `assets/items/item_kantong_plastik.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `kantong_plastik` |
| `assets/items/item_koran.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `koran` |
| `assets/items/item_pizza.png` | 160x160 | `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Trash item `pizza` |
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
| `assets/ui/panel_dark.png` | 96x96 | static | Modal / overlay panel: the rulebook, the calibration puzzle, and the blueprint component popup. NinePatchRect, 24px margins. |
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
| `assets/ui/slider_track.png` | 64x16 | static | Volume slider track. NinePatch, 8px margins, stretched to width. |
| `assets/ui/slider_fill.png` | 64x16 | static | Volume slider fill, the part left of the knob. NinePatch, 8px margins. |
| `assets/ui/slider_grabber.png` | 32x32 | static | Volume slider knob. |
| `assets/ui/slider_grabber_hover.png` | 32x32 | static | Volume slider knob, hovered/held. |
| `assets/ui/toggle_off.png` | 64x32 | static | Settings toggle, off state. Own drawing, not a tint of the on state. |
| `assets/ui/toggle_on.png` | 64x32 | static | Settings toggle, on state. |
| `assets/ui/scrollbar_track.png` | 16x64 | static | Scrollbar track. NinePatch, 8px margins, stretched to length. |
| `assets/ui/scrollbar_grabber.png` | 16x64 | static | Scrollbar grabber. NinePatch, 8px margins, stretched to length. |
| `assets/ui/scrollbar_grabber_hover.png` | 16x64 | static | Scrollbar grabber, hovered/dragged. |
| `assets/ui/textfield_normal.png` | 64x40 | static | Text field. NinePatch, 12px margins, stretched. |
| `assets/ui/textfield_focus.png` | 64x40 | static | Text field, focused. NinePatch, 12px margins. |
| `assets/ui/icon_pause_pressed.png` | 48x48 | static | Pause button, pressed state. |
| `assets/ui/arrow_left_pressed.png` | 96x96 | static | Console arrow button (left), pressed state. |
| `assets/ui/arrow_right_pressed.png` | 96x96 | static | Console arrow button (right), pressed state. |
| `assets/env/water_bg.png` | 1280x720 | static | Deep-water backdrop. The furthest parallax layer inside the tank window - scaled from its own size to cover the window, never stretched. |
| `assets/env/hull_wall.png` | 128x128 | static | Submarine hull, tiled at native size over everything outside the window. Must tile seamlessly. |
| `assets/env/coral_dead.png` | 174x140 | static | Far parallax scenery, planted along the back of the seabed. Cut-out; drawn at this size, so this row decides how big it reads. |
| `assets/env/coral_healthy.png` | 157x190 | static | Mid parallax scenery, nearer than the dead coral. Cut-out, drawn at this size. |
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
| `assets/items/box_closed.png` | 160x160 | `closed` 2 fr, `idle` 2 fr, `wobble` 4 fr, `sinking` 6 fr | Mystery box, sealed. State `closed`. |
| `assets/items/box_opened.png` | 160x160 | `opened` 2 fr | Mystery box, lid open. State `opened`. |
| `assets/ui/blueprint_bg_cleaner_drone.png` | 960x540 | static | Blueprint schematic sheet for `cleaner_drone`. Parts sit on top from normalized coords in the .tres. |
| `assets/ui/blueprint_bg_penyaring_mikroplastik.png` | 960x540 | static | Blueprint schematic sheet for `penyaring_mikroplastik`. Parts sit on top from normalized coords in the .tres. |
| `assets/ui/blueprint_bg_penetral_b3.png` | 960x540 | static | Blueprint schematic sheet for `penetral_b3`. Parts sit on top from normalized coords in the .tres. |
| `assets/ui/comp_drone_body_done.png` | 128x128 | static | Blueprint component `drone_body`, done. |
| `assets/ui/comp_drone_body_locked.png` | 128x128 | static | Blueprint component `drone_body`, locked. |
| `assets/ui/comp_bio_core_done.png` | 128x128 | static | Blueprint component `bio_core`, done. |
| `assets/ui/comp_bio_core_locked.png` | 128x128 | static | Blueprint component `bio_core`, locked. |
| `assets/ui/comp_intake_fin_done.png` | 128x128 | static | Blueprint component `intake_fin`, done. |
| `assets/ui/comp_intake_fin_locked.png` | 128x128 | static | Blueprint component `intake_fin`, locked. |
| `assets/ui/comp_filter_mesh_done.png` | 128x128 | static | Blueprint component `filter_mesh`, done. |
| `assets/ui/comp_filter_mesh_locked.png` | 128x128 | static | Blueprint component `filter_mesh`, locked. |
| `assets/ui/comp_pump_housing_done.png` | 128x128 | static | Blueprint component `pump_housing`, done. |
| `assets/ui/comp_pump_housing_locked.png` | 128x128 | static | Blueprint component `pump_housing`, locked. |
| `assets/ui/comp_collection_tank_done.png` | 128x128 | static | Blueprint component `collection_tank`, done. |
| `assets/ui/comp_collection_tank_locked.png` | 128x128 | static | Blueprint component `collection_tank`, locked. |
| `assets/ui/comp_sealed_chamber_done.png` | 128x128 | static | Blueprint component `sealed_chamber`, done. |
| `assets/ui/comp_sealed_chamber_locked.png` | 128x128 | static | Blueprint component `sealed_chamber`, locked. |
| `assets/ui/comp_neutralizer_cell_done.png` | 128x128 | static | Blueprint component `neutralizer_cell`, done. |
| `assets/ui/comp_neutralizer_cell_locked.png` | 128x128 | static | Blueprint component `neutralizer_cell`, locked. |
| `assets/ui/comp_safety_valve_done.png` | 128x128 | static | Blueprint component `safety_valve`, done. |
| `assets/ui/comp_safety_valve_locked.png` | 128x128 | static | Blueprint component `safety_valve`, locked. |
| `assets/items/hotspots_banana_peel.png` | 160x160 | static | Hotspot rings for `banana_peel`. **Generated from `data/items/banana_peel.tres`**, don't edit by hand. |
| `assets/items/hotspots_paper_cup.png` | 160x160 | static | Hotspot rings for `paper_cup`. **Generated from `data/items/paper_cup.tres`**, don't edit by hand. |
| `assets/items/hotspots_baju_organik.png` | 160x160 | static | Hotspot rings for `baju_organik`. **Generated from `data/items/baju_organik.tres`**, don't edit by hand. |
| `assets/items/hotspots_baju_daur_ulang.png` | 160x160 | static | Hotspot rings for `baju_daur_ulang`. **Generated from `data/items/baju_daur_ulang.tres`**, don't edit by hand. |
| `assets/items/hotspots_baju_b3.png` | 160x160 | static | Hotspot rings for `baju_b3`. **Generated from `data/items/baju_b3.tres`**, don't edit by hand. |
| `assets/items/hotspots_gelas_kertas_bersih.png` | 160x160 | static | Hotspot rings for `gelas_kertas_bersih`. **Generated from `data/items/gelas_kertas_bersih.tres`**, don't edit by hand. |
| `assets/items/hotspots_tisu_bekas.png` | 160x160 | static | Hotspot rings for `tisu_bekas`. **Generated from `data/items/tisu_bekas.tres`**, don't edit by hand. |
| `assets/items/hotspots_tisu_b3.png` | 160x160 | static | Hotspot rings for `tisu_b3`. **Generated from `data/items/tisu_b3.tres`**, don't edit by hand. |
| `assets/items/hotspots_apel.png` | 160x160 | static | Hotspot rings for `apel`. **Generated from `data/items/apel.tres`**, don't edit by hand. |
| `assets/items/hotspots_botol_kaca.png` | 160x160 | static | Hotspot rings for `botol_kaca`. **Generated from `data/items/botol_kaca.tres`**, don't edit by hand. |
| `assets/items/hotspots_cangkang_telur.png` | 160x160 | static | Hotspot rings for `cangkang_telur`. **Generated from `data/items/cangkang_telur.tres`**, don't edit by hand. |
| `assets/items/hotspots_daun.png` | 160x160 | static | Hotspot rings for `daun`. **Generated from `data/items/daun.tres`**, don't edit by hand. |
| `assets/items/hotspots_kantong_plastik.png` | 160x160 | static | Hotspot rings for `kantong_plastik`. **Generated from `data/items/kantong_plastik.tres`**, don't edit by hand. |
| `assets/items/hotspots_koran.png` | 160x160 | static | Hotspot rings for `koran`. **Generated from `data/items/koran.tres`**, don't edit by hand. |
| `assets/items/hotspots_pizza.png` | 160x160 | static | Hotspot rings for `pizza`. **Generated from `data/items/pizza.tres`**, don't edit by hand. |

## The font — the one thing that is not a PNG yet

Every visual in the table above is a file you can replace. Text is not: the game
currently renders with **Godot's built-in font**, because no typeface has been
chosen. That is the only pixel on screen that is not yours yet.

To claim it, drop a `.ttf` or `.otf` at `assets/ui/fonts/ui_font.ttf`, then add
one line to `assets/ui/ui_theme.tres` under `[resource]`:

    default_font = ExtResource("<the font's id>")

Sizes stay where they are (`default_font_size = 18`, buttons 20) so nothing
re-lays out. Pick something that reads at 18px — this is a text-heavy game.

Regenerate placeholders with `python3 tools/gen_placeholders.py`. Hotspot
overlays are separate, see above.
