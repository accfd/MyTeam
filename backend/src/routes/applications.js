const express = require('express');
const router = express.Router();
const db = require('../config/db');

// POST /api/v1/applications/join-team (FR-17: Lamar Tim dengan Posisi)
router.post('/join-team', async (req, res) => {
  try {
    const { id_tim, id_pengguna, posisi, pesan_pengajuan } = req.body;

    if (!id_tim || !id_pengguna || !posisi || !pesan_pengajuan) {
      return res.status(422).json({
        success: false,
        message: 'id_tim, id_pengguna, posisi, dan pesan_pengajuan wajib diisi.'
      });
    }

    const id_pbg = `pbg_${Date.now()}`;
    await db.query(
      'INSERT INTO Pengajuan_Bergabung_Tim (id_pengajuan_bergabung_tim, id_tim, id_pengguna, posisi, pesan_pengajuan, status_pengajuan) VALUES (?, ?, ?, ?, ?, ?)',
      [id_pbg, id_tim, id_pengguna, posisi, pesan_pengajuan, 'menunggu']
    );

    // Ambil pembuat tim untuk dikirimi notifikasi (FR-13 - Modul 2 Rafa)
    const [team] = await db.query('SELECT id_pengguna, nama_tim FROM Data_Tim WHERE id_tim = ?', [id_tim]);
    if (team.length > 0) {
      const idPembuat = team[0].id_pengguna;
      await db.query(
        'INSERT INTO Notifikasi (id_notifikasi, id_pengguna, id_pengajuan_bergabung_tim, jenis_notifikasi, pesan_notifikasi) VALUES (?, ?, ?, ?, ?)',
        [`notif_${Date.now()}`, idPembuat, id_pbg, 'pengajuan_masuk', `Ada pengajuan bergabung baru untuk posisi ${posisi} pada tim "${team[0].nama_tim}".`]
      );
    }

    return res.status(201).json({
      success: true,
      message: 'Pengajuan bergabung berhasil dikirim',
      data: {
        id_pengajuan_bergabung_tim: id_pbg,
        id_tim,
        posisi,
        status_pengajuan: 'menunggu'
      }
    });
  } catch (error) {
    console.error('Error apply team:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/applications/my-applications (FR-21: Riwayat Pengajuan Saya)
router.get('/my-applications', async (req, res) => {
  try {
    const id_pengguna = req.query.id_pengguna || 'usr_fuadi_01';
    const [rows] = await db.query(`
      SELECT pbt.*, dt.nama_tim, dt.nama_kegiatan, dt.kategori_kegiatan
      FROM Pengajuan_Bergabung_Tim pbt
      JOIN Data_Tim dt ON pbt.id_tim = dt.id_tim
      WHERE pbt.id_pengguna = ?
      ORDER BY pbt.waktu_pengajuan DESC
    `, [id_pengguna]);

    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
