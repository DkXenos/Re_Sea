"""Drawing parameters for the placeholder art. **No game content lives here.**

Revision 1 made the `.tres` files in `data/` the single source of truth for
everything the game reads: item properties, hotspots, rules, tools and days.
This file holds only what a placeholder *drawing* needs - which shape, which
colour, which two- or three-letter code - and becomes obsolete the moment the
designers deliver real art.

Hotspot rings are no longer drawn here at all. They are a separate overlay PNG
per item, generated from the `.tres` by `tools/gen_hotspot_overlays.gd`, so the
rings can never disagree with the coordinates the game checks against.
"""

# id -> how to draw its placeholder. Ids must match data/items/<id>.tres.
ITEM_ART = [
    dict(id="banana_peel", shape="peel", color=(232, 197, 71), code="ORG"),
    dict(id="fish_bone", shape="bone", color=(237, 230, 214), code="ORG"),
    dict(id="pet_bottle", shape="bottle", color=(127, 212, 232), code="PET"),
    dict(id="alu_can", shape="can", color=(201, 205, 212), code="ALU"),
    dict(id="styrofoam_tray", shape="tray", color=(242, 242, 242), code="PS"),
    dict(id="car_battery", shape="box", color=(74, 85, 104), code="B3"),
    dict(id="oil_jerrycan", shape="jerrycan", color=(143, 212, 143), code="HDP"),
    dict(id="paint_bottle", shape="bottle", color=(183, 201, 232), code="PET"),
    dict(id="juice_carton", shape="carton", color=(224, 122, 95), code="PAP"),
    dict(id="eco_tote", shape="tote", color=(163, 177, 138), code="TXT"),
    dict(id="paper_cup", shape="cup", color=(244, 225, 193), code="PAP"),
    dict(id="spray_can", shape="spray", color=(176, 183, 195), code="AER"),
    dict(id="glass_jar", shape="jar", color=(111, 168, 160), code="GL"),
    dict(id="fishing_net", shape="net", color=(62, 124, 177), code="PA6"),
]

# Icon colours only. ToolData.color in data/tools/*.tres is authoritative for
# anything the game itself renders.
TOOL_ART = [
    dict(id="rinse", name="Bilas", color=(96, 178, 230)),
    dict(id="swab", name="Usap Kimia", color=(214, 120, 200)),
    dict(id="magnifier", name="Kaca Pembesar", color=(240, 200, 84)),
    dict(id="cutter", name="Pemotong", color=(226, 106, 92)),
]

# Background only since revision 1 - no collision, no grab, no penalty.
FISH = [("fish_bg_small", 96, 48, (244, 162, 97)),
        ("fish_bg_medium", 128, 64, (231, 111, 81)),
        ("fish_bg_large", 176, 88, (140, 196, 180))]

BINS = [("organic", (106, 153, 78)), ("recyclable", (58, 134, 183)),
        ("hazard", (198, 76, 65)), ("landfill", (120, 113, 108))]
