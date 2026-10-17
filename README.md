# MyTeam

### Aplikasi Mobile Pencarian dan Pembentukan Tim Mahasiswa UNAND

MyTeam adalah aplikasi mobile berbasis Android yang membantu mahasiswa Universitas Andalas menemukan, membentuk, dan bergabung dengan tim untuk berbagai kegiatan seperti lomba, penelitian, proyek, dan kegiatan kampus lainnya.

Aplikasi ini membantu mahasiswa menemukan rekan yang sesuai berdasarkan minat, keahlian, pengalaman, dan kebutuhan suatu kegiatan tanpa harus bergantung pada berbagai grup atau media komunikasi.

---

## 📌 Latar Belakang

Mahasiswa yang ingin mengikuti kegiatan yang membutuhkan pembentukan tim masih mengalami kesulitan dalam menemukan tim atau anggota yang sesuai. Informasi mengenai mahasiswa yang mencari tim maupun mahasiswa yang membutuhkan anggota juga masih tersebar di berbagai grup dan media komunikasi.

MyTeam hadir sebagai wadah untuk mempermudah proses pencarian dan pembentukan tim secara lebih terstruktur.

---

## 🎯 Tujuan

MyTeam bertujuan untuk:

- Mempermudah mahasiswa menemukan tim yang sesuai dengan minat, keahlian, dan pengalaman.
- Mempermudah pembuat tim menemukan calon anggota yang sesuai dengan kebutuhan.
- Memperluas jangkauan pencarian tim dan anggota.
- Memfasilitasi proses pengajuan bergabung dan pengajuan kepada calon anggota.
- Memberikan informasi status pengajuan secara jelas melalui notifikasi.

---

## 👥 Target Pengguna

MyTeam ditujukan untuk mahasiswa aktif Universitas Andalas.

Pengguna dapat memiliki dua peran:

- **Pencari Tim** — mencari dan bergabung dengan tim yang sesuai.
- **Pencari Anggota** — membuat tim dan mencari anggota sesuai kebutuhan.

Satu mahasiswa dapat memiliki kedua peran tersebut sesuai dengan kegiatan yang diikutinya.

---

## ✨ Fitur Utama

### 1. Akun & Data Riwayat Diri

Pengguna dapat mengelola informasi diri, pendidikan, media sosial, minat, keahlian, pengalaman (beserta deskripsi pengalaman), serta informasi tim yang diikuti.

### 2. Pembentukan Tim

Pengguna dapat:

- Membuat tim.
- Mengisi informasi kegiatan.
- Menentukan kebutuhan anggota.
- Mengunggah dokumen pendukung seperti poster atau panduan.
- Melihat detail tim.
- Mengubah informasi tim.
- Menghapus tim.

### 3. Pencarian Tim & Pengajuan Bergabung

Pengguna sebagai pencari tim dapat:

- Melihat feed tim.
- Mencari tim.
- Memfilter tim berdasarkan kriteria tertentu.
- Melihat detail tim.
- Mengajukan permintaan bergabung.
- Melihat status pengajuan.

Pembuat tim dapat melihat, menerima, atau menolak pengajuan bergabung.

### 4. Pencarian Anggota & Pengajuan Anggota

Pembuat tim dapat mencari calon anggota berdasarkan:

- Nama pengguna.
- Keahlian.
- Pengalaman.
- Minat.

Pembuat tim juga dapat melihat informasi calon anggota dan mengirimkan permintaan untuk bergabung ke tim.

Calon anggota dapat menerima atau menolak permintaan tersebut.

### 5. Notifikasi

Sistem memberikan notifikasi terkait:

- Pembaruan data riwayat diri.
- Pengajuan bergabung ke tim.
- Pengajuan kepada calon anggota.
- Respons terhadap pengajuan.
- Perubahan status pengajuan.

---

## 🔄 Alur Utama (User Flow Ber-kode)

Aplikasi memiliki **4 Alur Pengguna Utama (2 Peran × 2 Arah Alur: Inbound & Outbound)**:

| Kode Alur | Nama Alur | Peran Aktor | Modul Penanggung Jawab | Deskripsi Singkat |
| :---: | :--- | :---: | :---: | :--- |
| **`UF-01`** | **Menerima Pengajuan Masuk** (*Inbound Application*) | Pembuat Tim | Modul 2, 3, 1 | Buat tim → pelamar melamar → ketua merekrut/menolak pelamar. |
| **`UF-02`** | **Mencari & Mengundang Calon Anggota** (*Outbound Invitation*) | Pembuat Tim | Modul 4, 2, 1 | Talent scouting mahasiswa → pilih tim & posisi → kirim undangan. |
| **`UF-03`** | **Mencari & Melamar ke Tim** (*Outbound Application*) | Pencari Tim | Modul 3, 2, 1 | Eksplorasi Feed tim → filter kategori/posisi → ajukan bergabung. |
| **`UF-04`** | **Menerima & Merespons Undangan** (*Inbound Invitation*) | Calon Anggota | Modul 4, 2, 1 | Notifikasi ajakan masuk → tinjau tim & posisi → terima/tolak undangan. |

