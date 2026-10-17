const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const db = require('../config/db');
const requireAuth = require('../middleware/auth');
const { getPositionCapacity } = require('../utils/kuota');

// Helper: Ekstraksi ID Pengguna dari Header Authorization JWT / Query / Body
const getAuthUserId = (req) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'myteam_secret');
      if (decoded && decoded.id_pengguna) {
        return decoded.id_pengguna;
      }
    }
  } catch (err) { }
  return req.body?.id_pengguna || req.query?.id_pengguna || req.headers['x-user-id'] || 'usr_fuadi_01';
};

// POST /api/v1/applications/join-team (FR-16: Lamar Tim dengan Posisi Wajib)
router.post('/join-team', async (req, res) => {
  let connection;
  let transactionStarted = false;
  try {
    const { id_tim, posisi, pesan_pengajuan } = req.body;
    const id_pengguna = getAuthUserId(req);

    if (!id_tim || !posisi || !pesan_pengajuan) {
      return res.status(422).json({
        success: false,
        message: 'id_tim, posisi, dan pesan_pengajuan wajib diisi.'
      });
    }

    const cleanIdTim = id_tim.toString().trim();
    const cleanPosisi = posisi.toString().trim();
    const cleanPesan = pesan_pengajuan.toString().trim();

    if (!cleanPosisi || !cleanPesan) {
      return res.status(422).json({
        success: false,
        message: 'Posisi dan pesan pengajuan tidak boleh kosong.'
      });
    }

    if (!id_pengguna) {
      return res.status(401).json({
        success: false,
        message: 'Sesi tidak valid atau pengguna belum login.'
      });
    }

    connection = await db.getConnection();
    await connection.beginTransaction();
    transactionStarted = true;

    // 1. Validasi tim: cek apakah tim ada dan berstatus terbuka
    const [teamRows] = await connection.query(
      'SELECT id_tim, id_pengguna, nama_tim, status_tim FROM Data_Tim WHERE id_tim = ? FOR UPDATE',
      [cleanIdTim]
    );

    if (teamRows.length === 0) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(404).json({
        success: false,
        message: 'Tim tidak ditemukan.'
      });
    }

    const team = teamRows[0];
    if (team.status_tim !== 'terbuka') {
      await connection.rollback();
      transactionStarted = false;
      return res.status(400).json({
        success: false,
        message: 'Pendaftaran untuk tim ini telah ditutup.'
      });
    }

    // 2. Validasi pembuat tim: pembuat tidak dapat melamar ke timnya sendiri
    if (team.id_pengguna === id_pengguna) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(403).json({
        success: false,
        message: 'Anda adalah pembuat tim ini dan tidak dapat melamar ke tim sendiri.'
      });
    }

    // 3. Validasi anggota tim: pengguna yang sudah menjadi anggota tim tidak dapat melamar lagi
    const [existingMembers] = await connection.query(
      'SELECT id_anggota_tim FROM Anggota_Tim WHERE id_tim = ? AND id_pengguna = ?',
      [cleanIdTim, id_pengguna]
    );
    if (existingMembers.length > 0) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(409).json({
        success: false,
        message: 'Anda sudah menjadi anggota tim ini.'
      });
    }

    // 4. Validasi lamaran ganda: cek apakah sudah ada pengajuan berstatus 'menunggu'
    const [pendingApps] = await connection.query(
      'SELECT id_pengajuan_bergabung_tim FROM Pengajuan_Bergabung_Tim WHERE id_tim = ? AND id_pengguna = ? AND status_pengajuan = "menunggu"',
      [cleanIdTim, id_pengguna]
    );
    if (pendingApps.length > 0) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(409).json({
        success: false,
        message: 'Anda sudah mengajukan lamaran yang sedang menunggu konfirmasi pada tim ini.'
      });
    }

    // 5. Validasi posisi sesuai kebutuhan tim
    const [kebutuhan] = await connection.query(
      'SELECT * FROM Kebutuhan_Anggota_Tim WHERE id_tim = ?',
      [cleanIdTim]
    );

    if (kebutuhan.length > 0) {
      const matchingKebutuhan = kebutuhan.find(
        k => k.posisi_dibutuhkan.trim().toLowerCase() === cleanPosisi.toLowerCase()
      );
      if (!matchingKebutuhan) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(422).json({
          success: false,
          message: `Posisi "${cleanPosisi}" tidak tersedia dalam daftar kebutuhan tim ini.`
        });
      }

      // Validasi kuota posisi jika sudah terpenuhi di Anggota_Tim
      const [[anggotaPosisi]] = await connection.query(`
        SELECT COUNT(*) AS total
        FROM Anggota_Tim
        WHERE id_tim = ? AND LOWER(TRIM(posisi)) = LOWER(TRIM(?))
      `, [cleanIdTim, matchingKebutuhan.posisi_dibutuhkan]);

      if (Number(anggotaPosisi.total) >= matchingKebutuhan.jumlah_anggota_dibutuhkan) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(409).json({
          success: false,
          message: `Kuota untuk posisi "${matchingKebutuhan.posisi_dibutuhkan}" sudah penuh.`
        });
      }
    }

    // 6. Masukkan data ke Pengajuan_Bergabung_Tim
    const id_pbg = `pbg_${Date.now()}`;
    await connection.query(
      `INSERT INTO Pengajuan_Bergabung_Tim 
       (id_pengajuan_bergabung_tim, id_tim, id_pengguna, posisi, pesan_pengajuan, status_pengajuan) 
       VALUES (?, ?, ?, ?, ?, 'menunggu')`,
      [id_pbg, cleanIdTim, id_pengguna, cleanPosisi, cleanPesan]
    );

    // 7. Ambil nama pelamar untuk notifikasi otomatis pemilik tim (FR-12)
    const [pelamarRows] = await connection.query(
      'SELECT nama_pengguna FROM Pengguna WHERE id_pengguna = ?',
      [id_pengguna]
    );
    const namaPelamar = pelamarRows[0]?.nama_pengguna || 'Seorang mahasiswa';
    const notifMsg = `${namaPelamar} mengajukan lamaran untuk posisi ${cleanPosisi} pada tim "${team.nama_tim}".`;

    await connection.query(
      `INSERT INTO Notifikasi 
       (id_notifikasi, id_pengguna, id_pengajuan_bergabung_tim, jenis_notifikasi, pesan_notifikasi) 
       VALUES (?, ?, ?, 'pengajuan_masuk', ?)`,
      [`notif_${Date.now()}`, team.id_pengguna, id_pbg, notifMsg]
    );

    await connection.commit();
    transactionStarted = false;

    return res.status(201).json({
      success: true,
      message: 'Pengajuan bergabung berhasil dikirim ke pembuat tim',
      data: {
        id_pengajuan_bergabung_tim: id_pbg,
        id_tim: cleanIdTim,
        id_pengguna,
        posisi: cleanPosisi,
        pesan_pengajuan: cleanPesan,
        waktu_pengajuan: new Date().toISOString(),
        status_pengajuan: 'menunggu'
      }
    });
  } catch (error) {
    console.error('Error apply team:', error);
    if (transactionStarted && connection) await connection.rollback();
    return res.status(500).json({ success: false, message: error.message });
  } finally {
    if (connection) connection.release();
  }
});

