const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/db');
const verifyGoogleToken = require('../middleware/verify_google_token');

/**
 * Helper untuk mendeteksi Program Studi dan Fakultas UNAND dari NIM
 * Khusus FTI: 1151 = Tekkom, 1152 = Sistem Informasi, 1153 = Informatika
 */
function detectProdiFakultas(nim) {
  if (!nim || nim.length < 6) {
    return { program_studi: '', fakultas: '' };
  }
  if (nim.includes('1151')) {
    return { program_studi: 'Teknik Komputer', fakultas: 'Teknologi Informasi' };
  }
  if (nim.includes('1152')) {
    return { program_studi: 'Sistem Informasi', fakultas: 'Teknologi Informasi' };
  }
  if (nim.includes('1153')) {
    return { program_studi: 'Informatika', fakultas: 'Teknologi Informasi' };
  }
  return { program_studi: '', fakultas: '' };
}

// POST /api/v1/auth/register
router.post('/register', async (req, res) => {
  try {
    const { nim, nama_pengguna, email, kata_sandi, kata_sandi_konfirmasi } = req.body;

    if (!nim || !nama_pengguna || !kata_sandi) {
      return res.status(422).json({
        success: false,
        message: 'NIM, nama pengguna, dan kata sandi wajib diisi.'
      });
    }

    // Validasi pembatasan khusus email resmi mahasiswa UNAND
    const userEmail = email ? email.toLowerCase().trim() : null;
    if (userEmail && !userEmail.endsWith('@student.unand.ac.id')) {
      return res.status(422).json({
        success: false,
        message: 'Pendaftaran hanya diizinkan menggunakan email resmi mahasiswa UNAND (@student.unand.ac.id).'
      });
    }

    if (kata_sandi !== kata_sandi_konfirmasi) {
      return res.status(422).json({
        success: false,
        message: 'Konfirmasi kata sandi tidak cocok.'
      });
    }

    // Cek apakah NIM atau Email sudah terdaftar
    const [existing] = await db.query(
      'SELECT nim, email FROM Pengguna WHERE nim = ? OR (email IS NOT NULL AND email = ?)',
      [nim, userEmail || '']
    );
    if (existing.length > 0) {
      const isNimDup = existing.some(e => e.nim === nim);
      return res.status(409).json({
        success: false,
        message: isNimDup ? 'NIM sudah terdaftar dalam sistem MyTeam.' : 'Email kampus sudah terdaftar dalam sistem MyTeam.'
      });
    }

    const id_pengguna = `usr_${Date.now()}`;
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(kata_sandi, salt);

    await db.query(
      'INSERT INTO Pengguna (id_pengguna, nim, kata_sandi, nama_pengguna, email) VALUES (?, ?, ?, ?, ?)',
      [id_pengguna, nim, hash, nama_pengguna, userEmail]
    );

    // Inisialisasi Data_Diri (auto-detect prodi & fakultas untuk mahasiswa FTI)
    const { program_studi, fakultas } = detectProdiFakultas(nim);
    await db.query(
      'INSERT INTO Data_Diri (id_pengguna, deskripsi_singkat, kontak, program_studi, fakultas, ipk) VALUES (?, ?, ?, ?, ?, ?)',
      [id_pengguna, '', '', program_studi, fakultas, 0.00]
    );

    const token = jwt.sign(
      { id_pengguna, nim, nama_pengguna },
      process.env.JWT_SECRET || 'myteam_secret',
      { expiresIn: '7d' }
    );

    return res.status(201).json({
      success: true,
      message: 'Registrasi akun berhasil',
      data: {
        id_pengguna,
        nim,
        nama_pengguna,
        email: userEmail,
        foto_profil: null,
        token
      }
    });
  } catch (error) {
    console.error('Error register:', error);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server.' });
  }
});

