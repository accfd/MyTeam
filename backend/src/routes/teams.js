const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET /api/v1/teams/feed (FR-14, FR-15: Feed & Filter Tim)
router.get('/feed', async (req, res) => {
  try {
    const { search, kategori, keahlian } = req.query;
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

    // Ambil kebutuhan posisi & dokumen per tim
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

// GET /api/v1/teams/feed/:id_tim (FR-16: Detail Tim dari Feed)
router.get('/feed/:id_tim', async (req, res) => {
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

// GET /api/v1/teams/my-teams (FR-10: Daftar Tim Saya)
router.get('/my-teams', async (req, res) => {
  try {
    const id_pengguna = req.query.id_pengguna || 'usr_rafa_02';
    const [rows] = await db.query('SELECT * FROM Data_Tim WHERE id_pengguna = ?', [id_pengguna]);
    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// POST /api/v1/teams (FR-09: Buat Tim Baru)
router.post('/', async (req, res) => {
  try {
    const { id_pengguna, nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi, kebutuhan } = req.body;
    const id_tim = `tim_${Date.now()}`;

    await db.query(
      'INSERT INTO Data_Tim (id_tim, id_pengguna, nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi, status_tim) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id_tim, id_pengguna, nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi, 'terbuka']
    );

    // Masukkan kebutuhan tim jika ada
    if (Array.isArray(kebutuhan)) {
      for (const item of kebutuhan) {
        await db.query(
          'INSERT INTO Kebutuhan_Anggota_Tim (id_kebutuhan, id_tim, posisi_dibutuhkan, keahlian_dibutuhkan, jumlah_anggota_dibutuhkan) VALUES (?, ?, ?, ?, ?)',
          [`keb_${Date.now()}_${Math.random().toString(36).substr(2, 4)}`, id_tim, item.posisi_dibutuhkan, item.keahlian_dibutuhkan, item.jumlah_anggota_dibutuhkan || 1]
        );
      }
    }

    return res.status(201).json({
      success: true,
      message: 'Tim berhasil dibuat',
      data: { id_tim, nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi }
    });
  } catch (error) {
    console.error('Error create team:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/teams/:id_tim/applications (FR-18: Pelamar Masuk ke Tim)
router.get('/:id_tim/applications', async (req, res) => {
  try {
    const { id_tim } = req.params;
    const [rows] = await db.query(`
      SELECT pbt.*, p.nama_pengguna, p.nim, p.foto_profil
      FROM Pengajuan_Bergabung_Tim pbt
      JOIN Pengguna p ON pbt.id_pengguna = p.id_pengguna
      WHERE pbt.id_tim = ?
      ORDER BY pbt.waktu_pengajuan DESC
    `, [id_tim]);

    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/teams/:id_tim (FR-10: Detail Tim)
router.get('/:id_tim', async (req, res) => {
  try {
    const { id_tim } = req.params;
    const [teams] = await db.query('SELECT * FROM Data_Tim WHERE id_tim = ?', [id_tim]);
    if (teams.length === 0) return res.status(404).json({ success: false, message: 'Tim tidak ditemukan' });
    return res.json({ success: true, data: teams[0] });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PUT /api/v1/teams/:id_tim (FR-11: Ubah Tim)
router.put('/:id_tim', async (req, res) => {
  try {
    const { id_tim } = req.params;
    const { nama_tim, nama_kegiatan, deskripsi, status_tim } = req.body;
    await db.query(
      'UPDATE Data_Tim SET nama_tim = ?, nama_kegiatan = ?, deskripsi = ?, status_tim = ? WHERE id_tim = ?',
      [nama_tim, nama_kegiatan, deskripsi, status_tim || 'terbuka', id_tim]
    );
    return res.json({ success: true, message: 'Data tim berhasil diperbarui' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// DELETE /api/v1/teams/:id_tim (FR-12: Hapus Tim)
router.delete('/:id_tim', async (req, res) => {
  try {
    const { id_tim } = req.params;
    await db.query('DELETE FROM Data_Tim WHERE id_tim = ?', [id_tim]);
    return res.json({ success: true, message: 'Tim berhasil dihapus dari sistem.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
