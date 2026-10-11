const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET /api/v1/members/search (FR-22: Pencarian Calon Anggota)
router.get('/search', async (req, res) => {
  try {
    const { q, keahlian, minat } = req.query;
    let query = `
      SELECT p.id_pengguna, p.nim, p.nama_pengguna, p.foto_profil,
             dd.program_studi, dd.fakultas, dd.ipk, dd.deskripsi_singkat,
             pp.preferensi_pencarian
      FROM Pengguna p
      LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
      LEFT JOIN Preferensi_Pencarian pp ON p.id_pengguna = pp.id_pengguna
      WHERE 1=1
    `;
    const params = [];

    if (q) {
      query += ` AND (p.nama_pengguna LIKE ? OR dd.program_studi LIKE ? OR p.nim LIKE ?)`;
      params.push(`%${q}%`, `%${q}%`, `%${q}%`);
    }

    const [members] = await db.query(query, params);

    // Ambil keahlian & minat per anggota untuk filter lanjutan & detail kartu
    const results = [];
    for (const member of members) {
      const [khl] = await db.query('SELECT keahlian FROM Data_Keahlian WHERE id_pengguna = ?', [member.id_pengguna]);
      const [mnt] = await db.query('SELECT minat FROM Data_Minat WHERE id_pengguna = ?', [member.id_pengguna]);
      
      const memberKeahlian = khl.map(k => k.keahlian);
      const memberMinat = mnt.map(m => m.minat);

      // Filter keahlian jika ada parameter
      if (keahlian && !memberKeahlian.some(k => k.toLowerCase().includes(keahlian.toLowerCase()))) {
        continue;
      }
      // Filter minat jika ada parameter
      if (minat && !memberMinat.some(m => m.toLowerCase().includes(minat.toLowerCase()))) {
        continue;
      }

      member.keahlian = memberKeahlian;
      member.minat = memberMinat;
      results.push(member);
    }

    return res.json({
      success: true,
      message: 'Pencarian calon anggota berhasil',
      data: results
    });
  } catch (error) {
    console.error('Error search members:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
