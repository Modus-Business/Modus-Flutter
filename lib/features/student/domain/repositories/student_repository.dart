import '../entities/chat_contribution_analysis.dart';
import '../entities/chat_intervention_advice.dart';
import '../entities/chat_message_advice.dart';
import '../entities/student_class.dart';
import '../entities/student_profile.dart';
import '../entities/student_upload_file.dart';

abstract class StudentRepository {
  Future<List<StudentClass>> fetchClasses();

  Future<StudentClass> joinClass(String classCode);

  Future<StudentClass> fetchClassGroup(String classId);

  Future<List<StudentAnnouncement>> fetchGroupNotices(String groupId);

  Future<StudentPresignedUpload> createPresignedUploadUrl(
    StudentUploadFile file,
  );

  Future<StudentPresignedUpload> uploadAssignmentFile(StudentUploadFile file);

  Future<void> submitAssignment(StudentSubmissionRequest request);

  Future<StudentSubmission?> fetchMySubmission(String groupId);

  Future<StudentGroupNickname> fetchGroupNickname(String groupId);

  Future<StudentChatMessageAdvice> requestChatMessageAdvice({
    required String groupId,
    required String content,
  });

  Future<StudentChatInterventionAdvice> requestChatInterventionAdvice(
    String groupId,
  );

  Future<StudentChatContributionAnalysis> requestChatContributionAnalysis(
    String groupId,
  );

  Future<StudentProfile> fetchProfile();

  List<StudentClass> getClasses();

  StudentClass? getClassById(String id);

  StudentProfile getProfile();
}
