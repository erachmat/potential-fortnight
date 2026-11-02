# PLAN — Prototype "Nitip" (Flutter)

Dokumen ini adalah instruksi eksekusi. Pelaksana (agent atau developer) mengikuti fase di §9 secara berurutan,
memenuhi kriteria selesai tiap fase, lalu mencatatnya di `docs/PROGRESS.md`.

---

## 0. Tujuan & definisi sukses

**Tujuan:** prototype yang bisa di-install (APK) dan dipresentasikan (Web) untuk meyakinkan klien sebelum deal.
Bukan aplikasi produksi. Kode UI dan model harus cukup rapi supaya bisa dipakai lagi setelah deal
(tinggal ganti repository fake dengan API sungguhan).

**Sukses berarti:**

1. Seluruh naskah `docs/DEMO_SCRIPT.md` bisa dijalankan tanpa error, baik di APK (1 HP) maupun di Web (Mode Panggung).
2. Semua aturan bisnis dari brief terlihat bekerja: tier ongkir, fee 2%, maks 20 item, pesanan multi-kantin,
   dispatch kurir dengan timeout lalu pindah kurir, saldo kurir, format rekap kurir, unduh laporan.
3. Tiap momen "signature" di `docs/MOTION.md` (prioritas P1) terimplementasi dan mulus.
4. `flutter analyze` bersih, `flutter test` hijau, APK release ter-build, web ter-deploy.

---

## 1. Keputusan yang sudah diambil

| Topik | Keputusan | Alasan |
|---|---|---|
| Framework | Flutter (stable terbaru saat mulai), Dart 3 | Ekspektasi klien |
| Bentuk deliverable | **1 APK** berisi 3 peran (pilih peran di awal) + **Flutter Web** dari codebase yang sama | Mudah di-install klien; state dibagi antar peran → aksi kurir langsung terlihat di sisi customer/admin |
| Admin | Layout responsif; target utama Web (laptop). Tetap bisa dibuka dari APK (layout tablet/HP) | Dashboard lebih meyakinkan di layar lebar |
| **Mode Panggung** (Web) | Satu layar laptop: HP Customer + HP Kurir + Dashboard Admin berdampingan, state dibagi live | Momen WOW terbesar saat presentasi |
| Backend | **Tidak ada.** Repository interface + implementasi fake in-memory dengan latensi simulasi | Belum deal; backend menyusul |
| State management | `flutter_riverpod` | Satu ProviderContainer dibagi ke semua panel |
| Routing | `go_router` | Deep link `/admin`, `/stage` di web |
| Brand | **"Nitip"** (lihat `docs/DESIGN.md`). Nama disimpan di satu file konfigurasi brand supaya mudah diganti | Klien belum punya brand |
| Tema | Light mode saja. Aplikasi kurir memakai header/aksen gelap | Fokus; dark mode di luar scope |
| Font | Plus Jakarta Sans, **dibundel** sebagai asset (bukan diunduh runtime) | Demo bisa offline |
| Peta | **Tanpa GPS/peta sungguhan.** Peta kampus ilustrasi (CustomPainter) | Antar di dalam kampus cukup gedung + ruang; lebih WOW dan tidak butuh API key |
| Timer tawaran kurir | Default demo **15 detik**, bisa diubah ke 60 detik (nilai produksi) di Panel Demo | Demo tidak membosankan |
| Notifikasi | Android: notifikasi sistem lokal sungguhan (`flutter_local_notifications`). Web: banner in-app | Terasa nyata tanpa server |
| SFX | Dibuat sendiri (sintesis nada lewat script) → bebas lisensi | Hindari masalah lisensi |

---

## 2. Asumsi bisnis (ditandai di UI demo, dikonfirmasi ke klien saat pitching)

