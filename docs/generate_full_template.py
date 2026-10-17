# -*- coding: utf-8 -*-
"""
Generator revisi Template Progress Report 1 - MyTeam (Kelompok 5)
Sesuai instruksi revisi dan target nilai 100 (Kategori Excellent di seluruh aspek).
"""

import sys
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

def set_cell_background(cell, hex_color):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=140, right=140):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(
        f'<w:tcMar {nsdecls("w")}>'
        f'<w:top w:w="{top}" w:type="dxa"/>'
        f'<w:bottom w:w="{bottom}" w:type="dxa"/>'
        f'<w:left w:w="{left}" w:type="dxa"/>'
        f'<w:right w:w="{right}" w:type="dxa"/>'
        f'</w:tcMar>'
    )
    tcPr.append(tcMar)

def format_table(table, col_widths=None, header_bg='EBF2FA'):
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False

    header_row = table.rows[0]
    trPr = header_row._tr.get_or_add_trPr()
    trPr.append(parse_xml(f'<w:tblHeader {nsdecls("w")}/>'))
    trPr.append(parse_xml(f'<w:cantSplit {nsdecls("w")}/>'))

    for cell in header_row.cells:
        set_cell_background(cell, header_bg)
        set_cell_margins(cell, top=110, bottom=110, left=130, right=130)
        cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
        for p in cell.paragraphs:
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(2)
            for r in p.runs:
                r.bold = True
                r.font.size = Pt(9.5)
                r.font.color.rgb = RGBColor(0x1B, 0x36, 0x5D)

    for r_idx, row in enumerate(table.rows[1:], start=1):
        trPr = row._tr.get_or_add_trPr()
        trPr.append(parse_xml(f'<w:cantSplit {nsdecls("w")}/>'))
        row_bg = 'FFFFFF' if r_idx % 2 == 1 else 'F8FAFC'
        for cell in row.cells:
            if row_bg != 'FFFFFF':
                set_cell_background(cell, row_bg)
            set_cell_margins(cell, top=90, bottom=90, left=130, right=130)
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            for p in cell.paragraphs:
                p.paragraph_format.space_before = Pt(1.5)
                p.paragraph_format.space_after = Pt(1.5)
                for r in p.runs:
                    r.font.size = Pt(9.0)

    if col_widths:
        for row in table.rows:
            for idx, width in enumerate(col_widths):
                if idx < len(row.cells):
                    row.cells[idx].width = Inches(width)

def add_guideline(doc, text):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(1.5)
    p.paragraph_format.space_after = Pt(3.5)
    run = p.add_run(text)
    run.italic = True
    run.font.color.rgb = RGBColor(0x55, 0x60, 0x70)
    run.font.size = Pt(9.5)
    return p

def add_placeholder_box(doc, text):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(3)
    p.paragraph_format.space_after = Pt(3)
    run = p.add_run(f'[{text}]')
    run.bold = True
    run.font.color.rgb = RGBColor(0x00, 0x4D, 0x99)
    run.font.size = Pt(9.5)
    return p

def add_code_block(doc, code_text):
    p = doc.add_paragraph(style='Code')
    p.paragraph_format.space_before = Pt(2)
    p.paragraph_format.space_after = Pt(2)
    run = p.add_run(code_text)
    run.font.name = 'Consolas'
    run.font.size = Pt(8.5)
    return p

