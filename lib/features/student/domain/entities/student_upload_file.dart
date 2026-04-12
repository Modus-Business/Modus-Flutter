import 'dart:typed_data';

class StudentUploadFile {
  const StudentUploadFile({
    required this.fileName,
    required this.contentType,
    required this.bytes,
    required this.size,
    this.purpose = 'assignments',
  });

  final String fileName;
  final String contentType;
  final Uint8List bytes;
  final int size;
  final String purpose;
}

class StudentPresignedUpload {
  const StudentPresignedUpload({
    required this.fileName,
    required this.contentType,
    required this.purpose,
    required this.rawData,
    this.uploadUrl,
    this.fileUrl,
  });

  final String fileName;
  final String contentType;
  final String purpose;
  final Map<String, dynamic> rawData;
  final String? uploadUrl;
  final String? fileUrl;
}

class StudentSubmissionRequest {
  const StudentSubmissionRequest({
    required this.groupId,
    required this.fileUrl,
    required this.link,
  });

  final String groupId;
  final String fileUrl;
  final String link;
}

class StudentSubmission {
  const StudentSubmission({
    required this.submissionId,
    required this.groupId,
    required this.fileUrl,
    required this.link,
    required this.submittedBy,
    required this.submittedAt,
    required this.updatedAt,
  });

  final String submissionId;
  final String groupId;
  final String fileUrl;
  final String link;
  final String submittedBy;
  final String submittedAt;
  final String updatedAt;
}
