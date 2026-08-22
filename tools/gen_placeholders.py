#!/usr/bin/env python3
"""Generates every placeholder PNG in assets/ and writes assets/ASSETS.md.

Flat colour shapes, high contrast, a thin outline, and - for anything with a
hidden property - a visible marker so it is testable. No AI image generation is
used anywhere in this project.

The manifest in ASSETS.md is emitted by this script as it draws, so the document
the designers work from can never drift from what is actually on disk.

    python3 tools/gen_placeholders.py
"""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import content as C

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")
MANIFEST = []

TOOL_COLORS = {t["id"]: t["color"] for t in C.TOOLS}
TOOL_LETTER = {"rinse": "R", "swab": "S", "magnifier": "M", "cutter": "C"}


def font(size):
    return ImageFont.load_default(size=size)


def shade(c, f):
    return tuple(max(0, min(255, int(v * f))) for v in c)


def canvas(w, h, bg=(0, 0, 0, 0)):
    img = Image.new("RGBA", (w, h), bg)
    return img, ImageDraw.Draw(img)


def save(img, rel, desc, animates="no", frames=1):
    path = os.path.join(ASSETS, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    MANIFEST.append((rel.replace(os.sep, "/"), "%dx%d" % img.size, desc, animates, frames))


def centered(d, box, text, fill, size):
    f = font(size)
    x0, y0, x1, y1 = box
    tb = d.textbbox((0, 0), text, font=f)
    d.text(((x0 + x1 - tb[2]) / 2, (y0 + y1 - tb[3]) / 2), text, font=f, fill=fill)


def outlined(d, kind, box, color, width=3, **kw):
    """Every placeholder shape is a flat fill plus a thin darker outline."""
    getattr(d, kind)(box, fill=color, outline=shade(color, 0.55), width=width, **kw)


# ----------------------------------------------------------------- item shapes

def draw_item_shape(d, shape, col, W, H):
    m = 16
    dark = shade(col, 0.55)
    if shape == "peel":
        outlined(d, "polygon", [(m, H - m), (W * .3, H * .35), (W * .55, m + 8),
                                (W * .72, m + 14), (W * .5, H * .55), (W - m, H - m)], col)
    elif shape == "bone":
        outlined(d, "rounded_rectangle", [m + 18, H * .42, W - m - 18, H * .58], col, radius=10)
        for cx in (m + 22, W - m - 22):
            for cy in (H * .34, H * .66):
                outlined(d, "ellipse", [cx - 16, cy - 14, cx + 16, cy + 14], col)
    elif shape == "bottle":
        outlined(d, "rounded_rectangle", [W * .28, H * .34, W * .72, H - m], col, radius=14)
        outlined(d, "rectangle", [W * .42, H * .16, W * .58, H * .36], col)
        outlined(d, "rectangle", [W * .40, m, W * .60, H * .18], shade(col, 0.7))
    elif shape == "can":
        outlined(d, "rounded_rectangle", [W * .30, H * .18, W * .70, H - m], col, radius=12)
        outlined(d, "ellipse", [W * .30, H * .12, W * .70, H * .24], shade(col, 0.8))
    elif shape == "tray":
        outlined(d, "polygon", [(m, H * .32), (W - m, H * .32),
                                (W - m - 22, H - m), (m + 22, H - m)], col)
    elif shape == "box":
        outlined(d, "rounded_rectangle", [m, H * .28, W - m, H - m], col, radius=8)
        for cx in (W * .30, W * .70):
            outlined(d, "rectangle", [cx - 12, H * .18, cx + 12, H * .30], shade(col, 1.5))
    elif shape == "jerrycan":
        outlined(d, "rounded_rectangle", [W * .22, H * .28, W * .78, H - m], col, radius=10)
        outlined(d, "rectangle", [W * .55, H * .12, W * .70, H * .30], shade(col, 0.85))
        d.arc([W * .18, H * .14, W * .48, H * .44], 190, 350, fill=dark, width=6)
    elif shape == "carton":
        outlined(d, "polygon", [(W * .26, H * .30), (W * .50, H * .12), (W * .74, H * .30)], col)
        outlined(d, "rectangle", [W * .26, H * .30, W * .74, H - m], col)
    elif shape == "tote":
        outlined(d, "rectangle", [W * .20, H * .38, W * .80, H - m], col)
        d.arc([W * .32, H * .12, W * .68, H * .56], 180, 360, fill=dark, width=7)
    elif shape == "cup":
        outlined(d, "polygon", [(W * .28, H * .28), (W * .72, H * .28),
                                (W * .62, H - m), (W * .38, H - m)], col)
        outlined(d, "ellipse", [W * .26, H * .22, W * .74, H * .34], shade(col, 0.85))
    elif shape == "spray":
        outlined(d, "rounded_rectangle", [W * .34, H * .24, W * .66, H - m], col, radius=10)
        outlined(d, "rectangle", [W * .42, H * .10, W * .58, H * .26], shade(col, 0.7))
        outlined(d, "rectangle", [W * .34, H * .46, W * .66, H * .58], shade(col, 1.35))
    elif shape == "jar":
        outlined(d, "rounded_rectangle", [W * .22, H * .30, W * .78, H - m], col, radius=12)
        outlined(d, "rectangle", [W * .28, H * .16, W * .72, H * .32], shade(col, 0.75))
    elif shape == "net":
        outlined(d, "rounded_rectangle", [m, H * .24, W - m, H - m], col, radius=16)
        for i in range(1, 5):
            x = m + (W - 2 * m) * i / 5
            d.line([(x, H * .24), (x, H - m)], fill=dark, width=3)
            y = H * .24 + (H - m - H * .24) * i / 5
            d.line([(m, y), (W - m, y)], fill=dark, width=3)


def draw_hotspot_marker(d, spot, W, H):
    """Placeholder-only affordance: a thin ring in the tool's colour so hotspots
    can be found and tested before real art exists. Final art should hide the
    hotspot inside a natural feature - a seam, a stain, a label corner."""
    cx, cy = spot["pos"][0] * W, spot["pos"][1] * H
    r = spot["radius"] * W
    col = TOOL_COLORS[spot["tool"]] + (235,)
    for a in range(0, 360, 30):
        d.arc([cx - r, cy - r, cx + r, cy + r], a, a + 18, fill=col, width=3)
    centered(d, (cx - 8, cy - 8, cx + 8, cy + 8), TOOL_LETTER[spot["tool"]], col, 14)


def gen_items():
    W = H = 160
    for it in C.ITEMS:
        img, d = canvas(W, H)
        draw_item_shape(d, it["shape"], it["color"], W, H)
        # small light plate so the code stays legible over any item colour
        d.rounded_rectangle([W / 2 - 26, H - 28, W / 2 + 26, H - 6], radius=6,
                            fill=(245, 245, 245, 235), outline=(40, 40, 40, 255), width=2)
        centered(d, (W / 2 - 26, H - 28, W / 2 + 26, H - 8), it["code"], (20, 20, 20), 14)
        for spot in it["hotspots"]:
            draw_hotspot_marker(d, spot, W, H)
        hidden = [s["reveals"] for s in it["hotspots"]]
        save(img, "items/item_%s.png" % it["id"],
             "%s - %s. Hotspots: %s" % (it["name"], it["vis_mat"],
                                        ", ".join(hidden) if hidden else "none"),
             "yes (wobble in tank)", 4)


# ------------------------------------------------------------------- claw/fish

def gen_claw():
    W = H = 160
    poses = {"open": 46, "closing": 24, "closed": 8, "carrying": 8}
    for name, spread in poses.items():
        img, d = canvas(W, H)
        col = (176, 186, 200)
        outlined(d, "rounded_rectangle", [W / 2 - 26, 10, W / 2 + 26, 52], col, radius=8)
        for sgn in (-1, 1):
            tip = W / 2 + sgn * (spread + 26)
            outlined(d, "polygon", [(W / 2 + sgn * 18, 46), (W / 2 + sgn * 30, 46),
                                    (tip, H - 26), (tip - sgn * 14, H - 26)], shade(col, 0.9))
        if name == "carrying":
            outlined(d, "ellipse", [W / 2 - 20, H - 46, W / 2 + 20, H - 12], (120, 130, 145))
        save(img, "claw/claw_%s.png" % name, "Claw arm, %s pose" % name,
             "yes (one SpriteFrames animation per pose)", 6)
    img, d = canvas(8, 64)
    d.rectangle([2, 0, 5, 63], fill=(150, 158, 172))
    save(img, "claw/claw_cable.png", "Cable segment, tiled vertically from rail to claw", "no", 1)


def gen_fish():
    for name, W, H, col in C.FISH:
        img, d = canvas(W, H)
        outlined(d, "ellipse", [W * .10, H * .18, W * .78, H * .82], col)
        outlined(d, "polygon", [(W * .74, H * .5), (W - 4, H * .12), (W - 4, H * .88)], shade(col, 0.85))
        d.ellipse([W * .20, H * .34, W * .30, H * .48], fill=(30, 30, 40))
        save(img, "fish/%s.png" % name, "Decoy fish, swims left to right", "yes (swim)", 6)


# ----------------------------------------------------------------- bins/tools

def gen_bins():
    W, H = 200, 240
    faces = {"idle": ("-", 1.0), "accept": ("OK", 1.25), "reject": ("X", 0.75)}
    for name, col in C.BINS:
        for state, (glyph, f) in faces.items():
            img, d = canvas(W, H)
            c = shade(col, f)
            outlined(d, "polygon", [(18, 46), (W - 18, 46), (W - 34, H - 10), (34, H - 10)], c)
            outlined(d, "rounded_rectangle", [8, 10, W - 8, 46], shade(c, 0.8), radius=6)
            centered(d, (0, 80, W, 160), glyph, shade(c, 0.4), 46)
            suffix = "" if state == "idle" else "_" + state
            save(img, "bins/bin_%s%s.png" % (name, suffix),
                 "%s bin, %s state" % (name, state), "yes (idle/accept/reject)", 6)


def gen_tools():
    W = H = 96
    for t in C.TOOLS:
        for state in ("idle", "using"):
            img, d = canvas(W, H)
            col = t["color"] if state == "idle" else shade(t["color"], 1.3)
            if t["id"] == "rinse":
                outlined(d, "rounded_rectangle", [26, 16, 62, 58], col, radius=8)
                for i in range(3):
                    d.line([(32 + i * 12, 62), (28 + i * 12, 88)], fill=shade(col, 0.7), width=5)
            elif t["id"] == "swab":
                d.line([(28, 76), (66, 26)], fill=shade(col, 0.6), width=8)
                outlined(d, "ellipse", [56, 14, 82, 40], col)
            elif t["id"] == "magnifier":
                outlined(d, "ellipse", [16, 12, 66, 62], col, width=6)
                d.line([(60, 58), (84, 84)], fill=shade(col, 0.6), width=9)
            else:
                outlined(d, "polygon", [(20, 74), (58, 22), (76, 34), (36, 84)], col)
                d.line([(20, 74), (36, 84)], fill=shade(col, 0.4), width=6)
            save(img, "tools/tool_%s%s.png" % (t["id"], "" if state == "idle" else "_using"),
                 "%s tool, %s" % (t["name"], state), "yes (idle/using)", 4)


# ------------------------------------------------------------------------ ui

def gen_ui():
    def panel(name, fill, border, w=96, h=96, r=18, desc=""):
        img, d = canvas(w, h)
        d.rounded_rectangle([2, 2, w - 3, h - 3], radius=r, fill=fill, outline=border, width=3)
        save(img, "ui/%s.png" % name, desc + " NinePatchRect, 24px margins.", "no", 1)

    panel("panel_main", (26, 48, 66, 235), (86, 140, 170, 255), desc="Main UI panel.")
    panel("panel_dark", (12, 22, 34, 245), (58, 96, 124, 255), desc="Modal / overlay panel.")
    panel("panel_slot", (20, 38, 54, 220), (70, 112, 140, 255), desc="Inventory slot background.")
    panel("chip_surface", (54, 62, 72, 240), (120, 130, 142, 255), 64, 40, 12,
          desc="Evidence chip, free surface info (grey).")
    panel("chip_reveal", (78, 62, 20, 240), (240, 200, 84, 255), 64, 40, 12,
          desc="Evidence chip, tool reveal (gold).")
    for name, fill, border in (("normal", (34, 66, 92, 240), (96, 156, 190, 255)),
                               ("hover", (48, 92, 124, 245), (140, 200, 232, 255)),
                               ("pressed", (22, 46, 66, 250), (86, 140, 170, 255)),
                               ("disabled", (30, 38, 46, 200), (70, 78, 88, 255))):
        img, d = canvas(64, 64)
        d.rounded_rectangle([2, 2, 61, 61], radius=14, fill=fill, outline=border, width=3)
        save(img, "ui/button_%s.png" % name, "Button %s state. NinePatch, 20px margins." % name, "no", 1)

    for name, col, glyph in (("icon_day", (240, 200, 84), "H"), ("icon_quota", (120, 200, 140), "T"),
                             ("icon_grab", (200, 200, 210), "C"), ("icon_health", (110, 200, 190), "L"),
                             ("icon_book", (220, 200, 160), "A"), ("icon_close", (220, 120, 110), "X"),
                             ("icon_check", (120, 200, 140), "V"), ("icon_cross", (220, 100, 90), "X")):
        img, d = canvas(48, 48)
        outlined(d, "ellipse", [3, 3, 44, 44], col)
        centered(d, (0, 0, 48, 48), glyph, shade(col, 0.35), 24)
        save(img, "ui/%s.png" % name, "HUD icon (%s)" % glyph, "no", 1)

    for name, col in (("meter_bg", (30, 44, 58)), ("meter_fill", (86, 196, 172))):
        img, d = canvas(320, 32)
        d.rounded_rectangle([0, 0, 319, 31], radius=14, fill=col + (255,),
                            outline=shade(col, 1.6) + (255,), width=2)
        save(img, "ui/%s.png" % name, "Ocean health meter %s. Fill is clipped by width." %
             name.split("_")[1], "no", 1)

    for name, col in (("pip_full", (240, 200, 84)), ("pip_empty", (70, 80, 92))):
        img, d = canvas(16, 16)
        outlined(d, "ellipse", [1, 1, 14, 14], col, width=2)
        save(img, "ui/%s.png" % name, "Tool charge pip (%s)" % name.split("_")[1], "no", 1)

    for name, ang in (("arrow_left", 180), ("arrow_right", 0)):
        img, d = canvas(96, 96)
        outlined(d, "ellipse", [4, 4, 91, 91], (58, 92, 118), width=3)
        pts = [(70, 28), (70, 68), (30, 48)] if ang == 180 else [(26, 28), (26, 68), (66, 48)]
        outlined(d, "polygon", pts, (200, 216, 230))
        save(img, "ui/%s.png" % name, "Console arrow button (%s)" % name.split("_")[1], "no", 1)

    img, d = canvas(128, 128)
    outlined(d, "ellipse", [4, 4, 123, 123], (40, 60, 78))
    save(img, "ui/joystick_base.png", "Console joystick base", "no", 1)
    img, d = canvas(72, 72)
    outlined(d, "ellipse", [2, 2, 69, 69], (198, 82, 72))
    save(img, "ui/joystick_knob.png", "Console joystick knob, offsets with claw", "no", 1)


# ----------------------------------------------------------------------- env

def gen_env():
    img, d = canvas(1280, 720)
    for y in range(720):
        t = y / 719.0
        d.line([(0, y), (1280, y)], fill=(int(8 + 14 * t), int(38 + 30 * t), int(72 + 26 * t), 255))
    save(img, "env/water_bg.png", "Full-screen water background, layer 0", "no", 1)

    img, d = canvas(1000, 140)
    d.rectangle([0, 30, 999, 139], fill=(74, 68, 52, 255))
    d.rectangle([0, 30, 999, 44], fill=(102, 94, 70, 255))
    for x, r in ((120, 34), (420, 22), (700, 40), (880, 18)):
        outlined(d, "ellipse", [x - r, 30 - r * .7, x + r, 30 + r], (58, 54, 44))
    save(img, "env/seabed.png", "Seabed floor inside the tank SubViewport, z_index -10", "no", 1)

    img, d = canvas(1040, 460)
    d.rounded_rectangle([0, 0, 1039, 459], radius=26, outline=(58, 74, 92, 255), width=20)
    d.rounded_rectangle([10, 10, 1029, 449], radius=20, outline=(96, 122, 148, 255), width=6)
    save(img, "env/tank_frame.png", "Machine frame around the tank. Centre is transparent.", "no", 1)

    img, d = canvas(1000, 420)
    for x0 in (60, 300, 660):
        d.polygon([(x0, 0), (x0 + 90, 0), (x0 + 30, 419), (x0 - 60, 419)], fill=(255, 255, 255, 16))
    d.rectangle([0, 0, 999, 419], fill=(120, 200, 220, 12))
    save(img, "env/glass_overlay.png", "Glass reflection and tint, layer 20", "no", 1)

    img, d = canvas(1280, 220)
    d.rectangle([0, 0, 1279, 219], fill=(24, 40, 54, 255))
    d.rectangle([0, 0, 1279, 10], fill=(96, 122, 148, 255))
    save(img, "env/machine_console.png", "Console backing plate under the tank, layer 30", "no", 1)

    img, d = canvas(24, 24)
    d.ellipse([1, 1, 22, 22], fill=(200, 235, 245, 90), outline=(230, 250, 255, 170), width=2)
    save(img, "env/bubble.png", "Bubble, count scales with the VFX slider", "no", 1)

    for i, (label, col) in enumerate((("LAUT", (18, 58, 92)), ("SAMPAH", (58, 52, 44)),
                                      ("MESIN", (34, 66, 78))), start=1):
        img, d = canvas(960, 540)
        for y in range(540):
            t = y / 539.0
            d.line([(0, y), (960, y)], fill=shade(col, 0.6 + 0.9 * t) + (255,))
        d.rectangle([0, 380, 959, 539], fill=shade(col, 0.45) + (255,))
        centered(d, (0, 180, 960, 260), label, (235, 240, 245), 64)
        save(img, "env/cutscene_%02d.png" % i, "Cutscene still %d (placeholder)" % i, "no", 1)

    img, d = canvas(640, 200)
    d.rounded_rectangle([4, 40, 635, 160], radius=20, fill=(16, 44, 68, 255),
                        outline=(110, 190, 210, 255), width=5)
    centered(d, (0, 60, 640, 140), "CAKAR LAUT", (220, 240, 250), 56)
    save(img, "env/logo.png", "Title logo", "no", 1)



# ------------------------------------------------------------- SpriteFrames
# Everything that will ever animate is already an AnimatedSprite2D backed by one
# of these, currently one frame per animation. Designers add frames here rather
# than replacing nodes.
FRAMES_DIR = os.path.join(ROOT, "data", "frames")


def write_frames(name, anims, speed=6.0):
    """anims: [(anim_name, [texture_rel_path, ...])]"""
    textures = []
    for _, paths in anims:
        for pth in paths:
            if pth not in textures:
                textures.append(pth)
    lines = ['[gd_resource type="SpriteFrames" load_steps=%d format=3]' % (len(textures) + 1), ""]
    for i, pth in enumerate(textures):
        lines.append('[ext_resource type="Texture2D" path="res://assets/%s" id="%d"]' % (pth, i + 1))
    lines += ["", "[resource]", "animations = ["]
    blocks = []
    for anim_name, paths in anims:
        fr = ", ".join('{\n"duration": 1.0,\n"texture": ExtResource("%d")\n}'
                       % (textures.index(p) + 1) for p in paths)
        blocks.append('{\n"frames": [%s],\n"loop": true,\n"name": &"%s",\n"speed": %.1f\n}'
                      % (fr, anim_name, speed))
    lines.append(", ".join(blocks) + "]")
    os.makedirs(FRAMES_DIR, exist_ok=True)
    with open(os.path.join(FRAMES_DIR, name + ".tres"), "w") as f:
        f.write("\n".join(lines) + "\n")


def gen_frames():
    n = 0
    write_frames("claw_frames", [(a, ["claw/claw_%s.png" % a])
                                 for a in ("open", "closing", "closed", "carrying")], 8.0)
    n += 1
    for name, _w, _h, _c in C.FISH:
        write_frames("%s_frames" % name, [("swim", ["fish/%s.png" % name])], 6.0)
        n += 1
    for it in C.ITEMS:
        write_frames("item_%s_frames" % it["id"],
                     [("wobble", ["items/item_%s.png" % it["id"]])], 4.0)
        n += 1
    for name, _col in C.BINS:
        write_frames("bin_%s_frames" % name,
                     [("idle", ["bins/bin_%s.png" % name]),
                      ("accept", ["bins/bin_%s_accept.png" % name]),
                      ("reject", ["bins/bin_%s_reject.png" % name])], 8.0)
        n += 1
    for t in C.TOOLS:
        write_frames("tool_%s_frames" % t["id"],
                     [("idle", ["tools/tool_%s.png" % t["id"]]),
                      ("using", ["tools/tool_%s_using.png" % t["id"]])], 8.0)
        n += 1
    print("generated %d SpriteFrames resources in data/frames/" % n)


HEADER = """# Asset Manifest

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
"""


def main():
    gen_items()
    gen_claw()
    gen_fish()
    gen_bins()
    gen_tools()
    gen_ui()
    gen_env()
    gen_frames()
    rows = "\n".join("| `assets/%s` | %s | %s | %s | %s |" % r for r in MANIFEST)
    with open(os.path.join(ASSETS, "ASSETS.md"), "w") as f:
        f.write(HEADER + rows + "\n\n_%d files. Regenerate placeholders with_ "
                "`python3 tools/gen_placeholders.py`.\n" % len(MANIFEST))
    print("generated %d PNGs + ASSETS.md" % len(MANIFEST))


if __name__ == "__main__":
    main()
