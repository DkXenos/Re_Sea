# CROSSCHECK_HASIL.md

Ditelusuri terhadap source tree pada commit `1da66f4` (branch `main`).
Tidak ada berkas yang diubah.

> **BACA INI DULU — build yang ada di `build/` sudah basi.**
> `build/web/index.pck` dibuat **7 Sep 22:37**, sementara source terakhir diubah
> **8 Sep**. Isi paket itu masih memuat `data/upgrades/00_cakar_ringan.tres`
> ("Light Claw") dan `01_pemindai_kasar.tres` ("Coarse Scanner") — dua berkas
> yang **sudah tidak ada** di source — plus node `GearTab` / `GearPage`, dan
> aset `ending_bad.png` / `ending_good.png` yang juga sudah tidak ada. Paket itu
> tidak memuat scene tutorial sama sekali.
> Artinya: juri yang memainkan `build/Re-Sea-web.zip` sekarang akan melihat
> versi lama dengan tab Gear dan 5 perlengkapan. Seluruh vonis di bawah dibuat
> terhadap **source**, bukan terhadap paket basi itu. Build ulang dulu sebelum
> mengirim apa pun.

---

## A. YANG BEDA ATAU HILANG

| # | Vonis | Yang benar |
|---|---|---|
| 8 | **BEDA** | Layar akhir hari punya **DUA** tab, bukan tiga: "The Day" dan "Technology". Tab Gear dihapus (`after_day.gd:32-36`, `enum Tab { RESULT, TECH }`). |
| 13 | **BEDA** | Yang berjalan lintas hari ada **tiga** hal, bukan empat: material di gudang, komponen yang dirakit, dan mesin yang dibangun. Tidak ada lagi "perlengkapan yang terpasang" sebagai hal terpisah. |
| 14 | **BEDA** | Tiga jalur itu masih ada, tetapi tombol End Shift kini **menolak** sampai target hari itu terpenuhi (`shift_phase.gd:76-84`, `desk_phase.gd:66-71`); tombolnya berbunyi "Sort {n} more". |
| 15 | **BEDA** | Kalimat lengkapnya: "Every last piece out of the water and into a bin. **The seabed is clear.**" |
| 19 | **BEDA** | Hari 4: Shift time **164** (bukan 150) dan **23 benda** di pool (bukan 20). Target 10, aturan berlapis, keempat alat, 2 peti — semuanya cocok. |
| 20 | **BEDA** | Hari 5: Shift time **174** (bukan 160) dan **26 benda** di pool (bukan 23). Target 12, tanpa aturan baru, keempat alat, 2 peti — semuanya cocok. |
| 21 | **BEDA** | Target naik 140 % (5→12) benar; Shift time naik **93,3 %** (90→174), bukan 78 %. |
| 22 | **BEDA** | Hari 1: 35 dari 90 benar. Hari 5: 84 dari **174**, bukan dari 160. |
| 49 | **BEDA** | Semua yang disebut memang gratis **kecuali "memasang perlengkapan", yang sudah tidak ada**. Membuka peti juga gratis dan belum disebut. |
| 71 | **BEDA** | Target memang dihitung dari benda yang dipilah benar maupun salah, tetapi **sekarang punya konsekuensi mekanis**: shift tidak bisa diakhiri lewat tombol sampai target terpenuhi. |
| 84 | **BEDA** | Tiga bagian benar; "WHERE THINGS GO" memang 14 baris. Tetapi judul glosariumnya **"WHAT THE LABELS AND MATERIALS MEAN"** (bukan "WHAT THE RECYCLING CODES MEAN") dan isinya **13 entri**, bukan 11. |
| 85 | **BEDA** | Ada **empat** nilai MARKING yang benar-benar tercetak pada benda: HDPE 2 (kantong plastik), PP 5 (sikat gigi), GL 71 / GL 70 (botol kaca / toples saus), dan **PAPER** (koran, gelas kertas bersih, gelas kertas). |
| 105 | **HILANG** | Tidak ada tab Gear dan tidak ada yang dipasang. Mesin yang selesai dibangun **langsung menyala dan tetap menyala sampai akhir run**; ketiganya berjalan bersamaan di akhir (`game.gd:501-515`, `upgrade_data.gd:4-10`). Tidak gratis/tidak-gratis, tidak bisa dibatalkan, tidak satu-satu. |
| 106 | **BEDA** | Ketiga perlengkapan yang tersisa **murni untung, tanpa pertukaran**. Dua field kerugian (`coarse_readings`, `post_drop_lockout`) masih bisa diisi tetapi tidak ada satu pun yang mengisinya. |
| 107 | **HILANG** | **Light Claw tidak ada** di source. Hanya ada tiga perlengkapan: Fast Rail, Strong Grip, Twin Arms. |
| 108 | **HILANG** | **Coarse Scanner tidak ada** di source. Jalur kode bacaan-kasar masih hidup di `inspect_panel.gd:293-308` tetapi tidak ada perlengkapan yang menyalakannya. |
| 109 | **BEDA** | Fast Rail: capit 60 % lebih cepat benar (`move_speed_multiplier = 1.6`). **Tidak ada** pemulihan rel 2 detik — `post_drop_lockout = 0.0`. |
| 110 | **BEDA** | Strong Grip: peluang cengkeram naik 15 poin benar (`grip_delta = 0.15`). Drop **tetap 6**, bukan 8 — `drop_cost = -1`. |
| 111 | **BEDA** | Twin Arms: alat 3 bukan 4 benar (`tool_cost = 3`). **Tidak ada** perlambatan capit 25 % — `move_speed_multiplier = 1.0`. |
| 114 | **BEDA** | Baris "Never checked:" hanya muncul untuk properti **satu aturan yang dilanggar**, bukan setiap properti penentu (`mistake_view.gd:15-28`). Kalau tidak ada aturan yang menyala — misalnya Faded Shirt dimasukkan ke ORGANIC — `broken_rule` bernilai null dan **tidak ada baris "Never checked:" sama sekali**, padahal MADE OF-lah yang menentukan. |
| 118 | **BEDA** | Selain keempat cacah itu, layar juga menampilkan "Target reached"/"Target missed", "{n} sorted wrongly - lost, not stored.", dan "Shift time used {spent} of {max}, {left} left". |
| 120 | **HILANG** | Baris itu tidak ada di mana pun. Naskah pembuka adalah 11 beat di atas 5 gambar (`open_1`–`open_11`). Yang paling dekat adalah `open_11`: "Lower the claw. Look before you decide." |
| 130 | **BEDA** | **120 PNG** yang benar-benar dipakai (117 dirujuk lewat path harfiah + `ending_1/2/3.png` yang diselesaikan lewat `ending_%d.png`), bukan 128. Total PNG di bawah `assets/` ada 150. |
| 137 | **BEDA** | **3 perlengkapan**, bukan 5. Sisanya cocok: 20 benda, 4 aturan, 4 alat, 7 komponen, 3 mesin, 5 hari. |
| 138 | **BEDA** | Benda/aturan/alat/hari/komponen/blueprint/perlengkapan memang `.tres`, tetapi dua tabel rujukan Rulebook (`Strings.GUIDANCE` 14 baris, `Strings.MATERIALS` 13 baris), seluruh teks antarmuka (193 kunci), daftar beat cutscene, dan 19 langkah tutorial hidup di dalam berkas `.gd`. |

