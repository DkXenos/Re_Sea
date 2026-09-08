# OUTPUT — Validasi klaim proposal terhadap build saat ini

Basis: working tree `/Users/jaysn/claw-test` per 2026-09-08, branch `main`.
Read-only. Tidak ada berkas yang diubah selain berkas ini.

---

## 1. RINGKASAN — klaim yang SALAH atau TIDAK ADA

Urut dari yang paling berisiko ketemu juri.

| # | Vonis | Versi yang benar |
|---|---|---|
| **A24** | **SALAH** | Ada **EMPAT** bin, bukan tiga: ORGANIC, RECYCLABLE, **HAZARDOUS**, RESIDUE. `ItemData.Category` = `{ORGANIC, RECYCLABLE, HAZARD, RESIDUE}`; `bin_row.gd` membangun empat tombol; `Strings` punya `"bin_hazard": "HAZARDOUS"`; tutorial berjudul "THE FOUR BINS"; rulebook merender blok HAZARDOUS. Sisa "landfill" juga masih ada: berkas plat bin RESIDUE bernama `assets/bins/bin_landfill.png`, dimuat lewat `data/frames/bin_landfill_frames.tres`, dan dirujuk `bin_row.gd:19` + `bin_icons.gd:12`. |
| **A36** | **SALAH** | Resep menuntut **KEEMPAT** kategori. `06_seeding_arm.tres` minta **5 HAZARDOUS**; tanpa bin HAZARDOUS, Reef Restoration Pod mustahil selesai. |
| **A9** | **TIDAK ADA** | Sebelum menjatuhkan, layar **tidak menampilkan apa pun**. `claw_phase.gd:_update_grip_preview()` menyetel `_grip_label.text = ""` di semua cabang kecuali saat rel terkunci. Peluang cengkeram tetap dihitung (`tank_item.gd:grip_chance()`) dan dipakai untuk roll, tapi angkanya tidak pernah sampai ke layar. Deskripsi permukaan benda sasaran juga tidak ada. Sinyal `Events.grip_preview_changed` dideklarasikan tapi tidak pernah di-emit maupun di-connect. |
| **A16** | **SALAH** | Yang benar-benar tampil gratis: **nama benda, "LOOKS LIKE: …" (`visible_material`), "MARKING: …" (`visible_label`, atau "no marking"), "WEIGHT: x.x kg"**, plus gambar bendanya yang bisa di-zoom/geser. **`surface_properties` TIDAK pernah dirender di mana pun** — ditulis lengkap di 20 dari 20 `.tres` item, dipakai nol kali di luar `item_data.gd`. |
| **A17** | **SALAH (sebagian)** | Rinse memang membersihkan dan efeknya permanen per-instance, biayanya **4** satuan, dan terlihat jelas. Tapi tidak semuanya jadi "material daur ulang" dan tidak semua bisa dipulihkan. Rincian di bawah. |
| **A5** | **SALAH** | Laporan dan layar persiapan adalah **SATU layar**, bukan dua. Alurnya: `main_menu → cutscene → day_start → shift → after_day → (day_start \| game_over)` (`day_manager.gd`). `after_day` punya tiga tab: "The Day" (laporan), "Technology" (rakit), "Gear" (perlengkapan). Scene laporan terpisah sudah dihapus. |
| **A33** | **SALAH** | R **hanya bekerja di tampilan Sorting Desk**. Handler-nya ada di `desk_phase.gd:_unhandled_input`, yang langsung `return` kalau `not _active`. Di kokpit mesin capit, menekan R tidak melakukan apa-apa. Benar bahwa rulebook gratis dan tidak menjeda. |
| **A26** | **SALAH (premisnya sudah hilang)** | Sudah **tidak ada animasi menerima sama sekali**. `bin_row.gd:flash()` adalah stub kosong (`pass`). Yang tersisa: SFX `bin_accept` berbunyi untuk setiap pemilahan yang diterima, benar maupun salah. Jadi kesimpulan klaimnya tetap berlaku, tapi lewat suara, bukan animasi. |
| **A49** | **SALAH** | Konsol mesin punya padanan klik untuk kiri/kanan/jatuhkan/pindah-tampilan/jeda (`ArrowLeft`, `ArrowRight`, `GrabButton`, `SortingButton`, `SettingsButton`). **R dan I tidak punya padanan klik di konsol** — dan keduanya memang tidak berfungsi di tampilan capit. **End Shift tidak ada di konsol capit**, hanya di desk. |
| **A48** | **SALAH (sebagian)** | Semua tombol cocok kecuali: **I** memilih benda **pertama** yang belum dipilah (`inventory_panel.select_first()`), bukan "berikutnya" — menekannya berulang tidak berpindah, dan bisa mendarat di Sealed Crate. **Esc** hanya menjeda di `day_start`/`shift`/`after_day` (`main.gd:PAUSABLE_KEYS`); di menu utama Esc membuka layar Settings, di cutscene Esc melewati, di layar akhir Esc tidak melakukan apa-apa. **R** hanya di desk (lihat A33). |
| **A45** | **SALAH (sebagian)** | Ada **satu** elemen yang digambar kode: overlay tutorial memakai `ColorRect` layar penuh + `assets/ui/spotlight.gdshader` sebagai masker peredup berlubang. Selain itu, **ending tier 1 dan 2 tidak punya gambar sendiri** — `game.gd:ending_still()` memulangkan `cutscene_04.png` untuk keduanya; hanya tier 0 dan 3 yang punya lukisan sendiri. Baris tool yang tidak tersedia juga diredupkan dengan `modulate.a = 0.35` pada label (teks UI, bukan aset gambar). |
| **A8** | **SALAH (kurang satu syarat)** | Ada **tiga** pemicu, bukan dua. `shift_phase.gd:_check_shift_over()` juga mengakhiri shift ketika **laut kosong dan meja kosong**, sekalipun anggaran masih banyak (memicu baris "Every last piece out of the water and into a bin."). |
| **A50** | **SALAH** | Ada **dua** preset, keduanya `runnable=true`: `Windows Desktop` dan `Web`. Jadi bukan Windows saja. **Tapi build Windows saat ini tidak bisa dihasilkan**: template `windows_release_x86_64.exe` **tidak terpasang** di `~/Library/Application Support/Godot/export_templates/4.7.2.stable/` (yang ada hanya varian `_console` dan arm64), dan `build/windows/` kosong. Hanya build Web yang benar-benar ada (`build/Re-Sea-web.zip`, ±23 MB). `BUILD.md` juga sudah usang: ia menyatakan "hanya template Web yang terpasang", padahal sebagian besar template Windows sudah ada — yang hilang justru tepat satu yang dibutuhkan preset ini. |

Selain itu, satu **uji otomatis GAGAL** (`smoke_tech`) karena pasokan HAZARDOUS terlalu tipis. Lihat bagian akhir.

---

## 2. VERIFIKASI — A1 sampai A50

### Struktur dan alur

