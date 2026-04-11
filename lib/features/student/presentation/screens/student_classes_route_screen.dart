import 'package:flutter/material.dart';

import '../../domain/entities/student_class.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/student_repository.dart';
import 'student_classes_screen.dart';

class StudentClassesRouteScreen extends StatefulWidget {
  const StudentClassesRouteScreen({
    super.key,
    required this.repository,
    required this.profile,
    required this.onClassesTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
    required this.onClassTap,
  });

  final StudentRepository repository;
  final StudentProfile profile;
  final VoidCallback onClassesTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;
  final ValueChanged<String> onClassTap;

  @override
  State<StudentClassesRouteScreen> createState() =>
      _StudentClassesRouteScreenState();
}

class _StudentClassesRouteScreenState extends State<StudentClassesRouteScreen> {
  late List<StudentClass> _classes;

  @override
  void initState() {
    super.initState();
    _classes = widget.repository.getClasses();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final List<StudentClass> classes = await widget.repository.fetchClasses();

    if (!mounted) {
      return;
    }

    setState(() {
      _classes = classes;
    });
  }

  Future<bool> _joinClass(String classCode) async {
    try {
      await widget.repository.joinClass(classCode);
      final List<StudentClass> classes = widget.repository.getClasses();

      if (!mounted) {
        return true;
      }

      setState(() {
        _classes = classes;
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StudentClassesScreen(
      classes: _classes,
      profile: widget.profile,
      onClassesTap: widget.onClassesTap,
      onSettingsTap: widget.onSettingsTap,
      onLogoutTap: widget.onLogoutTap,
      onClassTap: widget.onClassTap,
      onJoinClass: _joinClass,
    );
  }
}
