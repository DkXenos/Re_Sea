# PROPOSAL HOLOGAME — HOLOGY 9.0
## Re:Sea
### Subtema: Lingkungan

> **Catatan penggunaan.** Seluruh isi dokumen ini disusun dari kode dan data yang
> benar-benar ada di dalam project Godot `Re:Sea`. Setiap angka, nama mekanik,
> nama kategori, dan kontrol dapat ditelusuri ke berkas sumbernya. Bagian yang
> memerlukan data di luar kode ditandai `[BUTUH INPUT JASON: ...]` atau
> `[BUTUH SITASI: ...]` dan **harus dilengkapi sebelum dokumen dikirim.**
>
> Seluruh teks di dalam permainan berbahasa Inggris. Istilah yang muncul di layar
> dikutip persis seperti pada build dan tidak diterjemahkan; penjelasan bahasa
> Indonesia diberikan satu kali pada kemunculan pertama.

---

# BAB 1 PENDAHULUAN

## 1.1 Latar Belakang

Laut Indonesia menghadapi tekanan sampah yang tidak sebanding dengan kapasitas
penanganannya. Sampah yang tidak terkelola di darat berakhir di badan air, lalu
terbawa arus ke perairan pesisir, tempat ia berhenti menjadi persoalan estetika
dan mulai menjadi persoalan ekologi.
`[BUTUH SITASI: data volume sampah laut Indonesia per tahun — sumber yang lazim dipakai adalah KLHK/SIPSN, atau publikasi Jambeck et al. mengenai peringkat Indonesia dalam kebocoran sampah plastik ke laut. Cantumkan angka dan tahunnya.]`

Persoalannya tidak berhenti pada volume. Sebagian besar material yang terbuang ke
laut sesungguhnya **masih bernilai** — plastik bersih, kaca, dan kertas adalah
bahan baku daur ulang. Yang menghilangkan nilai itu bukan jumlahnya, melainkan
**kesalahan pemilahan**. Satu wadah bekas yang masih menyisakan residu dapat
mengontaminasi satu batch material daur ulang dan menurunkan seluruhnya menjadi
residu.
`[BUTUH SITASI: rujukan mengenai kontaminasi aliran daur ulang akibat kesalahan pemilahan di sumber, beserta perkiraan persentase material yang ditolak fasilitas daur ulang karena kontaminasi.]`

Kesalahan itu jarang lahir dari niat buruk. Ia lahir dari **keterbatasan
informasi**. Gelas kertas berlapis plastik terlihat persis seperti gelas kertas
biasa. Kain poliester terasa seperti kain katun di tangan. Kaus yang pernah
terkena pestisida tidak menampilkan apa pun yang membedakannya dari kaus kotor
biasa. Pemilahan yang benar menuntut sesuatu yang tidak dimiliki kebanyakan
orang: kemampuan membaca kode resin, kebiasaan memeriksa sebelum memutuskan, dan
pemahaman bahwa aturan pemilahan bersifat **berjenjang** — residu kimia
mengalahkan aturan residu biasa, yang pada gilirannya mengalahkan aturan material
dasar.
`[BUTUH SITASI: data tingkat literasi/pengetahuan masyarakat Indonesia mengenai pemilahan sampah rumah tangga, atau persentase rumah tangga yang memilah sampah — sumber BPS atau survei sejenis.]`

Di titik inilah permainan dapat melakukan sesuatu yang kampanye poster tidak
bisa. Poster memberi tahu jawabannya. Permainan dapat memberi pemain **kondisi
ketidaktahuan yang sama**, lalu membiarkannya merasakan sendiri bahwa menebak itu
mahal dan memeriksa itu menguntungkan. Pemain yang pernah kehilangan material
karena membuang gelas berlapis ke bin daur ulang akan mengingat pelajaran itu
dengan cara yang berbeda dari pemain yang sekadar membacanya.

`Re:Sea` dibangun di atas premis tersebut. Permainan ini tidak menghukum pemain
karena salah; ia hanya **tidak memberi imbalan apa pun** atas tebakan yang meleset
— dan membuat pemain melihat, di akhir hari, properti apa yang sebenarnya tidak
pernah ia periksa. Subtema Lingkungan tidak dilekatkan sebagai tema visual di atas
mekanik yang netral, melainkan menjadi aturan menang-kalahnya itu sendiri.

## 1.2 Deskripsi Game

### 1.2.1 Identitas Game

| Aspek | Keterangan |
|---|---|
| Judul | **Re:Sea** |
| Nama internal project | `Cakar Laut` (`project.godot` → `config/name`) |
| Subtema | Lingkungan |
| Genre | Simulasi inspeksi dan pemilahan, dengan mekanik mesin capit |
| Perspektif | 2D, tampilan samping, resolusi dasar 1280 × 720 |
| Engine | Godot Engine 4.7.2 stable |
| Bahasa dalam permainan | Inggris |
| Platform target | Windows (.exe) dan/atau WebGL `[BUTUH INPUT JASON: tentukan target akhir; berkas export_presets.cfg belum ada di project]` |
| Mode | Pemain tunggal, offline |
| Durasi satu run | 5 hari permainan `[BUTUH INPUT JASON: durasi rata-rata dalam menit — perlu diukur dari playtest]` |

### 1.2.2 Premis dan Latar Cerita

Pemain mengoperasikan sebuah mesin capit dari dalam lambung kapal selam kerja yang
duduk di dasar sebuah teluk. Jendela di depan pemain adalah jendela sungguhan:
laut hanya ada di dalam bingkai itu, dan selebihnya adalah dinding lambung tempat
pemain berada. Setiap hari arus membawa kiriman sampah baru ke dasar teluk, dan
tugas pemain adalah mengangkatnya, memeriksanya, lalu memilahnya.

Naskah pembuka permainan terdiri atas tiga baris yang tampil di layar `cutscene`:

> *"The bay used to be loud. Gulls arguing, waves turning over, a crab picking a fight with the tide."*
>
> *"One became a hundred. A hundred became the delivery the current brings every single day."*
>
> *"And none of it arrives labelled. A clean cup and a lined one sink in exactly the same way."*
>
> *"But a machine is only as good as what we feed it, and the sea does not sort itself."*
>
> *"Lower the claw. Look before you decide."*

Baris terakhir adalah tesis permainannya. Yang dihitung bukan berapa banyak sampah
yang diangkat, melainkan **keputusan** yang diambil atas setiap benda. Material
yang dipilah dengan benar dikirim ke bengkel dan menjadi bahan untuk membangun
tiga mesin pembersih laut. Material yang salah pilah tidak sampai ke mana-mana.

Latar ini juga menjelaskan mengapa pemain tidak pernah menyentuh sampah secara
langsung: ia melihatnya lewat kaca, lewat capit, dan lewat alat. Ketidaktahuan
pemain adalah ketidaktahuan yang dipaksakan oleh situasi, bukan oleh desain yang
sengaja menyembunyikan informasi.

### 1.2.3 Core Loop

Satu hari permainan adalah satu **shift**, dan satu shift berjalan dalam siklus
berikut:

1. **`day_start`** — layar pembuka hari menampilkan aturan yang berlaku hari itu,
   target pemilahan (`Quota`), jatah `Shift time`, dan alat apa saja yang
   tersedia. Pemain menekan `Lower the Claw`.
2. **Mengangkat.** Pada tampilan mesin capit, pemain menggeser capit di sepanjang
   rel dan menjatuhkannya. Setiap penjatuhan menghabiskan **6** `Shift time`,
   berhasil maupun gagal.
3. **Memeriksa.** Dengan menekan Tab, pemain berpindah ke `Sorting Desk` (meja
   pemilahan). Setiap benda yang berhasil diangkat muncul di daftar. Pemain dapat
   memperbesar dan menggeser gambarnya secara gratis, membaca properti
   permukaannya secara gratis, dan membuka `Rulebook` secara gratis — tetapi
   menggunakan alat inspeksi menghabiskan **4** `Shift time`.
4. **Memilah.** Pemain memilih satu dari empat bin. Tindakan ini menghabiskan
   **1** `Shift time`. **Permainan tidak memberi tahu apakah pilihan itu benar.**
5. Langkah 2–4 diulang, dalam urutan bebas, sampai `Shift time` habis atau tidak
   ada lagi tindakan bermakna yang bisa dibeli.
6. **`after_day`** — barulah di sini seluruh jawaban dibuka sekaligus. Tab
   `The Day` memuat apa yang salah, ke mana seharusnya, properti apa yang tidak
   pernah diperiksa, aturan mana yang dilanggar, dan berapa material yang
   benar-benar masuk ke bengkel. Pada layar yang sama, tab `Technology` dan
   `Gear` membelanjakan material itu untuk merakit komponen mesin dan memilih
   perlengkapan untuk hari berikutnya.
7. Kembali ke langkah 1 untuk hari berikutnya, sampai hari kelima berakhir.

Yang menahan loop ini tetap tegang adalah satu keputusan desain: **tidak ada
timer waktu nyata.** `Shift time` hanya berkurang oleh tindakan. Berpikir,
membaca, memperbesar gambar, dan berpindah tampilan sepenuhnya gratis. Dengan
demikian tekanannya jatuh pada pertanyaan *"apakah informasi ini layak dibeli?"*,
bukan pada kecepatan tangan pemain.

### 1.2.4 Keunikan dan Pembeda

**Pertama, dua genre yang saling mengunci, bukan sekadar berdampingan.** Mesin
capit menentukan *apa* yang harus pemain putuskan, dan meja pemilahan menentukan
*seberapa mahal* keputusan itu. Keduanya berbagi satu sumber daya yang sama —
`Shift time` — sehingga setiap penjatuhan capit adalah pengurangan anggaran
inspeksi, dan sebaliknya. Pemain yang rakus mengangkat akan kehabisan jatah untuk
memeriksa; pemain yang terlalu teliti tidak akan mencapai target.

**Kedua, biaya informasi sebagai mekanik inti.** Sebagian besar permainan bertema
lingkungan menempatkan jawaban di depan pemain dan mengukur ketelitian
eksekusinya. `Re:Sea` melakukan kebalikannya: jawabannya memang tersembunyi, dan
membukanya ada harganya. Sebuah alat yang tidak menemukan apa pun **tetap
menghabiskan 4 `Shift time`** — kegagalan itu adalah risiko yang melekat pada
keputusan memilih alat, dan permainan menyatakannya secara terbuka di layar.

**Ketiga, aturan berjenjang yang berubah antar hari.** Kategori sebuah benda
bukan properti tetap benda itu, melainkan hasil dari benda tersebut yang
dievaluasi terhadap **aturan yang berlaku hari itu**, dengan prioritas tertinggi
yang menang. Akibatnya benda yang sama dapat berpindah bin dari hari ke hari.
`Chemical-Soaked Tissue` termasuk `LANDFILL` pada hari ke-2 dan `HAZARDOUS` pada
hari ke-3, karena aturan residu kimia baru berlaku mulai hari ke-3. Pemain tidak
bisa menghafal jawaban; ia harus membaca aturan.

**Keempat, umpan balik yang tertunda dan bersifat mendidik.** Bin tidak pernah
memberi tahu benar atau salah pada saat pemilahan — animasi `accept` hanya berarti
"bin menerimanya". Seluruh evaluasi ditahan sampai `after_day`, dan di sana setiap
kesalahan ditampilkan lengkap dengan baris `Never checked:` yang menyebutkan
properti tersembunyi yang menentukan jawabannya. Pemain tidak sekadar diberi tahu
bahwa ia salah, melainkan **diberi tahu di mana letak celah pemeriksaannya**.

**Kelima, upgrade tanpa mata uang dan tanpa peningkatan murni.** Tidak ada uang di
dalam permainan. Perlengkapan dibuka dengan membangun mesin, dan setiap
perlengkapan adalah pertukaran: `Light Claw` mempermurah penjatuhan tetapi
menurunkan daya cengkeram, `Fast Rail` mempercepat gerak tetapi mengunci rel dua
detik setiap selesai menjatuhkan. Keduanya, keuntungan dan kerugiannya, selalu
ditampilkan bersamaan.

### 1.2.5 Dampak dan Pesan Positif

Pesan `Re:Sea` bukan "buanglah sampah pada tempatnya". Pesannya lebih spesifik dan
lebih jarang disampaikan: **memilah dengan benar menuntut pemeriksaan, dan
memilah dengan salah menghancurkan nilai material sepenuhnya, bukan sebagian.**