| # | Vonis | Bukti |
|---|---|---|
| A1 | **BENAR** | 5 berkas di `data/days/`, `day_number` 1–5, diurutkan di `game.gd:_load_days()`. |
| A2 | **BENAR** | `begin_day()` menyetel `budget_left = budget_max` dari `day.budget`. Tidak ada carry-over. |
| A3 | **BENAR** | `begin_day()` memanggil `inventory.clear()`. |
| A4 | **BENAR** | Yang tidak direset di `begin_day()`: `materials`, `crafted`, `unlocked_blueprints`, `equipped_upgrade` — persis keempatnya. |
| A5 | **SALAH** | Laporan + persiapan = satu layar `after_day` bertab tiga. Lihat Ringkasan. |
| A6 | **BENAR** | `shift_phase.gd` menampung `ClawView` dan `DeskView` sebagai dua anak dari satu scene; `_toggle_view()` hanya membunyikan `ui_click`, tidak memanggil `spend()`. |
| A7 | **BENAR** | `claw_phase._process()` memanggil `_update_spawning(delta)` tanpa syarat. `set_view_active(false)` hanya menyembunyikan CanvasLayer dan mematikan input capit; node tetap ber-`_process`. |
| A8 | **SALAH** | Ada syarat ketiga: laut + meja kosong. Lihat Ringkasan. |

### Mesin capit

| # | Vonis | Bukti |
|---|---|---|
| A9 | **TIDAK ADA** | `_grip_label.text = ""`. Lihat Ringkasan. |
| A10 | **BENAR** | `tank_item.gd:grip_chance()` = `clampf(1.0 - data.weight * 0.15 + Game.grip_delta(), 0.05, 0.95)`. |
| A11 | **BENAR** | Batas atas clamp = **0.95**. Tidak pernah 100 %. (Batas bawah 0.05.) |
| A12 | **BENAR** | `claw.gd:_resolve_grab()` menyetel `_slip_y` di antara 25–80 % perjalanan naik; `_process_rise` memicu `_slip()` → `tank_item.drop_into()` → jatuh kembali ke `home_y` di dasar. |
| A13 | **BENAR** | `claw_phase._on_drop_started()` memanggil `Game.spend(&"drop")` saat turun dimulai, jauh sebelum hasil cengkeram diketahui. |

### Shift time

| # | Vonis | Bukti |
|---|---|---|
| A14 | **BENAR** | `budget_left` hanya berkurang di `game.gd:spend_amount()` (satu-satunya tempat, sudah diaudit). Pemanggilnya: drop, sort, tool, rinse. Tidak ada `_process` yang mengurangi anggaran, tidak ada timer waktu nyata. (Timer waktu nyata yang ada hanya `_spawn_timer`, dan itu memunculkan benda, bukan memotong anggaran.) |
| A15 | **BENAR** | Berpikir (tidak ada jam), rulebook (`_rebuild()` saja), zoom/pan (`_on_surface_input` tidak menyentuh anggaran), pindah tampilan (`_toggle_view` hanya SFX). Semuanya gratis. |

### Inspeksi dan alat

| # | Vonis | Bukti |
|---|---|---|
| A16 | **SALAH** | `surface_properties` tidak pernah dirender. Lihat Ringkasan. |
| A17 | **SALAH (sebagian)** | Rincian di bawah tabel. |
| A18 | **BENAR** | `magnifier` → hotspot `{"tool":"magnifier","reveals":"true_material"}` pada 8 item; chip "MADE OF: …". |
| A19 | **BENAR** | `swab` → hotspot `reveals: "stain_type"`; `carried_item.IMPLIED_REVEALS` membuat `stain_type` otomatis membuka `stain_hazardous` dan `is_stained`. Jadi menamai nodanya sekaligus menjawab kimia-atau-makanan. |
| A20 | **BENAR** | `cutter.tres` `opens_containers = true`; `inspect_panel._open_crate()`. Gratis (`Game.open_container` tidak memanggil `spend`). |
| A21 | **BENAR** | Teks persis di baris feedback: **"Nothing on this one for that tool. The shift time is spent anyway -4."** (`inspect_nothing`, `{n}` diisi biaya nyata). Toast bersamaan: **"Nothing on this one for that tool."** (`reveal_nothing`). Pemotongan terjadi sebelum pengecekan `field.is_empty()`. |
| A22 | **BENAR** | Dua cabang di `_use_tool()` yang `return` sebelum `spend`: opener diarahkan ke non-crate → toast `"{tool} only opens sealed crates"`; alat inspeksi diarahkan ke crate tersegel → toast `"{tool} is no use on a sealed crate"`. Nol biaya. |
| A23 | **BENAR** | `_rebuild_log()` memilih `CHIP_MATCH` untuk kunci yang ada di `lit`; `_rebuild_rules()` meng-emit `bin_hint_changed` → `bin_row.highlight()` menyalakan `bin_outline.png` di bawah bin bersangkutan. Keduanya dipanggil di blok yang sama, jadi memang bersamaan. |

**A17 — rincian yang diminta.**
- **Benda yang bisa dipulihkan** (punya `is_stained = true` dan `stain_hazardous = false`): **Plastic Bag** (`kantong_plastik`), **Sauce Jar** (`botol_kaca_kotor`), **Muddy Shirt** (`baju_kotor`), **Paper Cup** (`paper_cup`).
- **Dipulihkan menjadi apa** — bukan selalu daur ulang:
  - Plastic Bag: RESIDUE → **RECYCLABLE** (hari 2–5)
  - Sauce Jar: RESIDUE → **RECYCLABLE** (hari 2–5)
  - Muddy Shirt: RESIDUE → **ORGANIC** (hari 2–5) ← bukan daur ulang
  - Paper Cup: RESIDUE → **RECYCLABLE** hanya di **hari 2–3**. Di **hari 4–5** aturan `r_multilayer` (prioritas 30) mengalahkan aturan noda (prioritas 10), jadi merinsenya **tidak mengubah apa pun** — tetap RESIDUE, dan 4 satuan anggaran hangus.
- **Yang tidak bisa dipulihkan**: Stained Shirt (`baju_b3`) dan Chemical-Soaked Tissue (`tisu_b3`) — `stain_hazardous = true`, rinse menolak.
- **Permanen?** Ya, per-instance. `entry.cleaned = true` di `CarriedItem`, dan `rule_overrides()` memaksa `is_stained:false, stain_type:"", stain_hazardous:false` selamanya untuk salinan itu. Dua gelas identik dirinse terpisah.
- **Biaya**: `Game.cost_of(&"tool")` = **4** (atau 2 dengan Coarse Scanner, 3 dengan Twin Arms).
- **Terlihat pemain?** Ya, empat tempat sekaligus: chip **"RINSED CLEAN"** di Evidence Log, toast **"Rinsed clean"**, baris feedback **"The stain washed straight off. It is clean now.  (shift time -4)"**, dan checklist aturan — baris "Still stained -> RESIDUE" berhenti menyala, sekaligus sorotan bin berpindah.

### Pemilahan