**Jawaban untuk nomor 39 (kamu minta dicek terbalik):**
**TIDAK.** Pratinjau peluang cengkeram **tidak** ditampilkan. `_update_grip_preview`
(`claw_phase.gd:453-469`) menulis `""` ke `GripLabel` di **setiap** cabang yang bisa
dicapai; komentar di dalamnya menyebut angka itu memang sengaja dibuang. Satu-satunya
cabang berisi teks adalah pesan rel-terkunci, dan itu mustahil tercapai karena
`post_drop_lockout` selalu 0. Jangan tambahkan klaim itu ke proposal.

---

## B. VONIS LENGKAP

| # | Vonis | # | Vonis | # | Vonis | # | Vonis |
|---|---|---|---|---|---|---|---|
| 1 | OK | 38 | OK | 75 | OK | 112 | OK |
| 2 | OK | 39 | *jawaban di atas* | 76 | OK | 113 | OK |
| 3 | OK | 40 | OK | 77 | OK | 114 | **BEDA** |
| 4 | OK | 41 | OK | 78 | OK | 115 | OK |
| 5 | OK | 42 | OK | 79 | OK | 116 | OK |
| 6 | OK | 43 | OK | 80 | OK | 117 | OK |
| 7 | OK | 44 | OK | 81 | OK | 118 | **BEDA** |
| 8 | **BEDA** | 45 | OK | 82 | OK | 119 | OK |
| 9 | OK | 46 | OK | 83 | OK | 120 | **HILANG** |
| 10 | OK | 47 | OK | 84 | **BEDA** | 121 | OK |
| 11 | OK | 48 | OK | 85 | **BEDA** | 122 | OK |
| 12 | OK | 49 | **BEDA** | 86 | OK | 123 | OK |
| 13 | **BEDA** | 50 | OK | 87 | OK | 124 | OK |
| 14 | **BEDA** | 51 | OK | 88 | OK | 125 | OK |
| 15 | **BEDA** | 52 | OK | 89 | OK | 126 | OK |
| 16 | OK | 53 | OK | 90 | OK | 127 | OK |
| 17 | OK | 54 | OK | 91 | OK | 128 | OK |
| 18 | OK | 55 | OK | 92 | OK | 129 | OK |
| 19 | **BEDA** | 56 | OK | 93 | OK | 130 | **BEDA** |
| 20 | **BEDA** | 57 | OK | 94 | OK | 131 | OK |
| 21 | **BEDA** | 58 | OK | 95 | OK | 132 | OK |
| 22 | **BEDA** | 59 | OK | 96 | OK | 133 | OK |
| 23 | OK | 60 | OK | 97 | OK | 134 | OK |
| 24 | OK | 61 | OK | 98 | OK | 135 | OK |
| 25 | OK | 62 | OK | 99 | OK | 136 | OK |
| 26 | OK | 63 | OK | 100 | OK | 137 | **BEDA** |
| 27 | OK | 64 | OK | 101 | OK | 138 | **BEDA** |
| 28 | OK | 65 | OK | 102 | OK | 139 | OK |
| 29 | OK | 66 | OK | 103 | OK | 140 | OK |
| 30 | OK | 67 | OK | 104 | OK | | |
| 31 | OK | 68 | OK | 105 | **HILANG** | | |
| 32 | OK | 69 | OK | 106 | **BEDA** | | |
| 33 | OK | 70 | OK | 107 | **HILANG** | | |
| 34 | OK | 71 | **BEDA** | 108 | **HILANG** | | |
| 35 | OK | 72 | OK | 109 | **BEDA** | | |
| 36 | OK | 73 | OK | 110 | **BEDA** | | |
| 37 | OK | 74 | OK | 111 | **BEDA** | | |

