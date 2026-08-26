# Sorting bins — 16 files

A wheelie bin / waste container, straight-on, lid closed. Four colours, and each needs three extra states (see the file list).

Every file here is **a cut-out with a transparent background**.

## How to use this folder

1. Find a picture for a row below.
2. Save it here with **exactly the filename in the first column**.
3. Any size is fine — `tools/install_incoming.py` resizes to the target for you.
   Match the shape (square vs wide) or it will look squashed.
4. When you have some or all of them, run from the project root:

       python3 tools/install_incoming.py

   It checks every file, resizes it, copies it into `assets/bins/`, and
   tells you what is still missing. Files you have not replaced keep their
   current placeholder.

## Watch out

- The four bins must read as four different colours at a glance - that is the whole game mechanic.
- `_highlight`, `_accept` and `_reject` are separate pictures, not the same bin recoloured. A glow, a green tick, a red cross - whatever reads fast.

## The files

| Save it as | Size | Background | What it is |
|------------|------|------------|------------|
| `bin_organic.png` | 200x240 | cut-out | organic bin, idle state |
| `bin_organic_accept.png` | 200x240 | cut-out | organic bin, accept state |
| `bin_organic_reject.png` | 200x240 | cut-out | organic bin, reject state |
| `bin_organic_highlight.png` | 200x240 | cut-out | organic bin, highlight state |
| `bin_recyclable.png` | 200x240 | cut-out | recyclable bin, idle state |
| `bin_recyclable_accept.png` | 200x240 | cut-out | recyclable bin, accept state |
| `bin_recyclable_reject.png` | 200x240 | cut-out | recyclable bin, reject state |
| `bin_recyclable_highlight.png` | 200x240 | cut-out | recyclable bin, highlight state |
| `bin_hazard.png` | 200x240 | cut-out | hazard bin, idle state |
| `bin_hazard_accept.png` | 200x240 | cut-out | hazard bin, accept state |
| `bin_hazard_reject.png` | 200x240 | cut-out | hazard bin, reject state |
| `bin_hazard_highlight.png` | 200x240 | cut-out | hazard bin, highlight state |
| `bin_landfill.png` | 200x240 | cut-out | landfill bin, idle state |
| `bin_landfill_accept.png` | 200x240 | cut-out | landfill bin, accept state |
| `bin_landfill_reject.png` | 200x240 | cut-out | landfill bin, reject state |
| `bin_landfill_highlight.png` | 200x240 | cut-out | landfill bin, highlight state |