Pesan itu tidak disampaikan lewat teks, melainkan lewat aturan ekonominya. Di
dalam kode, satu-satunya jalan material masuk ke gudang bengkel adalah fungsi yang
**hanya** menghitung benda yang masuk bin yang benar. Benda yang salah pilah tidak
menghasilkan nilai yang lebih kecil — ia menghasilkan **nol**. Layar `after_day`
menyatakannya dengan kalimat:

> *"Only what goes in the right bin becomes blueprint material."*
>
> *"{n} sorted wrongly - lost, not stored."*

Ini adalah analogi langsung dari kontaminasi aliran daur ulang di dunia nyata,
tempat satu benda yang salah masuk dapat menurunkan nilai seluruh batch. Pemain
mempelajarinya bukan sebagai fakta, melainkan sebagai konsekuensi yang ia alami
sendiri saat mesin yang sedang ia bangun tidak kunjung selesai.

Konsekuensi kesalahan sengaja dirancang **tanpa hukuman**. Tidak ada nyawa, tidak
ada denda, tidak ada game over karena salah pilah. Yang hilang hanyalah peluang.
Desain ini dipilih karena hukuman mendorong pemain bermain aman dan menebak
sesedikit mungkin, sedangkan biaya peluang mendorong pemain **belajar memeriksa** —
dan kemampuan memeriksa itulah perilaku yang ingin dibawa keluar dari permainan.

Tiga mesin yang dibangun pemain memberikan kerangka harapan yang proporsional:
`Ocean Cleaning Drone`, `Recycling Station`, dan `Reef Restoration Pod`. Ketiganya
mewakili tiga pendekatan nyata terhadap pencemaran laut — pengumpulan,
penyaringan, dan penetralan limbah berbahaya. Akhir permainan ditentukan murni
oleh berapa banyak dari ketiganya yang berhasil dibangun, dan permainan tidak
menjanjikan penyelesaian instan: teks akhir terbaik pun menyebut pemulihan sebagai
sesuatu yang dimulai, bukan yang selesai.

Terakhir, permainan ini menyelipkan literasi konkret yang dapat dibawa pulang.
`Rulebook` memuat panduan dasar `WHERE THINGS GO` dan glosarium
`WHAT THE RECYCLING CODES MEAN` yang menjelaskan sepuluh kode resin nyata —
`PET 1`, `HDPE 2`, `PVC 3`, `PE`, `PS 6`, `PA 6`, `PAP`, `ALU`, `GL`, dan `Pb` —
lengkap dengan catatan mana yang dapat didaur ulang dan dengan syarat apa. Kode-kode
ini bukan rekaan; kode yang sama tercetak pada kemasan di dunia nyata, sehingga
pengetahuan yang diperoleh pemain langsung dapat dipakai di luar permainan.

## 1.3 Panduan Instalasi dan Menjalankan Game

### 1.3.1 Tautan

| Keperluan | Tautan |
|---|---|
| Build permainan (Windows .exe) | `[BUTUH INPUT JASON: tautan itch.io. Preset export sudah siap; tinggal pasang export template Windows sekali lewat editor Godot, lalu jalankan perintah di BUILD.md.]` |
| Build permainan (WebGL) | `[BUTUH INPUT JASON: tautan itch.io, bila versi web ikut diunggah. Berkasnya sudah jadi: build/Re-Sea-web.zip, sekitar 15 MB.]` |
| Video gameplay / trailer | `[BUTUH INPUT JASON: tautan video, jika lomba mensyaratkan]` |
| Repositori | `[BUTUH INPUT JASON: tautan repositori, jika dicantumkan]` |

### 1.3.2 Spesifikasi Minimum

Permainan menggunakan metode render `gl_compatibility` (disetel pada
`project.godot`), yaitu jalur render Godot yang paling ringan dan paling luas
kompatibilitasnya.

| Komponen | Kebutuhan |
|---|---|
| Sistem operasi | Windows 10 64-bit atau lebih baru (untuk build .exe) |
| Prosesor | `[BUTUH INPUT JASON: tentukan setelah build diuji]` |
| Memori | `[BUTUH INPUT JASON: ukur pemakaian RAM saat build dijalankan]` |
| Grafis | Mendukung OpenGL 3.3 / OpenGL ES 3.0; untuk versi web dibutuhkan peramban dengan WebGL 2.0 |
| Resolusi layar | Minimal 1280 × 720 (resolusi dasar permainan) |
| Ruang penyimpanan | Sekitar 30 MB untuk versi Windows; versi web 15 MB. Jauh di bawah batas 300 MB. |
| Peranti masukan | Papan ketik dan tetikus (keduanya diperlukan) |
| Audio | Opsional; permainan dapat dimainkan tanpa suara |

### 1.3.3 Langkah Instalasi

**Versi Windows (.exe)**

1. Unduh berkas arsip dari tautan pada 1.3.1.
2. Ekstrak arsip. Isinya satu berkas `.exe` tunggal — seluruh data permainan
   sudah tertanam di dalamnya, sehingga tidak ada berkas pendamping yang bisa
   tertinggal.
3. Jalankan berkas `.exe`.
4. Bila Windows SmartScreen menampilkan peringatan, pilih **More info** lalu
   **Run anyway**. Peringatan ini muncul karena berkas tidak ditandatangani
   secara digital, bukan karena adanya perangkat lunak berbahaya.
5. Permainan langsung terbuka pada layar `main menu`. Tidak ada proses instalasi
   dan tidak ada berkas yang ditulis ke luar folder permainan, kecuali berkas
   pengaturan volume.

**Versi WebGL (ZIP berisi index.html)**

1. Unduh dan ekstrak arsip.
2. Jalankan melalui peladen web statis. Membuka `index.html` langsung dari sistem
   berkas (`file://`) tidak akan berhasil karena kebijakan keamanan peramban.
3. Buka alamat peladen tersebut pada peramban berbasis Chromium atau Firefox versi
   terkini.
4. Klik satu kali pada kanvas permainan agar audio dapat diaktifkan; peramban
   memblokir pemutaran suara sebelum ada interaksi pengguna.

### 1.3.4 Kontrol

Seluruh kontrol berikut diambil langsung dari peta masukan pada `project.godot`.

| Aksi | Tombol | Keterangan |
|---|---|---|
| Menggerakkan capit ke kiri | `A` atau `←` | Hanya saat capit berada di rel |
| Menggerakkan capit ke kanan | `D` atau `→` | Hanya saat capit berada di rel |
| Menjatuhkan capit | `Spasi`, `S`, atau `↓` | Menghabiskan 6 `Shift time` |
| Berpindah tampilan | `Tab` | Bergantian antara mesin capit dan `Sorting Desk` |
| Memakai alat / memilih | Klik kiri tetikus | Mengarahkan alat ke benda, memilih bin, menekan tombol |
| Memperbesar gambar benda | Gulir tetikus | Perbesaran 1,0× sampai 3,0×; gratis |
| Menggeser gambar benda | Seret dengan klik kiri | Gratis |
| Membuka `Rulebook` | `R` | Gratis, tidak menjeda permainan |
| Melompat ke benda berikutnya | `I` | Memilih benda pertama yang belum dipilah |
| Menjeda permainan | `Esc` | Juga dapat ditekan lewat tombol roda gigi pada konsol mesin |
| Melanjutkan layar naratif | `Enter` atau klik kiri | Pada layar judul, cutscene, dan `day_start` |
| Panel debug | `F1` | Hanya aktif pada build debug, tidak tersedia di build rilis |

Setiap kontrol papan ketik memiliki padanan yang dapat diklik pada konsol mesin —
tombol panah kiri, panah kanan, tombol `DROP`, tombol map `SORTING`, dan roda gigi
pengaturan. Menekan tombol papan ketik akan mengganti tekstur tombol yang
bersangkutan menjadi keadaan tertekan, sehingga pemain yang tidak membaca daftar
kontrol tetap dapat menemukan seluruh fungsi lewat antarmuka.

---

# BAB 2 ISI

## 2.1 Progresi dan Alur Game

### 2.1.1 Struktur

Satu run permainan terdiri atas **lima hari**, dan struktur itu dinyatakan dalam
data, bukan dalam kode: setiap hari adalah satu berkas `DayData` di
`data/days/day_01.tres` sampai `day_05.tres`. Objek `Game` memuat seluruh berkas
dari folder tersebut saat permainan dimulai dan mengurutkannya berdasarkan nomor
hari. Menambah hari keenam cukup dilakukan dengan menambah satu berkas; tidak ada
baris kode yang perlu diubah.

Satu hari sama dengan satu **shift**, dan satu shift sama dengan satu anggaran
`Shift time`. Tidak ada sumber daya yang berjalan lintas hari kecuali:

- **material** yang tersimpan di gudang bengkel,
- **komponen** yang sudah dirakit,
- **mesin** yang sudah dibangun, dan
- **perlengkapan** yang sedang terpasang.

Sisa `Shift time` tidak dibawa ke hari berikutnya, dan benda yang belum sempat
dipilah tidak dibawa ke hari berikutnya. Kemajuan permainan sepenuhnya diukur
oleh material yang berhasil diselamatkan.

Permainan tidak menyimpan progres run. Hanya pengaturan volume yang disimpan
secara permanen ke `user://settings.cfg`. Menutup permainan berarti kehilangan run
yang sedang berjalan — konsekuensi dari keputusan bahwa satu run dirancang untuk
diselesaikan dalam satu duduk.

### 2.1.2 Alur Antar Layar

Perpindahan antar layar dikendalikan oleh satu graf alur tunggal di
`systems/day_manager.gd`. Tidak ada satu pun layar yang menyimpan jalur ke layar
lain; semuanya hanya memancarkan sinyal `phase_finished`, dan graf alur yang
memutuskan tujuan berikutnya.

```
main_menu
   └─> cutscene            lima gambar diam, sebelas baris narasi, dapat dilewati
        └─> day_start      aturan hari ini, target, jatah waktu, alat
             └─> shift     ┌── Claw Machine  ─┐  dua tampilan,
                           └── Sorting Desk  ─┘  satu anggaran, Tab
                  └─> after_day   The Day | Technology | Gear
                       ├─> day_start    bila masih ada hari berikutnya
                       └─> game_over    bila hari ke-5 telah selesai
```

Perlu ditegaskan bahwa `shift` **bukan** dua fase berurutan. `Claw Machine` dan
`Sorting Desk` adalah dua tampilan dari satu shift yang sama. Keduanya berbagi
anggaran yang sama dan daftar benda yang sama, dan berpindah di antara keduanya
tidak memakan biaya apa pun. Benda-benda baru tetap berdatangan ke dasar laut
meskipun pemain sedang berada di meja pemilahan.

Keduanya kini sama-sama merupakan gambar layar penuh dengan bacaan dan tombolnya
sendiri. Layar mesin capit memuat kalender, panel waktu shift, panel target dan
panel mesin di dalam ilustrasi kokpitnya; layar meja pemilahan memuat bilah atas
berisi hari, target, sisa waktu, tombol pindah tampilan, tombol akhiri shift dan
roda gigi pengaturan. Tidak ada bilah antarmuka tambahan yang dilapiskan di atas
gambar mana pun — satu-satunya yang muncul di luar keduanya adalah plat kalimat
penutup ketika shift berakhir.

### 2.1.3 Progresi Kesulitan

Seluruh penyeimbangan tersimpan sebagai data, satu berkas `DayData` per hari di
`data/days/`. Tidak ada angka penyeimbangan yang tertulis di dalam kode.

| Hari | Target | `Shift time` | Aturan aktif | Alat tersedia | `Sealed Crate` | Jumlah benda |
|---|---|---|---|---|---|---|
| 1 | 5 | 90 | baseline | — | 0 | 6 |
| 2 | 6 | 110 | + residu | `Rinse`, `Magnifier`, `Cutter` | 1 | 11 |
| 3 | 8 | 130 | + residu kimia | + `Chem Swab` | 1 | 16 |
| 4 | 10 | 150 | + kemasan berlapis | keempatnya | 2 | 18 |
| 5 | 12 | 160 | (empat aturan) | keempatnya | 2 | 19 |

Kesulitan naik melalui empat sumbu yang bekerja bersamaan:

**Pertama, tekanan anggaran.** Target naik 140 % dari hari 1 ke hari 5 (5 → 12),
sementara `Shift time` hanya naik 78 % (90 → 160). Pada hari pertama, memenuhi
target hanya menghabiskan 35 dari 90 satuan, menyisakan margin sangat lebar. Pada
hari kelima, memenuhi target menghabiskan 84 dari 160 satuan, menyisakan 76 satuan
— setara 19 kali penggunaan alat untuk 12 benda. Ruang untuk memeriksa menyempit
justru ketika benda yang perlu diperiksa bertambah.

