import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Splash / Landing Screen — MyTeam
/// Ditampilkan selama 2.5 detik, lalu otomatis navigate ke halaman Login.
/// Sesuai permintaan: latar putih, logo MyTeam di tengah, teks branding di bawah.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigasi ke Login setelah 2.8 detik
    Future.delayed(const Duration(milliseconds: 2800), _navigateToLogin);
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo MyTeam ──────────────────────────────────────────
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withAlpha(38),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        'assets/images/logo-MyTeam.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Nama Aplikasi ─────────────────────────────────────────
                  Text(
                    'MyTeam',
                    style: AppTextStyles.headlineXl.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── Tagline ───────────────────────────────────────────────
                  Text(
                    'Platform Kolaborasi Tim Mahasiswa Unand',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 80),

                  // ── Loading indicator kecil ───────────────────────────────
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryContainer),
                    ),
                  ),

                  const SizedBox(height: 64),

                  // ── Copyright ─────────────────────────────────────────────
                  Text(
                    'MyTeam V.01  •  All Right Reserved',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textMuted.withAlpha(153),
                      letterSpacing: 0.6,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Universitas Andalas',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textMuted.withAlpha(102),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
