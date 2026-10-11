const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET /api/v1/profile/detail/:id_pengguna (FR-06 & Detail Profil Lengkap)
router.get('/detail/:id_pengguna', async (req, res) => {
  try {
    const { id_pengguna } = req.params;

    const [user] = await db.query(
      'SELECT id_pengguna, nim, nama_pengguna, foto_profil FROM Pengguna WHERE id_pengguna = ?',
      [id_pengguna]
    );

    if (user.length === 0) {
      return res.status(404).json({ success: false, message: 'Pengguna tidak ditemukan.' });
    }

    const [dataDiri] = await db.query('SELECT * FROM Data_Diri WHERE id_pengguna = ?', [id_pengguna]);
    const [pref] = await db.query('SELECT preferensi_pencarian FROM Preferensi_Pencarian WHERE id_pengguna = ?', [id_pengguna]);
    const [medsos] = await db.query('SELECT id_media_sosial, nama_media_sosial, link_media_sosial FROM Media_Sosial WHERE id_pengguna = ?', [id_pengguna]);
    const [minat] = await db.query('SELECT id_minat, minat, deskripsi_minat FROM Data_Minat WHERE id_pengguna = ?', [id_pengguna]);
    const [keahlian] = await db.query('SELECT id_keahlian, keahlian, deskripsi_keahlian FROM Data_Keahlian WHERE id_pengguna = ?', [id_pengguna]);
    const [pengalaman] = await db.query('SELECT id_pengalaman, nama_kegiatan, peran, tahun, deskripsi_pengalaman FROM Data_Pengalaman WHERE id_pengguna = ?', [id_pengguna]);
    
    // Tim yang diikuti (FR-06)
    const [tim] = await db.query(`
      SELECT at.id_anggota_tim, dt.id_tim, dt.nama_tim, dt.nama_kegiatan, dt.kategori_kegiatan, at.posisi
      FROM Anggota_Tim at
      JOIN Data_Tim dt ON at.id_tim = dt.id_tim
      WHERE at.id_pengguna = ?
    `, [id_pengguna]);

    return res.status(200).json({
      success: true,
      message: 'Detail profil pengguna berhasil diambil',
      data: {
        pengguna: user[0],
        data_diri: dataDiri[0] || null,
        preferensi_pencarian: pref[0]?.preferensi_pencarian || 'keduanya',
        media_sosial: medsos,
        minat,
        keahlian,
        pengalaman,
        tim_yang_diikuti: tim
      }
    });
  } catch (error) {
    console.error('Error profile detail:', error);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server.' });
  }
});

// GET /api/v1/profile/pengalaman (FR-05)
router.get('/pengalaman', async (req, res) => {
  try {
    const id_pengguna = req.query.id_pengguna || 'usr_fuadi_01';
    const [rows] = await db.query('SELECT * FROM Data_Pengalaman WHERE id_pengguna = ?', [id_pengguna]);
    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// POST /api/v1/profile/pengalaman (FR-05)
router.post('/pengalaman', async (req, res) => {
  try {
    const { id_pengguna, nama_kegiatan, peran, tahun, deskripsi_pengalaman } = req.body;
    const id_pengalaman = `exp_${Date.now()}`;

    await db.query(
      'INSERT INTO Data_Pengalaman (id_pengalaman, id_pengguna, nama_kegiatan, peran, tahun, deskripsi_pengalaman) VALUES (?, ?, ?, ?, ?, ?)',
      [id_pengalaman, id_pengguna, nama_kegiatan, peran, tahun, deskripsi_pengalaman]
    );

    // Auto-event notifikasi (FR-08 - Modul 1 Fuadi)
    await db.query(
      'INSERT INTO Notifikasi (id_notifikasi, id_pengguna, jenis_notifikasi, pesan_notifikasi) VALUES (?, ?, ?, ?)',
      [`notif_${Date.now()}`, id_pengguna, 'aktivitas_profil', `Riwayat pengalaman "${nama_kegiatan}" berhasil ditambahkan.`]
    );

    return res.status(201).json({
      success: true,
      message: 'Riwayat pengalaman berhasil ditambahkan',
      data: { id_pengalaman, nama_kegiatan, peran, tahun, deskripsi_pengalaman }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
