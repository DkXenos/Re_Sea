#!/usr/bin/env python3
"""Builds the shareable asset board (one self-contained HTML page).

Every picture on the page is the real PNG from assets/, embedded as a data URI,
so the board can never show something the game does not actually load. Sizes,
descriptions and animation notes come from assets/ASSETS.md; transparency is
measured off each file rather than assumed.

    python3 tools/make_asset_board.py [out.html]
"""
import base64
import io
import json
import os
import re
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")

# Mirrors tools/make_shopping_list.py - the search advice the designers get.
GROUPS = {
    "items":  ("Trash items", "The litter you fish out. One object, straight-on, filling the frame.",
               "Search the object name plus <em>png transparent</em> or <em>cutout</em>."),
    "bins":   ("Sorting bins", "Four colours, each with three reaction states.",
               "The four must read as four different colours instantly — that is the mechanic."),
    "tools":  ("Inspection tools", "Handheld tools, each with a locked and unlocked version.",
               "Shown at 60px in the rack, so pick a bold silhouette."),
    "claw":   ("The claw", "The grabber, in four states, plus its cable.",
               "All four must read as the same claw or it looks like it teleports."),
    "fish":   ("Background fish", "Decoration swimming past behind everything.",
               "Side profile, simple, darker than the water."),
    "env":    ("Backgrounds & scenery", "The only opaque files — they fill the whole frame.",
               "Keep them dim; everything else is drawn on top and has to stay readable."),
    "ui":     ("Interface chrome", "Buttons, panels, icons, sliders, scrollbars.",
               "Most of these get stretched. Watch for the 9-slice badge."),
}
ORDER = ["items", "bins", "tools", "claw", "fish", "env", "ui"]


def manifest():
    md = open(os.path.join(ASSETS, "ASSETS.md")).read()
    table = md[md.index("## every PNG"):]
    for line in table.splitlines():
        m = re.match(r"\|\s*`assets/([^/]+)/([^`]+)`\s*\|\s*(\S+)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|$", line)
        if m:
            yield dict(group=m.group(1), name=m.group(2), size=m.group(3),
                       anim=m.group(4), desc=m.group(5))


def thumb(path, cap=320):
    """Full art, capped on the long edge so the page stays small."""
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    if max(w, h) > cap:
        s = cap / max(w, h)
        im = im.resize((max(1, round(w * s)), max(1, round(h * s))), Image.LANCZOS)
    buf = io.BytesIO()
    im.save(buf, "PNG", optimize=True)
    return base64.b64encode(buf.getvalue()).decode("ascii")


def build():
    rows = []
    for e in manifest():
        if e["name"].startswith("hotspots_"):
            continue
        path = os.path.join(ASSETS, e["group"], e["name"])
        if not os.path.isfile(path):
            continue
        im = Image.open(path).convert("RGBA")
        opaque = im.getchannel("A").getextrema()[0] == 255
        nine = re.search(r"(\d+)px margins", e["desc"])
        anim = None
        if e["anim"] != "static":
            anim = re.sub(r"`", "", e["anim"])
        rows.append(dict(
            g=e["group"], n=e["name"], sz=e["size"],
            d=re.sub(r"\s*NinePatch(Rect)?[^.]*\.", "", e["desc"]).strip(),
            cut=not opaque, np=int(nine.group(1)) if nine else 0,
            an=anim, b=thumb(path)))
    return rows


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "asset_board.html")
    rows = build()
    groups = [dict(k=k, t=GROUPS[k][0], s=GROUPS[k][1], w=GROUPS[k][2],
                   n=sum(1 for r in rows if r["g"] == k))
              for k in ORDER if any(r["g"] == k for r in rows)]
    html = TEMPLATE.replace("__DATA__", json.dumps(rows, separators=(",", ":"))) \
                   .replace("__GROUPS__", json.dumps(groups, separators=(",", ":"))) \
                   .replace("__TOTAL__", str(len(rows)))
    with open(out, "w") as f:
        f.write(html)
    print("%s  (%d assets, %.1f MB)" % (out, len(rows), os.path.getsize(out) / 1e6))


TEMPLATE = open(os.path.join(ROOT, "tools", "asset_board_template.html")).read() \
    if os.path.exists(os.path.join(ROOT, "tools", "asset_board_template.html")) else ""

if __name__ == "__main__":
    if not TEMPLATE:
        sys.exit("missing tools/asset_board_template.html")
    main()