| # | Vonis | Bukti |
|---|---|---|
| A24 | **SALAH** | Empat bin, HAZARDOUS ada, sisa `landfill` ada di 4 tempat. Lihat Ringkasan. |
| A25 | **BENAR** | Keempat `Button` di `bin_row._ready()` tidak pernah di-`disabled`. Benda yang belum diperiksa sama sekali tetap bisa dimasukkan. (Ditolak hanya bila: tidak ada benda terpilih, benda adalah crate tersegel, atau anggaran < 1 — masing-masing dengan toast + SFX `bin_reject`.) |
| A26 | **SALAH** | Tidak ada animasi menerima sama sekali. Lihat Ringkasan. |
| A27 | **BENAR** | `game.gd:day_recovered()` melewati `if entry.sorted_to == -1 or not entry.was_correct: continue` — bin salah menghasilkan nol, bukan sebagian. Satu-satunya penulis `materials[…] +=` di seluruh basis kode adalah `_credit_materials()`, yang hanya dipanggil dari `commit_day_result()`, yang hanya dipanggil sekali dari `after_day._ready()` dan dijaga `day_committed`. Satu-satunya penulis lain adalah `craft_component()`, yang **mengurangi**. Tidak ada jalur lain. |
| A28 | **BENAR** | Tidak ada nyawa, denda, atau kalah. `game_over` hanyalah layar ending setelah hari 5; tidak ada yang memanggilnya lebih awal (kecuali debug `skip_day`). |
| A29 | **BENAR** | `desk_phase._on_bin_chosen()` menaikkan `stats["sorted"]` sebelum memisahkan benar/salah. `quota_met` hanya dibaca untuk mencetak "Target reached"/"Target missed" — nihil konsekuensi. |

### Aturan

| # | Vonis | Bukti |
|---|---|---|
| A30 | **BENAR (dengan catatan)** | `RuleChecker.resolve()` menghitung ulang tiap kali dari `item` + `rules` + `overrides`; hasilnya baru ditulis ke entry di `judge()` saat benda benar-benar dimasukkan. **Catatan 1**: dasar awalnya tetap properti tetap benda (`item.correct_category`); aturan hari itu yang menimpanya. **Catatan 2**: pemenangnya `if rule.priority >= winner.priority`, jadi pada prioritas **seri** yang menang adalah aturan **terakhir** dalam daftar, bukan "yang tertinggi". Saat ini keempat aturan berprioritas beda (0/10/30/40), jadi belum pernah kelihatan. |
| A31 | **BENAR** | Persis satu benda: **Toothbrush** (`toothbrush.tres`). **Hari 3 → RECYCLABLE**, **hari 4 → RESIDUE**. Penyebabnya `r_multilayer` (`is_multilayer: true` → RESIDUE, prioritas 30), yang baru aktif di hari 4. Diverifikasi dengan menjalankan ulang resolusi aturan untuk seluruh pool tiap hari; tidak ada benda lain yang berpindah kategori antar hari. |
| A32 | **BENAR** | `day_01.tres`: `available_tools = []`. Pool: Newspapers, Glass Bottle, Clean Paper Cup, Pizza Slice, Apple Core, Banana Peel, Eggshells, Dry Leaves. Satu-satunya aturan hari 1 (`r_baseline`) ber-`applies_when` kosong sehingga tidak pernah cocok, jadi kategori = `correct_category` masing-masing. Tidak satu pun dari delapan benda itu bernoda, berlaminasi, atau kimiawi. Semuanya terpilah dari nama + LOOKS LIKE + MARKING saja. |
| A33 | **SALAH** | R hanya di desk. Lihat Ringkasan. |
| A34 | **BENAR** | `inspect_panel._rebuild_rules()` selalu menggambar seluruh `day.active_rules` di panel `RulesList` di sebelah benda. Penandanya berbeda dan dua lapis: prefiks **"+ "** dengan warna hijau `(0.55, 0.95, 0.72)` untuk aturan yang buktinya terkumpul, **"- "** dengan abu-abu `(0.62, 0.68, 0.76)` untuk yang belum. "Buktinya terkumpul" = `RuleChecker.evidence_supports()`, yang menuntut aturan cocok **dan** setiap field yang jadi kuncinya sudah benar-benar dibuka pemain. |

### Technology dan Gear

| # | Vonis | Bukti |
|---|---|---|
| A35 | **BENAR** | Tiga mesin, nama persis di layar: **"Ocean Cleaning Drone"**, **"Recycling Station"**, **"Reef Restoration Pod"**. **Penggantian nama sudah dilakukan** — string "Hazardous Waste Neutraliser" tidak ada lagi di mana pun di pohon sumber. (`02_penetral_b3.res` masih muncul di cache editor `.godot/`, tapi itu sisa cache, bukan berkas sumber, dan tidak ikut ter-build.) |
| A36 | **SALAH** | Menuntut empat kategori, termasuk 5 HAZARDOUS. Lihat Ringkasan. |
| A37 | **BENAR** | Tidak ada koin/uang/kredit di mana pun. Yang ada: `budget` (per hari, tidak dibawa) dan `materials` (hitungan per kategori, dibelanjakan ke komponen). |
| A38 | **BENAR** | `equip_upgrade()` adalah toggle (`&"" if upgrade_id == equipped_upgrade else upgrade_id`), `equipped_upgrade` satu StringName tunggal, dan tidak ada `spend` di jalurnya. Gratis, bisa dibatalkan, satu terpasang. |
| A39 | **BENAR** | Kelima perlengkapan punya sisi untung **dan** sisi rugi — tidak ada peningkatan murni. Diperiksa satu per satu di tabel B8. (Catatan kecil: komentar `after_day.gd:522` menulis "all four always listed", padahal ada **lima** berkas di `data/upgrades/`. Kode-nya sendiri melooping seluruh array, jadi kelimanya tampil.) |
| A40 | **BENAR** | `after_day._make_gear_row()` menambahkan baris `+ benefit_text` (hijau) dan `- cost_text` (jingga) berurutan tanpa syarat, selama perlengkapannya terbuka. |

### Laporan akhir hari

| # | Vonis | Bukti |
|---|---|---|
| A41 | **BENAR** | `mistake_view.build_row()` menyusun, berurutan: gambar benda (`entry.data.texture`), nama benda, **"You put it in: {v}"**, **"Should have been: {v}"**, satu baris **"Never checked: {v}"** per properti penentu yang belum dibuka, lalu **"Broke: {v}"** berisi `broken_rule.text` lengkap. Label persis seperti dikutip. **Catatan**: bila `broken_rule == null` — yaitu setiap kesalahan di hari 1, karena `r_baseline` tidak pernah cocok — baris "Never checked:" dan "Broke:" **tidak muncul sama sekali**; kartunya hanya nama + dua baris bin. |
| A42 | **BENAR** | `missed_properties()` melooping `entry.broken_rule.applies_when` saja, lalu melewati apa pun yang `entry.is_revealed(field)`. Jadi bahkan lebih sempit dari klaim: hanya properti yang jadi kunci **aturan yang dilanggar**, dan hanya yang belum dibuka. |
| A43 | **BENAR** | Tidak ada nilai/poin di mana pun. Yang tampil hanyalah cacah: target `n/N`, sisa shift time, "Correct {ok} · wrong {bad} · unsorted {left}", jumlah material, "Machines built: {have} / {need}". `end_day_breakdown()` sendiri diberi komentar "a count of what happened, no points". |
| A44 | **BENAR** | `ending_tier()` = `clampi(unlocked_blueprints.size(), 0, blueprints.size())` = 0–3, dan `end_0_*` … `end_3_*` keempatnya ada di `Strings`. **Catatan**: hanya tier 0 dan 3 punya gambar sendiri; tier 1 dan 2 memakai `cutscene_04.png`. |

