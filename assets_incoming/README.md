# Replacement art — drop-in folders

134 pictures replace every visual in the game. Each folder below has its
own README listing the exact filenames it wants, the size, and what kind of
picture fits.

| Folder | What | Files | Background |
|--------|------|-------|------------|
| [`bins/`](bins/README.md) | Sorting bins | 16 | transparent cut-out |
| [`claw/`](claw/README.md) | The claw | 5 | transparent cut-out |
| [`env/`](env/README.md) | Backgrounds and scenery | 17 | **mixed — check each row** |
| [`fish/`](fish/README.md) | Background fish | 3 | transparent cut-out |
| [`items/`](items/README.md) | Trash items | 16 | transparent cut-out |
| [`tools/`](tools/README.md) | Inspection tools | 12 | transparent cut-out |
| [`ui/`](ui/README.md) | Interface chrome | 65 | **mixed — check each row** |

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
