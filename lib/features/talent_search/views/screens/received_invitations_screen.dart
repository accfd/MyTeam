import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/storage_service.dart';
import '../../services/talent_search_service.dart';
import 'team_detail_view_screen.dart';

/// Halaman Notifikasi Undangan (FR-24 + FR-24b + FR-25)
/// Tab 1 — Undangan Masuk (FR-24): GET /applications/received-invitations
///          PATCH /applications/received-invitations/{id}/status
/// Tab 2 — Undangan Terkirim (FR-24b): GET /applications/sent-invitations
/// FR-25: Notifikasi respon otomatis dari backend (event)
/// PIC Modul 4: Diva Ramadhani (2411521017)
class ReceivedInvitationsScreen extends StatefulWidget {
  const ReceivedInvitationsScreen({super.key});

  @override
  State<ReceivedInvitationsScreen> createState() =>
      _ReceivedInvitationsScreenState();
}

class _ReceivedInvitationsScreenState extends State<ReceivedInvitationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  String _myUserId = '';

  // ── Tab 1: Undangan Masuk ─────────────────────────────────────────────────
  List<Map<String, dynamic>> _received = [];
  bool _loadingReceived = true;
  String? _errorReceived;
  final Set<String> _processingIds = {};

  // ── Tab 2: Undangan Terkirim ──────────────────────────────────────────────
  List<Map<String, dynamic>> _sent = [];
  bool _loadingSent = true;
  String? _errorSent;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _init();
  }

  Future<void> _init() async {
    _myUserId = await StorageService.getUserId() ?? '';
    await Future.wait([_loadReceived(), _loadSent()]);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Load Received ──────────────────────────────────────────────────────────
  Future<void> _loadReceived() async {
    if (!mounted) return;
    setState(() { _loadingReceived = true; _errorReceived = null; });
    try {
      final data = await TalentSearchService.getReceivedInvitations(_myUserId);
      if (mounted) setState(() => _received = data);
    } catch (e) {
      if (mounted) setState(() => _errorReceived = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingReceived = false);
    }
  }

  // ── Load Sent ─────────────────────────────────────────────────────────────
  Future<void> _loadSent() async {
    if (!mounted) return;
    setState(() { _loadingSent = true; _errorSent = null; });
    try {
      final data = await TalentSearchService.getSentInvitations(_myUserId);
      if (mounted) setState(() => _sent = data);
    } catch (e) {
      if (mounted) setState(() => _errorSent = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingSent = false);
    }
  }

  // ── Respond Invitation (FR-24 + FR-25) ───────────────────────────────────
  Future<void> _respond(String id, String status) async {
    setState(() => _processingIds.add(id));
    try {
      await TalentSearchService.respondInvitation(
          idPengajuanAnggota: id, status: status);
      if (mounted) {
        final label = status == 'diterima' ? 'diterima' : 'ditolak';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Undangan berhasil $label.'),
          backgroundColor: status == 'diterima'
              ? AppColors.statusSuccessText
              : AppColors.statusDangerText,
          behavior: SnackBarBehavior.floating,
        ));
        await _loadReceived();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.statusDangerText,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _processingIds.remove(id));
    }
  }

  Future<void> _confirmRespond(String id, String namaTim, String status) async {
    final isAccept = status == 'diterima';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isAccept ? 'Terima Undangan?' : 'Tolak Undangan?',
            style: AppTextStyles.titleMd),
        content: Text(
          isAccept
              ? 'Anda akan bergabung ke tim "$namaTim". Aksi ini tidak dapat dibatalkan.'
              : 'Anda akan menolak undangan dari tim "$namaTim".',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept
                  ? AppColors.primaryContainer
                  : AppColors.statusDangerText,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isAccept ? 'Terima' : 'Tolak',
                style: AppTextStyles.labelLg.copyWith(fontSize: 13)),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
    if (confirmed == true) await _respond(id, status);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _received.where((i) => i['status_pengajuan'] == 'menunggu').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.text, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Notifikasi Undangan',
                style: AppTextStyles.titleMd.copyWith(fontSize: 16)),
            Text('Kelola undangan tim kamu',
                style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primary, size: 20),
              onPressed: () => Future.wait([_loadReceived(), _loadSent()]),
              tooltip: 'Segarkan',
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primaryContainer,
          indicatorWeight: 2.5,
          labelColor: AppColors.primaryContainer,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTextStyles.labelMd.copyWith(fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Undangan Masuk'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text('$pendingCount',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Undangan Terkirim'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildReceivedTab(),
          _buildSentTab(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 1: UNDANGAN MASUK
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildReceivedTab() {
    if (_loadingReceived) return _buildLoadingList();
    if (_errorReceived != null) {
      return _buildErrorState(_errorReceived!, _loadReceived);
    }
    if (_received.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mail_outline_rounded,
        title: 'Belum ada undangan masuk',
        subtitle:
            'Ketika pembuat tim mengundang Anda bergabung,\nundangan akan muncul di sini.',
      );
    }

    final menunggu =
        _received.where((i) => i['status_pengajuan'] == 'menunggu').toList();
    final selesai =
        _received.where((i) => i['status_pengajuan'] != 'menunggu').toList();

    return RefreshIndicator(
      color: AppColors.primaryContainer,
      onRefresh: _loadReceived,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (menunggu.isNotEmpty) ...[
            _buildSectionHeader(
                'Menunggu Keputusan', menunggu.length, Colors.amber),
            const SizedBox(height: 8),
            ...menunggu.map((inv) => _buildReceivedCard(inv, isPending: true)),
            const SizedBox(height: 16),
          ],
          if (selesai.isNotEmpty) ...[
            _buildSectionHeader(
                'Riwayat Undangan', selesai.length, AppColors.textMuted),
            const SizedBox(height: 8),
            ...selesai.map((inv) => _buildReceivedCard(inv, isPending: false)),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReceivedCard(Map<String, dynamic> inv,
      {required bool isPending}) {
    final id = inv['id_pengajuan_anggota'] as String? ?? '';
    final idTim = inv['id_tim'] as String? ?? '';
    final namaTim = inv['nama_tim'] as String? ?? 'Tim';
    final namaKegiatan = inv['nama_kegiatan'] as String? ?? '';
    final kategori = inv['kategori_kegiatan'] as String? ?? '';
    final deskripsiTim = inv['deskripsi_tim'] as String? ?? '';
    final pesan = inv['pesan_pengajuan'] as String? ?? '';
    final waktu = inv['waktu_pengajuan'] as String? ?? '';
    final status = inv['status_pengajuan'] as String? ?? 'menunggu';
    final isProcessing = _processingIds.contains(id);

    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColors.primaryOutline : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(
                width: 3.5,
                color: isPending
                    ? AppColors.primaryContainer
                    : _statusColor(status),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: icon + nama tim + tombol Detail Tim
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.groups_rounded,
                                color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(namaTim,
                                    style: AppTextStyles.titleMd
                                        .copyWith(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                if (namaKegiatan.isNotEmpty)
                                  Text(namaKegiatan,
                                      style: AppTextStyles.bodySm
                                          .copyWith(fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                if (kategori.isNotEmpty)
                                  Text(kategori,
                                      style: AppTextStyles.bodySm.copyWith(
                                          fontSize: 10,
                                          color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          // Tombol Lihat Detail Tim
                          if (idTim.isNotEmpty)
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TeamDetailViewScreen(
                                      idTim: idTim, namaTim: namaTim),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.primaryOutline),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.open_in_new_rounded,
                                        size: 11, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text('Detail Tim',
                                        style: AppTextStyles.labelSm.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Deskripsi Tim
                      if (deskripsiTim.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(deskripsiTim,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],

                      // Pesan Undangan
                      if (pesan.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.format_quote_rounded,
                                  color: AppColors.primary, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(pesan,
                                    style: AppTextStyles.bodySm.copyWith(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 10),

                      // Waktu + action buttons / status badge
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(_formatDate(waktu),
                              style:
                                  AppTextStyles.bodySm.copyWith(fontSize: 11)),
                          const Spacer(),
                          if (isPending)
                            ..._buildActionButtons(id, namaTim, isProcessing)
                          else
                            _buildStatusBadge(status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return card;
  }

  List<Widget> _buildActionButtons(
      String id, String namaTim, bool isProcessing) {
    if (isProcessing) {
      return [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              color: AppColors.primaryContainer, strokeWidth: 2),
        ),
      ];
    }
    return [
      GestureDetector(
        onTap: () => _confirmRespond(id, namaTim, 'ditolak'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.statusDangerBg,
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: AppColors.statusDangerText.withAlpha(60)),
          ),
          child: Text('Tolak',
              style: AppTextStyles.labelMd
                  .copyWith(color: AppColors.statusDangerText, fontSize: 12)),
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () => _confirmRespond(id, namaTim, 'diterima'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('Terima',
              style: AppTextStyles.labelMd
                  .copyWith(color: Colors.white, fontSize: 12)),
        ),
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 2: UNDANGAN TERKIRIM (FR-24b)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSentTab() {
    if (_loadingSent) return _buildLoadingList();
    if (_errorSent != null) return _buildErrorState(_errorSent!, _loadSent);
    if (_sent.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_rounded,
        title: 'Belum ada undangan terkirim',
        subtitle:
            'Undangan yang kamu kirim ke calon anggota\nakan muncul di sini beserta statusnya.',
      );
    }

    final menunggu =
        _sent.where((i) => i['status_pengajuan'] == 'menunggu').toList();
    final diterima =
        _sent.where((i) => i['status_pengajuan'] == 'diterima').toList();
    final ditolak =
        _sent.where((i) => i['status_pengajuan'] == 'ditolak').toList();

    return RefreshIndicator(
      color: AppColors.primaryContainer,
      onRefresh: _loadSent,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary chips
          _buildSentSummary(menunggu.length, diterima.length, ditolak.length),
          const SizedBox(height: 16),

          if (menunggu.isNotEmpty) ...[
            _buildSectionHeader(
                'Menunggu Respons', menunggu.length, Colors.amber),
            const SizedBox(height: 8),
            ...menunggu.map(_buildSentCard),
            const SizedBox(height: 16),
          ],
          if (diterima.isNotEmpty) ...[
            _buildSectionHeader(
                'Diterima', diterima.length, AppColors.statusSuccessText),
            const SizedBox(height: 8),
            ...diterima.map(_buildSentCard),
            const SizedBox(height: 16),
          ],
          if (ditolak.isNotEmpty) ...[
            _buildSectionHeader(
                'Ditolak', ditolak.length, AppColors.statusDangerText),
            const SizedBox(height: 8),
            ...ditolak.map(_buildSentCard),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSentSummary(int menunggu, int diterima, int ditolak) {
    return Row(
      children: [
        _summaryChip(
            'Menunggu', menunggu, Colors.amber.shade100, Colors.amber.shade700),
        const SizedBox(width: 8),
        _summaryChip('Diterima', diterima, AppColors.statusSuccessBg,
            AppColors.statusSuccessText),
        const SizedBox(width: 8),
        _summaryChip('Ditolak', ditolak, AppColors.statusDangerBg,
            AppColors.statusDangerText),
      ],
    );
  }

  Widget _summaryChip(String label, int count, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: fg.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text('$count',
                style: AppTextStyles.headlineMd.copyWith(
                    color: fg, fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.bodySm.copyWith(color: fg, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSentCard(Map<String, dynamic> inv) {
    final namaTim = inv['nama_tim'] as String? ?? 'Tim';
    final namaKegiatan = inv['nama_kegiatan'] as String? ?? '';
    final kategori = inv['kategori_kegiatan'] as String? ?? '';
    final namaCalon = inv['nama_calon'] as String? ?? 'Calon Anggota';
    final prodiCalon = inv['prodi_calon'] as String? ?? '';
    final pesan = inv['pesan_pengajuan'] as String? ?? '';
    final waktu = inv['waktu_pengajuan'] as String? ?? '';
    final status = inv['status_pengajuan'] as String? ?? 'menunggu';

    final parts = namaCalon.trim().split(' ');
    final inisial = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : namaCalon.substring(0, namaCalon.length.clamp(0, 2)).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3.5, color: _statusColor(status)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calon anggota
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primarySoft,
                            child: Text(inisial,
                                style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(namaCalon,
                                    style: AppTextStyles.titleMd
                                        .copyWith(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                if (prodiCalon.isNotEmpty)
                                  Text(prodiCalon,
                                      style: AppTextStyles.bodySm
                                          .copyWith(fontSize: 11)),
                              ],
                            ),
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Nama tim info
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.groups_rounded,
                                color: AppColors.primary, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(namaTim,
                                      style: AppTextStyles.bodyMd.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12)),
                                  if (namaKegiatan.isNotEmpty)
                                    Text(namaKegiatan,
                                        style: AppTextStyles.bodySm
                                            .copyWith(fontSize: 11)),
                                  if (kategori.isNotEmpty)
                                    Text(kategori,
                                        style: AppTextStyles.bodySm.copyWith(
                                            fontSize: 10,
                                            color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (pesan.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('"$pesan"',
                            style: AppTextStyles.bodySm.copyWith(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontStyle: FontStyle.italic),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],

                      const SizedBox(height: 10),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(_formatDate(waktu),
                              style:
                                  AppTextStyles.bodySm.copyWith(fontSize: 11)),
                          const Spacer(),
                          Text(
                            _statusDescription(status, namaCalon),
                            style: AppTextStyles.bodySm.copyWith(
                                fontSize: 10,
                                color: _statusColor(status),
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusDescription(String status, String nama) {
    switch (status) {
      case 'diterima':
        return '$nama menerima undangan';
      case 'ditolak':
        return '$nama menolak undangan';
      default:
        return 'Menunggu respons $nama';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, int count, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
              color: accentColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.headlineMd.copyWith(fontSize: 15)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(99)),
          child: Text('$count',
              style: AppTextStyles.labelSm
                  .copyWith(color: AppColors.primary, fontSize: 10)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg, fg;
    String label;
    IconData icon;
    switch (status) {
      case 'diterima':
        bg = AppColors.statusSuccessBg;
        fg = AppColors.statusSuccessText;
        label = 'Diterima';
        icon = Icons.check_circle_rounded;
        break;
      case 'ditolak':
        bg = AppColors.statusDangerBg;
        fg = AppColors.statusDangerText;
        label = 'Ditolak';
        icon = Icons.cancel_rounded;
        break;
      default:
        bg = AppColors.statusPendingBg;
        fg = AppColors.statusPendingText;
        label = 'Menunggu';
        icon = Icons.hourglass_top_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.labelSm.copyWith(color: fg, fontSize: 10)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'diterima':
        return AppColors.statusSuccessText;
      case 'ditolak':
        return AppColors.statusDangerText;
      default:
        return AppColors.statusPendingText;
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return 'Hari ini';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildLoadingList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
                color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 44),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.titleMd.copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textMuted, height: 1.5),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildErrorState(String msg, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(msg,
                style:
                    AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