### Aset dan teknis

| # | Vonis | Bukti |
|---|---|---|
| A45 | **SALAH (sebagian)** | Ada satu elemen kode: `ColorRect` + `spotlight.gdshader` untuk peredup tutorial. Selain itu prinsipnya dipegang — uji statis "no drawn visuals, no 3D", "no shaders…", "panels are NinePatchRect over a PNG, never StyleBoxFlat", dan "no modulate expressing state on a game object" semuanya **PASS**, dan setiap keadaan memang PNG tersendiri (`panel_slot` / `panel_slot_selected`, `machine_left` / `machine_left_pressed`, `chip_surface` / `chip_reveal` / `chip_match`, `box_closed` / `box_opened`). Pengecualian yang perlu disebut: ending tier 1–2 memakai ulang `cutscene_04.png`, dan baris tool yang tidak tersedia diredupkan dengan `modulate.a` pada label teks. |
| A46 | **BENAR** | Tidak ada direktori `addons/`, tidak ada seksi `[editor_plugins]` di `project.godot`. |
| A47 | **BENAR** | Seluruh konten adalah `.tres`: 20 item, 4 aturan, 4 alat, 5 perlengkapan, 7 komponen, 3 blueprint, 5 hari. Uji statis "no per-asset special cases in code" (mencari `\.id *== *&?"`) **PASS**. Grep manual untuk setiap id item di dalam `.gd` tidak menemukan apa pun. Satu-satunya nama alat yang tertulis di kode adalah `&"rinse"` di `inspect_panel.gd:366`, dan itu hanya payload sinyal telemetri, bukan percabangan perilaku. |
| A48 | **SALAH (sebagian)** | Rincian di Ringkasan. |
| A49 | **SALAH** | Rincian di Ringkasan. |
| A50 | **SALAH** | Dua preset (Windows + Web), tapi template rilis x86_64 hilang dan `build/windows/` kosong. Rincian di Ringkasan. |

---

## 3. DATA

### B1 — Definisi bin dari sudut pandang pemain

Empat, bukan tiga. Diambil dari `Strings.GUIDANCE` + `tut_desk_bins_body` yang benar-benar dirender.

1. **ORGANIC** — apa pun yang membusuk: sisa makanan, sampah kebun, dan serat alam seperti katun dan wol.
2. **RECYCLABLE** — kertas, kaca, logam, dan plastik yang **bersih**, termasuk poliester (kain yang sebenarnya plastik tenun).
3. **HAZARDOUS** — apa pun yang terkena bahan kimia yang tidak bisa dicuci (oli, cat pelarut, pestisida, obat kedaluwarsa) dan logam beracun; kategori ini menang atas bahan penyusunnya.
4. **RESIDUE** — sisanya: benda yang nodanya belum dicuci, kemasan berlapis, benda multi-bahan yang lapisannya tak terpisahkan, dan tisu bekas.

### B2 — Tabel per hari

| Hari | Target | Shift time | Aturan yang mulai berlaku | Alat tersedia | Benda di pool | Sealed Crate |
|---|---|---|---|---|---|---|
| 1 | 5 | 90 | `r_baseline` (teks rulebook saja, tidak pernah memicu) | *tidak ada* | 8 | 0 |
| 2 | 6 | 110 | `r_residue` | Rinse, Magnifier, Cutter | 14 | 1 |
| 3 | 8 | 130 | `r_chem_residue` | Rinse, Magnifier, Chem Swab, Cutter | 19 | 1 |
| 4 | 10 | 150 | `r_multilayer` | Rinse, Magnifier, Chem Swab, Cutter | 20 | 2 |
| 5 | 12 | 160 | **tidak ada aturan baru** | Rinse, Magnifier, Chem Swab, Cutter | 23 | 2 |

Catatan: satu Sealed Crate berisi 2–3 benda tambahan (`box_contents_min/max`), diambil dari pool hari itu tanpa crate, jadi jumlah benda nyata di hari 2–5 lebih tinggi dari kolom "Benda di pool".

**Kontradiksi**: `intro_text` hari 5 berbunyi *"More rules and more items, on nearly the same shift time. Watch for the new foil rule."* — padahal hari 5 **tidak menambah aturan apa pun**; aturan foil/laminasi (`r_multilayer`) sudah masuk di hari 4. Lihat C2.

### B3 — Kenaikan dan biaya minimum

- **Kenaikan target hari 1 → 5**: 5 → 12 = **+140 %**.
- **Kenaikan Shift time hari 1 → 5**: 90 → 160 = **+77,8 %**.
- **Anggaran untuk sekadar memenuhi target** (lantai deterministik: setiap cengkeraman berhasil pada percobaan pertama; drop 6 + sort 1 = 7 per benda):
  - **Hari 1**: 5 × 7 = **35 dari 90** (38,9 %). Sisa 55, dan hari 1 tidak punya alat, jadi sisanya hanya bisa dipakai untuk mengambil lebih banyak benda.
  - **Hari 5**: 12 × 7 = **84 dari 160** (52,5 %). Sisa 76 — cukup untuk 19 penggunaan alat bagi 12 benda.
- Angka di atas belum memperhitungkan cengkeraman yang gagal. Peluang cengkeram rata-rata di hari 1 ≈ 0,9, jadi realistisnya sekitar 38 dari 90. Untuk benda terberat (Glass Bottle, weight 2.0) peluangnya 0,70, jadi rata-rata butuh 1,43 drop.

### B4 — Biaya tindakan final

Dari `game.gd:ACTION_COST`:

| Tindakan | Biaya | Catatan |
|---|---|---|
| Menjatuhkan capit | **6** | Terpotong saat turun dimulai, sebelum hasil diketahui. |
| Menggunakan alat | **4** | Terpotong walau tidak menemukan apa pun. |
| Memilah satu benda | **1** | Benar maupun salah. |
| Membuka Sealed Crate (Cutter) | **0** | `opens_containers = true` melewati `spend` sepenuhnya. |

Tindakan berbiaya lain: **tidak ada**. Gratis: pindah tampilan, rulebook, zoom/pan, memasang & melepas perlengkapan, merakit komponen, membangun mesin.

Perlengkapan mengubah biaya: Light Claw → drop 4; Coarse Scanner → tool 2 (tapi bacaan kedua tetap 4); Twin Arms → tool 3; Strong Grip → drop 8.

### B5 — Tabel aturan

