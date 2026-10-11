const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET /api/v1/notifications (Inbox Notifikasi Universal)
router.get('/', async (req, res) => {
  try {
    const id_pengguna = req.query.id_pengguna || 'usr_fuadi_01';
    const [rows] = await db.query(
      'SELECT * FROM Notifikasi WHERE id_pengguna = ? ORDER BY waktu_notifikasi DESC',
      [id_pengguna]
    );

    return res.json({
      success: true,
      message: 'Daftar notifikasi berhasil diambil',
      data: rows
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PATCH /api/v1/notifications/:id/read (Tandai Dibaca)
router.patch('/:id/read', async (req, res) => {
  try {
    const { id } = req.params;
    await db.query('UPDATE Notifikasi SET status_dibaca = TRUE WHERE id_notifikasi = ?', [id]);
    return res.json({ success: true, message: 'Notifikasi ditandai telah dibaca.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
