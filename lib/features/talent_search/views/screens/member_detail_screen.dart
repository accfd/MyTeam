import 'package:flutter/material.dart';
import '../../../profile/views/screens/profile_screen.dart';
import '../../models/talent_member_model.dart';

/// Halaman Detail Profil Calon Anggota (FR-22)
/// Terpadu 100% menggunakan ProfileScreen sebagai Single Source of Truth
/// Menjamin seluruh tampilan, proporsi persegi panjang tab, dan kartu data seragam 100%
class MemberDetailScreen extends StatelessWidget {
  final TalentMemberModel member;
  final String myUserId;

  const MemberDetailScreen({
    super.key,
    required this.member,
    required this.myUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      idPenggunaOverride: member.idPengguna,
      showAppBar: true,
      visitingMember: member,
    );
  }
}
