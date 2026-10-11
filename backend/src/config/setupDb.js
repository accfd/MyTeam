const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config();

async function setupDatabase() {
  console.log('🔄 Memulai inisialisasi database otomatis...');

  let connection;
  try {
    // 1. Buat koneksi awal ke server MySQL (tanpa pilih database)
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      port: process.env.DB_PORT || 3306,
      multipleStatements: true
    });

    console.log('✅ Terhubung ke MySQL server');

    // 2. Baca dan jalankan schema_myteam.sql
    const schemaPath = path.resolve(__dirname, '../../../schema_myteam.sql');
    if (!fs.existsSync(schemaPath)) {
      throw new Error(`File schema tidak ditemukan di: ${schemaPath}`);
    }
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');
    console.log('⏳ Mengimpor skema 13 tabel (schema_myteam.sql)...');
    await connection.query(schemaSql);
    console.log('✅ Skema tabel berhasil dibuat!');

    // 3. Baca dan jalankan dummy_seed_myteam.sql
    const seedPath = path.resolve(__dirname, '../../../dummy_seed_myteam.sql');
    if (!fs.existsSync(seedPath)) {
      throw new Error(`File seeder tidak ditemukan di: ${seedPath}`);
    }
    const seedSql = fs.readFileSync(seedPath, 'utf8');
    console.log('⏳ Mengimpor data dummy 4 akun mahasiswa (dummy_seed_myteam.sql)...');
    await connection.query(seedSql);
    console.log('✅ Data dummy seeder berhasil diimpor!');

    console.log('\n======================================================');
    console.log('🎉 SUKSES! Database myteam_db dan data dummy siap dipakai!');
    console.log('======================================================');
  } catch (error) {
    console.error('❌ Gagal inisialisasi database:', error.message);
    console.error('👉 Pastikan XAMPP/MySQL sudah dinyalakan.');
    process.exit(1);
  } finally {
    if (connection) await connection.end();
  }
}

setupDatabase();