// GET /api/v1/applications/team/:id_tim (Alias FR-17: Pelamar Masuk ke Tim)
router.get('/team/:id_tim', async (req, res) => {
  // Redirect internal ke endpoint resmi /api/v1/teams/:id_tim/applications
  const statusQuery = req.query.status ? `?status=${encodeURIComponent(req.query.status)}` : '';
  return res.redirect(307, `/api/v1/teams/${req.params.id_tim}/applications${statusQuery}`);
});

// GET /api/v1/applications/join-team/:id (FR-18: Detail Pengajuan)
router.get('/join-team/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const authUserId = getAuthUserId(req);

    const [rows] = await db.query(`
      SELECT 
        pbt.id_pengajuan_bergabung_tim,
        pbt.id_tim,
        pbt.id_pengguna,
        pbt.posisi,
        pbt.pesan_pengajuan,
        pbt.waktu_pengajuan,
        pbt.status_pengajuan,
        dt.id_pengguna AS id_pemilik_tim,
        dt.nama_tim, 
        dt.nama_kegiatan, 
        dt.kategori_kegiatan, 
        dt.deskripsi AS deskripsi_tim,
        dt.status_tim,
        p.nama_pengguna, 
        p.nim, 
        p.foto_profil, 
        dd.deskripsi_singkat,
        dd.program_studi, 
        dd.fakultas, 
        dd.ipk, 
        dd.kontak
      FROM Pengajuan_Bergabung_Tim pbt
      JOIN Data_Tim dt ON pbt.id_tim = dt.id_tim
      JOIN Pengguna p ON pbt.id_pengguna = p.id_pengguna
      LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
      WHERE pbt.id_pengajuan_bergabung_tim = ?
    `, [id]);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Pengajuan tidak ditemukan.' });
    }

    const app = rows[0];

    // Otorisasi: Verifikasi bahwa pemanggil adalah pembuat tim dari tim yang dilamar (atau pelamar itu sendiri)
    if (authUserId && app.id_pemilik_tim !== authUserId && app.id_pengguna !== authUserId) {
      return res.status(403).json({
        success: false,
        message: 'Akses ditolak. Hanya pembuat tim yang dapat mengakses rincian pengajuan ini.'
      });
    }

    const pelamarId = app.id_pengguna;

    // Agregasi rekam jejak & portofolio akademik pelamar (Modul 1)
    const [medsos] = await db.query(
      'SELECT id_media_sosial, nama_media_sosial, link_media_sosial FROM Media_Sosial WHERE id_pengguna = ? ORDER BY created_at ASC',
      [pelamarId]
    );

    const [keahlian] = await db.query(
      'SELECT id_keahlian, keahlian, deskripsi_keahlian FROM Data_Keahlian WHERE id_pengguna = ? ORDER BY created_at ASC',
      [pelamarId]
    );

    const [minat] = await db.query(
      'SELECT id_minat, minat, deskripsi_minat FROM Data_Minat WHERE id_pengguna = ? ORDER BY created_at ASC',
      [pelamarId]
    );

    const [pengalaman] = await db.query(
      'SELECT id_pengalaman, nama_kegiatan, peran, tahun, deskripsi_pengalaman FROM Data_Pengalaman WHERE id_pengguna = ? ORDER BY tahun DESC, created_at DESC',
      [pelamarId]
    );

    const detailData = {
      ...app,
      media_sosial: medsos,
      keahlian: keahlian,
      minat: minat,
      pengalaman: pengalaman,
      pelamar: {
        pengguna: {
          id_pengguna: app.id_pengguna,
          nim: app.nim,
          nama_pengguna: app.nama_pengguna,
          foto_profil: app.foto_profil,
        },
        data_diri: {
          id_pengguna: app.id_pengguna,
          deskripsi_singkat: app.deskripsi_singkat,
          kontak: app.kontak,
          program_studi: app.program_studi,
          fakultas: app.fakultas,
          ipk: app.ipk,
        },
        media_sosial: medsos,
        keahlian: keahlian,
        minat: minat,
        pengalaman: pengalaman,
      }
    };

    return res.json({
      success: true,
      message: 'Detail pengajuan bergabung berhasil diambil',
      data: detailData
    });
  } catch (error) {
    console.error('Error join-team detail:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PATCH /api/v1/applications/join-team/:id/status (FR-19: Terima / Tolak Lamaran)
router.patch('/join-team/:id/status', async (req, res) => {
  let connection;
  let transactionStarted = false;
  try {
    const { id } = req.params;
    const { status_pengajuan } = req.body; // 'diterima' | 'ditolak'
    const authUserId = getAuthUserId(req);

    if (!['diterima', 'ditolak'].includes(status_pengajuan)) {
      return res.status(400).json({
        success: false,
        message: 'Status pengajuan harus "diterima" atau "ditolak".'
      });
    }

    connection = await db.getConnection();
    await connection.beginTransaction();
    transactionStarted = true;

    // 1. Kunci dan ambil baris pengajuan bergabung beserta data tim (NFR-07: ACID Transaction)
    const [appRows] = await connection.query(`
      SELECT 
        pbt.*, 
        dt.id_pengguna AS id_pemilik_tim, 
        dt.nama_tim, 
        dt.nama_kegiatan, 
        dt.status_tim
      FROM Pengajuan_Bergabung_Tim pbt
      JOIN Data_Tim dt ON pbt.id_tim = dt.id_tim
      WHERE pbt.id_pengajuan_bergabung_tim = ?
      FOR UPDATE
    `, [id]);

    if (appRows.length === 0) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(404).json({ success: false, message: 'Pengajuan tidak ditemukan.' });
    }

    const app = appRows[0];

    // Otorisasi: Verifikasi pemilik tim yang berhak mengambil keputusan
    if (authUserId && app.id_pemilik_tim !== authUserId) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(403).json({
        success: false,
        message: 'Akses ditolak. Hanya pembuat tim yang berhak mengambil keputusan pengajuan ini.'
      });
    }

    // 2. Validasi status pengajuan saat ini harus 'menunggu'
    if (app.status_pengajuan !== 'menunggu') {
      await connection.rollback();
      transactionStarted = false;
      return res.status(409).json({
        success: false,
        message: `Pengajuan ini sudah pernah diputuskan sebelumnya dan berstatus "${app.status_pengajuan}".`
      });
    }

    // 3. Jika keputusan adalah 'diterima':
    if (status_pengajuan === 'diterima') {
      // 3a. Cek apakah pelamar sudah terdaftar dalam Anggota_Tim pada tim ini
      const [existingMember] = await connection.query(
        'SELECT id_anggota_tim FROM Anggota_Tim WHERE id_tim = ? AND id_pengguna = ? FOR UPDATE',
        [app.id_tim, app.id_pengguna]
      );

      if (existingMember.length > 0) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(409).json({
          success: false,
          message: 'Pelamar sudah terdaftar sebagai anggota di dalam tim ini.'
        });
      }

      // 3b. Cek kuota posisi pada Kebutuhan_Anggota_Tim & hitung jumlah anggota saat ini di posisi tersebut
      const [kebutuhanRows] = await connection.query(`
        SELECT id_kebutuhan, jumlah_anggota_dibutuhkan
        FROM Kebutuhan_Anggota_Tim
        WHERE id_tim = ? AND LOWER(TRIM(posisi_dibutuhkan)) = LOWER(TRIM(?))
        FOR UPDATE
      `, [app.id_tim, app.posisi]);

      const [[anggotaCount]] = await connection.query(`
        SELECT COUNT(*) AS total
        FROM Anggota_Tim
        WHERE id_tim = ? AND LOWER(TRIM(posisi)) = LOWER(TRIM(?))
      `, [app.id_tim, app.posisi]);

      if (kebutuhanRows.length > 0) {
        const kuotaDibutuhkan = kebutuhanRows.reduce((sum, row) => sum + Number(row.jumlah_anggota_dibutuhkan), 0);
        if (Number(anggotaCount.total) >= kuotaDibutuhkan) {
          await connection.rollback();
          transactionStarted = false;
          return res.status(409).json({
            success: false,
            message: `Kuota untuk posisi "${app.posisi}" pada tim ini sudah terpenuhi (${anggotaCount.total}/${kuotaDibutuhkan}).`
          });
        }
      }

      // 3c. Insert pelamar ke tabel Anggota_Tim
      const idAnggota = `ang_${Date.now()}`;
      await connection.query(
        'INSERT INTO Anggota_Tim (id_anggota_tim, id_tim, id_pengguna, posisi) VALUES (?, ?, ?, ?)',
        [idAnggota, app.id_tim, app.id_pengguna, app.posisi]
      );
    }

    // 4. Update tabel Pengajuan_Bergabung_Tim
    await connection.query(
      'UPDATE Pengajuan_Bergabung_Tim SET status_pengajuan = ? WHERE id_pengajuan_bergabung_tim = ?',
      [status_pengajuan, id]
    );

    // 5. Insert notifikasi ke tabel Notifikasi untuk akun pelamar (FR-20)
    const namaTim = app.nama_tim || 'Tim';
    const notifMsg = status_pengajuan === 'diterima'
      ? `Selamat! Pengajuan bergabung Anda untuk posisi ${app.posisi} pada tim "${namaTim}" telah diterima.`
      : `Mohon maaf, pengajuan bergabung Anda untuk posisi ${app.posisi} pada tim "${namaTim}" belum dapat diterima.`;

    const idNotif = `notif_${Date.now()}`;
    await connection.query(
      'INSERT INTO Notifikasi (id_notifikasi, id_pengguna, id_pengajuan_bergabung_tim, jenis_notifikasi, pesan_notifikasi) VALUES (?, ?, ?, ?, ?)',
      [idNotif, app.id_pengguna, id, status_pengajuan === 'diterima' ? 'pengajuan_diterima' : 'pengajuan_ditolak', notifMsg]
    );

    // 6. Commit Transaksi
    await connection.commit();
    transactionStarted = false;

    return res.status(200).json({
      success: true,
      message: status_pengajuan === 'diterima'
        ? 'Pengajuan berhasil diterima. Pelamar telah ditambahkan ke dalam anggota tim.'
        : 'Pengajuan berhasil ditolak.',
      data: {
        id_pengajuan_bergabung_tim: id,
        status_pengajuan: status_pengajuan,
        posisi_terdaftar: status_pengajuan === 'diterima' ? app.posisi : null
      }
    });
  } catch (error) {
    if (transactionStarted && connection) {
      await connection.rollback();
    }
    console.error('Error status application:', error);
    return res.status(500).json({ success: false, message: error.message });
  } finally {
    if (connection) {
      connection.release();
    }
  }
});