| # | Asumsi | Default di prototype | Dibuat bisa diubah? |
|---|---|---|---|
| A1 | Fee 2% dihitung dari **subtotal** (tanpa ongkir) | subtotal | Ya, flag `feeBase` di konfigurasi bisnis |
| A2 | Pembulatan fee | ke rupiah terdekat, setengah ke atas | Tidak perlu |
| A3 | Maks 20 = total qty **seluruh** item (lintas kantin) | total | Tidak |
| A4 | Ongkir tetap per transaksi walau multi-kantin | ya | Tidak |
| A5 | Kurir menalangi belanja di kantin, lalu menerima subtotal + ongkir ke saldo | ya | Tidak |
| A6 | Fee 2% = pendapatan platform/owner | ya | Tidak |
| A7 | Tukar saldo diproses manual oleh admin (approve → tandai dibayar) | manual | Tidak |
| A8 | Jika tidak ada kurir tersedia: status "Belum ada kurir", tombol "Coba lagi" | ya | Tidak |
| A9 | SLA antar 30 menit sejak kurir menerima; lewat dari itu ditandai merah di admin | 30 menit | Ya, di Panel Demo |

---

## 3. Stack & package

Pilih versi **terbaru yang kompatibel** dengan Flutter stable saat mulai; cek di pub.dev. Jangan tambah package
di luar daftar tanpa alasan jelas (catat di PROGRESS.md jika menambah).

| Kebutuhan | Package |
|---|---|
| State | `flutter_riverpod` |
| Routing | `go_router` |
| Animasi deklaratif (stagger, shimmer, shake) | `flutter_animate` |
| Transisi Material motion (container transform, shared axis, fade through) | `animations` |
| Confetti | `confetti` |
| QR (render string QRIS dummy) | `qr_flutter` |
| Grafik dashboard | `fl_chart` |
| Format angka/tanggal Indonesia | `intl` |
| Upload foto KTM | `image_picker` |
| Buka WhatsApp / telepon | `url_launcher` |
| Notifikasi lokal Android | `flutter_local_notifications` |
| Suara | `audioplayers` |
| Generate Excel | `excel` (di web memicu unduhan; di Android simpan lalu bagikan via `share_plus`) |
| Ikon aplikasi & splash native | `flutter_launcher_icons`, `flutter_native_splash` (dev) |
| Test waktu/timer | `fake_async` (dev) |

Haptik memakai `HapticFeedback` bawaan Flutter.

---

## 4. Arsitektur & struktur folder

Prinsip: **UI → provider/controller → repository interface → implementasi fake.** Logika bisnis (harga, dispatch,
ledger) berupa fungsi/kelas murni yang bisa di-test tanpa Flutter. Waktu lewat abstraksi `Clock` supaya timer bisa
di-test dan dipercepat.

```
lib/
  main.dart                  # entry; deteksi web → buka /stage atau role picker
  app/
    router.dart              # go_router: /, /customer/..., /courier/..., /admin/..., /stage
    app.dart                 # MaterialApp.router, theme, overlay badge MODE DEMO
  core/
    brand/                   # nama app, tagline, logo (path SVG), warna brand — SATU tempat
    design_system/           # tokens (warna, tipografi, radius, spacing, shadow), komponen dasar
    motion/                  # durasi & kurva, widget animasi reusable (odometer, countdown ring, radar, fly-to-cart)
    format/                  # format rupiah, tanggal, durasi
    clock.dart               # abstraksi waktu (real & dipercepat)
  domain/
    models/                  # User, Courier, Canteen, Product, CartLine, Order, OrderLine, CourierOffer, LedgerEntry, Withdrawal, AppNotification, Building
    pricing.dart             # aturan harga murni (§6.1)
    dispatch.dart            # aturan pemilihan kurir murni (§6.2)
    order_state.dart         # state machine pesanan (§5.2)
  data/
    repositories/            # interface (AuthRepo, CatalogRepo, OrderRepo, CourierRepo, WalletRepo, AdminRepo, NotificationRepo)
    fake/                    # implementasi in-memory + latensi simulasi 300–800 ms
    seed/                    # data awal (§7)
  features/
    customer/                # C-xx
    courier/                 # K-xx
    admin/                   # A-xx (responsif)
    shared/                  # S-xx (splash, role picker)
  demo/
    demo_director.dart       # orkestrasi simulasi: timer tawaran, perilaku kurir bot, auto-pilot
    demo_panel/              # Panel Demo (bottom sheet tersembunyi)
    stage/                   # Mode Panggung (web)
    notifications/           # jembatan ke notifikasi lokal / banner in-app
assets/
  fonts/ images/food/ images/ktm/ images/avatars/ sfx/ brand/
test/
  domain/ (pricing_test, dispatch_test, order_state_test, ledger_test)
  widget/ (smoke test tiap peran)
tool/
  gen_sfx.py                 # sintesis SFX (wav) bebas lisensi
```