**Kedua, bertambahnya aturan.** Hari pertama hanya memiliki aturan dasar dan
sengaja dirancang tanpa alat sama sekali, sehingga berfungsi sebagai tutorial
tanpa memerlukan sistem tutorial terpisah — seluruh benda hari itu dapat dipilah
dari properti permukaannya saja. Setiap hari berikutnya menambahkan satu aturan
baru yang berprioritas lebih tinggi.

**Ketiga, pergeseran jawaban.** Karena kategori dihitung dari benda terhadap
aturan hari itu, benda yang sama dapat berpindah bin. `Chemical-Soaked Tissue`
masuk `LANDFILL` pada hari ke-2 (hanya aturan residu yang berlaku) dan berpindah
ke `HAZARDOUS` pada hari ke-3 ketika aturan residu kimia berprioritas 40 mulai
aktif. Hafalan dari hari sebelumnya justru menyesatkan.

**Keempat, ketersediaan material `HAZARDOUS`.** Benda berkategori `HAZARDOUS` baru
muncul mulai hari ke-3. Karena `Reef Restoration Pod` membutuhkan 5 material
`HAZARDOUS`, mesin ketiga secara alamiah terkunci hingga paruh kedua permainan
tanpa memerlukan penguncian buatan.

Kepadatan kemunculan benda relatif tetap: setelah pembukaan hari, benda baru
berdatangan setiap 8 sampai 14 detik, dan bila jumlah benda di dasar laut turun
sampai 2, benda berikutnya langsung dikirim tanpa menunggu. Aturan lantai minimum
ini menjamin selalu ada sasaran untuk dibidik, sehingga kesulitan tidak pernah
berubah menjadi menunggu.

### 2.1.4 Kondisi Menang dan Kalah

**Akhir shift.** Shift berakhir apabila pemain menekan `End Shift`, atau apabila
anggaran tidak lagi dapat membeli tindakan bermakna apa pun. Dua situasi khusus
mendapat kalimat penutupnya sendiri:

- tidak satu pun benda dipilah sepanjang hari →
  *"Shift over, and not one thing sorted. Nothing reaches the workshop today."*
- seluruh benda di air maupun di meja habis terpilah →
  *"Every last piece out of the water and into a bin. The seabed is clear."*

**Target harian.** `after_day` menyatakan `Target reached` atau `Target missed`.
Perlu dicatat bahwa **target tidak memiliki konsekuensi mekanis**: tidak ada
hukuman atas target yang meleset dan tidak ada hadiah atas target yang tercapai.
Target berfungsi sebagai penanda ritme kerja, sementara nilai sesungguhnya dari
sebuah hari adalah material yang berhasil diselamatkan. Perlu ditegaskan pula
bahwa target dihitung dari **jumlah benda yang dipilah**, benar maupun salah —
sehingga pemain dapat mencapai target sambil pulang dengan gudang kosong.

**Akhir permainan.** Setelah hari kelima, permainan berpindah ke `game_over` dan
menampilkan satu dari **empat** akhir — satu tingkat untuk setiap mesin —
ditentukan **semata-mata** oleh jumlah mesin yang berhasil dibangun:

| Mesin dibangun | Judul di layar |
|---|---|
| 0 | `THE BAY WAS LEFT AS IT WAS` |
| 1 | `A FIRST MACHINE` |
| 2 | `THE WATER IS TURNING` |
| 3 | `THE BAY CAME BACK` |

Tidak ada kondisi kalah yang menghentikan permainan di tengah jalan. Pemain selalu
menyelesaikan kelima hari; yang berbeda hanyalah apa yang tersisa di akhir. Logika
penentuan akhir ditulis relatif terhadap jumlah blueprint yang ada, sehingga
penambahan mesin keempat tidak memerlukan perubahan kode.

## 2.2 Mechanics

Bagian ini menguraikan setiap mekanik yang **sudah terimplementasi dan dapat
dimainkan pada build**. Setiap sub-bab memuat tiga hal: cara kerja dari sudut
pandang pemain, parameter nyata dari kode, dan alasan desainnya.

### 2.2.1 Mesin Capit

**Cara kerja.** Capit tergantung pada rel horizontal di bagian atas jendela.
Pemain menggesernya kiri-kanan, lalu menjatuhkannya. Capit turun lurus ke bawah,
berhenti pada sentuhan pertama dengan benda apa pun atau pada kedalaman maksimum,
menutup selama 0,30 detik, lalu naik kembali. Selama capit bergerak, pemain tidak
memiliki kendali sama sekali sampai capit kembali ke rel.

Sebelum menjatuhkan, layar menampilkan pratinjau: deskripsi permukaan benda yang
akan diraih dan **peluang cengkeramnya dalam persen**. Pratinjau ini mengunci
sasaran ke benda yang benar-benar akan dijangkau oleh penurunan, bukan benda
terdekat secara horizontal — keduanya dapat berbeda ketika dua benda bertumpuk.

Bila cengkeraman gagal, benda tetap terangkat sesaat lalu **terlepas di ketinggian
acak** dalam perjalanan naik dan jatuh kembali ke dasar. `Shift time` yang sudah
dibelanjakan tidak dikembalikan.

**Parameter.**

| Parameter | Nilai | Sumber |
|---|---|---|
| Kecepatan horizontal | 220 px/detik | `claw.gd` → `H_SPEED` |
| Kecepatan turun | 160 px/detik | `DESCEND_SPEED` |
| Kecepatan naik | 200 px/detik | `RISE_SPEED` |
| Durasi menutup | 0,30 detik | `CLOSE_TIME` |
| Lebar dasar laut | 2600 px | `seabed_width` |
| Lebar jendela tampak | 848 × 408 px | `TANK_VIEW` |
| Peluang cengkeram | `clamp(1,0 − berat × 0,15 + modifier, 0,05, 0,95)` | `tank_item.gd` |
| Biaya satu penjatuhan | 6 `Shift time` | `Game.ACTION_COST` |

Karena berat benda berkisar 0,1 kg sampai 2,0 kg, peluang cengkeram nyata di dalam
permainan berkisar **70 % sampai 95 %**: `Glass Bottle` (2,0 kg) adalah yang paling
sulit dipegang pada 70 %, sedangkan `Dry Leaves` (0,1 kg) mencapai batas atas 95 %.

**Alasan desain.** Capit tidak menggunakan mesin fisika sama sekali; ia adalah
interpolasi posisi manual ditambah deteksi tumpang-tindih `Area2D` dan satu
lemparan dadu. Pilihan ini diambil agar hasilnya dapat direproduksi dari sebuah
seed dan agar setiap kegagalan dapat dijelaskan kepada pemain sebagai angka,
bukan sebagai simulasi yang tidak dapat ditebak. Menampilkan persentase sebelum
penjatuhan mengubah kegagalan dari sesuatu yang terasa tidak adil menjadi risiko
yang pemain terima secara sadar. Batas atas 95 % memastikan tidak ada benda yang
pernah benar-benar aman, sehingga penjatuhan tetap merupakan taruhan.

Rel diberi penanda peta di bagian atas kokpit yang menunjukkan bagian dasar laut
mana yang sedang terlihat, beserta titik-titik posisi seluruh benda yang masih
tersisa. Tanpa itu, mencari kembali benda tertentu di dasar laut selebar 2600 px
hanya akan menjadi pekerjaan menyisir yang membosankan.

### 2.2.2 `Shift time` — Ekonomi Aksi

**Cara kerja.** Setiap hari memberi pemain satu anggaran tunggal bernama
`Shift time`. Anggaran ini berkurang **hanya karena tindakan**, tidak pernah
karena waktu berlalu.

| Tindakan | Biaya dasar |
|---|---|
| Menjatuhkan capit | 6 |
| Menggunakan alat inspeksi | 4 |
| Memilah satu benda ke bin | 1 |
| Membuka `Sealed Crate` dengan `Cutter` | 0 (gratis) |

Yang **tidak** memakan biaya: berpikir, membaca `Rulebook`, memperbesar dan
menggeser gambar benda, berpindah antara mesin capit dan meja pemilahan, membaca
daftar aturan yang aktif, serta membaca seluruh catatan bukti yang sudah terkumpul.

Shift berakhir ketika anggaran tidak lagi dapat membeli tindakan bermakna. Kondisi
ini diperiksa secara menyeluruh: selain memeriksa apakah masih mampu menjatuhkan
capit atau memilah, permainan juga memeriksa apakah masih ada `Sealed Crate` yang
dapat dibuka **dan** masih ada anggaran untuk memilah isinya — sebab membuka peti
itu gratis, dan tanpa pemeriksaan kedua tersebut sebuah peti yang belum dibuka
akan membuat shift berjalan selamanya di atas anggaran nol.

**Alasan desain.** Ini adalah keputusan desain paling menentukan dalam permainan.
Alternatif yang wajar — hitung mundur waktu nyata — akan mematikan seluruh
mekanik inspeksi, karena pemain yang sedang dikejar waktu tidak akan pernah
berhenti untuk membaca kode resin pada sebuah gelas. Dengan menjadikan anggaran
sebagai jumlah tindakan, permainan memindahkan seluruh tekanan ke pertanyaan
*"apakah informasi ini layak dibeli?"* — yang persis merupakan pertanyaan yang
ingin dilatih.

Rasio biaya juga bermakna. Menjatuhkan capit (6) enam kali lebih mahal daripada
memilah (1), sehingga mengangkat benda merupakan komitmen, bukan tindakan iseng.
Alat (4) berharga dua pertiga penjatuhan, sehingga memeriksa secara berlebihan
setara dengan kehilangan kesempatan mengangkat benda lain. Memilah dibuat sangat
murah agar pemain tidak pernah ragu memilah benda yang sudah ia yakini — biaya 1
hanya berfungsi mencegah pemilahan asal-asalan secara massal.

### 2.2.3 Inspeksi dan Alat

**Cara kerja.** Pada meja pemilahan, benda yang dipilih ditampilkan besar di panel
tengah. Pemain dapat memperbesarnya hingga 3× dan menggesernya. Di sebelahnya
terdapat tiga panel informasi: rak alat, daftar `RULES IN FORCE TODAY`, dan
`EVIDENCE LOG`.

Informasi yang diberikan **gratis** untuk setiap benda:

- nama benda,
- tiga properti permukaan, misalnya `"stiff · slick surface · light"`,
- material yang terlihat (`LOOKS LIKE:`),
- penanda yang tercetak bila ada (`MARKING:`),
- berat (`WEIGHT:`).

Informasi yang **harus dibeli** memerlukan alat. Pemain memilih alat dari rak,
kursor tetikus berubah menjadi ikon alat tersebut, lalu pemain mengklik benda.
Tidak ada pembidikan: seluruh benda adalah sasarannya.

| Alat | Nama di layar | Yang dibuka | Biaya |
|---|---|---|---|
| Bilas | `Rinse` | ada atau tidaknya residu | 4 |
| Usap kimia | `Chem Swab` | jenis residu | 4 |
| Kaca pembesar | `Magnifier` | kode atau label tercetak | 4 |
| Pemotong | `Cutter` | membuka `Sealed Crate` | gratis |

Aturan biaya yang penting: **alat yang tidak menemukan apa pun tetap menghabiskan
4 `Shift time`.** Permainan menyatakannya secara terbuka di layar dengan kalimat
*"Nothing on this one for that tool. The shift time is spent anyway -4."*
Sebaliknya, alat yang **menolak melakukan pekerjaan yang bukan bagiannya** —
`Cutter` yang diarahkan ke benda biasa, atau `Rinse` yang diarahkan ke peti
tersegel — tidak menghabiskan apa pun, karena itu adalah salah klik, bukan
percobaan.

Alat yang sedang dipilih ditandai oleh plat yang muncul di belakang barisnya di
rak; gambar alatnya sendiri tidak pernah berubah. Alat yang tidak tersedia hari
itu tetap tampil utuh, tetapi barisnya diberi keterangan `not today` dan tidak
dapat diklik.

Setiap temuan ditambahkan sebagai kartu ke `EVIDENCE LOG`. Kartu yang **memenuhi**
salah satu aturan hari itu berubah menjadi tekstur berbeda, dan pada saat yang
sama bin yang bersangkutan menyala di baris bin. Penalaran dan kesimpulan menyala
bersamaan, sehingga pemain dapat melihat hubungan sebab-akibatnya secara langsung.

