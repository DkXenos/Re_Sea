# Interface chrome — 65 files

Buttons, panels, icons, sliders, scrollbars. **This is the folder where random photos go wrong** - read the stretching note below. The three `blueprint_bg_*` files are the odd ones out: full-frame 960x540 pictures, not chrome.

**Check the Background column per file** - this folder holds both cut-outs and solid full-frame pictures.

## How to use this folder

1. Find a picture for a row below.
2. Save it here with **exactly the filename in the first column**.
3. Any size is fine — `tools/install_incoming.py` resizes to the target for you.
   Match the shape (square vs wide) or it will look squashed.
4. When you have some or all of them, run from the project root:

       python3 tools/install_incoming.py

   It checks every file, resizes it, copies it into `assets/ui/`, and
   tells you what is still missing. Files you have not replaced keep their
   current placeholder.

## Watch out

- Most of these get STRETCHED from a small square to whatever the screen needs. A photo will smear. Look for a plain frame, a rounded rectangle, a wood/metal panel texture - something with no important detail in the middle.
- Icons (`icon_*.png`) are small and must read at 48px. A flat symbol beats a photograph every time.
- State pairs (`_normal`/`_hover`/`_pressed`/`_disabled`, `_locked`/`_done`, `toggle_off`/`toggle_on`) must be visibly different from each other.

## The files

