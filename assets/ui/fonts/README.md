# Fonts

**Fredoka**, by Milena Brandao and Hafontia. Licensed under the SIL Open Font
License 1.1 — the full text is in `OFL.txt` beside this file, and `README.txt`
is the family's own readme as downloaded. The licence permits bundling the font
inside a game, including a commercial one, as long as the licence travels with
it. It is the only third-party asset in the project, and it is credited in
section 3.3 of the proposal.

Two weights ship in the build:

| File | Used for |
|---|---|
| `Fredoka-Medium.ttf` | every label, the theme's `default_font` |
| `Fredoka-SemiBold.ttf` | buttons and the numbers on the cockpit plates |

The other 23 weights of the family (Light through Bold, Condensed through
Expanded) are not in the project. They live in
`~/Re-Sea-art-masters/fonts/Fredoka-full-family/` so the build does not carry
1.5 MB of unused typefaces. Pull one back in only if a screen actually needs it.
