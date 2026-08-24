## Every player-facing string in the game. All text is Indonesian; code,
## comments and filenames stay English. Item names and rule text live in their
## own .tres files - everything else lives here so re-wording is one file.
class_name Strings
extends RefCounted

const TABLE: Dictionary = {
	# --- menu ---
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
	"settings_hotspots": "Tampilkan tanda titik periksa",
	"settings_back": "Kembali",

	# --- cutscene ---
	"cutscene_skip": "Lewati (Esc)",
	"cutscene_advance": "Klik atau Enter untuk lanjut",
	"cutscene_line_1": "Dulu teluk ini penuh ikan. Sekarang penuh sampah kiriman dari darat.",
	"cutscene_line_2": "Setiap hari arus membawa kiriman baru. Ada yang jelas, ada yang menyamar.",
	"cutscene_line_3": "Kamu operator cakar. Angkat, periksa, pilah. Laut menghitung setiap keputusanmu.",

	# --- day start ---
	"day_label": "HARI {n}",
	"day_rules_today": "Aturan hari ini",
	"day_quota": "Target pilah",
	"day_budget": "Waktu shift",
	"day_tools": "Alat tersedia",
	"day_tools_locked": "Belum tersedia",
	"day_begin": "Turunkan Cakar",
	"day_seed": "Seed: {n}",

	# --- claw phase ---
	"budget_label": "Sisa waktu shift",
	"budget_cost": "biaya {n}",
	"budget_too_low": "Waktu shift tidak cukup untuk itu",
	"shift_end": "Akhiri Shift",
	"shift_to_desk": "Ke Meja Pilah",
	"shift_to_claw": "Ke Mesin Cakar",
	"shift_unsorted": "{n} belum dipilah",
	"shift_over": "Waktu shift habis",
	"ocean_label": "Laut: {v}  ({n}/100)",
	"upgrade_active": "Alat aktif: {v}  -  turun {drop} · alat {tool} · pilah {sort}",
	"upgrade_none": "Tanpa peningkatan  -  turun {drop} · alat {tool} · pilah {sort}",
	"claw_grip_chance": "Peluang cengkeram: {n}%",
	"claw_rail_locked": "Rel sedang siap ulang - sebentar lagi bisa digeser",
	"claw_grip_none": "Arahkan cakar ke sebuah benda",
	"claw_hint": "A/D atau panah untuk geser, Spasi untuk turun. Klik tombol di konsol juga bisa.",
	"claw_drop_button": "TURUN  ({n})",
	"claw_slipped": "Lepas! Benda jatuh kembali.",

	# --- desk phase ---
	"desk_inventory": "Barang terkumpul",
	"desk_empty": "Semua barang sudah dipilah",
	"desk_no_selection": "Pilih barang dulu sebelum membuang",
	"desk_rulebook_button": "Buku Aturan (R)",
	"inspect_zoom_hint": "Gulir untuk perbesar, seret untuk geser",
	"tools_locked": "Alat belum tersedia hari ini",
	"tools_armed": "{tool} siap - klik pada barang",
	"evidence_title": "CATATAN BUKTI",
	"reveal_nothing": "Bersih di titik ini - tidak ada yang bisa dibaca.",
	"inspect_found": "Ditemukan: {v}   (waktu shift -{n})",
	"inspect_coarse": "Ada sesuatu di titik ini, tapi belum terbaca. Pakai alat sekali lagi untuk membacanya. (waktu shift -{n})",
	"inspect_nothing": "Bersih di titik ini. Tidak ada temuan, waktu shift tetap terpakai -{n}.",
	"inspect_rules_title": "ATURAN AKTIF HARI INI",
	"inspect_question": "Terlihat seperti {mat}. Percaya?",
	"inspect_question_labeled": "Tertulis {label}, terlihat seperti {mat}. Percaya?",
	"inspect_pick_first": "Pilih barang dari daftar di kiri.",
	"tools_cost_label": "biaya {n}",

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

	# --- mystery box (revision 4) ---
	"box_open": "Buka",
	"box_sealed": "Kotak tersegel - belum tahu isinya",
	"box_opened_toast": "Kotak dibuka: {n} barang masuk ke daftar",

	# --- bins ---
	"bin_organic": "ORGANIK",
	"bin_recyclable": "DAUR ULANG",
	"bin_hazard": "B3 / BERBAHAYA",
	"bin_landfill": "RESIDU",

	# --- rulebook ---
	"rulebook_title": "BUKU ATURAN",
	"rulebook_codes": "ARTI KODE DAUR ULANG",
	"rulebook_codes_note": "Kode ini dicetak atau dicap pada barangnya. Kode memberi tahu bahannya - bukan apakah barangnya bersih.",
	"rulebook_close": "Tutup",
	"rulebook_empty": "Belum ada aturan khusus hari ini",
	"rulebook_general": "UMUM",

	# --- day report ---
	"report_title": "LAPORAN HARI {n}",
	"report_correct": "Pilah benar",
	"report_wrong": "Pilah salah",
	"report_clean_bonus": "Bonus hari bersih",
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

	# --- after-day screen (revision 3) ---
	"after_title": "HARI {n} SELESAI",
	"after_tab_result": "Hasil Hari Ini",
	"after_tab_tech": "Teknologi",
	"after_tab_gear": "Peralatan",
	"after_next_day": "Mulai Hari Berikutnya",
	"after_last_day": "Selesaikan Shift Terakhir",
	"after_sorted": "Pilah benar {ok}  ·  salah {bad}  ·  belum dipilah {left}",
	"after_budget": "Waktu shift terpakai {spent} dari {max}, sisa {left}",
	"after_health": "Kesehatan laut {before} -> {after}   (Laut: {tier})",

	# --- blueprints (revision 2) ---
	"blueprint_requires": "Butuh: {v}",
	"blueprint_done": "SELESAI",
	"blueprint_claim": "Klaim  (+{n})",

	# --- upgrades (revision 2) ---
	"upgrade_equip": "Pakai",
	"upgrade_equipped": "Terpasang",
	"upgrade_locked": "Terkunci",
	"upgrade_benefit": "+ {v}",
	"upgrade_cost": "- {v}",

	# --- calibration puzzle (EXPERIMENTAL, revision 2 §5) ---
	# Delete this block together with scenes/puzzle/. The step text and the
	# failure lines live in that folder, so removing it removes the feature.
	"puzzle_title": "URUTKAN LANGKAH MESIN",
	"puzzle_hint": "Seret langkah ke urutan yang benar, lalu jalankan. Salah urutan tidak menghukum - coba lagi sebanyak yang kamu mau.",
	"puzzle_run": "Jalankan",
	"puzzle_skip": "Lewati",
	"puzzle_continue": "Lanjut",
	"puzzle_success": "Mesin berjalan benar. Kesehatan laut +{n}.",
	"puzzle_wrong": "Urutannya belum tepat.",

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
	"pause_menu": "Menu Utama",
}

