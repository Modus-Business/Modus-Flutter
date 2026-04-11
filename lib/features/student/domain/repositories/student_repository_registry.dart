import 'student_repository.dart';

class StudentRepositoryRegistry {
  StudentRepositoryRegistry._();

  static StudentRepository? _repository;

  static StudentRepository? get repository => _repository;

  static void register(StudentRepository repository) {
    _repository = repository;
  }
}
