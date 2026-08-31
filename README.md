# Cakar Laut

Underwater claw machine + waste sorting. Godot 4.

You run a claw machine that pulls trash off the seabed, then sort what you got
into four bins. The catch is you can't tell what most things are by looking at
them - you have to spend budget on tools (magnifier, cutter, swab, rinse) to
find out, and the rules change every day. There is no score: only what you put
in the right bin becomes material for the machines you're trying to build.

Five days. One budget per day, spent by actions (drop 6, tool 4, sort 1). No
timer.

## running it

Open in Godot 4.x and press play. `main.tscn` is the entry point.

F1 for the debug overlay in debug builds - skip days, refill budget, force the
grip roll, fill the inventory.

## layout

```
autoload/   Events (signal bus) + Game (run state)
data/       Resource classes and the .tres content
scenes/     claw, desk, shift, report, after_day, menus
systems/    rule checking, flow graph, settings
assets/     all the art and sound (see ASSETS.md)
tools/      placeholder generators + headless checks
```

Content lives in `data/*.tres`, not in code. Adding an item or a rule shouldn't
need a code change.

Text is English, in `data/strings.gd`.

See NOTES.md for the rules I keep breaking.

## state

Prototype. Art is all placeholder - real sprites are coming from two designers,
which is why everything is a PNG loaded from a fixed path.
