class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.teacherOnlyVisibility,
    required this.isEmailVerified,
  });

  final String name;
  final String email;
  final String roleLabel;
  final String teacherOnlyVisibility;
  final bool isEmailVerified;
}
