const { OAuth2Client } = require('google-auth-library');

const client = new OAuth2Client();

/**
 * Middleware untuk memverifikasi Google ID Token dan memastikan akun berdomain @student.unand.ac.id
 */
module.exports = async function verifyGoogleToken(req, res, next) {
  try {
    const idToken = req.body.id_token || (
      req.headers.authorization?.startsWith('Bearer ')
        ? req.headers.authorization.slice(7).trim()
        : null
    );

    if (!idToken) {
      return res.status(400).json({
        success: false,
        message: 'ID Token Google wajib disertakan.'
      });
    }

    // Audiences yang diizinkan (Web Client ID & Android Client ID dari Google Cloud Console)
    const audience = process.env.GOOGLE_CLIENT_ID
      ? process.env.GOOGLE_CLIENT_ID.split(',').map(id => id.trim())
      : undefined;

    // Verifikasi tanda tangan kriptografi token melalui server Google
    const ticket = await client.verifyIdToken({
      idToken,
      audience
    });

    const payload = ticket.getPayload();

    if (!payload || !payload.email) {
      return res.status(401).json({
        success: false,
        message: 'Google ID Token tidak memuat informasi profil atau email pengguna.'
      });
    }

    const email = payload.email.toLowerCase().trim();

    // Validasi pembatasan domain khusus mahasiswa UNAND
    const isUnandStudent = email.endsWith('@student.unand.ac.id') || payload.hd === 'student.unand.ac.id';
    if (!isUnandStudent) {
      return res.status(403).json({
        success: false,
        message: 'Akses ditolak. Anda wajib masuk menggunakan email resmi mahasiswa Universitas Andalas (@student.unand.ac.id).'
      });
    }

    // Teruskan payload profil Google terverifikasi ke handler berikutnya
    req.googleUser = {
      google_id: payload.sub,
      email: email,
      nama: payload.name || payload.email.split('@')[0],
      foto_profil: payload.picture || null,
      email_verified: payload.email_verified
    };

    return next();
  } catch (error) {
    console.error('Verifikasi Google Token Gagal:', error.message);
    return res.status(401).json({
      success: false,
      message: 'ID Token Google tidak valid atau telah kedaluwarsa.',
      error: error.message
    });
  }
};
