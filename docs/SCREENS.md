# SCREENS — Spesifikasi Layar

Format: **ID · Nama · Prioritas** → isi, state, animasi (ID dari `docs/MOTION.md`), navigasi.
P1 = wajib untuk naskah demo. P2 = pelengkap.
Semua layar: loading (skeleton), kosong, dan error harus ditangani bila relevan.

---

## Umum

### S-01 · Splash · P1
Latar putih → logo animasi (M-01) → masuk ke S-02 (atau S-03 di peluncuran pertama peran Customer).

### S-02 · Pilih Peran · P1
- Judul: "Mau masuk sebagai **siapa**?" + subjudul "Prototype Nitip — semua data simulasi."
- Kartu: **Customer** (ilustrasi tas), **Kurir** (ilustrasi motor/jalan kaki), **Admin/Owner** (ilustrasi grafik). Di web: **Mode Panggung**.
- Animasi: kartu masuk bertahap (M-02); kartu terpilih membesar menjadi layar tujuan (M-03).

### S-03 · Onboarding Customer · P2
3 slide: "Lagi kelas? **Nitip** aja." · "Satu pesanan, **banyak kantin**." · "Kurir sesama **mahasiswa**, cepat & aman."
Indikator titik → pill (M-04). Tombol "Mulai".

---

## Customer

### C-01 · Masuk · P1
Email atau NIM + kata sandi, "Lupa kata sandi?" (non-fungsional, toast "Belum tersedia di prototype"), tautan "Daftar".
Akun demo sudah aktif terisi otomatis (chip "Pakai akun demo").

### C-02 · Daftar 1/2 — Data Diri · P1
Field: Nama lengkap, NIM, Email, No. HP (+62), Kata sandi (indikator kekuatan). Validasi saat blur.
Progress bar 2 langkah (M-05). Tombol "Lanjut".

### C-03 · Daftar 2/2 — Upload KTM · P1
- Area unggah besar dengan ilustrasi kartu + tips ("Pastikan nama & NIM terbaca jelas, tanpa pantulan cahaya").
- Pilihan: Kamera / Galeri / **"Pakai KTM contoh"** (hanya mode demo).
- Setelah memilih: preview + animasi pemindaian (M-06) "Mengecek kualitas foto…" → "Foto jelas ✓".
- Tombol "Kirim Pendaftaran".

### C-04 · Menunggu Verifikasi · P1
Ilustrasi jam pasir berdenyut (M-07), "Admin lagi mencocokkan data kamu dengan KTM. Biasanya kurang dari 1×24 jam.
Kami kabari lewat email & WhatsApp."
**Live:** saat admin menyetujui (A-03), layar ini otomatis berubah ke C-05 (M-08). Saat ditolak: tampil alasan +
tombol "Perbaiki data".

### C-05 · Akun Aktif · P1
Confetti + centang (M-08), "Akun kamu **aktif**! 🎉". Di bawahnya 2 kartu pratinjau notifikasi palsu: email & WhatsApp
("Halo Rina, akun Nitip kamu sudah aktif…"). Android: notifikasi sistem lokal juga muncul. Tombol "Mulai Jajan".

### C-06 · Beranda · P1
- Header: "Antar ke" + gedung terpilih (tap → C-10), ikon notifikasi (badge), avatar.
- Judul: "Mau **jajan** apa hari ini?"
- Search bar (filter lokal produk & kantin).
- Banner promo carousel (M-10), misal "Gratis ongkir pesanan pertama" — **hanya visual**, tidak memengaruhi harga.
- Chip kategori: Semua · Makanan · Minuman · Snack (M-11).
- "Kantin di sekitarmu" (kartu horizontal: huruf kantin, nama, jam buka, "± 5 menit").
- "Lagi populer" (grid FoodCard).
- FAB keranjang mengambang dengan badge jumlah + total singkat ("5 item · Rp35.000") (M-13).
- Bottom nav pill: Beranda · Pesanan · Notifikasi · Profil (M-12).
- Loading pertama: skeleton (M-09), lalu konten masuk bertahap.

