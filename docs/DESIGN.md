# DESIGN — Brand & Design System "Nitip"

Arah visual: **pola layar dari Ref 2 (Insightlancer), rasa visual dari Ref 1 (Cravk).** Hanya inspirasi —
jangan menyalin aset, logo, foto, atau layout 1:1.

- Ref 1: https://www.behance.net/gallery/240998287/Food-Ordering-Mobile-App-UIUX-Case-Study
- Ref 2: https://www.behance.net/gallery/246669901/Food-Delivery-App-UIUX-Design-Food-Ordering-App-UI

Yang diambil: latar putih/abu hangat yang lapang, foto makanan besar, CTA pill hitam, bottom nav pill mengambang,
aksen oranye, kartu bersudut besar, judul tebal dengan kata kunci ditebalkan ("Mau **jajan** apa hari ini?").

---

## 1. Brand

### Nama
**Nitip** — dari budaya kampus "nitip dong", yaitu minta tolong teman yang mau ke kantin untuk dibelikan jajan.
Aplikasi ini memformalkan kebiasaan itu: kurirnya sesama mahasiswa.

| Aplikasi | Nama tampil | Tagline |
|---|---|---|
| Customer | **Nitip** | "Kuliah jalan, jajan datang." |
| Kurir | **Nitip Kurir** | "Antar jajan, tambah cuan." |
| Admin/Owner | **Nitip Console** | — |

Alternatif kalau klien tidak suka: **Jajanin**, **KantinKu**. Semua nama, tagline, dan warna brand ada di
`lib/core/brand/` supaya cukup diganti di satu tempat.

### Logo (dibuat sendiri sebagai SVG)
- **Simbol:** tas kertas belanja yang **pegangannya membentuk huruf "n"** kecil, ditambah **gelembung chat bulat**
  kecil di pojok kanan atas tas (melambangkan pesan "nitip dong"). Geometris, garis tebal seragam, sudut membulat.
- **Wordmark:** "nitip" huruf kecil, Plus Jakarta Sans ExtraBold, letter-spacing −2%. Titik huruf "i" pertama
  diganti gelembung chat oranye kecil.
- **Varian:** (a) simbol saja, (b) simbol + wordmark horizontal, (c) mono putih, (d) mono hitam.
- **Ikon launcher:**
  - Customer: latar oranye `brand.500`, simbol warna `ink.900`.
  - Kurir: latar `ink.900`, simbol oranye + 2 garis kecepatan di kiri tas.
  - Web/Console: favicon simbol oranye di latar transparan.
- **Versi animasi** (splash, lihat M-01): garis tas digambar (path draw), pegangan "n" memantul, gelembung chat muncul
  dengan pop, lalu wordmark muncul per huruf.

---

## 2. Warna

| Token | Hex | Pemakaian |
|---|---|---|
| `brand.500` | `#FF6A2B` | Isian brand: badge, chip aktif, ikon aksen, ilustrasi, progress, ring countdown |
| `brand.600` | `#E5531A` | Isian brand saat ditekan |
| `brand.50` | `#FFF1EA` | Latar lembut (kartu promo, highlight baris) |
| `brand.text` | `#C2410C` | **Teks oranye** (harga, tautan) — kontras 4.8:1 di putih |
| `ink.900` | `#14110F` | Teks utama, **CTA utama (pill hitam)**, header aplikasi kurir |
| `ink.600` | `#5F5A55` | Teks sekunder |
| `ink.400` | `#9A948E` | Teks samar, placeholder |
| `line` | `#ECE8E4` | Garis, border |
| `surface` | `#FFFFFF` | Kartu, sheet |
| `surface.alt` | `#F7F5F3` | Latar halaman |
| `success` | `#16A34A` | Berhasil, saldo masuk |
| `warning` | `#F59E0B` | Countdown hampir habis, SLA mendekati batas |
| `danger` | `#E5484D` | Telat SLA, tolak, error |
| `info` | `#2F6FEB` | Info netral |