Rekap dari 140 klaim: **114 OK, 21 BEDA, 4 HILANG, 1 pertanyaan terbalik (39).**
Nomor 141–146 dijawab di bagian C.

### Catatan pada beberapa vonis OK

- **1** — `godot --version` → `4.7.2.stable.official`; `renderer/rendering_method="gl_compatibility"`.
- **2** — semua teks dalam permainan berbahasa Inggris. `item_card.tscn:55,62` menyimpan teks Indonesia ("Kantong Plastik", "Butuh: Cutter") sebagai placeholder editor, tetapi `setup()` menimpanya sebelum kartu tampil, jadi tidak pernah terlihat.
- **3** — hanya build Web yang ada di disk (`build/web/`, `build/Re-Sea-web.zip`). Ada preset export "Windows Desktop" di `export_presets.cfg`, tetapi tidak ada `.exe` yang dihasilkan. Seluruh folder `build/` masuk `.gitignore`, jadi tidak ikut di repo.
- **34** — angkanya persis, bukan kira-kira: `clampf(1.0 - berat * 0.15 + grip_delta, 0.05, 0.95)`. Botol kaca 2,0 kg → **70,0 %**. Daun kering 0,1 kg → 98,5 % yang lalu dijepit ke **95 %**.
- **38** — tidak ada RigidBody, joint, atau gravitasi; gerak capit murni interpolasi posisi dan satu `randf()`. Deteksi sentuhannya memakai tumpang-tindih `Area2D`, jadi server fisika 2D Godot tetap ikut terpakai untuk mendeteksi kontak — bukan untuk menggerakkan apa pun.
- **46** — 4 adalah harga dasar. Begitu Reef Restoration Pod dibangun, Twin Arms menyala dan harganya jadi **3**, dan rak alat ikut menampilkan 3.
- **50** — klaimnya berbunyi "tepat empat hal" tetapi menyebut lima. Kelima-limanya memang ada: gambar yang bisa di-zoom/geser, nama benda, `LOOKS LIKE:`, `MARKING:`, dan `WEIGHT:`.
- **61** — templatnya `"Nothing on this one for that tool. The shift time is spent anyway -{n}."` dan `{n}` adalah biaya sebenarnya, jadi **-4** pada harga dasar dan **-3** setelah Twin Arms menyala.
- **79/80/81** — teks checklist di layar memakai panah ASCII `->`, bukan `→`. Isinya sama persis selain itu.
- **93** — klaimnya benar apa adanya, tapi perlu kamu tahu: keduanya sudah bisa dibedakan dari **informasi gratis** — Muddy Shirt `LOOKS LIKE: woven fabric` / 0,6 kg, Stained Shirt `LOOKS LIKE: stained woven fabric` / 0,7 kg. Jadi pasangan ini tidak sekedap pasangan Frayed/Faded.
- **103** — HAZARDOUS per hari: 0, 0, 2, 5, 6. Total 13 di lima hari — pasokan terkecil dari keempat kategori.
- **112** — benar, tiap blueprint punya `unlocks_upgrade`. Tapi "membuka" sekarang berarti **langsung menyala sendiri**; tidak ada tempat untuk memasangnya.
- **113** — kelima unsur itu ada. Baris pertama kartu juga memuat nama benda, yang belum disebut klaim.
- **135** — benar untuk artnya: outline bin, slot terpilih, plat baris alat, dan tombol konsol yang ditekan semuanya PNG tersendiri. Satu-satunya perkecualian adalah baris alat yang mati: itu `modulate.a = 0.35` pada **label teksnya**, bukan pada gambar.
- **140** — setiap `var`, `const`, parameter, dan tipe kembalian sudah bertipe. Perkecualiannya **12 variabel perulangan** yang bertipe Variant: `for child in ...` (8×), `for category in ItemData.Category.values()` (3×), dan `for c in materials` di `game.gd:441`.

