#!/usr/bin/env python3
"""Removes a flat background from an image, leaving a transparent cut-out.

Works by flooding inward from the edges, so a colour that also appears *inside*
the subject is kept - clearing "every pixel near this colour" would punch holes
through white paper, chrome highlights and sky reflections.

Only for flat or near-flat backgrounds: chroma-key green, a studio white sweep,
the grey plate behind a scanned drawing. A subject photographed against a real
cluttered scene needs a segmentation model, which is not installed here.

    python3 tools/cutout.py IMAGE [IMAGE...] [--tol 30] [--feather 1] [--inplace]

Writes <name>_cut.png next to each input unless --inplace is given.
"""
import os
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageFilter


def cut(path, tol=30, feather=1):
    im = Image.open(path).convert("RGBA")
    rgb = np.array(im.convert("RGB"), dtype=np.int16)
    h, w, _ = rgb.shape

    # the background colour is whatever the four corners agree on
    corners = [rgb[0, 0], rgb[0, w - 1], rgb[h - 1, 0], rgb[h - 1, w - 1]]
    key = np.median(np.stack(corners), axis=0)
    near = np.abs(rgb - key).sum(axis=2) <= tol

    # flood from every edge pixel that matches, 4-connected
    bg = np.zeros((h, w), dtype=bool)
    q = deque()
    for x in range(w):
        for y in (0, h - 1):
            if near[y, x] and not bg[y, x]:
                bg[y, x] = True; q.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if near[y, x] and not bg[y, x]:
                bg[y, x] = True; q.append((y, x))
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and near[ny, nx] and not bg[ny, nx]:
                bg[ny, nx] = True; q.append((ny, nx))

    alpha = np.where(bg, 0, 255).astype(np.uint8)
    a = Image.fromarray(alpha, "L")
    if feather:
        # one pass of blur kills the hard jaggies the flood leaves behind
        a = a.filter(ImageFilter.GaussianBlur(feather))
    out = im.copy()
    out.putalpha(a)

    # chroma green bleeds into the subject's edge pixels; pull it back so the
    # cut-out does not carry a green halo onto a dark background
    if key[1] > 150 and key[1] - key[0] > 60 and key[1] - key[2] > 30:
        arr = np.array(out)
        edge = (arr[..., 3] > 0) & (arr[..., 3] < 250)
        g = arr[..., 1].astype(np.int16)
        cap = np.maximum(arr[..., 0], arr[..., 2]).astype(np.int16)
        fix = edge & (g > cap + 10)
        arr[..., 1] = np.where(fix, cap, g).astype(np.uint8)
        out = Image.fromarray(arr, "RGBA")
    return out, float((alpha == 0).mean())


def main():
    args = sys.argv[1:]
    tol = int(args[args.index("--tol") + 1]) if "--tol" in args else 30
    feather = float(args[args.index("--feather") + 1]) if "--feather" in args else 1.0
    inplace = "--inplace" in args
    files = [a for i, a in enumerate(args)
             if not a.startswith("--") and (i == 0 or args[i - 1] not in ("--tol", "--feather"))]
    if not files:
        sys.exit(__doc__)
    for f in files:
        out, frac = cut(f, tol, feather)
        dst = f if inplace else os.path.splitext(f)[0] + "_cut.png"
        out.save(dst)
        print("  %-42s %.0f%% removed -> %s" % (os.path.basename(f), frac * 100, os.path.basename(dst)))


if __name__ == "__main__":
    main()