| Save it as | Size | Background | What it is |
|------------|------|------------|------------|
| `panel_main.png` | 96x96 | **solid** | Main UI panel. NinePatchRect, 24px margins. |
| `panel_dark.png` | 96x96 | **solid** | Modal / overlay panel: the rulebook, the calibration puzzle, and the blueprint component popup. NinePatchRect, 24px margins. |
| `panel_slot.png` | 96x96 | **solid** | Inventory slot background. NinePatchRect, 24px margins. |
| `panel_slot_selected.png` | 96x96 | **solid** | Inventory slot, selected. A different PNG rather than a tint. NinePatchRect, 24px margins. |
| `chip_surface.png` | 64x40 | cut-out | Evidence chip, free surface info (grey). NinePatchRect, 24px margins. |
| `chip_reveal.png` | 64x40 | cut-out | Evidence chip, tool reveal (gold). NinePatchRect, 24px margins. |
| `button_normal.png` | 64x64 | **solid** | Button normal state. NinePatch, 20px margins. |
| `button_hover.png` | 64x64 | **solid** | Button hover state. NinePatch, 20px margins. |
| `button_pressed.png` | 64x64 | **solid** | Button pressed state. NinePatch, 20px margins. |
| `button_disabled.png` | 64x64 | **solid** | Button disabled state. NinePatch, 20px margins. |
| `icon_day.png` | 48x48 | cut-out | HUD icon (H) |
| `icon_quota.png` | 48x48 | cut-out | HUD icon (T) |
| `icon_grab.png` | 48x48 | cut-out | HUD icon (C) |
| `icon_health.png` | 48x48 | cut-out | HUD icon (L) |
| `icon_book.png` | 48x48 | cut-out | HUD icon (A) |
| `icon_close.png` | 48x48 | cut-out | HUD icon (X) |
| `icon_check.png` | 48x48 | cut-out | HUD icon (V) |
| `icon_cross.png` | 48x48 | cut-out | HUD icon (X) |
| `icon_pause.png` | 48x48 | cut-out | HUD icon (II) |
| `chip_match.png` | 64x40 | cut-out | Evidence chip that satisfies an active rule (green). NinePatchRect, 24px margins. |
| `minimap_bg.png` | 960x28 | **solid** | Minimap strip background. Stretched to width. |
| `minimap_view.png` | 64x28 | cut-out | Minimap window showing the visible slice. Stretched. |
| `minimap_item.png` | 10x10 | cut-out | Minimap dot for one item on the seabed |
| `minimap_claw.png` | 12x20 | cut-out | Minimap marker for the claw |
| `meter_bg.png` | 320x32 | cut-out | Ocean health meter bg. Fill is clipped by width. |
| `meter_fill.png` | 320x32 | cut-out | Ocean health meter fill. Fill is clipped by width. |
| `arrow_left.png` | 96x96 | cut-out | Console arrow button (left) |
| `arrow_right.png` | 96x96 | cut-out | Console arrow button (right) |
| `joystick_base.png` | 128x128 | cut-out | Console joystick base |
| `joystick_knob.png` | 72x72 | cut-out | Console joystick knob, offsets with claw |
| `slider_track.png` | 64x16 | cut-out | Volume slider track. NinePatch, 8px margins, stretched to width. |
| `slider_fill.png` | 64x16 | cut-out | Volume slider fill, the part left of the knob. NinePatch, 8px margins. |
| `slider_grabber.png` | 32x32 | cut-out | Volume slider knob. |
| `slider_grabber_hover.png` | 32x32 | cut-out | Volume slider knob, hovered/held. |
| `toggle_off.png` | 64x32 | cut-out | Settings toggle, off state. Own drawing, not a tint of the on state. |
| `toggle_on.png` | 64x32 | cut-out | Settings toggle, on state. |
| `scrollbar_track.png` | 16x64 | cut-out | Scrollbar track. NinePatch, 8px margins, stretched to length. |
| `scrollbar_grabber.png` | 16x64 | cut-out | Scrollbar grabber. NinePatch, 8px margins, stretched to length. |
| `scrollbar_grabber_hover.png` | 16x64 | cut-out | Scrollbar grabber, hovered/dragged. |
| `textfield_normal.png` | 64x40 | cut-out | Text field. NinePatch, 12px margins, stretched. |
| `textfield_focus.png` | 64x40 | cut-out | Text field, focused. NinePatch, 12px margins. |
| `icon_pause_pressed.png` | 48x48 | cut-out | Pause button, pressed state. |
| `arrow_left_pressed.png` | 96x96 | cut-out | Console arrow button (left), pressed state. |
| `arrow_right_pressed.png` | 96x96 | cut-out | Console arrow button (right), pressed state. |
| `blueprint_bg_cleaner_drone.png` | 960x540 | **solid** | Blueprint schematic sheet for `cleaner_drone`. Parts sit on top from normalized coords in the .tres. |
| `blueprint_bg_penyaring_mikroplastik.png` | 960x540 | **solid** | Blueprint schematic sheet for `penyaring_mikroplastik`. Parts sit on top from normalized coords in the .tres. |
| `blueprint_bg_penetral_b3.png` | 960x540 | **solid** | Blueprint schematic sheet for `penetral_b3`. Parts sit on top from normalized coords in the .tres. |
| `comp_drone_body_done.png` | 128x128 | cut-out | Blueprint component `drone_body`, done. |
| `comp_drone_body_locked.png` | 128x128 | cut-out | Blueprint component `drone_body`, locked. |
| `comp_bio_core_done.png` | 128x128 | cut-out | Blueprint component `bio_core`, done. |
| `comp_bio_core_locked.png` | 128x128 | cut-out | Blueprint component `bio_core`, locked. |
| `comp_intake_fin_done.png` | 128x128 | cut-out | Blueprint component `intake_fin`, done. |
| `comp_intake_fin_locked.png` | 128x128 | cut-out | Blueprint component `intake_fin`, locked. |
| `comp_filter_mesh_done.png` | 128x128 | cut-out | Blueprint component `filter_mesh`, done. |
| `comp_filter_mesh_locked.png` | 128x128 | cut-out | Blueprint component `filter_mesh`, locked. |
| `comp_pump_housing_done.png` | 128x128 | cut-out | Blueprint component `pump_housing`, done. |
| `comp_pump_housing_locked.png` | 128x128 | cut-out | Blueprint component `pump_housing`, locked. |
| `comp_collection_tank_done.png` | 128x128 | cut-out | Blueprint component `collection_tank`, done. |
| `comp_collection_tank_locked.png` | 128x128 | cut-out | Blueprint component `collection_tank`, locked. |
| `comp_sealed_chamber_done.png` | 128x128 | cut-out | Blueprint component `sealed_chamber`, done. |
| `comp_sealed_chamber_locked.png` | 128x128 | cut-out | Blueprint component `sealed_chamber`, locked. |
| `comp_neutralizer_cell_done.png` | 128x128 | cut-out | Blueprint component `neutralizer_cell`, done. |
| `comp_neutralizer_cell_locked.png` | 128x128 | cut-out | Blueprint component `neutralizer_cell`, locked. |
| `comp_safety_valve_done.png` | 128x128 | cut-out | Blueprint component `safety_valve`, done. |
| `comp_safety_valve_locked.png` | 128x128 | cut-out | Blueprint component `safety_valve`, locked. |
