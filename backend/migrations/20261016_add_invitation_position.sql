ALTER TABLE Pengajuan_Anggota
    ADD COLUMN posisi VARCHAR(100) NOT NULL DEFAULT 'Anggota' AFTER id_pengguna;