Teks kolom "Teks di rulebook" adalah `text` verbatim; kolom "Teks di checklist" adalah `short_text` verbatim.

| Nama | Teks di rulebook (persis) | Teks di checklist (persis) | Syarat | Memaksa ke | Prioritas |
|---|---|---|---|---|---|
| `r_baseline` | "Sort by what it is made of: natural matter goes in ORGANIC; clean plastic, metal, glass and paper go in RECYCLABLE; chemicals go in HAZARDOUS; everything else goes in RESIDUE." | "What it is made of decides where it goes" | `{}` kosong — **tidak pernah cocok** | — (tidak pernah dipakai) | 0 |
| `r_residue` | "A stain still on it cannot be composted or recycled. Rinse it off and it is whatever it is made of again - leave it on and it goes in RESIDUE." | "Still stained  ->  RESIDUE" | `is_stained = true` | RESIDUE | 10 |
| `r_multilayer` | "Laminated packaging - paper, plastic and foil bonded together - cannot be separated, however clean it is. It goes in RESIDUE." | "Laminated packaging  ->  RESIDUE" | `is_multilayer = true` | RESIDUE | 30 |
| `r_chem_residue` | "Engine oil, solvent paint, pesticide and expired medicine do not rinse off. Whatever they soaked into is hazardous waste. This rule beats the stain rule." | "Chemical stain, will not rinse  ->  HAZARDOUS" | `stain_hazardous = true` | HAZARDOUS | 40 |

`r_baseline` berperilaku sebagai teks referensi saja: `RuleData.matches()` memulangkan `false` untuk `applies_when` kosong. Di rulebook ia masuk ke grup **"GENERAL"**. Di checklist samping benda ia **selalu tampil abu-abu dengan prefiks "- "**, tidak pernah menyala — padahal justru aturan itulah yang menentukan sebagian besar benda (lewat `item.correct_category`). Lihat C1.

### B6 — Dua pasangan jebakan terbaik

**1. Frayed Shirt vs Faded Shirt** — pasangan terkuat di game, hadir bersama di hari 2–5.

| | Frayed Shirt (`baju_organik`) | Faded Shirt (`baju_daur_ulang`) |
|---|---|---|
| Yang membuatnya sama | `visible_material` **"woven fabric"** pada keduanya; `weight` **0.6** pada keduanya; `visible_label` **kosong** pada keduanya; `surface_properties` keduanya diawali "soft" dan diakhiri "label washed out" | idem |
| Pembeda | `true_material` = "cotton - natural fibre" | `true_material` = "polyester - plastic woven into cloth" |
| Berakhir di | **ORGANIC** | **RECYCLABLE** |
| Alat yang membongkar | **Magnifier** — dan hanya magnifier. Tidak ada informasi gratis yang membedakan keduanya. | idem |

**2. Muddy Shirt vs Stained Shirt** — hadir bersama di hari 3–5.

| | Muddy Shirt (`baju_kotor`) | Stained Shirt (`baju_b3`) |
|---|---|---|
| Yang membuatnya sama | Sama-sama kemeja bernoda; `weight` 0.6 vs 0.7; keduanya `is_stained = true`; keduanya `true_material` katun; keduanya tanpa marking | idem |
| Pembeda | `stain_type` = "river mud", `stain_hazardous = false` | `stain_type` = "pesticide concentrate", `stain_hazardous = true` |
| Berakhir di | **RESIDUE** — atau **ORGANIC** kalau dirinse | **HAZARDOUS**, dan tidak bisa diselamatkan |
| Alat yang membongkar | **Chem Swab** (murah, langsung menamai) — atau **Rinse** sebagai jalan mahal: rinse yang gagal membuktikan nodanya kimia | idem |

Pasangan ketiga yang layak disebut tapi timpang: **Clean Paper Cup vs Paper Cup**. Keduanya `visible_material` "paper" dan `visible_label` "PAPER" — jebakan sempurna di atas kertas. Masalahnya, **Clean Paper Cup hilang dari pool sejak hari 4**, tepat ketika `r_multilayer` mulai berlaku. Jadi pasangan kembar itu hanya pernah muncul bersama di hari 2–3, di mana yang membedakan cuma noda (Chem Swab / Rinse), bukan laminasi (Magnifier).

### B7 — Isi Rulebook

Yang benar-benar dirender oleh `rulebook_panel._rebuild()`, berurutan:

1. **Judul "RULEBOOK"**, lalu aturan hari itu, **dikelompokkan menurut bin yang dipaksakan** (heading = nama bin), dengan aturan tanpa syarat masuk ke grup **"GENERAL"**. Tiap aturan ditulis "-  " + `text` lengkap.
2. **"WHERE THINGS GO"** + catatan pengantar, lalu satu blok per bin dalam urutan enum (ORGANIC → RECYCLABLE → HAZARDOUS → RESIDUE). Tiap blok diawali plat bin + nama bin, lalu baris-baris dari `Strings.GUIDANCE` — **14 baris total**.
3. **"WHAT THE RECYCLING CODES MEAN"** + catatan, lalu **11 baris kode**.
4. Tombol **"Close"**.

**Glosarium kode resin: MASIH ADA dan BENAR-BENAR TAMPIL.** `_add_glossary()` dipanggil tanpa syarat di setiap cabang `_rebuild()`, jadi ia muncul setiap kali rulebook dibuka. Isinya 11 entri: PET 1, HDPE 2, PVC 3, PE, PS 6, PP 5, PA 6, PAP, ALU, GL, Pb.

**Tetapi kode-kodenya sebagian besar tidak muncul sebagai penanda pada benda mana pun.**

- Kode glosarium yang **benar-benar** muncul sebagai penanda tercetak (`visible_label`, chip "MARKING:") pada minimal satu benda:
  - **HDPE 2** → Plastic Bag
  - **PP 5** → Toothbrush
  - **GL** → Glass Bottle ("GL 71") dan Sauce Jar ("GL 70") — kecocokan awalan, bukan persis
- Kode yang muncul **hanya di dalam bacaan Magnifier** (`true_material`), bukan sebagai penanda: **PAP** (PAP 21 pada Clean Paper Cup, PAP 22 pada Paper Cup), **PE** (di dalam teks "PAP 22 - paper bonded to a PE liner")
- Kode glosarium yang **tidak muncul pada benda mana pun sama sekali**: **PET 1, PVC 3, PS 6, PA 6, ALU, Pb** — enam dari sebelas
- Kebalikannya: penanda **"PAPER"** dipakai tiga benda (Newspapers, Clean Paper Cup, Paper Cup) tapi **tidak ada di glosarium** — glosariumnya menulis "PAP"

Jadi klaim glosariumnya boleh dipertahankan; yang perlu diperhalus adalah kesan bahwa kode-kode itu dipakai luas di dalam permainan. Tiga kode dipakai sebagai penanda, dan salah satunya hanya lewat awalan.

### B8 — Tabel perlengkapan

Kolom "keuntungan"/"kerugian" adalah `benefit_text`/`cost_text` verbatim, persis seperti tampil di tab Gear.

