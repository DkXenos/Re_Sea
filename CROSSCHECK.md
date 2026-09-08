# CROSSCHECK.md — verifikasi proposal terhadap build

Konteks untuk Claude Code: berkas ini memuat **setiap klaim faktual** yang tertulis
di proposal lomba Re:Sea. Proposal itu akan dibaca juri sambil memainkan build,
jadi satu klaim yang meleset akan terlihat.

## Aturan pengerjaan

1. **READ-ONLY.** Jangan mengubah, menghapus, atau merefactor apa pun. Kalau kamu
   menemukan bug, laporkan — jangan perbaiki.
2. Untuk setiap klaim, telusuri ke kode/data/scene, lalu beri vonis:
   - **OK** — cocok dengan build sekarang
   - **BEDA** — tidak cocok; tulis versi yang benar dalam satu kalimat
   - **HILANG** — mekanik/aset yang diklaim tidak ada lagi di build
3. Jangan menyimpulkan dari nama fungsi, nama berkas, atau komentar. Telusuri
   sampai titik di mana pemain benar-benar melihat atau merasakannya. Klaim yang
   berbunyi "tampil di layar" hanya OK kalau ada node yang benar-benar
   merendernya di jalur permainan normal.
4. Untuk angka, tulis angka yang sebenarnya, bukan "kurang lebih".
5. Jangan menulis saran perbaikan. Hanya fakta.

## Keluaran

Tulis `CROSSCHECK_HASIL.md` dengan tiga bagian:

- **A. YANG BEDA ATAU HILANG** — hanya klaim yang vonisnya bukan OK, dengan versi
  yang benar. Taruh paling atas; ini satu-satunya bagian yang benar-benar aku
  butuhkan cepat.
- **B. VONIS LENGKAP** — satu baris per nomor klaim.
- **C. YANG BERUBAH SEJAK AUDIT TERAKHIR** — kalau kamu melihat perubahan pada
  mekanik, aturan, benda, aset, atau teks layar yang tidak tercakup daftar di
  bawah, sebutkan di sini. Ini penting karena proposal mungkin belum menyebutkan
  fitur baru sama sekali.

Terakhir, jalankan seluruh uji otomatis dan laporkan hasilnya tanpa memperbaiki
yang gagal.

---

# DAFTAR KLAIM

## Identitas dan platform

| # | Klaim di proposal |
|---|---|
| 1 | Engine: Godot Engine 4.7.2 stable, renderer GL Compatibility |
| 2 | Bahasa seluruh teks dalam permainan: Inggris |
| 3 | Platform: Web (WebGL), dimainkan langsung di peramban. Tidak ada build Windows yang disertakan |
| 4 | Mode pemain tunggal |
| 5 | Satu run terdiri atas lima hari |
| 6 | Judul yang tampil di jendela/aplikasi: "Re:Sea" |

## Alur dan struktur

| # | Klaim di proposal |
|---|---|
| 7 | Alur layar: menu utama → cutscene pembuka → pembukaan hari → shift → layar akhir hari → hari berikutnya, atau layar ending setelah hari kelima |
| 8 | Layar akhir hari adalah SATU layar dengan tiga tab: The Day, Technology, Gear |
| 9 | Mesin capit dan Sorting Desk adalah dua tampilan dari satu shift yang sama; berpindah di antaranya gratis |
| 10 | Benda baru tetap berdatangan ke dasar laut saat pemain berada di Sorting Desk |
| 11 | Sisa Shift time tidak dibawa ke hari berikutnya |
| 12 | Benda yang belum dipilah tidak dibawa ke hari berikutnya |
| 13 | Yang berjalan lintas hari hanya empat hal: material di gudang, komponen yang dirakit, mesin yang dibangun, perlengkapan yang terpasang |
| 14 | Shift berakhir dalam TIGA keadaan: pemain menekan End Shift; anggaran tidak cukup untuk tindakan bermakna; atau seluruh benda di laut dan di meja habis terpilah |
| 15 | Kalimat penutup saat semua habis terpilah: "Every last piece out of the water and into a bin." |

