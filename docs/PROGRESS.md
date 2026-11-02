# PROGRESS

Update file ini setiap fase selesai: centang, tanggal, catatan singkat (keputusan, package tambahan, hal yang
ditunda), dan path screenshot jika ada.

| Fase | Status | Tanggal | Catatan |
|---|---|---|---|
| 0 — Fondasi | ✅ | 2026-11-02 | Flutter 3.47.9 dipasang di /opt/sdk/flutter. Web release build OK (~55 dtk). APK **belum bisa dibuild lokal** (tanpa Android SDK) → dibuild di GitHub Actions (`.github/workflows/ci.yml`); CI belum terverifikasi karena belum ada PR/run. Font Plus Jakarta Sans dibundel (diunduh via Google Fonts API). |
| 1 — Design system & primitif animasi | ⬜ | | |
| 2 — Domain, data fake, simulasi | ⬜ | | |
| 3 — Alur Customer | ⬜ | | |
| 4 — Alur Kurir | ⬜ | | |
| 5 — Admin | ⬜ | | |
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