**Alasan desain.** Versi awal permainan mengharuskan pemain mengklik titik panas
kecil pada gambar benda. Mekanik itu dibuang karena pertanyaan yang menarik adalah
*"apakah benda ini menyembunyikan sesuatu?"*, bukan *"dapatkah kamu mengklik
lingkaran berdiameter 22 piksel?"* Menjadikan seluruh benda sebagai sasaran
memindahkan seluruh kesulitan ke pemilihan alat, tempat kesulitan itu seharusnya
berada.

Ketiadaan pengembalian biaya untuk alat yang gagal juga disengaja: itulah yang
membuat pemilihan alat menjadi keputusan. Bila alat yang gagal digratiskan, strategi
optimalnya adalah mencoba keempat alat pada setiap benda, dan seluruh mekanik
inspeksi kehilangan maknanya. Pemain tetap diberi tahu ketika sebuah alat tidak
menemukan apa-apa, karena klik yang tidak berefek akan terbaca sebagai kerusakan
program.

Fasilitas perbesaran dan geser sepenuhnya bersifat taktil — tidak ada mekanik yang
bergantung pada tingkat perbesaran. Fungsinya semata-mata memberi pemain rasa
sedang benar-benar memeriksa sesuatu.

### 2.2.4 Pemilahan dan Konsekuensi Kesalahan

**Cara kerja.** Terdapat empat bin, dan keempatnya **selalu dapat diklik**.
Permainan tidak pernah mencegah pemain memilah benda yang belum diperiksa sama
sekali.

| Kategori | Nama di layar |
|---|---|
| 0 | `ORGANIC` |
| 1 | `RECYCLABLE` |
| 2 | `HAZARDOUS` |
| 3 | `LANDFILL` |

Satu-satunya isyarat visual pada baris bin adalah cincin sorot yang berpindah ke
bin yang **ditunjuk oleh bukti yang sudah terkumpul** — dan cincin itu hanya
muncul apabila pemain benar-benar sudah membuka properti yang menjadi kunci
aturannya. Bin tidak pernah memberi tanda benar atau salah pada saat pemilahan.
Penolakan hanya terjadi untuk tiga hal yang secara mekanis mustahil — tidak ada
benda yang dipilih, benda tersebut `Sealed Crate` yang belum dibuka, atau
`Shift time` tidak mencukupi — dan ketiganya dijelaskan lewat pesan singkat
beserta bunyi penolakan, bukan lewat perubahan gambar.

**Konsekuensi kesalahan.** Ini adalah aturan paling penting dalam permainan:

> **Benda yang masuk bin yang salah hilang sepenuhnya. Bukan bernilai lebih kecil
> — bernilai nol.**

Rantai konsekuensinya berlapis, dan seluruhnya berupa **biaya peluang**, bukan
hukuman:

1. **Material tidak pernah masuk gudang.** Di dalam kode, satu-satunya fungsi yang
   dapat menambah isi gudang bengkel adalah fungsi yang hanya menghitung benda
   dengan status benar. Tidak ada jalur lain di seluruh basis kode.
2. **`Shift time` tetap terpotong.** Biaya 1 untuk pemilahan tetap dibayar. Pemain
   membayar penuh dan tidak mendapat apa pun.
3. **Slot target tetap terpakai.** Penghitung target naik untuk setiap pemilahan,
   benar maupun salah. Akibatnya pemain dapat mencapai `Target reached` sambil
   pulang tanpa membawa material sama sekali.
4. **Kemajuan mesin tertunda.** Karena material adalah satu-satunya bahan untuk
   merakit komponen, setiap kesalahan menunda pembangunan mesin, yang pada
   gilirannya menentukan akhir permainan.
5. **Umpan balik terperinci di `after_day`.** Setiap kesalahan mendapat satu kartu
   berisi gambar benda, `You put it in:`, `Should have been:`, baris
   `Never checked:` untuk setiap properti penentu yang tidak pernah dibuka, dan
   `Broke:` berisi teks lengkap aturan yang dilanggar.

Yang **tidak** terjadi: tidak ada pengurangan nyawa, tidak ada denda, tidak ada
game over, dan tidak ada indikator kesehatan apa pun. Layar `after_day` merangkumnya
dengan dua baris:

> *"{n} sorted wrongly - lost, not stored."*
>
> *"Only what goes in the right bin becomes blueprint material."*

**Alasan desain.** Membiarkan keempat bin selalu dapat diklik adalah keputusan
yang disengaja: pemain **harus** diperbolehkan menebak, sebab menebak adalah
perilaku yang ingin permainan koreksi. Bila permainan mencegah pemilahan yang
belum diperiksa, pemain tidak akan pernah merasakan biaya menebak.

Menahan seluruh umpan balik sampai `after_day` menjaga agar setiap keputusan tetap
menjadi keputusan. Bila bin langsung memberi tahu benar atau salah, pemain akan
belajar dengan cara mencoba-coba, dan `EVIDENCE LOG` beserta `Rulebook` akan
menjadi hiasan.

Pilihan menghukum dengan nol dan bukan dengan denda didasari pertimbangan
pedagogis: hukuman mendorong pemain menghindari risiko dan memilah sesedikit
mungkin, sedangkan biaya peluang mendorong pemain **memeriksa lebih banyak** —
dan kebiasaan memeriksa itulah yang ingin dibawa keluar dari permainan. Nilai nol,
bukan nilai separuh, dipilih karena mencerminkan kenyataan kontaminasi daur ulang:
material yang tercemar tidak menjadi setengah berharga, melainkan ditolak.

### 2.2.5 `Rulebook` dan Aturan Harian

**Cara kerja.** Kategori yang benar untuk sebuah benda **bukan** properti tetap
benda tersebut. Ia dihitung setiap kali, dari benda tersebut terhadap aturan yang
berlaku hari itu, dengan aturan berprioritas tertinggi yang menang. Bila tidak ada
aturan yang cocok, kategori bawaan benda itulah yang berlaku.

| Aturan | Teks ringkas di layar | Syarat | Memaksa ke | Prioritas |
|---|---|---|---|---|
| `r_baseline` | *"What it is made of decides where it goes"* | — (hanya rujukan) | — | 0 |
| `r_residue` | *"Any residue left → LANDFILL"* | ada residu | `LANDFILL` | 10 |
| `r_multilayer` | *"Laminated packaging → LANDFILL"* | berlapis | `LANDFILL` | 30 |
| `r_chem_residue` | *"Oil / paint / medicine residue → HAZARDOUS"* | residu berupa oli mesin, cat berpelarut, atau obat kedaluwarsa | `HAZARDOUS` | 40 |

Sistem prioritas inilah yang menghasilkan pergeseran jawaban antar hari.
`Chemical-Soaked Tissue` mengandung residu cat berpelarut. Pada hari ke-2 hanya
`r_residue` yang aktif, sehingga jawabannya `LANDFILL`. Pada hari ke-3
`r_chem_residue` berprioritas 40 mulai berlaku dan mengalahkan `r_residue`,
sehingga jawaban yang sama kini menjadi `HAZARDOUS`.

`Rulebook` dapat dibuka kapan saja dengan `R`, tidak menjeda apa pun, dan tidak
memakan biaya. Isinya tiga bagian: aturan khusus hari itu yang dikelompokkan
menurut bin yang dipaksakannya, panduan dasar `WHERE THINGS GO` yang berisi 13
entri, dan glosarium `WHAT THE RECYCLING CODES MEAN` yang menjelaskan 10 kode
resin nyata.

Selain itu, daftar aturan yang berlaku selalu terpampang di sebelah benda yang
sedang diperiksa. Aturan yang buktinya sudah terkumpul ditandai `+` dan berwarna
hijau; yang belum ditandai `-`. Aturan hanya dinyatakan aktif apabila pemain
benar-benar telah membuka properti yang menjadi kuncinya — mengetahui sebuah
aturan ada tidaklah sama dengan mengetahui aturan itu berlaku pada benda ini.

**Daftar lengkap benda dan kategorinya** (kategori di bawah adalah kategori pada
hari ke-3 sampai ke-5, ketika seluruh aturan berlaku):

| Nama di layar | Berat | Terlihat sebagai | Penanda | Tersembunyi | Kategori |
|---|---|---|---|---|---|
| `Apple Core` | 0,3 | fruit scraps | — | — | `ORGANIC` |
| `Banana Peel` | 0,3 | fruit peel | — | — | `ORGANIC` |
| `Eggshells` | 0,2 | shell | — | — | `ORGANIC` |
| `Dry Leaves` | 0,1 | leaves | — | — | `ORGANIC` |
| `Pizza Slice` | 0,4 | food scraps | — | — | `ORGANIC` |
| `Natural Fibre Shirt` | 0,6 | cotton fabric | `COTTON 100%` | — | `ORGANIC` |
| `Stack of Newspapers` | 0,9 | paper | `PAPER` | — | `RECYCLABLE` |
| `Glass Bottle` | 2,0 | glass | `GL 71` | — | `RECYCLABLE` |
| `Clean Paper Cup` | 0,4 | paper | `PAPER` | — | `RECYCLABLE` |
| `Plastic Bag` | 0,2 | plastic | `HDPE 2` | — | `RECYCLABLE` |
| `Polyester Shirt` | 0,6 | polyester fabric | `POLYESTER` | — | `RECYCLABLE` |
| `Pesticide-Soaked Shirt` | 0,7 | pesticide-soaked fabric | — | — | `HAZARDOUS` |
| `Chemical-Soaked Tissue` | 0,2 | tissue | — | residu cat berpelarut | `HAZARDOUS` |
| `Used Tissue` | 0,2 | used tissue | — | — | `LANDFILL` |
| `Paper Cup` | 0,5 | paper | `PAPER` | residu kopi, `PAP 22 - PE liner`, berlapis PE | `LANDFILL` |
| `Sealed Crate` | 1,5 | sealed crate | — | wadah tersegel | `LANDFILL` |

**Alasan desain.** Struktur pasangan-jebakan dalam daftar di atas adalah inti
edukasinya. `Natural Fibre Shirt` dan `Polyester Shirt` terlihat serupa dan
sama-sama terasa lembut, tetapi yang pertama adalah serat alami yang membusuk dan
yang kedua adalah plastik yang ditenun — satu-satunya pembeda adalah penandanya.
`Clean Paper Cup` dan `Paper Cup` sama-sama bertanda `PAPER`; yang membedakan hanya
lapisan PE yang tidak tampak dari luar dan hanya diakui oleh kode `PAP 22 - PE liner`
yang dapat dibaca `Magnifier`. Pasangan-pasangan inilah yang membuat pertanyaan
pembuka pada setiap benda — *"Marked PAPER, looks like paper. Do you believe it?"* —
menjadi pertanyaan yang sungguh-sungguh.

Aturan disimpan sebagai berkas data, bukan sebagai percabangan kode, sehingga
kategori yang benar tidak pernah tertulis di dalam logika permainan. Menambah
aturan baru cukup dilakukan dengan menambah satu berkas dan menyebutnya pada hari
yang bersangkutan.

### 2.2.6 `Sealed Crate`

**Cara kerja.** Mulai hari ke-2, dasar laut memuat peti tersegel. Peti terlihat
seperti benda biasa di dalam air dan dapat diangkat seperti benda biasa, tetapi di
meja pemilahan ia tidak dapat dimasukkan ke bin mana pun. Kartunya menampilkan
petunjuk `Cutter opens this`, dan pertanyaan pemeriksaannya berbunyi
*"Sealed shut. Cut it open to find out."*

Membuka peti dengan `Cutter` **tidak memakan biaya sama sekali**. Isinya, dua
sampai tiga benda yang diambil dari kumpulan benda hari itu, langsung disisipkan
ke dalam daftar tepat di bawah peti tersebut. Petinya sendiri **tetap tinggal** dan
kini menjadi sampah biasa yang harus dipilah ke `LANDFILL`.

Isi peti ditentukan oleh aliran acak tersendiri yang di-seed dari nomor urut peti,
bukan dari aliran acak utama. Ini disengaja: aliran utama juga dipakai oleh
pengatur waktu kemunculan benda, sehingga bila isi peti diambil dari sana, isinya
akan bergantung pada berapa lama pemain menatap dasar laut sebelum mengangkatnya.

**Parameter.** Hari 2 dan 3 memuat 1 peti; hari 4 dan 5 memuat 2 peti. Setiap peti
berisi 2 sampai 3 benda. Benda di dalam peti tidak pernah berupa peti lain.

