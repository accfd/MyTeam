const jwt = require('jsonwebtoken');

module.exports = function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith('Bearer ')
    ? authHeader.slice('Bearer '.length).trim()
    : '';

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token autentikasi wajib disertakan.'
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'myteam_secret');
    if (!decoded?.id_pengguna) {
      return res.status(401).json({
        success: false,
        message: 'Token autentikasi tidak memuat identitas pengguna yang valid.'
      });
    }

    req.user = decoded;
    return next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Token autentikasi tidak valid atau sudah kedaluwarsa.'
    });
  }
};