## Progresi per hari

| # | Klaim di proposal |
|---|---|
| 16 | Hari 1: target 5, Shift time 90, aturan dasar, tanpa alat, 8 benda, 0 peti |
| 17 | Hari 2: target 6, Shift time 110, aturan noda mulai berlaku, alat Rinse + Magnifier + Cutter, 14 benda, 1 peti |
| 18 | Hari 3: target 8, Shift time 130, aturan cemaran kimia mulai berlaku, + Chem Swab, 19 benda, 1 peti |
| 19 | Hari 4: target 10, Shift time 150, aturan kemasan berlapis mulai berlaku, keempat alat, 20 benda, 2 peti |
| 20 | Hari 5: target 12, Shift time 160, TIDAK ada aturan baru, keempat alat, 23 benda, 2 peti |
| 21 | Target naik 140 % dan Shift time naik 78 % dari hari 1 ke hari 5 |
| 22 | Memenuhi target menghabiskan 35 dari 90 satuan di hari 1, dan 84 dari 160 di hari 5 |
| 23 | Hari 1 tidak menyediakan alat, dan kedelapan bendanya tidak ada yang bernoda, berlapis, atau tercemar kimia — semuanya bisa dipilah dari informasi gratis |
| 24 | Toothbrush termasuk RECYCLABLE di hari 3 dan berpindah ke RESIDUE di hari 4 karena aturan kemasan berlapis |
| 25 | Satu peti berisi 2–3 benda tambahan |

## Ending

| # | Klaim di proposal |
|---|---|
| 26 | Ada empat ending, ditentukan hanya oleh jumlah mesin yang dibangun |
| 27 | 0 mesin → "THE BAY WAS LEFT AS IT WAS" |
| 28 | 1 mesin → "A FIRST MACHINE" |
| 29 | 2 mesin → "THE WATER IS TURNING" |
| 30 | 3 mesin → "THE BAY CAME BACK" |
| 31 | Tidak ada kondisi kalah yang menghentikan permainan di tengah jalan |

## Mesin capit

| # | Klaim di proposal |
|---|---|
| 32 | Capit turun lurus, berhenti pada sentuhan pertama, menutup, lalu naik |
| 33 | Peluang cengkeram bergantung pada berat benda |
| 34 | Rentang peluang: sekitar 70 % untuk botol kaca 2 kg, 95 % untuk daun kering 0,1 kg |
| 35 | Peluang cengkeram tidak pernah mencapai 100 % |
| 36 | Bila gagal, benda terlepas di ketinggian acak saat naik dan jatuh kembali ke dasar |
| 37 | Biaya penjatuhan terpotong saat capit mulai turun, sebelum hasil diketahui, dan tidak dikembalikan |
| 38 | Capit tidak menggunakan mesin fisika — interpolasi posisi + satu lemparan dadu |
| 39 | Proposal TIDAK mengklaim adanya pratinjau peluang cengkeram di layar. **Cek sebaliknya: apakah sekarang pratinjau itu SUDAH ditampilkan?** Kalau ya, katakan — aku akan menambahkannya ke proposal |

## Sealed Crate

| # | Klaim di proposal |
|---|---|
| 40 | Peti muncul mulai hari kedua |
| 41 | Peti tidak dapat dimasukkan ke bin mana pun sampai dibuka dengan Cutter |
| 42 | Membuka peti tidak memakan biaya sama sekali |
| 43 | Peti kosong tetap tinggal di daftar dan harus dipilah sebagai sampah biasa |

## Shift time

| # | Klaim di proposal |
|---|---|
| 44 | Shift time berkurang hanya karena tindakan; tidak ada penghitung waktu nyata di mana pun |
| 45 | Menjatuhkan capit: 6 |
| 46 | Menggunakan alat: 4 |
| 47 | Memilah satu benda: 1 |
| 48 | Membuka peti dengan Cutter: 0 |
| 49 | Gratis: berpikir, membaca Rulebook, memperbesar/menggeser gambar, berpindah tampilan, merakit komponen, memasang perlengkapan |

