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

ANIMS = []  # (SpriteFrames resource, animation, source PNG, target frame count)


def font(size):
    return ImageFont.load_default(size=size)


def shade(c, f):
    return tuple(max(0, min(255, int(v * f))) for v in c)


def canvas(w, h, bg=(0, 0, 0, 0)):
    img = Image.new("RGBA", (w, h), bg)
    return img, ImageDraw.Draw(img)


def save(img, rel, desc):
    path = os.path.join(ASSETS, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    MANIFEST.append((rel.replace(os.sep, "/"), "%dx%d" % img.size, desc))


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


def gen_items():
    """Clean item art: one flat shape, one colour, nothing written on it.

    Earlier placeholders stamped a material code ("PET", "ORG") on every item.
    That was removed: the whole inspect phase is about judging what an item is
    from what you can observe, and a label reading PET answers the question for
    free - and does it in art the designers were never going to reproduce.

    Hotspot rings are a separate overlay generated from the .tres by
    tools/gen_hotspot_overlays.gd - never baked in here."""
    W = H = 160
    for it in C.ITEM_ART:
        img, d = canvas(W, H)
        draw_item_shape(d, it["shape"], it["color"], W, H)
        save(img, "items/item_%s.png" % it["id"], "Trash item `%s`" % it["id"])


# ----------------------------------------------------------------- mystery box

def gen_boxes():
    """The sealed box (revision 4 §2). Two states, two PNGs - never a tint.

    Flat crate, thin outline, no gradient and no baked shadow, drawn exactly
    like the items so it reads as one more thing on the seabed. `closed` is what
    drifts in and what the inventory card shows; the card swaps to `opened` when
    the player presses Buka."""
    W = H = 160
    col = (176, 134, 86)
    dark = shade(col, 0.55)

    img, d = canvas(W, H)
    outlined(d, "rounded_rectangle", [22, 44, W - 22, H - 20], col, radius=10)
    outlined(d, "rectangle", [16, 32, W - 16, 54], shade(col, 0.8))
    for y in (86, 112):
        d.line([(26, y), (W - 26, y)], fill=dark, width=3)
    d.line([(W // 2, 56), (W // 2, H - 22)], fill=dark, width=3)
    save(img, "items/box_closed.png", "Mystery box, sealed. State `closed`.")

    img, d = canvas(W, H)
    outlined(d, "rounded_rectangle", [22, 56, W - 22, H - 20], col, radius=10)
    outlined(d, "rectangle", [32, 58, W - 32, 88], shade(col, 0.35))
    outlined(d, "polygon", [(14, 44), (W - 44, 16), (W - 14, 30), (44, 58)],
             shade(col, 0.8))
    d.line([(W // 2, 90), (W // 2, H - 22)], fill=dark, width=3)
    save(img, "items/box_opened.png", "Mystery box, lid open. State `opened`.")



# ------------------------------------------------------------- blueprint sheets

def greyscale(c):
    """The locked component is drawn in the greyscale of its own colour.

    It is a SEPARATE PNG, not the colour one with a filter over it at runtime -
    revision 4 §3 is explicit that locked and done are two drawings. Doing the
    conversion here, once, at draw time, is what keeps them the same shape."""
    v = int(round(0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]))
    return (v, v, v)


def draw_component_shape(d, shape, col, W, H):
    m = 14
    dark = shade(col, 0.55)
    if shape == "hull":
        outlined(d, "rounded_rectangle", [m + 16, H * .34, W - m - 16, H * .66], col, radius=12)
        for y in (H * .30, H * .70):
            outlined(d, "rectangle", [m, y - 7, W - m, y + 7], shade(col, 0.75))
    elif shape == "core":
        outlined(d, "ellipse", [m + 4, m + 4, W - m - 4, H - m - 4], col)
        outlined(d, "ellipse", [W * .34, H * .34, W * .66, H * .66], shade(col, 0.6))
    elif shape == "fin":
        outlined(d, "polygon", [(m, H - m), (W * .5, m), (W - m, H - m)], col)
        d.line([(W * .5, m + 18), (W * .5, H - m - 6)], fill=dark, width=4)
    elif shape == "mesh":
        outlined(d, "rectangle", [m, m, W - m, H - m], col)
        for i in range(1, 4):
            at = m + (W - 2 * m) * i / 4.0
            d.line([(at, m), (at, H - m)], fill=dark, width=3)
            d.line([(m, at), (W - m, at)], fill=dark, width=3)
    elif shape == "pump":
        outlined(d, "ellipse", [m, H * .22, W * .68, H * .90], col)
        outlined(d, "rectangle", [W * .52, H * .30, W - m, H * .54], shade(col, 0.75))
    elif shape == "tank":
        outlined(d, "rounded_rectangle", [W * .26, m + 12, W * .74, H - m], col, radius=14)
        outlined(d, "rectangle", [W * .40, m, W * .60, m + 16], shade(col, 0.75))
        d.line([(W * .30, H * .62), (W * .70, H * .62)], fill=dark, width=4)
    elif shape == "chamber":
        outlined(d, "rectangle", [m, m, W - m, H - m], col, width=8)
        outlined(d, "rectangle", [W * .34, H * .34, W * .66, H * .66], shade(col, 0.6))
    elif shape == "cell":
        outlined(d, "rounded_rectangle", [m + 8, m, W - m - 8, H - m], col, radius=10)
        for y in (H * .34, H * .52, H * .70):
            d.line([(W * .30, y), (W * .70, y)], fill=dark, width=4)
    elif shape == "valve":
        outlined(d, "ellipse", [W * .22, H * .22, W * .78, H * .78], col)
        d.line([(W * .5, m), (W * .5, H - m)], fill=dark, width=6)
        d.line([(m, H * .5), (W - m, H * .5)], fill=dark, width=6)
    else:
        outlined(d, "rectangle", [m, m, W - m, H - m], col)


def gen_blueprints():
    """The three schematic sheets and the nine components on them.

    Flat: a field, a thin grid and a border, no gradient and no baked shadow.
    Nothing is written on a sheet - the component NAMES come from the .tres and
    are drawn as labels by the tab, so a designer redrawing a sheet never has to
    reproduce Indonesian text in the art."""
    for sheet in C.BLUEPRINT_SHEETS:
        W, H = 960, 540
        img, d = canvas(W, H, sheet["color"] + (255,))
        grid = shade(sheet["color"], 1.5) + (255,)
        for x in range(0, W, 48):
            d.line([(x, 0), (x, H)], fill=grid, width=1)
        for y in range(0, H, 48):
            d.line([(0, y), (W, y)], fill=grid, width=1)
        border = shade(sheet["color"], 2.4) + (255,)
        d.rectangle([2, 2, W - 3, H - 3], outline=border, width=4)
        d.rectangle([22, 22, W - 23, H - 23], outline=border, width=2)
        save(img, "ui/blueprint_bg_%s.png" % sheet["id"],
             "Blueprint schematic sheet for `%s`. Components are positioned on "
             "top of it from normalized coordinates in the .tres." % sheet["id"])

    for comp in C.COMPONENT_ART:
        W = H = 128
        for state, col in (("done", comp["color"]),
                           ("locked", greyscale(comp["color"]))):
            img, d = canvas(W, H)
            draw_component_shape(d, comp["shape"], col, W, H)
            save(img, "ui/comp_%s_%s.png" % (comp["id"], state),
                 "Blueprint component `%s`, %s. A separate drawing, never the "
                 "other one tinted." % (comp["id"], state))



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
        save(img, "claw/claw_%s.png" % name, "Claw arm, %s pose" % name)
    img, d = canvas(8, 64)
    d.rectangle([2, 0, 5, 63], fill=(150, 158, 172))
    save(img, "claw/claw_cable.png", "Cable, stretched vertically from rail to claw")


def gen_fish():
    for name, W, H, col in C.FISH:
        img, d = canvas(W, H)
        outlined(d, "ellipse", [W * .10, H * .18, W * .78, H * .82], col)
        outlined(d, "polygon", [(W * .74, H * .5), (W - 4, H * .12), (W - 4, H * .88)], shade(col, 0.85))
        d.ellipse([W * .20, H * .34, W * .30, H * .48], fill=(30, 30, 40))
        save(img, "fish/%s.png" % name,
             "Background fish. Not grabbable - atmosphere only")


# ----------------------------------------------------------------- bins/tools

def gen_bins():
    W, H = 200, 240
    faces = {"idle": ("-", 1.0), "accept": ("OK", 1.25), "reject": ("X", 0.75),
             "highlight": ("!", 1.5)}
    for name, col in C.BINS:
        for state, (glyph, f) in faces.items():
            img, d = canvas(W, H)
            c = shade(col, f)
            outlined(d, "polygon", [(18, 46), (W - 18, 46), (W - 34, H - 10), (34, H - 10)], c)
            outlined(d, "rounded_rectangle", [8, 10, W - 8, 46], shade(c, 0.8), radius=6)
            centered(d, (0, 80, W, 160), glyph, shade(c, 0.4), 46)
            suffix = "" if state == "idle" else "_" + state
            save(img, "bins/bin_%s%s.png" % (name, suffix),
                 "%s bin, %s state" % (name, state))


def gen_tools():
    W = H = 96
    for t in C.TOOL_ART:
        for state in ("idle", "using", "locked"):
            img, d = canvas(W, H)
            col = t["color"]
            if state == "using":
                col = shade(t["color"], 1.3)
            elif state == "locked":
                # A locked tool is its own drawing, not a dimmed one. Code must
                # never express state by tinting designer art (rev 3 §1.4).
                col = (96, 100, 108)
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
            save(img, "tools/tool_%s%s.png" % (t["id"], "" if state == "idle" else "_" + state),
                 "%s tool, %s" % (t["name"], state))


# ------------------------------------------------------------------------ ui

def gen_ui():
    def panel(name, fill, border, w=96, h=96, r=18, desc=""):
        img, d = canvas(w, h)
        d.rounded_rectangle([2, 2, w - 3, h - 3], radius=r, fill=fill, outline=border, width=3)
        save(img, "ui/%s.png" % name, desc + " NinePatchRect, 24px margins.")

    panel("panel_main", (26, 48, 66, 235), (86, 140, 170, 255), desc="Main UI panel.")
    # Revision 4 §3 called for a `popup_panel.png` "or reuse the existing panel
    # if one fits". This one fits: it is already the modal backing.
    panel("panel_dark", (12, 22, 34, 245), (58, 96, 124, 255),
          desc="Modal / overlay panel: the rulebook, the calibration puzzle, "
               "and the blueprint component popup.")
    panel("panel_slot", (20, 38, 54, 220), (70, 112, 140, 255), desc="Inventory slot background.")
    panel("panel_slot_selected", (34, 68, 92, 235), (150, 210, 240, 255),
          desc="Inventory slot, selected. A different PNG rather than a tint.")
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
        save(img, "ui/button_%s.png" % name, "Button %s state. NinePatch, 20px margins." % name)

    for name, col, glyph in (("icon_day", (240, 200, 84), "H"), ("icon_quota", (120, 200, 140), "T"),
                             ("icon_grab", (200, 200, 210), "C"), ("icon_health", (110, 200, 190), "L"),
                             ("icon_book", (220, 200, 160), "A"), ("icon_close", (220, 120, 110), "X"),
                             ("icon_check", (120, 200, 140), "V"), ("icon_cross", (220, 100, 90), "X"),
                             ("icon_pause", (200, 210, 225), "II")):
        img, d = canvas(48, 48)
        outlined(d, "ellipse", [3, 3, 44, 44], col)
        centered(d, (0, 0, 48, 48), glyph, shade(col, 0.35), 24)
        save(img, "ui/%s.png" % name, "HUD icon (%s)" % glyph)

    panel("chip_match", (22, 74, 48, 245), (110, 224, 150, 255), 64, 40, 12,
          desc="Evidence chip that satisfies an active rule (green).")

    # Minimap: the seabed is wider than the screen, so the player needs to see
    # where everything is without sweeping the camera.
    img, d = canvas(960, 28)
    d.rounded_rectangle([0, 0, 959, 27], radius=8, fill=(14, 30, 44, 235),
                        outline=(70, 112, 140, 255), width=2)
    save(img, "ui/minimap_bg.png", "Minimap strip background. Stretched to width.")
    img, d = canvas(64, 28)
    d.rectangle([0, 0, 63, 27], fill=(120, 190, 220, 46), outline=(150, 220, 245, 200), width=2)
    save(img, "ui/minimap_view.png", "Minimap window showing the visible slice. Stretched.")
    img, d = canvas(10, 10)
    outlined(d, "ellipse", [0, 0, 9, 9], (236, 200, 96), width=1)
    save(img, "ui/minimap_item.png", "Minimap dot for one item on the seabed")
    img, d = canvas(12, 20)
    outlined(d, "polygon", [(6, 19), (0, 4), (11, 4)], (232, 96, 84), width=1)
    save(img, "ui/minimap_claw.png", "Minimap marker for the claw")

    for name, col in (("meter_bg", (30, 44, 58)), ("meter_fill", (86, 196, 172))):
        img, d = canvas(320, 32)
        d.rounded_rectangle([0, 0, 319, 31], radius=14, fill=col + (255,),
                            outline=shade(col, 1.6) + (255,), width=2)
        save(img, "ui/%s.png" % name, "Ocean health meter %s. Fill is clipped by width." %
             name.split("_")[1])

    for name, ang in (("arrow_left", 180), ("arrow_right", 0)):
        img, d = canvas(96, 96)
        outlined(d, "ellipse", [4, 4, 91, 91], (58, 92, 118), width=3)
        pts = [(70, 28), (70, 68), (30, 48)] if ang == 180 else [(26, 28), (26, 68), (66, 48)]
        outlined(d, "polygon", pts, (200, 216, 230))
        save(img, "ui/%s.png" % name, "Console arrow button (%s)" % name.split("_")[1])

    img, d = canvas(128, 128)
    outlined(d, "ellipse", [4, 4, 123, 123], (40, 60, 78))
    save(img, "ui/joystick_base.png", "Console joystick base")
    img, d = canvas(72, 72)
    outlined(d, "ellipse", [2, 2, 69, 69], (198, 82, 72))
    save(img, "ui/joystick_knob.png", "Console joystick knob, offsets with claw")


# ----------------------------------------------------------------------- env

def gen_env():
    img, d = canvas(1280, 720)
    for y in range(720):
        t = y / 719.0
        d.line([(0, y), (1280, y)], fill=(int(8 + 14 * t), int(38 + 30 * t), int(72 + 26 * t), 255))
    save(img, "env/water_bg.png", "Full-screen water background, layer 0")

    img, d = canvas(1000, 140)
    d.rectangle([0, 30, 999, 139], fill=(74, 68, 52, 255))
    d.rectangle([0, 30, 999, 44], fill=(102, 94, 70, 255))
    for x, r in ((120, 34), (420, 22), (700, 40), (880, 18)):
        outlined(d, "ellipse", [x - r, 30 - r * .7, x + r, 30 + r], (58, 54, 44))
    save(img, "env/seabed.png", "Seabed floor inside the tank SubViewport, z_index -10")

    img, d = canvas(1040, 460)
    d.rounded_rectangle([0, 0, 1039, 459], radius=26, outline=(58, 74, 92, 255), width=20)
    d.rounded_rectangle([10, 10, 1029, 449], radius=20, outline=(96, 122, 148, 255), width=6)
    save(img, "env/tank_frame.png", "Machine frame around the tank. Centre is transparent.")

    img, d = canvas(1000, 420)
    for x0 in (60, 300, 660):
        d.polygon([(x0, 0), (x0 + 90, 0), (x0 + 30, 419), (x0 - 60, 419)], fill=(255, 255, 255, 16))
    d.rectangle([0, 0, 999, 419], fill=(120, 200, 220, 12))
    save(img, "env/glass_overlay.png", "Glass reflection and tint, layer 20")

    img, d = canvas(1280, 220)
    d.rectangle([0, 0, 1279, 219], fill=(24, 40, 54, 255))
    d.rectangle([0, 0, 1279, 10], fill=(96, 122, 148, 255))
    save(img, "env/machine_console.png", "Console backing plate under the tank, layer 30")

    img, d = canvas(24, 24)
    d.ellipse([1, 1, 22, 22], fill=(200, 235, 245, 90), outline=(230, 250, 255, 170), width=2)
    save(img, "env/bubble.png", "Bubble, count scales with the VFX slider")

    for i, (label, col) in enumerate((("LAUT", (18, 58, 92)), ("SAMPAH", (58, 52, 44)),
                                      ("MESIN", (34, 66, 78))), start=1):
        img, d = canvas(960, 540)
        for y in range(540):
            t = y / 539.0
            d.line([(0, y), (960, y)], fill=shade(col, 0.6 + 0.9 * t) + (255,))
        d.rectangle([0, 380, 959, 539], fill=shade(col, 0.45) + (255,))
        centered(d, (0, 180, 960, 260), label, (235, 240, 245), 64)
        save(img, "env/cutscene_%02d.png" % i, "Cutscene still %d (placeholder)" % i)

    img, d = canvas(640, 200)
    d.rounded_rectangle([4, 40, 635, 160], radius=20, fill=(16, 44, 68, 255),
                        outline=(110, 190, 210, 255), width=5)
    centered(d, (0, 60, 640, 140), "game laut idk", (220, 240, 250), 56)
    save(img, "env/logo.png", "Title logo")



# --------------------------------------------------------------- ocean tiers
# Revision 2 §1. The seabed backdrop, the coral and the debris are swapped by
# tier, so the recovering ocean is something the player can see rather than a
# number on a report. Counts and thresholds live in data/tiers/*.tres.

def gen_tiers():
    """Four seabed backdrops, murky to bright, plus coral and debris overlays."""
    for tier, (floor_col, top_col, rocks) in enumerate(C.TIER_SEABED):
        img, d = canvas(1000, 140)
        d.rectangle([0, 30, 999, 139], fill=floor_col + (255,))
        d.rectangle([0, 30, 999, 44], fill=top_col + (255,))
        for x, r in rocks:
            outlined(d, "ellipse", [x - r, 30 - r * .7, x + r, 30 + r], shade(floor_col, 0.8))
        save(img, "env/seabed_tier_%d.png" % tier,
             "Seabed backdrop for ocean tier %d. Tiled across the seabed width." % tier)

    for name, col, dead in (("coral_healthy", (232, 118, 132), False),
                            ("coral_dead", (128, 124, 118), True)):
        img, d = canvas(120, 140)
        branches = [(60, 138, 60, 44), (60, 96, 26, 40), (60, 96, 94, 40),
                    (60, 70, 38, 18), (60, 70, 84, 20)]
        for x0, y0, x1, y1 in branches:
            d.line([(x0, y0), (x1, y1)], fill=shade(col, 0.7), width=11)
        for x0, y0, x1, y1 in branches:
            r = 9 if dead else 13
            outlined(d, "ellipse", [x1 - r, y1 - r, x1 + r, y1 + r], col, width=2)
        save(img, "env/%s.png" % name,
             "Coral overlay, %s. Sways in place; count is per ocean tier."
             % ("bleached" if dead else "in colour"))

    img, d = canvas(96, 96)
    for x0, y0, w, h in ((8, 62, 40, 22), (44, 70, 34, 16), (20, 44, 26, 20)):
        outlined(d, "rounded_rectangle", [x0, y0, x0 + w, y0 + h], (78, 74, 66), radius=5)
    d.line([(10, 40), (58, 30)], fill=(64, 60, 54), width=5)
    save(img, "env/debris_overlay.png",
         "Debris clutter on the seabed. Count falls as the ocean recovers.")


# ------------------------------------------------------------- SpriteFrames
# Everything that will ever animate is already an AnimatedSprite2D backed by one
# of these, currently one frame per animation. Designers add frames here rather
# than replacing nodes.
FRAMES_DIR = os.path.join(ROOT, "data", "frames")


def write_frames(name, anims, speed=6.0):
    """anims: [(animation_name, [texture_rel_path, ...], target_frame_count)]"""
    textures = []
    for _, paths, _ in anims:
        for pth in paths:
            if pth not in textures:
                textures.append(pth)
    lines = ['[gd_resource type="SpriteFrames" load_steps=%d format=3]' % (len(textures) + 1), ""]
    for i, pth in enumerate(textures):
        lines.append('[ext_resource type="Texture2D" path="res://assets/%s" id="%d"]' % (pth, i + 1))
    lines += ["", "[resource]", "animations = ["]
    blocks = []
    for anim_name, paths, target in anims:
        fr = ", ".join('{\n"duration": 1.0,\n"texture": ExtResource("%d")\n}'
                       % (textures.index(p) + 1) for p in paths)
        blocks.append('{\n"frames": [%s],\n"loop": true,\n"name": &"%s",\n"speed": %.1f\n}'
                      % (fr, anim_name, speed))
        ANIMS.append(("data/frames/%s.tres" % name, anim_name, paths[0], target))
    lines.append(", ".join(blocks) + "]")
    os.makedirs(FRAMES_DIR, exist_ok=True)
    with open(os.path.join(FRAMES_DIR, name + ".tres"), "w") as f:
        f.write("\n".join(lines) + "\n")


def frames_box():
    """The box answers to the tank's three named states as well as its own two.

    tank_item.gd plays `idle`, `wobble` and `sinking` on everything it holds; a
    box that did not have them would need the tank to learn what a box is, which
    is exactly the per-asset special case the data model forbids. All three show
    the sealed crate - `opened` is only ever reached from the inventory card.
    """
    write_frames("box", [
        ("closed", ["items/box_closed.png"], 2),
        ("opened", ["items/box_opened.png"], 2),
        ("idle", ["items/box_closed.png"], 2),
        ("wobble", ["items/box_closed.png"], 4),
        ("sinking", ["items/box_closed.png"], 6)], 4.0)


def gen_frames():
    n = 0
    write_frames("claw_frames", [
        ("open", ["claw/claw_open.png"], 4),
        ("closing", ["claw/claw_closing.png"], 6),
        ("closed", ["claw/claw_closed.png"], 2),
        ("carrying", ["claw/claw_carrying.png"], 6)], 8.0)
    n += 1
    for name, _w, _h, _c in C.FISH:
        write_frames("%s_frames" % name, [("swim", ["fish/%s.png" % name], 6)], 6.0)
        n += 1
    for it in C.ITEM_ART:
        base = "items/item_%s.png" % it["id"]
        # idle on the seabed, wobble when held, sinking while drifting in.
        write_frames("item_%s_frames" % it["id"], [
            ("idle", [base], 2),
            ("wobble", [base], 4),
            ("sinking", [base], 6)], 4.0)
        n += 1
    for name, _col in C.BINS:
        write_frames("bin_%s_frames" % name, [
            ("idle", ["bins/bin_%s.png" % name], 2),
            ("accept", ["bins/bin_%s_accept.png" % name], 6),
            ("reject", ["bins/bin_%s_reject.png" % name], 6),
            ("highlight", ["bins/bin_%s_highlight.png" % name], 4)], 8.0)
        n += 1
    for t in C.TOOL_ART:
        write_frames("tool_%s_frames" % t["id"], [
            ("idle", ["tools/tool_%s.png" % t["id"]], 2),
            ("using", ["tools/tool_%s_using.png" % t["id"]], 4),
            ("locked", ["tools/tool_%s_locked.png" % t["id"]], 1)], 8.0)
        n += 1
    write_frames("bubble_frames", [("rise", ["env/bubble.png"], 6)], 6.0)
    n += 1
    frames_box()
    n += 1
    # Ocean-tier overlays. They sway; nothing in code moves them (revision 1 §1).
    for name in ("coral_healthy", "coral_dead", "debris_overlay"):
        write_frames("%s_frames" % name, [("idle", ["env/%s.png" % name], 6)], 3.0)
        n += 1
    print("generated %d SpriteFrames resources in data/frames/" % n)


HEADER = """# Asset Manifest

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
   | Box on its inventory card | 160×160 | 64×64 | `InventoryPanel.BOX_CARD_SCALE` = 0.4 |

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
"""

TABLE_HEADER = """

## Every PNG

`Animated` names the `SpriteFrames` animations this PNG is the placeholder
frame for, with the frame count the final version should have. `static` means
the file is displayed as-is and never animates.

| Path | Size | Animated | What it is |
|------|------|----------|-----------|
"""


def animation_note(rel_path):
    """Which animations, and at how many frames, this PNG stands in for."""
    parts = ["`%s` %d fr" % (anim, target)
             for _res, anim, src, target in ANIMS if src == rel_path]
    return ", ".join(parts) if parts else "static"


def note_generated_elsewhere():
    """Files this script does not draw, but which belong in the manifest so the
    designers see the full picture."""
    for it in C.ITEM_ART:
        MANIFEST.append(("items/hotspots_%s.png" % it["id"], "160x160",
                         "Hotspot rings for `%s`. **Generated from "
                         "`data/items/%s.tres`** by `tools/gen_hotspot_overlays.gd` - "
                         "never edit by hand, and do not draw it into the item art."
                         % (it["id"], it["id"])))


## Groups a --only run can ask for, so adding one asset never means redrawing
## every PNG in the project. A group may also own SpriteFrames.
def _groups():
    return {
        "items": [gen_items],
        "boxes": [gen_boxes, frames_box],
        "blueprints": [gen_blueprints],
        "claw": [gen_claw],
        "fish": [gen_fish],
        "bins": [gen_bins],
        "tools": [gen_tools],
        "ui": [gen_ui],
        "env": [gen_env],
        "tiers": [gen_tiers],
    }


def generate_only(names):
    """Draws just the named groups and leaves ASSETS.md alone.

    A full run rewrites every PNG and the whole manifest. That is right when the
    art rules change and wrong when one asset is added, so the new rows go into
    ASSETS.md by hand and a later full run reproduces them in place."""
    groups = _groups()
    for name in names:
        if name not in groups:
            raise SystemExit("unknown group %r; have: %s"
                             % (name, ", ".join(sorted(groups))))
        for fn in groups[name]:
            fn()
    for rel, size, desc in MANIFEST:
        print("  assets/%s  %s  %s" % (rel, size, desc))
    print("generated %d PNGs for: %s (ASSETS.md not rewritten)"
          % (len(MANIFEST), ", ".join(names)))


def main():
    if len(sys.argv) > 2 and sys.argv[1] == "--only":
        generate_only(sys.argv[2].split(","))
        return
    gen_items()
    gen_claw()
    gen_fish()
    gen_bins()
    gen_tools()
    gen_ui()
    gen_env()
    gen_tiers()
    gen_boxes()
    gen_blueprints()
    gen_frames()
    note_generated_elsewhere()
    anims = "\n".join("| `%s` | `%s` | `assets/%s` | %d |" % a for a in ANIMS)
    rows = "\n".join("| `assets/%s` | %s | %s | %s |"
                     % (r[0], r[1], animation_note(r[0]), r[2]) for r in MANIFEST)
    with open(os.path.join(ASSETS, "ASSETS.md"), "w") as f:
        f.write(HEADER + anims + TABLE_HEADER + rows +
                "\n\n_%d PNGs, %d animations across %d SpriteFrames resources._\n"
                "_Hotspot overlays are generated separately — see above._\n"
                "_Regenerate with_ `python3 tools/gen_placeholders.py`.\n"
                % (len(MANIFEST), len(ANIMS), len(set(a[0] for a in ANIMS))))
    print("generated %d PNGs + ASSETS.md" % len(MANIFEST))


if __name__ == "__main__":
    main()
