import 'package:flutter/material.dart';

class AuthSectionBadge extends StatelessWidget {
  const AuthSectionBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
          color: Color(0xFF4865D6),
        ),
      ),
    );
  }
}