---

## C. YANG BERUBAH SEJAK AUDIT TERAKHIR

Hal-hal berikut ada di build tetapi tidak tercakup daftar 1–140.

### C1. Sistem baru yang belum disebut proposal sama sekali

1. **Tur berpemandu (tutorial overlay).** Layar baru: `scenes/tutorial/` + `data/tutorial_steps.gd`. **19 langkah** dalam dua segmen — 8 di kokpit, 11 di meja pilah. Layar digelapkan, satu lubang bercahaya dipotong dengan shader di atas kontrol yang sedang dibicarakan, keterangan muncul di sebelahnya. **Menjeda tree** dan menelan semua input; klik di mana saja untuk maju; tidak ada tombol skip. Berjalan otomatis sekali per peluncuran aplikasi, pada run pertama. Bisa dipanggil ulang lewat tombol "Show the Tutorial Again" di layar Settings dan di menu jeda.
2. **Gerbang target pada End Shift.** Tombol End Shift menolak selama target belum terpenuhi, dan berubah menjadi "Sort {n} more". Ini mengubah nomor 14 dan 71.
3. **Perlengkapan menyala sendiri.** Seluruh sistem memasang/melepas perlengkapan dibuang. Nomor 105–111 semuanya menyangkut sistem yang sudah tidak ada bentuknya.
4. **Parallax enam lapis di dalam tangki** (`claw_phase.gd:74-84`), dengan kedalaman scroll per lapis, dan pemandangan yang disebar acak per hari dari seed harian.
5. **Rel penanda + minimap titik** di atas kokpit: penanda menunjukkan potongan dasar laut yang sedang dilihat, titik-titik menunjukkan benda yang masih di bawah (`claw_phase.gd:475-500`).
6. **Sebelas gambar ikan** (`FISH_FRAMES`) yang diacak per hari, 12 ekor per shift, plus gelembung yang jumlahnya digerakkan slider VFX.
7. **Kotak tabrakan benda diukur dari piksel gambarnya**, bukan dari bingkai sprite (`tank_item.gd:64-107`) — sekali pindai alpha per tekstur.
8. **Menu jeda punya tombol Exit Game**, yang di build Web tidak melakukan apa-apa yang berarti.

