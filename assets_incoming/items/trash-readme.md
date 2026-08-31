# dropping trash art in

## naming

One flat folder. No subfolders. One file per item variation:

    <item>-<kategori>.png

`<kategori>` is the bin the item belongs in, and must be exactly one of:

| slug         | bin in game       | ItemData.Category |
|--------------|-------------------|-------------------|
| `organik`    | ORGANIK           | 0                 |
| `daur-ulang` | DAUR ULANG        | 1                 |
| `b3`         | B3 / BERBAHAYA    | 2                 |
| `residu`     | RESIDU            | 3                 |

An item with variations gets one file per variation, all sharing the `<item>`
stem — that is what makes them read as the same object in different states:

    baju-organik.png        serat alami
    baju-daur-ulang.png     poliester
    baju-b3.png             kena pestisida

An item with only one variation is just the one file, e.g. `daun-organik.png`.
When a second state is drawn later, add it alongside; nothing has to be renamed.

Lowercase, hyphens only, no spaces, `.png` not `.PNG`.

## the art itself

- 2048x2048, RGBA, cut out on transparency. Installed to 160x160, so it is a
  1:1 downscale with no distortion — keep the subject roughly centred and
  don't rely on detail finer than ~13 px at 2048 (1 px at final size).
- Draw the state you mean. The category is decided by what is visibly on the
  object: a clean cup is `daur-ulang`, the same cup with coffee in it is
  `residu`. If nothing is drawn on it, it is treated as clean.

## after you drop files in

Art alone does not reach the game. Ask for these, or run them:

1. install the PNGs to `assets/items/item_<id>.png` at 160x160
2. `data/items/<id>.tres` — the item, its category and its surface properties
3. `data/frames/item_<id>_frames.tres` — idle / wobble / sinking
4. rows in `assets/ASSETS.md` (three tables reference every item PNG)
5. an entry in `data/days.json`, then `python3 tools/gen_days.py`
6. `godot --headless --import`, then `tools/gen_hotspot_overlays.gd` **twice**
   with another `--import` in between
7. `./tools/smoke/run_all.sh`

An item that is not listed in `data/days.json` loads fine but never spawns.