## Inspeksi dan alat

| # | Klaim di proposal |
|---|---|
| 50 | Informasi gratis untuk setiap benda tepat empat hal: gambar yang bisa diperbesar/digeser, nama benda, "LOOKS LIKE:", "MARKING:", dan berat |
| 51 | Rinse membersihkan noda sehingga benda dapat dipulihkan ke kategori bahan aslinya |
| 52 | Magnifier membaca material yang sebenarnya |
| 53 | Chem Swab menamai jenis noda — kotoran biasa atau cemaran kimia |
| 54 | Cutter membuka peti tersegel |
| 55 | Tidak ada titik yang harus dibidik; seluruh benda adalah sasaran alat |
| 56 | Kantong plastik dan toples saus dapat dirinse menjadi RECYCLABLE |
| 57 | Kemeja berlumpur dapat dirinse menjadi ORGANIC (bukan RECYCLABLE) |
| 58 | Gelas kertas dapat dirinse menjadi berguna di hari 2–3, tetapi TIDAK di hari 4–5 karena aturan kemasan berlapis berprioritas lebih tinggi |
| 59 | Kemeja berpestisida dan tisu bercat pelarut menolak dirinse |
| 60 | Alat yang tidak menemukan apa pun tetap memotong anggaran |
| 61 | Teks persis di layar: "Nothing on this one for that tool. The shift time is spent anyway -4." |
| 62 | Alat yang salah sasaran (Cutter ke benda biasa) tidak memotong apa pun |
| 63 | Setiap temuan menjadi kartu di EVIDENCE LOG |
| 64 | Kartu yang memenuhi aturan berubah tampilannya, dan bin bersangkutan menyala pada saat yang sama |

## Bin dan pemilahan

| # | Klaim di proposal |
|---|---|
| 65 | Ada EMPAT bin: ORGANIC, RECYCLABLE, HAZARDOUS, RESIDUE |
| 66 | Keempat bin selalu dapat diklik, termasuk untuk benda yang belum diperiksa |
| 67 | Bin menerima benda tanpa memberi isyarat benar atau salah |
| 68 | Penolakan hanya untuk tiga hal: tidak ada benda terpilih, benda masih peti tersegel, anggaran tidak cukup |
| 69 | Benda yang masuk bin salah menghasilkan NOL material, bukan sebagian; tidak ada jalur lain yang menambah gudang |
| 70 | Tidak ada nyawa, denda, atau game over akibat salah pilah |
| 71 | Target dihitung dari jumlah benda yang dipilah, benar maupun salah, dan tidak punya konsekuensi mekanis |
| 72 | Definisi ORGANIC di proposal: apa pun yang membusuk — sisa makanan, sampah kebun, serat alam seperti katun |
| 73 | Definisi RECYCLABLE: kertas, kaca, logam, plastik bersih, termasuk poliester |
| 74 | Definisi HAZARDOUS: apa pun yang terkena bahan kimia yang tidak bisa dicuci; menang atas bahan penyusunnya |
| 75 | Definisi RESIDUE: benda bernoda yang belum dibersihkan, kemasan berlapis, tisu bekas |

## Aturan

