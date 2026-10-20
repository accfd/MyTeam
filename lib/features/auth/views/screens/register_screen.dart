import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_text_field.dart';

/// Halaman Registrasi Akun Mahasiswa Khusus Universitas Andalas
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _viewModel = AuthViewModel();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    // Auto-ekstrak NIM otomatis jika mahasiswa mengetik format email kampus
    // Contoh: 2411522001_fuadi@student.unand.ac.id -> NIM terisi 2411522001
    _emailCtrl.addListener(_extractNimFromEmail);
  }

  void _extractNimFromEmail() {
    final text = _emailCtrl.text.trim();
    // Tangkap 10 digit angka di posisi awal maupun tengah email (misal: 2411522001_fuadi atau fuadi_2411522001)
    final match = RegExp(r'(\d{10})').firstMatch(text);
    if (match != null) {
      final extractedNim = match.group(1)!;
      if (_nimCtrl.text != extractedNim) {
        setState(() {
          _nimCtrl.text = extractedNim;
        });
      }
    } else if (text.isEmpty && _nimCtrl.text.isNotEmpty) {
      setState(() {
        _nimCtrl.text = '';
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_extractNimFromEmail);
    _emailCtrl.dispose();
    _nimCtrl.dispose();
    _namaCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok!'),
          backgroundColor: AppColors.statusDangerText,
        ),
      );
      return;
    }

    final success = await _viewModel.register(
      nim: _nimCtrl.text.trim(),
      namaPengguna: _namaCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      kataSandi: _passCtrl.text,
      kataSandiKonfirmasi: _confirmPassCtrl.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Selamat datang di MyTeam.'),
            backgroundColor: AppColors.primaryContainer,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage ?? 'Registrasi gagal'),
            backgroundColor: AppColors.statusDangerText,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bergabung dengan MyTeam', style: AppTextStyles.headlineMd),
                    const SizedBox(height: 6),
                    Text(
                      'Khusus Mahasiswa Aktif Universitas Andalas (@student.unand.ac.id)',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 16),

                    // Kotak Info Kampus
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryOutline),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.school_outlined, color: AppColors.primary, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Hanya menerima email resmi kampus UNAND. NIM akan otomatis terisi dari format email.',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.primaryDark,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input Email Kampus UNAND
                    AuthTextField(
                      label: 'Email Resmi UNAND',
                      hint: 'Contoh: 2411522001_fuadi@student.unand.ac.id',
                      controller: _emailCtrl,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateUnandEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Input NIM Mahasiswa (Terkunci & Otomatis)
                    AuthTextField(
                      label: 'NIM Mahasiswa',
                      hint: 'Otomatis terisi setelah memasukkan email kampus',
                      controller: _nimCtrl,
                      prefixIcon: Icons.badge_outlined,
                      readOnly: true,
                      validator: Validators.validateNim,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Input Nama Lengkap
                    AuthTextField(
                      label: 'Nama Lengkap',
                      hint: 'Nama lengkap Anda',
                      controller: _namaCtrl,
                      prefixIcon: Icons.person_outline,
                      validator: (v) => Validators.validateRequired(v, 'Nama lengkap'),
                    ),
                    const SizedBox(height: 16),

                    // Input Kata Sandi
                    AuthTextField(
                      label: 'Kata Sandi',
                      hint: 'Minimal 6 karakter',
                      controller: _passCtrl,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePass,
                      onToggleVisibility: () => setState(() => _obscurePass = !_obscurePass),
                      validator: (v) => (v == null || v.length < 6) ? 'Kata sandi minimal 6 karakter' : null,
                    ),
                    const SizedBox(height: 16),

                    // Konfirmasi Kata Sandi
                    AuthTextField(
                      label: 'Konfirmasi Kata Sandi',
                      hint: 'Ulangi kata sandi Anda',
                      controller: _confirmPassCtrl,
                      prefixIcon: Icons.lock_clock_outlined,
                      isPassword: true,
                      obscureText: _obscureConfirm,
                      onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) => (v == null || v.isEmpty) ? 'Konfirmasi kata sandi wajib diisi' : null,
                    ),
                    const SizedBox(height: 28),

                    // Tombol Submit Register
                    ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _viewModel.isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _viewModel.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Daftar Sekarang',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Link Kembali ke Login
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sudah memiliki akun? ', style: AppTextStyles.bodySm),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Masuk di sini',
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
