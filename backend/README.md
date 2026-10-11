# MyTeam Backend API Server 🚀

Server Backend resmi untuk aplikasi mobile **MyTeam – Universitas Andalas**, dibangun menggunakan **Node.js + Express.js** dan terhubung ke database **MySQL (`myteam_db`)** di phpMyAdmin.

---

## 🛠️ Prasyarat
1. **Node.js** (v18 ke atas) sudah terpasang di laptop.
2. **XAMPP / Laragon** sudah menyala (modul Apache & MySQL aktif).

---

## ⚡ Panduan Cepat Menjalankan Backend & Setup Database Otomatis

Cukup jalankan 5 langkah simpel berikut lewat terminal:

1. Pastikan modul **Apache** dan **MySQL** di aplikasi XAMPP/Laragon sudah berstatus **Start**.
2. Buka terminal dan masuk ke folder `backend` dengan mengetik: `cd backend`.
3. Pasang dependensi package (cukup sekali di awal): `npm install`.
4. Jalankan perintah impor database otomatis: `npm run db:setup` (perintah ini akan otomatis membuat database `myteam_db`, 14 tabel, dan mengisi data dummy 4 anggota tim tanpa perlu membuka phpMyAdmin).
5. Jalankan server backend: `npm start` (server akan aktif di port 8000 dan siap melayani login aplikasi Flutter).

---

## 📱 Uji Coba Login dari Flutter

1. Pada kode proyek Flutter, pastikan URL API sudah mengarah ke `http://10.0.2.2:8000/api/v1` (untuk Android Emulator) atau `http://localhost:8000/api/v1` (untuk Chrome).
2. Jalankan aplikasi Flutter (`flutter run`).
3. Lakukan uji coba login menggunakan akun mahasiswa yang sudah terisi di database:
   - **NIM:** `2411522001` (Fuadi) / `2411522014` (Rafa) / `2411521017` (Diva) / `2411521007` (Nayla)
   - **Kata Sandi:** `SandiAman123!`

---

## 📡 Daftar Endpoint Utama

| Modul | Method | Endpoint | Deskripsi |
| :--- | :---: | :--- | :--- |
| **Auth** | `POST` | `/api/v1/auth/login` | Login menggunakan NIM & Password |
| **Auth** | `POST` | `/api/v1/auth/register` | Pendaftaran akun mahasiswa baru |
| **Profil (M1)** | `GET` | `/api/v1/profile/detail/:id` | Mengambil detail profil lengkap & tim yang diikuti |
| **Profil (M1)** | `POST` | `/api/v1/profile/pengalaman` | Menambah riwayat pengalaman (FR-05) |
| **Tim (M2)** | `GET` | `/api/v1/teams/my-teams` | Melihat daftar tim yang dibuat pengguna |
| **Tim (M3)** | `GET` | `/api/v1/teams/feed` | Melihat feed tim terbaru & filter pencarian |
| **Lamaran (M3)**| `POST`| `/api/v1/applications/join-team` | Mengajukan lamaran bergabung ke tim (FR-17) |
| **Notif (M4)** | `GET` | `/api/v1/notifications` | Mengambil riwayat notifikasi pengguna |