| Nama | Keuntungan | Kerugian | Syarat terbuka | Bisa terbuka dalam satu run 5 hari? |
|---|---|---|---|---|
| **Light Claw** | "Dropping the claw costs 4 shift time instead of 6." | "Its grip is weaker: the chance of holding on drops by 15 points." | Terbuka sejak awal (`unlock_after_blueprints = 0`) | **Ya** — tersedia dari layar akhir hari 1 |
| **Coarse Scanner** | "Using a tool costs 2 shift time instead of 4." | "The reading is coarse - it only tells you something is there. Reading it properly costs one more use at the normal price." | Terbuka sejak awal | **Ya** |
| **Fast Rail** | "The claw travels the rail 60% faster." | "After every drop the rail needs 2 seconds to reset before it will move again." | "Unlocked once the Ocean Cleaning Drone is built." | **Ya** — paling cepat di akhir hari 2 (butuh ORGANIC 3, RECYCLABLE 2, RESIDUE 1; hari 1 sama sekali tidak menghasilkan RESIDUE, jadi tidak mungkin di akhir hari 1) |
| **Strong Grip** | "Grip chance goes up by 15 points." | "Dropping the claw costs 8 shift time instead of 6." | "Unlocked once the Recycling Station is built." | **Ya**, secara teori — butuh tambahan ORGANIC 2, RECYCLABLE 4, RESIDUE 3 |
| **Twin Arms** | "Using a tool costs 3 shift time instead of 4." | "The extra arm weighs the rail down: the claw travels 25% slower." | "Unlocked once the Reef Restoration Pod is built." | **Terbuka, tapi praktis tidak pernah sempat dipakai.** Pod butuh 5 HAZARDOUS, dan HAZARDOUS baru ada mulai hari 3. Kalau Pod baru selesai di layar akhir hari 5, perlengkapan ini terbuka tepat ketika run berakhir — tidak ada shift tersisa untuk memasangnya |

Kelimanya adalah pertukaran sejati — tidak ada yang murni untung. `UpgradeData.is_trade_off()` mengonfirmasi ini secara struktural, dan uji `smoke_upgrades` **PASS**.

### B9 — Kebutuhan material total

Per komponen:

| Komponen | Mesin | ORGANIC | RECYCLABLE | HAZARDOUS | RESIDUE |
|---|---|---|---|---|---|
| Drone Shell | Ocean Cleaning Drone | 1 | 2 | – | – |
| Rotor Skid | Ocean Cleaning Drone | 2 | – | – | 1 |
| Intake Arm | Recycling Station | – | 2 | – | – |
| Sorting Belt | Recycling Station | – | – | – | 3 |
| Press Housing | Recycling Station | 2 | 2 | – | – |
| Pod Shell | Reef Restoration Pod | 2 | – | – | 3 |
| Seeding Arm | Reef Restoration Pod | – | – | 5 | – |

Per mesin: Ocean Cleaning Drone = 3 ORG / 2 REC / 1 RES (6). Recycling Station = 2 ORG / 4 REC / 3 RES (9). Reef Restoration Pod = 2 ORG / 5 HAZ / 3 RES (10).

**Total ketiga mesin: ORGANIC 7, RECYCLABLE 6, HAZARDOUS 5, RESIDUE 7 = 25.**

- **Pemilahan benar minimum**: **25**. Satu pemilahan benar = satu satuan material di kategorinya, tidak ada sumber lain.
- **Akumulasi target lima hari**: 5 + 6 + 8 + 10 + 12 = **41**.

Jadi 25 dari 41 pemilahan (61 %) harus **benar dan tepat kategorinya** — bukan sekadar memenuhi target.

Pasokan yang bisa ditemukan (kategori hasil resolusi aturan, pool dasar, crate tidak dihitung):

| Kategori | Butuh | Bisa ditemukan | Margin |
|---|---|---|---|
| ORGANIC | 7 | 23 | +16 |
| RECYCLABLE | 6 | 18 | +12 |
| **HAZARDOUS** | **5** | **7** | **+2** |
| RESIDUE | 7 | 36 | +29 |

HAZARDOUS hanya berasal dari dua jenis benda (Stained Shirt, Chemical-Soaked Tissue), yang total muncul 7 kali di hari 3–5. Inilah yang menggagalkan `smoke_tech`. Lihat C4.

### B10 — Empat ending

Syarat = jumlah mesin yang dibangun (`Game.ending_tier()` = `unlocked_blueprints.size()`). Judul persis seperti di layar:

| Mesin dibangun | Judul persis | Gambar |
|---|---|---|
| 0 | **"THE BAY WAS LEFT AS IT WAS"** | `ending_bad.png` |
| 1 | **"A FIRST MACHINE"** | `cutscene_04.png` (pinjaman) |
| 2 | **"THE WATER IS TURNING"** | `cutscene_04.png` (pinjaman) |
| 3 | **"THE BAY CAME BACK"** | `ending_good.png` |

Setiap layar juga menampilkan `end_N_body` dan baris "Machines built: {have} / {need}", plus tombol "Try Again" dan "Main Menu".

### B11 — Jumlah aset final

| Jenis | Jumlah | Catatan |
|---|---|---|
| **PNG** | **128** dipakai game + **14** di `assets/newaset/` = **142** total | Ke-14 di `assets/newaset/` **tidak dirujuk kode/scene/tres mana pun**, tapi punya berkas `.import` dan preset memakai `export_filter="all_resources"`, jadi tetap ikut terpaket. 10 PNG lain di dalam pohon utama juga tidak dirujuk: `button_normal/pressed/disabled` (tersisa dari tema lama), `meter_bg`, `meter_fill`, `desk_meter_frame`, `icon_pause`, `icon_pause_pressed`, `coral_dead`, `coral_healthy`. |
| **WAV** | **11** | Semuanya di `assets/audio/`, semuanya dipakai. (`assets/newaset/sea-bgm.wav` menjadikannya 12 kalau folder staging ikut dihitung.) |
| **MP3** | **2** dipakai (`music_game.mp3`, `amb_sea.mp3`) + 1 di staging | Keduanya bed musik, di-loop lewat kode. |
| **Font** | **2 berkas, satu keluarga: Fredoka Medium + Fredoka SemiBold** | **Bukan bawaan engine.** Berlisensi OFL (`assets/ui/fonts/OFL.txt`). Terpasang lewat `ui_theme.tres` (`default_font` = Medium, Button/PrimaryButton = SemiBold), yang di-apply project-wide dari `project.godot`. |
| SVG | 1 (`icon.svg`) | Ikon project bawaan Godot, belum diganti. |

### B12 — Versi Godot

**Godot 4.7.2.stable.official.ed1daf0bf** (binari di mesin ini). `project.godot` menulis `config/features=PackedStringArray("4.7", "GL Compatibility")`; renderer `gl_compatibility`.

### B13 — Durasi rata-rata satu run

