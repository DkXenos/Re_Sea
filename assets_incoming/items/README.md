# Trash items — 16 files

One piece of litter, photographed or drawn straight-on against nothing. Search the item name plus **png** or **cutout** - e.g. `plastic bottle png transparent`. The player has to recognise it in a 160px square, so the object should fill most of the frame.

Every file here is **a cut-out with a transparent background**.

## How to use this folder

1. Find a picture for a row below.
2. Save it here with **exactly the filename in the first column**.
3. Any size is fine — `tools/install_incoming.py` resizes to the target for you.
   Match the shape (square vs wide) or it will look squashed.
4. When you have some or all of them, run from the project root:

       python3 tools/install_incoming.py

   It checks every file, resizes it, copies it into `assets/items/`, and
   tells you what is still missing. Files you have not replaced keep their
   current placeholder.

## Watch out

- Nothing else in the picture. One bottle, not a pile of bottles.
- No drop shadow baked in - the game lights these itself.
- Avoid a photo taken at a steep angle; the desk view is straight-on.
- `hotspots_*` files are **not in this list and must not be replaced** - they are generated from data/items/*.tres by tools/gen_hotspot_overlays.gd.

## The files

| Save it as | Size | Background | What it is |
|------------|------|------------|------------|
| `item_banana_peel.png` | 160x160 | cut-out | Trash item `banana_peel` |
| `item_fish_bone.png` | 160x160 | cut-out | Trash item `fish_bone` |
| `item_pet_bottle.png` | 160x160 | cut-out | Trash item `pet_bottle` |
| `item_alu_can.png` | 160x160 | cut-out | Trash item `alu_can` |
| `item_styrofoam_tray.png` | 160x160 | cut-out | Trash item `styrofoam_tray` |
| `item_car_battery.png` | 160x160 | cut-out | Trash item `car_battery` |
| `item_oil_jerrycan.png` | 160x160 | cut-out | Trash item `oil_jerrycan` |
| `item_paint_bottle.png` | 160x160 | cut-out | Trash item `paint_bottle` |
| `item_juice_carton.png` | 160x160 | cut-out | Trash item `juice_carton` |
| `item_eco_tote.png` | 160x160 | cut-out | Trash item `eco_tote` |
| `item_paper_cup.png` | 160x160 | cut-out | Trash item `paper_cup` |
| `item_spray_can.png` | 160x160 | cut-out | Trash item `spray_can` |
| `item_glass_jar.png` | 160x160 | cut-out | Trash item `glass_jar` |
| `item_fishing_net.png` | 160x160 | cut-out | Trash item `fishing_net` |
| `box_closed.png` | 160x160 | cut-out | Mystery box, sealed. State `closed`. |
| `box_opened.png` | 160x160 | cut-out | Mystery box, lid open. State `opened`. |
