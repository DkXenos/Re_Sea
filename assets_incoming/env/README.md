# Backgrounds and scenery — 17 files

**Two different jobs in one folder, so check the Background column on every row.** Five of these are full-frame scenes (`water_bg`, `machine_console`, the three `cutscene_*`) - search `underwater background`, `ocean floor`. The rest are cut-outs that sit on top of the water: coral, bubbles, the seabed strips, the logo, the tank frame.

**Check the Background column per file** - this folder holds both cut-outs and solid full-frame pictures.

## How to use this folder

1. Find a picture for a row below.
2. Save it here with **exactly the filename in the first column**.
3. Any size is fine — `tools/install_incoming.py` resizes to the target for you.
   Match the shape (square vs wide) or it will look squashed.
4. When you have some or all of them, run from the project root:

       python3 tools/install_incoming.py

   It checks every file, resizes it, copies it into `assets/env/`, and
   tells you what is still missing. Files you have not replaced keep their
   current placeholder.

## Watch out

- Getting this backwards is the easiest mistake here. An opaque coral gives you a rectangle of sea floating in the water.
- Wide ones get stretched horizontally, so avoid a strong subject in the middle that would smear.
- Keep them dim. Everything else is drawn on top and has to stay readable against them.

## The files

| Save it as | Size | Background | What it is |
|------------|------|------------|------------|
| `water_bg.png` | 1280x720 | **solid** | Full-screen water background, layer 0 |
| `seabed.png` | 1000x140 | cut-out | Seabed floor inside the tank SubViewport, z_index -10 |
| `tank_frame.png` | 1040x460 | cut-out | Machine frame around the tank. Centre is transparent. |
| `glass_overlay.png` | 1000x420 | cut-out | Glass reflection and tint, layer 20 |
| `machine_console.png` | 1280x220 | **solid** | Console backing plate under the tank, layer 30 |
| `bubble.png` | 24x24 | cut-out | Bubble, count scales with the VFX slider |
| `cutscene_01.png` | 960x540 | **solid** | Cutscene still 1 (placeholder) |
| `cutscene_02.png` | 960x540 | **solid** | Cutscene still 2 (placeholder) |
| `cutscene_03.png` | 960x540 | **solid** | Cutscene still 3 (placeholder) |
| `logo.png` | 640x200 | cut-out | Title logo |
| `seabed_tier_0.png` | 1000x140 | cut-out | Seabed backdrop for ocean tier 0. Tiled across the seabed width. |
| `seabed_tier_1.png` | 1000x140 | cut-out | Seabed backdrop for ocean tier 1. Tiled across the seabed width. |
| `seabed_tier_2.png` | 1000x140 | cut-out | Seabed backdrop for ocean tier 2. Tiled across the seabed width. |
| `seabed_tier_3.png` | 1000x140 | cut-out | Seabed backdrop for ocean tier 3. Tiled across the seabed width. |
| `coral_healthy.png` | 120x140 | cut-out | Coral overlay, in colour. Sways in place; count is per ocean tier. |
| `coral_dead.png` | 120x140 | cut-out | Coral overlay, bleached. Sways in place; count is per ocean tier. |
| `debris_overlay.png` | 96x96 | cut-out | Debris clutter on the seabed. Count falls as the ocean recovers. |