**Tidak bisa diukur.** Tidak ada telemetri durasi di dalam game, tidak ada catatan playthrough di repo, dan run headless (`smoke_full`) menyelesaikan lima hari dalam hitungan detik karena tidak ada manusia yang mengambil keputusan — angkanya tidak mewakili apa pun. Aku tidak menebak.

Yang bisa dinyatakan sebagai fakta struktural, bukan sebagai jawaban atas pertanyaannya:
- Satu siklus capit ≈ **2,4 detik** waktu mesin (turun 189 px @ 160 px/s = 1,18 s; menutup 0,30 s; naik 189 px @ 200 px/s = 0,95 s), belum termasuk waktu membidik.
- Benda baru masuk tiap **8–14 detik** di semua hari, dan langsung menyusul bila jumlah di laut turun di bawah `min_available_items` (2).
- Akhir shift menahan layar **1,4 detik** (atau 3,0 detik untuk dua baris penutup khusus).
- Cutscene pembuka 11 beat, maju hanya lewat klik/Enter, bisa dilewati dengan Esc.
- Anggaran lima hari total 640 satuan; pada 7 satuan per benda yang diambil-dan-dipilah, itu berarti langit-langit sekitar 91 benda per run.

Untuk mengisi tabel proposal, angka ini harus datang dari playthrough yang benar-benar diukur dengan stopwatch.

---

## 4. KONTRADIKSI

### C1 — Mekanik yang bekerja tapi tidak pernah terlihat pemain

1. **`surface_properties` — yang terbesar.** Ditulis lengkap dan bagus di 20 dari 20 item ("stiff, slick surface, light" untuk Paper Cup, "crust around the rim, smells sweet" untuk Sauce Jar). `ItemData.surface_label()` ada untuk merangkainya. **Nol pemanggil.** Tidak ada satu pun panel yang menampilkannya. Ini persis informasi yang diklaim A16 sebagai gratis.
2. **Peluang cengkeram.** Dihitung per benda, dipakai untuk roll, tapi `_grip_label` selalu dikosongkan. Pemain tidak pernah tahu bahwa botol kaca 2 kg hanya 70 % dan daun 0,1 kg 95 % — padahal itu keputusan ekonomi yang nyata (6 satuan per drop).
3. **`ToolData.reveals_field`.** Diisi di keempat `.tres` alat (`swab` → `stain_type`, `magnifier` → `true_material`). **Tidak pernah dibaca kode mana pun.** Pemetaan alat→field yang sebenarnya dipakai hidup di `hotspots` tiap item. Data mati yang tampak otoritatif.
4. **`ItemData.source_batch`.** Diisi di semua 20 item (`household`, `beach_cafe`, `textile_mill`, `coastal_workshop`, `drinks_plant`, `current_delivery`) dan terdaftar di `RuleChecker.SURFACE_KEYS` sebagai "gratis dibaca" — tapi tidak pernah dirender. Sebuah aturan yang mengunci pada `source_batch` akan bekerja secara mekanis dan tidak akan pernah bisa dibuktikan pemain.
5. **`r_baseline` tidak pernah menyala.** `applies_when` kosong → `matches()` selalu `false`. Di checklist samping benda ia permanen abu-abu dengan "- ", padahal justru aturan itu yang menentukan sebagian besar benda. Pemain melihat aturan utama permainan seolah tidak pernah berlaku.
6. **Sealed Crate yang tidak sempat dibuka lenyap tanpa jejak.** Sudah ditandai `TODO` di `game.gd:sealed_containers()`: tidak masuk laporan, tidak masuk hasil hari itu, tidak disebut di mana pun.
7. **`bin_row.flash()` adalah stub kosong.** Empat pemanggil di `desk_phase.gd` masih meneruskan argumen `accepted: bool` yang tidak menghasilkan apa-apa.
8. **`Events.grip_preview_changed`** dideklarasikan, tidak pernah di-emit, tidak pernah di-connect. **`Game.total_materials()`** juga sudah ditandai tidak dipakai di komentarnya sendiri.
9. **Tidak ada meter anggaran.** `Events.budget_changed` dipancarkan rajin, tapi hanya menghidupkan label angka telanjang. `meter_bg.png`, `meter_fill.png`, dan `desk_meter_frame.png` ada di disk dan tidak dirujuk siapa pun.

### C2 — Teks di layar yang menyebut sesuatu yang tidak berlaku

1. **`intro_text` hari 5** (tampil di layar pembukaan hari, tidak bisa dilewatkan): *"…Watch for the new foil rule."* — **Hari 5 tidak menambah aturan apa pun.** `active_rules` hari 5 identik dengan hari 4. Aturan laminasi masuk di hari 4, dan `intro_text` hari 4 sudah mengumumkannya dengan benar. Pemain akan mencari aturan baru yang tidak ada.
2. **`tut_desk_outcome_body`** (tutorial, tampil di run pertama): *"\"MARKING: PET 1\" is a code the magnifier read."* — **dua kesalahan sekaligus.** (a) Tidak ada satu pun benda di game yang bertanda PET 1. (b) "MARKING:" adalah chip **gratis** yang berasal dari `visible_label`; magnifier tidak pernah menghasilkannya — magnifier menulis chip **"MADE OF:"**. Ini mengajarkan hubungan alat→chip yang salah pada momen pertama pemain belajar.
3. **Glosarium rulebook** memuat enam kode yang tidak dipakai benda mana pun: **PET 1, PVC 3, PS 6, PA 6, ALU, Pb**. Yang paling menonjol **Pb**, karena `Strings.GUIDANCE` juga punya baris HAZARDOUS khusus untuknya ("Toxic metals — anything marked Pb (lead)") padahal tidak ada benda berlabel Pb. Sebaliknya penanda **"PAPER"** dipakai tiga benda tapi tidak ada di glosarium.
4. **Kunci string `machines_title`** berisi teks **"Cost per drop"** dan dipasang pada `MachinesTitle` di HUD capit — nama kunci dan isinya bicara hal berbeda. Yang tampil di layar benar; hanya penamaan internalnya sisa desain lama.
5. **Nama berkas `bin_landfill.png`** untuk kategori yang sekarang bernama RESIDUE. Tidak terlihat pemain, tapi terlihat juri kalau mereka membuka isi build, dan sudah dikomentari di dua tempat sebagai utang yang disengaja.
6. **`assets/ASSETS.md`** menulis `InspectPanel.TOOL_ICON_SCALE = 0.85`; kodenya `0.62`. **`BUILD.md`** menulis "34 pemeriksaan"; `run_all.sh` menjalankan **33**. `BUILD.md` juga menyatakan template Windows belum terpasang, padahal sebagian besar sudah. Ketiganya dokumen internal, bukan teks layar.

### C3 — Dua tempat yang menampilkan angka berbeda untuk hal yang sama

**Ada satu, dan berdampak nyata pada anggaran.**

Dengan **Coarse Scanner** terpasang, baris tool di rak selalu menulis **"costs 2"** (`inspect_panel._refresh_rack()` memakai `Game.cost_of(&"tool")` tanpa syarat). Tetapi bacaan **kedua** pada field yang sama dipotong `Game.base_cost(&"tool")` = **4**, bukan 2:

