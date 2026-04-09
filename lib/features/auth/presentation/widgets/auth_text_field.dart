import 'package:flutter/material.dart';

import '../../../../component/theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.icon,
    this.label,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  final String? label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryInk,
            ),
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF2F5FC),
            prefixIcon: Icon(icon, color: const Color(0xFF7A87A6)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 22,
            ),
            hintStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF96A2BD),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(color: Color(0xFFE1E7F4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(color: Color(0xFFE1E7F4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(
                color: Color(0xFF6C84F1),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
