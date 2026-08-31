#!/usr/bin/env python3
"""Builds assets_incoming/ - the drop-in folder for sourced replacement art.

Reads the manifest in assets/ASSETS.md (the same table the game is built from)
and writes one folder per asset group, each with a README naming every file that
belongs in it, its exact pixel size, and what kind of picture fits. Nothing here
touches assets/ - dropping a file in assets_incoming/ does nothing until
tools/install_incoming.py copies it across.

    python3 tools/make_shopping_list.py
"""
import os
import re

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets_incoming")

# What each folder needs, in the terms you'd actually type into a search box.
# "cutout" means the subject must sit on a transparent background.
GROUPS = {
    "items": dict(
        title="Trash items",
        brief="One piece of litter, photographed or drawn straight-on against "
              "nothing. Search the item name plus **png** or **cutout** - e.g. "
              "`plastic bottle png transparent`. The player has to recognise it "
              "in a 160px square, so the object should fill most of the frame.",
        gotchas=["Nothing else in the picture. One bottle, not a pile of bottles.",
                 "No drop shadow baked in - the game lights these itself.",
                 "Avoid a photo taken at a steep angle; the desk view is straight-on."]),
    "bins": dict(
        title="Sorting bins",
        brief="A wheelie bin / waste container, straight-on, lid closed. Four "
              "colours, and each needs three extra states (see the file list).",
        gotchas=["The four bins must read as four different colours at a glance - "
                 "that is the whole game mechanic.",
                 "`_highlight`, `_accept` and `_reject` are separate pictures, not "
                 "the same bin recoloured. A glow, a green tick, a red cross - "
                 "whatever reads fast."]),
    "tools": dict(
        title="Inspection tools",
        brief="A hand tool on transparent background: rinse bottle, cotton swab, "
              "magnifying glass, cutter. Each has a locked and unlocked version.",
        gotchas=["`_locked` should read as unavailable - greyed, chained, dimmed.",
                 "These are shown small (60px in the rack), so pick a bold silhouette."]),
    "claw": dict(
        title="The claw",
        brief="An arcade grabber claw, seen from the front. Four states: open, "
              "closing, closed, carrying - plus the cable.",
        gotchas=["All four should be recognisably the SAME claw, or it will look "
                 "like it teleports between frames. Best sourced as one image you "
                 "crop/rotate four ways.",
                 "`claw_cable.png` is a vertical cable that gets stretched - a flat "
                 "rope or chain, no perspective."]),
    "fish": dict(
        title="Background fish",
        brief="A side-on fish silhouette, three sizes. Decoration only - it "
              "swims past behind everything.",
        gotchas=["Side profile, facing left or right, not head-on.",
                 "Keep it simple and darker than the water; these sit far back."]),
    "env": dict(
        title="Backgrounds and scenery",
        brief="**Two different jobs in one folder, so check the Background "
              "column on every row.** Five of these are full-frame scenes "
              "(`water_bg`, `machine_console`, the three `cutscene_*`) - search "
              "`underwater background`, `ocean floor`. The rest are cut-outs "
              "that sit on top of the water: coral, bubbles, the seabed strips, "
              "the logo, the tank frame.",
        gotchas=["Getting this backwards is the easiest mistake here. An opaque "
                 "coral gives you a rectangle of sea floating in the water.",
                 "Wide ones get stretched horizontally, so avoid a strong subject "
                 "in the middle that would smear.",
                 "Keep them dim. Everything else is drawn on top and has to stay "
                 "readable against them."]),
    "ui": dict(
        title="Interface chrome",
        brief="Buttons, panels, icons, sliders, scrollbars. **This is the folder "
              "where random photos go wrong** - read the stretching note below. "
              "The three `blueprint_bg_*` files are the odd ones out: full-frame "
              "960x540 pictures, not chrome.",
        gotchas=["Most of these get STRETCHED from a small square to whatever the "
                 "screen needs. A photo will smear. Look for a plain frame, a "
                 "rounded rectangle, a wood/metal panel texture - something with "
                 "no important detail in the middle.",
                 "Icons (`icon_*.png`) are small and must read at 48px. A flat "
                 "symbol beats a photograph every time.",
                 "State pairs (`_normal`/`_hover`/`_pressed`/`_disabled`, "
                 "`_locked`/`_done`, `toggle_off`/`toggle_on`) must be visibly "
                 "different from each other."]),
}

# Files the designers must NOT touch, and why. Nothing is frozen right now -
# the hotspot overlays were, and they are gone.
FROZEN = {}

NINEPATCH = re.compile(r"NinePatch|(\d+)px margins")


def is_cutout(group, name):
    """Whether this slot wants transparency, read off the placeholder itself."""
    p = os.path.join(ROOT, "assets", group, name)
    if not os.path.isfile(p):
        return True
    with Image.open(p) as im:
        return im.convert("RGBA").getchannel("A").getextrema()[0] != 255


def rows():
    """Every (path, size, animated, description) from the manifest table."""
    md = open(os.path.join(ROOT, "assets", "ASSETS.md")).read()
    table = md[md.index("## every PNG"):]
    for line in table.splitlines():
        m = re.match(r"\|\s*`assets/([^`]+)`\s*\|\s*(\S+)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|$", line)
        if m:
            yield m.group(1), m.group(2), m.group(3), m.group(4)


