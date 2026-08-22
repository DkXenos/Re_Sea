## Every player-facing string in the game. All text is Indonesian; code,
## comments and filenames stay English. Item names and rule text live in their
## own .tres files - everything else lives here so re-wording is one file.
class_name Strings
extends RefCounted

const TABLE: Dictionary = {
	# --- menu ---
	"game_title": "CAKAR LAUT",
	"game_subtitle": "Pilah sampah, selamatkan laut",
	"menu_play": "Mulai",
	"menu_settings": "Pengaturan",
	"menu_quit": "Keluar",
	"menu_hint": "Klik tombol atau tekan Enter",

	# --- settings ---
	"settings_title": "PENGATURAN",
	"settings_master": "Volume Utama",
	"settings_music": "Musik",
	"settings_sfx": "Efek Suara",
	"settings_vfx": "Intensitas Efek Visual",
	"settings_back": "Kembali",

	# --- cutscene ---
	"cutscene_skip": "Lewati (Esc)",
	"cutscene_advance": "Klik atau Enter untuk lanjut",

	# --- day start ---
	"day_label": "HARI {n}",
	"day_rules_today": "Aturan hari ini",
	"day_quota": "Target pilah",
	"day_grabs": "Jatah cakar",
	"day_tools": "Alat periksa",
	"day_tools_locked": "Belum tersedia",
	"day_begin": "Turunkan Cakar",
	"day_seed": "Seed: {n}",

	# --- claw phase ---
	"claw_grabs_left": "Cakar tersisa",
	"claw_grip_chance": "Peluang cengkeram: {n}%",
	"claw_grip_none": "Arahkan cakar ke sebuah benda",
	"claw_hint": "A/D atau panah untuk geser, Spasi untuk turun. Klik tombol di konsol juga bisa.",
	"claw_drop_button": "TURUN",
	"claw_caught_fish": "Ikan tersangkut! Laut dirugikan.",
	"claw_slipped": "Lepas! Benda jatuh kembali.",
	"claw_finished": "Jatah cakar habis - kembali ke meja",
	"claw_to_desk": "Ke Meja Pilah",
	"claw_inventory": "Terkumpul",

	# --- desk phase ---
	"desk_title": "MEJA PILAH",
	"desk_inventory": "Barang terkumpul",
	"desk_empty": "Semua barang sudah dipilah",
	"desk_finish": "Selesaikan Hari",
	"desk_pick_item": "Pilih barang untuk diperiksa",
	"desk_back": "Kembali ke daftar",
	"inspect_title": "PEMERIKSAAN",
	"inspect_zoom_hint": "Gulir untuk perbesar, seret untuk geser",
	"tools_title": "ALAT",
	"tools_locked": "Alat belum tersedia hari ini",
	"tools_armed": "{tool} siap - klik pada barang",
	"tools_no_charge": "Jatah {tool} habis",
	"evidence_title": "CATATAN BUKTI",
	"bins_title": "Buang ke",
	"reveal_success": "Ditemukan sesuatu!",
	"reveal_nothing": "Tidak ada apa-apa di titik itu. Jatah tetap terpakai.",
	"charges_label": "Jatah",

	# --- evidence chips ---
	"chip_material": "TAMPAK: {v}",
	"chip_label": "TULISAN: {v}",
	"chip_weight": "BERAT: {v} kg",
	"chip_no_label": "tanpa tulisan",
	"chip_residue": "SISA KOTORAN: {v}",
	"chip_residue_type": "JENIS KOTORAN: {v}",
	"chip_true_material": "BAHAN ASLI: {v}",
	"chip_tag": "KODE / LABEL: {v}",
	"field_residue_yes": "ada",
	"field_residue_no": "bersih",
	"field_none": "tidak ada",
	"field_no_tag": "tidak ada kode",
	"field_multilayer_suffix": " (berlapis)",

	# --- bins ---
	"bin_organic": "ORGANIK",
	"bin_recyclable": "DAUR ULANG",
	"bin_hazard": "B3 / BERBAHAYA",
	"bin_landfill": "RESIDU",

	# --- rulebook ---
	"rulebook_title": "BUKU ATURAN",
	"rulebook_hint": "TAB untuk buka / tutup",
	"rulebook_close": "Tutup",
	"rulebook_empty": "Belum ada aturan khusus hari ini",

	# --- day report ---
	"report_title": "LAPORAN HARI {n}",
	"report_correct": "Pilah benar",
	"report_wrong": "Pilah salah",
	"report_fish": "Ikan tersangkut",
	"report_shortfall": "Kurang dari target",
	"report_total": "Perubahan kesehatan laut",
	"report_health": "Kesehatan laut",
	"report_quota_met": "Target tercapai",
	"report_quota_failed": "Target tidak tercapai",
	"report_mistakes": "Yang terlewat",
	"report_missed": "Tidak diperiksa: {v}",
	"report_rule": "Melanggar: {v}",
	"report_should_be": "Seharusnya: {v}",
	"report_you_put": "Kamu buang ke: {v}",
	"report_next": "Hari Berikutnya",
	"report_perfect": "Tidak ada kesalahan. Kerja bagus.",

	# --- endings ---
	"over_title": "LAUT MATI",
	"over_body": "Kesehatan laut habis. Sampah menang kali ini.",
	"win_title": "LIMA HARI SELESAI",
	"win_body": "Laut bertahan. Kesehatan akhir: {n}",
	"over_retry": "Coba Lagi",
	"over_menu": "Menu Utama",

	# --- pause ---
	"pause_title": "JEDA",
	"pause_resume": "Lanjut",
	"pause_settings": "Pengaturan",
	"pause_menu": "Menu Utama",
}

static func t(key: String) -> String:
	if TABLE.has(key):
		return TABLE[key]
	push_warning("Missing string key: %s" % key)
	return key

## t() with {placeholder} substitution, e.g. tf("day_label", {"n": 3})
static func tf(key: String, args: Dictionary) -> String:
	return t(key).format(args)

static func category_name(cat: int) -> String:
	match cat:
		ItemData.Category.ORGANIC: return t("bin_organic")
		ItemData.Category.RECYCLABLE: return t("bin_recyclable")
		ItemData.Category.HAZARD: return t("bin_hazard")
		ItemData.Category.LANDFILL: return t("bin_landfill")
	return "?"