### C-07 · Detail Kantin · P1
Header foto + nama + jam buka. Daftar menu per kategori. Tombol + di tiap item → fly-to-cart (M-14).
Item yang sudah di keranjang menampilkan stepper qty kecil.

### C-08 · Detail Produk · P2
Container transform dari FoodCard (M-15). Foto besar, nama, kantin, harga, deskripsi singkat, catatan
("Nggak pedas", "Es sedikit"), stepper qty, "Tambah ke Keranjang · Rp20.000".

### C-09 · Keranjang · P1 ⭐
- Baris dikelompokkan **per kantin** (CanteenSection), tiap baris: foto, nama, harga, stepper qty, hapus (geser).
- **Meter item 0–20** dengan penanda tier (5 | 10 | 20) dan label tier ongkir aktif (M-16).
- Ringkasan: Subtotal · Ongkir (label "6–10 item") · Biaya layanan 2% · **Total** — semua RupiahText beranimasi (M-17).
- Saat tier berubah: chip "Ongkir jadi Rp8.000 (6–10 item)" meluncur masuk (M-17).
- Menambah sampai >20: stepper bergetar + haptik + pesan (M-18).
- Tombol: "Lanjut · Rp48.800".
- Kosong: ilustrasi tas kosong + "Belum ada jajan di keranjang" + "Lihat kantin".

### C-10 · Alamat Antar · P1
Peta kampus ilustrasi (CampusMap): tap gedung → pin jatuh (M-19). Field: Lantai/Ruang ("Lt. 3, R. 305"), Patokan
("Depan lab komputer"). Riwayat alamat terakhir sebagai chip. Tombol "Pakai Alamat Ini".

### C-11 · Ringkasan Pesanan · P1
Alamat, ringkasan per kantin (bisa dilipat), rincian biaya, metode: **QRIS** (satu-satunya, dengan logo generik
"QRIS" teks — jangan pakai logo resmi). Tombol "Bayar dengan QRIS · Rp48.800".

### C-12 · QRIS · P1 ⭐
- Transisi container transform dari tombol (M-20).
- Kartu putih: nama merchant "NITIP KANTIN UNC", QR (qr_flutter dari string dummy bertanda DEMO), nominal besar,
  ID pesanan, countdown 15:00 (M-21).
- Instruksi singkat "Scan pakai m-banking / e-wallet apa saja".
- Tombol demo **"Simulasi Bayar"** → garis pemindaian melintasi QR → C-13.
- Tombol sekunder "Batalkan".

### C-13 · Pembayaran Berhasil · P1
Centang digambar + confetti + suara + haptik sukses (M-22). "Pembayaran **diterima**" + total + ID.
Otomatis lanjut ke C-14 setelah 1,5 detik (atau tap "Cari Kurir").

### C-14 · Mencari Kurir · P1 ⭐
- Radar dengan gelombang konsentris + avatar kurir kandidat mengorbit (M-23).
- Kartu status: "Menawarkan ke **Budi** ★4.9" + countdown ring di sekeliling avatar (sinkron dengan `kedaluwarsaPada`).
- Timeout/tolak: avatar memudar abu + tanda × → ring melompat ke kandidat berikutnya ("Mencari kurir lain… Sari ★4.8") (M-24).
- Diterima: avatar ke tengah, kartu berbalik menampilkan profil kurir (M-25) → C-15.
- `noCourierFound`: ilustrasi + "Kurir lagi penuh nih" + "Coba lagi".

### C-15 · Lacak Pesanan · P1 ⭐
- Atas: CampusMap mini dengan jalur animasi Kantin A → Kantin B → gedung tujuan, titik kurir bergerak (M-26).
- Kartu kurir: foto, nama, rating, NIM disamarkan, tombol **WhatsApp** & **Telepon** (url_launcher).
- StatusTimeline (M-27): Dibayar ✓ → Kurir menuju kantin → **Belanja**: sub-langkah per kantin (centang saat kurir
  mencentang di K-05) → Diantar → Sampai.
