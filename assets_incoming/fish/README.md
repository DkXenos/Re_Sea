# Background fish — 3 files

A side-on fish silhouette, three sizes. Decoration only - it swims past behind everything.

Every file here is **a cut-out with a transparent background**.

## How to use this folder

1. Find a picture for a row below.
2. Save it here with **exactly the filename in the first column**.
3. Any size is fine — `tools/install_incoming.py` resizes to the target for you.
   Match the shape (square vs wide) or it will look squashed.
4. When you have some or all of them, run from the project root:

       python3 tools/install_incoming.py

   It checks every file, resizes it, copies it into `assets/fish/`, and
   tells you what is still missing. Files you have not replaced keep their
   current placeholder.

## Watch out

- Side profile, facing left or right, not head-on.
- Keep it simple and darker than the water; these sit far back.

## The files

| Save it as | Size | Background | What it is |
|------------|------|------------|------------|
| `fish_bg_small.png` | 96x48 | cut-out | Background fish. Not grabbable - atmosphere only |
| `fish_bg_medium.png` | 128x64 | cut-out | Background fish. Not grabbable - atmosphere only |
| `fish_bg_large.png` | 176x88 | cut-out | Background fish. Not grabbable - atmosphere only |
