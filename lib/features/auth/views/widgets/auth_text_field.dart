import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Reusable Widget Text Field untuk Halaman Autentikasi
class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final String? helperText;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.text, fontSize: 13),
            ),
            if (readOnly) ...[
              const SizedBox(width: 6),
              const Icon(Icons.lock_outline, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '(Terkunci otomatis)',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMd.copyWith(
            color: readOnly ? const Color(0xFF374151) : AppColors.text,
            fontWeight: readOnly ? FontWeight.w600 : FontWeight.normal,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            helperText: helperText,
            helperStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted, fontSize: 11.5),
            prefixIcon: Icon(
              prefixIcon,
              color: readOnly ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : (readOnly
                    ? const Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 18)
                    : null),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF3F4F6) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: readOnly ? const Color(0xFFE5E7EB) : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: readOnly ? const Color(0xFFE5E7EB) : AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: readOnly ? const Color(0xFFE5E7EB) : AppColors.primary,
                width: readOnly ? 1.0 : 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