- Timer berjalan "Sudah 07:32" + estimasi "Tiba ± 12 menit".
- Ringkasan pesanan (bisa dilipat).

### C-16 · Pesanan Sampai + Rating · P1
Confetti kecil, "Selamat menikmati! 😋". Tombol "Pesanan sudah diterima". Rating 5 bintang dengan pop bertahap
(M-28), chip pujian ("Cepat", "Ramah", "Sesuai pesanan"), komentar opsional. "Kirim Penilaian" → rating kurir di data ikut berubah.

### C-17 · Riwayat & E-Receipt · P2
Tab Aktif · Selesai · Dibatalkan. E-receipt: per kantin, rincian biaya, metode QRIS, waktu tiap status.

### C-18 · Profil · P2
Data akun, status KTM (badge "Terverifikasi"), alamat tersimpan, bantuan (WhatsApp admin), keluar.

### C-19 · Notifikasi · P2
Daftar notifikasi dengan ikon status; tap → deep link.

---

## Kurir (header gelap `ink.900`)

### K-01 · Masuk Kurir · P1
Seperti C-01, wordmark "Nitip Kurir". Chip "Pakai akun demo (Sari)". Minta izin notifikasi (Android 13+).

### K-02 · Beranda Kurir · P1
- Toggle besar **Online/Offline** (M-29): saat online, latar header berdenyut halus "Menunggu pesanan…".
- Kartu saldo (tap → K-07), statistik hari ini: Pesanan · Ongkir didapat · Rating.
- Daftar "Pesanan berjalan" (jika ada).

### K-03 · Order Masuk · P1 ⭐
- Full-screen meluncur dari bawah dengan pegas (M-30), latar oranye berdenyut, suara "ding", pola getar.
- Android di background: notifikasi sistem heads-up "Pesanan baru · Rp48.000 untukmu".
- Konten: countdown ring besar (sinkron), "2 kantin · 6 item", **Belanja Rp40.000 · Ongkir Rp8.000**, tujuan
  "Gedung A · Lt. 3 R. 305", jarak ilustratif.
- Aksi: **SlideToConfirm "Geser untuk Terima"** + tombol teks "Tolak".
- Timeout → layar menutup dengan pesan "Pesanan dialihkan ke kurir lain".

### K-04 · Detail Pesanan · P1
Format persis brief:
```
Kantin A · Gorengan Bu Sri
  Pisang Goreng      2 × Rp10.000   Rp20.000
Kantin B · Kopi Pojok
  Kopi Hitam         4 × Rp5.000    Rp20.000
---------------------------------------------
Belanja Rp40.000 · Ongkir Rp8.000 · Kamu terima Rp48.000
```
Plus info customer (nama, gedung, patokan, tombol WA/Telepon).

### K-05 · Progres Antar · P1 ⭐
- Header: timer berjalan + SLA tersisa (warna berubah mendekati batas).
- Langkah 1 **Belanja**: kartu per kantin dengan checklist item (centang → coret animasi, M-31), "Siapkan uang
  Rp20.000 untuk Kantin A". Kantin selesai → kartu menyusut + centang.
- Langkah 2 **Antar**: tujuan + patokan + kontak customer.
- Langkah 3 **Serahkan**: SlideToConfirm "Geser kalau sudah diserahkan".
- Setiap aksi langsung tercermin di C-15 dan A-04/A-05.

### K-06 · Selesai · P1
Koin berhamburan + saldo bergulir dari nilai lama ke baru (M-32). "+Rp48.000" mengambang. Rincian: Belanja
Rp40.000 + Ongkir Rp8.000. Tombol "Kembali ke Beranda".

### K-07 · Saldo & Mutasi · P1
Saldo tersedia (besar), saldo ditahan (jika ada pengajuan). Daftar mutasi per hari (masuk hijau, keluar merah).
Tombol "Tukar Saldo".