### C2. Teks di layar yang menyebut sesuatu yang tidak berlaku (jawaban nomor 142)

Ada, empat tempat, semuanya di dalam Rulebook/tutorial:

1. **`PS 6` (styrofoam)** — ada di glosarium `Strings.MATERIALS:309`, tetapi **tidak ada satu benda pun** yang membawa kode itu. Glosariumnya sendiri mengaku "Only entries something in the game can actually show" (`strings.gd:301-303`), jadi baris ini melanggar aturannya sendiri.
2. **Baris "Metal — aluminium and steel cans"** di `GUIDANCE:274` — tidak ada benda logam di dalam permainan.
3. **Baris "Chemicals themselves — paint, solvent, pesticide, batteries, expired medicine"** di `GUIDANCE:279` — tidak ada benda yang *berupa* bahan kimia; yang ada hanya benda yang *terkena* bahan kimia.
4. **`tut_desk_outcome_body`** mengutip chip berbunyi `"STAIN IS: chemical"`. Chip yang sebenarnya muncul adalah `STAIN IS: <nama noda>` (mis. "pesticide concentrate"), sementara yang menyebut kata "chemical" adalah chip lain: `STAIN: chemical, will not wash off`. Kutipan itu tidak pernah muncul persis begitu.
5. Bonus: string `claw_rail_locked` ("Rail is resetting…") tidak pernah bisa tampil karena `post_drop_lockout` selalu 0.

### C3. Dua tempat dengan angka berbeda untuk hal yang sama (jawaban nomor 143)

**Tidak ada yang benar-benar terlihat pemain sekarang.** Rak alat memakai `Game.cost_of(&"tool")` dan disegarkan setiap `budget_changed`, jadi angkanya selalu sama dengan yang dipotong. Readout "Cost per drop" di kokpit memakai `Game.cost_of(&"drop")` dan disegarkan tiap frame.

Dua ketidakcocokan **laten** yang tidak bisa muncul hari ini tetapi akan muncul kalau sistemnya dihidupkan lagi:

- `GrabButton.tooltip_text` di `claw_phase.gd:156` diisi **sekali** di `_ready()` dan tidak pernah disegarkan. Aman sekarang karena tidak ada perlengkapan yang mengubah biaya drop; akan basi begitu ada.
- Bacaan kedua pemindai kasar dipotong `Game.base_cost(&"tool")` (4) sementara rak menampilkan `Game.cost_of(&"tool")` (3) — `inspect_panel.gd:295`. Tidak terjangkau karena `coarse_readings` tidak pernah menyala.

Ketidakcocokan angka yang **nyata** hari ini ada di dokumentasi, bukan di layar:
- `BUILD.md` menyebut "34 pemeriksaan"; `tests/run_all.sh` sebenarnya menjalankan **33**.
- `assets/ASSETS.md:339` berbunyi "There is no music yet… nothing plays on it", padahal tabel dua baris di bawahnya mendaftar dua berkas musik dan `game.gd` memang memutarnya.
- `assets/ui/fonts/README.md:4` merujuk `README.txt` di sebelahnya; berkas itu tidak ada di repo.

### C4. Margin pasokan material (jawaban nomor 144)

Diukur seperti `smoke_tech.gd` mengukurnya — kategori hasil resolusi terhadap aturan hari itu, tanpa dibilas, seluruh lima hari:

| Kategori | Dibutuhkan | Bisa ditemukan | Margin |
|---|---|---|---|
| ORGANIC | 7 | 23 | **+16** |
| RECYCLABLE | 6 | 18 | **+12** |
| HAZARDOUS | 5 | 13 | **+8** |
| RESIDUE | 7 | 36 | **+29** |

Ambangnya `MIN_MARGIN = 3`. **Uji penyeimbangan LULUS**, dengan jarak lebar — tidak lagi gagal.

Sebagai pembanding, kalau pemain membilas semua yang bisa dibilas, margin bergeser menjadi ORGANIC +23, RECYCLABLE +27, HAZARDOUS +8, RESIDUE +7. HAZARDOUS adalah satu-satunya kategori yang margin-nya tidak berubah oleh keputusan pemain, dan tetap yang paling sempit — sesuai klaim 103.