| # | Klaim di proposal |
|---|---|
| 76 | Kategori dihitung ulang setiap kali dari benda terhadap aturan hari itu, prioritas tertinggi menang |
| 77 | Bila tidak ada aturan yang cocok, bahan penyusun benda yang menentukan |
| 78 | Aturan bahan dasar, prioritas 0, teks checklist "What it is made of decides where it goes" |
| 79 | Aturan noda, prioritas 10, memaksa ke RESIDUE, teks checklist "Still stained → RESIDUE" |
| 80 | Aturan kemasan berlapis, prioritas 30, memaksa ke RESIDUE, teks checklist "Laminated packaging → RESIDUE" |
| 81 | Aturan cemaran kimia, prioritas 40, memaksa ke HAZARDOUS, teks checklist "Chemical stain, will not rinse → HAZARDOUS" |
| 82 | Rulebook memuat kalimat "This rule beats the stain rule." |
| 83 | Rulebook dibuka dengan R, hanya di Sorting Desk, tidak menjeda, dan gratis |
| 84 | Rulebook punya tiga bagian: aturan hari itu dikelompokkan per bin; "WHERE THINGS GO" berisi 14 baris; glosarium "WHAT THE RECYCLING CODES MEAN" berisi 11 kode |
| 85 | Tiga kode glosarium benar-benar tercetak sebagai MARKING pada benda: HDPE 2 pada kantong plastik, PP 5 pada sikat gigi, GL pada botol kaca |
| 86 | Daftar aturan yang berlaku selalu terpampang di sebelah benda yang diperiksa |
| 87 | Penandanya tanda tambah hijau untuk aturan yang buktinya terkumpul, tanda kurang abu-abu untuk yang belum |
| 88 | Aturan hanya dinyatakan terbukti bila pemain sudah membuka properti kuncinya |

## Pasangan jebakan

| # | Klaim di proposal |
|---|---|
| 89 | Frayed Shirt dan Faded Shirt sama-sama tampil "woven fabric", sama-sama 0,6 kg, sama-sama tanpa penanda |
| 90 | Hanya Magnifier yang membedakan keduanya |
| 91 | Frayed Shirt katun → ORGANIC; Faded Shirt poliester → RECYCLABLE |
| 92 | Keduanya hadir bersama sejak hari kedua sampai hari kelima |
| 93 | Muddy Shirt dan Stained Shirt sama-sama kemeja katun bernoda tanpa penanda |
| 94 | Chem Swab menamai lumpur sungai vs konsentrat pestisida |
| 95 | Muddy Shirt bisa dirinse menjadi ORGANIC; Stained Shirt tidak bisa diselamatkan dan masuk HAZARDOUS |

## Technology dan Gear

| # | Klaim di proposal |
|---|---|
| 96 | Tiga mesin bernama: Ocean Cleaning Drone, Recycling Station, Reef Restoration Pod |
| 97 | Tujuh komponen menyusun ketiga mesin |
| 98 | Ocean Cleaning Drone butuh 3 ORGANIC, 2 RECYCLABLE, 1 RESIDUE |
| 99 | Recycling Station butuh 2 ORGANIC, 4 RECYCLABLE, 3 RESIDUE |
| 100 | Reef Restoration Pod butuh 2 ORGANIC, 5 HAZARDOUS, 3 RESIDUE |
| 101 | Total ketiganya: 7 ORGANIC, 6 RECYCLABLE, 5 HAZARDOUS, 7 RESIDUE = 25 |
| 102 | Akumulasi target lima hari = 41, sehingga 61 % keputusan harus tepat |
| 103 | Material HAZARDOUS hanya muncul mulai hari ketiga dan paling terbatas jumlahnya |
| 104 | Tidak ada mata uang dalam permainan |
| 105 | Memasang perlengkapan gratis dan dapat dibatalkan; hanya satu terpasang pada satu waktu |
| 106 | Setiap perlengkapan adalah pertukaran; tidak ada peningkatan murni |
| 107 | Light Claw: drop 4 bukan 6; peluang cengkeram turun 15 poin |
| 108 | Coarse Scanner: alat 2 bukan 4; bacaan kasar, membaca benar butuh satu pemakaian lagi pada harga normal |
| 109 | Fast Rail: capit 60 % lebih cepat; rel butuh 2 detik pulih setiap selesai menjatuhkan |
| 110 | Strong Grip: peluang cengkeram naik 15 poin; drop 8 bukan 6 |
| 111 | Twin Arms: alat 3 bukan 4; capit 25 % lebih lambat |
| 112 | Setiap mesin yang dibangun membuka satu perlengkapan |