```text
                               ┌──────────────┐
                               │   Open App   │
                               └──────┬───────┘
                                      │
                               ┌──────▼───────┐
                               │  Daftar/Login│ (Modul 1 - Fuadi)
                               └──────┬───────┘
                                      │
                               ┌──────▼───────┐
                               │    Beranda   │
                               └──────┬───────┘
                                      │
              ┌───────────────────────┴───────────────────────┐
              │                                               │
       ┌──────▼──────┐                                 ┌──────▼──────┐
       │ PENCARI TIM │                                 │ PEMBUAT TIM │
       └──────┬──────┘                                 └──────┬──────┘
              │                                               │
     [UF-03] Melamar ke Tim                          [UF-01] Menerima Lamaran
   (Feed -> Filter -> Apply Posisi)               (Review Profil -> Terima/Tolak)
              │                                               │
     [UF-04] Merespons Undangan                      [UF-02] Mengundang Kandidat
    (Tinjau Tim -> Validasi Kuota)               (Talent Scouting -> Kirim Undangan)
              │                                               │
              └───────────────────────┬───────────────────────┘
                                      │
                               ┌──────▼───────┐
                               │  Notifikasi  │ (Pusat Pembaruan Multi-Modul)
                               └──────────────┘
```

---

## 📚 Dokumen Spesifikasi Proyek (`docs/`)

Seluruh dokumen perancangan dan spesifikasi teknis dikelompokkan rapi di dalam folder [`docs/`](docs/):

| Dokumen | Berkas | Deskripsi |
| :--- | :--- | :--- |
| **Product Requirements Document (PRD)** | [`docs/PRD_MyTeam.md`](docs/PRD_MyTeam.md) | Spesifikasi kebutuhan fungsional (FR-01 s.d FR-25), non-fungsional, kodifikasi User Flow (UF-01 s.d UF-04), dan matriks keberhubungan antar modul. |
| **Design System Specification** | [`docs/DESIGN.md`](docs/DESIGN.md) | Panduan sistem desain *Academic Emerald Synergy*, token warna Unand Emerald, tipografi Inter, komponen UI, dan pemetaan layar antarmuka. |
| **API Specification Contract** | [`docs/api_specification_contract.md`](docs/api_specification_contract.md) | Kontrak endpoint RESTful JSON, header autentikasi JWT, payload form-data, dan traceability matriks FR ke endpoint. |
| **Database ERD & DBML** | [`docs/erd_myteam.dbml`](docs/erd_myteam.dbml) | Relasi 13 tabel basis data MySQL, spesifikasi constraint relasional cascading, dan kamus data. |
| **Skema SQL Database** | [`docs/schema_myteam.sql`](docs/schema_myteam.sql) | DDL migrasi 13 tabel database MySQL pendukung sistem. |
| **Seeder Dummy Data** | [`docs/dummy_seed_myteam.sql`](docs/dummy_seed_myteam.sql) | Data akun simulasi 4 mahasiswa pengembang dan relasi tim nyata. |

---

## 🛠️ Teknologi

| Teknologi | Keterangan |
|---|---|
| Flutter | Framework pengembangan aplikasi mobile lintas platform |
| Dart | Bahasa pemrograman aplikasi mobile |
| Android | Platform target utama (Minimum SDK 26 / Android 8.0 Oreo) |
| Node.js & Express | Backend RESTful API server |
| MySQL | Basis data relasional (13 tabel relasional) |
| Git & GitHub | Version control dan kolaborasi repository |
| Figma | Perancangan UI/UX berbasis Academic Emerald Synergy |

---

## 📱 Platform

- Android
- Minimum Android 8.0 (Oreo, API Level 26)

---

## 📂 Struktur Project

Struktur project mengikuti kaidah Clean Architecture modular Flutter:

```text
MyTeam/
├── android/             # Konfigurasi native Android
├── assets/              # Aset gambar & logo resmi (assets/images/logo-MyTeam.png)
├── backend/             # Server Node.js & Express RESTful API
│   ├── src/
│   │   ├── config/      # Konfigurasi DB & setupDb seeder
│   │   ├── middleware/  # JWT auth & error handling
│   │   └── routes/      # Endpoint per modul (auth, profile, teams, applications, members)
│   └── server.js
├── docs/                # Seluruh berkas spesifikasi, PRD, Desain, API, ERD, & laporan
│   ├── PRD_MyTeam.md
│   ├── DESIGN.md
│   ├── api_specification_contract.md
│   ├── erd_myteam.dbml
│   ├── schema_myteam.sql
│   └── dummy_seed_myteam.sql
├── lib/                 # Source code Flutter
│   ├── core/            # Theme (AppColors, AppTextStyles), network API client
│   └── features/        # Modul fitur (auth, profile, team_management, team_feed, talent_search)
├── test/                # Unit & widget testing
├── pubspec.yaml         # Dependensi Flutter
└── README.md            # Dokumentasi utama repositori
```

---

## 👨‍💻 Tim Pengembang & PIC Modul

| Nama Mahasiswa | NIM | Penanggung Jawab (PIC) | Cakupan Modul & Kebutuhan Fungsional |
|---|---|:---:|---|
| **Fuadi Dhiyaulhaq** | 2411522001 | **Modul 1** | **Pengelolaan Data Riwayat Diri (Profil) & Autentikasi**<br>Biodata akademik, kontak, IPK, keahlian, minat, pengalaman, media sosial, riwayat tim diikuti, dan autentikasi (FR-01 s.d FR-07). |
| **Nayla Puspita Sari** | 2411521007 | **Modul 2** | **Pembuatan & Pengelolaan Tim**<br>Form buat tim baru, upload poster/panduan lomba via native picker, kelola detail tim, edit, serta hapus tim (FR-08 s.d FR-12). |
| **Rafa Gian Atthari** | 2411522014 | **Modul 3** | **Pencarian Tim & Pengajuan Bergabung**<br>Feed tim/lomba terbaru, filter multi-kriteria, detail tim, form apply posisi & pesan motivasi, review pelamar, dan tracking status (FR-13 s.d FR-20). |
| **Diva Ramadhani** | 2411521017 | **Modul 4** | **Pencarian Anggota & Pengajuan Anggota**<br>Talent scouting mahasiswa berdasarkan skill/minat/nama, profil kandidat, kirim undangan bergabung ke posisi berkuota, dan respon undangan (FR-21 s.d FR-25). |

**Mata Kuliah:** Pemrograman Aplikasi Mobile (PAM)  
**Program Studi:** Sistem Informasi / Teknologi Informasi  
**Universitas:** Universitas Andalas  
**Versi Sistem:** 1.1.0

---

## 📋 Requirements

Untuk menjalankan project, pastikan telah tersedia:

- Flutter SDK
- Dart SDK
- Android Studio atau IDE yang mendukung Flutter
- Android Emulator atau perangkat Android
- Git

---

## 🚀 Cara Menjalankan Project

Clone repository:

```bash
git clone https://github.com/RafaGian3/MyTeam.git
```

Masuk ke folder project:

```bash
cd MyTeam
```

Install dependencies:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

Untuk memeriksa kode:

```bash
flutter analyze
```

---

## 📌 Scope

### In Scope

- Pengelolaan akun dan data riwayat diri.
- Pengelolaan media sosial, minat, keahlian, dan pengalaman.
- Pembuatan dan pengelolaan tim.
- Pengelolaan kebutuhan anggota dan dokumen pendukung.
- Pencarian dan penyaringan tim.
- Pencarian calon anggota.
- Pengajuan bergabung dua arah.
- Penerimaan atau penolakan pengajuan.
- Pemantauan status pengajuan.
- Notifikasi terkait aktivitas pengajuan dan perubahan status.

### Out of Scope

MyTeam tidak mencakup:

- Katalog atau daftar resmi kegiatan.
- Pendaftaran resmi ke kegiatan.
- Pengelolaan tim setelah pembentukan selesai.
- Chat atau komunikasi langsung antarmahasiswa.
- Pembayaran atau transaksi.
- Sistem rekomendasi berbasis AI/ML.
- Admin sebagai aktor utama.
- Firebase Storage.

---

## 🔐 Catatan

MyTeam dirancang sebagai aplikasi **user-to-user** tanpa admin sebagai aktor utama. Data yang ditampilkan dalam aplikasi berasal dari data yang dimasukkan oleh pengguna.

Aplikasi membutuhkan koneksi internet untuk fungsi yang memerlukan pertukaran dan pembaruan data antarpengguna.

---

## 📄 Dokumentasi

Dokumentasi lengkap mengenai kebutuhan produk, functional requirements, non-functional requirements, user flow, data requirements, scope, dan constraints tersedia pada **Product Requirements Document (PRD)**.

---

## 📚 Academic Project

Project ini dikembangkan sebagai bagian dari **Mata Kuliah Mobile Programming, Fakultas Teknologi Informasi, Universitas Andalas**.