**Mode Panggung (teknis):** satu `ProviderScope` di root. Tiap panel (HP Customer, HP Kurir, Admin) adalah
widget dengan **instance GoRouter sendiri** (dirender via `Router.withConfig`) di dalam bingkai HP yang di-scale
(`FittedBox`). Jadi tiap panel punya navigasi sendiri tapi membaca state yang sama.

---

## 5. Model domain & state machine

### 5.1 Entitas (field minimum)

- **User (customer):** id, nama, NIM, email, noHp, statusAkun (`pending | active | rejected`), fotoKtm, alasanTolak?
- **Courier:** id, nama, NIM, noHp, foto, rating (double), jumlahUlasan, online (bool), sibuk (bool), perilakuDemo (`manual | ignore | reject | acceptAfter(n detik)`)
- **Canteen:** id, nama ("Kantin A · Gorengan Bu Sri"), kodeHuruf, jamBuka, foto, posisi di peta kampus
- **Product:** id, canteenId, nama, harga (int), foto, kategori (`makanan | minuman | snack`), populer (bool)
- **CartLine:** productId, qty, catatan?
- **Order:** id (format `NTP-0412`), customerId, lines (snapshot nama/harga/canteenId), tujuan (Building + lantai/ruang + patokan), subtotal, ongkir, fee, total, status, courierId?, timestamps per status, rating?
- **CourierOffer:** orderId, courierId, dibuatPada, kedaluwarsaPada, hasil (`pending | accepted | rejected | expired`)
- **LedgerEntry (saldo kurir):** id, courierId, tipe (`earning | withdrawal`), jumlah (+/−), orderId?, waktu, keterangan. **Saldo = jumlah semua entry**, tidak disimpan sebagai satu angka.
- **Withdrawal:** id, courierId, jumlah, tujuan (e-wallet/bank/tunai), status (`requested | approved | paid | rejected`)
- **Building:** id, nama ("Gedung A · Fakultas Teknik"), posisi di peta kampus
- **AppNotification:** id, peran target, judul, isi, waktu, dibaca, deepLink

### 5.2 State machine pesanan

```
awaitingPayment ──bayar──▶ paid ──▶ searchingCourier ──diterima──▶ courierAssigned
                                         │  ▲                         │
                         semua habis ◀───┘  └── kurir dibatalkan admin ┘ (kembali mencari, kurir lama dikecualikan)
                              ▼
                        noCourierFound ──coba lagi──▶ searchingCourier

courierAssigned ──mulai belanja──▶ purchasing ──semua kantin dicentang──▶ delivering ──diserahkan──▶ delivered
delivered ──customer konfirmasi/rating──▶ completed
awaitingPayment ──kedaluwarsa (15 menit)──▶ expired
```

- `purchasing` menyimpan progres per kantin (kantin mana yang sudah selesai dibeli).
- Saat `delivered`: tulis LedgerEntry `earning` = subtotal + ongkir untuk kurir; fee tercatat sebagai pendapatan platform.
- Transisi tidak sah harus ditolak (dan di-test).

---

## 6. Aturan bisnis (WAJIB persis + unit test)

### 6.1 Harga

