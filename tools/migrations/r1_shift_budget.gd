## Revision 1 migration: replace max_grabs and per-tool charges with a single
## shift budget, and add the drift-in spawn parameters.
##
##   godot --headless --script tools/migrations/r1_shift_budget.gd
##
## Budgets and quotas come from §5 of the revision brief. They are starting
## points for tuning, recorded in PROGRESS.md as such.
extends SceneTree

const DAYS := {
	1: {"budget": 90, "quota": 5, "tools": [],
		"intro": "Hari pertama. Pilah dari yang terlihat saja - alat periksa belum ada. Setiap cakar, periksa dan buang memakai waktu shift; berpikir gratis."},
	2: {"budget": 110, "quota": 6, "tools": [&"rinse", &"magnifier"],
		"intro": "Alat periksa datang. Bilas untuk melihat sisa kotoran, kaca pembesar untuk membaca kode. Keduanya memakai waktu shift."},
	3: {"budget": 130, "quota": 8, "tools": [&"rinse", &"magnifier", &"swab"],
		"intro": "Usap kimia tersedia. Tidak semua sisa kotoran sama bahayanya."},
	4: {"budget": 150, "quota": 10, "tools": [&"rinse", &"magnifier", &"swab", &"cutter"],
		"intro": "Pemotong tersedia. Yang terlihat seperti kertas belum tentu kertas - tapi setiap pemeriksaan mengurangi jatah cakar."},
	5: {"budget": 160, "quota": 12, "tools": [&"rinse", &"magnifier", &"swab", &"cutter"],
		"intro": "Aturan bertambah dan barang bertambah, tapi waktu shift hampir sama. Perhatikan aturan aluminium yang baru."},
}


func _init() -> void:
	for n: int in DAYS:
		var path := "res://data/days/day_%02d.tres" % n
		var day: DayData = load(path)
		if day == null:
			push_error("missing " + path)
			continue
		var spec: Dictionary = DAYS[n]
		day.budget = int(spec["budget"])
		day.quota = int(spec["quota"])
		var tools: Array[StringName] = []
		for id: StringName in spec["tools"]:
			tools.append(id)
		day.available_tools = tools
		# Never open on an empty seabed, and never leave the player waiting.
		day.initial_seed_fraction = 0.4
		day.spawn_interval_min = 3.0
		day.spawn_interval_max = 6.5
		day.min_available_items = 4
		day.intro_text = String(spec["intro"])
		ResourceSaver.save(day, path)
		print("  day %d: budget %d, quota %d, tools %s, seeded %d%% of %d items"
			% [n, day.budget, day.quota, day.available_tools,
			int(day.initial_seed_fraction * 100.0), day.item_pool.size()])
	quit()
