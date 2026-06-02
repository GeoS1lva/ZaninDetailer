import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AdminCustomInput extends StatelessWidget {
  final String hint;
  final String? prefixText;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const AdminCustomInput({
    super.key,
    required this.hint,
    required this.controller,
    this.prefixText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: baseStyle,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            baseStyle?.copyWith(color: Colors.white.withValues(alpha: 0.3)),
        prefixText: prefixText,
        prefixStyle: baseStyle?.copyWith(fontWeight: FontWeight.bold),
        filled: true,
        fillColor: const Color(0xFF161616),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryRed, width: 1),
        ),
      ),
    );
  }
}
