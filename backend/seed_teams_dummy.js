/**
 * Seed data tim dummy untuk empat akun contoh MyTeam.
 * Jalankan dari folder backend: node seed_teams_dummy.js
 */

const mysql = require('mysql2/promise');
require('dotenv').config();

const db = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'myteam_db',
  port: process.env.DB_PORT || 3306,
});

const teams = [
  {
    id_tim: 'tim_gemastik_01',
    id_pengguna: 'usr_rafa_02',
    nama_tim: 'Tim Robotik Cerdas Unand',
    nama_kegiatan: 'GEMASTIK XVII Divisi Software Development',
    kategori_kegiatan: 'Lomba',
    deskripsi: 'Membangun aplikasi kendali telemetri untuk robot penjelajah otonom kampus.',
    kebutuhan: [
      ['keb_01', 'Frontend Flutter', 'Flutter, Dart, REST API Integration'],
      ['keb_02', 'UI/UX Designer', 'Figma, Wireframing, User Testing'],
    ],
  },
  {
    id_tim: 'tim_pkm_02',
    id_pengguna: 'usr_nayla_04',
    nama_tim: 'Inovator Pangan Unand',
    nama_kegiatan: 'Program Kreativitas Mahasiswa Riset Eksakta 2026',
    kategori_kegiatan: 'Penelitian',
    deskripsi: 'Riset AI dan aplikasi pemantau kestabilan pasokan komoditas pangan lokal.',
    kebutuhan: [
      ['keb_03', 'Mobile App Developer', 'Flutter, Android, SQLite'],
      ['keb_04', 'Data Analyst', 'Python, Data Modeling, Statistics'],
    ],
  },
  {
    id_tim: 'tim_fuadi_03',
    id_pengguna: 'usr_fuadi_01',
    nama_tim: 'Aplikasi Jelajah Kampus',
    nama_kegiatan: 'Unand Digital Innovation Challenge 2026',
    kategori_kegiatan: 'Proyek',
    deskripsi: 'Mengembangkan aplikasi untuk membantu mahasiswa menemukan fasilitas kampus.',
    kebutuhan: [
      ['keb_05', 'Flutter Developer', 'Flutter, Dart, REST API'],
      ['keb_09', 'Product Designer', 'Product discovery, usability testing, Figma'],
    ],
  },
  {
    id_tim: 'tim_rafa_04',
    id_pengguna: 'usr_rafa_02',
    nama_tim: 'Sistem Irigasi Cerdas',
    nama_kegiatan: 'Kompetisi Inovasi Teknologi Pertanian 2026',
    kategori_kegiatan: 'Lomba',
    deskripsi: 'Merancang sistem IoT dan backend untuk pemantauan irigasi lahan pertanian.',
    kebutuhan: [
      ['keb_06', 'IoT Engineer', 'ESP32, sensor, MQTT'],
      ['keb_10', 'Backend Developer', 'Node.js, API design, database'],
    ],
  },
  {
    id_tim: 'tim_diva_05',
    id_pengguna: 'usr_diva_03',
    nama_tim: 'Ruang Belajar Inklusif',
    nama_kegiatan: 'Program Kreativitas Mahasiswa Pengabdian 2026',
    kategori_kegiatan: 'Penelitian',
    deskripsi: 'Mendesain pengalaman belajar digital yang mudah diakses semua mahasiswa.',
    kebutuhan: [
      ['keb_07', 'UI/UX Designer', 'Figma, accessibility, user research'],
      ['keb_11', 'Accessibility Tester', 'WCAG, usability testing, inclusive design'],
    ],
  },
  {
    id_tim: 'tim_diva_06',
    id_pengguna: 'usr_diva_03',
    nama_tim: 'Dashboard Data Kampus',
    nama_kegiatan: 'Unand Data Visualization Project 2026',
    kategori_kegiatan: 'Proyek',
    deskripsi: 'Membuat dashboard interaktif untuk menyajikan data layanan dan aktivitas kampus.',
    kebutuhan: [
      ['keb_08', 'Data Visualization Designer', 'Figma, dashboard design, data storytelling'],
      ['keb_12', 'Frontend Developer', 'React, charting library, REST API'],
    ],
  },
  {
    id_tim: 'tim_fuadi_08',
    id_pengguna: 'usr_fuadi_01',
    nama_tim: 'Platform Relawan Kampus',
    nama_kegiatan: 'Unand Social Impact Challenge 2026',
    kategori_kegiatan: 'Proyek',
    deskripsi: 'Menghubungkan relawan mahasiswa dengan program sosial di sekitar kampus.',
    kebutuhan: [
      ['keb_13', 'Backend Developer', 'Node.js, PostgreSQL, REST API'],
      ['keb_14', 'UX Researcher', 'User interview, service design, usability testing'],
    ],
  },
  {
    id_tim: 'tim_fuadi_09',
    id_pengguna: 'usr_fuadi_01',
    nama_tim: 'Deteksi Hoaks Bahasa Minang',
    nama_kegiatan: 'Kompetisi Inovasi Digital Sumatera Barat 2026',
    kategori_kegiatan: 'Lomba',
    deskripsi: 'Mengembangkan model dan aplikasi untuk mengenali hoaks berbahasa Minang.',
    kebutuhan: [
      ['keb_15', 'Machine Learning Engineer', 'Python, NLP, model evaluation'],
      ['keb_16', 'Mobile Developer', 'Flutter, Dart, API integration'],
    ],
  },
  {
    id_tim: 'tim_fuadi_10',
    id_pengguna: 'usr_fuadi_01',
    nama_tim: 'Asisten Akademik Berbasis AI',
    nama_kegiatan: 'Proyek Riset Teknologi Pendidikan 2026',
    kategori_kegiatan: 'Penelitian',
    deskripsi: 'Merancang asisten akademik untuk membantu menemukan materi dan informasi kuliah.',
    kebutuhan: [
      ['keb_17', 'AI Researcher', 'Python, LLM, information retrieval'],
      ['keb_18', 'Frontend Developer', 'Flutter, responsive UI, accessibility'],
    ],
  },
  {
    id_tim: 'tim_rafa_08',
    id_pengguna: 'usr_rafa_02',
    nama_tim: 'Pemantau Kualitas Udara',
    nama_kegiatan: 'Lomba IoT dan Smart City 2026',
    kategori_kegiatan: 'Lomba',
    deskripsi: 'Membangun perangkat IoT dan dashboard pemantau kualitas udara kampus.',
    kebutuhan: [
      ['keb_19', 'IoT Engineer', 'ESP32, sensor calibration, MQTT'],
      ['keb_20', 'Data Dashboard Developer', 'React, data visualization, API'],
    ],
  },
];

