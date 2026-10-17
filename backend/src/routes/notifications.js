const express = require('express');
const router = express.Router();
const db = require('../config/db');
const requireAuth = require('../middleware/auth');

// GET /api/v1/notifications (Inbox Notifikasi Universal)
router.get('/', requireAuth, async (req, res) => {
  try {
    const id_pengguna = req.user.id_pengguna;
    const [rows] = await db.query(`
      SELECT 
        n.*,
        COALESCE(pbt.id_tim, pa.id_tim) AS id_tim,
        COALESCE(dt_pbt.nama_tim, dt_pa.nama_tim) AS nama_tim,
        COALESCE(dt_pbt.nama_kegiatan, dt_pa.nama_kegiatan) AS nama_kegiatan
      FROM Notifikasi n
      LEFT JOIN Pengajuan_Bergabung_Tim pbt ON n.id_pengajuan_bergabung_tim = pbt.id_pengajuan_bergabung_tim
      LEFT JOIN Data_Tim dt_pbt ON pbt.id_tim = dt_pbt.id_tim
      LEFT JOIN Pengajuan_Anggota pa ON n.id_pengajuan_anggota = pa.id_pengajuan_anggota
      LEFT JOIN Data_Tim dt_pa ON pa.id_tim = dt_pa.id_tim
      WHERE n.id_pengguna = ?
      ORDER BY n.waktu_notifikasi DESC
    `, [id_pengguna]);

    return res.json({
      success: true,
      message: 'Daftar notifikasi berhasil diambil',
      data: rows
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PATCH /api/v1/notifications/read-all (Tandai seluruh notifikasi dibaca)
router.patch('/read-all', requireAuth, async (req, res) => {
  try {
    const [result] = await db.query(
      'UPDATE Notifikasi SET status_dibaca = TRUE WHERE id_pengguna = ? AND status_dibaca = FALSE',
      [req.user.id_pengguna]
    );
    return res.json({
      success: true,
      message: 'Seluruh notifikasi ditandai telah dibaca.',
      data: { updated_count: result.affectedRows }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/notifications/unread-count (Hitung Belum Dibaca)
router.get('/unread-count', requireAuth, async (req, res) => {
  try {
    const id_pengguna = req.user.id_pengguna;
    const [rows] = await db.query(
      'SELECT COUNT(*) AS unread_count FROM Notifikasi WHERE id_pengguna = ? AND status_dibaca = FALSE',
      [id_pengguna]
    );
    return res.json({
      success: true,
      data: { unread_count: rows[0].unread_count }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PATCH /api/v1/notifications/:id/read (Tandai Dibaca)
router.patch('/:id/read', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await db.query(
      'UPDATE Notifikasi SET status_dibaca = TRUE WHERE id_notifikasi = ? AND id_pengguna = ?',
      [id, req.user.id_pengguna]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Notifikasi tidak ditemukan.'
      });
    }
    return res.json({ success: true, message: 'Notifikasi ditandai telah dibaca.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