## Laporan akhir hari

| # | Klaim di proposal |
|---|---|
| 113 | Kartu kesalahan memuat gambar benda, "You put it in:", "Should have been:", "Never checked:", dan "Broke:" |
| 114 | Ada satu baris "Never checked:" untuk SETIAP properti penentu yang tidak pernah dibuka pemain |
| 115 | "Never checked:" hanya menampilkan properti yang belum dibuka, bukan seluruh properti tersembunyi |
| 116 | "Broke:" berisi teks lengkap aturan yang dilanggar |
| 117 | Tidak ada skor berupa angka di mana pun dalam permainan |
| 118 | Yang ditampilkan hanya cacah: benar, salah, belum dipilah, dan material yang masuk gudang |
| 119 | Teks di layar: "Only what goes in the right bin becomes blueprint material." |

## Cutscene dan naskah

| # | Klaim di proposal |
|---|---|
| 120 | Naskah pembuka memuat baris: "You run the claw. Lift it, inspect it, sort it. The sea counts every decision you make." |

## Kontrol

| # | Klaim di proposal |
|---|---|
| 121 | Menggerakkan capit: A / D atau ← / → |
| 122 | Menjatuhkan capit: Spasi, S, atau ↓ |
| 123 | Berpindah tampilan: Tab |
| 124 | Alat, bin, tombol: klik kiri |
| 125 | Memperbesar dan menggeser gambar benda: gulir dan seret |
| 126 | Rulebook: R (hanya di Sorting Desk) |
| 127 | Memilih benda PERTAMA yang belum dipilah: I |
| 128 | Menjeda: Esc |
| 129 | Konsol mesin punya tombol klik untuk menggeser capit, menjatuhkan, berpindah tampilan, dan membuka pengaturan |

## Aset dan teknis

| # | Klaim di proposal |
|---|---|
| 130 | 128 PNG dipakai permainan |
| 131 | 11 efek suara WAV |
| 132 | 2 berkas musik/ambience |
| 133 | Font Fredoka (Medium dan SemiBold), lisensi SIL Open Font License |
| 134 | Tidak ada bentuk yang digambar oleh kode |
| 135 | Setiap keadaan antarmuka adalah gambar tersendiri, bukan pewarnaan ulang |
| 136 | Tidak ada add-on pihak ketiga |
| 137 | Konten permainan: 20 benda, 4 aturan, 4 alat, 5 perlengkapan, 7 komponen, 3 mesin, 5 hari |
| 138 | Seluruh konten tersimpan sebagai berkas data terpisah dari kode |
| 139 | Tidak ada percabangan khusus per benda di dalam kode |
| 140 | GDScript seluruhnya bertipe statis |

## Pertanyaan terbuka

| # | Yang aku butuhkan |
|---|---|
| 141 | Apakah ada MEKANIK BARU, benda baru, aturan baru, alat baru, atau layar baru yang belum disebut di daftar 1–140? Sebutkan satu per satu. |
| 142 | Apakah masih ada teks di layar yang menyebut sesuatu yang tidak berlaku — aturan yang tidak ada, kode kemasan yang tidak dipakai benda mana pun, atau nama sistem lama? |
| 143 | Apakah dua tempat menampilkan angka berbeda untuk hal yang sama (misalnya biaya alat di rak versus yang benar-benar dipotong)? |
| 144 | Berapa margin pasokan material per kategori sekarang (bisa ditemukan dikurangi yang dibutuhkan)? Apakah uji penyeimbangan masih gagal? |
| 145 | Apakah musik dan ambience punya berkas kredit/lisensi di dalam repo? Kalau ada, sebutkan nama pembuat dan lisensinya persis. |
| 146 | Apakah ada aset di dalam build yang tidak dirujuk kode/scene mana pun tetapi tetap ikut terpaket? |
