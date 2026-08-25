"""Drawing parameters for the placeholder art. No game content in here.

The .tres files in data/ are the only source of truth for anything the game
reads - item properties, hotspots, rules, tools, days. This is just what a
placeholder drawing needs (shape, colour, a 2-3 letter code) and it's dead
the moment real art shows up.

Hotspot rings are no longer drawn here at all. They are a separate overlay PNG
per item, generated from the `.tres` by `tools/gen_hotspot_overlays.gd`, so the
rings can never disagree with the coordinates the game checks against.
"""

# id -> how to draw its placeholder. Ids must match data/items/<id>.tres.
# Shape and colour only: nothing is written on an item any more. A code stamped
# on the art told the player the material for free, which is the one thing the
# inspect phase is supposed to make them work for.
ITEM_ART = [
    dict(id="banana_peel", shape="peel", color=(232, 197, 71)),
    dict(id="fish_bone", shape="bone", color=(237, 230, 214)),
    dict(id="pet_bottle", shape="bottle", color=(127, 212, 232)),
    dict(id="alu_can", shape="can", color=(201, 205, 212)),
    dict(id="styrofoam_tray", shape="tray", color=(242, 242, 242)),
    dict(id="car_battery", shape="box", color=(74, 85, 104)),
    dict(id="oil_jerrycan", shape="jerrycan", color=(143, 212, 143)),
    dict(id="paint_bottle", shape="bottle", color=(183, 201, 232)),
    dict(id="juice_carton", shape="carton", color=(224, 122, 95)),
    dict(id="eco_tote", shape="tote", color=(163, 177, 138)),
    dict(id="paper_cup", shape="cup", color=(244, 225, 193)),
    dict(id="spray_can", shape="spray", color=(176, 183, 195)),
    dict(id="glass_jar", shape="jar", color=(111, 168, 160)),
    dict(id="fishing_net", shape="net", color=(62, 124, 177)),
]

# Icon colours only. ToolData.color in data/tools/*.tres is authoritative for
# anything the game itself renders.
TOOL_ART = [
    dict(id="rinse", name="Bilas", color=(96, 178, 230)),
    dict(id="swab", name="Usap Kimia", color=(214, 120, 200)),
    dict(id="magnifier", name="Kaca Pembesar", color=(240, 200, 84)),
    dict(id="cutter", name="Pemotong", color=(226, 106, 92)),
]

# background only, no collision, no grab
FISH = [("fish_bg_small", 96, 48, (244, 162, 97)),
        ("fish_bg_medium", 128, 64, (231, 111, 81)),
        ("fish_bg_large", 176, 88, (140, 196, 180))]

BINS = [("organic", (106, 153, 78)), ("recyclable", (58, 134, 183)),
        ("hazard", (198, 76, 65)), ("landfill", (120, 113, 108))]

# tier seabeds: floor colour, ridge colour, where the rocks sit. 0 is murky
# and cluttered, 3 is bright and open. thresholds/counts are in data/tiers/.
TIER_SEABED = [
    ((66, 60, 44), (88, 80, 58), [(120, 34), (300, 30), (420, 22), (560, 36),
                                  (700, 40), (880, 18)]),
    ((74, 70, 52), (100, 94, 68), [(120, 34), (420, 22), (700, 40), (880, 18)]),
    ((88, 92, 66), (118, 124, 86), [(160, 28), (520, 24), (820, 30)]),
    ((104, 118, 84), (140, 158, 108), [(200, 22), (760, 26)]),
]


# blueprint diagram art. shape and colour only - what a component COSTS is
# game content and lives in data/components/*.tres.
#
# The sheet colour is per blueprint so three schematics are told apart at a
# glance; the components are drawn in colour for `done` and in the greyscale of
# that same colour for `locked`, as two separate PNGs.
BLUEPRINT_SHEETS = [
    dict(id="cleaner_drone", color=(26, 62, 104)),
    dict(id="penyaring_mikroplastik", color=(22, 66, 88)),
    dict(id="penetral_b3", color=(48, 46, 92)),
]

COMPONENT_ART = [
    dict(id="drone_body", shape="hull", color=(126, 196, 232)),
    dict(id="bio_core", shape="core", color=(140, 214, 150)),
    dict(id="intake_fin", shape="fin", color=(232, 190, 108)),
    dict(id="filter_mesh", shape="mesh", color=(128, 206, 214)),
    dict(id="pump_housing", shape="pump", color=(214, 154, 120)),
    dict(id="collection_tank", shape="tank", color=(154, 186, 232)),
    dict(id="sealed_chamber", shape="chamber", color=(196, 132, 124)),
    dict(id="neutralizer_cell", shape="cell", color=(178, 156, 224)),
    dict(id="safety_valve", shape="valve", color=(226, 206, 120)),
]