### K-08 · Tukar Saldo · P1
Nominal (chip cepat: 50rb, 100rb, Semua), tujuan (GoPay/OVO/DANA/Bank/Tunai ke admin — teks saja, tanpa logo resmi),
SlideToConfirm. Lalu timeline status: Diajukan → Disetujui → Dibayar (update live dari A-07).

### K-09 · Riwayat Antar · P2
### K-10 · Profil Kurir · P2
NIM, rating + ulasan terbaru, toggle suara.

---

## Admin / Owner — "Nitip Console" (responsif; target utama web ≥1280px)

Layout web: sidebar kiri (Dashboard · Validasi · Pesanan · Kurir · Tukar Saldo · Laporan · Kantin & Menu), konten kanan.
Layar sempit: sidebar menjadi drawer.

### A-01 · Masuk Admin · P1
Form sederhana + "Pakai akun demo".

### A-02 · Dashboard · P1 ⭐
- KPI (count-up, M-33): **Transaksi hari ini** · **Pendapatan hari ini (biaya layanan 2%)** · Nilai belanja (GMV) ·
  Ongkir untuk kurir · **Pesanan belum diantar** · Kurir aktif.
- Grafik transaksi per jam (fl_chart); titik baru muncul animasi saat pesanan selesai (M-34).
- Feed aktivitas live (baris baru meluncur masuk, M-35).
- Panel "Perlu perhatian": pesanan lewat SLA (merah berdenyut) + pendaftaran pending.

### A-03 · Validasi Pendaftaran · P1 ⭐
- Kiri: daftar pending (nama, NIM, waktu).
- Kanan: **foto KTM berdampingan dengan data input**; kaca pembesar saat hover/drag di KTM (M-36). Field yang
  dicocokkan diberi checklist manual (Nama ✓, NIM ✓).
- "Setujui Akun" → kartu tergeser keluar, item berikutnya masuk (M-37); customer terkait berubah live ke C-05.
- "Tolak" → dialog alasan (pilihan: "NIM tidak sesuai KTM", "Foto buram", lainnya).

### A-04 · Monitor Pesanan · P1
Tabel: ID, customer, kantin (chip), total, kurir, status (badge warna), durasi. Filter status. Baris lewat SLA
berdenyut merah. Klik → panel detail samping dengan timeline.

### A-05 · Kurir On-Progress · P1 ⭐
Kartu per kurir yang sedang mengantar: foto, nama, pesanan, durasi berjalan (live), progres langkah.
Tombol **WhatsApp** · **Telepon** · **Batalkan Kurir** (dialog konfirmasi bernama: "Batalkan Andi dari NTP-0398?
Pesanan akan dicarikan kurir lain." + alasan) → pesanan kembali ke dispatch (terlihat di feed).

### A-06 · Detail Kurir · P1
Format persis brief:
```
NIM                                   : 2022010211
Nama Kurir                            : Sari Wulandari
Jumlah Pesanan Hari Ini               : 6
Jumlah Rupiah Pesanan                 : Rp214.000
Nominal Ongkir yang Didapat           : Rp39.000
Total Uang yang Harus Dikasih ke Kurir: Rp253.000
```
(angka dihitung dari data, contoh di atas hanya ilustrasi). Plus rating, riwayat hari ini, tombol WA/Telepon.

### A-07 · Permintaan Tukar Saldo · P2
Daftar pengajuan: Setujui → Tandai Sudah Dibayar / Tolak. Update live ke K-08.

### A-08 · Laporan Keuangan · P1
Pilih rentang (Hari ini / 7 hari / Bulan ini / kustom), ringkasan angka, tabel pratinjau.
"Unduh Excel" → tombol progress → ikon file pop + toast (M-38). Sheet: Ringkasan, Transaksi, Rekap Kurir.

### A-09 · Kantin & Menu · P2
CRUD lokal kantin dan produk (nama, harga, foto, tersedia/habis). Perubahan langsung terlihat di C-06.
