# MOTION — Katalog Animasi

Animasi di sini adalah **alat jual**: tiap momen penting di naskah demo punya satu animasi "signature" supaya
penonton ingat. Sisanya halus dan cepat, jangan sampai mengganggu.

---

## 1. Prinsip & token

- **Bermakna:** animasi menjelaskan sebab-akibat (item terbang ke keranjang → keranjang bertambah). Bukan hiasan acak.
- **Cepat untuk UI, panjang hanya untuk signature.** Interaksi biasa 150–300 ms; signature 600–1500 ms, maksimal satu per layar.
- **Satu bahasa gerak:** kurva dan durasi pakai token di bawah, jangan angka acak.
- **Reduce motion:** jika `MediaQuery.disableAnimations` aktif → ganti dengan fade 150 ms; confetti, radar, dan parallax dimatikan.
- **Performa:** animasi kontinu (radar, ring, peta) dibungkus `RepaintBoundary`; controller selalu di-dispose; hindari
  `BackdropFilter` di area besar; uji di mode profile Android.

| Token | Nilai |
|---|---|
| `dur.fast` | 150 ms |
| `dur.base` | 250 ms |
| `dur.slow` | 400 ms |
| `dur.signature` | 600–1500 ms |
| `stagger` | 40 ms per item (maks 8 item, sisanya langsung muncul) |
| `curve.standard` | easeOutCubic |
| `curve.emphasized` | easeInOutCubicEmphasized (Material 3) |
| `curve.pop` | easeOutBack — **hanya** untuk pop kecil (badge, bintang, centang) |
| `spring.sheet` | pegas teredam (damping ratio ±0.8) untuk sheet & kartu yang meluncur |

**Transisi antar layar default:** Shared Axis horizontal (package `animations`) untuk alur bertahap
(daftar, checkout); Fade Through untuk ganti tab; Container Transform untuk kartu → detail.

---

## 2. Katalog

Prioritas: **P1** wajib (bagian dari naskah demo), **P2** jika waktu cukup.
Petunjuk implementasi hanya saran; pelaksana boleh memilih cara lain yang hasilnya sama.