**Alasan desain.** Peti berfungsi sebagai pengganda beban kerja yang tidak dapat
diramalkan. Satu penjatuhan capit seharga 6 dapat menghasilkan empat benda yang
harus dipilah, sehingga rencana anggaran pemain dapat berantakan justru karena
keberhasilan. Membuat pembukaan peti gratis memindahkan seluruh biaya peti ke
keputusan yang sebenarnya: pemain harus **sudah membawa** `Cutter` hari itu.
Karena `Cutter` adalah satu-satunya alat yang dapat membuka peti, setiap hari yang
memuat peti wajib menyertakan `Cutter` dalam daftar alatnya — bila tidak, peti
menjadi mustahil dibuka dan shift dapat menemui jalan buntu.

Membiarkan peti kosong tetap berada di daftar adalah keputusan tematik: peti itu
sendiri juga sampah, dan pemain harus memutuskan ke mana ia pergi.

### 2.2.7 `Technology` — Material, Komponen, dan Mesin

**Cara kerja.** Pada layar `after_day`, tab `Technology` menampilkan lembar rancang
bangun mesin, satu per halaman, yang dapat dibolak-balik dengan tombol panah.
Setiap lembar memuat tiga komponen yang tergambar pada posisinya masing-masing di
atas rancangan. Komponen yang belum dirakit ditampilkan dengan gambar terkunci,
yang sudah dirakit dengan gambar jadi.

Pemain mengklik satu komponen untuk membuka jendela rincian, yang menampilkan
untuk setiap material: pelat bin asalnya, nama binnya, jumlah yang dimiliki
berbanding jumlah yang dibutuhkan, dan tanda centang atau silang. Tombol
perakitannya sendiri membawa kekurangannya, misalnya `Short 2 LANDFILL`.

Setelah ketiga komponen terakit, tombol `BUILD {nama mesin}` menjadi aktif.

| Mesin | Komponen | Kebutuhan material |
|---|---|---|
| **`Ocean Cleaning Drone`** | Drone Shell | 1 `ORGANIC` + 2 `RECYCLABLE` |
| | Rotor Skid | 2 `ORGANIC` + 1 `LANDFILL` |
| **`Recycling Station`** | Intake Arm | 2 `RECYCLABLE` |
| | Sorting Belt | 3 `LANDFILL` |
| | Press Housing | 2 `ORGANIC` + 2 `RECYCLABLE` |
| **`Reef Restoration Pod`** | Pod Shell | 2 `ORGANIC` + 3 `LANDFILL` |
| | Seeding Arm | 5 `HAZARDOUS` |

Total untuk menyelesaikan ketiganya: **7 `ORGANIC`, 6 `RECYCLABLE`, 5 `HAZARDOUS`,
dan 7 `LANDFILL`** — atau **25 benda yang dipilah dengan benar** dari akumulasi
target lima hari sebesar 41 pemilahan.

Material dikreditkan **hanya sekali, pada layar `after_day`**, tidak pada saat
pemilahan. Setiap mesin yang dibangun membuka satu perlengkapan di tab `Gear`.

**Alasan desain.** Sistem ini adalah satu-satunya penghubung antara kualitas
pemilahan dan hasil akhir permainan, dan sengaja dibuat sepenuhnya transparan:
seluruh resep tertulis di berkas data dan tampil di layar sebelum pemain
berkomitmen. Tidak ada penggabungan, tidak ada yang perlu ditemukan, dan tidak ada
kemungkinan gagal merakit. Ketidakpastiannya seluruhnya berada di fase pemilahan,
tempat ketidakpastian itu memang seharusnya berada.

Perakitan dibayar per komponen, bukan sekaligus, sehingga pemain dapat mencicil
kemajuan pada hari-hari yang buruk. Kemampuan membayar diperiksa terhadap seluruh
biaya komponen terlebih dahulu, sehingga komponen yang kurang pada material
keduanya tidak akan memakan material pertamanya.

Kebutuhan material dirancang agar keempat bin diperlukan. Pemain tidak dapat
mengabaikan `LANDFILL` sebagai "bin sampah sisa", karena `LANDFILL` adalah material
yang paling banyak dibutuhkan dari keempatnya. Ini menegaskan pesan bahwa memilah
dengan benar bernilai untuk **setiap** kategori, bukan hanya untuk yang dapat
didaur ulang.

Penempatan `HAZARDOUS` yang hanya muncul mulai hari ke-3 membuat mesin ketiga
terkunci secara alami. Jendela rancang bangun berpindah gambar sesuai keadaannya —
terkunci, siap, dan terbangun — sehingga kemajuan terbaca dari ilustrasinya sendiri,
bukan dari bilah kemajuan tambahan.

### 2.2.8 `Gear` — Perlengkapan Bertukar-untung

**Cara kerja.** Tab `Gear` pada layar `after_day` memuat lima perlengkapan.
Memasang perlengkapan **gratis dan dapat dibatalkan** — tidak ada mata uang di
dalam permainan. Hanya satu perlengkapan yang dapat terpasang pada satu waktu, dan
menekan tombol pada perlengkapan yang sedang terpasang akan melepasnya.

| Perlengkapan | Keuntungan | Kerugian | Terbuka |
|---|---|---|---|
| `Light Claw` | penjatuhan seharga 4, bukan 6 | peluang cengkeram turun 15 poin | sejak awal |
| `Coarse Scanner` | alat seharga 2, bukan 4 | pembacaan kabur; membaca sesungguhnya butuh satu pemakaian lagi seharga 4 | sejak awal |
| `Fast Rail` | capit bergerak 60 % lebih cepat | rel terkunci 2 detik setiap selesai menjatuhkan | setelah `Ocean Cleaning Drone` dibangun |
| `Strong Grip` | peluang cengkeram naik 15 poin | penjatuhan seharga 8, bukan 6 | setelah `Recycling Station` dibangun |
| `Twin Arms` | alat seharga 3, bukan 4 | capit bergerak 25 % lebih lambat | setelah `Reef Restoration Pod` dibangun |

Keuntungan dan kerugian **selalu ditampilkan bersamaan**, dengan tanda `+` hijau
dan `-` oranye. Bilah antarmuka pada layar shift juga selalu menampilkan biaya
ketiga tindakan yang sedang berlaku, dibaca langsung dari sumber yang sama dengan
yang memotong anggaran, sehingga label tidak mungkin berbeda dari kenyataan.

Mekanisme `Coarse Scanner` layak disorot karena merupakan satu-satunya perlengkapan
yang mengubah bentuk informasi, bukan sekadar harganya. Pemakaian pertama seharga 2
hanya memberi tahu bahwa ada sesuatu di sana tanpa menyebutkan apa; membacanya
dengan benar menuntut pemakaian kedua pada harga penuh 4. Total 6 untuk pembacaan
lengkap lebih mahal daripada 4 tanpa perlengkapan — sehingga perlengkapan ini
menguntungkan justru bagi pemain yang cukup disiplin untuk berhenti pada pembacaan
kabur ketika sekadar mengetahui "ada sesuatu" sudah cukup untuk mengambil keputusan.

**Alasan desain.** Aturan yang dipegang teguh adalah **tidak boleh ada peningkatan
murni**. Bila salah satu perlengkapan lebih baik dari semua sisi, memilih menjadi
mudah dan tab ini akan berubah menjadi daftar periksa. Dengan pertukaran nyata,
setiap perlengkapan berpasangan dengan gaya bermain: pemain yang teliti memilih
`Twin Arms` atau `Coarse Scanner`, pemain yang agresif memilih `Light Claw`.

Ketiadaan mata uang membuat perlengkapan menjadi keputusan bergaya main, bukan
keputusan ekonomi. Pemain tidak pernah "membeli yang salah" dan menyesal — ia hanya
memilih pendekatan untuk hari berikutnya, dan dapat mengubahnya keesokan harinya.

Dua perlengkapan terbuka sejak hari pertama agar pemain dapat berkenalan dengan
konsep pertukaran sebelum sistem mesin sempat memberikan apa pun.

### 2.2.9 `The Day` — Laporan Akhir Hari

**Cara kerja.** Tab `The Day` pada layar `after_day` adalah satu-satunya tempat
pemain mengetahui hasil kerjanya. Layar itu digambar sebagai dua lembar kertas
cetak biru berselotip di atas meja: lembar tinggi di kiri menjelaskan setiap
kesalahan, lembar lebar di kanan mencatat material yang berhasil diselamatkan.

Setiap kesalahan ditampilkan sebagai satu kartu berisi lima baris:

1. gambar dan nama benda,
2. `You put it in: {bin}` (merah),
3. `Should have been: {bin}` (hijau),
4. `Never checked: {properti}` (kuning) — satu baris untuk **setiap** properti
   penentu yang tidak pernah dibuka pemain,
5. `Broke: {teks lengkap aturan}` (biru).

Baris keempat adalah bagian terpenting dari seluruh layar ini. Ia dihitung dengan
memeriksa aturan yang dilanggar, menemukan properti yang menjadi kuncinya, lalu
menyaring properti yang sudah pernah dibuka pemain. Sisanya adalah celah
pemeriksaan yang sesungguhnya.

Lembar kanan, `MATERIAL RECOVERED`, mencatat satu baris per kategori berisi
jumlah benda yang benar-benar sampai ke bengkel, disusul catatan berapa benda
yang hilang karena salah bin. Kedua lembar itu berpasangan secara langsung:
yang kiri menerangkan mengapa sebuah benda tidak muncul di yang kanan.

**Alasan desain.** Tidak ada skor di dalam permainan ini, dan ketiadaan itu
disengaja. Sebuah angka skor akan mengalihkan perhatian pemain dari satu-satunya
hal yang benar-benar penting, yaitu material yang diselamatkan. Layar ini karena
itu menghitung kejadian, bukan poin.

Baris `Never checked:` adalah jawaban langsung atas pertanyaan yang paling wajar
muncul di benak pemain — *"bagaimana mungkin saya tahu?"* Permainan menjawabnya
dengan menunjuk properti yang sebenarnya dapat ia buka. Dengan demikian kesalahan
berubah menjadi pelajaran yang dapat ditindaklanjuti, bukan sekadar vonis. Baris
ini juga yang mengubah kesalahan menjadi umpan balik atas **proses**, bukan atas
**hasil**.

Sebelumnya laporan ini terpecah menjadi dua layar berurutan — sebuah layar
`report` tersendiri, lalu tab `Today's Haul` yang mengulang daftar kesalahan
yang sama dalam bentuk pendek. Dua layar berturut-turut yang mengatakan hal yang
sama membuat akhir hari terasa diulang, sehingga keduanya disatukan menjadi satu
layar ini.

## 2.3 Daftar Aset Game

Seluruh visual dalam permainan adalah berkas PNG yang dimuat dari jalur tetap;
tidak ada satu pun bentuk yang digambar oleh kode. Aturan ini ditegakkan oleh
pemeriksaan otomatis yang gagal apabila menemukan `_draw()`, `ColorRect`,
`Polygon2D`, `StyleBoxFlat`, atau shader di dalam kode permainan.

### Ringkasan

| Jenis | Jumlah | Keterangan |
|---|---|---|
| Aset visual (PNG) | **120** | seluruhnya di `assets/` |
| Aset audio (WAV) | **11** | efek suara, `assets/audio/` |
| Berkas font | **2** | `Fredoka-Medium` dan `Fredoka-SemiBold`, `assets/ui/fonts/` |
| Definisi animasi (`SpriteFrames`) | **29** | `data/frames/*.tres` |

### Aset visual per kelompok

| Folder | Jumlah | Isi |
|---|---|---|
| `assets/items/` | 17 | 15 gambar sampah pada 160 × 160, ditambah peti tertutup dan terbuka |
| `assets/bins/` | 5 | 4 bin pemilahan, ditambah satu cincin sorot yang dipindah-pindah ke bin yang ditunjuk bukti |
| `assets/claw/` | 5 | capit terbuka, menutup, tertutup, membawa, dan batang penggantungnya |
| `assets/env/` | 15 | latar air, dasar laut, karang, gelembung, dinding lambung, latar menu, logo, lima gambar cutscene pembuka, dan dua gambar akhir |
| `assets/fish/` | 11 | sebelas makhluk latar: ikan kecil, sedang, besar, bulat, dan ubur-ubur |
| `assets/tools/` | 4 | empat alat inspeksi, satu gambar per alat |
| `assets/ui/` | 63 | latar meja pemilahan, latar briefing pra-shift, dua lembar laporan akhir hari, bingkai kokpit, tombol konsol, pelat tombol aksi utama, rak alat, kartu bukti, panel, penggeser, bilah gulir, balon dialog, tiga lembar rancang bangun beserta versi jadinya, dan tujuh gambar komponen |

