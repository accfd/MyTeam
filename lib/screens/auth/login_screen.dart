import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Login & Daftar Screen — MyTeam Auth Module
/// Berisi dua tab: [Masuk] dan [Daftar] dalam satu halaman dengan toggle.
/// Referensi desain: gambar mockup + DESIGN.md "Academic Emerald Synergy"
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── Tab state ──────────────────────────────────────────────────────────────
  bool _isMasukTab = true;

  // ── Form Masuk ────────────────────────────────────────────────────────────
  final _loginFormKey = GlobalKey<FormState>();
  final _loginNimCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _loginPassVisible = false;
  bool _loginLoading = false;

  // ── Form Daftar ───────────────────────────────────────────────────────────
  final _registerFormKey = GlobalKey<FormState>();
  final _regNimCtrl = TextEditingController();
  final _regNamaCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regPassConfCtrl = TextEditingController();
  bool _regPassVisible = false;
  bool _regPassConfVisible = false;
  bool _regLoading = false;

  // ── Animation ────────────────────────────────────────────────────────────
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _loginNimCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNimCtrl.dispose();
    _regNamaCtrl.dispose();
    _regPassCtrl.dispose();
    _regPassConfCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────────

  void _switchTab(bool isMasuk) {
    if (_isMasukTab == isMasuk) return;
    _fadeCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _isMasukTab = isMasuk);
      _fadeCtrl.forward();
    });
  }

  Future<void> _doLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loginLoading = true);
    try {
      final UserModel user = await AuthService.login(
        nim: _loginNimCtrl.text.trim(),
        kataSandi: _loginPassCtrl.text,
      );
      await StorageService.saveUserSession(
        idPengguna: user.idPengguna,
        nim: user.nim,
        namaPengguna: user.namaPengguna,
        token: user.token,
        fotoProfil: user.fotoProfil,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _showSnackbar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  Future<void> _doRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() => _regLoading = true);
    try {
      final UserModel user = await AuthService.register(
        nim: _regNimCtrl.text.trim(),
        namaPengguna: _regNamaCtrl.text.trim(),
        kataSandi: _regPassCtrl.text,
        kataSandiKonfirmasi: _regPassConfCtrl.text,
      );
      await StorageService.saveUserSession(
        idPengguna: user.idPengguna,
        nim: user.nim,
        namaPengguna: user.namaPengguna,
        token: user.token,
        fotoProfil: user.fotoProfil,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _showSnackbar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _regLoading = false);
    }
  }

  void _showSnackbar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? AppColors.statusDangerText : AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTabToggle(),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _isMasukTab ? _buildLoginForm() : _buildRegisterForm(),
                ),
                const SizedBox(height: 20),
                _buildProofCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header: Logo + Judul ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo MyTeam
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withAlpha(46),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/images/logo-MyTeam.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Judul
        Text(
          'Selamat Datang di MyTeam',
          style: AppTextStyles.headlineLg,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        Text(
          'Platform Kolaborasi & Pencarian Rekan Tim\nMahasiswa Universitas Andalas',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Tab Toggle: Masuk | Daftar ────────────────────────────────────────────
  Widget _buildTabToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTabButton(label: 'Masuk', icon: Icons.login_rounded, isActive: _isMasukTab, onTap: () => _switchTab(true)),
          _buildTabButton(label: 'Daftar', icon: Icons.person_add_alt_1_rounded, isActive: !_isMasukTab, onTap: () => _switchTab(false)),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryContainer.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMd.copyWith(
                  color: isActive ? Colors.white : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Form Card Container ───────────────────────────────────────────────────
  Widget _buildFormCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Form Masuk ────────────────────────────────────────────────────────────
  Widget _buildLoginForm() {
    return _buildFormCard(
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NIM field
            _buildFieldLabel('NIM'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _loginNimCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: 'Contoh: 2411522001',
                prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.textMuted),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'NIM wajib diisi';
                if (v.trim().length < 7) return 'NIM tidak valid';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Kata Sandi field
            _buildFieldLabel('Kata Sandi'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _loginPassCtrl,
              obscureText: !_loginPassVisible,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: '••••••••••••',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(
                    _loginPassVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => setState(() => _loginPassVisible = !_loginPassVisible),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                if (v.length < 6) return 'Kata sandi minimal 6 karakter';
                return null;
              },
            ),

            // Lupa Kata Sandi
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                child: Text(
                  'Lupa Kata Sandi?',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Tombol Masuk
            ElevatedButton(
              onPressed: _loginLoading ? null : _doLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                disabledBackgroundColor: AppColors.primaryOutline,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _loginLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Masuk ke MyTeam', style: AppTextStyles.labelLg.copyWith(fontSize: 15)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Form Daftar ───────────────────────────────────────────────────────────
  Widget _buildRegisterForm() {
    return _buildFormCard(
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NIM
            _buildFieldLabel('NIM Mahasiswa'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regNimCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.bodyMd,
              decoration: const InputDecoration(
                hintText: 'Contoh: 2411522001',
                prefixIcon: Icon(Icons.badge_outlined, size: 20, color: AppColors.textMuted),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'NIM wajib diisi';
                if (v.trim().length < 7) return 'NIM tidak valid';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Nama Lengkap
            _buildFieldLabel('Nama Lengkap'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regNamaCtrl,
              textCapitalization: TextCapitalization.words,
              style: AppTextStyles.bodyMd,
              decoration: const InputDecoration(
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textMuted),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                if (v.trim().length < 3) return 'Nama terlalu pendek';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Kata Sandi
            _buildFieldLabel('Kata Sandi'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regPassCtrl,
              obscureText: !_regPassVisible,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: 'Min. 6 karakter',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(
                    _regPassVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => setState(() => _regPassVisible = !_regPassVisible),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                if (v.length < 6) return 'Kata sandi minimal 6 karakter';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Konfirmasi Kata Sandi
            _buildFieldLabel('Konfirmasi Kata Sandi'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regPassConfCtrl,
              obscureText: !_regPassConfVisible,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: 'Ulangi kata sandi',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(
                    _regPassConfVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => setState(() => _regPassConfVisible = !_regPassConfVisible),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
                if (v != _regPassCtrl.text) return 'Kata sandi tidak cocok';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Tombol Daftar
            ElevatedButton(
              onPressed: _regLoading ? null : _doRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                disabledBackgroundColor: AppColors.primaryOutline,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _regLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Buat Akun MyTeam', style: AppTextStyles.labelLg.copyWith(fontSize: 15)),
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.white),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Label Field ───────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelMd.copyWith(color: AppColors.text),
    );
  }

  // ── Social Proof Card ─────────────────────────────────────────────────────
  Widget _buildProofCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryOutline, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: AppColors.primaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '340+ Proyek Aktif',
                      style: AppTextStyles.titleMd.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.categoryCompetitionBg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'PKM & Lomba',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.categoryCompetitionText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Temukan teman satu visi dari lintas 15 fakultas',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