- `totalQty` = jumlah qty semua baris di keranjang (lintas kantin).
- Validasi: `1 ≤ totalQty ≤ 20`. Menambah item yang membuat totalQty > 20 **ditolak** (UI: animasi shake + pesan "Maksimal 20 item per pesanan").
- Ongkir: totalQty 1–5 → **Rp5.000**; 6–10 → **Rp8.000**; 11–20 → **Rp12.000**.
- Fee layanan: `round(2% × feeBase)`, default feeBase = subtotal, pembulatan setengah ke atas ke rupiah.
- Total = subtotal + ongkir + fee.
- Pendapatan kurir per pesanan = subtotal + ongkir. Pendapatan platform = fee.

**Kasus uji minimum:**

| Keranjang | totalQty | Subtotal | Ongkir | Fee | Total |
|---|---|---|---|---|---|
| Pisang Goreng 10.000 ×2 + Kopi Hitam 5.000 ×3 | 5 | 35.000 | 5.000 | 700 | **40.700** |
| (sama) + Kopi Hitam ×1 lagi | 6 | 40.000 | 8.000 | 800 | **48.800** |
| 10 item | 10 | — | 8.000 | — | — |
| 11 item | 11 | — | 12.000 | — | — |
| 20 item | 20 | — | 12.000 | — | — |
| Tambah ke 21 | — | ditolak | | | |
| Subtotal 12.345 | — | 12.345 | — | 247 (246,9 → 247) | — |
| feeBase = subtotal+ongkir, kasus 1 | 5 | 35.000 | 5.000 | 800 | 40.800 |

### 6.2 Dispatch kurir

1. Kandidat = kurir `online`, tidak `sibuk`, dan **belum pernah ditawari** untuk pesanan ini (termasuk yang menolak/kedaluwarsa/dibatalkan admin).
2. Urutkan berdasarkan rating tertinggi; seri → acak dengan **seed tetap** (demo harus deterministik).
3. Buat CourierOffer dengan `kedaluwarsaPada = sekarang + offerTimeout` (default demo 15 detik; produksi 60 detik).
4. Diterima → pesanan `courierAssigned`, kurir `sibuk`. Ditolak/kedaluwarsa → kembali ke langkah 1.
5. Tidak ada kandidat → `noCourierFound`.
6. Admin membatalkan kurir saat `courierAssigned/purchasing/delivering` → kurir tidak sibuk lagi, pesanan kembali ke `searchingCourier` (kurir lama dikecualikan). Prototype tidak menangani kasus uang sudah terpakai — cukup dialog konfirmasi yang menyebut ini.
7. Countdown di UI dihitung dari `kedaluwarsaPada` (bukan timer lokal per layar) supaya semua panel sinkron.

**Kasus uji:** urutan rating; seri deterministik dengan seed; timeout → pindah kurir berikutnya; tolak → pindah;
semua habis → noCourierFound; kurir offline/sibuk tidak pernah ditawari; pembatalan admin mengecualikan kurir lama.
Pakai `fake_async` + Clock.

### 6.3 Saldo & tukar saldo

- Saldo kurir = Σ LedgerEntry. Pengajuan tukar saldo > saldo tersedia ditolak. Minimum Rp10.000.
- Pengajuan membuat Withdrawal `requested` dan **menahan** jumlahnya (saldo tersedia = saldo − total withdrawal yang belum selesai).
- Admin approve → `approved`; tandai dibayar → `paid` + LedgerEntry `withdrawal` negatif. Ditolak → tahanan dilepas.

---

## 7. Data seed (fiktif)

**Kampus fiktif:** "Universitas Nusantara Contoh". Semua KTM memakai watermark besar **"CONTOH"** supaya jelas bukan dokumen asli.

**Kantin & menu (harga Rupiah):**