// GET /api/v1/applications/my-applications (FR-20: Riwayat Lamaran Saya — Rafa Gian Atthari)
router.get('/my-applications', async (req, res) => {
  try {
    const id_pengguna = getAuthUserId(req);
    const filterStatus = req.query.status ? req.query.status.toString().toLowerCase().trim() : null;

    // Ambil seluruh pengajuan pengguna bersangkutan beserta rincian tim dan pemilik tim
    const [allRows] = await db.query(`
      SELECT 
        pbt.id_pengajuan_bergabung_tim,
        pbt.id_tim,
        pbt.id_pengguna,
        pbt.posisi,
        pbt.pesan_pengajuan,
        pbt.waktu_pengajuan,
        pbt.status_pengajuan,
        dt.nama_tim,
        dt.nama_kegiatan,
        dt.kategori_kegiatan,
        dt.deskripsi AS deskripsi_tim,
        dt.status_tim,
        dt.id_pengguna AS id_pemilik_tim,
        u.nama_pengguna AS nama_pemilik_tim,
        u.foto_profil AS foto_pemilik_tim,
        (
          SELECT dp.path_file 
          FROM Dokumen_Pendukung dp 
          WHERE dp.id_tim = dt.id_tim AND dp.jenis_dokumen = 'poster' 
          ORDER BY dp.urutan ASC 
          LIMIT 1
        ) AS poster_tim
      FROM Pengajuan_Bergabung_Tim pbt
      JOIN Data_Tim dt ON pbt.id_tim = dt.id_tim
      JOIN Pengguna u ON dt.id_pengguna = u.id_pengguna
      WHERE pbt.id_pengguna = ?
      ORDER BY pbt.waktu_pengajuan DESC
    `, [id_pengguna]);

    // Hitung ringkasan statistik status pengajuan
    const summary = {
      total: allRows.length,
      menunggu: allRows.filter(r => r.status_pengajuan === 'menunggu').length,
      diterima: allRows.filter(r => r.status_pengajuan === 'diterima').length,
      ditolak: allRows.filter(r => r.status_pengajuan === 'ditolak').length
    };

    // Filter baris data jika filter status diberikan dan bukan 'semua'
    let filteredRows = allRows;
    if (filterStatus && filterStatus !== 'semua') {
      filteredRows = allRows.filter(r => r.status_pengajuan.toLowerCase() === filterStatus);
    }

    return res.json({
      success: true,
      message: 'Riwayat pengajuan bergabung berhasil diambil',
      summary,
      data: filteredRows
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/invite-member', requireAuth, async (req, res) => {
  let connection;
  let transactionStarted = false;
  try {
    const { id_tim, id_pengguna, posisi, pesan_pengajuan } = req.body;
    if (!id_tim || !id_pengguna || !posisi) {
      return res.status(422).json({
        success: false,
        message: 'id_tim, id_pengguna, dan posisi wajib diisi.'
      });
    }

    const currentUserId = req.user.id_pengguna;
    if (currentUserId === id_pengguna) {
      return res.status(422).json({
        success: false,
        message: 'Anda tidak dapat mengundang diri Anda sendiri ke dalam tim.'
      });
    }

    const pesan = (pesan_pengajuan && typeof pesan_pengajuan === 'string') ? pesan_pengajuan.trim() : '';

    connection = await db.getConnection();
    await connection.beginTransaction();
    transactionStarted = true;

    const [teams] = await connection.query(
      'SELECT id_pengguna, nama_tim FROM Data_Tim WHERE id_tim = ? FOR UPDATE',
      [id_tim]
    );
    if (teams.length === 0) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(404).json({
        success: false,
        message: 'Tim tidak ditemukan.'
      });
    }
    const team = teams[0];
    if (team.id_pengguna !== currentUserId) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(403).json({
        success: false,
        message: 'Hanya pembuat tim yang dapat mengirim undangan.'
      });
    }

    const [candidate] = await connection.query(
      'SELECT id_pengguna FROM Pengguna WHERE id_pengguna = ?',
      [id_pengguna]
    );
    if (candidate.length === 0) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(404).json({
        success: false,
        message: 'Calon anggota tidak ditemukan.'
      });
    }

    const [existingMembers] = await connection.query(
      'SELECT id_anggota_tim FROM Anggota_Tim WHERE id_tim = ? AND id_pengguna = ?',
      [id_tim, id_pengguna]
    );
    if (existingMembers.length > 0) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(409).json({
        success: false,
        message: 'Mahasiswa ini sudah resmi menjadi anggota di tim ini.'
      });
    }

    // Cek apakah sudah pernah dikirim undangan dan statusnya masih menunggu (Cegah spam!)
    const [pendingInvites] = await connection.query(
      "SELECT id_pengajuan_anggota FROM Pengajuan_Anggota WHERE id_tim = ? AND id_pengguna = ? AND status_pengajuan = 'menunggu'",
      [id_tim, id_pengguna]
    );
    if (pendingInvites.length > 0) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(409).json({
        success: false,
        message: 'Anda sudah pernah mengirimkan undangan ke mahasiswa ini dan statusnya masih menunggu konfirmasi.'
      });
    }

    const capacity = await getPositionCapacity(connection, id_tim, posisi);
    if (!capacity.available) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(409).json({
        success: false,
        message: `Posisi "${posisi}" sudah penuh atau tidak tersedia. Undangan tidak dikirim.`
      });
    }

    const id_pga = `pga_${Date.now()}`;

    await connection.query(
      'INSERT INTO Pengajuan_Anggota (id_pengajuan_anggota, id_tim, id_pengguna, posisi, pesan_pengajuan, status_pengajuan) VALUES (?, ?, ?, ?, ?, ?)',
      [id_pga, id_tim, id_pengguna, posisi, pesan, 'menunggu']
    );

    // Notifikasi undangan ke calon anggota
    await connection.query(
      'INSERT INTO Notifikasi (id_notifikasi, id_pengguna, id_pengajuan_anggota, jenis_notifikasi, pesan_notifikasi) VALUES (?, ?, ?, ?, ?)',
      [`notif_${Date.now()}`, id_pengguna, id_pga, 'undangan_masuk', `Anda menerima undangan untuk bergabung ke "${team.nama_tim}" sebagai ${posisi}.`]
    );

    await connection.commit();
    transactionStarted = false;
    return res.status(201).json({
      success: true,
      message: 'Undangan berhasil dikirim ke calon anggota',
      data: { id_pengajuan_anggota: id_pga, id_tim, id_pengguna, posisi, status_pengajuan: 'menunggu' }
    });
  } catch (error) {
    console.error('Error inviting team member:', error);
    if (transactionStarted && connection) await connection.rollback();
    return res.status(500).json({ success: false, message: error.message });
  } finally {
    if (connection) connection.release();
  }
});