### C5. Kredit/lisensi musik (jawaban nomor 145)

**Tidak ada.** Tidak ada berkas kredit atau lisensi untuk `music_game.mp3` maupun
`amb_sea.mp3` di mana pun dalam repo. `assets/ASSETS.md` hanya mendaftar durasi
dan bus-nya. Satu-satunya lisensi pihak ketiga yang terdokumentasi adalah font:
`assets/ui/fonts/OFL.txt` + `README.md`, yang justru menyatakan font itu
"the only third-party asset in the project" — pernyataan yang bertabrakan dengan
adanya dua berkas musik. **Ini lubang yang perlu kamu tutup sebelum submit.**

### C6. Aset terpaket tanpa dirujuk siapa pun (jawaban nomor 146)

**Ada.** `export_filter="all_resources"` pada kedua preset, jadi semua yang
pernah di-import ikut terpaket. Yang terbukti ada di dalam `build/web/index.pck`
padahal tidak dirujuk kode/scene mana pun:

- Seluruh isi `assets/newaset/` — 15 PNG (`Ocean bg/parralex-*`, `settimg/settings-*`, `teddy-bear.PNG`, `toothbrush.PNG`, `universal-background-*.png`, `cursor-source.PNG`), plus **`music-for-game.mp3` dan `sea-bgm.wav`** yang menggandakan musik yang benar-benar dipakai.
- `assets/ui/`: `button_normal.png`, `button_hover.png`, `button_pressed.png`, `button_disabled.png`, `desk_meter_frame.png`, `meter_bg.png`, `meter_fill.png`, `icon_pause.png`, `icon_pause_pressed.png`.
- `assets/env/`: `coral_dead.png`, `coral_healthy.png`.

Yang **tidak** ikut terpaket tetapi tetap ada di disk: keempat gambar ending
master di `assets/ui/endings/` (`IMG_0767/0770/0783/0784.PNG`) — Godot tidak
meng-import-nya, jadi aman dari sisi ukuran, tapi tetap menganggur di repo.

Ada juga satu scene yatim: `scenes/after_day/day_report.tscn` menunjuk
`res://scenes/report/day_report.gd`, dan **folder `scenes/report/` tidak ada**.
Scene ini tidak dirujuk siapa pun dan tidak ikut terpaket, tapi kalau ada yang
membukanya di editor, itu akan error.

### C7. Data yang sudah tidak dipakai lagi

- `ItemData.surface_properties` dan `surface_label()` **tidak pernah dipanggil di luar `item_data.gd`**. Semua 20 benda mengisinya ("mushy, watery, sweet smell" dan seterusnya), tetapi tidak ada satu pun node yang merendernya. Yang tampil di `LOOKS LIKE:` adalah `visible_material`, bukan ini.
- Signal `Events.grip_preview_changed` dideklarasikan tapi tidak pernah di-emit — sisa dari pratinjau peluang cengkeram yang dibuang (lihat nomor 39).
- Bagian `# --- upgrades ---` di `strings.gd:229` kosong.
- Kunci `machines_title` sekarang berisi teks "Cost per drop" — nama kunci lama yang tidak lagi cocok dengan isinya.
- String `tech_unlocks` / `tech_fitted` masih memakai kata "fits" / "is running", peninggalan sistem gear.

---

## HASIL UJI OTOMATIS

`./tests/run_all.sh` — **33 pemeriksaan, 33 PASS, 0 FAIL.** `All checks passed.` (exit 0)

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
  PASS  smoke_claw          PASS  smoke_ending
  PASS  smoke_desk          PASS  smoke_box
  PASS  smoke_shift         PASS  smoke_tech
  PASS  smoke_shift_end     PASS  smoke_upgrades
  PASS  smoke_inspect       PASS  smoke_upgrade_play
  PASS  smoke_layout        PASS  smoke_settings
  PASS  smoke_parallax      PASS  smoke_debug
  PASS  smoke_report        PASS  smoke_extensibility
                            PASS  smoke_full
  PASS  smoke_claw --fail
  PASS  smoke_full --bad
  PASS  smoke_shift day 1
All checks passed.
```

Tidak ada yang gagal, jadi tidak ada yang perlu dilaporkan sebagai kegagalan.
Catatan: `BUILD.md` menyebut angka 34; yang benar-benar dijalankan 33.