- **Kantin A · Gorengan Bu Sri** — Pisang Goreng 10.000 · Tahu Isi (3 pcs) 6.000 · Bakwan Jagung (3 pcs) 6.000 · Cireng Rujak 8.000 · Risol Mayo 5.000
- **Kantin B · Kopi Pojok** — Kopi Hitam 5.000 · Es Kopi Susu Gula Aren 12.000 · Es Teh Manis 4.000 · Teh Tarik 8.000 · Matcha Latte 15.000
- **Kantin C · Penyetan Mas Joko** — Nasi Ayam Penyet 18.000 · Nasi Lele Penyet 16.000 · Tempe Penyet 12.000 · Nasi Telur Balado 13.000
- **Kantin D · Es & Jus Segar** — Jus Alpukat 12.000 · Es Campur 10.000 · Jus Jeruk 9.000 · Es Kelapa Muda 10.000

**Gedung tujuan:** Gedung A · Fakultas Teknik; Gedung B · Fakultas Ekonomi & Bisnis; Gedung C · FISIP; Perpustakaan Pusat;
Gedung Rektorat; Masjid Kampus; Asrama Mahasiswa; GOR Kampus. Masing-masing punya posisi di peta ilustrasi.

**Customer:** Rina Ayu Lestari, NIM 2023010145 — dipakai di demo pendaftaran.
**Pendaftar pending lain:** Dimas Arya (NIM di form beda 1 digit dari KTM → contoh penolakan), Putri Maharani (valid).

**Kurir:**

| Nama | NIM | Rating | Perilaku demo default |
|---|---|---|---|
| Budi Santoso | 2021010087 | 4.9 (212 ulasan) | `ignore` (dibiarkan sampai timeout) |
| Sari Wulandari | 2022010211 | 4.8 (187) | `manual` (dikendalikan presenter) |
| Andi Pratama | 2021010132 | 4.5 (96) | sedang mengantar pesanan yang **sudah telat 45 menit** |
| Fajar Nugroho | 2022010098 | 4.6 (64) | offline |

**Riwayat hari ini (untuk dashboard):** 27 transaksi selesai tersebar pukul 07.00 sampai "sekarang" dengan pola jam
makan (puncak 09.30–10.00 dan 12.00–13.00), total dan fee dihitung pakai aturan §6.1 (bukan angka karangan).
Saldo awal Sari Rp126.500 dengan beberapa mutasi.

**Foto makanan:** foto dengan lisensi bebas (Unsplash/Pexels) dikompres WebP ±800px, ≤120 KB; catat sumbernya di
`assets/images/food/CREDITS.md`. Jika tidak bisa mengunduh, pakai kartu placeholder bergradasi + nama makanan dan
tandai di PROGRESS.md supaya user mengganti dengan foto sendiri.

---

## 8. Infrastruktur demo

### 8.1 Role picker (S-02)
Tiga kartu: Customer, Kurir, Admin/Owner. Di Web ada kartu keempat **"Mode Panggung"**.

### 8.2 Badge "MODE DEMO"
Pil kecil di pojok kanan atas, di atas semua layar (overlay). **Tekan lama 1 detik** → buka Panel Demo.

### 8.3 Panel Demo (bottom sheet)
- Reset semua data ke seed (dengan konfirmasi)
- Timeout tawaran kurir: 15 detik / 60 detik
- Perilaku tiap kurir bot (manual / abaikan / tolak / terima setelah n detik)
- Auto-pilot Sari: otomatis terima + jalan sampai selesai (untuk demo 1 HP tanpa pindah peran)
- Kecepatan waktu simulasi (1× / 2× / 5×) untuk timer antar dan SLA
- Picu "order masuk" untuk kurir dari pesanan siap pakai
- Lompat ke: sesudah bayar / kurir di kantin / pesanan sampai
- Suara on/off, haptik on/off
- Pindah peran cepat (tanpa kembali ke role picker)

### 8.4 Mode Panggung (Web, lebar ≥ 1280 px)
- Kiri: HP Customer. Tengah: HP Kurir. Kanan: Dashboard Admin. Semua live, state sama.
- **Spotlight:** jika ada event di panel yang tidak sedang dipakai (misal order masuk ke kurir), bingkai panel itu
  bersinar oranye lembut + label kecil "Order masuk!" supaya penonton menoleh ke sana.
