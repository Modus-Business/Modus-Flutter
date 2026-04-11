class StudentUploadFile {
  const StudentUploadFile({
    required this.fileName,
    required this.contentType,
    this.purpose = 'assignments',
  });

  final String fileName;
  final String contentType;
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
