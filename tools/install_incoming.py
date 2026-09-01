#!/usr/bin/env python3
"""Copies sourced art from assets_incoming/ into assets/, at the right size.

The game reads one PNG per visual, at a fixed path and a fixed pixel size. This
resizes whatever you dropped in to that size, converts it to PNG, checks the
things that silently look wrong (a cut-out that turned out to be a solid JPEG),
and copies it across. Anything you have not replaced keeps its placeholder.

    python3 tools/install_incoming.py            # install everything found
    python3 tools/install_incoming.py --dry-run  # say what would happen
    python3 tools/install_incoming.py ui bins    # only these folders
    python3 tools/install_incoming.py --restore  # put the placeholders back

Backups of the placeholders go to assets_incoming/.placeholder_backup/ the first
time a file is overwritten, so --restore always has something to restore from.
"""
import os
import shutil
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")
INCOMING = os.path.join(ROOT, "assets_incoming")
BACKUP = os.path.join(INCOMING, ".placeholder_backup")

SOURCE_EXT = (".png", ".jpg", ".jpeg", ".webp", ".bmp", ".gif", ".tif", ".tiff", ".avif")

# How a source that is the wrong shape gets made to fit.
#
#   cover    scale until it fills, then centre-crop. Loses the edges. Right for
#            scenery and textures, where any part of the picture will do.
#   contain  scale until it fits, then pad with transparency. Loses nothing.
#            Right for a cut-out subject that must stay whole.
#   stretch  squash to the target exactly. Right for frames and full-area
#            overlays, which are meant to be resized and have no subject.
#
# Default when a file is not listed: cover for a solid slot, contain for a
# cut-out. Override here when the picture's content says otherwise - a seabed
# is a texture (cover) even though its placeholder is a cut-out.
FIT = {
    "env/tank_frame.png": "stretch",     # a frame, and the scene stretches it anyway
    "env/glass_overlay.png": "stretch",  # full-area haze, no subject to protect
    "env/seabed.png": "cover",           # ground texture, any part will do
    "env/seabed_tier_0.png": "cover",
    "env/seabed_tier_1.png": "cover",
    "env/seabed_tier_2.png": "cover",
    "env/seabed_tier_3.png": "cover",
    # bars and strips have no subject to protect and must span their whole
    # width, so letterboxing them would leave dead gaps at the ends
    "ui/meter_bg.png": "stretch",
    "ui/meter_fill.png": "stretch",
    "ui/minimap_bg.png": "stretch",
    "ui/panel_main.png": "cover",       # nine-patch plate, square to square
    # a nine-patch plate has to fill its patch exactly - letterboxing one
    # leaves transparent gutters that show up as holes in every button
    "ui/button_normal.png": "stretch",
    "ui/machine_frame.png": "stretch",  # the full canvas, scaled 1:1 to the viewport
}

# a source filed under another name, or in a subfolder of the group
ALIAS = {
    "items/box_closed.png": "boxes/Close",
    "items/box_opened.png": "boxes/Open",
    # the machine cockpit, delivered in assets_incoming/ui/ui/ under the
    # designer's own names
    "ui/machine_frame.png": "ui/main-ui",
    "ui/machine_grab.png": "ui/grab-button",
    "ui/machine_grab_pressed.png": "ui/grab-button-pressed",
    "ui/machine_left.png": "ui/left-button",
    "ui/machine_left_pressed.png": "ui/left-button-pressed",
    "ui/machine_right.png": "ui/right-button",
    "ui/machine_right_pressed.png": "ui/right-button-pressed",
    "ui/machine_sorting.png": "ui/sorting-button",
    "ui/machine_sorting_hover.png": "ui/sorting-button-hovered",
    "ui/machine_settings.png": "ui/settings",
    "ui/machine_settings_hover.png": "ui/settings-hovered",
    "ui/machine_slider.png": "ui/slider",
}