- Feed aktivitas ("Sari menerima pesanan NTP-0412") tampil di dashboard.
- Shortcut keyboard presenter: `1`/`2`/`3` fokus panel, `R` reset (dengan konfirmasi), `D` buka Panel Demo, `F` fullscreen.
- Di bawah 1280 px: tampilkan role picker biasa.

---

## 9. Fase eksekusi

Kerjakan berurutan. Setiap fase: commit, push, update `docs/PROGRESS.md` (centang + catatan + screenshot jika ada).

### Fase 0 — Fondasi (±0,5 hari)
- Buat project Flutter (`org` com.nitip.demo, nama `nitip`), aktifkan platform android & web.
- Pasang package §3, lint ketat (`flutter_lints` + aturan tambahan wajar), struktur folder §4.
- Bundel font Plus Jakarta Sans (Regular, Medium, SemiBold, Bold, ExtraBold).
- CI GitHub Actions: analyze → test → build APK release (debug signing bawaan cukup untuk sideload) → build web → upload keduanya sebagai artifact.
- Isi perintah di `CLAUDE.md`.
- **Selesai jika:** CI hijau, artifact APK + web tersedia, app kosong menampilkan teks dengan font yang benar.

### Fase 1 — Design system & primitif animasi (±1 hari)
- Token di `docs/DESIGN.md` → ThemeData + ekstensi tema.
- Komponen: tombol (primary hitam, secondary, ghost, slide-to-confirm), kartu, chip kategori dengan indikator geser,
  stepper qty dengan angka bergulir, teks rupiah beranimasi (odometer), countdown ring, bottom nav pill mengambang,
  skeleton shimmer, toast/banner, empty state, bingkai HP (untuk Mode Panggung), badge MODE DEMO.
- Primitif motion `docs/MOTION.md`: odometer, countdown ring, radar, fly-to-cart, confetti burst, checkmark draw, shake.
- Route tersembunyi `/_gallery` menampilkan semua komponen + animasi.
- **Selesai jika:** gallery menampilkan semua komponen; screenshot gallery disimpan di PROGRESS.md.

### Fase 2 — Domain, data fake, simulasi (±1 hari)
- Model §5, aturan §6, seed §7, repository interface + fake, Clock, DemoDirector (timer tawaran, perilaku bot, auto-pilot).
- Unit test seluruh kasus §6.1–6.3 + state machine.
- **Selesai jika:** `flutter test` hijau dan semua tabel kasus uji ada sebagai test.

### Fase 3 — Alur Customer (±2 hari)
- Layar C-01 sampai C-16 (P1), lalu P2 bila waktu cukup. Ikuti `docs/SCREENS.md`.
- Peta kampus ilustrasi dipakai di C-10 (pilih gedung) dan C-15 (lacak).
- **Selesai jika:** Babak 1–3 naskah demo bisa dijalankan di web lokal (dengan admin approve via Panel Demo untuk sementara).

### Fase 4 — Alur Kurir (±1,5 hari)
- K-01 sampai K-08 (P1). Order masuk full-screen + suara + haptik + notifikasi lokal Android.
- **Selesai jika:** Babak 4 bisa dijalankan, saldo bertambah sesuai §6.1, tukar saldo menahan saldo sesuai §6.3.

### Fase 5 — Admin (±1,5 hari)
- A-01 sampai A-08 (P1), responsif (web lebar sebagai target utama).
- Excel: sheet Ringkasan, Transaksi, Rekap Kurir — angka harus sama dengan dashboard.
- **Selesai jika:** Babak 5 bisa dijalankan; file Excel terunduh di web dan bisa dibagikan di Android.

