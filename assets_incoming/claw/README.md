# The claw — 5 files

An arcade grabber claw, seen from the front. Four states: open, closing, closed, carrying - plus the cable.

Every file here is **a cut-out with a transparent background**.

## How to use this folder

1. Find a picture for a row below.
2. Save it here with **exactly the filename in the first column**.
3. Any size is fine — `tools/install_incoming.py` resizes to the target for you.
   Match the shape (square vs wide) or it will look squashed.
4. When you have some or all of them, run from the project root:

       python3 tools/install_incoming.py

   It checks every file, resizes it, copies it into `assets/claw/`, and
   tells you what is still missing. Files you have not replaced keep their
   current placeholder.

## Watch out

- All four should be recognisably the SAME claw, or it will look like it teleports between frames. Best sourced as one image you crop/rotate four ways.
- `claw_cable.png` is a vertical cable that gets stretched - a flat rope or chain, no perspective.

## The files

| Save it as | Size | Background | What it is |
|------------|------|------------|------------|
| `claw_open.png` | 160x160 | cut-out | Claw arm, open pose |
| `claw_closing.png` | 160x160 | cut-out | Claw arm, closing pose |
| `claw_closed.png` | 160x160 | cut-out | Claw arm, closed pose |
| `claw_carrying.png` | 160x160 | cut-out | Claw arm, carrying pose |
| `claw_cable.png` | 8x64 | cut-out | Cable, stretched vertically from rail to claw |