# slots trimmed to ONE shared alpha box instead of each to its own. the open
# and closed crate are the same object - crop them apart and the base jumps
# sideways the moment the lid opens.
TRIM_TOGETHER = [
    ["items/box_closed.png", "items/box_opened.png"],
    # Every cockpit part arrives on the full 2560x1440 canvas, in place. The
    # shared crop is what turns that into a sprite plus a position - and a
    # button and its pressed state MUST crop together or it jumps when pushed.
    ["ui/machine_grab.png", "ui/machine_grab_pressed.png"],
    ["ui/machine_left.png", "ui/machine_left_pressed.png"],
    ["ui/machine_right.png", "ui/machine_right_pressed.png"],
    ["ui/machine_sorting.png", "ui/machine_sorting_hover.png"],
    ["ui/machine_settings.png", "ui/machine_settings_hover.png"],
    ["ui/machine_slider.png"],
    # a group of one is just "trim this to its own subject", which is what a
    # scenery cut-out wants: the manifest size should be the coral, not the
    # coral plus whatever margin the canvas happened to have
    ["env/coral_dead.png"],
    ["env/coral_healthy.png"],
]

# Background removal leaves a haze of alpha 1-8 where it should be 0. Left in,
# it shows as a dirty rectangle over the art behind.
ALPHA_FLOOR = 8


def targets():
    """{group: {filename: (w, h)}} for every PNG the manifest lists.

    The manifest is the list the shopping-list folders are built from, so the
    two always agree. Sizes come off the file on disk, which is the size the
    game actually reads. A stray PNG in assets/ that nothing references is not
    in the manifest and is left alone."""
    import re
    md = open(os.path.join(ASSETS, "ASSETS.md")).read()
    table = md[md.index("## every PNG"):]
    out = {}
    for m in re.finditer(r"\|\s*`assets/([^/]+)/([^`]+)`", table):
        group, name = m.group(1), m.group(2)
        path = os.path.join(ASSETS, group, name)
        if not os.path.isfile(path):
            continue
        with Image.open(path) as im:
            out.setdefault(group, {})[name] = im.size
    return out


def find_source(gdir, stem, alias=None):
    """The file the designer dropped in, whatever extension they saved it as."""
    stems = [stem, stem.replace(".png", "")]
    if alias:
        stems = [alias, alias.upper(), alias.lower()] + stems
    for ext in SOURCE_EXT:
        for base in stems:
            for cand in (base + ext, base + ext.upper()):
                p = os.path.join(gdir, cand)
                if os.path.isfile(p):
                    return p
    return None


def shared_trim(group, name):
    """The alpha box to crop to, unioned over every slot in this one's group.

    Returns None when the slot trims on its own (which is everything except the
    crate pair). Sources come in with whatever dead margin the designer left
    around the subject; trimming each file separately re-centres them one by
    one, so a two-state object drifts between its states."""
    slot = "%s/%s" % (group, name)
    for members in TRIM_TOGETHER:
        if slot not in members:
            continue
        box = None
        for other in members:
            ogroup, oname = other.split("/", 1)
            src = find_source(os.path.join(INCOMING, ogroup), oname, ALIAS.get(other))
            if src is None:
                return None
            with Image.open(src) as im:
                b = im.convert("RGBA").getchannel("A").getbbox()
            if b is None:
                return None
            box = b if box is None else (min(box[0], b[0]), min(box[1], b[1]),
                                         max(box[2], b[2]), max(box[3], b[3]))
        return box
    return None


def wants_alpha(group, name):
    """True if this slot is a cut-out, decided by the placeholder it replaces.

    Group is the wrong unit: env/ holds five full-frame backgrounds AND a dozen
    cut-outs (coral, bubbles, the seabed strips, the logo, the tank frame). The
    placeholder already answers the question for every file, so ask it. Once a
    file has been replaced the backup holds the original, so read that first."""
    for base in (os.path.join(BACKUP, group, name), os.path.join(ASSETS, group, name)):
        if os.path.isfile(base):
            with Image.open(base) as im:
                return im.convert("RGBA").getchannel("A").getextrema()[0] != 255
    return True


