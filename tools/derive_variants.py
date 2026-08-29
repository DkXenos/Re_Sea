#!/usr/bin/env python3
"""Generates the state art the designers did not supply, from the art they did.

The project's rule is that state is a different drawing, never a tint applied at
runtime (see assets/ASSETS.md). That rule is about the *game* never recolouring
art. Deriving a second PNG here, once, at build time is how you honour it when
only one drawing exists: the game still just picks a file.

Every variant below is regenerated from its base, so re-running this after the
designers deliver a new base keeps the set consistent.

    python3 tools/derive_variants.py [panels|bins|joystick|buttons ...]
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
A = os.path.join(ROOT, "assets")


def load(rel):
    return Image.open(os.path.join(A, rel)).convert("RGBA")


def save(im, rel, why):
    im.save(os.path.join(A, rel))
    print("  %-32s %s" % (rel, why))


def relevel(im, mul, add=0):
    """Scale RGB, keep alpha. Cheaper than a hue shift and keeps the material."""
    a = np.array(im).astype(np.float32)
    a[..., :3] = np.clip(a[..., :3] * mul + add, 0, 255)
    return Image.fromarray(a.astype(np.uint8), "RGBA")


def edge_glow(im, colour, width=3):
    """A ring just inside the panel border, so a state reads without a tint."""
    out = im.copy()
    d = ImageDraw.Draw(out)
    w, h = out.size
    for i in range(width):
        d.rectangle([2 + i, 2 + i, w - 3 - i, h - 3 - i], outline=colour, width=1)
    return out


# ---------------------------------------------------------------- panels
def panels():
    """panel_main is the only plate supplied. The other three are the same
    material at different depths, which is what the UI actually means by them."""
    base = load("ui/panel_main.png")
    save(relevel(base, 0.55), "ui/panel_dark.png",
         "panel_main at 55% brightness - modal/overlay backing")
    save(relevel(base, 0.78), "ui/panel_slot.png",
         "panel_main at 78% - inventory slot, reads as recessed")
    sel = relevel(base, 1.25)
    save(edge_glow(sel, (150, 214, 245, 255), 3), "ui/panel_slot_selected.png",
         "brighter plate + pale blue inner ring - selected slot")


# ---------------------------------------------------------------- buttons
def buttons():
    """Only button_normal was supplied, so the other three states are that same
    plate re-lit: brighter when the pointer is over it, darker and flatter when
    it is held, washed out when it cannot be pressed."""
    base = load("ui/button_normal.png")
    for name, mul, add in (("hover", 1.12, 8),
                           ("pressed", 0.78, -6),
                           ("disabled", 0.62, 0)):
        out = relevel(base, mul, add)
        if name == "disabled":
            # the plate is already grey, so draining colour does nothing. Flatten
            # the bevel instead: a button with no raised edge reads as dead even
            # at a glance, which dimming alone does not achieve.
            a = np.array(out).astype(np.float32)
            flat = a[..., :3].mean()
            a[..., :3] = a[..., :3] * 0.35 + flat * 0.65
            out = Image.fromarray(a.astype(np.uint8), "RGBA")
        save(out, "ui/button_%s.png" % name,
             "button_normal re-lit to %.0f%%%s - %s state"
             % (mul * 100, ", bevel flattened" if name == "disabled" else "", name))


# ---------------------------------------------------------------- bins
def bins():
    """Each bin arrived as one drawing; the game plays four animations on it.

    highlight = lit and haloed, accept = green tick, reject = red cross. Badges
    rather than tints, so the state survives whatever colour the bin is."""
    for cat in ("organic", "recyclable", "hazard", "landfill"):
        base = load("bins/bin_%s.png" % cat)
        w, h = base.size

        halo = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        halo.paste((255, 245, 190, 255), (0, 0), base.getchannel("A"))
        halo = halo.filter(ImageFilter.GaussianBlur(7))
        lit = Image.alpha_composite(halo, ImageEnhance.Brightness(base).enhance(1.22))
        save(lit, "bins/bin_%s_highlight.png" % cat, "warm halo + 22% brighter")

        for state, colour, glyph in (("accept", (74, 190, 116), "tick"),
                                     ("reject", (214, 76, 66), "cross")):
            im = ImageEnhance.Brightness(base).enhance(1.05 if state == "accept" else 0.85)
            im = im.convert("RGBA")
            d = ImageDraw.Draw(im)
            r = int(min(w, h) * 0.19)
            cx, cy = w - r - 6, r + 6
            d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=colour + (255,),
                      outline=(255, 255, 255, 255), width=max(2, r // 8))
            k = r * 0.5
            if glyph == "tick":
                d.line([(cx - k, cy), (cx - k * 0.2, cy + k * 0.7), (cx + k, cy - k * 0.7)],
                       fill=(255, 255, 255, 255), width=max(3, r // 5), joint="curve")
            else:
                d.line([(cx - k, cy - k), (cx + k, cy + k)], fill=(255, 255, 255, 255), width=max(3, r // 5))
                d.line([(cx - k, cy + k), (cx + k, cy - k)], fill=(255, 255, 255, 255), width=max(3, r // 5))
            save(im, "bins/bin_%s_%s.png" % (cat, state),
                 "%s badge - bin took it" % glyph if state == "accept" else "%s badge - bin refused" % glyph)


# ---------------------------------------------------------------- joystick
def joystick():
    """One joystick drawing was supplied, and the designers said a separate knob
    is not needed. The scene still has a knob node, so make it draw nothing
    rather than leaving the old placeholder ball floating over the new stick."""
    blank = Image.new("RGBA", (72, 72), (0, 0, 0, 0))
    save(blank, "ui/joystick_knob.png", "intentionally empty - joystick_base is the whole control")


GROUPS = {"panels": panels, "bins": bins, "joystick": joystick, "buttons": buttons}

if __name__ == "__main__":
    want = [a for a in sys.argv[1:] if not a.startswith("-")] or list(GROUPS)
    for g in want:
        if g not in GROUPS:
            sys.exit("unknown group %r; have: %s" % (g, ", ".join(GROUPS)))
        print("%s:" % g)
        GROUPS[g]()