def generate_report():
    doc = docx.Document()
    
    # Page Setup
    for section in doc.sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)
        section.page_width = Inches(8.5)
        section.page_height = Inches(11.0)

    styles = doc.styles
    
    normal_style = styles['Normal']
    normal_style.font.name = 'Calibri'
    normal_style.font.size = Pt(11)
    normal_style.font.color.rgb = RGBColor(0x22, 0x22, 0x22)
    normal_style.paragraph_format.line_spacing = 1.15
    normal_style.paragraph_format.space_after = Pt(3.5)
    normal_style.paragraph_format.space_before = Pt(0)
    
    h1_style = styles['Heading 1']
    h1_style.font.name = 'Calibri'
    h1_style.font.size = Pt(18)
    h1_style.font.bold = True
    h1_style.font.color.rgb = RGBColor(0x1B, 0x36, 0x5D)
    h1_style.paragraph_format.space_before = Pt(10)
    h1_style.paragraph_format.space_after = Pt(4)
    
    h2_style = styles['Heading 2']
    h2_style.font.name = 'Calibri'
    h2_style.font.size = Pt(13.5)
    h2_style.font.bold = True
    h2_style.font.color.rgb = RGBColor(0x1B, 0x36, 0x5D)
    h2_style.paragraph_format.space_before = Pt(12)
    h2_style.paragraph_format.space_after = Pt(3)
    
    h3_style = styles['Heading 3']
    h3_style.font.name = 'Calibri'
    h3_style.font.size = Pt(11.5)
    h3_style.font.bold = True
    h3_style.font.color.rgb = RGBColor(0x2B, 0x4C, 0x7E)
    h3_style.paragraph_format.space_before = Pt(9)
    h3_style.paragraph_format.space_after = Pt(2.5)

    try:
        code_style = styles['Code']
    except KeyError:
        code_style = styles.add_style('Code', docx.enum.style.WD_STYLE_TYPE.PARAGRAPH)
    code_style.font.name = 'Consolas'
    code_style.font.size = Pt(9.0)
    code_style.font.color.rgb = RGBColor(0x1E, 0x29, 0x3B)
    code_style.paragraph_format.space_before = Pt(2)
    code_style.paragraph_format.space_after = Pt(2)
    code_style.paragraph_format.left_indent = Inches(0.2)

    # ==========================================
    # HEADER / COVER
    # ==========================================
    p_title = doc.add_paragraph(style='Heading 1')
    p_title.add_run('Progress Report 1 – MyTeam: Aplikasi Mobile Pencarian dan Pembentukan Tim Mahasiswa Unand')
    
    p_meta = doc.add_paragraph()
    r_meta = p_meta.add_run('Mata Kuliah: Mobile Programming | Kelompok 5 | Tanggal Laporan: [Tanggal]')
    r_meta.font.size = Pt(10)
    r_meta.font.color.rgb = RGBColor(0x66, 0x66, 0x66)

    add_guideline(
        doc,
        'Panduan Penggunaan Template (Target Nilai 100 / Kategori Excellent):\n'
        '1. Teks miring berawalan "Panduan" menjelaskan kriteria penilaian dosen dan panduan pengisian untuk mencapai poin maksimal (Excellent) pada 4 aspek: Progress Aplikasi (40%), Kendala & Solusi (20%), Code Audit & Refactoring (25%), dan Koordinasi Tim (15%). Hapus seluruh teks panduan sebelum laporan dikumpulkan.\n'
        '2. Ganti semua teks dalam [kurung siku] dengan data kondisi nyata aplikasi yang sudah berjalan. Laporan dinilai berdasarkan implementasi nyata pada aplikasi dan repository, bukan sekadar rencana.\n'
        '3. Pada Bab 2, progress disajikan terperinci per modul (2.1 s.d 2.4), dilanjutkan dengan arsitektur database/ERD (2.5), flow utama berjalan (2.6), subbab bukti aplikasi berjalan per alur (2.7.1 s.d 2.7.4), dan rencana pekerjaan berikutnya (2.8).'
    )

    doc.add_paragraph('Halaman Judul & Identitas Proyek', style='Heading 2')
    add_guideline(doc, 'Panduan: Lengkapi identitas laporan. Pastikan tautan repository dan video demo dapat diakses oleh dosen dan asisten praktikum.')

    t_ident = doc.add_table(rows=8, cols=2)
    t_ident.style = 'Table Grid'
    ident_data = [
        ('Keterangan', 'Isi Data Identitas Proyek'),
        ('Judul Laporan', 'Progress Report 1 – MyTeam: Aplikasi Mobile Pencarian dan Pembentukan Tim Mahasiswa Unand'),
        ('Mata Kuliah', 'Mobile Programming (Kelas A/B/...)'),
        ('Kelompok', 'Kelompok 5'),
        ('Anggota & NIM', '1. Nayla Puspita Sari (2411521007)\n2. Diva Ramadhani (2411521017)\n3. Fuadi Dhiyaulhaq (2411522001)\n4. Rafa Gian Atthari (2411522014)'),
        ('Tanggal Laporan', '[Tanggal Pengumpulan, misal: 17 Oktober 2026]'),
        ('Tautan Repository', '[Tautan GitHub/GitLab repository project MyTeam]'),
        ('Tautan Video Demo & APK', '[Tautan Google Drive / YouTube Unlisted video demo (1–3 menit) dan file APK runnable]'),
    ]
    for r_idx, (c0, c1) in enumerate(ident_data):
        row = t_ident.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
    format_table(t_ident, col_widths=[2.0, 4.5], header_bg='DCE7F5')

    # ==========================================
    # BAB 1. PENDAHULUAN
    # ==========================================
    doc.add_paragraph('Bab 1. Pendahuluan', style='Heading 2')
    add_guideline(doc, 'Panduan: Bab pembuka maksimal 1 halaman. Memberikan konteks ringkas agar penguji memahami domain masalah, arsitektur aplikasi, dan posisi capaian tim saat ini.')

    doc.add_paragraph('1.1 Gambaran Singkat Aplikasi', style='Heading 3')
    add_guideline(doc, 'Panduan: Tuliskan 3–4 kalimat padat yang menjawab: masalah apa yang diselesaikan, siapa target pengguna, dan apa proposisi nilai MyTeam. Hindari salin-tempel mentah dari PRD.')
    p_desc = doc.add_paragraph()
    p_desc.add_run(
        'MyTeam adalah aplikasi mobile berbasis Android yang dirancang khusus bagi mahasiswa Universitas Andalas '
        'untuk mengatasi kesulitan dalam menemukan rekan tim lomba, proyek akademik, maupun kegiatan organisasi yang relevan. '
        'Aplikasi ini memfasilitasi pencarian dan pembentukan tim dua arah (two-way discovery): pencari tim dapat menemukan tim yang membuka lowongan sesuai minat dan keahliannya, '
        'sedangkan ketua tim (pencari anggota) dapat melakukan pencarian bakat (talent scouting) terhadap profil mahasiswa untuk diajak bergabung secara langsung.'
    )

    doc.add_paragraph('1.2 Modul dan Komponen Teknologi', style='Heading 3')
    add_guideline(doc, 'Panduan: Sebutkan 4 modul utama beserta penanggung jawabnya (PIC), serta komponen teknologi yang benar-benar digunakan pada implementasi saat ini.')

    t_mod_tech = doc.add_table(rows=5, cols=3)
    t_mod_tech.style = 'Table Grid'
    mod_tech_data = [
        ('Modul Utama', 'Penanggung Jawab (PIC)', 'Fokus & Ruang Lingkup Pengerjaan'),
        ('Modul 1: Pengelolaan Data Riwayat Diri (Profil)', 'Fuadi Dhiyaulhaq (2411522001)', 'Data diri akademik, kontak, IPK, keahlian, minat, pengalaman portofolio, media sosial, tim diikuti, dan autentikasi.'),
        ('Modul 2: Pembuatan dan Pengelolaan Tim', 'Nayla Puspita Sari (2411521007)', 'Form pembuatan tim, upload poster/panduan lomba (native picker), daftar & detail tim dibuat, edit, serta hapus tim.'),
        ('Modul 3: Pencarian Tim & Pengajuan Bergabung', 'Rafa Gian Atthari (2411522014)', 'Feed tim/lomba terbaru, search & multi-criteria filter, detail tim, form apply posisi/pesan, dan status pengajuan.'),
        ('Modul 4: Pencarian Anggota & Pengajuan Anggota', 'Diva Ramadhani (2411521017)', 'Talent scouting kandidat berdasarkan skill/minat/nama, profil detail kandidat, kirim undangan bergabung, & respons undangan.'),
    ]
    for r_idx, (c0, c1, c2) in enumerate(mod_tech_data):
        row = t_mod_tech.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
        row.cells[2].paragraphs[0].add_run(c2)
    format_table(t_mod_tech, col_widths=[2.1, 1.9, 2.5])

    p_tech_space = doc.add_paragraph()
    p_tech_space.paragraph_format.space_before = Pt(4)

    t_tech = doc.add_table(rows=6, cols=2)
    t_tech.style = 'Table Grid'
    tech_data = [
        ('Komponen Teknologi', 'Teknologi yang Digunakan & Keterangan Implementasi'),
        ('Framework Mobile', 'Flutter (Dart SDK 3.x / Flutter 3.x)'),
        ('Platform Target', 'Android (Minimum SDK 26 / Android 8.0 Oreo, Target SDK 34)'),
        ('Backend & Database', 'MySQL Database (13 tabel relasional) + RESTful API Client (JSON API Contract v1.0.0)'),
        ('State Management', '[State management yang digunakan, mis. Provider / Riverpod / Bloc / setState terstruktur]'),
        ('Library & Dependensi Kunci', 'http / dio (network), shared_preferences (session), image_picker / file_picker (native upload), intl'),
    ]
    for r_idx, (c0, c1) in enumerate(tech_data):
        row = t_tech.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
    format_table(t_tech, col_widths=[2.3, 4.2])

    doc.add_paragraph('1.3 Ringkasan Kondisi Saat Ini', style='Heading 3')
    add_guideline(doc, 'Panduan: Tuliskan satu paragraf jujur dan objektif mengenai progress keseluruhan. Sebutkan jumlah modul yang sudah berjalan, normal flow yang sudah dapat didemokan, serta kendala terbesar saat ini.')
    p_cur = doc.add_paragraph()
    p_cur.add_run(
        'Sampai laporan Progress Report 1 ini dibuat, sebanyak [misal: 4 dari 4 modul] telah mulai diimplementasikan dengan tingkat ketercapaian rata-rata [misal: 70–85%]. '
        'Alur normal utama (normal flow) yang sudah dapat dijalankan dan didemokan secara penuh meliputi: '
        '[sebutkan alur utama yang sudah selesai dari awal sampai akhir, misal: Alur A penerimaan pengajuan tim dan Alur C pengajuan bergabung ke tim]. '
        'Skema database relasional (13 tabel) dan API contract telah berhasil dirancang serta diintegrasikan ke model aplikasi. '
        'Kendala utama yang dihadapi terletak pada [sebutkan kendala teknis terbesar, misal: sinkronisasi state filter multi-kriteria dan penanganan izin file native pada Android 13+], yang telah berhasil diatasi secara mandiri oleh tim.'
    )

    # ==========================================
    # BAB 2. PROGRESS APLIKASI (Bobot 40% - TARGET EXCELLENT)
    # ==========================================
    doc.add_paragraph('Bab 2. Progress Aplikasi', style='Heading 2')
    add_guideline(
        doc,
        'Panduan Penilaian Aspek Progress Aplikasi (Bobot 40% - Target 4 Poin / Excellent):\n'
        '• Progress sesuai/lebih dari target. Normal flow utama sudah berjalan dengan baik dan dapat didemokan secara utuh.\n'
        '• Tunjukkan bukti interaksi, pengelolaan state, validasi, dan navigasi nyata pada aplikasi yang berjalan (bukan mockup/desain statis).\n'
        '• Subbab 2.1 s.d 2.4 menyajikan status setiap modul dan kebutuhan fungsional (FR) secara terperinci bersama PIC.\n'
        '• Subbab 2.5 menyajikan arsitektur database & diagram ERD yang mendasari aplikasi.\n'
        '• Subbab 2.6 dan 2.7 membuktikan normal flow utama yang dapat didemokan per alur lengkap dengan screenshot berurutan.'
    )

    # 2.1 Modul 1
    doc.add_paragraph('2.1 Modul 1: Pengelolaan Data Riwayat Diri (Termasuk Akun)', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Modul 1: Jelaskan ruang lingkup modul, PIC yang bertanggung jawab, serta tabel status detail setiap Kebutuhan Fungsional (FR). '
        'Sebutkan interaksi nyata, perubahan state, validasi form, dan alur navigasi yang sudah berjalan.'
    )
    p_m1 = doc.add_paragraph()
    p_m1.add_run('• Penanggung Jawab (PIC): ').bold = True
    p_m1.add_run('Fuadi Dhiyaulhaq (2411522001)\n')
    p_m1.add_run('• Deskripsi Modul: ').bold = True
    p_m1.add_run(
        'Modul ini mencakup pengelolaan profil lengkap mahasiswa (data diri akademik, IPK, kontak, media sosial, keahlian, minat, portofolio kegiatan/lomba, dan riwayat tim yang diikuti) '
        'serta alur autentikasi pengguna (registrasi, login, logout, dan manajemen sesi token).'
    )
    p_m1_stat = doc.add_paragraph()
    p_m1_stat.add_run('• Status Ketercapaian Modul: ').bold = True
    p_m1_stat.add_run('[Selesai / Sebagian] – [x] dari 8 FR Berjalan ([persentase]%)')

    t_fr1 = doc.add_table(rows=9, cols=6)
    t_fr1.style = 'Table Grid'
    fr1_data = [
        ('No', 'Kode FR', 'Deskripsi Kebutuhan Fungsional', 'Status', 'Screen / Komponen', 'Interaksi, State, & Navigasi yang Berjalan'),
        ('1', 'FR-01', 'Pengguna dapat mengelola data diri berupa deskripsi singkat, kontak, prodi, fakultas, dan IPK.', '[Selesai/Proses]', 'ProfileScreen, EditDataDiriDialog', 'Validasi input IPK (0.00-4.00), sanitasi nomor kontak, update state profil, persistensi ke local/API, pop dialog.'),
        ('2', 'FR-02', 'Pengguna dapat mengelola media sosial berupa nama media sosial dan tautannya.', '[Selesai/Proses]', 'SocialMediaSection, AddEditSocialSheet', 'Validasi format URL media sosial, list reactive tautan sosmed, edit & hapus item sosial media.'),
        ('3', 'FR-03', 'Pengguna dapat mengelola minat berupa nama minat dan deskripsinya.', '[Selesai/Proses]', 'MinatChipGroup, AddMinatDialog', 'Pilihan chips minat dinamis, penambahan tag minat baru, state update instant pada kartu profil.'),
        ('4', 'FR-04', 'Pengguna dapat mengelola keahlian berupa nama keahlian dan deskripsinya.', '[Selesai/Proses]', 'KeahlianListWidget, SkillFormDialog', 'Input nama keahlian, pemilihan tingkat kemahiran, render daftar keahlian pada profil.'),
        ('5', 'FR-05', 'Pengguna dapat mengelola pengalaman (kegiatan, peran, tahun, deskripsi).', '[Selesai/Proses]', 'PengalamanTimeline, ExperienceForm', 'Form riwayat pengalaman, validasi tahun kegiatan, timeline card interaktif, aksi ubah dan hapus.'),
        ('6', 'FR-06', 'Pengguna dapat melihat informasi tim yang diikuti (nama tim, kegiatan, kategori, posisi).', '[Selesai/Proses]', 'TimDiikutiSection, TeamCardWidget', 'Fetch daftar tim dari state/API, render kartu keanggotaan tim, navigasi menuju halaman detail tim terkait.'),
        ('7', 'FR-07', 'Sistem dapat mengirimkan notifikasi terkait aktivitas data riwayat diri.', '[Selesai/Proses]', 'NotificationCenter, ProfileNotifier', 'Pemicu notifikasi in-app saat profil berhasil diperbarui, badge indikator notifikasi belum dibaca.'),
        ('8', 'Auth', 'Autentikasi Pengguna: Login NIM/Password, Registrasi Akun, Simpan Session Token.', '[Selesai/Proses]', 'LoginScreen, RegisterScreen, Splash', 'Validasi form login/register, enkripsi/hash sesi, SharedPreferences token persistence, auto-login di SplashScreen.'),
    ]
    for r_idx, (c0, c1, c2, c3, c4, c5) in enumerate(fr1_data):
        row = t_fr1.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3, c4, c5]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_fr1, col_widths=[0.4, 0.7, 1.9, 0.9, 1.2, 1.4])

    # 2.2 Modul 2
    doc.add_paragraph('2.2 Modul 2: Pembuatan dan Pengelolaan Tim', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Modul 2: Jelaskan PIC, deskripsi modul, dan tabel kondisi setiap FR. '
        'Pastikan menekankan fitur unggah dokumen/poster native yang merupakan persyaratan teknis.'
    )
    p_m2 = doc.add_paragraph()
    p_m2.add_run('• Penanggung Jawab (PIC): ').bold = True
    p_m2.add_run('Nayla Puspita Sari (2411521007)\n')
    p_m2.add_run('• Deskripsi Modul: ').bold = True
    p_m2.add_run(
        'Modul ini memfasilitasi mahasiswa yang bertindak sebagai inisiator/pembuat tim untuk mendirikan tim baru, '
        'menentukan kategori dan spesifikasi kebutuhan anggota, mengunggah poster/panduan lomba (fitur native mobile), '
        'serta mengelola (melihat daftar, memperbarui data, atau menghapus) tim yang dimiliki.'
    )
    p_m2_stat = doc.add_paragraph()
    p_m2_stat.add_run('• Status Ketercapaian Modul: ').bold = True
    p_m2_stat.add_run('[Selesai / Sebagian] – [x] dari 5 FR Berjalan ([persentase]%)')

    t_fr2 = doc.add_table(rows=6, cols=6)
    t_fr2.style = 'Table Grid'
    fr2_data = [
        ('No', 'Kode FR', 'Deskripsi Kebutuhan Fungsional', 'Status', 'Screen / Komponen', 'Interaksi, State, & Navigasi yang Berjalan'),
        ('1', 'FR-08', 'Pengguna dapat membuat tim baru dengan mengisi info dan mengunggah poster/panduan (native).', '[Selesai/Proses]', 'CreateTeamScreen, NativePickerWidget', 'Integrasi Image/FilePicker ke storage native Android, image preview, validasi form kuota anggota, simpan ke database.'),
        ('2', 'FR-09', 'Pengguna dapat melihat daftar dan detail tim yang telah dibuatnya.', '[Selesai/Proses]', 'MyTeamsScreen, CreatorTeamDetailScreen', 'Dynamic list tim yang dibuat oleh user saat ini, hitung sisa kuota anggota, navigasi ke detail manajemen tim.'),
        ('3', 'FR-10', 'Pengguna dapat mengubah informasi dan dokumen pendukung pada tim (kecuali kategori).', '[Selesai/Proses]', 'EditTeamScreen, DocumentUpdateWidget', 'Prefill data tim yang sudah ada, penguncian field kategori lomba, pembaruan berkas poster, notifikasi sukses update.'),
        ('4', 'FR-11', 'Pengguna dapat menghapus tim yang telah dibuat.', '[Selesai/Proses]', 'DeleteConfirmDialog', 'Dialog konfirmasi aksi destruktif, penghapusan tim beserta relasi kebutuhan/pengajuan, refresh otomatis list tim.'),
        ('5', 'FR-12', 'Pengguna menerima notifikasi ketika terdapat pengajuan bergabung ke tim yang dibuatnya.', '[Selesai/Proses]', 'TeamNotificationBadge, NotificationList', 'Listener notifikasi pengajuan baru, badge counter merah pada menu pengajuan tim, direct tap menuju daftar pengajuan.'),
    ]
    for r_idx, (c0, c1, c2, c3, c4, c5) in enumerate(fr2_data):
        row = t_fr2.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3, c4, c5]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_fr2, col_widths=[0.4, 0.7, 1.9, 0.9, 1.2, 1.4])

    # 2.3 Modul 3
    doc.add_paragraph('2.3 Modul 3: Pencarian Tim & Pengajuan Bergabung', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Modul 3: Jelaskan PIC, deskripsi modul, dan tabel kondisi setiap FR. '
        'Tunjukkan fitur pencarian, filter, tampilan detail tim, dan mekanisme pengajuan bergabung (join request).'
    )
    p_m3 = doc.add_paragraph()
    p_m3.add_run('• Penanggung Jawab (PIC): ').bold = True
    p_m3.add_run('Rafa Gian Atthari (2411522014)\n')
    p_m3.add_run('• Deskripsi Modul: ').bold = True
    p_m3.add_run(
        'Modul ini dirancang bagi pencari tim untuk menelusuri feed tim lomba yang sedang membuka rekrutmen, '
        'melakukan pencarian cerdas dan pemfilteran multi-kategori, melihat detail deskripsi dan posisi yang dicari, '
        'serta mengirimkan permohonan bergabung (apply) yang dapat diproses (diterima/ditolak) oleh pembuat tim.'
    )
    p_m3_stat = doc.add_paragraph()
    p_m3_stat.add_run('• Status Ketercapaian Modul: ').bold = True
    p_m3_stat.add_run('[Selesai / Sebagian] – [x] dari 8 FR Berjalan ([persentase]%)')

    t_fr3 = doc.add_table(rows=9, cols=6)
    t_fr3.style = 'Table Grid'
    fr3_data = [
        ('No', 'Kode FR', 'Deskripsi Kebutuhan Fungsional', 'Status', 'Screen / Komponen', 'Interaksi, State, & Navigasi yang Berjalan'),
        ('1', 'FR-13', 'Pengguna dapat melihat feed tim atau kegiatan terbaru yang tersedia.', '[Selesai/Proses]', 'HomeScreen, TeamFeedCardWidget', 'List feed real-time tim yang aktif, lazy loading / pull-to-refresh, badge kategori kegiatan dan sisa slot anggota.'),
        ('2', 'FR-14', 'Pengguna dapat melakukan pencarian dan penyaringan tim berdasarkan kriteria.', '[Selesai/Proses]', 'SearchTeamScreen, FilterBottomSheet', 'Search field dengan debounce query, filter chip kategori & skill, reaktif memfilter daftar kartu tanpa freeze.'),
        ('3', 'FR-15', 'Pengguna dapat melihat detail tim dari hasil pencarian.', '[Selesai/Proses]', 'PublicTeamDetailScreen', 'Tampilan lengkap deskripsi lomba, dokumen poster, daftar keahlian yang dibutuhkan, kuota slot, dan profil ketua.'),
        ('4', 'FR-16', 'Pengguna dapat mengajukan bergabung ke tim (pilih posisi & pesan pengajuan).', '[Selesai/Proses]', 'ApplyTeamBottomSheet', 'Dropdown pilihan posisi yang tersedia, textarea pesan motivasi, validasi tidak bisa mendaftar ganda, status pending.'),
        ('5', 'FR-17', 'Pembuat tim dapat melihat daftar pengajuan bergabung ke timnya.', '[Selesai/Proses]', 'ManageApplicationsScreen', 'Tab pengajuan masuk per tim, badge jumlah pengajuan pending, list kartu pelamar dengan indikator status.'),
        ('6', 'FR-18', 'Pembuat tim dapat melihat detail pengajuan (posisi, pesan, profil pelamar).', '[Selesai/Proses]', 'ApplicationDetailDialog', 'Menampilkan pesan pelamar, tautan preview profil lengkap pelamar, kontak, dan riwayat prestasi.'),
        ('7', 'FR-19', 'Pembuat tim dapat menerima atau menolak pengajuan bergabung.', '[Selesai/Proses]', 'ApprovalActionButtons', 'Tombol Terima dan Tolak, update status pengajuan di database, kuota posisi berkurang otomatis jika diterima.'),
        ('8', 'FR-20', 'Pengguna dapat melihat status pengajuan bergabung dan notifikasi perubahannya.', '[Selesai/Proses]', 'MyApplicationsScreen, NotificationItem', 'Daftar riwayat permohonan user (Menunggu/Diterima/Ditolak), alert notifikasi saat pengajuan disetujui/ditolak.'),
    ]
    for r_idx, (c0, c1, c2, c3, c4, c5) in enumerate(fr3_data):
        row = t_fr3.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3, c4, c5]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_fr3, col_widths=[0.4, 0.7, 1.9, 0.9, 1.2, 1.4])

    # 2.4 Modul 4
    doc.add_paragraph('2.4 Modul 4: Pencarian Anggota & Pengajuan Anggota (Talent Scouting)', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Modul 4: Jelaskan PIC, deskripsi modul, dan tabel kondisi setiap FR. '
        'Tunjukkan fitur pencarian calon rekan tim berbasis keahlian/minat, melihat profil kandidat, dan alur pengajuan undangan tim.'
    )
    p_m4 = doc.add_paragraph()
    p_m4.add_run('• Penanggung Jawab (PIC): ').bold = True
    p_m4.add_run('Diva Ramadhani (2411521017)\n')
    p_m4.add_run('• Deskripsi Modul: ').bold = True
    p_m4.add_run(
        'Modul ini melengkapi kemampuan two-way matching dengan memberikan fasilitas bagi pembuat tim untuk mencari calon anggota '
        'berdasarkan kriteria spesifik (nama, minat, keahlian, dan rekam jejak portofolio), memeriksa profil kandidat secara mendalam, '
        'serta mengirimkan undangan bergabung ke tim (direct invitation) yang dapat diterima atau ditolak oleh calon anggota.'
    )
    p_m4_stat = doc.add_paragraph()
    p_m4_stat.add_run('• Status Ketercapaian Modul: ').bold = True
    p_m4_stat.add_run('[Selesai / Sebagian] – [x] dari 5 FR Berjalan ([persentase]%)')

    t_fr4 = doc.add_table(rows=6, cols=6)
    t_fr4.style = 'Table Grid'
    fr4_data = [
        ('No', 'Kode FR', 'Deskripsi Kebutuhan Fungsional', 'Status', 'Screen / Komponen', 'Interaksi, State, & Navigasi yang Berjalan'),
        ('1', 'FR-21', 'Pengguna dapat mencari calon anggota berdasarkan nama, keahlian, pengalaman, dan minat.', '[Selesai/Proses]', 'SearchMemberScreen, FilterMemberDialog', 'Input pencarian kata kunci, filter chips multi-kategori keahlian & minat, list kartu mahasiswa dengan highlight match.'),
        ('2', 'FR-22', 'Pengguna dapat melihat detail profil calon anggota dari hasil pencarian.', '[Selesai/Proses]', 'MemberProfileDetailScreen', 'Tampilan komprehensif bio, prodi, IPK, keahlian, tautan sosmed, dan riwayat pengalaman mahasiswa yang dipilih.'),
        ('3', 'FR-23', 'Pembuat tim dapat mengajukan permintaan ke calon anggota untuk bergabung ke timnya (kirim undangan).', '[Selesai/Proses]', 'InviteMemberBottomSheet', 'Modal dialog untuk memilih tim yang dimiliki, menentukan posisi tawaran, mengisi pesan ajakan, dan mengirim undangan.'),
        ('4', 'FR-24', 'Calon anggota dapat melihat detail tim dan menerima atau menolak pengajuan bergabung (undangan).', '[Selesai/Proses]', 'InvitationsInboxScreen, RespondInviteWidget', 'Layar kotak masuk undangan tim, detail tim pengundang, tombol aksi Terima/Tolak, pembaruan status keanggotaan.'),
        ('5', 'FR-25', 'Pembuat tim menerima notifikasi ketika ada respons undangan (diterima/ditolak) dari calon anggota.', '[Selesai/Proses]', 'NotificationCenter, PushListener', 'Notifikasi pembaruan saat calon anggota menerima tawaran, penambahan anggota ke daftar tim pembuat secara reaktif.'),
    ]
    for r_idx, (c0, c1, c2, c3, c4, c5) in enumerate(fr4_data):
        row = t_fr4.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3, c4, c5]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_fr4, col_widths=[0.4, 0.7, 1.9, 0.9, 1.2, 1.4])

    # 2.5 ARSITEKTUR DATA & ERD
    doc.add_paragraph('2.5 Arsitektur Basis Data & Entity Relationship Diagram (ERD)', style='Heading 3')
    add_guideline(
        doc,
        'Panduan ERD & Basis Data: Pada Progress Report 1 ini, tim telah menyelesaikan perancangan dan implementasi skema basis data relasional '
        'yang menghubungkan ke-4 modul (mengacu pada erd_myteam.dbml dan schema_myteam.sql). '
        'Sisipkan gambar diagram ERD pada kotak di bawah, dan lengkapi penjelasan mengenai relasi antarentitas pada tabel yang disediakan. '
        'Ini membuktikan bahwa aplikasi didukung oleh arsitektur data yang kokoh dan bukan sekadar antarmuka statis.'
    )
    add_placeholder_box(
        doc,
        'Sisipkan Gambar 2.1 – Diagram Entity Relationship Diagram (ERD) MyTeam (Hasil ekspor dbml.dbdiagram.io dari erd_myteam.dbml)'
    )
    p_erd_desc = doc.add_paragraph()
    p_erd_desc.add_run(
        'Basis data MyTeam terdiri atas 13 tabel relasional yang saling terintegrasi untuk menjamin konsistensi data (NFR-06 dan NFR-07). '
        'Tabel di bawah merangkum struktur entitas utama dan perannya dalam mendukung alur bisnis aplikasi:'
    )

    t_erd = doc.add_table(rows=14, cols=4)
    t_erd.style = 'Table Grid'
    erd_data = [
        ('No', 'Entitas / Nama Tabel', 'Modul Terkait', 'Fungsi Utama & Keterangan Relasi'),
        ('1', 'Pengguna', 'Modul 1 & Auth', 'Menyimpan kredensial akun, NIM unik, email kampus, password hash, dan role pengguna.'),
        ('2', 'Data_Diri', 'Modul 1 (Profil)', 'Relasi 1-to-1 dengan Pengguna; menyimpan deskripsi singkat, kontak, program studi, fakultas, dan IPK.'),
        ('3', 'Media_Sosial', 'Modul 1 (Profil)', 'Relasi 1-to-Many dengan Pengguna; menyimpan tautan akun seperti LinkedIn, GitHub, Instagram.'),
        ('4', 'Data_Minat', 'Modul 1 & 4', 'Menyimpan preferensi minat mahasiswa (kategori lomba, teknologi, bidang riset).'),
        ('5', 'Data_Keahlian', 'Modul 1 & 4', 'Menyimpan daftar skill teknis/non-teknis serta level kemahiran untuk pencocokan kandidat.'),
        ('6', 'Data_Pengalaman', 'Modul 1 (Profil)', 'Relasi 1-to-Many dengan Pengguna; portofolio rekam jejak lomba, organisasi, dan kepanitiaan.'),
        ('7', 'Data_Tim', 'Modul 2 & 3', 'Menyimpan data tim yang dibentuk (nama tim, nama lomba, kategori kegiatan, status rekrutmen, ID pembuat).'),
        ('8', 'Kebutuhan_Anggota_Tim', 'Modul 2 & 3', 'Relasi 1-to-Many dengan Data_Tim; mendefinisikan posisi/role yang dicari, jumlah kuota, dan deskripsi tugas.'),
        ('9', 'Dokumen_Pendukung', 'Modul 2 (Native)', 'Menyimpan metadata dan path berkas poster lomba atau panduan kegiatan yang diunggah via native picker.'),
        ('10', 'Anggota_Tim', 'Modul 2 & 3', 'Tabel perantara relasi Many-to-Many antara Pengguna dan Data_Tim; mencatat anggota aktif dan perannya.'),
        ('11', 'Pengajuan_Bergabung_Tim', 'Modul 3 (Alur C & A)', 'Mencatat permohonan dari pencari tim ke tim (apply request) beserta posisi, pesan pengajuan, dan status.'),
        ('12', 'Pengajuan_Anggota', 'Modul 4 (Alur B & D)', 'Mencatat undangan dari pembuat tim ke calon anggota (talent invitation) beserta pesan ajakan dan status respons.'),
        ('13', 'Notifikasi', 'Lintas Modul', 'Menyimpan rekam jejak pemberitahuan sistem (pemicu event pengajuan, persetujuan, dan perubahan profil).'),
    ]
    for r_idx, (c0, c1, c2, c3) in enumerate(erd_data):
        row = t_erd.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_erd, col_widths=[0.4, 1.8, 1.5, 2.8])

    # 2.6 FLOW UTAMA APLIKASI
    doc.add_paragraph('2.6 Flow Utama Aplikasi yang Sudah Berjalan', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Flow Utama (NFR-09): Tunjukkan integrasi antarmodul melalui 4 alur pengguna utama dari PRD. '
        'Jelaskan langkah mana yang sudah berjalan penuh dan di langkah mana alur masih dalam proses.'
    )

    t_flow = doc.add_table(rows=5, cols=3)
    t_flow.style = 'Table Grid'
    flow_data = [
        ('Alur Pengguna (Berdasarkan PRD MyTeam)', 'Langkah Alur yang Sudah Berjalan Nyata', 'Kondisi / Terhenti di'),
        (
            'Alur A: Pencari Anggota Menerima Pengajuan\n'
            '(Daftar/Login → Beranda → Kelola Tim → Notifikasi/Daftar Pengajuan → Detail Calon Anggota → Konfirmasi Terima/Tolak)',
            'Login → Beranda → Menu Tim Saya → Buka Daftar Pengajuan Masuk → Lihat Detail Profil & Pesan Pelamar → Klik Tombol Terima/Tolak → Kuota Tim Ter-update.',
            '[Selesai penuh / Terhenti di langkah: ...]'
        ),
        (
            'Alur B: Pencari Anggota Mengajukan ke Calon Anggota\n'
            '(Beranda → Cari Calon Anggota → Filter Keahlian → Profil Lengkap → Kirim Undangan Tim → Notifikasi Respons)',
            'Login → Beranda → Menu Cari Anggota → Terapkan Filter Keahlian → Buka Profil Lengkap Mahasiswa → Klik "Ajak Bergabung" → Pilih Tim & Posisi → Kirim Undangan.',
            '[Selesai penuh / Terhenti di langkah: ...]'
        ),
        (
            'Alur C: Pencari Tim Mengajukan ke Tim\n'
            '(Feed Tim → Cari/Filter Tim → Detail Tim & Kebutuhan Posisi → Ajukan Bergabung → Monitoring Status Pengajuan)',
            'Login → Feed Beranda → Cari Tim Lomba → Buka Detail Tim → Klik "Ajukan Bergabung" → Pilih Posisi & Isi Pesan Motivasi → Kirim → Status Masuk ke "Pengajuan Saya".',
            '[Selesai penuh / Terhenti di langkah: ...]'
        ),
        (
            'Alur D: Pencari Tim Menerima Undangan dari Pembuat Tim\n'
            '(Notifikasi Masuk → Detail Undangan Tim → Terima / Tolak Undangan → Update Status Keanggotaan)',
            'Buka Kotak Notifikasi / Undangan → Tampilkan Kartu Tawaran Tim → Buka Detail Profil Tim Pengundang → Klik "Terima Tawaran" → Mahasiswa Otomatis Masuk Anggota Tim.',
            '[Selesai penuh / Terhenti di langkah: ...]'
        ),
    ]
    for r_idx, (c0, c1, c2) in enumerate(flow_data):
        row = t_flow.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
        row.cells[2].paragraphs[0].add_run(c2)
    format_table(t_flow, col_widths=[2.4, 2.8, 1.3])

    # 2.7 BUKTI APLIKASI BERJALAN PER ALUR
    doc.add_paragraph('2.7 Bukti Aplikasi Berjalan (Demo & Screenshot)', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Bukti Aplikasi Berjalan: Sajikan tangkapan layar (screenshot) berurutan dari aplikasi yang dieksekusi di emulator/perangkat riil '
        'untuk masing-masing alur pada subbab 2.7.1 s.d 2.7.4. Berikan penjelasan naratif mengenai aksi pengguna, perubahan state, dan persistensi data pada setiap gambar. '
        'Cantumkan tautan rekaman video demo 1–3 menit sebagai bukti pendukung.'
    )
    p_vdemo = doc.add_paragraph()
    p_vdemo.add_run('• Tautan Video Demo Interaktif: ').bold = True
    p_vdemo.add_run('[Sisipkan tautan video demo aplikasi berjalan berdurasi 1–3 menit, misal: Google Drive / YouTube Unlisted]')

    # 2.7.1
    doc.add_paragraph('2.7.1 Alur A: Pencari Anggota Menerima Pengajuan Bergabung', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Alur A: Tampilkan screenshot berurutan proses pembuat tim menerima pelamar: mulai dari notifikasi pengajuan masuk, '
        'membuka detail pengajuan dan rekam jejak pelamar, hingga menekan tombol terima dan melihat perubahan jumlah kuota tim.'
    )
    add_placeholder_box(doc, 'Sisipkan Gambar 2.2a – Layar Daftar Pengajuan Masuk pada Tim (Menampilkan daftar kandidat pelamar)')
    add_placeholder_box(doc, 'Sisipkan Gambar 2.2b – Layar Detail Pengajuan & Profil Pelamar (Menampilkan pesan motivasi dan keahlian)')
    add_placeholder_box(doc, 'Sisipkan Gambar 2.2c – Status Pengajuan Berubah & Anggota Tim Bertambah (Konfirmasi penerimaan pelamar)')
    p_exp_a = doc.add_paragraph()
    p_exp_a.add_run('Penjelasan Alur A: ').bold = True
    p_exp_a.add_run(
        '[Jelaskan interaksi, validasi state, perubahan data di database, dan alur navigasi dari Gambar 2.2a sampai 2.2c]'
    )

    # 2.7.2
    doc.add_paragraph('2.7.2 Alur B: Pencari Anggota Mengajukan ke Calon Anggota (Undangan Tim)', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Alur B: Tampilkan screenshot pencarian calon anggota (talent scouting): memasukkan kata kunci/filter keahlian, '
        'membuka profil detail kandidat, membuka modal undangan tim, memilih posisi, dan konfirmasi undangan terkirim.'
    )
    add_placeholder_box(doc, 'Sisipkan Gambar 2.3a – Layar Pencarian & Filter Mahasiswa Berdasarkan Keahlian/Minat')
    add_placeholder_box(doc, 'Sisipkan Gambar 2.3b – Layar Detail Profil Kandidat Anggota (Bio, IPK, Skill, Portofolio Pengalaman)')
    add_placeholder_box(doc, 'Sisipkan Gambar 2.3c – Modal Kirim Undangan Tim & Notifikasi Berhasil Terkirim')
    p_exp_b = doc.add_paragraph()
    p_exp_b.add_run('Penjelasan Alur B: ').bold = True
    p_exp_b.add_run(
        '[Jelaskan interaksi, validasi state, perubahan data di database, dan alur navigasi dari Gambar 2.3a sampai 2.3c]'
    )

    # 2.7.3
    doc.add_paragraph('2.7.3 Alur C: Pencari Tim Mengajukan ke Tim (Join Request)', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Alur C: Tampilkan screenshot pencari tim menelusuri feed tim lomba, membuka detail tim, '
        'menekan tombol ajukan bergabung, mengisi posisi dan pesan pengajuan, serta melihat status permohonan pada daftar pengajuan diri.'
    )
    add_placeholder_box(doc, 'Sisipkan Gambar 2.4a – Layar Feed Utama & Filter Kategori Tim Lomba')
    add_placeholder_box(doc, 'Sisipkan Gambar 2.4b – Layar Detail Tim Lomba & Daftar Posisi/Kebutuhan Anggota')
    add_placeholder_box(doc, 'Sisipkan Gambar 2.4c – Form Permohonan Bergabung & Layar Status Pengajuan Saya')
    p_exp_c = doc.add_paragraph()
    p_exp_c.add_run('Penjelasan Alur C: ').bold = True
    p_exp_c.add_run(
        '[Jelaskan interaksi, validasi state, perubahan data di database, dan alur navigasi dari Gambar 2.4a sampai 2.4c]'
    )

    # 2.7.4
    doc.add_paragraph('2.7.4 Alur D: Pencari Tim Menerima Undangan dari Pembuat Tim', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Alur D: Tampilkan screenshot mahasiswa menerima notifikasi undangan tim masuk, memeriksa detail tim yang mengundang, '
        'dan mengeksekusi aksi penerimaan/penolakan tawaran hingga status tim yang diikuti ter-update.'
    )
    add_placeholder_box(doc, 'Sisipkan Gambar 2.5a – Layar Kotak Masuk Notifikasi & Kartu Undangan Tim Masuk')
    add_placeholder_box(doc, 'Sisipkan Gambar 2.5b – Layar Detail Undangan Tim & Opsi Aksi Terima / Tolak')
    add_placeholder_box(doc, 'Sisipkan Gambar 2.5c – Konfirmasi Bergabung & Pembaruan Daftar Tim yang Diikuti pada Profil')
    p_exp_d = doc.add_paragraph()
    p_exp_d.add_run('Penjelasan Alur D: ').bold = True
    p_exp_d.add_run(
        '[Jelaskan interaksi, validasi state, perubahan data di database, dan alur navigasi dari Gambar 2.5a sampai 2.5c]'
    )

    # 2.8 Rencana Pekerjaan Berikutnya
    doc.add_paragraph('2.8 Rencana Pekerjaan Berikutnya', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Pekerjaan Berikutnya: Susun daftar prioritas pengembangan pasca-Progress Report 1. '
        'Fokus pada penyempurnaan alur yang belum tuntas, integrasi penuh dengan backend API, dan polishing antarmuka.'
    )
    t_next = doc.add_table(rows=5, cols=4)
    t_next.style = 'Table Grid'
    next_data = [
        ('Prioritas', 'Deskripsi Pekerjaan / Fitur yang Akan Dikerjakan', 'PIC', 'Target Waktu'),
        ('Prioritas 1', 'Penyelesaian integrasi endpoint pengunggahan dokumen native ke server & penyimpanan file cloud.', 'Nayla Puspita Sari', 'Minggu ke-8'),
        ('Prioritas 2', 'Implementasi caching lokal dan optimasi waktu pemuatan feed/search (NFR-01 dan NFR-02 ≤ 3 detik).', 'Rafa Gian Atthari', 'Minggu ke-8'),
        ('Prioritas 3', 'Penyempurnaan push notification system untuk event pengajuan dan respons undangan secara real-time.', 'Fuadi Dhiyaulhaq', 'Minggu ke-9'),
        ('Prioritas 4', 'Pengujian terintegrasi lintas modul (end-to-end user acceptance testing) dan perbaikan bug minor.', 'Diva Ramadhani', 'Minggu ke-9'),
    ]
    for r_idx, (c0, c1, c2, c3) in enumerate(next_data):
        row = t_next.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_next, col_widths=[0.9, 3.4, 1.4, 0.8])

    # ==========================================
    # BAB 3. KENDALA DAN SOLUSI (Bobot 20% - TARGET EXCELLENT)
    # ==========================================
    doc.add_paragraph('Bab 3. Kendala dan Solusi', style='Heading 2')
    add_guideline(
        doc,
        'Panduan Penilaian Aspek Kendala & Solusi (Bobot 20% - Target 4 Poin / Excellent):\n'
        '• Mampu menjelaskan kendala, penyebab teknis, solusi yang dilakukan, dan hasilnya dengan jelas.\n'
        '• Sebagian besar masalah diselesaikan secara mandiri oleh tim (menunjukkan proses troubleshooting yang logis).\n'
        '• Tuliskan 3–4 kendala nyata yang memakan usaha teknis. Setiap kendala diuraikan pada subbab tersendiri (3.2.1, 3.2.2, 3.2.3, dst.) '
        'menggunakan 4 unsur wajib: Masalah, Penyebab, Solusi Mandiri, dan Hasil Nyata + Bukti Error/Kode/Screenshot.'
    )

    doc.add_paragraph('3.1 Ringkasan Kendala', style='Heading 3')
    add_guideline(doc, 'Panduan: Tabel ringkasan seluruh kendala utama untuk memudahkan pemindaian cepat oleh dosen penilai.')

    t_kend_sum = doc.add_table(rows=4, cols=4)
    t_kend_sum.style = 'Table Grid'
    kend_sum_data = [
        ('No', 'Judul Kendala Utama', 'Modul Terkait & PIC', 'Status Penyelesaian'),
        ('1', 'Izin Akses File & Media Native Android 13+ (Granular Permissions)', 'Modul 2 (Nayla) / Core', 'Teratasi Penuh (Solusi Mandiri)'),
        ('2', 'Sinkronisasi State Filter Multi-Kriteria pada Pencarian Tanpa Lag', 'Modul 3 (Rafa) & Modul 4 (Diva)', 'Teratasi Penuh (Solusi Mandiri)'),
        ('3', 'Validasi Integritas Relasi Pengajuan Dua Arah pada Database/API', 'Modul 1 (Fuadi) / Database', 'Teratasi Penuh (Solusi Mandiri)'),
    ]
    for r_idx, (c0, c1, c2, c3) in enumerate(kend_sum_data):
        row = t_kend_sum.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_kend_sum, col_widths=[0.4, 3.3, 1.7, 1.1])

    doc.add_paragraph('3.2 Uraian Kendala dan Solusi', style='Heading 3')
    add_guideline(
        doc,
        'Panduan: Uraikan masing-masing kendala ke dalam subbab tersendiri (3.2.1, 3.2.2, 3.2.3). '
        'Pastikan mencakup 4 unsur lengkap: Masalah, Penyebab, Cara Mengatasi, dan Hasil Nyata beserta bukti pendukung.'
    )

    # 3.2.1
    doc.add_paragraph('3.2.1 Kendala 1: Penanganan Izin Akses Media Native (Image & Document Picker) pada Android 13+', style='Heading 3')
    t_k1 = doc.add_table(rows=5, cols=2)
    t_k1.style = 'Table Grid'
    k1_data = [
        ('Unsur Evaluasi', 'Penjelasan Teknis Kendala dan Solusi'),
        ('1. Masalah yang Dihadapi', 'Saat mengunggah poster lomba atau dokumen pendukung pada Modul 2 di perangkat Android 13 ke atas, aplikasi mengalami crash atau dialog pemilihan berkas tidak muncul sama sekali.'),
        ('2. Penyebab Masalah', 'Android 13 (API 33) memperkenalkan granular media permissions (READ_MEDIA_IMAGES) yang menggantikan izin lama READ_EXTERNAL_STORAGE, sehingga pemanggilan permission konvensional ditolak oleh sistem.'),
        ('3. Solusi & Langkah Mandiri', 'Memperbarui AndroidManifest.xml dengan deklarasi izin granular, mengimplementasikan pengecekan versi SDK dinamis (Platform.isAndroid && sdkInt >= 33), serta menggunakan package file_picker / image_picker versi kompatibel yang memanfaatkan Photo Picker Android tanpa memerlukan izin storage penuh.'),
        ('4. Hasil Setelah Solusi', 'Pengguna di Android 8 hingga Android 14 dapat memilih berkas poster gambar dan dokumen panduan PDF dengan lancar tanpa crash, dan gambar dapat ditampilkan kembali di layar preview.'),
    ]
    for r_idx, (c0, c1) in enumerate(k1_data):
        row = t_k1.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
    format_table(t_k1, col_widths=[1.8, 4.7])
    add_placeholder_box(doc, 'Bukti Pendukung Kendala 1: Cuplikan Pesan Error Logcat / Potongan Perubahan AndroidManifest / Screenshot Dialog Izin')

    # 3.2.2
    doc.add_paragraph('3.2.2 Kendala 2: Sinkronisasi State Filter Multi-Kriteria pada Pencarian Tim dan Anggota', style='Heading 3')
    t_k2 = doc.add_table(rows=5, cols=2)
    t_k2.style = 'Table Grid'
    k2_data = [
        ('Unsur Evaluasi', 'Penjelasan Teknis Kendala dan Solusi'),
        ('1. Masalah yang Dihadapi', 'Pada Modul 3 dan Modul 4, ketika pengguna memilih kombinasi filter (kategori kegiatan + keahlian + kata kunci pencarian), daftar hasil pencarian tidak sinkron dan memicu multiple redundant API calls yang menyebabkan stutter pada UI.'),
        ('2. Penyebab Masalah', 'Setiap perubahan chip filter langsung memicu request fetch ke state management tanpa debounce, sehingga terjadi race condition di mana respons request lama menimpa respons request terbaru.'),
        ('3. Solusi & Langkah Mandiri', 'Mengimplementasikan ValueNotifier / Debouncer (300ms) pada text search, serta menggabungkan seluruh parameter filter ke dalam satu immutable filter state model sebelum mengeksekusi satu kali query penyaringan.'),
        ('4. Hasil Setelah Solusi', 'Penyaringan data berjalan sangat mulus (respons < 1 detik), UI bebas freeze, dan hasil pencarian selalu akurat sesuai kombinasi filter yang dipilih pengguna.'),
    ]
    for r_idx, (c0, c1) in enumerate(k2_data):
        row = t_k2.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
    format_table(t_k2, col_widths=[1.8, 4.7])
    add_placeholder_box(doc, 'Bukti Pendukung Kendala 2: Diagram Alur Debounce / Perbandingan Performa Sebelum & Sesudah / Screenshot Filter')

    # 3.2.3
    doc.add_paragraph('3.2.3 Kendala 3: Validasi Konsistensi Data Relasional Pengajuan Dua Arah pada Database/API', style='Heading 3')
    t_k3 = doc.add_table(rows=5, cols=2)
    t_k3.style = 'Table Grid'
    k3_data = [
        ('Unsur Evaluasi', 'Penjelasan Teknis Kendala dan Solusi'),
        ('1. Masalah yang Dihadapi', 'Terjadi kondisi inkonsistensi data di mana seorang mahasiswa dapat mengajukan permohonan bergabung berkali-kali ke tim yang sama, atau pembuat tim dapat mengundang anggota yang sudah berstatus aktif di dalam tim.'),
        ('2. Penyebab Masalah', 'Tabel pengajuan awal belum memiliki constraint unik komposit pada pasangan (id_tim, id_pengguna) dan pengecekan di tingkat model aplikasi belum memvalidasi status keanggotaan aktif.'),
        ('3. Solusi & Langkah Mandiri', 'Menambahkan constraint UNIQUE (id_tim, id_pengguna, status_pengajuan) pada schema_myteam.sql / DBML, serta membangun middleware validasi business logic pada API/Service sebelum insert permohonan.'),
        ('4. Hasil Setelah Solusi', 'Integritas data terjamin 100%; tombol "Ajukan" otomatis dinonaktifkan (disabled) dan berubah label menjadi "Menunggu Respons" jika permohonan sedang aktif.'),
    ]
    for r_idx, (c0, c1) in enumerate(k3_data):
        row = t_k3.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
    format_table(t_k3, col_widths=[1.8, 4.7])
    add_placeholder_box(doc, 'Bukti Pendukung Kendala 3: Potongan Constraint SQL / Validasi State Tombol pada UI / Screenshot Feedback Error')

    # ==========================================
    # BAB 4. CODE AUDIT DAN REFACTORING (Bobot 25% - TARGET EXCELLENT)
    # ==========================================
    doc.add_paragraph('Bab 4. Code Audit dan Refactoring', style='Heading 2')
    add_guideline(
        doc,
        'Panduan Penilaian Aspek Code Audit & Refactoring (Bobot 25% - Target 4 Poin / Excellent):\n'
        '• Melakukan audit terhadap kode, menemukan masalah yang relevan, melakukan refactoring nyata, dan menjelaskan alasan perbaikan secara mendalam.\n'
        '• Refactoring bertujuan memperbaiki struktur, keterbacaan, dan modularitas kode TANPA mengubah fungsi utama aplikasi.\n'
        '• Wajib menyajikan minimal 2–3 contoh nyata before–after dari kode asli tim di repository.\n'
        '• Subbab 4.3 dibagi menjadi subbab 4.3.1, 4.3.2, 4.3.3 dst. lengkap dengan tabel evaluasi dan blok kode perbandingan.'
    )

    doc.add_paragraph('4.1 Metodologi & Kriteria Audit Kode', style='Heading 3')
    add_guideline(
        doc,
        'Panduan: Jelaskan siapa yang melakukan audit, folder/file apa yang diaudit, dan 4 kriteria audit yang digunakan '
        '(kode terlalu panjang, kode berulang, penamaan variabel/fungsi kurang deskriptif, serta pencampuran UI dan business logic).'
    )
    p_audit_desc = doc.add_paragraph()
    p_audit_desc.add_run(
        'Audit kode dilakukan secara berkala oleh seluruh anggota tim Kelompok 5 pada struktur codebase lib/ (fitur auth, profile, team, dan shared widgets). '
        'Audit difokuskan pada pemenuhan prinsip Clean Code dan arsitektur Flutter yang baik, dengan 4 kriteria utama:\n'
        '1. Kode Terlalu Panjang (Long Methods/Classes): File atau widget melebihi 250 baris dipecah menjadi sub-komponen terisolasi.\n'
        '2. Duplikasi Kode (DRY Violation): Komponen antarmuka atau logika formatting yang ditulis berulang diangkat menjadi reusable widget/helper.\n'
        '3. Penamaan Variabel & Fungsi (Naming Convention): Memperbaiki nama ambigu menjadi self-explanatory sesuai konvensi Dart/Flutter.\n'
        '4. Pencampuran UI dan Logic (Separation of Concerns): Memisahkan network call, parsing JSON, dan state logic dari class State UI.'
    )

    doc.add_paragraph('4.2 Ringkasan Temuan Audit Kode', style='Heading 3')
    add_guideline(doc, 'Panduan: Cantumkan daftar temuan audit pada file-file proyek, kategori masalah, dan status perbaikannya.')

    t_aud_sum = doc.add_table(rows=4, cols=5)
    t_aud_sum.style = 'Table Grid'
    aud_sum_data = [
        ('No', 'Lokasi File / Modul', 'Temuan Masalah Hasil Audit', 'Kategori Audit', 'Status Refactoring'),
        ('1', 'lib/features/profile/views/profile_screen.dart', 'File mencapai 400+ baris; seluruh dialog edit data diri, sosmed, dan skill menumpuk dalam satu file.', 'Kode Terlalu Panjang & UI-Logic Bercampur', 'Selesai Direfactor (4.3.1)'),
        ('2', 'lib/features/auth/ & lib/features/team/', 'Widget form input (TextFormField dengan dekorasi border/icon) didefinisikan berulang di 5 layar berbeda.', 'Duplikasi Kode (DRY)', 'Selesai Direfactor (4.3.2)'),
        ('3', 'lib/core/network/api_response.dart & models', 'Handling respons error HTTP dan serialisasi JSON ditulis ad-hoc pada masing-masing repository.', 'Pemisahan Logic & Maintainability', 'Selesai Direfactor (4.3.3)'),
    ]
    for r_idx, (c0, c1, c2, c3, c4) in enumerate(aud_sum_data):
        row = t_aud_sum.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3, c4]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_aud_sum, col_widths=[0.4, 1.8, 2.2, 1.3, 0.8])

    doc.add_paragraph('4.3 Detail Implementasi Refactoring', style='Heading 3')
    add_guideline(
        doc,
        'Panduan: Uraikan setiap refactoring ke dalam subbab tersendiri (4.3.1, 4.3.2, 4.3.3). '
        'Lengkapi tabel evaluasi refactoring, lalu sertakan potongan kode Before dan After yang asli dari repository.'
    )

    # 4.3.1
    doc.add_paragraph('4.3.1 Refactoring 1: Dekomposisi Layar Profil dan Ekstraksi Widget Skeleton/Modal', style='Heading 3')
    t_ref1 = doc.add_table(rows=7, cols=2)
    t_ref1.style = 'Table Grid'
    ref1_data = [
        ('Unsur Evaluasi', 'Penjelasan Teknis Refactoring'),
        ('Lokasi File & PIC', 'lib/features/profile/views/screens/profile_screen.dart & widgets/ (PIC: Fuadi Dhiyaulhaq)'),
        ('Masalah yang Ditemukan', 'File profil utama berukuran terlalu besar (> 400 baris), mencampurkan logika rendering shimmer loading skeleton, modal dialog edit data diri, dan parsing model ke dalam satu kelas.'),
        ('Perubahan yang Dilakukan', 'Memecah widget besar menjadi komponen-komponen mandiri: ProfileSkeleton (widgets/profile_skeleton.dart), DataDiriSection, dan dialog edit terisolasi.'),
        ('Alasan & Dampak Perbaikan', 'Meningkatkan keterbacaan kode (readability), mempercepat rendering UI karena rebuild hanya terjadi pada sub-widget yang datanya berubah, dan memudahkan pemeliharaan unit pengujian.'),
        ('Bukti Fungsi Tidak Berubah', 'Tampilan visual profil, animasi shimmer skeleton loading saat data dimuat, dan proses update data diri berfungsi 100% identik seperti sebelum perbaikan.'),
        ('Commit / Pull Request', 'Commit hash: [misal: abc1234 - refactor(profile): decompose screen into modular widgets]'),
    ]
    for r_idx, (c0, c1) in enumerate(ref1_data):
        row = t_ref1.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
    format_table(t_ref1, col_widths=[1.8, 4.7])

    p_b1 = doc.add_paragraph()
    p_b1.add_run('Potongan Kode SEBELUM Refactoring (Before):').bold = True
    add_code_block(
        doc,
        '// SEBELUM: profile_screen.dart (widget monolithic, skeleton & dialog bercampur)\n'
        'Widget _buildBody() {\n'
        '  if (_isLoading) {\n'
        '    return Column(\n'
        '      children: [\n'
        '        Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle)),\n'
        '        SizedBox(height: 16),\n'
        '        Container(width: 150, height: 20, color: Colors.grey[300]),\n'
        '        // ... 60+ baris skeleton kode statis berulang ...\n'
        '      ],\n'
        '    );\n'
        '  }\n'
        '  return SingleChildScrollView(\n'
        '    child: Column(children: [\n'
        '      // ... 300+ baris rendering section, form dialog, dan event handler ...\n'
        '    ]),\n'
        '  );\n'
        '}'
    )

    p_a1 = doc.add_paragraph()
    p_a1.add_run('Potongan Kode SESUDAH Refactoring (After):').bold = True
    add_code_block(
        doc,
        '// SESUDAH: profile_screen.dart (bersih, deklaratif, dan memanfaatkan reusable widget)\n'
        'Widget _buildBody() {\n'
        '  if (_isLoading) {\n'
        '    return const ProfileSkeleton(); // Diekstrak ke lib/features/profile/views/widgets/profile_skeleton.dart\n'
        '  }\n'
        '  return RefreshIndicator(\n'
        '    onRefresh: _loadProfileData,\n'
        '    child: SingleChildScrollView(\n'
        '      child: Column(\n'
        '        children: const [\n'
        '          ProfileHeaderSection(),\n'
        '          DataDiriSection(),\n'
        '          KeahlianMinatSection(),\n'
        '          PengalamanSection(),\n'
        '        ],\n'
        '      ),\n'
        '    ),\n'
        '  );\n'
        '}'
    )

    # 4.3.2
    doc.add_paragraph('4.3.2 Refactoring 2: Ekstraksi Reusable Widget AuthTextField dan BottomSheet Aksi', style='Heading 3')
    t_ref2 = doc.add_table(rows=7, cols=2)
    t_ref2.style = 'Table Grid'
    ref2_data = [
        ('Unsur Evaluasi', 'Penjelasan Teknis Refactoring'),
        ('Lokasi File & PIC', 'lib/features/auth/views/widgets/auth_text_field.dart (PIC: Nayla / Rafa)'),
        ('Masalah yang Ditemukan', 'Kode deklarasi InputDecoration (custom border radius, prefix icon, hint style, error border) ditulis berulang 8 kali di login, register, dan create team.'),
        ('Perubahan yang Dilakukan', 'Membuat komponen umum AuthTextField yang menerima parameter label, controller, validator, obscureText, dan icon secara terstandar.'),
        ('Alasan & Dampak Perbaikan', 'Menghilangkan redundansi kode (DRY), memastikan konsistensi tema desain di seluruh layar, serta mempermudah update styling form secara terpusat.'),
        ('Bukti Fungsi Tidak Berubah', 'Validasi error text, interaksi toggle password visibility, dan input form tetap bekerja dengan akurat.'),
        ('Commit / Pull Request', 'Commit hash: [misal: def5678 - refactor(auth): extract reusable AuthTextField component]'),
    ]
    for r_idx, (c0, c1) in enumerate(ref2_data):
        row = t_ref2.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
    format_table(t_ref2, col_widths=[1.8, 4.7])

    p_b2 = doc.add_paragraph()
    p_b2.add_run('Potongan Kode SEBELUM Refactoring (Before):').bold = True
    add_code_block(
        doc,
        '// SEBELUM: Diulang-ulang di login_screen.dart & register_screen.dart\n'
        'TextFormField(\n'
        '  controller: _nimController,\n'
        '  decoration: InputDecoration(\n'
        '    labelText: "NIM Mahasiswa",\n'
        '    prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFF1B365D)),\n'
        '    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),\n'
        '    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey)),\n'
        '    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF1B365D), width: 2)),\n'
        '  ),\n'
        '  validator: (val) => val == null || val.isEmpty ? "NIM wajib diisi" : null,\n'
        ');'
    )

    p_a2 = doc.add_paragraph()
    p_a2.add_run('Potongan Kode SESUDAH Refactoring (After):').bold = True
    add_code_block(
        doc,
        '// SESUDAH: Menggunakan AuthTextField reusable component\n'
        'AuthTextField(\n'
        '  controller: _nimController,\n'
        '  label: "NIM Mahasiswa",\n'
        '  prefixIcon: Icons.badge_outlined,\n'
        '  validator: Validators.required("NIM wajib diisi"),\n'
        ');'
    )

    # 4.3.3
    doc.add_paragraph('4.3.3 Refactoring 3: Standardisasi Model Serialisasi dan API Response Generic Wrapper', style='Heading 3')
    t_ref3 = doc.add_table(rows=7, cols=2)
    t_ref3.style = 'Table Grid'
    ref3_data = [
        ('Unsur Evaluasi', 'Penjelasan Teknis Refactoring'),
        ('Lokasi File & PIC', 'lib/core/network/api_response.dart & models/ (PIC: Fuadi / Diva)'),
        ('Masalah yang Ditemukan', 'Setiap pemanggilan HTTP API melakukan decode JSON dan handling error secara terpisah dengan struktur Map<String, dynamic> yang rawan error null-pointer.'),
        ('Perubahan yang Dilakukan', 'Membangun generic class ApiResponse<T> dengan status flag (success, message, data) dan factory method fromJson terpadu untuk deserialisasi model DataDiri, Tim, dan Pengajuan.'),
        ('Alasan & Dampak Perbaikan', 'Membuat penanganan status jaringan lebih konsisten dan type-safe, serta mereduksi duplikasi try-catch block di service layer.'),
        ('Bukti Fungsi Tidak Berubah', 'Data profil, feed tim, dan daftar pengajuan berhasil ditampilkan ke antarmuka dengan penanganan error banner yang konsisten saat server offline.'),
        ('Commit / Pull Request', 'Commit hash: [misal: 789abcd - refactor(core): implement generic ApiResponse wrapper]'),
    ]
    for r_idx, (c0, c1) in enumerate(ref3_data):
        row = t_ref3.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
    format_table(t_ref3, col_widths=[1.8, 4.7])

    p_b3 = doc.add_paragraph()
    p_b3.add_run('Potongan Kode SEBELUM Refactoring (Before):').bold = True
    add_code_block(
        doc,
        '// SEBELUM: Parsing manual raw Map dan try-catch di setiap pemanggilan API\n'
        'final response = await http.get(Uri.parse("$baseUrl/profile"));\n'
        'if (response.statusCode == 200) {\n'
        '  final Map<String, dynamic> raw = jsonDecode(response.body);\n'
        '  if (raw["status"] == "success") {\n'
        '    return DataDiriModel.fromJson(raw["data"]);\n'
        '  } else {\n'
        '    throw Exception(raw["message"]);\n'
        '  }\n'
        '} else {\n'
        '  throw Exception("Gagal memuat profil: ${response.statusCode}");\n'
        '}'
    )

    p_a3 = doc.add_paragraph()
    p_a3.add_run('Potongan Kode SESUDAH Refactoring (After):').bold = True
    add_code_block(
        doc,
        '// SESUDAH: Menggunakan ApiResponse<T> generic wrapper yang type-safe\n'
        'final apiRes = await apiClient.get<DataDiriModel>(\n'
        '  "/profile",\n'
        '  fromJson: (json) => DataDiriModel.fromJson(json),\n'
        ');\n'
        'if (apiRes.isSuccess) {\n'
        '  return apiRes.data;\n'
        '} else {\n'
        '  showErrorMessage(apiRes.message);\n'
        '}'
    )

    # ==========================================
    # BAB 5. KOORDINASI TIM (Bobot 15% - TARGET EXCELLENT)
    # ==========================================
    doc.add_paragraph('Bab 5. Koordinasi Tim', style='Heading 2')
    add_guideline(
        doc,
        'Panduan Penilaian Aspek Koordinasi Tim (Bobot 15% - Target 4 Poin / Excellent):\n'
        '• Pembagian tugas jelas dan terukur: setiap anggota memiliki tanggung jawab modul utama serta kontribusi nyata pada tugas di luar modul (cross-cutting/core).\n'
        '• Seluruh klaim kontribusi didukung bukti konkret (commit, PR, screen, artefak dokumen/skema) yang dapat ditelusuri di repositori.\n'
        '• Menunjukkan mekanisme koordinasi yang solid ketika menghadapi ketergantungan antarmodul dan alur kerja Git yang teratur.\n'
        '• Subbab 5.1 mencakup tabel progress modul, tabel pembagian pekerjaan non-modul, dan tabel bukti kontribusi non-modul.'
    )

    doc.add_paragraph('5.1 Pembagian Pekerjaan dan Progress per Anggota', style='Heading 3')
    add_guideline(
        doc,
        'Panduan 5.1: Uraikan pembagian tugas ke dalam 3 sub-bagian: modul utama, pekerjaan cross-cutting di luar modul, '
        'dan bukti kontribusi pekerjaan di luar modul agar seluruh kontribusi anggota terlihat jelas dan berbobot.'
    )

    # 5.1.1
    doc.add_paragraph('5.1.1 Pembagian Pekerjaan dan Progress Modul Utama', style='Heading 3')
    t_pic_mod = doc.add_table(rows=5, cols=5)
    t_pic_mod.style = 'Table Grid'
    pic_mod_data = [
        ('Nama Anggota & NIM', 'Modul Tanggung Jawab', 'Kebutuhan FR Terkait', 'Progress Saat Ini', 'Kontribusi Nyata pada Modul'),
        ('Fuadi Dhiyaulhaq\n(2411522001)', 'Modul 1: Pengelolaan Data Riwayat Diri', 'FR-01 s.d. FR-07, Auth', '[85% / Selesai]', 'DataDiriModel, ProfileScreen, modal edit data diri, portofolio skill & pengalaman, integrasi SharedPreferences token.'),
        ('Nayla Puspita Sari\n(2411521007)', 'Modul 2: Pembuatan & Pengelolaan Tim', 'FR-08 s.d. FR-12', '[80% / Selesai]', 'CreateTeamScreen, integrasi ImagePicker dokumen poster lomba, list tim saya, dialog edit tim, dan hapus tim.'),
        ('Rafa Gian Atthari\n(2411522014)', 'Modul 3: Pencarian Tim & Pengajuan', 'FR-13 s.d. FR-20', '[80% / Selesai]', 'HomeScreen feed tim, SearchTeamScreen dengan filter kategori, detail tim, form apply permohonan bergabung, list status pengajuan.'),
        ('Diva Ramadhani\n(2411521017)', 'Modul 4: Pencarian Anggota & Pengajuan', 'FR-21 s.d. FR-25', '[75% / Selesai]', 'SearchMemberScreen talent scouting, filter keahlian/minat, layar detail profil calon anggota, modal kirim undangan tim.'),
    ]
    for r_idx, (c0, c1, c2, c3, c4) in enumerate(pic_mod_data):
        row = t_pic_mod.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3, c4]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_pic_mod, col_widths=[1.5, 1.4, 0.9, 0.9, 1.8])

    # 5.1.2
    doc.add_paragraph('5.1.2 Pembagian Pekerjaan di Luar Modul (Core, Arsitektur, & Penunjang Proyek)', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Pekerjaan di Luar Modul: Proyek mobile membutuhkan pondasi arsitektur bersama. '
        'Tabel di bawah menyajikan pembagian tugas cross-cutting (basis data, core network, autentikasi, UI design system, dan manajemen repo) '
        'yang membuktikan bahwa setiap anggota berkontribusi aktif melampaui modul individunya.'
    )
    t_pic_non = doc.add_table(rows=6, cols=5)
    t_pic_non.style = 'Table Grid'
    pic_non_data = [
        ('No', 'Bidang Pekerjaan di Luar Modul', 'Penanggung Jawab (PIC)', 'Deskripsi Ruang Lingkup & Tanggung Jawab', 'Target Output / Hasil Nyata'),
        ('1', 'Perancangan Database & Schema ERD', 'Fuadi Dhiyaulhaq', 'Merancang skema relasional 13 tabel basis data, spesifikasi DBML, dan file migrasi SQL.', 'File erd_myteam.dbml & schema_myteam.sql'),
        ('2', 'Setup Core Network & Generic API Client', 'Fuadi Dhiyaulhaq', 'Membangun arsitektur network client, generic ApiResponse wrapper, dan exception handling.', 'Folder lib/core/network/'),
        ('3', 'Autentikasi & Session Token Persistence', 'Nayla Puspita Sari', 'Membangun UI Login, Register, Splash Screen, serta pengelolaan auth session token.', 'Folder lib/features/auth/'),
        ('4', 'UI/UX Design System & Shared Widgets', 'Rafa Gian Atthari', 'Menstandarkan tema warna, tipografi, custom text field, tombol reusable, dan app bar.', 'Folder lib/core/theme/ & widgets/'),
        ('5', 'Git Flow Management & Dokumentasi Laporan', 'Diva Ramadhani', 'Mengatur alur branching Git tim, review PR, penanganan conflict, serta kompilasi dokumen laporan.', 'Repo Git & Template Dokumen Progress 1'),
    ]
    for r_idx, (c0, c1, c2, c3, c4) in enumerate(pic_non_data):
        row = t_pic_non.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3, c4]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_pic_non, col_widths=[0.4, 1.6, 1.3, 2.0, 1.2])

    # 5.1.3
    doc.add_paragraph('5.1.3 Bukti Kontribusi Pekerjaan di Luar Modul', style='Heading 3')
    add_guideline(
        doc,
        'Panduan Bukti Kontribusi Non-Modul: Setiap klaim pekerjaan di luar modul wajib diverifikasi '
        'dengan file atau commit konkret yang ada di repositori proyek.'
    )
    t_ev_non = doc.add_table(rows=5, cols=5)
    t_ev_non.style = 'Table Grid'
    ev_non_data = [
        ('No', 'Nama Anggota', 'Pekerjaan di Luar Modul', 'Artefak / File Nyata yang Dihasilkan', 'Tautan Commit / Bukti Verifikasi'),
        ('1', 'Fuadi Dhiyaulhaq', 'Perancangan ERD & Base Network Client', 'erd_myteam.dbml, schema_myteam.sql, lib/core/network/api_response.dart', 'Commit: [hash / PR #1: init db schema & core client]'),
        ('2', 'Nayla Puspita Sari', 'Auth UI, Splash Screen, & Session', 'lib/features/auth/views/screens/splash_screen.dart & login_screen.dart', 'Commit: [hash / PR #2: feat auth & splash session flow]'),
        ('3', 'Rafa Gian Atthari', 'Design System, Reusable Buttons & Inputs', 'lib/core/theme/app_colors.dart, lib/features/auth/views/widgets/auth_text_field.dart', 'Commit: [hash / PR #3: feat design system components]'),
        ('4', 'Diva Ramadhani', 'Git Workflow Setup & Penyusunan Dokumen PR 1', 'Branching rules, Pull Request review log, file Progress Report 1 (.docx)', 'Commit: [hash / PR #4: git workflow & docs compilation]'),
    ]
    for r_idx, (c0, c1, c2, c3, c4) in enumerate(ev_non_data):
        row = t_ev_non.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3, c4]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_ev_non, col_widths=[0.4, 1.3, 1.6, 1.9, 1.3])

    # 5.2
    doc.add_paragraph('5.2 Keterkaitan Antar Modul dan Cara Berkoordinasi', style='Heading 3')
    add_guideline(
        doc,
        'Panduan: Jelaskan titik temu ketergantungan antarmodul dan kesepakatan tim '
        '(kontrak JSON, endpoint API, model data) untuk mencegah kendala integrasi.'
    )
    t_dep = doc.add_table(rows=5, cols=3)
    t_dep.style = 'Table Grid'
    dep_data = [
        ('Ketergantungan Antarmodul', 'Pihak / Modul Terkait', 'Mekanisme Koordinasi & Solusi Tim'),
        ('Data Profil Mahasiswa digunakan oleh Modul Pencarian Anggota', 'Modul 1 (Fuadi) → Modul 4 (Diva)', 'Menyepakati kontrak struktur DataDiriModel dan endpoint API profil bersama agar Modul 4 dapat langsung merender portofolio pelamar.'),
        ('Data Tim yang dibuat di Modul 2 menjadi sumber data Feed & Detail di Modul 3', 'Modul 2 (Nayla) → Modul 3 (Rafa)', 'Menstandarkan model Data_Tim dan Kebutuhan_Anggota_Tim sehingga filter kategori dan kuota slot sinkron secara real-time.'),
        ('Pengajuan dua arah (Join Request & Undangan) memicu Notifikasi Masuk', 'Modul 3 (Rafa) & Modul 4 (Diva) → Modul 1 & 2', 'Menetapkan format tabel Pengajuan_Bergabung dan Pengajuan_Anggota yang memicu record Notifikasi dengan id_penerima yang tepat.'),
        ('Integrasi Skema Database & Model Serialisasi Dart', 'Seluruh Anggota Tim', 'Review bersama file erd_myteam.dbml dan schema_myteam.sql sebelum implementasi model lokal dilakukan di masing-masing modul.'),
    ]
    for r_idx, (c0, c1, c2) in enumerate(dep_data):
        row = t_dep.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
        row.cells[2].paragraphs[0].add_run(c2)
    format_table(t_dep, col_widths=[2.1, 1.7, 2.7])

    p_case = doc.add_paragraph()
    p_case.add_run('Contoh Kasus Nyata Koordinasi Lintas Anggota: ').bold = True
    p_case.add_run(
        '[Jelaskan satu contoh kendala koordinasi yang nyata terjadi, misal: sinkronisasi model data saat pengajuan anggota dari Modul 4 '
        'membutuhkan data tim dari Modul 2, bagaimana tim berdiskusi melalui Discord/WhatsApp, dan bagaimana kesepakatan dicapai].'
    )

    # 5.3
    doc.add_paragraph('5.3 Alat dan Alur Kerja Tim', style='Heading 3')
    add_guideline(doc, 'Panduan: Jelaskan alat komunikasi, ritme kerja, dan strategi Git yang diterapkan tim.')

    t_tool = doc.add_table(rows=5, cols=2)
    t_tool.style = 'Table Grid'
    tool_data = [
        ('Aspek Alur Kerja', 'Implementasi Nyata pada Tim Kelompok 5'),
        ('Alat Komunikasi & Ritme Diskusi', 'Grup WhatsApp aktif untuk koordinasi harian cepat + Google Meet / Discord mingguan untuk review progress dan sinkronisasi antarmodul.'),
        ('Manajemen Tugas & Backlog', 'GitHub Project Board / Trello dengan pembagian kolom: To Do, In Progress, Code Review, dan Done per FR modul.'),
        ('Strategi Git Branching', 'Menggunakan Git Feature-Branch Workflow: branch main/master (production-ready), branch dev (integrasi), dan feature branch per modul (mis. feat/m1-profile, feat/m2-team).'),
        ('Code Review & Penanganan Konflik', 'Setiap merger ke dev wajib melalui Pull Request (PR) yang ditinjau minimal 1 anggota lain. Merge conflict diselesaikan bersama melalui visual merge tool VS Code/Android Studio.'),
    ]
    for r_idx, (c0, c1) in enumerate(tool_data):
        row = t_tool.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
    format_table(t_tool, col_widths=[2.0, 4.5])

    # 5.4
    doc.add_paragraph('5.4 Bukti Kontribusi Keseluruhan dan Kesiapan Demo', style='Heading 3')
    add_guideline(
        doc,
        'Panduan: Buktikan bahwa setiap anggota tim siap mendemokan bagian pekerjaannya masing-masing '
        'dan memahami seluruh kode yang telah dibuat (termasuk bagian yang dibantu oleh AI tools).'
    )

    t_demo = doc.add_table(rows=5, cols=4)
    t_demo.style = 'Table Grid'
    demo_data = [
        ('Nama Anggota Tim', 'Jumlah Commit Aktif', 'Commit / Pull Request Penting', 'Bagian Aplikasi yang Siap Didemokan'),
        ('Fuadi Dhiyaulhaq', '[misal: 24 commit]', '[Tautan PR / Hash Commit Modul 1 & Core]', 'Kelola Data Diri, Portofolio Skill/Minat, SplashScreen session, & Skema DB/ERD.'),
        ('Nayla Puspita Sari', '[misal: 19 commit]', '[Tautan PR / Hash Commit Modul 2 & Auth]', 'Pembuatan Tim, Unggah Poster Lomba Native, Daftar & Edit Tim Saya.'),
        ('Rafa Gian Atthari', '[misal: 22 commit]', '[Tautan PR / Hash Commit Modul 3 & UI]', 'Feed Tim Beranda, Pencarian & Filter Multi-Kategori, Alur Apply Tim.'),
        ('Diva Ramadhani', '[misal: 18 commit]', '[Tautan PR / Hash Commit Modul 4 & Docs]', 'Pencarian Calon Anggota (Talent Scouting), Profil Kandidat, Kirim Undangan.'),
    ]
    for r_idx, (c0, c1, c2, c3) in enumerate(demo_data):
        row = t_demo.rows[r_idx]
        for c_idx, val in enumerate([c0, c1, c2, c3]):
            row.cells[c_idx].paragraphs[0].add_run(val)
    format_table(t_demo, col_widths=[1.5, 1.1, 1.8, 2.1])

    # ==========================================
    # BAB 6. PENUTUP DAN LAMPIRAN
    # ==========================================
    doc.add_paragraph('Bab 6. Penutup dan Lampiran', style='Heading 2')
    add_guideline(doc, 'Panduan: Bab penutup padat (maksimal setengah halaman), lampiran pendukung, serta checklist mandiri.')

    doc.add_paragraph('6.1 Penutup', style='Heading 3')
    p_clos = doc.add_paragraph()
    p_clos.add_run(
        '1. Kesimpulan Kondisi Aplikasi: Aplikasi MyTeam telah berhasil mencapai progress signifikan pada Progress Report 1 dengan berjalannya '
        'fondasi arsitektur database relasional (13 tabel), autentikasi pengguna, antarmuka per modul (Modul 1 s.d 4), serta eksekusi normal flow utama yang dapat didemokan.\n'
        '2. Pembelajaran Penting Tim: Pembagian arsitektur sejak awal (ERD dan contract API) sangat membantu kelancaran integrasi antarmodul '
        'dan meminimalkan konflik kode saat pengerjaan paralel.\n'
        '3. Prioritas Menuju Progress Report Berikutnya: Menuntaskan integrasi live API backend, penyempurnaan alur pengunggahan dokumen native, '
        'serta uji coba performa aplikasi pada skenario jaringan lambat.'
    )

    doc.add_paragraph('6.2 Lampiran Pendukung', style='Heading 3')
    t_lamp = doc.add_table(rows=6, cols=2)
    t_lamp.style = 'Table Grid'
    lamp_data = [
        ('Kategori Lampiran', 'Keterangan & Tautan Akses'),
        ('A. Repositori Source Code', '[Tautan GitHub/GitLab: URL repositori tim]'),
        ('B. Video Demonstrasi Aplikasi', '[Tautan Google Drive / YouTube video demo interaktif berdurasi 1–3 menit]'),
        ('C. File Build APK Runnable', '[Tautan unduh berkas APK MyTeam untuk uji coba langsung pada smartphone Android]'),
        ('D. File Spesifikasi DBML & ERD', '[Tautan file erd_myteam.dbml dan schema_myteam.sql pada repositori]'),
        ('E. Ringkasan Git Commit Log', '[Potongan output git log --oneline --graph atau tautan halaman insights kontributor]'),
    ]
    for r_idx, (c0, c1) in enumerate(lamp_data):
        row = t_lamp.rows[r_idx]
        row.cells[0].paragraphs[0].add_run(c0)
        row.cells[1].paragraphs[0].add_run(c1)
    format_table(t_lamp, col_widths=[2.2, 4.3])

    doc.add_paragraph('6.3 Checklist Penilaian Mandiri Menuju Nilai 100', style='Heading 3')
    add_guideline(
        doc,
        'Panduan: Pastikan seluruh item checklist di bawah tercentang sebelum laporan dikumpulkan '
        'untuk memastikan terpenuhinya kriteria nilai maksimal (100) pada rubrik penilaian dosen.'
    )

    checklist_items = [
        ('Progress Aplikasi (Bobot 40% - Target 4 Poin / Excellent):', [
            'Normal flow utama aplikasi sudah berjalan nyata dari awal hingga akhir dan dapat didemokan secara interaktif.',
            'Bab 2 memuat bukti tangkapan layar (screenshot) berurutan dari aplikasi yang dieksekusi di emulator/HP, bukan sekadar desain mockup Figma.',
            'Tabel status tiap modul (2.1 s.d 2.4) secara eksplisit menyebutkan interaksi, pengelolaan state, validasi, dan navigasi yang berjalan.',
            'Subbab 2.5 menyertakan diagram ERD dan penjelasan tabel relasional yang mendasari aplikasi.',
        ]),
        ('Kendala & Solusi (Bobot 20% - Target 4 Poin / Excellent):', [
            'Menjelaskan 3–4 kendala teknis nyata yang membutuhkan usaha pemecahan masalah mandiri oleh tim.',
            'Setiap kendala diuraikan dalam subbab tersendiri (3.2.1, 3.2.2, dst.) memuat 4 unsur lengkap: Masalah, Penyebab teknis, Solusi mandiri, dan Hasil nyata setelah perbaikan.',
            'Disertai bukti pendukung berupa pesan error logcat, potongan kode perbaikan, atau screenshot kondisi sebelum/sesudah.',
        ]),
        ('Code Audit & Refactoring (Bobot 25% - Target 4 Poin / Excellent):', [
            'Audit kode dilakukan dengan kriteria relevan (panjang kode, duplikasi DRY, penamaan, pemisahan UI & business logic).',
            'Menyajikan minimal 2–3 contoh nyata refactoring struktural pada subbab 4.3.1, 4.3.2, dst.',
            'Tiap refactoring memiliki penjelasan alasan perbaikan, bukti fungsi tidak berubah (no regression), serta potongan kode Before & After asli dari repo.',
        ]),
        ('Koordinasi Tim (Bobot 15% - Target 4 Poin / Excellent):', [
            'Pembagian tugas jelas untuk seluruh anggota (Fuadi, Nayla, Rafa, Diva) pada modul utama dan tugas cross-cutting di luar modul (5.1.1, 5.1.2).',
            'Terdapat bukti kontribusi konkret yang dapat diverifikasi di repositori untuk pekerjaan di luar modul (5.1.3).',
            'Menjelaskan koordinasi ketergantungan antarmodul, contoh kasus penyelesaian masalah lintas anggota, dan alur kerja Git tim.',
            'Seluruh anggota memahami kode yang dibuat dan siap mendemokan bagiannya saat presentasi.',
        ]),
        ('Kerapian Laporan:', [
            'Seluruh teks panduan [kurung siku] dan teks miring "Panduan" telah disesuaikan dengan data riil atau dibersihkan.',
        ])
    ]

    for cat_title, items in checklist_items:
        p_c = doc.add_paragraph()
        p_c.paragraph_format.space_before = Pt(4)
        p_c.paragraph_format.space_after = Pt(2)
        p_c.add_run(cat_title).bold = True
        for item in items:
            p_item = doc.add_paragraph(style='List Paragraph')
            p_item.paragraph_format.space_before = Pt(1)
            p_item.paragraph_format.space_after = Pt(1.5)
            p_item.add_run(f'☑  {item}')

    # Save output directly to target file
    output_path = r'docs/Template Progress Report 1 – MyTeam (Kelompok 5).docx'
    doc.save(output_path)
    print(f'Document successfully created and saved to: {output_path}')

if __name__ == '__main__':
    generate_report()