async function seed() {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    // Hapus hanya ID tim dummy usang agar jumlah contoh sesuai distribusi baru.
    await connection.query(
      `DELETE FROM Data_Tim
       WHERE id_tim IN ('tim_diva_001', 'tim_diva_002', 'tim_diva_003', 'tim_diva_07')`
    );

    for (const team of teams) {
      const [users] = await connection.query(
        'SELECT id_pengguna FROM Pengguna WHERE id_pengguna = ?',
        [team.id_pengguna]
      );
      if (users.length === 0) {
        throw new Error(`Pengguna ${team.id_pengguna} belum ada. Jalankan npm run db:setup terlebih dahulu.`);
      }

      const [existing] = await connection.query(
        'SELECT id_tim FROM Data_Tim WHERE id_tim = ?',
        [team.id_tim]
      );
      if (existing.length === 0) {
        await connection.query(
          `INSERT INTO Data_Tim
            (id_tim, id_pengguna, nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi, status_tim)
           VALUES (?, ?, ?, ?, ?, ?, 'terbuka')`,
          [
            team.id_tim,
            team.id_pengguna,
            team.nama_tim,
            team.nama_kegiatan,
            team.kategori_kegiatan,
            team.deskripsi,
          ]
        );
      }

      for (const [idKebutuhan, posisi, keahlian] of team.kebutuhan) {
        const [existingNeed] = await connection.query(
          'SELECT id_kebutuhan FROM Kebutuhan_Anggota_Tim WHERE id_kebutuhan = ?',
          [idKebutuhan]
        );
        if (existingNeed.length === 0) {
          await connection.query(
            `INSERT INTO Kebutuhan_Anggota_Tim
              (id_kebutuhan, id_tim, posisi_dibutuhkan, keahlian_dibutuhkan, jumlah_anggota_dibutuhkan)
             VALUES (?, ?, ?, ?, 1)`,
            [idKebutuhan, team.id_tim, posisi, keahlian]
          );
        }
      }
    }

    await connection.commit();
    console.log('Seed tim dummy selesai: Fuadi 4, Rafa 3, Diva 2, Nayla 1.');
  } catch (error) {
    await connection.rollback();
    console.error('Gagal menjalankan seed tim dummy:', error.message);
    process.exitCode = 1;
  } finally {
    connection.release();
    await db.end();
  }
}

seed().catch((error) => {
  console.error('Gagal menghubungkan ke database:', error.message);
  process.exitCode = 1;
});
