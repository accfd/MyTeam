const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8000;

const path = require('path');

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
const isVercel = process.env.VERCEL || process.env.AWS_LAMBDA_FUNCTION_NAME;
if (isVercel) {
  const os = require('os');
  app.use('/storage/teams', express.static(path.join(os.tmpdir(), 'storage', 'teams')));
  app.use('/storage/profiles', express.static(path.join(os.tmpdir(), 'storage', 'profiles')));
}
app.use('/storage', express.static(path.join(__dirname, 'storage')));

// Rute Pengujian Status Server (Health Check)
app.get('/', (req, res) => {
  res.json({
    status: 'online',
    project: 'MyTeam API Backend',
    version: '1.0.0',
    university: 'Universitas Andalas',
    message: 'Server Backend MyTeam berjalan lancar!'
  });
});

app.get('/api/v1', (req, res) => {
  res.json({
    status: 'ready',
    contract_version: '1.0.0',
    base_url: `http://localhost:${PORT}/api/v1`,
    endpoints: [
      '/auth/login',
      '/auth/register',
      '/profile/detail/:id',
      '/teams/feed',
      '/teams/my-teams',
      '/applications/join-team',
      '/notifications'
    ]
  });
});

app.get('/api/v1/health-db', async (req, res) => {
  try {
    const db = require('./src/config/db');
    const [rows] = await db.query('SELECT 1 + 1 AS result');
    res.json({
      success: true,
      message: 'Database TiDB Cloud terhubung dengan baik!',
      result: rows[0].result
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Gagal terhubung ke database',
      error: err.message
    });
  }
});

// Registrasi Modul Endpoint Resmi
app.use('/api/v1/auth', require('./src/routes/auth'));
app.use('/api/v1/profile', require('./src/routes/profile'));
app.use('/api/v1/teams', require('./src/routes/teams'));
app.use('/api/v1/applications', require('./src/routes/applications'));
app.use('/api/v1/members', require('./src/routes/members'));
app.use('/api/v1/notifications', require('./src/routes/notifications'));

// Error 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Endpoint ${req.method} ${req.originalUrl} tidak ditemukan pada server MyTeam.`
  });
});

// Global Error Handler (memastikan respon error selalu berformat JSON, bukan halaman HTML)
app.use((err, req, res, next) => {
  console.error('Unhandled server error:', err);
  if (res.headersSent) {
    return next(err);
  }
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({
      success: false,
      message: 'Ukuran berkas melebihi batas maksimal 10 MB.'
    });
  }
  return res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Terjadi kesalahan pada server backend.'
  });
});

// Menjalankan Server secara lokal / dedicated
if (process.env.NODE_ENV !== 'production' || !process.env.VERCEL) {
  app.listen(PORT, () => {
    console.log(`=================================================`);
    console.log(`🚀 Server Backend MyTeam aktif di Port ${PORT}`);
    console.log(`🌐 Localhost URL : http://localhost:${PORT}`);
    console.log(`📱 Emulator URL  : http://10.0.2.2:${PORT}/api/v1`);
    console.log(`=================================================`);
  });
}

module.exports = app;
