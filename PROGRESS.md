# Progress

Running notes for the owner. One line per item, newest revision at the top.

---

## Revision 4

### Needs human — decisions I did not make for you

- **Should opening a box cost budget?** It costs **0** right now, exactly as the
  brief specified. The price of a box is the sorting time of what comes out of
  it: a drop costs 6 and yields 2–3 items instead of 1, so a box is currently a
  strict win on budget-per-item. If that reads as too generous, the cost belongs
  in `Game.ACTION_COST` as a fourth action, not as a number invented here.
- **Box spawn counts per day.** Day 1 → 0 (tutorial stays clean), days 2–5 →
  1, 1, 2, 2, contents 2–3, all as suggested in the brief and all untested
  against a human player. They live in `data/days/day_0*.tres` as
  `box_spawn_count` / `box_contents_min` / `box_contents_max`.
- **Real art for the box.** `assets/items/box_closed.png` and
  `box_opened.png`, 160×160, flat. Two drawings, never a tint — the card swaps
  the PNG.

### Noticed while working, not acted on

- `PROGRESS.md` and `WALKTHROUGH.md` did not exist in the repo when revision 4
  started, though the brief opens by asking that both be read. This file is new;
  there is still no walkthrough.
- A box left sealed when the shift ends is dropped silently — it is not in the
  day report and not in the after-day haul, because an unopened box never
  became items. Worth a line on the report if playtests show people forgetting
  them.
