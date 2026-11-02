# PROGRESS

Status per fase, keputusan yang menyimpang dari `PLAN.md`, dan apa yang **belum** dikerjakan / belum terverifikasi.
Terakhir diperbarui: 2026-11-02.

## Ringkasan

| Fase | Status | Catatan |
|---|---|---|
| 0 — Fondasi | ✅ | Flutter 3.47.9; CI GitHub Actions ditulis (**belum pernah dijalankan** — lihat "Belum terverifikasi") |
| 1 — Design system & primitif animasi | ✅ (dengan catatan) | Token, tema, komponen, odometer, countdown ring, radar, centang digambar, confetti, shake, fly-to-cart. `/_gallery` ada. |
| 2 — Domain, data fake, simulasi | ✅ | Aturan harga/dispatch/saldo/state machine + unit test + test backend |
| 3 — Alur Customer | ✅ (dengan catatan) | C-01..C-07, C-09..C-19. **C-08 (detail produk) ditunda.** |
| 4 — Alur Kurir | ✅ (dengan catatan) | K-01..K-08. K-09/K-10 (P2) belum. |
| 5 — Admin | ✅ (dengan catatan) | A-01..A-08. A-09 (CRUD kantin) belum. |
| 6 — Infrastruktur demo | ✅ | Role picker, badge, Panel Demo, **Mode Panggung** (spotlight, shortcut), notifikasi in-app + notifikasi sistem Android (kode ada, belum diuji di perangkat) |
| 7 — Brand & aset | ✅ | Logo "Nitip" (tas belanja + pegangan "n" + gelembung chat), ikon launcher/favicon/PWA, splash native, 5 SFX buatan sendiri |
| 8 — Polish WOW | 🟡 | Sebagian besar animasi P1 ada; beberapa disederhanakan (daftar di bawah). Profil performa Android **belum**. |
| 9 — QA, build, deploy | 🟡 | 42 test hijau; web + APK ter-build lokal; QA visual via Playwright. **Belum:** deploy Vercel, jalan di perangkat/emulator, CI belum terverifikasi. |

## Terverifikasi (dengan bukti)

- `flutter analyze`: bersih. `flutter test`: **42 test hijau** — unit (harga §6.1, dispatch §6.2, saldo §6.3, state machine, backend)
  dan widget e2e: Customer (login → belanja multi-kantin → bayar → kurir → rating; daftar → admin setujui → aktif; layar kantin),
  Kurir (order masuk → terima → belanja → serahkan → saldo +Rp48.000), Admin (dashboard, validasi KTM, batalkan kurir telat, Excel),
  Mode Panggung (3 panel berbagi state + spotlight), Panel Demo, dan reduce-motion.
- `flutter build web --release` dan `flutter build apk --release` berhasil lokal. APK: 57,7 MB, `com.nitip.nitip`, minSdk 24,
  label "Nitip", font + SFX + aset brand ikut terbundel (dicek lewat `apkanalyzer`/`unzip`).
- QA visual di Chromium (Playwright, 1920×1080) memakai klik mouse nyata: seluruh alur demo Babak 2–5 berjalan di Mode Panggung
  tanpa error konsol. Screenshot: `docs/screenshots/`.
- Angka naskah demo terbukti di UI: 6 item → ongkir Rp8.000, layanan Rp800, **total Rp48.800**; kurir terima **Rp48.000**;
  dashboard 27 → 28 transaksi, pendapatan +Rp800.

### Bug yang ketahuan lewat QA visual (tidak tertangkap test awal) dan sudah diperbaiki
1. Logo `NitipMark` tergambar raksasa di layar login (CustomPaint melebar mengikuti lebar ListView).
2. FAB keranjang hilang di layar kantin (satu `GlobalKey` dipakai dua FAB). Sekarang ada `CartAnchors` + test regresi
   (terbukti gagal dengan perilaku lama: "Duplicate GlobalKey detected").
3. Data seed: pesanan telat NTP-0398 dan 26 riwayat tercatat sebagai milik Rina (akun demo) → dipindah ke customer lain.
4. Konsep logo awal terbaca sebagai **gembok**; digambar ulang sebagai tas belanja (badan trapesium, pegangan menembus ke dalam).
5. Overflow `SecondaryButton` di kartu sempit; label gedung di peta terpotong; tombol mati di layar belanja kurir; "-" saat patokan kosong.

## Belum terverifikasi / belum dikerjakan (jujur)

**Belum terverifikasi**
- **APK belum pernah dijalankan di perangkat atau emulator** (container tanpa emulator). Yang terbukti hanya: ter-build dan isinya benar.
  Belum dicek di HP: kamera/galeri KTM, getar, notifikasi sistem Android (izin POST_NOTIFICATIONS), suara, performa/jank.
