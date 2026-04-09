import '../entities/student_class.dart';
import '../entities/student_profile.dart';

abstract class StudentRepository {
  List<StudentClass> getClasses();

  StudentClass? getClassById(String id);

  StudentProfile getProfile();
}
