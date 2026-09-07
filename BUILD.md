# Build

Godot **4.7.2 stable**. Export presets sudah tersedia di `export_presets.cfg`
(`Windows Desktop` dan `Web`). Perintah di bawah dijalankan dari root project.

---

## Yang harus kamu pencet sendiri sekali: pasang export template Windows

Saat ini di mesin ini **hanya template Web** yang terpasang. Template Windows
belum ada, jadi build `.exe` akan gagal sampai kamu memasangnya. Ini satu-satunya
langkah manual, dan cukup dilakukan sekali.

1. Buka project di Godot 4.7.2.
2. Menu **Editor → Manage Export Templates…**
3. Klik **Download and Install**. Unduhannya ±1 GB, jadi siapkan koneksi.
4. Tunggu sampai statusnya menjadi terpasang, lalu tutup dialognya.

Verifikasi berhasil — folder ini harus memuat `windows_release_x86_64.exe`:

    ls ~/Library/Application\ Support/Godot/export_templates/4.7.2.stable/

Kalau unduhan lewat editor gagal, alternatifnya: unduh
`Godot_v4.7.2-stable_export_templates.tpz` dari halaman rilis Godot di GitHub,
lalu di dialog yang sama pilih **Install from File**.

---

## Build Windows (.exe) — target utama untuk itch.io

    godot --headless --export-release "Windows Desktop"

Hasilnya satu berkas tunggal:

    build/windows/Re-Sea.exe

`.pck` sudah **tertanam di dalam `.exe`** (`binary_format/embed_pck=true`), jadi
tidak ada berkas pendamping yang bisa tertinggal atau terpisah.

Untuk diunggah ke itch.io, bungkus jadi zip:

    cd build/windows && zip -r ../Re-Sea-windows.zip . && cd ../..

Di halaman itch.io, centang **This file will be downloaded** dan tandai
platformnya **Windows**.

---

## Build Web (WebGL) — sudah jadi, siap pakai

Template-nya sudah terpasang, jadi ini bisa langsung dijalankan:

    godot --headless --export-release "Web"
    cd build/web && zip -r ../Re-Sea-web.zip . && cd ../..

Menghasilkan `build/Re-Sea-web.zip` (±15 MB, berisi `index.html`).

Untuk itch.io: unggah zip itu, centang **This file will be played in the
browser**, lalu set ukuran viewport **1280 × 720**. Aktifkan juga
**SharedArrayBuffer support** di pengaturan itch kalau tersedia.

Build web berguna sebagai cadangan: juri bisa langsung mencoba tanpa mengunduh
dan tanpa peringatan SmartScreen.

---

## Sebelum setiap build: jalankan uji otomatis

    ./tests/run_all.sh

34 pemeriksaan: aturan statis arsitektur, boot, tiap sistem, dan satu run penuh
lima hari sampai layar akhir. Semua harus `PASS`. Kalau ada yang `FAIL`, jangan
di-build dulu.

Setelah menambah atau mengubah skrip yang punya `class_name`, jalankan dulu:

    godot --headless --import

---

## Ukuran

Batas lomba 300 MB. Kondisi saat ini jauh di bawahnya:

| Build | Ukuran |
|---|---|
| Web (zip) | ±15 MB |
| Windows (zip) | perkiraan ±30 MB |

---

## Ikon .exe (opsional, belum dipasang)

`.exe` saat ini memakai ikon bawaan Godot. Untuk memakai ikon sendiri, Windows
menuntut berkas `.ico` (bukan `.png`):

1. Siapkan gambar persegi, minimal 256 × 256, milik tim sendiri.
2. Konversi ke `.ico` multi-resolusi, misalnya dengan Python + Pillow:

       python3 -c "from PIL import Image; im=Image.open('sumber.png').convert('RGBA'); im.save('icon.ico', sizes=[(16,16),(32,32),(48,48),(64,64),(128,128),(256,256)])"

3. Simpan hasilnya sebagai `icon.ico` di root project.
4. Di `export_presets.cfg`, pada blok `[preset.0.options]`, ubah:

       application/icon="res://icon.ico"

5. Build ulang.

---

## Checklist rilis

- [ ] `./tests/run_all.sh` — semua PASS
- [ ] Template Windows terpasang
- [ ] `godot --headless --export-release "Windows Desktop"` berhasil
- [ ] `.exe` dijalankan di mesin Windows yang bersih — masuk main menu, satu hari
      penuh bisa diselesaikan sampai layar report
- [ ] Judul jendela berbunyi **Re:Sea**
- [ ] Zip dan unggah ke itch.io
