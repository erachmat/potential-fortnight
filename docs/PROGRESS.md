# PROGRESS

Update file ini setiap fase selesai: centang, tanggal, catatan singkat (keputusan, package tambahan, hal yang
ditunda), dan path screenshot jika ada.

| Fase | Status | Tanggal | Catatan |
|---|---|---|---|
| 0 — Fondasi | ✅ | 2026-11-02 | Flutter 3.47.9 dipasang di /opt/sdk/flutter. Web release build OK (~55 dtk). APK **belum bisa dibuild lokal** (tanpa Android SDK) → dibuild di GitHub Actions (`.github/workflows/ci.yml`); CI belum terverifikasi karena belum ada PR/run. Font Plus Jakarta Sans dibundel (diunduh via Google Fonts API). |
| 1 — Design system & primitif animasi | 🟡 | 2026-11-02 | Token, tema, komponen, odometer, ring, radar, centang, confetti, shake sudah ada. Route `/_gallery` menyusul bersama router (Fase 3). |
| 2 — Domain, data fake, simulasi | ✅ | 2026-11-02 | 29 test hijau (pricing §6.1, dispatch §6.2, wallet §6.3, state machine, alur penuh). **Deviasi:** tidak ada interface repository terpisah; satu kelas `Backend` (ChangeNotifier, `lib/data/backend.dart`) = permukaan API yang nanti diganti impl sungguhan. Seed: 26 selesai + 1 telat (NTP-0398) = 27 transaksi hari ini. Foto makanan: placeholder emoji bergradasi (belum ada foto stok). |
| 3 — Alur Customer | ✅ | 2026-11-02 | C-01..C-07, C-09..C-17, C-18/19 (versi ringkas); C-08 (detail produk) ditunda. Widget test e2e hijau (login → belanja → bayar → kurir → rating; daftar → approve). Router: `/customer`; semua tahap pesanan dalam satu `OrderFlowScreen` yang mengikuti status live. **Deviasi:** pakai `InheritedNotifier` (BackendScope), bukan Riverpod (dihapus dari pubspec). |
| 4 — Alur Kurir | ✅ | 2026-11-02 | K-01..K-08 (+ K-06 koin/saldo bergulir). Order masuk = overlay layar penuh di atas Navigator, countdown dari `expiresAt`. Notifikasi sistem Android (`flutter_local_notifications`) **belum** — baru banner in-app (lihat Fase 6). Widget test e2e hijau. K-09/K-10 (P2) belum. |
| 5 — Admin | ✅ | 2026-11-02 | A-01..A-08. Responsif (sidebar ≥900px, drawer di bawahnya). Validasi KTM dengan kaca pembesar + pembanding otomatis NIM. Excel 3 sheet (Ringkasan/Transaksi/Rekap Kurir) lewat `excel`; web = unduh blob, Android = share sheet. A-09 (CRUD kantin) belum. Test menemukan & memperbaiki overflow `SecondaryButton`. |
| 6 — Infrastruktur demo (Panel, Mode Panggung) | ⬜ | | |
| 7 — Brand & aset | ⬜ | | |
| 8 — Polish WOW | ⬜ | | |
| 9 — QA, build, deploy | ⬜ | | |

## Perlu tindakan user

- [ ] Konfirmasi nama brand "Nitip" (atau pilih alternatif di `docs/DESIGN.md` §1).
- [ ] Buat project Vercel + set secret `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` di GitHub (sebelum Fase 9).
- [ ] (Opsional) Kirim foto jajanan sendiri jika foto stok kurang pas.

## Log

- 2026-11-02 Fase 0: package §3 terpasang semua. github.com diblokir proxy; storage.googleapis.com & pub.dev bisa.