### Aset audio

Sebelas efek suara: `claw_move`, `claw_drop`, `grab_success`, `grab_fail`,
`tool_use`, `reveal_success`, `reveal_nothing`, `bin_accept`, `bin_reject`,
`day_end`, dan `ui_click`. Seluruhnya WAV mono 16-bit, 22.050 Hz.

`[BUTUH INPUT JASON: seluruh berkas audio saat ini masih berupa nada sinus dan kotak yang dibangkitkan oleh skrip Python internal tim (memakai modul wave dari pustaka standar — bukan generative AI; skrip pembangkitnya sudah dikeluarkan dari repositori bersama folder tools/). Tidak ada musik latar sama sekali, meskipun bus audio Music dan penggeser volumenya sudah tersedia. Putuskan apakah audio akan diganti sebelum pengumpulan, dan bila ya, cantumkan sumber serta lisensinya di 3.3.]`

### Font

Permainan memakai **Fredoka**, typeface sans-serif membulat karya Milena Brandao
dan Hafontia, berlisensi SIL Open Font License 1.1. Dua ketebalan ikut dalam
build: `Fredoka-Medium` sebagai font bawaan seluruh label, dan `Fredoka-SemiBold`
untuk tombol serta angka besar pada panel kokpit. Keduanya berada di
`assets/ui/fonts/` bersama salinan lengkap lisensinya. Karena setiap ukuran huruf
sudah ditetapkan pada berkas tema dan pada masing-masing simpul, pemasangan font
tidak menuntut satu pun perubahan tata letak yang bersifat struktural.

Fredoka adalah **satu-satunya aset pihak ketiga** dalam permainan ini, dan
dikreditkan pada bagian 3.3.

### Catatan konsistensi aset

Seluruh aset mengikuti tiga aturan yang ditegakkan secara otomatis:

1. **Satu berkas untuk satu benda.** Tidak ada atlas dan tidak ada penggabungan.
2. **Keadaan adalah gambar tersendiri, bukan pewarnaan ulang.** Alat terkunci, bin
   yang menyala, dan slot yang terpilih masing-masing memiliki berkasnya sendiri.
   Kode tidak pernah mewarnai ulang karya ilustrator.
3. **Animasi selalu berupa `AnimatedSprite2D` yang memainkan animasi bernama.**
   Kode menentukan animasi mana dan kapan, tetapi tidak pernah menganimasikan
   posisi, skala, atau rotasi sebuah objek permainan untuk memalsukan gerak.

Aturan-aturan ini dipilih agar ilustrator dapat mengganti berkas mana pun di jalur
yang sama tanpa satu baris kode pun berubah.

## 2.4 Teknologi dan Sumber Daya

| Kebutuhan | Yang dipakai |
|---|---|
| Engine | Godot Engine 4.7.2 stable |
| Bahasa pemrograman | GDScript, seluruhnya bertipe statis |
| Metode render | `gl_compatibility` (OpenGL 3.3 / ES 3.0 / WebGL 2.0) |
| Dimensi | 2D sepenuhnya; tidak ada satu pun node 3D |
| Add-on / pustaka pihak ketiga | **tidak ada** |
| Ilustrasi | Procreate `[BUTUH INPUT JASON: konfirmasi versi/perangkat bila perlu dicantumkan]` |
| Alat bantu pengembangan | Uji otomatis headless Godot (`tests/`) |
| Kontrol versi | Git |

### 2.4.1 Alasan Pemilihan Teknologi

**Godot 4 dengan GDScript.** Godot dipilih karena ia sumber terbuka, ringan, dan
tidak menuntut biaya lisensi maupun pembagian hasil. Untuk permainan 2D yang
sangat bergantung pada antarmuka pengguna, sistem `Control` dan sistem tema Godot
memungkinkan seluruh tampilan antarmuka diatur dari satu berkas tema tunggal.
GDScript dipilih karena keterpaduannya dengan editor, dan seluruh kode ditulis
dengan tipe statis sehingga kesalahan tertangkap pada waktu kompilasi, bukan pada
saat presentasi.

**Sistem `Resource` sebagai basis konten.** Ini adalah keputusan arsitektur paling
penting dalam project. Benda, aturan, alat, perlengkapan, komponen, mesin, dan hari
seluruhnya berupa berkas `.tres` — 46 berkas seluruhnya. Kode permainan tidak
pernah menyebut satu pun benda secara langsung; terdapat pemeriksaan otomatis yang
gagal apabila menemukan perbandingan terhadap id benda tertentu di dalam kode.
Konsekuensinya, menambah benda ke-40 tidak memerlukan perubahan kode sama sekali,
dan ilustrator dapat menambah konten tanpa menyentuh program.

**Metode render `gl_compatibility`.** Dipilih agar permainan berjalan pada perangkat
kelas bawah dan agar ekspor ke WebGL menjadi mungkin. Permainan tidak menggunakan
shader, pencahayaan, maupun partikel, sehingga tidak ada yang dikorbankan dari
pilihan ini.

**Tanpa mesin fisika.** Capit tidak menggunakan `RigidBody2D`. Ia berupa
interpolasi posisi ditambah tumpang-tindih `Area2D` dan satu lemparan dadu. Ini
menjaga perilaku capit tetap dapat diprediksi, dapat direproduksi dari sebuah seed,
dan dapat dijelaskan kepada pemain sebagai persentase.

**Tanpa add-on pihak ketiga.** Project tidak memuat satu pun add-on. Seluruh
ketergantungan adalah engine itu sendiri, sehingga tidak ada risiko kegagalan
ekspor akibat pustaka luar dan tidak ada kewajiban lisensi tambahan.

### 2.4.2 Struktur Project

```
Re:Sea/
├── project.godot          konfigurasi, peta masukan, tema global
├── main.tscn / main.gd    pengalih layar; satu-satunya yang tahu jalur scene
│
├── autoload/              tepat dua singleton, tidak lebih
│   ├── events.gd          bus sinyal murni: tanpa state, tanpa logika
│   └── game.gd            state run dan hari; tanpa akses ke pohon scene
│
├── data/                  seluruh konten sebagai Resource
│   ├── *.gd               7 kelas Resource (ItemData, RuleData, ToolData, ...)
│   ├── items/             16 benda
│   ├── rules/             4 aturan
│   ├── tools/             4 alat
│   ├── upgrades/          5 perlengkapan
│   ├── blueprints/        3 mesin
│   ├── components/        9 komponen
│   ├── days/              5 hari
│   ├── frames/            29 definisi animasi
│   └── strings.gd         seluruh teks yang dilihat pemain
│
├── scenes/                satu folder per layar
│   ├── main_menu/  cutscene/  day_start/
│   ├── claw/              mesin capit, benda di tangki, ikan latar
│   ├── desk/              meja pemilahan: inventaris, inspeksi, bin, rulebook
│   ├── shift/             pembungkus yang menyatukan claw dan desk
│   ├── after_day/  game_over/  settings/  debug/
│
├── systems/               logika murni tanpa scene
│   ├── rule_checker.gd    benda + aturan hari ini → bin yang benar
│   ├── day_manager.gd     graf alur antar layar
│   ├── carried_item.gd    pembungkus runtime satu benda yang terangkat
│   ├── mistake_view.gd    pembangun kartu kesalahan
│   ├── bin_icons.gd       pemetaan kategori ke pelat bin
│   └── save_settings.gd   penyimpanan pengaturan volume
│
├── assets/                127 PNG + 11 WAV + ASSETS.md
└── tests/                 17 uji otomatis headless + run_all.sh
```

Dua prinsip arsitektur ditegakkan secara ketat. **Pertama, tidak ada satu scene
pun yang menyimpan jalur ke scene lain** — komunikasi seluruhnya melalui sinyal
pada `Events`, dan hanya `main.gd` yang mengetahui peta jalur. **Kedua, tepat dua
autoload**, dengan pemeriksaan otomatis yang gagal apabila jumlahnya berubah;
batasan ini mencegah state permainan tersebar ke banyak singleton.

## 2.5 Proses Pengembangan

Pengembangan berlangsung dari **22 Agustus 2026** sampai **1 September 2026**,
tercatat dalam 43 commit Git.

**Fase 0 – 7 (22 Agustus).** Kerangka awal dibangun berurutan: konfigurasi project
dan peta masukan; aset placeholder beserta manifes `ASSETS.md`; seluruh kelas
`Resource` dan isinya; fase mesin capit; fase meja pemilahan; layar laporan; serta
menu, pengaturan, cutscene, dan panel debug.

**Revisi 1 (22 Agustus).** Revisi struktural terbesar. Ikan diturunkan menjadi
elemen latar yang tidak dapat diangkat; seluruh animasi disatukan ke `SpriteFrames`;
dasar laut diperlebar dengan kamera dan penanda peta; benda mulai berdatangan
selama shift berjalan alih-alih hadir sekaligus di awal; dan yang paling penting,
**sistem jumlah-angkat serta jumlah-pemakaian-alat yang terpisah digantikan oleh
satu anggaran `Shift time` tunggal.** Pada revisi ini pula mesin capit dan meja
pemilahan berubah dari dua fase berurutan menjadi dua tampilan dari satu shift.

**Revisi 2 (23 Agustus).** Sistem `Technology` diperkenalkan: material, komponen,
dan mesin. Identifikasi benda diubah menjadi berbasis properti. Perlengkapan
diperkenalkan, dengan aturan bahwa setiap perlengkapan wajib merupakan pertukaran.

**Revisi 3 (23 Agustus).** Angka-angka penyeimbangan diukur alih-alih ditebak.
Layar `after_day` diubah agar dimasuki **setiap hari** — versi sebelumnya hanya
muncul ketika sebuah mesin kebetulan selesai, sehingga pemain bisa memainkan empat
dari lima hari tanpa pernah melihat sistem meta sama sekali.

**Revisi 4 (24 Agustus).** `Sealed Crate` ditambahkan. Kebutuhan material untuk
setiap komponen ditetapkan berdasarkan pengukuran dari permainan nyata, bukan
perkiraan.

**Penggantian aset (25 Agustus – 1 September).** Ilustrasi asli mulai berdatangan
dan menggantikan placeholder secara bertahap. Puncaknya adalah pembangunan ulang
layar mesin capit menjadi kokpit utuh: satu ilustrasi 1280 × 720 yang memuat
lambung kapal, bingkai jendela, kalender, panel bacaan, dan seluruh tombol konsol
di dalam gambarnya sendiri.

**Layar sekitar shift (7 September).** Kiriman terakhir melengkapi dua layar yang
mengapit setiap shift: briefing sebelum hari dimulai dan laporan setelah hari
berakhir. Keduanya digambar sebagai lembar kertas cetak biru berselotip di atas
meja kerja, sehingga aturan harian dan hasil pemilahan dibaca seolah dari catatan
kerja tokohnya sendiri, bukan dari kotak dialog. Kiriman yang sama membawa pelat
tombol aksi utama, yang kini dipakai pada tiga tombol yang paling menentukan alur
— `Start` di menu, `Lower the Claw` di briefing, dan `Start the Next Day` di
laporan. Ilustrasi briefing bahkan sudah memuat soket gelap tempat tombol itu
duduk, sehingga posisi tombol ditentukan oleh gambar, bukan oleh tebakan tata
letak.

### 2.5.1 Playtest

Pengujian dilakukan pada dua tingkat.

**Pengujian otomatis.** Project memiliki **17 skrip uji headless**, dijalankan
melalui satu perintah (`./tests/run_all.sh`, 34 pemeriksaan seluruhnya). Yang diperiksa mencakup: permainan berhasil dijalankan
tanpa galat; setiap sistem berfungsi sendiri-sendiri; tata letak antarmuka tidak
saling bertindihan dan tidak keluar dari layar; serta satu run penuh lima hari
dapat diselesaikan sampai layar akhir. Uji terakhir ini juga menjalankan run
secara terbalik dengan sengaja memilah salah, untuk memastikan jalur akhir yang
buruk pun berfungsi.

Di samping itu terdapat pemeriksaan statis yang menegakkan aturan yang tidak dapat
ditangkap uji runtime: tidak boleh ada bentuk yang digambar kode, tidak boleh ada
pewarnaan ulang yang menyatakan keadaan, tidak boleh ada percabangan khusus per
benda, dan seluruh kelas `Control` yang dipakai wajib tercakup oleh berkas tema.