// POST /api/v1/auth/login
router.post('/login', async (req, res) => {
  try {
    const { nim, kata_sandi } = req.body;

    if (!nim || !kata_sandi) {
      return res.status(400).json({
        success: false,
        message: 'NIM atau Email dan kata sandi wajib diisi.'
      });
    }

    const identifier = nim.toLowerCase().trim();

    // Cari akun berdasarkan NIM atau Email UNAND
    const [rows] = await db.query(
      'SELECT id_pengguna, nim, kata_sandi, nama_pengguna, foto_profil, email FROM Pengguna WHERE nim = ? OR email = ?',
      [identifier, identifier]
    );

    if (rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'NIM/Email atau kata sandi tidak valid.'
      });
    }

    const user = rows[0];
    if (!user.kata_sandi) {
      return res.status(401).json({
        success: false,
        message: 'Akun ini belum memiliki kata sandi lokal.'
      });
    }

    // Fix kompatibilitas: hash dummy seed pakai prefix $2y$ (PHP),
    // bcryptjs Node.js pakai $2b$ — keduanya algoritmanya sama, beda prefix saja.
    const hashCompat = user.kata_sandi.replace(/^\$2y\$/, '$2b$');
    const isMatch = await bcrypt.compare(kata_sandi, hashCompat);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'NIM/Email atau kata sandi tidak valid.'
      });
    }

    const token = jwt.sign(
      { id_pengguna: user.id_pengguna, nim: user.nim, nama_pengguna: user.nama_pengguna },
      process.env.JWT_SECRET || 'myteam_secret',
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      success: true,
      message: 'Autentikasi berhasil',
      data: {
        id_pengguna: user.id_pengguna,
        nim: user.nim,
        nama_pengguna: user.nama_pengguna,
        foto_profil: user.foto_profil,
        email: user.email,
        token
      }
    });
  } catch (error) {
    console.error('Error login:', error);
    return res.status(500).json({ success: false, message: error.message || 'Terjadi kesalahan pada server.' });
  }
});

// POST /api/v1/auth/google
router.post('/google', verifyGoogleToken, async (req, res) => {
  try {
    const { google_id, email, nama, foto_profil } = req.googleUser;

    // 1. Ekstrak 10 digit NIM dari prefix email kampus UNAND
    // Contoh format: 2411522001_Fuadi@student.unand.ac.id atau 2411522001@student.unand.ac.id
    const prefix = email.split('@')[0];
    const nimMatch = prefix.match(/^(\d{10})/);

    if (!nimMatch) {
      return res.status(422).json({
        success: false,
        message: 'Format email tidak valid. Email akun harus diawali dengan 10 digit NIM Anda (contoh: 2411522001...@student.unand.ac.id).'
      });
    }

    const nim = nimMatch[1];
    const nama_pengguna = nama || `Mahasiswa_${nim}`;

    // 2. Cek apakah akun sudah terdaftar (berdasarkan google_id, email, atau nim)
    const [rows] = await db.query(
      'SELECT id_pengguna, nim, nama_pengguna, foto_profil, email, google_id FROM Pengguna WHERE google_id = ? OR email = ? OR nim = ?',
      [google_id, email, nim]
    );

    let user;
    let isNewUser = false;

    if (rows.length > 0) {
      // Pengguna sudah terdaftar -> sinkronkan data Google jika belum terhubung
      user = rows[0];
      const updatedFoto = user.foto_profil || foto_profil;

      await db.query(
        'UPDATE Pengguna SET google_id = COALESCE(google_id, ?), email = COALESCE(email, ?), foto_profil = COALESCE(foto_profil, ?) WHERE id_pengguna = ?',
        [google_id, email, updatedFoto, user.id_pengguna]
      );

      user.foto_profil = updatedFoto;
      user.email = user.email || email;
      user.google_id = user.google_id || google_id;
    } else {
      // Pengguna baru -> registrasi otomatis
      isNewUser = true;
      const id_pengguna = `usr_${Date.now()}`;

      await db.query(
        'INSERT INTO Pengguna (id_pengguna, nim, nama_pengguna, email, google_id, foto_profil) VALUES (?, ?, ?, ?, ?, ?)',
        [id_pengguna, nim, nama_pengguna, email, google_id, foto_profil]
      );

      // Inisialisasi entri Data_Diri (auto-detect prodi & fakultas untuk mahasiswa FTI)
      const { program_studi, fakultas } = detectProdiFakultas(nim);
      await db.query(
        'INSERT INTO Data_Diri (id_pengguna, deskripsi_singkat, kontak, program_studi, fakultas, ipk) VALUES (?, ?, ?, ?, ?, ?)',
        [id_pengguna, '', '', program_studi, fakultas, 0.00]
      );

      user = {
        id_pengguna,
        nim,
        nama_pengguna,
        foto_profil,
        email,
        google_id
      };
    }

    // 3. Terbitkan JWT MyTeam standar
    const token = jwt.sign(
      { id_pengguna: user.id_pengguna, nim: user.nim, nama_pengguna: user.nama_pengguna },
      process.env.JWT_SECRET || 'myteam_secret',
      { expiresIn: '7d' }
    );

    return res.status(isNewUser ? 201 : 200).json({
      success: true,
      message: isNewUser ? 'Registrasi akun mahasiswa via Google berhasil' : 'Autentikasi Google berhasil',
      data: {
        id_pengguna: user.id_pengguna,
        nim: user.nim,
        nama_pengguna: user.nama_pengguna,
        foto_profil: user.foto_profil,
        email: user.email,
        token
      }
    });
  } catch (error) {
    console.error('Error Google Auth handler:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server saat memproses autentikasi Google.'
    });
  }
});

module.exports = router;
