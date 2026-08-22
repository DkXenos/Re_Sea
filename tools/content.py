"""Single source of truth for the prototype's content, used by both the
placeholder art generator and the .tres generator. This exists so the hotspot
markers drawn on an item's PNG can never drift from the hotspots stored in its
ItemData. After bootstrap the .tres files are the source of truth - gen_data.py
refuses to overwrite them without --force.

Categories: 0 ORGANIC, 1 RECYCLABLE, 2 HAZARD, 3 LANDFILL
"""

ORGANIC, RECYCLABLE, HAZARD, LANDFILL = 0, 1, 2, 3

# tool ids used by hotspots
RINSE, SWAB, MAG, CUT = "rinse", "swab", "magnifier", "cutter"


def hs(x, y, tool, reveals, radius=0.14):
    return {"pos": (x, y), "radius": radius, "tool": tool, "reveals": reveals}


# --------------------------------------------------------------------- ITEMS
# 6 obvious / 5 traps / 3 honest-but-ambiguous
ITEMS = [
    # ---------------- obvious: correct from surface info alone ----------------
    dict(id="banana_peel", name="Kulit Pisang", code="ORG", shape="peel",
         color=(232, 197, 71), weight=0.3, cat=ORGANIC, batch="rumah_tangga",
         vis_mat="kulit buah", vis_label="", hotspots=[]),
    dict(id="fish_bone", name="Tulang Ikan", code="ORG", shape="bone",
         color=(237, 230, 214), weight=0.3, cat=ORGANIC, batch="kapal_nelayan",
         vis_mat="tulang", vis_label="", hotspots=[]),
    dict(id="pet_bottle", name="Botol Air Bening", code="PET", shape="bottle",
         color=(127, 212, 232), weight=0.6, cat=RECYCLABLE, batch="rumah_tangga",
         vis_mat="PET bening", vis_label="AIR MINERAL", tag="PET 1 - bening bersih",
         hotspots=[hs(.32, .68, RINSE, "has_residue"), hs(.60, .30, MAG, "tag_text")]),
    dict(id="alu_can", name="Kaleng Minuman", code="ALU", shape="can",
         color=(201, 205, 212), weight=0.5, cat=RECYCLABLE, batch="rumah_tangga",
         vis_mat="aluminium", vis_label="SODA", tag="ALU - kaleng minuman",
         residue="sisa minuman manis",
         hotspots=[hs(.50, .72, RINSE, "has_residue"), hs(.45, .28, MAG, "tag_text")]),
    dict(id="styrofoam_tray", name="Wadah Styrofoam", code="PS", shape="tray",
         color=(242, 242, 242), weight=0.4, cat=LANDFILL, batch="pasar_ikan",
         vis_mat="styrofoam", vis_label="", tag="PS 6 - tidak didaur ulang",
         hotspots=[hs(.55, .60, MAG, "tag_text")]),
    dict(id="car_battery", name="Aki Bekas", code="B3", shape="box",
         color=(74, 85, 104), weight=4.2, cat=HAZARD, batch="bengkel_pesisir",
         vis_mat="logam dan plastik tebal", vis_label="AWAS ASAM",
         tag="Pb - AWAS ASAM", true_mat="timbal dan asam sulfat",
         hotspots=[hs(.70, .25, MAG, "tag_text"), hs(.30, .55, CUT, "true_material")]),

    # ---------------- traps: look clean, hide something ----------------
    dict(id="oil_jerrycan", name="Jeriken Bening", code="HDP", shape="jerrycan",
         color=(143, 212, 143), weight=2.2, cat=RECYCLABLE, batch="bengkel_pesisir",
         vis_mat="HDPE bening", vis_label="HDPE 2", tag="HDPE 2",
         residue="oli mesin", true_mat="HDPE",
         hotspots=[hs(.38, .70, RINSE, "has_residue"), hs(.62, .60, SWAB, "residue_type"),
                   hs(.50, .24, MAG, "tag_text")]),
    dict(id="paint_bottle", name="Botol Bening Bekas", code="PET", shape="bottle",
         color=(183, 201, 232), weight=1.6, cat=RECYCLABLE, batch="pabrik_cat",
         vis_mat="PET bening", vis_label="PET 1", tag="PET 1",
         residue="cat berbasis pelarut",
         hotspots=[hs(.45, .72, RINSE, "has_residue"), hs(.62, .55, SWAB, "residue_type"),
                   hs(.50, .26, MAG, "tag_text")]),
    dict(id="juice_carton", name="Kotak Jus", code="PAP", shape="carton",
         color=(224, 122, 95), weight=0.8, cat=RECYCLABLE, batch="pabrik_minuman",
         vis_mat="kertas karton", vis_label="DAUR ULANG", tag="PAP 84 - karton berlapis",
         true_mat="kertas, aluminium dan PE", multilayer=True,
         hotspots=[hs(.55, .30, MAG, "tag_text"), hs(.28, .62, CUT, "true_material")]),
    dict(id="eco_tote", name="Tas Kain Ramah Lingkungan", code="TXT", shape="tote",
         color=(163, 177, 138), weight=0.9, cat=RECYCLABLE, batch="pabrik_tekstil",
         vis_mat="kain katun", vis_label="RAMAH LINGKUNGAN", tag="60% katun / 40% PVC",
         true_mat="katun berlapis PVC", multilayer=True,
         hotspots=[hs(.62, .68, MAG, "tag_text"), hs(.35, .40, CUT, "true_material")]),
    dict(id="paper_cup", name="Gelas Kertas", code="PAP", shape="cup",
         color=(244, 225, 193), weight=0.5, cat=RECYCLABLE, batch="kedai_pantai",
         vis_mat="kertas", vis_label="KERTAS", tag="PAP 22 - lapisan PE",
         residue="kopi", true_mat="kertas berlapis PE", multilayer=True,
         hotspots=[hs(.50, .70, RINSE, "has_residue"), hs(.58, .32, MAG, "tag_text"),
                   hs(.28, .45, CUT, "true_material")]),

    # ---------------- honest but ambiguous: a tool charge well spent ----------
    dict(id="spray_can", name="Kaleng Semprot", code="AER", shape="spray",
         color=(176, 183, 195), weight=1.4, cat=RECYCLABLE, batch="pabrik_cat",
         vis_mat="kaleng baja", vis_label="KOSONG?",
         tag="MUDAH TERBAKAR - jangan ditusuk",
         true_mat="baja dengan sisa gas propelan",
         hotspots=[hs(.52, .72, MAG, "tag_text"), hs(.30, .40, CUT, "true_material")]),
    dict(id="glass_jar", name="Toples Kaca", code="GL", shape="jar",
         color=(111, 168, 160), weight=2.0, cat=RECYCLABLE, batch="klinik_pesisir",
         vis_mat="kaca", vis_label="", tag="GL 70 - kaca campur",
         residue="sisa obat kadaluarsa",
         hotspots=[hs(.50, .62, RINSE, "has_residue"), hs(.66, .50, SWAB, "residue_type"),
                   hs(.40, .28, MAG, "tag_text")]),
    dict(id="fishing_net", name="Jaring Nilon Sobek", code="PA6", shape="net",
         color=(62, 124, 177), weight=2.6, cat=RECYCLABLE, batch="kapal_nelayan",
         vis_mat="nilon", vis_label="", tag="PA 6 - inti berserat",
         true_mat="nilon dengan serat baja", multilayer=True,
         hotspots=[hs(.60, .35, MAG, "tag_text"), hs(.35, .62, CUT, "true_material")]),
]