// GET /api/v1/applications/received-invitations (FR-24: Undangan yang Diterima Calon Anggota)
router.get('/received-invitations', requireAuth, async (req, res) => {
  try {
    const id_pengguna = req.user.id_pengguna;
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
router.patch('/received-invitations/:id/status', requireAuth, async (req, res) => {
  let connection;
  let transactionStarted = false;
  try {
    const { id } = req.params;
    const { status_pengajuan } = req.body; // 'diterima' | 'ditolak'

    if (!['diterima', 'ditolak'].includes(status_pengajuan)) {
      return res.status(400).json({ success: false, message: 'Status undangan harus "diterima" atau "ditolak".' });
    }

    connection = await db.getConnection();
    await connection.beginTransaction();
    transactionStarted = true;

    const [rows] = await connection.query(
      'SELECT * FROM Pengajuan_Anggota WHERE id_pengajuan_anggota = ? FOR UPDATE',
      [id]
    );
    if (rows.length === 0) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(404).json({ success: false, message: 'Undangan tidak ditemukan.' });
    }
    const inv = rows[0];
    if (inv.id_pengguna !== req.user.id_pengguna) {
      await connection.rollback();
      transactionStarted = false;
      return res.status(403).json({
        success: false,
        message: 'Hanya penerima undangan yang dapat merespons undangan ini.'
      });
    }
    if (inv.status_pengajuan !== 'menunggu') {
      await connection.rollback();
      transactionStarted = false;
      return res.status(409).json({ success: false, message: 'Undangan ini sudah pernah direspons.' });
    }

    let finalStatus = status_pengajuan;
    let finalMessage = `Undangan berhasil di-${status_pengajuan}.`;

    if (status_pengajuan === 'diterima') {
      if (!inv.posisi) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(409).json({
          success: false,
          message: 'Undangan lama ini belum memiliki posisi. Minta pembuat tim mengirim undangan baru.'
        });
      }

      const [existingMembers] = await connection.query(
        'SELECT id_anggota_tim FROM Anggota_Tim WHERE id_tim = ? AND id_pengguna = ?',
        [inv.id_tim, inv.id_pengguna]
      );
      if (existingMembers.length > 0) {
        await connection.rollback();
        transactionStarted = false;
        return res.status(409).json({
          success: false,
          message: 'Anda sudah menjadi anggota tim ini.'
        });
      }
      const capacity = await getPositionCapacity(connection, inv.id_tim, inv.posisi);
      if (!capacity.available) {
        finalStatus = 'ditolak';
        finalMessage = `Kuota untuk posisi "${inv.posisi}" sudah penuh. Undangan otomatis ditolak.`;
      } else {
        await connection.query(`
          INSERT INTO Anggota_Tim (id_anggota_tim, id_tim, id_pengguna, posisi)
          VALUES (?, ?, ?, ?)
        `, [`ang_${Date.now()}`, inv.id_tim, inv.id_pengguna, inv.posisi]);
      }
    }

    await connection.query(
      'UPDATE Pengajuan_Anggota SET status_pengajuan = ? WHERE id_pengajuan_anggota = ?',
      [finalStatus, id]
    );

    // Kirim notifikasi respon ke ketua tim (FR-25 - Modul 4 Diva)
    const [team] = await connection.query('SELECT id_pengguna, nama_tim FROM Data_Tim WHERE id_tim = ?', [inv.id_tim]);
    if (team.length > 0) {
      const [calon] = await connection.query('SELECT nama_pengguna FROM Pengguna WHERE id_pengguna = ?', [inv.id_pengguna]);
      const namaCalon = calon[0]?.nama_pengguna || 'Calon Anggota';
      const detailPosisi = finalStatus === 'diterima' ? ` sebagai ${inv.posisi}` : '';
      await connection.query(
        'INSERT INTO Notifikasi (id_notifikasi, id_pengguna, id_pengajuan_anggota, jenis_notifikasi, pesan_notifikasi) VALUES (?, ?, ?, ?, ?)',
        [`notif_${Date.now()}`, team[0].id_pengguna, id, 'respon_undangan', `${namaCalon} telah ${finalStatus} undangan bergabung ke tim "${team[0].nama_tim}"${detailPosisi}.`]
      );
    }

    await connection.commit();
    transactionStarted = false;
    return res.json({
      success: true,
      message: finalMessage,
      data: { id_pengajuan_anggota: id, status_pengajuan: finalStatus }
    });
  } catch (error) {
    console.error('Error responding to team invitation:', error);
    if (transactionStarted && connection) await connection.rollback();
    return res.status(500).json({ success: false, message: error.message });
  } finally {
    if (connection) connection.release();
  }
});

// GET /api/v1/applications/sent-invitations (FR-25: Status Undangan Terkirim)
// Digunakan oleh ketua tim untuk melihat status semua undangan yang pernah dikirim
router.get('/sent-invitations', requireAuth, async (req, res) => {
  try {
    const id_pengguna = req.user.id_pengguna;

    // Ambil semua undangan dari tim yang dimiliki user
    const [rows] = await db.query(`
      SELECT
        pa.id_pengajuan_anggota,
        pa.id_tim,
        pa.id_pengguna        AS id_calon,
        pa.posisi,
        pa.pesan_pengajuan,
        pa.status_pengajuan,
        pa.waktu_pengajuan,
        dt.nama_tim,
        dt.nama_kegiatan,
        dt.kategori_kegiatan,
        p.nama_pengguna       AS nama_calon,
        p.foto_profil         AS foto_calon,
        p.nim                 AS nim_calon,
        dd.program_studi      AS prodi_calon
      FROM Pengajuan_Anggota pa
      JOIN Data_Tim dt ON pa.id_tim = dt.id_tim
      JOIN Pengguna p  ON pa.id_pengguna = p.id_pengguna
      LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
      WHERE dt.id_pengguna = ?
      ORDER BY pa.waktu_pengajuan DESC
    `, [id_pengguna]);

    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
