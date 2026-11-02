# DEMO SCRIPT — Presentasi ke Klien (±12 menit)

Semua fitur prototype ada untuk melayani naskah ini. Jika ada fitur yang tidak dipakai di naskah, prioritasnya rendah.

Ada dua versi, alurnya sama:

- **Versi Panggung (utama):** laptop + proyektor, Web `/stage`. HP Customer, HP Kurir, dan Dashboard Admin tampil berdampingan.
- **Versi 1 HP:** APK di HP presenter (mirror ke layar via scrcpy/cast), pindah peran lewat Panel Demo. Juga dipakai
  saat klien mencoba sendiri setelah presentasi.

---

## Persiapan (H-1 dan 10 menit sebelum)

- [ ] Panel Demo → **Reset data**. Timeout tawaran = **15 detik**. Budi = abaikan, Sari = manual.
- [ ] Suara ON, volume laptop/HP cukup; HP mode Jangan Ganggu **OFF** (notifikasi harus muncul).
- [ ] Izin notifikasi untuk APK sudah diberikan.
- [ ] Browser fullscreen (`F`), zoom 100%, internet tidak wajib (aset dibundel).
- [ ] APK cadangan terpasang di HP kedua; URL web dibuka di tab cadangan.
- [ ] Siapkan proposal (harga, timeline, asumsi §2 PLAN) untuk dibuka setelah demo.

---

## Babak 0 — Pembuka (30 detik)
Splash logo Nitip (M-01) → role picker.
> "Ini prototype **Nitip**. Satu aplikasi bisa memerankan Customer, Kurir, dan Owner. Datanya simulasi, tapi
> semua aturan bisnis di brief Bapak/Ibu sudah jalan."

Pilih **Mode Panggung**.

## Babak 1 — Daftar & validasi (2 menit)
1. **Customer:** Daftar → isi data Rina (C-02) → "Pakai KTM contoh" → animasi pindai (M-06) → Kirim → C-04 menunggu.
2. Spotlight menyala di **Admin** (M-39): "1 pendaftaran baru".
3. **Admin A-03:** tunjukkan KTM berdampingan dengan data, geser kaca pembesar ke NIM (M-36) → **Setujui Akun** (M-37).
4. **Customer** langsung berubah: confetti "Akun kamu aktif!" + pratinjau email/WA (M-08). Di APK juga muncul notifikasi sistem.
> "Admin mencocokkan KTM, customer langsung dapat kabar lewat email dan WhatsApp."

(Opsional: tolak Dimas Arya karena NIM tidak cocok — menunjukkan alur penolakan.)

## Babak 2 — Belanja multi-kantin (2,5 menit)
1. Beranda (M-09, M-11) → **Kantin A** → Pisang Goreng **×2** (fly-to-cart M-14).
2. **Kantin B** → Kopi Hitam **×3**.
3. Keranjang (C-09): dua kantin terkelompok. Tunjuk angka:
   Subtotal **Rp35.000** · 5 item → Ongkir **Rp5.000** · Biaya layanan 2% **Rp700** · **Total Rp40.700**.
4. Tambah 1 Kopi → 6 item → chip "Ongkir jadi Rp8.000" (M-17) → **Total Rp48.800**.
5. Naikkan qty terus sampai mentok 20 → coba tambah lagi → stepper bergetar + "Maksimal 20 item" (M-18). Kembalikan ke 6 item.
> "Ongkir otomatis ikut tier 1–5, 6–10, 11–20, biaya layanan 2%, maksimal 20 item. Sesuai brief."
> (Sebut asumsi: "2% kami hitung dari subtotal — nanti kita konfirmasi.")