# --------------------------------------------------------------------- RULES
# An empty applies_when means "rulebook text only, never overrides" - that is
# how the day 1 baseline rule is expressed without special-casing it in code.
RULES = [
    dict(id="r_baseline", priority=0, when={}, forces=ORGANIC,
         text="Pilah dari bahannya: bahan alami masuk ORGANIK; plastik, logam, kaca dan kertas yang bersih masuk DAUR ULANG; bahan kimia masuk B3; sisanya masuk RESIDU."),
    dict(id="r_residue", priority=10, when={"has_residue": True}, forces=LANDFILL,
         text="Barang yang masih ada sisa kotoran tidak bisa didaur ulang. Buang ke RESIDU."),
    dict(id="r_multilayer", priority=30, when={"is_multilayer": True}, forces=LANDFILL,
         text="Kemasan berlapis (kertas, plastik dan aluminium yang menyatu) tidak bisa dipisah. Buang ke RESIDU."),
    dict(id="r_chem_residue", priority=40,
         when={"residue_type": ["oli mesin", "cat berbasis pelarut", "sisa obat kadaluarsa"]},
         forces=HAZARD,
         text="Sisa oli, cat pelarut atau obat kadaluarsa membuat wadahnya menjadi limbah B3. Aturan ini mengalahkan aturan sisa kotoran."),
    dict(id="r_flammable", priority=50, when={"tag_text": ["MUDAH TERBAKAR - jangan ditusuk"]},
         forces=HAZARD,
         text="Barang dengan label MUDAH TERBAKAR selalu masuk B3, walaupun terlihat kosong."),
    dict(id="r_alu_always", priority=70, when={"visible_material": ["aluminium"]},
         forces=RECYCLABLE,
         text="Mulai hari ini aluminium selalu bisa didaur ulang, walaupun masih ada sisa kotoran. Aturan ini mengalahkan aturan sisa kotoran."),
]

# --------------------------------------------------------------------- TOOLS
TOOLS = [
    dict(id="rinse", name="Bilas", reveals="has_residue", charges=4,
         desc="Menyiram permukaan untuk melihat apakah masih ada sisa kotoran di baliknya.",
         color=(96, 178, 230)),
    dict(id="swab", name="Usap Kimia", reveals="residue_type", charges=3,
         desc="Mengusap sisa kotoran untuk mengetahui jenisnya.",
         color=(214, 120, 200)),
    dict(id="magnifier", name="Kaca Pembesar", reveals="tag_text", charges=5,
         desc="Membaca kode daur ulang atau label kecil yang tercetak.",
         color=(240, 200, 84)),
    dict(id="cutter", name="Pemotong", reveals="true_material", charges=2,
         desc="Menyayat sedikit bagian barang untuk melihat bahan aslinya dan lapisannya.",
         color=(226, 106, 92)),
]