| ID | Di mana | Apa yang terjadi | Durasi / kurva | Petunjuk implementasi | Prio |
|---|---|---|---|---|---|
| M-01 | S-01 Splash | Garis tas digambar → pegangan "n" memantul → gelembung chat pop → wordmark muncul per huruf → logo mengecil dan berpindah ke posisi di S-02 | 1400 ms total | Path metrics untuk path draw; flutter_animate untuk stagger huruf; Hero ke S-02 | P1 |
| M-02 | S-02 | Kartu peran masuk bertahap dari bawah (fade + slide 16 px) | 250 ms, stagger 60 ms | flutter_animate | P1 |
| M-03 | S-02 → app | Kartu terpilih membesar memenuhi layar menjadi layar pertama peran | 450 ms emphasized | `OpenContainer` (animations) | P1 |
| M-04 | S-03 | Indikator titik melebar jadi pill; ilustrasi parallax mengikuti geser | ikut gestur | PageController offset | P2 |
| M-05 | C-02/C-03 | Progress bar langkah terisi | 300 ms standard | TweenAnimationBuilder | P1 |
| M-06 | C-03 | Garis pemindaian oranye menyapu preview KTM 2×, sudut kartu menyala, lalu centang | 1600 ms | CustomPainter + controller | P1 |
| M-07 | C-04 | Jam pasir berdenyut pelan + titik "…" bergantian | loop 1600 ms | flutter_animate loop | P1 |
| M-08 | C-04 → C-05 | Saat admin menyetujui (live): ilustrasi berubah jadi centang besar, confetti meledak dari tengah, judul berganti | 1200 ms | AnimatedSwitcher + confetti | P1 |
| M-09 | Semua daftar | Skeleton shimmer saat loading, lalu konten masuk bertahap | shimmer 1200 ms loop | flutter_animate shimmer | P1 |
| M-10 | C-06 | Banner carousel auto-geser 4 detik, foto bergeser lebih lambat dari kartu (parallax) | 500 ms | PageView + transform | P2 |
| M-11 | C-06 | Indikator pill oranye meluncur ke chip kategori terpilih; grid di bawah fade through | 300 ms emphasized | AnimatedPositioned / layout measure | P1 |
| M-12 | Bottom nav | Blob oranye meluncur ke tab aktif, ikon sedikit membesar | 300 ms spring | Custom | P1 |
| M-13 | C-06 FAB keranjang | Badge memantul saat bertambah; teks total bergulir | 300 ms pop | Odometer | P1 |
| M-14 | C-07/C-06 | **Fly-to-cart:** thumbnail produk melayang melengkung (bezier) ke FAB keranjang, mengecil, FAB "menelan" + badge pop + haptik ringan | 650 ms | Overlay + bezier tween | **P1 ⭐** |
| M-15 | FoodCard → C-08 | Container transform kartu → detail | 450 ms | OpenContainer | P2 |
| M-16 | C-09 | Meter item 0–20 terisi; saat melewati 5 atau 10 penanda tier menyala dan berdenyut sekali | 300 ms | Custom painter | P1 |
| M-17 | C-09 | **Odometer rupiah:** angka subtotal/ongkir/fee/total bergulir per digit; saat tier berubah chip "Ongkir jadi Rp8.000" meluncur dari kanan dan menghilang 2,5 detik | digit 350 ms | Widget odometer (tabular figures) | **P1 ⭐** |
| M-18 | C-09 | Melebihi 20: stepper bergetar horizontal 3×, meter berkedip merah, haptik berat | 400 ms | flutter_animate shake | P1 |
| M-19 | C-10 | Pin jatuh ke gedung + bayangan memantul; gedung terpilih terangkat | 450 ms pop | CustomPainter + tween | P1 |
| M-20 | C-11 → C-12 | Tombol bayar membesar menjadi kartu QRIS | 450 ms emphasized | OpenContainer | P1 |
| M-21 | C-12 | Modul QR muncul dari tengah ke luar (reveal radial); countdown berjalan | 700 ms | ShaderMask / clip radial | P1 |
| M-22 | C-13 | Lingkaran digambar → centang digambar → confetti → suara "cha-ching" + haptik sukses | 1200 ms | Path draw + confetti | **P1 ⭐** |
| M-23 | C-14 | **Radar:** sapuan berputar + gelombang konsentris; avatar kandidat mengorbit perlahan | loop 2400 ms | CustomPainter + RepaintBoundary | **P1 ⭐** |
| M-24 | C-14 | Tawaran habis: avatar memudar abu + × kecil; ring countdown "melompat" (pegas) ke avatar berikutnya; teks status berganti dengan slide vertikal | 600 ms | Tween posisi + AnimatedSwitcher | **P1 ⭐** |
| M-25 | C-14 → C-15 | Kurir menerima: avatar ke tengah membesar, kartu berbalik (flip 3D) menampilkan profil kurir | 700 ms | Transform rotateY | P1 |
| M-26 | C-15 | **Peta kampus:** jalur digambar putus-putus Kantin A → B → tujuan; titik kurir bergerak mengikuti progres sungguhan (bukan loop palsu); pin kantin berubah centang saat selesai | pergerakan halus 800 ms per update | CustomPainter + path metrics | **P1 ⭐** |
| M-27 | C-15 | Timeline: garis progres terisi ke langkah baru, langkah aktif berdenyut, sub-langkah per kantin dicentang | 400 ms | Custom | P1 |
| M-28 | C-16 | Bintang pop bertahap saat dipilih; emoji reaksi berubah sesuai nilai (😐 → 😋) | 200 ms stagger 50 ms | flutter_animate | P1 |
| M-29 | K-02 | Toggle online: kenop meluncur, header berubah dari abu ke "hidup" dengan gelombang denyut halus | 400 ms + loop | Custom | P1 |
| M-30 | K-03 | **Order masuk:** sheet full-screen meluncur dengan pegas, latar oranye berdenyut, ring countdown besar mengosong dan berubah warna (hijau → kuning → merah), 5 detik terakhir ring bergetar + bunyi tik | pegas + loop | Spring simulation | **P1 ⭐** |
| M-31 | K-05 | Centang item: kotak terisi, teks tercoret dengan garis yang ditarik; kantin selesai → kartu menyusut + centang besar | 300 ms | Custom painter coret | P1 |
| M-32 | K-06 | **Saldo naik:** koin berhamburan dari tombol ke kartu saldo, saldo bergulir dari lama ke baru, "+Rp48.000" mengambang lalu menghilang, suara koin | 1400 ms | Particle sederhana + odometer | **P1 ⭐** |
| M-33 | A-02 | KPI count-up saat dibuka; saat berubah live, angka bergulir + delta "+1" hijau mengambang | 800 ms | Odometer | P1 |
| M-34 | A-02 | Titik baru di grafik muncul dengan pop, garis memanjang | 500 ms | fl_chart animasi bawaan | P1 |
| M-35 | A-02 | Baris feed aktivitas baru meluncur dari atas, baris lama turun | 300 ms | AnimatedList | P1 |
| M-36 | A-03 | Kaca pembesar bulat mengikuti kursor/jari di foto KTM (zoom 2.5×) | real-time | Transform + clip | P1 |
| M-37 | A-03 | Setujui: kartu tergeser ke kanan + memudar, stempel "DISETUJUI" hijau sekilas; item berikutnya masuk | 500 ms | Dismissible-like custom | P1 |
| M-38 | A-08 | Tombol unduh: progress terisi → berubah jadi ikon file yang pop → toast | 900 ms | AnimatedContainer | P1 |
| M-39 | Mode Panggung | **Spotlight:** bingkai HP yang menerima event bersinar oranye lembut + label kecil di atasnya, memudar 3 detik | 300 ms in, 3 s hold | Glow BoxShadow beranimasi | **P1 ⭐** |
| M-40 | Global | Banner notifikasi in-app meluncur dari atas (gaya heads-up), bisa di-swipe | 350 ms spring | Overlay | P1 |