## Babak 3 — Bayar & dispatch kurir (2 menit) ⭐
1. Alamat: tap **Gedung A** di peta kampus (M-19), isi "Lt. 3, R. 305".
2. Bayar dengan QRIS → kartu QRIS (M-20, M-21), nominal **Rp48.800** → **Simulasi Bayar** → sukses (M-22).
3. Mencari kurir (M-23): "Menawarkan ke **Budi ★4.9**". Di panel Kurir, Budi (bot) tidak merespons.
4. 15 detik habis → Budi memudar → ring melompat ke **Sari ★4.8** (M-24). Spotlight di HP Kurir (M-39).
> "Sistem memilih kurir dengan rating tertinggi. Kalau 1 menit tidak direspons — di demo kami percepat jadi
> 15 detik — otomatis pindah ke kurir berikutnya sampai ada yang ambil."

## Babak 4 — Sisi kurir (3 menit) ⭐
1. **Kurir (Sari):** layar order masuk full-screen + ding + ring countdown (M-30). Tunjukkan
   "2 kantin · 6 item · Belanja Rp40.000 · Ongkir Rp8.000" → **Geser untuk Terima**.
2. **Customer** bereaksi: kartu berbalik menampilkan Sari (M-25) → halaman lacak.
3. K-04: detail per kantin persis format brief.
4. K-05: centang Pisang Goreng di Kantin A (M-31) → di **Customer**, peta dan timeline bergerak (M-26, M-27).
   Centang Kantin B → Antar → **Geser kalau sudah diserahkan**.
5. **Kurir** K-06: koin + saldo bergulir **+Rp48.000** (M-32).
6. **Customer:** "Pesanan sudah diterima" → beri 5 bintang (M-28).
7. (Opsional, 20 detik) Kurir → Tukar Saldo Rp100.000 → status "Diajukan".
> "Uang belanja ditambah ongkir masuk ke saldo kurir dan bisa dicairkan lewat fitur tukar saldo."

## Babak 5 — Owner (2 menit)
1. **Admin A-02:** KPI baru saja bergulir (M-33): transaksi **27 → 28**, pendapatan hari ini bertambah **Rp800**,
   titik baru di grafik (M-34), feed aktivitas (M-35).
2. A-05: **Andi** merah — sudah 45 menit. Tekan **WhatsApp** (WhatsApp benar-benar terbuka) → kembali →
   **Batalkan Kurir** → pesanan Andi masuk lagi ke pencarian kurir (terlihat di feed).
3. A-06: rekap **Sari** — NIM, jumlah pesanan, rupiah pesanan, ongkir, total yang harus dikasih ke kurir.
4. A-08: **Unduh Excel** (M-38) → buka filenya: sheet Ringkasan, Transaksi, Rekap Kurir.
> "Owner bisa pantau semua pesanan, menegur atau membatalkan kurir yang terlalu lama, dan unduh laporan keuangan."

## Penutup (1 menit)
Tampilkan slide/layar "Yang belum ada di prototype ini":
backend & database · payment gateway QRIS sungguhan (Xendit/Midtrans) · notifikasi server (FCM) ·
timer dispatch di server · email/WhatsApp sungguhan · rilis Play Store.
> "Yang Bapak/Ibu lihat ini tampilan dan alurnya. Bagian terbesar pekerjaan ada di balik layar — itu yang kita
> kerjakan setelah deal." → buka proposal.

---

## Rencana cadangan

| Masalah | Tindakan |
|---|---|
| Ada yang macet / salah tap | Badge MODE DEMO → Panel Demo → "Lompat ke" step berikutnya |
| Data berantakan | Panel Demo → Reset (semua kembali ke seed dalam < 1 detik) |
| Suara tidak keluar | Lanjut saja; animasi tetap menceritakan |
| Laptop/proyektor bermasalah | Pindah ke Versi 1 HP + mirror; aktifkan auto-pilot Sari agar tidak perlu bolak-balik peran |

## Versi 1 HP — perbedaan
- Mulai dari role picker → Customer.
- Babak 1: setelah kirim pendaftaran, Panel Demo → pindah ke Admin → setujui → pindah balik ke Customer.
- Babak 3–4: aktifkan **auto-pilot Sari** jika ingin tetap di layar Customer; atau pindah ke Kurir saat notifikasi
  "Pesanan baru" muncul (banner in-app/notifikasi sistem), tap → langsung ke K-03.