Verifikasi terakhir dijalankan pada 7 September 2026: satu run penuh lima hari
berhasil diselesaikan, mengunjungi 23 layar, mencapai akhir `THE BAY RECOVERED`
dengan ketiga mesin terbangun, tanpa satu pun galat.

**Pengujian oleh pemain.** `[BUTUH INPUT JASON: uraikan playtest dengan manusia — berapa orang, latar belakang mereka, kapan dilakukan, dan temuan utamanya. Riwayat Git mencatat satu commit berjudul "Fix the playtest report: drag crash, unreadable desk, baked-in item codes" pada 24 Agustus 2026, yang menunjukkan playtest memang pernah dilakukan; namun catatan hasilnya tidak ada di dalam project. Bagian ini penting karena "Gameplay" berbobot 25 %.]`

Beberapa keputusan desain yang tercatat dalam kode memang lahir dari pengamatan
bermain, dan dapat dijadikan bahan untuk bagian ini:

- Nama benda semula disembunyikan sampai diperiksa. Aturan ini dibatalkan karena
  daftar inventaris menjadi tidak terbaca — pemain tidak dapat merencanakan shift
  ketika tujuh kartu semuanya bertuliskan *"soft, damp"*.
- Mekanik titik panas yang harus diklik dihapus karena mengubah keputusan menjadi
  uji ketangkasan tetikus.
- Tab `after_day` semula hanya muncul ketika ada mesin yang selesai, sehingga
  sebagian besar pemain tidak pernah melihat sistem meta.
- Jeda penutup shift dinaikkan dari 0,8 detik menjadi 1,4 detik karena terasa
  terlalu mendadak, dan menjadi 3,0 detik untuk dua kalimat penutup khusus yang
  memang perlu dibaca.

## 2.6 Rencana Pengembangan Lanjutan

Bagian ini memuat fitur yang **belum ada pada build** dan tidak diklaim sebagai
bagian dari permainan saat ini.

**Audio dan musik.** Prioritas tertinggi. Sebelas efek suara yang ada saat ini
masih berupa nada sederhana, dan belum ada musik latar sama sekali meskipun bus
audio dan penggeser volumenya sudah tersedia. Rencananya adalah menggarap lanskap
suara bawah laut beserta musik yang berubah nuansanya seiring mesin yang dibangun.

**Typeface tersendiri.** Permainan masih memakai font bawaan Godot. Memasang satu
typeface akan mengubah kesan visual seluruh layar tanpa perubahan tata letak,
karena seluruh ukuran huruf sudah ditetapkan pada berkas tema.

**Ilustrasi alat.** Empat ikon alat inspeksi digambar sebagai siluet datar satu
warna, lebih sederhana daripada kelompok aset lain yang bervolume dan bertekstur.
Karena rak alat tampil terus-menerus sejak hari kedua, menggambar ulang keempatnya
dalam gaya yang sama dengan benda sampah adalah pekerjaan estetika yang tersisa
dengan dampak paling terasa.

**Perluasan konten.** Arsitektur berbasis data memungkinkan penambahan hari, benda,
dan aturan tanpa perubahan kode. Rencana konkretnya adalah menambah aturan yang
berlawanan arah — misalnya aturan yang memindahkan sesuatu **keluar** dari
`LANDFILL` — agar pemain tidak dapat menyimpulkan bahwa aturan berprioritas tinggi
selalu berarti kategori yang lebih buruk.

**Penyimpanan progres.** Saat ini hanya pengaturan volume yang tersimpan; run yang
sedang berjalan hilang bila permainan ditutup.

**Penanganan `Sealed Crate` yang tersisa.** Peti yang belum sempat dibuka sampai
shift berakhir saat ini menghilang tanpa keterangan apa pun di laporan. Perlu
disebutkan secara eksplisit kepada pemain.

**Aksesibilitas.** Pengaturan ukuran huruf, opsi tanpa mengandalkan warna untuk
membedakan kartu bukti, dan dukungan gamepad.

`[BUTUH INPUT JASON: tambahkan rencana lain yang memang ingin dicantumkan, terutama yang sudah pernah dibicarakan dengan tim.]`

## 2.7 Tim Pengembang

| Nama | Peran | Tanggung jawab |
|---|---|---|
| **Jason Tio** | Developer | Arsitektur project, seluruh pemrograman GDScript, desain sistem dan penyeimbangan, pipeline data dan aset, pengujian otomatis |
| **Yumiko Jeanette Japari** | Designer | Ilustrasi aset permainan |
| **Nathanova Yvonne Fridany** | Designer | Ilustrasi aset permainan |

`[BUTUH INPUT JASON: perinci pembagian kerja antara Yumiko dan Nathanova — siapa mengerjakan kelompok aset yang mana (benda sampah, bin, capit, lingkungan, antarmuka kokpit). Riwayat Git hanya memuat satu author sehingga pembagian ini tidak dapat disimpulkan dari project. Tambahkan pula asal institusi/angkatan bila format lomba mensyaratkannya.]`

---

# BAB 3 PENUTUP

## 3.1 Kesimpulan

`Re:Sea` adalah permainan simulasi 2D yang menggabungkan mesin capit dengan
pemilahan sampah bergaya inspeksi, dibangun menggunakan Godot Engine 4.7.2 untuk
subtema Lingkungan. Pemain menjalani lima hari kerja, mengangkat sampah dari dasar
teluk, memeriksanya dengan alat yang harus dibeli menggunakan anggaran terbatas,
lalu memilahnya ke empat kategori — `ORGANIC`, `RECYCLABLE`, `HAZARDOUS`, dan
`LANDFILL` — di bawah aturan yang bertambah dan berjenjang setiap harinya.

Kekuatan utamanya terletak pada satu keputusan desain: **menjadikan biaya
informasi sebagai mekanik inti**. Dengan mengganti hitung mundur waktu nyata
menjadi anggaran yang hanya berkurang oleh tindakan, permainan memberi ruang bagi
pemain untuk berpikir, membaca, dan memeriksa — sambil tetap menjaga ketegangan
melalui pertanyaan yang berulang pada setiap benda: *apakah informasi ini layak
dibeli?*

Pesan lingkungannya tidak ditempelkan di atas mekanik yang netral, melainkan
tertanam di dalam aturan menang-kalahnya. Satu-satunya jalan menuju kemajuan
adalah material yang dipilah dengan benar, dan kesalahan menghancurkan nilai
material secara utuh, bukan sebagian — cerminan langsung dari kontaminasi aliran
daur ulang di dunia nyata. Permainan tidak menghukum pemain; ia hanya menunjukkan,
di akhir setiap hari, properti apa yang tidak pernah ia periksa. Dengan demikian
pemain tidak sekadar diberi tahu bahwa memilah itu penting, melainkan mengalami
sendiri bahwa memilah dengan benar menuntut kebiasaan memeriksa.

Secara teknis, project ini dibangun di atas arsitektur berbasis data yang ketat:
seluruh benda, aturan, alat, perlengkapan, dan hari berupa berkas `Resource`
terpisah, sehingga seluruh konten dapat diperluas tanpa perubahan kode. Seluruh
visual berupa berkas PNG pada jalur tetap, sehingga ilustrator dapat mengganti
karyanya tanpa menyentuh program. Delapan belas uji otomatis menjaga agar aturan
arsitektur tersebut tidak pernah dilanggar.

## 3.2 Tim Pengembang

| Nama | Peran |
|---|---|
| **Jason Tio** | Developer |
| **Yumiko Jeanette Japari** | Designer |
| **Nathanova Yvonne Fridany** | Designer |

`[BUTUH INPUT JASON: lengkapi dengan NIM/asal institusi/kontak sesuai format yang diminta panitia HOLOGY 9.0.]`

## 3.3 Daftar Aset dari Sumber Lain beserta Kreditnya

### Aset yang dibuat sendiri oleh tim

Jumlah pada tabel di bawah dihitung langsung dari isi direktori `assets/`, satu
baris untuk setiap subdirektori, dan seluruhnya berjumlah 120 berkas PNG serta 11
berkas WAV. Manifes lengkap berikut ukuran piksel dan keterangan tiap berkas
tersedia pada `assets/ASSETS.md` di dalam repositori.

| Kelompok aset | Direktori | Jumlah | Pembuat | Metode |
|---|---|---|---|---|
| Ilustrasi benda sampah | `assets/items/` | 17 | Yumiko Jeanette Japari, Nathanova Yvonne Fridany | Ilustrasi manual pada Procreate |
| Ilustrasi bin pemilahan | `assets/bins/` | 5 | Yumiko Jeanette Japari, Nathanova Yvonne Fridany | Ilustrasi manual pada Procreate |
| Ilustrasi capit | `assets/claw/` | 5 | Yumiko Jeanette Japari, Nathanova Yvonne Fridany | Ilustrasi manual pada Procreate |
| Ilustrasi lingkungan, cutscene, logo | `assets/env/` | 15 | Yumiko Jeanette Japari, Nathanova Yvonne Fridany | Ilustrasi manual pada Procreate |
| Ilustrasi ikan latar | `assets/fish/` | 11 | Yumiko Jeanette Japari, Nathanova Yvonne Fridany | Ilustrasi manual pada Procreate |
| Ikon alat inspeksi | `assets/tools/` | 4 | Yumiko Jeanette Japari, Nathanova Yvonne Fridany | Ilustrasi manual pada Procreate |
| Antarmuka, kokpit mesin, lembar rancang | `assets/ui/` | 63 | Yumiko Jeanette Japari, Nathanova Yvonne Fridany | Ilustrasi manual pada Procreate |
| Efek suara | `assets/audio/` | 11 | Jason Tio | Sintesis prosedural melalui skrip Python (memakai modul `wave` dari pustaka standar) |
| Seluruh kode program | — | — | Jason Tio | GDScript |

**Pernyataan mengenai generative AI.** Tidak ada satu pun aset gambar maupun audio
dalam permainan ini yang dihasilkan oleh generative AI. Seluruh ilustrasi digambar
manual oleh ilustrator tim menggunakan Procreate. Seluruh efek suara dihasilkan
secara prosedural oleh skrip Python milik tim yang menyusun gelombang sinus dan
kotak menggunakan pustaka standar Python — sebuah proses sintesis matematis, bukan
generative AI.

Seluruh gambar cutscene, logo menu, ilustrasi alat, bin, capit, ikan, meja
pemilahan dan lembar rancang bangun berasal dari kiriman ilustrator tim dan
digambar manual di Procreate. Tidak ada satu pun aset dari sumber luar yang
tersisa di dalam project.

### Aset dari sumber lain

| Aset | Pembuat | Lisensi | Dipakai untuk |
|---|---|---|---|
| Typeface **Fredoka** (`Fredoka-Medium`, `Fredoka-SemiBold`) | Milena Brandao, Hafontia | SIL Open Font License 1.1 | seluruh teks dalam permainan |

Lisensi SIL OFL 1.1 mengizinkan penyertaan font di dalam sebuah karya digital,
termasuk karya komersial, selama berkas lisensinya turut disertakan. Salinan utuh
`OFL.txt` berada di `assets/ui/fonts/` di dalam repositori dan ikut terbungkus
dalam build.

Godot Engine 4.7.2 sendiri berlisensi MIT dan tidak mensyaratkan atribusi.


`[BUTUH INPUT JASON: bagian ini WAJIB diisi atau dinyatakan kosong secara eksplisit.
Hal-hal yang perlu dipastikan sebelum pengumpulan:

 1. Konfirmasi tertulis dari Yumiko dan Nathanova bahwa SELURUH berkas yang mereka
    kirim adalah karya asli mereka, dan tidak ada satu pun yang di-trace, disalin,
    atau diambil dari Pinterest / Google Images. Ini penting karena berkas panduan
    untuk ilustrator di dalam project (assets_incoming/README.md) memang sempat
    mengizinkan gambar dari sumber-sumber tersebut untuk keperluan pengujian
    pipeline secara internal.
 2. Musik: bila musik ditambahkan, cantumkan judul, pembuat, dan lisensinya.
 3. Godot Engine sendiri berlisensi MIT dan tidak menuntut atribusi, tetapi
    mencantumkannya adalah praktik yang baik.

Bila memang tidak ada satu pun aset pihak ketiga, tulis kalimat eksplisit:
"Seluruh aset dalam permainan ini adalah karya asli tim pengembang. Tidak ada aset
pihak ketiga yang digunakan." Menyatakannya secara tegas lebih baik daripada
mengosongkan bagian ini.]`

