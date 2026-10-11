const express = require('express');
const router = express.Router();
const db = require('../config/db');

// POST /api/v1/applications/join-team (FR-16: Lamar Tim dengan Posisi Wajib)
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

    // Kirim notifikasi otomatis ke pembuat tim (FR-12 - Modul 2 Rafa)
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

// GET /api/v1/applications/join-team/:id (FR-18: Detail Pengajuan)
router.get('/join-team/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.query(`
      SELECT pbt.*, p.nama_pengguna, p.nim, p.foto_profil, dd.program_studi, dd.ipk
      FROM Pengajuan_Bergabung_Tim pbt
      JOIN Pengguna p ON pbt.id_pengguna = p.id_pengguna
      LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
      WHERE pbt.id_pengajuan_bergabung_tim = ?
    `, [id]);

    if (rows.length === 0) return res.status(404).json({ success: false, message: 'Pengajuan tidak ditemukan.' });
    return res.json({ success: true, data: rows[0] });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PATCH /api/v1/applications/join-team/:id/status (FR-19: Terima / Tolak Lamaran)
router.patch('/join-team/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status_pengajuan } = req.body; // 'diterima' | 'ditolak'

    if (!['diterima', 'ditolak'].includes(status_pengajuan)) {
      return res.status(400).json({ success: false, message: 'Status pengajuan harus "diterima" atau "ditolak".' });
    }

    const [appRows] = await db.query('SELECT * FROM Pengajuan_Bergabung_Tim WHERE id_pengajuan_bergabung_tim = ?', [id]);
    if (appRows.length === 0) return res.status(404).json({ success: false, message: 'Pengajuan tidak ditemukan.' });

    const app = appRows[0];
    await db.query('UPDATE Pengajuan_Bergabung_Tim SET status_pengajuan = ? WHERE id_pengajuan_bergabung_tim = ?', [status_pengajuan, id]);

    // Jika diterima, otomatis masukkan pelamar ke tabel Anggota_Tim
    if (status_pengajuan === 'diterima') {
      const idAnggota = `ang_${Date.now()}`;
      await db.query(`
        INSERT INTO Anggota_Tim (id_anggota_tim, id_tim, id_pengguna, posisi)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE posisi = VALUES(posisi)
      `, [idAnggota, app.id_tim, app.id_pengguna, app.posisi]);
    }

    // Ambil nama tim
    const [team] = await db.query('SELECT nama_tim FROM Data_Tim WHERE id_tim = ?', [app.id_tim]);
    const namaTim = team[0]?.nama_tim || 'Tim';

    // Kirim notifikasi hasil ke pelamar (FR-20 - Modul 3 Diva)
    const notifMsg = status_pengajuan === 'diterima'
      ? `Selamat! Pengajuan bergabung Anda untuk posisi ${app.posisi} pada "${namaTim}" telah diterima.`
      : `Mohon maaf, pengajuan bergabung Anda pada "${namaTim}" belum dapat diterima.`;

    await db.query(
      'INSERT INTO Notifikasi (id_notifikasi, id_pengguna, id_pengajuan_bergabung_tim, jenis_notifikasi, pesan_notifikasi) VALUES (?, ?, ?, ?, ?)',
      [`notif_${Date.now()}`, app.id_pengguna, id, status_pengajuan === 'diterima' ? 'pengajuan_diterima' : 'pengajuan_ditolak', notifMsg]
    );

    return res.json({
      success: true,
      message: `Pengajuan berhasil di-${status_pengajuan}.`,
      data: { id_pengajuan_bergabung_tim: id, status_pengajuan }
    });
  } catch (error) {
    console.error('Error status application:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/applications/my-applications (FR-20: Riwayat Lamaran Saya)
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

// POST /api/v1/applications/invite-member (FR-23: Ajak Calon Anggota)
router.post('/invite-member', async (req, res) => {
  try {
    const { id_tim, id_pengguna, pesan_pengajuan } = req.body;
    const id_pga = `pga_${Date.now()}`;

    await db.query(
      'INSERT INTO Pengajuan_Anggota (id_pengajuan_anggota, id_tim, id_pengguna, pesan_pengajuan, status_pengajuan) VALUES (?, ?, ?, ?, ?)',
      [id_pga, id_tim, id_pengguna, pesan_pengajuan, 'menunggu']
    );

    // Ambil info tim
    const [team] = await db.query('SELECT nama_tim FROM Data_Tim WHERE id_tim = ?', [id_tim]);
    const namaTim = team[0]?.nama_tim || 'Tim';

    // Notifikasi undangan ke calon anggota
    await db.query(
      'INSERT INTO Notifikasi (id_notifikasi, id_pengguna, id_pengajuan_anggota, jenis_notifikasi, pesan_notifikasi) VALUES (?, ?, ?, ?, ?)',
      [`notif_${Date.now()}`, id_pengguna, id_pga, 'undangan_masuk', `Anda menerima undangan untuk bergabung ke "${namaTim}".`]
    );

    return res.status(201).json({
      success: true,
      message: 'Undangan berhasil dikirim ke calon anggota',
      data: { id_pengajuan_anggota: id_pga, id_tim, id_pengguna, status_pengajuan: 'menunggu' }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/applications/received-invitations (FR-24: Undangan yang Diterima Calon Anggota)
router.get('/received-invitations', async (req, res) => {
  try {
    const id_pengguna = req.query.id_pengguna || 'usr_fuadi_01';
    const [rows] = await db.query(`
      SELECT pa.*, dt.nama_tim, dt.nama_kegiatan, dt.kategori_kegiatan, dt.deskripsi AS deskripsi_tim
      FROM Pengajuan_Anggota pa
      JOIN Data_Tim dt ON pa.id_tim = dt.id_tim
      WHERE pa.id_pengguna = ?
      ORDER BY pa.waktu_pengajuan DESC
    `, [id_pengguna]);

    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PATCH /api/v1/applications/received-invitations/:id/status (FR-24, FR-25: Respon Undangan)
router.patch('/received-invitations/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status_pengajuan } = req.body; // 'diterima' | 'ditolak'

    const [rows] = await db.query('SELECT * FROM Pengajuan_Anggota WHERE id_pengajuan_anggota = ?', [id]);
    if (rows.length === 0) return res.status(404).json({ success: false, message: 'Undangan tidak ditemukan.' });

    const inv = rows[0];
    await db.query('UPDATE Pengajuan_Anggota SET status_pengajuan = ? WHERE id_pengajuan_anggota = ?', [status_pengajuan, id]);

    // Kirim notifikasi respon ke ketua tim (FR-25 - Modul 4 Nayla)
    const [team] = await db.query('SELECT id_pengguna, nama_tim FROM Data_Tim WHERE id_tim = ?', [inv.id_tim]);
    if (team.length > 0) {
      const [calon] = await db.query('SELECT nama_pengguna FROM Pengguna WHERE id_pengguna = ?', [inv.id_pengguna]);
      const namaCalon = calon[0]?.nama_pengguna || 'Calon Anggota';
      await db.query(
        'INSERT INTO Notifikasi (id_notifikasi, id_pengguna, id_pengajuan_anggota, jenis_notifikasi, pesan_notifikasi) VALUES (?, ?, ?, ?, ?)',
        [`notif_${Date.now()}`, team[0].id_pengguna, id, 'respon_undangan', `${namaCalon} telah ${status_pengajuan} undangan bergabung ke tim "${team[0].nama_tim}".`]
      );
    }

    return res.json({ success: true, message: `Undangan berhasil di-${status_pengajuan}.` });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