---

## 3. Suara & haptik

**SFX** dibuat sendiri lewat `tool/gen_sfx.py` (sintesis gelombang sinus + envelope, ekspor WAV pendek ≤ 1 detik):

| File | Karakter | Dipakai di |
|---|---|---|
| `order_ding.wav` | dua nada naik, cerah | K-03 order masuk |
| `success_chime.wav` | tiga nada arpeggio mayor | C-13, C-05 |
| `coin.wav` | nada tinggi pendek dengan sedikit "kilau" | K-06 |
| `tick.wav` | klik lembut | 5 detik terakhir countdown K-03 |
| `pop.wav` | pop sangat pendek | fly-to-cart masuk keranjang |

Volume default sedang; bisa dimatikan di Panel Demo.

**Haptik:** `selectionClick` (chip, stepper) · `lightImpact` (tambah ke keranjang) · `mediumImpact` (terima order,
geser konfirmasi) · `heavyImpact` (batas 20 item, error) · pola getar (order masuk).

---

## 4. Checklist WOW (wajib lulus sebelum Fase 9)

- [ ] Splash logo (M-01) mulus dan berpindah ke role picker tanpa kedip.
- [ ] Fly-to-cart (M-14) terasa "memuaskan" dan badge selalu sinkron dengan jumlah sebenarnya.
- [ ] Odometer (M-17) tidak bergoyang lebar (tabular figures) dan angkanya selalu benar menurut §6.1.
- [ ] Radar + perpindahan kurir (M-23, M-24) terbaca jelas oleh penonton dari jarak 3 meter (layar proyektor).
- [ ] Order masuk kurir (M-30) + suara + getar terasa seperti panggilan masuk.
- [ ] Peta kampus (M-26) bergerak mengikuti aksi kurir sungguhan di K-05.
- [ ] Saldo naik (M-32) menampilkan nilai lama → baru yang benar.
- [ ] Mode Panggung: aksi di satu panel → panel lain bereaksi < 300 ms + spotlight (M-39).
- [ ] Reduce motion: semua alur tetap jalan, animasi besar diganti fade.
- [ ] Mode profile Android: tidak ada frame > 16 ms yang terasa saat M-14, M-23, M-30.
