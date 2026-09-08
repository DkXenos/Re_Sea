# Build

Godot **4.7.2 stable**. Export preset tersedia di `export_presets.cfg`
(`Windows Desktop`, `macOS`, dan `Web`). Semua perintah dijalankan dari root
project.

---

## Export template: sudah terpasang

Template Windows, macOS, dan Web sudah terpasang di mesin ini. Tidak ada langkah
manual yang tersisa.

Verifikasi — folder ini harus memuat `windows_release_x86_64.exe` (±104 MB) dan
`macos.zip`:

    ls -la ~/Library/Application\ Support/Godot/export_templates/4.7.2.stable/

> **Catatan kalau build `.exe` tiba-tiba gagal dengan
> `Failed to copy export template`:** itu tandanya template Windows terunduh
> sebagian. Gejala khasnya, di folder di atas hanya ada
> `windows_release_x86_64_console.exe` yang berukuran ±190 KB, sementara
> `windows_release_x86_64.exe` yang ±104 MB **tidak ada**. Berkas `_console.exe`
> yang kecil itu cuma wrapper, bukan template sebenarnya, jadi keberadaannya
> gampang menipu. Perbaikannya: pasang ulang lewat
> **Editor → Manage Export Templates… → Download and Install**, atau ambil
> berkas yang kurang saja dari
> `Godot_v4.7.2-stable_export_templates.tpz` (entri `templates/`) di halaman
> rilis Godot.

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

## Build macOS (.app) — universal, jalan di Intel dan Apple Silicon

    godot --headless --export-release "macOS"

Hasilnya:

    build/macos/Re-Sea.zip     →  berisi Re-Sea.app

Binernya **universal** (`x86_64` + `arm64`), jadi jalan native di Mac Intel
maupun Apple Silicon tanpa Rosetta. Ditandatangani **ad-hoc**
(`codesign/codesign=1`), bukan dengan Developer ID.

Konsekuensi ad-hoc: di Mac orang lain, Gatekeeper akan menolak pada percobaan
pertama. Cara membukanya — **klik kanan `Re-Sea.app` → Open → Open**. Sekali
saja; sesudah itu bisa dibuka normal. Cantumkan langkah ini di halaman itch.io,
kalau tidak juri Mac akan mengira build-nya rusak.

Preset macOS memakai `universal`, dan Godot mensyaratkan ETC2 ASTC aktif untuk
target `universal`/`arm64`. Karena itu `project.godot` memuat:

    [rendering]
    textures/vram_compression/import_etc2_astc=true

Ini **tidak** menggemukkan build Windows: preset Windows tetap
`texture_format/etc2_astc=false`, jadi varian ETC2 tidak ikut dipaket ke sana.
Dari 164 tekstur, hanya 12 yang ber-VRAM compression dan terpengaruh; 152
sisanya lossless.

---

## Build Web (WebGL) — cadangan, siap pakai

    godot --headless --export-release "Web"
    cd build/web && zip -r ../Re-Sea-web.zip . && cd ../..

Menghasilkan `build/Re-Sea-web.zip` (±22 MB, berisi `index.html`).

Untuk itch.io: unggah zip itu, centang **This file will be played in the
browser**, lalu set ukuran viewport **1280 × 720**. Aktifkan juga
**SharedArrayBuffer support** di pengaturan itch kalau tersedia.

Build web berguna sebagai cadangan: juri bisa langsung mencoba tanpa mengunduh
dan tanpa peringatan SmartScreen.

---

## Sebelum setiap build: jalankan uji otomatis

    ./tests/run_all.sh

33 pemeriksaan: aturan statis arsitektur, boot, tiap sistem, dan satu run penuh
lima hari sampai layar akhir. Semua harus `PASS`. Kalau ada yang `FAIL`, jangan
di-build dulu.

Setelah menambah atau mengubah skrip yang punya `class_name`, jalankan dulu:

    godot --headless --import

Uji asap cepat pada hasil build macOS (boot sampai keluar, tanpa jendela):

    build/macos/Re-Sea.app/Contents/MacOS/Re-Sea --headless --quit-after 300

Harus selesai tanpa baris `ERROR`.

---

## Ukuran

Batas lomba 300 MB. Kondisi saat ini jauh di bawahnya:

| Build | Ukuran |
|---|---|
| Web (zip) | ±22 MB |
| Windows (zip) | ±79 MB |
| macOS (zip) | ±101 MB |

Angka Windows/macOS didominasi runtime Godot itu sendiri; `.pck` game hanya
±46 MB. Master ilustrasi berukuran penuh (2560×1440) **tidak** disimpan di dalam
project — letaknya di `/Users/jaysn/Re-Sea-art-masters/`. Jangan memindahkannya
kembali ke `assets/`, karena seluruh isinya akan ikut terpaket ke build. Hal yang
sama berlaku untuk 23 bobot Fredoka yang tidak dipakai, di
`~/Re-Sea-art-masters/fonts/`.

---

## Ikon aplikasi — sudah terpasang

Sumbernya `game-logo.PNG` (2048 × 2048, RGBA). Dua berkas ikon di root project
di-generate dari situ dan sudah dirujuk oleh preset:

| Berkas | Dipakai oleh | Preset |
|---|---|---|
| `icon.ico` | ikon `.exe` Windows | `application/icon="res://icon.ico"` |
| `icon.icns` | ikon `.app` macOS | `application/icon="res://icon.icns"` |

Kalau logonya berganti, generate ulang keduanya dari root project:

    # Windows — .ico multi-resolusi
    python3 -c "from PIL import Image; im=Image.open('game-logo.PNG').convert('RGBA'); im.save('icon.ico', sizes=[(16,16),(32,32),(48,48),(64,64),(128,128),(256,256)])"

    # macOS — .icns
    mkdir -p icon.iconset
    for s in 16 32 128 256 512; do \
      sips -z $s $s game-logo.PNG --out icon.iconset/icon_${s}x${s}.png; \
      sips -z $((s*2)) $((s*2)) game-logo.PNG --out icon.iconset/icon_${s}x${s}@2x.png; \
    done
    iconutil -c icns icon.iconset -o icon.icns
    rm -rf icon.iconset

Ikon `.exe` ditanam Godot langsung ke resource PE (`application/modify_resources=true`),
tanpa perlu rcedit. Verifikasi keenam resolusi benar-benar masuk ke `.exe`:

    python3 -c "
    import struct
    exe=open('build/windows/Re-Sea.exe','rb').read(); ico=open('icon.ico','rb').read()
    n=struct.unpack('<H',ico[4:6])[0]
    for i in range(n):
        o=6+i*16; w,h=ico[o],ico[o+1]
        size,off=struct.unpack('<II',ico[o+8:o+16])
        print(f'{w or 256}x{h or 256}', ico[off:off+size] in exe)
    "

Keenam barisnya harus `True`.

---

## Checklist rilis

- [ ] `./tests/run_all.sh` — semua PASS
- [ ] `godot --headless --export-release "Windows Desktop"` berhasil
- [ ] `godot --headless --export-release "macOS"` berhasil
- [ ] `.exe` dijalankan di mesin Windows yang bersih — masuk main menu, satu hari
      penuh bisa diselesaikan sampai layar report
- [ ] Ikon `.exe` tampil benar di Explorer (bukan ikon bawaan Godot)
- [ ] `Re-Sea.app` dibuka di Mac lain lewat klik kanan → Open
- [ ] Judul jendela berbunyi **Re:Sea**
- [ ] Zip dan unggah ke itch.io, sertakan catatan Gatekeeper untuk build macOS
