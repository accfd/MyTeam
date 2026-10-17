import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../team_management/services/team_management_service.dart';
import '../../models/talent_member_model.dart';
import '../../services/talent_search_service.dart';

/// Modal Bottom Sheet Formulir Pengajuan Ajakan Bergabung ke Tim
class InviteMemberBottomSheet extends StatefulWidget {
  final TalentMemberModel member;

  const InviteMemberBottomSheet({
    super.key,
    required this.member,
  });

  @override
  State<InviteMemberBottomSheet> createState() => _InviteMemberBottomSheetState();
}

class _InviteMemberBottomSheetState extends State<InviteMemberBottomSheet> {
  final _msgCtrl = TextEditingController();
  List<Map<String, dynamic>> _myTeams = [];
  bool _loadingTeams = true;
  String? _teamsErrorMsg;
  String? _selectedTeamId;
  String? _selectedPosition;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadMyTeams();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMyTeams() async {
    setState(() {
      _loadingTeams = true;
      _teamsErrorMsg = null;
    });

    try {
      final teams = await TeamManagementService.getMyTeams();
      if (!mounted) return;

      final eligible =
          teams.where((t) => t.statusTim.toLowerCase() != 'selesai').toList();

      setState(() {
        _myTeams = eligible.map((t) => {
          'id_tim': t.idTim,
          'nama_tim': t.namaTim,
          'nama_kegiatan': t.namaKegiatan,
          'kebutuhan_tim': t.kebutuhanTim.map((k) {
            final terisiCount = t.anggotaTim
                .where((a) =>
                    a.posisi.trim().toLowerCase() ==
                    k.posisiDibutuhkan.trim().toLowerCase())
                .length;
            return {
              'posisi_dibutuhkan': k.posisiDibutuhkan,
              'kuota': k.jumlahAnggotaDibutuhkan,
              'terisi': terisiCount,
            };
          }).toList(),
        }).toList();

        if (_myTeams.isNotEmpty) {
          _selectedTeamId = _myTeams.first['id_tim'];
          final pos = _availablePositions;
          if (pos.isNotEmpty) {
            _selectedPosition = pos.keys.first;
          }
        }
        _loadingTeams = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _teamsErrorMsg = e.toString().replaceFirst('Exception: ', '');
        _loadingTeams = false;
      });
    }
  }

  Map<String, int> get _availablePositions {
    final team = _myTeams.where((item) => item['id_tim'] == _selectedTeamId);
    if (team.isEmpty) return {};

    final needs = team.first['kebutuhan_tim'] as List<dynamic>? ?? [];
    final map = <String, int>{};
    for (final item in needs) {
      final pos = item['posisi_dibutuhkan']?.toString() ?? '';
      final kuota = (item['kuota'] as num?)?.toInt() ?? 1;
      final terisi = (item['terisi'] as num?)?.toInt() ?? 0;
      final remaining = kuota - terisi;
      if (remaining > 0 && pos.isNotEmpty) {
        map[pos] = remaining;
      }
    }
    return map;
  }

  Future<void> _sendInvitation() async {
    if (_selectedTeamId == null || _selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tim dan posisi terlebih dahulu.'),
          backgroundColor: AppColors.statusDangerText,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await TalentSearchService.inviteMember(
        idTim: _selectedTeamId!,
        idPengguna: widget.member.idPengguna,
        posisi: _selectedPosition!,
        pesanPengajuan: _msgCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Undangan berhasil dikirim kepada ${widget.member.namaPengguna}!',
          ),
          backgroundColor: AppColors.statusSuccessText,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.statusDangerText,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Judul Sheet
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ajak Bergabung ke Tim',
                          style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Kirim undangan kepada ${widget.member.namaPengguna}',
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),

              if (_loadingTeams)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_teamsErrorMsg != null)
                Text(_teamsErrorMsg!,
                    style:
                        const TextStyle(color: AppColors.statusDangerText))
              else if (_myTeams.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.textMuted, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Anda belum memiliki tim yang aktif.',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buat tim terlebih dahulu di tab MyTeam untuk dapat mengundang anggota.',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else ...[
                // Pilih Tim
                Text('Pilih Tim Anda',
                    style: AppTextStyles.labelMd
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTeamId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  items: _myTeams.map((t) {
                    return DropdownMenuItem<String>(
                      value: t['id_tim'],
                      child: Text(t['nama_tim'],
                          style: AppTextStyles.bodySm
                              .copyWith(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedTeamId = val;
                      final pos = _availablePositions;
                      _selectedPosition =
                          pos.isNotEmpty ? pos.keys.first : null;
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Pilih Posisi
                Text('Pilih Posisi Ditawarkan',
                    style: AppTextStyles.labelMd
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (_availablePositions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusDangerBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Semua kuota posisi pada tim ini telah penuh.',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.statusDangerText),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPosition,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: _availablePositions.entries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.key,
                        child: Text('${e.key} (Sisa ${e.value} kuota)',
                            style: AppTextStyles.bodySm),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedPosition = val);
                    },
                  ),
                const SizedBox(height: 14),

                // Pesan Ajakan
                Text('Pesan Ajakan (Opsional)',
                    style: AppTextStyles.labelMd
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _msgCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Tuliskan alasan mengapa Anda mengajak mahasiswa ini bergabung...',
                    hintStyle: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Kirim Undangan
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _sendInvitation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Kirim Undangan Sekarang',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