## The resin and material codes printed on real packaging, in plain Indonesian.
##
## A player who has never sorted waste has no reason to know what PET means, and
## the game shows the code on the item, on its label and in the magnifier
## reading. Explaining it is one page in a book that is already free to open.
##
## This is a fixed reference table, not per-item content, so it lives here with
## the rest of the text rather than becoming fourteen more .tres files.
const CODES: Array = [
	["PET 1", "plastik bening untuk botol minuman. Bisa didaur ulang kalau bersih."],
	["HDPE 2", "plastik tebal untuk jerigen dan botol sabun. Bisa didaur ulang kalau bersih."],
	["PVC 3", "plastik lentur tahan air. Sulit didaur ulang."],
	["PE", "lapisan plastik tipis, sering dilapiskan ke kertas."],
	["PS 6", "styrofoam. Hampir tidak pernah diterima daur ulang."],
	["PA 6", "nilon, dipakai untuk tali dan jaring."],
	["PAP", "kertas dan karton. Kalau berlapis plastik atau aluminium, tidak bisa dipisah."],
	["ALU", "aluminium. Bernilai tinggi dan bisa didaur ulang berulang kali."],
	["GL", "kaca. Bisa didaur ulang, tapi kaca campur sering ditolak."],
	["Pb", "timbal. Logam berat beracun - selalu B3."],
]

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
