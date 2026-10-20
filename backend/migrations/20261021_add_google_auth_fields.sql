-- =============================================================================
-- MIGRATION: 20261021_add_google_auth_fields.sql
-- DESKRIPSI: Modifikasi tabel Pengguna untuk mendukung autentikasi Google OAuth
-- FITUR: Modul 1 - Autentikasi Mahasiswa UNAND (Google Sign-In)
-- =============================================================================

USE myteam_db;

ALTER TABLE Pengguna
    MODIFY COLUMN kata_sandi VARCHAR(255) NULL,
    ADD COLUMN email VARCHAR(150) NULL UNIQUE AFTER nama_pengguna,
    ADD COLUMN google_id VARCHAR(100) NULL UNIQUE AFTER email;
