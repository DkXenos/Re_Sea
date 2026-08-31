#!/usr/bin/env python3
"""Writes data/days/day_*.tres from data/days.json.

The JSON is the file a human edits: readable ids, one line per day, easy to
diff. The .tres files are what Godot loads, and are treated as build output -
do not hand-edit them, your change will be overwritten by the next run.

    python3 tools/gen_days.py            # rewrite every day
    python3 tools/gen_days.py --check    # fail if any .tres is out of date

smoke_content.gd runs --check, so the two can never silently drift apart.
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "data")

TEMPLATE = """[gd_resource type="Resource" script_class="DayData" format=3]

{ext}
[resource]
script = ExtResource("{day_script}")
day_number = {day}
active_rules = Array[ExtResource("{rule_script}")]([{rules}])
item_pool = Array[ExtResource("{item_script}")]([{items}])
{box}quota = {quota}
budget = {budget}
available_tools = Array[StringName]([{tools}])
initial_seed_fraction = {seed_fraction}
spawn_interval_min = {spawn_min}
spawn_interval_max = {spawn_max}
min_available_items = {min_items}
{modifier}intro_text = {intro}
"""


# ---------------------------------------------------------------- item mixing

# Bin names as written in days.json, in ItemData.Category order.
CATEGORIES = ["organic", "recyclable", "hazard", "landfill"]

# Residues that r_chem_residue escalates to B3. Kept in step with
# data/rules/r_chem_residue.tres - smoke_tech re-checks supply using the real
# GDScript RuleChecker, so a drift here shows up there rather than silently.
CHEM_RESIDUES = ("engine oil", "solvent-based paint", "expired medicine")


def _field(text, key):
    m = re.search(r"^%s = (.+)$" % key, text, re.M)
    return m.group(1).strip() if m else None


def item_facts():
    """{id: {...}} for every item, read straight off the .tres files."""
    out = {}
    for path in sorted(glob.glob(os.path.join(DATA, "items", "*.tres"))):
        item_id = os.path.basename(path)[:-5]
        text = open(path).read()
        residue = (_field(text, "residue_type") or "").strip('"')
        out[item_id] = {
            "category": int(_field(text, "correct_category") or 0),
            "has_residue": _field(text, "has_residue") == "true",
            "multilayer": _field(text, "is_multilayer") == "true",
            "container": _field(text, "is_container") == "true",
            "chem": residue in CHEM_RESIDUES,
        }
    return out


def resolve_category(facts, rules):
    """Mirror of RuleChecker.resolve for the rules that force a bin."""
    category = facts["category"]
    if "r_residue" in rules and facts["has_residue"]:
        category = 3
    if "r_multilayer" in rules and facts["multilayer"]:
        category = 3
    if "r_chem_residue" in rules and facts["chem"]:
        category = 2
    return category


def expand_mix(day, facts):
    """A mix of bin counts -> a concrete, stable list of item ids.

    Round-robins through the eligible items in id order, so asking for 5
    ORGANIK spreads across five different items before repeating one, and the
    same JSON always produces the same list.
    """
    mix = day["mix"]
    unknown = [k for k in mix if k not in CATEGORIES]
    if unknown:
        raise SystemExit("day %d: unknown bin %s (expected %s)"
                         % (day["day"], unknown, CATEGORIES))
    rules = day["rules"]
    chosen = []
    for index, name in enumerate(CATEGORIES):
        want = int(mix.get(name, 0))
        if want <= 0:
            continue
        pool = [i for i in sorted(facts)
                if not facts[i]["container"]
                and resolve_category(facts[i], rules) == index]
        exclude = set(day.get("exclude", []))
        pool = [i for i in pool if i not in exclude]
        if not pool:
            raise SystemExit(
                "day %d asks for %d %s but no item resolves to that bin under "
                "rules %s" % (day["day"], want, name.upper(), rules))
        chosen += [pool[n % len(pool)] for n in range(want)]
    return chosen


def items_for(day, facts):
    """Explicit list wins; otherwise expand the mix."""
    if day.get("items") is not None:
        return day["items"]
    if day.get("mix") is not None:
        return expand_mix(day, facts)
    raise SystemExit("day %d has neither 'items' nor 'mix'" % day["day"])


def q(s):
    """Godot .tres strings: double quotes, backslash-escaped."""
    return '"%s"' % s.replace("\\", "\\\\").replace('"', '\\"')


def build(day, facts):
    ext, ids = [], {}

    def add(kind, path):
        if path in ids:
            return ids[path]
        rid = "%d_%s" % (len(ext) + 1, os.path.basename(path).split(".")[0])
        ids[path] = rid
        ext.append('[ext_resource type="%s" path="res://%s" id="%s"]' % (kind, path, rid))
        return rid

    rule_script = add("Script", "data/rule_data.gd")
    rules = [add("Resource", "data/rules/%s.tres" % r) for r in day["rules"]]
    item_script = add("Script", "data/item_data.gd")
    items = [add("Resource", "data/items/%s.tres" % i)
             for i in items_for(day, facts)]
    box = day.get("box") or {}
    box_lines = ""
    if box.get("item"):
        bid = add("Resource", "data/items/%s.tres" % box["item"])
        box_lines = ('box_item = ExtResource("%s")\n'
                     "box_spawn_count = %d\n"
                     "box_contents_min = %d\n"
                     "box_contents_max = %d\n"
                     % (bid, box.get("count", 0), box.get("contents_min", 2),
                        box.get("contents_max", 3)))
    day_script = add("Script", "data/day_data.gd")

    sp = day["spawning"]
    return TEMPLATE.format(
        ext="\n".join(ext) + "\n",
        day_script=day_script, rule_script=rule_script, item_script=item_script,
        day=day["day"],
        rules=", ".join('ExtResource("%s")' % r for r in rules),
        items=", ".join('ExtResource("%s")' % i for i in items),
        box=box_lines, quota=day["quota"], budget=day["budget"],
        tools=", ".join("&%s" % q(t) for t in day["tools"]),
        seed_fraction=sp["initial_seed_fraction"],
        spawn_min=sp["spawn_interval_min"], spawn_max=sp["spawn_interval_max"],
        min_items=sp["min_available_items"],
        modifier=("modifier = %s\n" % q(day["modifier"])) if day.get("modifier") else "",
        intro=q(day["intro_text"]))


def main():
    check = "--check" in sys.argv
    spec = json.load(open(os.path.join(DATA, "days.json")))
    facts = item_facts()
    stale = []
    for day in spec["days"]:
        path = os.path.join(DATA, "days", "day_%02d.tres" % day["day"])
        text = build(day, facts)
        current = open(path).read() if os.path.exists(path) else None
        if check:
            if current != text:
                stale.append(os.path.relpath(path, ROOT))
            continue
        if current != text:
            open(path, "w").write(text)
            print("  wrote %s" % os.path.relpath(path, ROOT))
        else:
            print("  ok    %s" % os.path.relpath(path, ROOT))
    if check:
        if stale:
            print("out of date with data/days.json:\n  " + "\n  ".join(stale))
            print("run: python3 tools/gen_days.py")
            sys.exit(1)
        print("every day_*.tres matches data/days.json")


if __name__ == "__main__":
    main()
