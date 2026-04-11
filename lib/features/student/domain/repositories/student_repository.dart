import '../entities/student_class.dart';
import '../entities/student_profile.dart';

abstract class StudentRepository {
  Future<List<StudentClass>> fetchClasses();

  Future<StudentClass> joinClass(String classCode);

  Future<StudentClass> fetchClassGroup(String classId);

  Future<StudentProfile> fetchProfile();

  List<StudentClass> getClasses();

  StudentClass? getClassById(String id);

  StudentProfile getProfile();
}