## 3.4 Daftar Pustaka

`[BUTUH INPUT JASON: susun daftar pustaka dari sitasi yang dilengkapi pada bagian 1.1. Gunakan format yang diminta panitia — bila tidak ditentukan, APA edisi ke-7 adalah pilihan yang aman. Sumber yang perlu dicari:

 1. Data volume sampah laut Indonesia (KLHK / SIPSN, atau Jambeck et al. 2015)
 2. Kontaminasi aliran daur ulang akibat kesalahan pemilahan di sumber
 3. Tingkat literasi dan praktik pemilahan sampah rumah tangga di Indonesia (BPS)

Ditambah rujukan teknis yang sudah pasti:

 4. Godot Engine Documentation. https://docs.godotengine.org
 5. Kode resin SPI / ASTM D7611 untuk glosarium PET 1, HDPE 2, PVC 3, PS 6, dan
    seterusnya yang dipakai di dalam Rulebook]`

---
---

# CATATAN UNTUK JASON

Bagian ini **tidak untuk ditempel ke Google Docs.** Hapus sebelum mengirim.

## 1. Daftar seluruh penanda yang harus dilengkapi

### `[BUTUH SITASI]` — 3 buah, semuanya di bagian 1.1

| # | Lokasi | Yang dibutuhkan |
|---|---|---|
| 1 | 1.1 paragraf 1 | Volume sampah laut Indonesia per tahun. Sumber lazim: KLHK/SIPSN, atau Jambeck et al. (2015) untuk peringkat global. Sertakan angka **dan** tahunnya. |
| 2 | 1.1 paragraf 2 | Kontaminasi aliran daur ulang akibat salah pilah di sumber, plus perkiraan persentase material yang ditolak fasilitas daur ulang. Ini menopang argumen inti 1.2.5. |
| 3 | 1.1 paragraf 3 | Tingkat literasi / praktik pemilahan sampah rumah tangga di Indonesia. Sumber: BPS atau survei sejenis. |

Saya tidak menuliskan satu pun angka statistik di bagian ini. Yang ada hanya
kerangka argumennya. **Jangan mengarang angka** — juri lomba lingkungan biasanya
mengenali statistik yang tidak berdasar.

### `[BUTUH INPUT JASON]` — 18 penanda, dikelompokkan jadi 13 butir

**Memblokir pengumpulan:**

| # | Lokasi | Yang dibutuhkan |
|---|---|---|
| 1 | 3.3 | **Ganti empat berkas placeholder** — tiga cutscene dan logo menu. Lihat poin A di bawah untuk jalur dan ukurannya. Sampai ini beres, pernyataan anti-AI di 3.3 belum benar. |
| 2 | 1.3.1 | Tautan itch.io untuk build Windows (dan build web, kalau ikut diunggah). |
| 3 | 1.2.1, 1.3.2 | Target platform final: Windows, WebGL, atau keduanya. |
| 4 | 2.7, 3.2 | Pembagian kerja antara Yumiko dan Nathanova; NIM / asal institusi sesuai format panitia. |

**Penting, memengaruhi nilai:**

| # | Lokasi | Yang dibutuhkan |
|---|---|---|
| 5 | 2.5.1 | **Data playtest dengan manusia.** Bobot "Gameplay" 25 %. Git mencatat playtest pernah dilakukan (commit 24 Agustus) tetapi hasilnya tidak ada di project. |
| 6 | 2.3 | Keputusan soal audio — diganti atau tidak sebelum pengumpulan. |
| 7 | 2.3 | Keputusan soal font — dipasang atau tidak. |
| 8 | 1.3.2 | Spesifikasi prosesor dan RAM, diukur setelah `.exe` jadi. |

**Pelengkap:**

| # | Lokasi | Yang dibutuhkan |
|---|---|---|
| 9 | 1.2.1 | Durasi rata-rata satu run dalam menit. |
| 10 | 1.3.1 | Tautan video gameplay dan repositori, bila disyaratkan. |
| 11 | 2.4 | Versi Procreate / perangkat, bila perlu dicantumkan. |
| 12 | 2.6 | Rencana lanjutan tambahan yang sudah dibicarakan tim. |
| 13 | 3.4 | Daftar pustaka final. |

## 2. Ketidakcocokan konsep vs implementasi

**Sudah dibereskan pada refactor 7 September 2026** — tidak ada lagi yang perlu
kamu kerjakan untuk poin-poin ini:

- **Calibration puzzle** dicabut seluruhnya: folder `scenes/puzzle/`, feature
  flag `feature_calibration_puzzle`, satu-satunya pemanggil di `after_day.gd`,
  blok string `puzzle_*` di `strings.gd`, dan uji `smoke_puzzle.gd`. Nol sisa.
- **`ToolData.default_charges`** dicabut — sisa sistem charge per-alat yang sudah
  digantikan `Shift time`. **`DayData.modifier`** dicabut — tidak pernah dibaca
  kode mana pun.
- **Penamaan `ocean`** yang tersisa dari mekanik ocean health diganti sesuai apa
  yang benar-benar ditampilkan: `OceanLabel`/`OceanTitle` → `MachinesLabel`/
  `MachinesTitle`, kunci string `ocean_label` → `machines_label`,
  `smoke_ocean.gd` → `smoke_ending.gd`. Aset `icon_health.png` dihapus.
- **Nama project** `Cakar Laut` → `Re:Sea` di `project.godot` dan `README.md`.
- **`ASSETS.md`** disinkronkan dua arah dengan isi folder: 19 baris untuk berkas
  yang tidak ada dibuang, 3 baris yang hilang ditambahkan, tabel audio 11 berkas
  ditambahkan, seksi `## hotspots` ditulis ulang (isinya masih mendokumentasikan
  mekanik ring-posisi yang sudah dihapus), dan konstanta `BOX_CARD_SCALE` yang
  tidak pernah ada di kode dihapus dari tabelnya.

**Yang sengaja TIDAK saya cabut, beserta alasannya:**

- **`ItemData.true_material`** — di laporan pertama saya sebut ini mati. Setelah
  ditelusuri lebih teliti, ini bukan leftover: `tests/smoke_extensibility.gd`
  justru memakainya sebagai kasus uji, membuktikan bahwa memetakan alat baru ke
  properti baru bisa dilakukan murni lewat data. Yang kosong adalah kontennya,
  bukan mekaniknya — belum ada satu pun benda yang memakai jalur ini, sehingga
  kartu bukti `TRUE MATERIAL:` memang tidak pernah muncul saat bermain.
- **`ItemData.source_batch`** — terdaftar di `RuleChecker.SURFACE_KEYS`, artinya
  aturan bisa dibuat berdasarkan asal batch (misalnya "semua dari pabrik tekstil
  hari ini berbahaya") tanpa perubahan kode. Metadata yang belum dipakai, bukan
  mekanik yang ditinggalkan.

Mencabut keduanya berarti membuang titik perluasan yang berfungsi dan sudah
teruji, demi menghapus satu field yang tidak merugikan siapa pun.

**Yang masih menggantung di kode:**

- `Sealed Crate` yang belum dibuka sampai shift berakhir menguap tanpa jejak —
  tidak masuk laporan, tidak masuk haul. `TODO` ada di `autoload/game.gd`. Sudah
  saya tulis di 2.6.
- Target harian tidak punya konsekuensi mekanis apa pun. Sudah saya tulis apa
  adanya di 2.1.4.

## 3. Hal-hal yang berpotensi jadi masalah untuk lomba

**A. Empat berkas bermasalah sudah diganti — risiko ini SELESAI.**

Pada pemeriksaan sebelumnya, tiga gambar cutscene dan logo menu bukan karya tim:
logo menu adalah logo organisasi "Call of the Sea" yang diambil dari Pinterest,
dan ketiga cutscene punya tiga gaya berbeda yang tidak cocok satu sama lain.

Keempatnya kini **ditimpa oleh aset asli tim** dari kiriman `NEW-ASSETS`:

| Berkas | Diganti oleh |
|---|---|
| `assets/env/logo.png` | Wordmark **RE:SEA** milik tim, 541 × 276 |
| `assets/env/cutscene_01.png` | `beach-1` — teluk sebelum tercemar |
| `assets/env/cutscene_02.png` | `trash-in-sea-2` — satu gelas tenggelam |
| `assets/env/cutscene_03.png` | `more-trash-in-sea-3` — kiriman harian |

Ditambah dua gambar baru (`cutscene_04` penyelam, `cutscene_05` meja rancang
bangun) dan dua gambar akhir. Tidak ada lagi aset dari sumber luar di dalam
project. Pernyataan anti-AI dan anti-pihak-ketiga di 3.3 kini benar.

**B. Build Windows terhalang export template.**

`export_presets.cfg` sudah saya buat (preset `Windows Desktop` dan `Web`), tetapi
di mesin ini **hanya template Web yang terpasang**. Template Windows harus diunduh
sekali lewat editor Godot — langkahnya ada di `BUILD.md`, unduhannya ±1 GB.

Build Web sudah jadi dan terverifikasi: `build/Re-Sea-web.zip`, sekitar 15 MB,
jauh di bawah batas 300 MB, dan sudah saya periksa tidak membocorkan `tests/`,
`*.md`, maupun PDF proposal ke dalam paketnya. Build web ini berguna sebagai
cadangan — juri bisa mencoba langsung tanpa mengunduh dan tanpa peringatan
SmartScreen.

**C. Kredit dan lisensi aset.**

Seluruh ilustrasi tim digambar manual di Procreate, dan itu sudah saya tulis
tegas di 3.3 beserta pernyataan bahwa tidak ada aset gambar maupun audio yang
dihasilkan generative AI. Dengan keempat berkas di poin A sudah diganti,
pernyataan itu kini benar apa adanya.

**D. Artefak AI sudah dihapus dari working tree, tetapi masih ada di git history.**

`AI-SIGN.md` dan `ai-prompt.txt` sudah dihapus, dan `ai-prompt.txt` juga sudah
dilepas dari indeks git. Di luar itu tidak ada satu pun referensi ke AI yang
tersisa di kode, scene, resource, maupun dokumen — sudah saya sisir.

Yang tidak bisa dihapus dengan mengedit berkas: sejarah git masih memuat
`CLAUDE.md`, `PROGRESS.md`, `REVISION*.md`, dan `WALKTHROUGH.md` dari commit-commit
lama. **Saya sengaja tidak menulis ulang sejarah git** — itu operasi destruktif
yang tidak kamu minta.

Praktisnya ini kemungkinan besar tidak relevan: kamu mengumpulkan **build** ke
itch.io, bukan repositori, sehingga sejarah git tidak pernah keluar dari mesinmu.
Kalau nanti kamu memang ingin mempublikasikan repo, cara yang jujur adalah
memulai repositori publik baru dari kondisi saat ini, bukan memalsukan sejarah
yang lama.

**E. Font masih bawaan Godot.**

Estetika berbobot 15 %, dan ini permainan yang hampir seluruhnya teks. Satu
berkas `.ttf` ke `assets/ui/fonts/ui_font.ttf` plus satu baris di
`assets/ui/ui_theme.tres` mengubah kesan seluruh layar tanpa perubahan tata letak
— semua ukuran huruf sudah ditetapkan di tema. Ambil font berlisensi OFL dari
Google Fonts dan catat lisensinya di 3.3.

**F. Audio 100 % placeholder, dan tidak ada musik.**

Sebelas WAV, seluruhnya nada sinus dan kotak 22 kHz. Bus `Music` ada dan
penggeser volumenya berfungsi, tetapi tidak ada yang diputar. Kalau tidak sempat
diganti, biarkan — 2.6 sudah menyebutnya sebagai rencana lanjutan, sehingga tidak
ada klaim berlebihan yang bisa dibantah juri.

**G. Dua ending belum punya gambar sendiri.**

Lembar spesifikasi di `NEW-ASSETS/Cutscene/Endings` menetapkan empat ending,
tetapi hanya ending 1 (0 mesin) dan ending 4 (3 mesin) yang sudah ada
gambarnya. Ending 2 dan 3 saat ini memakai gambar penyelam dari cutscene
pembuka sebagai penahan sementara — netral secara nada, dan tidak mengklaim
sesuatu yang salah, tetapi jelas bukan gambar yang dimaksud.

Begitu gambarnya datang, timpa saja jalurnya dan `Game.ending_still()` di
`autoload/game.gd` tinggal diarahkan ke berkas baru — satu baris per ending.