# ---------------------------------------------------------------------- DAYS
# Numbers come straight from section 16 of the brief. They are starting points
# for tuning, not final values.
DAYS = [
    dict(n=1, quota=5, grabs=8, tools_enabled=False, charges={},
         rules=["r_baseline"],
         items=["banana_peel", "fish_bone", "pet_bottle", "alu_can", "styrofoam_tray", "car_battery"],
         intro="Hari pertama. Pilah dari yang terlihat saja - belum ada alat periksa."),
    dict(n=2, quota=6, grabs=10, tools_enabled=True, charges={"rinse": 3, "magnifier": 3},
         rules=["r_baseline", "r_residue"],
         items=["banana_peel", "fish_bone", "pet_bottle", "alu_can", "styrofoam_tray",
                "car_battery", "oil_jerrycan", "paint_bottle"],
         intro="Alat periksa datang. Bilas untuk melihat sisa kotoran, kaca pembesar untuk membaca kode."),
    dict(n=3, quota=8, grabs=12, tools_enabled=True,
         charges={"rinse": 3, "magnifier": 4, "swab": 2},
         rules=["r_baseline", "r_residue", "r_chem_residue"],
         items=["banana_peel", "fish_bone", "pet_bottle", "alu_can", "styrofoam_tray",
                "car_battery", "oil_jerrycan", "paint_bottle", "paper_cup", "glass_jar"],
         intro="Usap kimia tersedia. Tidak semua sisa kotoran sama bahayanya."),
    dict(n=4, quota=10, grabs=14, tools_enabled=True,
         charges={"rinse": 4, "magnifier": 4, "swab": 3, "cutter": 2},
         rules=["r_baseline", "r_residue", "r_chem_residue", "r_multilayer"],
         items=["banana_peel", "fish_bone", "pet_bottle", "alu_can", "styrofoam_tray",
                "car_battery", "oil_jerrycan", "paint_bottle", "paper_cup", "glass_jar",
                "juice_carton", "eco_tote"],
         intro="Pemotong tersedia, hanya dua kali pakai. Yang terlihat seperti kertas belum tentu kertas."),
    dict(n=5, quota=12, grabs=15, tools_enabled=True,
         charges={"rinse": 3, "magnifier": 3, "swab": 2, "cutter": 1},
         rules=["r_baseline", "r_residue", "r_chem_residue", "r_multilayer",
                "r_flammable", "r_alu_always"],
         items=[i["id"] for i in ITEMS],
         intro="Aturan bertambah, jatah alat berkurang. Perhatikan aturan aluminium yang baru."),
]

FISH = [("fish_small", 96, 48, (244, 162, 97)),
        ("fish_medium", 128, 64, (231, 111, 81)),
        ("fish_large", 176, 88, (140, 196, 180))]

BINS = [("organic", (106, 153, 78)), ("recyclable", (58, 134, 183)),
        ("hazard", (198, 76, 65)), ("landfill", (120, 113, 108))]


def as_json():
    """Dump the content table for tools/gen_data.gd, which builds the actual
    .tres files. Godot serializes its own resources so the .tres format - typed
    arrays, resource references, StringName - is always correct."""
    def item(i):
        return dict(
            id=i["id"], display_name=i["name"], weight=i["weight"],
            visible_material=i["vis_mat"], visible_label=i["vis_label"],
            has_residue=bool(i.get("residue")), residue_type=i.get("residue", ""),
            true_material=i.get("true_mat", ""), is_multilayer=i.get("multilayer", False),
            tag_text=i.get("tag", ""), correct_category=i["cat"], source_batch=i["batch"],
            hotspots=[dict(pos=list(h["pos"]), radius=h["radius"], tool=h["tool"],
                           reveals=h["reveals"]) for h in i["hotspots"]],
        )
    return dict(
        items=[item(i) for i in ITEMS],
        rules=[dict(id=r["id"], text=r["text"], applies_when=r["when"],
                    forces_category=r["forces"], priority=r["priority"]) for r in RULES],
        tools=[dict(id=t["id"], display_name=t["name"], reveals_field=t["reveals"],
                    default_charges=t["charges"], description=t["desc"]) for t in TOOLS],
        days=[dict(day_number=d["n"], quota=d["quota"], max_grabs=d["grabs"],
                   tools_enabled=d["tools_enabled"], tool_charges=d["charges"],
                   active_rules=d["rules"], item_pool=d["items"], intro_text=d["intro"],
                   modifier="") for d in DAYS],
    )


if __name__ == "__main__":
    import json, os
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "content.json")
    with open(out, "w") as f:
        json.dump(as_json(), f, indent=1, ensure_ascii=False)
    print("wrote", out)