def fit(im, size, mode):
    """Make a source of any shape into exactly `size`. Returns (image, note)."""
    tw, th = size
    sw, sh = im.size
    if mode == "stretch":
        return im.resize((tw, th), Image.LANCZOS), ""
    if mode == "contain":
        scale = min(tw / sw, th / sh)
        nw, nh = max(1, round(sw * scale)), max(1, round(sh * scale))
        out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
        out.paste(im.resize((nw, nh), Image.LANCZOS), ((tw - nw) // 2, (th - nh) // 2))
        pad = 100 - round(100 * (nw * nh) / (tw * th))
        return out, ("padded %d%%" % pad if pad >= 5 else "")
    scale = max(tw / sw, th / sh)
    nw, nh = max(1, round(sw * scale)), max(1, round(sh * scale))
    im = im.resize((nw, nh), Image.LANCZOS)
    left, top = (nw - tw) // 2, (nh - th) // 2
    lost = 100 - round(100 * (tw * th) / (nw * nh))
    return im.crop((left, top, left + tw, top + th)), ("cropped %d%%" % lost if lost >= 5 else "")


def main():
    args = [a for a in sys.argv[1:]]
    dry = "--dry-run" in args
    restore = "--restore" in args
    only = [a for a in args if not a.startswith("--")]

    if restore:
        n = 0
        for group in sorted(os.listdir(BACKUP)) if os.path.isdir(BACKUP) else []:
            if only and group not in only:
                continue
            for name in sorted(os.listdir(os.path.join(BACKUP, group))):
                shutil.copy2(os.path.join(BACKUP, group, name),
                             os.path.join(ASSETS, group, name))
                n += 1
        print("restored %d placeholder%s" % (n, "" if n == 1 else "s"))
        print("run `godot --headless --import` so Godot picks them up")
        return

    tgt = targets()
    installed = warned = missing = 0
    for group, files in sorted(tgt.items()):
        if only and group not in only:
            continue
        gdir = os.path.join(INCOMING, group)
        if not os.path.isdir(gdir):
            continue
        done = []
        for name, size in sorted(files.items()):
            src = find_source(gdir, name, ALIAS.get("%s/%s" % (group, name)))
            if src is None:
                missing += 1
                continue
            try:
                im = Image.open(src)
            except Exception as e:
                print("  SKIP  %s/%s - cannot read %s (%s)"
                      % (group, name, os.path.basename(src), e))
                warned += 1
                continue
            im = im.convert("RGBA")
            trim = shared_trim(group, name)
            if trim is not None:
                im = im.crop(trim)
            note = ""
            got_alpha = im.getchannel("A").getextrema()[0] != 255
            mode = FIT.get("%s/%s" % (group, name),
                           "contain" if wants_alpha(group, name) else "cover")
            # An explicit cover override means the picture is a texture rather
            # than a subject. A floor looks right either way, so neither warn
            # nor force it - "either" is a real answer, not a missing one.
            policy = ("either" if "%s/%s" % (group, name) in FIT and mode == "cover"
                      else "need" if wants_alpha(group, name) else "none")
            if policy == "need" and not got_alpha:
                note = "  <- no transparency; will show as a solid rectangle"
                warned += 1
            elif policy == "none" and got_alpha:
                note = "  <- see-through, but this slot is a solid background"
                warned += 1
            out, fitnote = fit(im, size, mode)
            if policy != "none":
                # kill the background-removal haze so it does not show as a
                # dirty rectangle over whatever is behind it
                a = out.getchannel("A").point(lambda v: 0 if v <= ALPHA_FLOOR else v)
                out.putalpha(a)
            elif out.getchannel("A").getextrema()[0] != 255:
                flat = Image.new("RGBA", out.size, (0, 0, 0, 255))
                flat.alpha_composite(out)
                out = flat
            dst = os.path.join(ASSETS, group, name)
            if not dry:
                bdir = os.path.join(BACKUP, group)
                os.makedirs(bdir, exist_ok=True)
                if not os.path.exists(os.path.join(bdir, name)):
                    shutil.copy2(dst, os.path.join(bdir, name))
                out.save(dst)
            bits = " ".join(x for x in (mode, fitnote) if x)
            done.append("  %-26s %-26s %-9s %-18s%s"
                        % (name, os.path.basename(src),
                           "%dx%d" % (size[0], size[1]), bits, note))
            installed += 1
        if done:
            print("%s/" % group)
            print("\n".join(done))

    verb = "would install" if dry else "installed"
    print("\n%s %d, %d still on placeholders" % (verb, installed, missing))
    if warned:
        print("%d warning%s above - those will look wrong in game"
              % (warned, "" if warned == 1 else "s"))
    if installed and not dry:
        print("\nnow run:  godot --headless --import")
        print("then:     ./tools/smoke/run_all.sh")
        print("undo:     python3 tools/install_incoming.py --restore")


if __name__ == "__main__":
    main()