### Fase 6 — Infrastruktur demo (±1 hari)
- Role picker, badge, Panel Demo §8.3, Mode Panggung §8.4 (spotlight + shortcut).
- **Selesai jika:** seluruh naskah demo bisa dijalankan di Mode Panggung tanpa reload, dan Reset mengembalikan semua ke seed.

### Fase 7 — Brand & aset (±0,5 hari)
- Logo SVG + versi animasi (`docs/DESIGN.md` §1), ikon launcher Customer-style (oranye), favicon + ikon PWA web,
  splash native, nama app "Nitip". SFX via `tool/gen_sfx.py`.
- **Selesai jika:** ikon & splash tampil di APK, favicon/judul tab benar di web.

### Fase 8 — Polish "WOW" (±1,5 hari)
- Lengkapi semua animasi P1 di `docs/MOTION.md`, lalu P2 sesuai waktu.
- Rapikan micro-copy, empty state, loading state, error state (misal kamera ditolak).
- Uji reduce motion.
- **Selesai jika:** checklist WOW di `docs/MOTION.md` §4 tercentang semua (P1).

### Fase 9 — QA, build, deploy (±0,5–1 hari)
- Jalankan naskah demo end-to-end di web (Playwright: screenshot tiap babak) dan, bila ada perangkat/emulator, di APK.
- Profil performa (mode profile) di Android: tidak ada jank pada radar, countdown, dan fly-to-cart.
- Deploy web ke Vercel (§10). Lampirkan APK di GitHub Release/artifact.
- README: cara install APK, URL web, ringkasan naskah demo, daftar asumsi §2.
- **Selesai jika:** URL Vercel hidup, APK bisa di-install, README lengkap.

**Total kasar: 10–12 hari kerja.**

---

## 10. Verifikasi, build & deploy

- **Lokal (container cloud):** Flutter SDK mungkin belum terpasang. Pasang Flutter stable (clone repo resmi). Jika
  jaringan menolak, baca dokumentasi environment (topik network) lalu laporkan ke user, jangan diakali.
- **Android SDK berat** untuk container; build APK **di GitHub Actions** (`subosito/flutter-action` + `actions/setup-java` 17).
- **Verifikasi visual web:** `flutter build web` → sajikan statis → Playwright (Chromium sudah terpasang di environment)
  ambil screenshot route penting. Catatan: Flutter web merender ke canvas, jadi verifikasi lewat screenshot, bukan query DOM.
- **Vercel:** build di GitHub Actions lalu `vercel deploy --prebuilt --prod` dengan secret `VERCEL_TOKEN`,
  `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` (**user yang membuat project & secret**). `vercel.json` berisi rewrite semua path ke
  `index.html` (SPA). Alternatif tanpa secret: artifact web untuk diunggah manual.

---

## 11. Risiko & mitigasi

| Risiko | Mitigasi |
|---|---|
| Klien mengira aplikasi "hampir jadi" | Badge MODE DEMO; layar penutup "Yang belum ada di prototype"; README menyebut scope |
| Prototype dibawa ke vendor lain | Hanya APK/URL yang dibagikan; source tidak diberikan sebelum DP |
| Animasi patah-patah di HP klien | RepaintBoundary, hindari blur besar, uji mode profile, fallback reduce motion |
| Demo gagal di tengah presentasi | Panel Demo: reset & lompat ke step; data deterministik; offline-capable |
| Notifikasi Android 13+ butuh izin | Minta izin saat pertama masuk peran Kurir; fallback banner in-app |
| Nama "Nitip" bentrok merek/app lain | Wajib cek PDKI & Play Store sebelum produksi; nama ada di satu file konfigurasi |
| Foto makanan tidak bisa diunduh | Placeholder bergradasi; user mengganti nanti |

---

## 12. Di luar scope prototype

Backend, autentikasi nyata, OCR KTM, payment gateway & webhook, payout otomatis, push notification via server,
chat in-app (pakai tautan WhatsApp), peta/GPS sungguhan, dark mode, multi-bahasa, aplikasi untuk kantin,
publikasi Play Store.