- **CI GitHub Actions belum pernah jalan** (`ci.yml`, `deploy-web.yml`); ditulis sesuai praktik standar tapi belum teruji.
  Build lokal memakai Flutter 3.47.9; CI memakai `channel: stable` (bisa berbeda versi).
- **Deploy Vercel belum dilakukan** (butuh akun/secret milik user). Konfigurasi siap: `vercel.json`, `deploy-web.yml`.
- Unduhan Excel di **web** (blob + anchor) dan **Android** (share sheet) belum dicoba di perangkat nyata; yang diuji hanya pembuatan file xlsx valid.
- Profil performa (`--profile`) di Android untuk radar/countdown/fly-to-cart belum dilakukan.

**Belum dikerjakan (di luar yang ditunda sengaja)**
- C-08 detail produk (+ container transform M-15), K-09 riwayat antar, K-10 profil kurir, A-09 kelola kantin & menu.
- Foto makanan masih **placeholder emoji bergradasi** (belum ada foto stok). Ganti dengan foto sendiri bila perlu.
- Notifikasi "email/WhatsApp" hanya pratinjau kartu palsu di layar (sesuai scope prototype).

**Animasi yang disederhanakan dibanding `MOTION.md`**
- M-03/M-15/M-20 (container transform): diganti fade + transisi default.
- M-01: logo digambar (path draw + pop gelembung) tapi "pegangan memantul" belum ada.
- M-32: koin berhamburan memakai confetti (bukan partikel koin), saldo bergulir sudah sesuai.
- M-10: parallax banner hanya offset ikon, bukan foto.
- M-04 (onboarding S-03) tidak dibuat (P2).

## Deviasi dari PLAN.md

| PLAN | Kenyataan | Alasan |
|---|---|---|
| `flutter_riverpod` | `InheritedNotifier` (`BackendScope`), Riverpod dihapus | `Backend` sudah `ChangeNotifier`; satu instance mudah dibagi ke 3 panel Mode Panggung |
| Interface repository + impl fake | Satu kelas `Backend` (`lib/data/backend.dart`) | Lebih ringkas; permukaan API publiknya yang nanti diganti impl sungguhan |
| `go_router` per panel di Mode Panggung | Tiap panel memakai `Navigator` sendiri (bukan GoRouter) | Lebih sederhana dan stabil di dalam `FittedBox` |
| `flutter_native_splash` sebagai dev dependency | Dilepas setelah generate | Plugin Android-nya gagal compile (compileSdk 31) di build release; aset splash sudah ter-generate |
| applicationId `com.nitip.demo` | `com.nitip.nitip` | Default `flutter create --org com.nitip`; ganti bila perlu sebelum rilis |
| APK dibangun hanya di CI | Dibangun juga lokal (Android SDK dipasang di `/opt/android`) | Agar APK benar-benar terverifikasi |
| APK di-commit ke repo | **Tidak** di-commit (`dist/` di-gitignore) | Binary 57 MB membengkakkan riwayat git; ambil dari CI artifact atau kirim langsung |

## Perlu tindakan user

- [ ] Konfirmasi nama brand **Nitip** (atau alternatif di `docs/DESIGN.md` §1); cek PDKI/Play Store sebelum produksi.
- [ ] **Coba APK di HP asli** dan laporkan masalah (terutama kamera KTM, notifikasi, suara, kelancaran animasi).
- [ ] Buat project Vercel + secret `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` di GitHub, lalu jalankan workflow *Deploy web*.
- [ ] Jalankan workflow CI sekali (push/`workflow_dispatch`) dan pastikan hijau.
- [ ] Konfirmasi asumsi bisnis A1–A8 ke klien (lihat `README.md`), terutama basis biaya layanan 2% dan siapa yang menalangi belanja.
- [ ] (Opsional) Foto jajanan sendiri untuk mengganti placeholder.

## Log

- 2026-11-02 Fase 0–2: Flutter 3.47.9 di `/opt/sdk/flutter`; github.com diblokir proxy, `storage.googleapis.com`, pub.dev, dl.google.com, Maven bisa.
- 2026-11-02 Fase 3–5: tiga peran selesai dengan widget test e2e.
- 2026-11-02 Fase 6–7: Mode Panggung, SFX (`tool/gen_sfx.py`), ikon (`tool/gen_icons.py`), notifikasi sistem, konfigurasi Vercel.
- 2026-11-02 Build APK: Maven Central sering membalas **429** lewat proxy bersama → build dibungkus retry dengan jeda; cache Gradle
  membuat percobaan berikutnya cepat. Catatan untuk sesi mendatang ada di `CLAUDE.md`.
- 2026-11-02 QA visual Playwright menemukan 5 bug nyata (lihat di atas); semuanya diperbaiki + test regresi untuk FAB ganda.