```
inspect_panel.gd:305   var second_reading := Game.coarse_readings() and field != "" and entry.is_probed(field)
inspect_panel.gd:307   var cost := Game.base_cost(&"tool") if second_reading else Game.cost_of(&"tool")
```

Jadi rak berkata 2, kas terpotong 4. Baris feedback setelahnya memang menyebut biaya sebenarnya (`"…(shift time -4)"`), tapi itu muncul **setelah** pemain memutuskan. `cost_text` perlengkapan itu sendiri memperingatkan ("Reading it properly costs one more use at the normal price"), jadi ini lebih ke label rak yang tidak ikut menyesuaikan diri daripada mekanik yang tersembunyi — tetap saja, dua angka untuk satu hal.

Selain itu **tidak ada** ketidakcocokan angka: biaya drop di HUD capit (`cost_of("drop")`) sama dengan yang dipotong; Cutter tertulis "free" dan memang nol; biaya sort tidak pernah diubah perlengkapan mana pun.

### C4 — Jalan buntu

**Tidak ada jalan buntu yang menghentikan pemain**, tapi **ada satu yang membuat ending terbaik rapuh**, dan uji otomatisnya sudah menangkapnya.

Yang **aman**:
- Shift selalu bisa berakhir. `can_still_act()` menutup lubang crate-tersegel-dengan-anggaran-nol secara eksplisit (crate hanya dihitung sebagai pekerjaan tersisa bila ada pembukanya **dan** masih ada anggaran untuk memilah isinya). Tanpa itu, shift bisa hidup selamanya di anggaran kosong.
- `_check_shift_over()` juga mengakhiri shift saat laut dan meja kosong, jadi tidak ada keadaan "tidak ada yang bisa dilakukan tapi hari tidak selesai".
- Bin selalu bisa diklik; benda yang tidak bisa dipilah (crate tersegel) selalu punya jalan keluar lewat Cutter yang gratis dan tersedia sejak hari 2.
- Kalkulasi material tidak pernah negatif (`craft_component` memeriksa keterjangkauan seluruh biaya lebih dulu), dan uji `smoke_tech` bagian itu **PASS**.

Yang **rapuh — dan ini penyebab satu-satunya kegagalan uji**:

> `smoke_tech` FAIL: *"B3: blueprints need 5 but only 7 are findable across all five days (margin +2, want at least +3). A player who mis-sorts a couple can no longer reach the good ending."*

Reef Restoration Pod menuntut **5 HAZARDOUS** lewat Seeding Arm. HAZARDOUS hanya keluar dari dua jenis benda — Stained Shirt dan Chemical-Soaked Tissue — yang baru muncul di hari 3 dan total **7 kali** di seluruh run (hari 3: 2, hari 4: 2, hari 5: 3). Margin **+2**, sementara uji menuntut minimal +3.

Konsekuensi nyatanya: pemain yang salah memilah **tiga** benda hazardous saja — atau gagal mencapainya di laut, atau kehabisan anggaran sebelum sempat mengambilnya — **tidak lagi bisa membangun mesin ketiga**, dan ending "THE BAY CAME BACK" jadi mustahil, tanpa game pernah memberi tahu bahwa pintunya sudah tertutup. Ini juga membuat Twin Arms praktis tak terjangkau (lihat B8).

Perlu dicatat juga bahwa hari 5 punya 25 benda di laut tapi anggaran 160 — cukup untuk sekitar 22 pengambilan-dan-pemilahan tanpa alat sama sekali. Hari 5 memang dirancang agar tidak semuanya bisa diambil, jadi benda hazardous di hari 5 bersaing dengan sisanya untuk anggaran yang sama.

### C5 — `feature_calibration_puzzle` dan `config/name`

- **`feature_calibration_puzzle`: flag ini sudah tidak ada sama sekali.** Bukan `false` — **tidak ada**. Grep ke seluruh repo hanya menemukannya di `PROPOSAL_ISI.md:1406`, yang menyebut "satu-satunya pemanggil di `after_day.gd`". Di `after_day.gd` sekarang tidak ada flag itu, tidak ada pemanggilnya, dan `project.godot` tidak punya entri apa pun untuknya. Klaim proposal tentang flag ini perlu dihapus, bukan diperbaiki.
- **`config/name` sudah `"Re:Sea"`** ✓ (`project.godot` baris 12). `export_presets.cfg` juga konsisten: `application/product_name="Re:Sea"` dan `application/file_description="Re:Sea"`.

---

## 5. HASIL UJI OTOMATIS

Dijalankan `./tests/run_all.sh` di akhir validasi. **33 pemeriksaan, 32 PASS, 1 FAIL, exit code 1.** Tidak ada yang diperbaiki.

```
Rules:
  PASS  no tweens in game-object scripts
  PASS  no tweened transforms or frames on game objects
  PASS  no drawn visuals, no 3D
  PASS  no shaders, lighting or runtime textures
  PASS  panels are NinePatchRect over a PNG, never StyleBoxFlat
  PASS  no modulate expressing state on a game object
  PASS  sprites are scaled only by a named display constant
  PASS  no per-asset special cases in code
  PASS  every Control class used is covered by the theme
  PASS  the theme is applied project-wide
  PASS  exactly two autoloads
Boot:
  PASS  boots (2 frames)
  PASS  boots (240 frames)
Systems:
  PASS  smoke_claw
  PASS  smoke_desk
  PASS  smoke_shift
  PASS  smoke_shift_end
  PASS  smoke_inspect
  PASS  smoke_layout
  PASS  smoke_parallax
  PASS  smoke_report
  PASS  smoke_ending
  PASS  smoke_box
  FAIL  smoke_tech
        SCRIPT ERROR: Assertion failed: B3: blueprints need 5 but only 7 are
        findable across all five days (margin +2, want at least +3). A player
        who mis-sorts a couple can no longer reach the good ending.
  PASS  smoke_upgrades
  PASS  smoke_upgrade_play
  PASS  smoke_settings
  PASS  smoke_debug
  PASS  smoke_extensibility
  PASS  smoke_full
  PASS  smoke_claw --fail
  PASS  smoke_full --bad
  PASS  smoke_shift day 1
FAILURES above.
```

Satu-satunya kegagalan adalah pasokan HAZARDOUS di C4. Aku memverifikasi angkanya secara terpisah dengan menghitung ulang resolusi aturan untuk seluruh pool kelima hari, dan hasilnya cocok persis dengan uji: ORGANIC +16, RECYCLABLE +12, **HAZARDOUS +2**, RESIDUE +29.

Catatan tambahan yang ditemukan saat memeriksa build, di luar cakupan uji: **`scenes/after_day/day_report.tscn` rusak.** Ia merujuk `res://scenes/report/day_report.gd`, dan direktori `scenes/report/` tidak ada. Scene ini yatim — tidak terdaftar di `main.SCENES` dan tidak pernah dimuat saat bermain, jadi tidak berdampak pada permainan — tetapi `export_filter="all_resources"` berarti ia tetap ikut terpaket ke dalam build.
