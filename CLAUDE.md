# Nitip — Prototype Aplikasi Kantin Kampus

Repo ini berisi **prototype Flutter** untuk pitching ke klien: aplikasi pesan jajanan kantin kampus
(Customer + Kurir sebagai APK Android, Admin/Owner sebagai Flutter Web). **Tidak ada backend.**
Semua data palsu (in-memory), pembayaran disimulasikan. Tujuannya satu: klien bilang "WOW" lalu deal.

## Baca dulu sebelum menulis kode (urut)

1. `docs/PLAN.md` — keputusan, arsitektur, aturan bisnis, fase kerja + kriteria selesai. **Wajib.**
2. `docs/DESIGN.md` — brand (nama, logo), token warna/tipografi/spacing, komponen.
3. `docs/SCREENS.md` — spesifikasi tiap layar (ID C-xx, K-xx, A-xx, S-xx).
4. `docs/MOTION.md` — katalog animasi (ID M-xx). Ini yang bikin WOW, jangan dianggap hiasan.
5. `docs/DEMO_SCRIPT.md` — naskah demo; semua fitur harus melayani naskah ini.
6. `docs/PROGRESS.md` — status fase. Update setiap selesai satu fase.

## Aturan keras

- Jangan bangun backend, auth beneran, atau integrasi payment beneran. Data lewat interface repository + implementasi fake.
- Semua teks UI **Bahasa Indonesia**, sapaan "kamu", nada santai-sopan. Uang selalu `Rp48.800` (titik ribuan, tanpa desimal). Uang disimpan sebagai `int` rupiah, tidak pernah `double`.
- Aturan harga & dispatch **persis** seperti `docs/PLAN.md` §6, dan wajib punya unit test.
- Jangan menyalin aset, logo, atau foto dari referensi Behance (Cravk, Insightlancer). Hanya inspirasi gaya.
- Badge "MODE DEMO" selalu tampil — klien harus tahu ini prototype.
- Hormati "reduce motion" (MediaQuery.disableAnimations): animasi besar diganti fade singkat.
- Target 60fps di Android kelas menengah. Animasi kontinu dibungkus RepaintBoundary; hindari blur besar.
- Commit per fase (atau lebih kecil), push ke branch kerja yang ditentukan sesi. Jangan buat PR kecuali diminta.

## Perintah

Flutter di container ada di `/opt/sdk/flutter` (pasang ke PATH: `export PATH=/opt/sdk/flutter/bin:$PATH FLUTTER_SUPPRESS_ANALYTICS=true`).
Bila hilang: unduh stable dari `storage.googleapis.com/flutter_infra_release` (github.com diblokir proxy).

- Install deps: `flutter pub get`
- Analisis: `flutter analyze`
- Test: `flutter test`
- Jalankan web: `flutter run -d web-server --web-port 8080`
- Build APK: `flutter build apk --release`
- Build web: `flutter build web --release`
