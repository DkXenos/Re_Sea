# Trash items — 17 files

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

## The files

| Save it as | Size | Background | What it is |
|------------|------|------------|------------|
| `item_banana_peel.png` | 160x160 | cut-out | Trash item `banana_peel` |
| `item_paper_cup.png` | 160x160 | cut-out | Trash item `paper_cup` |
| `item_baju_organik.png` | 160x160 | cut-out | Trash item `baju_organik` |
| `item_baju_daur_ulang.png` | 160x160 | cut-out | Trash item `baju_daur_ulang` |
| `item_baju_b3.png` | 160x160 | cut-out | Trash item `baju_b3` |
| `item_gelas_kertas_bersih.png` | 160x160 | cut-out | Trash item `gelas_kertas_bersih` |
| `item_tisu_bekas.png` | 160x160 | cut-out | Trash item `tisu_bekas` |
| `item_tisu_b3.png` | 160x160 | cut-out | Trash item `tisu_b3` |
| `item_apel.png` | 160x160 | cut-out | Trash item `apel` |
| `item_botol_kaca.png` | 160x160 | cut-out | Trash item `botol_kaca` |
| `item_cangkang_telur.png` | 160x160 | cut-out | Trash item `cangkang_telur` |
| `item_daun.png` | 160x160 | cut-out | Trash item `daun` |
| `item_kantong_plastik.png` | 160x160 | cut-out | Trash item `kantong_plastik` |
| `item_koran.png` | 160x160 | cut-out | Trash item `koran` |
| `item_pizza.png` | 160x160 | cut-out | Trash item `pizza` |
| `box_closed.png` | 160x160 | cut-out | Mystery box, sealed. State `closed`. |
| `box_opened.png` | 160x160 | cut-out | Mystery box, lid open. State `opened`. |
