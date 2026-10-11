const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET /api/v1/teams/feed (FR-14, FR-15: Feed & Filter Tim)
router.get('/feed', async (req, res) => {
  try {
    const { search, kategori } = req.query;
    let query = `
      SELECT dt.*, p.nama_pengguna, p.foto_profil 
      FROM Data_Tim dt
      JOIN Pengguna p ON dt.id_pengguna = p.id_pengguna
      WHERE dt.status_tim = 'terbuka'
    `;
    const params = [];

    if (search) {
      query += ` AND (dt.nama_tim LIKE ? OR dt.nama_kegiatan LIKE ?)`;
      params.push(`%${search}%`, `%${search}%`);
    }
    if (kategori) {
      query += ` AND dt.kategori_kegiatan = ?`;
      params.push(kategori);
    }

    query += ` ORDER BY dt.created_at DESC`;

    const [teams] = await db.query(query, params);

    // Ambil kebutuhan posisi per tim
    for (const team of teams) {
      const [kebutuhan] = await db.query('SELECT * FROM Kebutuhan_Anggota_Tim WHERE id_tim = ?', [team.id_tim]);
      const [dokumen] = await db.query('SELECT * FROM Dokumen_Pendukung WHERE id_tim = ?', [team.id_tim]);
      team.kebutuhan_tim = kebutuhan;
      team.dokumen_pendukung = dokumen;
    }

    return res.json({
      success: true,
      message: 'Feed tim berhasil diambil',
      data: teams
    });
  } catch (error) {
    console.error('Error feed teams:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/teams/my-teams (FR-10: Tim Saya)
router.get('/my-teams', async (req, res) => {
  try {
    const id_pengguna = req.query.id_pengguna || 'usr_rafa_02';
    const [rows] = await db.query('SELECT * FROM Data_Tim WHERE id_pengguna = ?', [id_pengguna]);
    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/teams/:id_tim (FR-10, FR-16: Detail Tim)
router.get('/:id_tim', async (req, res) => {
  try {
    const { id_tim } = req.params;
    const [teams] = await db.query(`
      SELECT dt.*, p.nama_pengguna, p.foto_profil
      FROM Data_Tim dt
      JOIN Pengguna p ON dt.id_pengguna = p.id_pengguna
      WHERE dt.id_tim = ?
    `, [id_tim]);

    if (teams.length === 0) {
      return res.status(404).json({ success: false, message: 'Tim tidak ditemukan.' });
    }

    const team = teams[0];
    const [kebutuhan] = await db.query('SELECT * FROM Kebutuhan_Anggota_Tim WHERE id_tim = ?', [id_tim]);
    const [dokumen] = await db.query('SELECT * FROM Dokumen_Pendukung WHERE id_tim = ?', [id_tim]);
    const [anggota] = await db.query(`
      SELECT at.*, p.nama_pengguna, p.foto_profil
      FROM Anggota_Tim at
      JOIN Pengguna p ON at.id_pengguna = p.id_pengguna
      WHERE at.id_tim = ?
    `, [id_tim]);

    team.kebutuhan_tim = kebutuhan;
    team.dokumen_pendukung = dokumen;
    team.anggota_tim = anggota;

    return res.json({ success: true, data: team });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