HEADER = """# %(title)s — %(count)d files

%(brief)s

%(size_note)s

## How to use this folder

1. Find a picture for a row below.
2. Save it here with **exactly the filename in the first column**.
3. Any size is fine — `tools/install_incoming.py` resizes to the target for you.
   Match the shape (square vs wide) or it will look squashed.
4. When you have some or all of them, run from the project root:

       python3 tools/install_incoming.py

   It checks every file, resizes it, copies it into `assets/%(group)s/`, and
   tells you what is still missing. Files you have not replaced keep their
   current placeholder.

## Watch out

%(gotchas)s

## The files

| Save it as | Size | Background | What it is |
|------------|------|------------|------------|
%(rows)s
"""


def main():
    by_group = {}
    frozen_notes = {}
    for path, size, _anim, desc in rows():
        group, name = path.split("/", 1)
        if any(name.startswith(p) for p in FROZEN):
            frozen_notes.setdefault(group, []).append((name, desc))
            continue
        by_group.setdefault(group, []).append(
            (name, size, desc, is_cutout(group, name)))

    # Whether a folder is all cut-outs, all solid, or mixed is a fact about the
    # files, not something to declare by hand - env/ and ui/ both turned out to
    # be mixed. Derive it so a new asset can never make the README lie.
    for group, files in by_group.items():
        cuts = {cut for _n, _s, _d, cut in files}
        GROUPS[group]["cutout"] = cuts.pop() if len(cuts) == 1 else None

    os.makedirs(OUT, exist_ok=True)
    # Godot imports every file under the project root. Without this it would
    # try to import half-finished downloads and fill the folder with .import
    # files - and a broken JPEG would show up as an editor error.
    open(os.path.join(OUT, ".gdignore"), "w").close()
    total = 0
    index = []
    for group, files in sorted(by_group.items()):
        g = GROUPS[group]
        d = os.path.join(OUT, group)
        os.makedirs(d, exist_ok=True)
        body = "\n".join(
            "| `%s` | %s | %s | %s |"
            % (n, s, "cut-out" if cut else "**solid**", desc)
            for n, s, desc, cut in files)
        notes = list(g["gotchas"])
        for n, why in frozen_notes.get(group, [])[:1]:
            notes.append("`%s*` files are **not in this list and must not be replaced** "
                         "- they are %s." % (list(FROZEN)[0], list(FROZEN.values())[0]))
        with open(os.path.join(d, "README.md"), "w") as f:
            f.write(HEADER % dict(
                title=g["title"], count=len(files), brief=g["brief"], group=group,
                size_note=(
                    "**Check the Background column per file** - this folder holds "
                    "both cut-outs and solid full-frame pictures."
                    if g["cutout"] is None else
                    "Every file here is **a cut-out with a transparent background**."
                    if g["cutout"] else
                    "Every file here is **fully opaque** - it fills the frame."),
                gotchas="\n".join("- " + x for x in notes),
                rows=body))
        index.append((group, g["title"], len(files), g["cutout"]))
        total += len(files)

    with open(os.path.join(OUT, "README.md"), "w") as f:
        f.write(INDEX % dict(
            total=total,
            table="\n".join(
                "| [`%s/`](%s/README.md) | %s | %d | %s |"
                % (g, g, t, n,
                   "**mixed — check each row**" if c is None
                   else "transparent cut-out" if c else "opaque, full frame")
                for g, t, n, c in index)))
    print("assets_incoming/ ready: %d files across %d folders" % (total, len(index)))


INDEX = """# Replacement art — drop-in folders

%(total)d pictures replace every visual in the game. Each folder below has its
own README listing the exact filenames it wants, the size, and what kind of
picture fits.

| Folder | What | Files | Background |
|--------|------|-------|------------|
%(table)s

## The loop

1. Open a folder's README and pick a row.
2. Find a picture. Save it in that folder under the **exact filename** given.
3. Run `python3 tools/install_incoming.py` from the project root.

The installer resizes each file to the target, copies it into `assets/`, and
prints what is still missing. It is safe to run repeatedly and safe to run with
only a few files done — anything you have not replaced keeps its placeholder, so
the game always runs.

## Two things that will bite you

**Stretching.** Buttons, panels, sliders and scrollbars are small images stretched
to fit. A photograph smears when stretched. Anything in `ui/` marked *NinePatch*
wants a plain frame or texture with nothing important in the middle.

**Transparency.** Almost everything must be a cut-out — the subject on nothing.
The exceptions are the five full-frame pictures in `env/`; that folder is mixed,
so its table has a Background column telling you which is which. A JPEG has no transparency, so a JPEG of a bottle gives you a bottle on
a white square. Search for `png transparent` or `cutout`, and prefer `.png`.
The installer warns you when a file that should be a cut-out is fully opaque.

## Licensing

Pictures found on Pinterest, Google Images and similar are almost always someone
else's copyrighted work, and Pinterest is an index of other sites rather than a
source. That is fine while you are only testing the pipeline internally, and a
problem the moment the game is shown publicly, submitted, or published.

If you want images you can actually keep, these are free to use commercially and
searchable the same way: **Pexels**, **Unsplash**, **Pixabay** (photos and
backgrounds), **OpenGameArt**, **Kenney.nl**, **itch.io free assets** (game art,
icons, UI frames — often already cut out and already sized for games), and
**Game-icons.net** (icons). Kenney's UI packs in particular already solve the
stretching problem for you.
"""


if __name__ == "__main__":
    main()