**Aturan kontras:** teks putih **tidak boleh** di atas `brand.500` (kontras 2.9:1, gagal). Di atas oranye pakai
`ink.900`. CTA utama = pill hitam + teks putih. Teks oranye kecil pakai `brand.text`.

**Aplikasi kurir:** header/app bar `ink.900` dengan teks putih, aksen tetap oranye, badan layar terang
(supaya tetap terbaca di bawah sinar matahari).

---

## 3. Tipografi — Plus Jakarta Sans (dibundel)

| Gaya | Ukuran/Line height | Berat | Pemakaian |
|---|---|---|---|
| display | 32/38 | ExtraBold | Judul onboarding, angka besar sukses |
| h1 | 24/30 | Bold | Judul layar |
| h2 | 20/26 | Bold | Judul seksi |
| title | 16/22 | SemiBold | Judul kartu, nama produk |
| body | 14/20 | Regular | Teks umum |
| bodyStrong | 14/20 | SemiBold | Label penting |
| caption | 12/16 | Medium | Meta, badge |
| number | sesuai konteks | Bold + **tabular figures** | Semua angka rupiah & timer (supaya odometer tidak bergoyang) |

Gaya judul khas: campuran berat, misal "Mau **jajan** apa hari ini?" (kata kunci Bold `ink.900`, sisanya
Regular `ink.600`).

---

## 4. Spasi, radius, bayangan

- **Spasi:** kelipatan 4 → 4, 8, 12, 16, 20, 24, 32, 40. Gutter halaman 20.
- **Radius:** input 12 · kartu 20 · sheet & kartu besar 28 · pill 999.
- **Bayangan:** lembut dan jarang. `shadow.card` = y 4, blur 16, hitam 6%. `shadow.float` (bottom nav, FAB keranjang) = y 10, blur 30, hitam 12%.
- **Tap target:** minimal 48×48.

---

## 5. Komponen inti

| Komponen | Catatan |
|---|---|
| `PrimaryButton` | Pill hitam, tinggi 56, teks putih SemiBold; status loading (spinner → centang) |
| `SecondaryButton` | Pill border `line`, teks `ink.900` |
| `SlideToConfirm` | Pill dengan kenop yang digeser (terima order, konfirmasi tukar saldo) |
| `CategoryChips` | Indikator pill oranye yang **bergeser** ke chip terpilih |
| `QtyStepper` | − angka +; angka bergulir (odometer) |
| `RupiahText` | Format `Rp48.800`; opsi animasi count/odometer saat nilai berubah |
| `CountdownRing` | Cincin yang mengosong; warna hijau → kuning (≤50%) → merah (≤20%) |
| `FloatingPillNav` | Bottom nav mengambang hitam, item aktif = blob oranye yang meluncur |
| `FoodCard` | Foto besar, nama, kantin, harga, tombol + bulat oranye |
| `CanteenSection` | Header kantin (logo huruf + nama) + daftar item — dipakai di keranjang, detail kurir, e-receipt |
| `StatusTimeline` | Timeline vertikal; garis progres terisi; langkah aktif berdenyut |
| `CampusMap` | Peta kampus ilustrasi (CustomPainter): blok gedung, jalur, pin kantin & tujuan, titik kurir bergerak |
| `KpiCard` | Angka besar count-up + delta kecil ("+1 barusan") |
| `PhoneFrame` | Bingkai HP untuk Mode Panggung, dengan efek spotlight |
| `DemoBadge` | Pil kecil "MODE DEMO"; tekan lama → Panel Demo |
| `Skeleton` | Shimmer untuk loading |
| `AppToast/Banner` | Banner notifikasi in-app (geser dari atas) |

---

## 6. Gaya tulisan (micro-copy)

- Sapaan "kamu", singkat, hangat. Contoh: "Pesananmu lagi dibeliin Sari di Kantin A 🍌" (emoji secukupnya, maks 1 per kalimat).
- Tombol diawali kata kerja: "Bayar Rp48.800", "Terima Pesanan", "Setujui Akun", "Unduh Laporan". Hindari "OK" / "Submit".
- Pesan error menjelaskan solusinya: "Maksimal 20 item per pesanan. Kurangi dulu salah satu item ya."
