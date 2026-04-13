import '../../domain/entities/chat_contribution_analysis.dart';
import '../../domain/entities/chat_intervention_advice.dart';
import '../../domain/entities/chat_message_advice.dart';
import '../../domain/entities/student_class.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/entities/student_upload_file.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/student_repository_registry.dart';
import '../datasources/student_remote_data_source.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl({this.remoteDataSource})
    : _cachedClasses = <StudentClass>[],
      _cachedProfile = _fallbackProfile {
    StudentRepositoryRegistry.register(this);
  }

  final StudentRemoteDataSource? remoteDataSource;
  List<StudentClass> _cachedClasses;
  StudentProfile _cachedProfile;

  static const StudentProfile _fallbackProfile = StudentProfile(
    name: '모두달리기42',
    email: 'runner42@modus.app',
    roleLabel: '수강생',
    teacherOnlyVisibility: '비공개',
    isEmailVerified: true,
  );

  static const List<StudentClass> _dummyClasses = <StudentClass>[
    StudentClass(
      id: 'product-studio',
      title: '프로덕트 스튜디오',
      description: '서비스 구조 설계와 퍼블리싱을 함께 진행하는\n메인 실습 수업',
      classCode: 'MODUS-7J2Q',
      groupAssigned: true,
      groupName: '모둠 3 · 스프린트',
      assignments: [
        StudentAssignment(
          id: 'a1',
          title: '발표 자료 슬라이드 정리',
          dueDateLabel: '2026-04-10',
          status: AssignmentStatus.pending,
        ),
        StudentAssignment(
          id: 'a2',
          title: '작업 링크 및 역할 분담표 제출',
          dueDateLabel: '2026-04-12',
          status: AssignmentStatus.pending,
        ),
      ],
      announcements: [
        StudentAnnouncement(
          id: 'n1',
          title: '2차 중간 점검 공지',
          summary: '금일 수업 시작 10분 전까지 시안 링크와 담당 역할을 정리해 주세요.',
          dateLabel: '2026-04-07',
        ),
        StudentAnnouncement(
          id: 'n2',
          title: '발표 자료 템플릿 공유',
          summary: '공용 발표 슬라이드 템플릿이 업데이트되었습니다.',
          dateLabel: '2026-04-05',
        ),
        StudentAnnouncement(
          id: 'n3',
          title: '과제 제출 포맷 안내',
          summary: '작업 링크, 요약, 역할 분담표를 함께 제출합니다.',
          dateLabel: '2026-04-02',
        ),
      ],
      chatMessages: [
        StudentChatMessage(
          id: 'm1',
          author: '청설모코더',
          message: '메인 카드 간격은 24px 기준으로 맞추고, 헤더는 클래스룸처럼 넓게 가져가면 좋겠어요.',
          sentAt: '오후 7:14',
          isMine: false,
        ),
        StudentChatMessage(
          id: 'm2',
          author: '야행성토끼',
          message: '공지 버튼은 팝업으로 빼고, 오른쪽 멤버 영역은 고정 폭으로 두면 균형이 좋아요.',
          sentAt: '오후 7:16',
          isMine: false,
        ),
        StudentChatMessage(
          id: 'm3',
          author: '모두달리기42',
          message: '좋아요. 메인 톤은 첫 레퍼런스처럼 밝은 블루 계열로 통일해볼게요.',
          sentAt: '오후 7:18',
          isMine: true,
        ),
      ],
      group: StudentGroup(
        id: 'group-1',
        name: '모둠 3 · 스프린트',
        members: ['모두달리기42', '청설모코더', '야행성토끼', '노트북바람'],
        classCode: 'MODUS-7J2Q',
      ),
    ),
    StudentClass(
      id: 'design-writing',
      title: '디자인 라이팅 워크숍',
      description: '텍스트 톤앤매너와 설명형 UI 문구를 다듬는\n보조 워크숍',
      classCode: 'MODUS-8K1A',
      groupAssigned: false,
      groupName: null,
      assignments: [
        StudentAssignment(
          id: 'a3',
          title: '첫 문장 후보 정리',
          dueDateLabel: '2026-04-14',
          status: AssignmentStatus.pending,
        ),
      ],
      announcements: [
        StudentAnnouncement(
          id: 'n4',
          title: '워크숍 자료 업로드',
          summary: '톤앤매너 비교표와 문장 사례집을 올렸습니다.',
          dateLabel: '2026-04-08',
        ),
      ],
      chatMessages: [],
      group: null,
    ),
  ];

  @override
  Future<List<StudentClass>> fetchClasses() async {
    if (remoteDataSource == null) {
      return getClasses();
    }

    try {
      final List<Map<String, dynamic>> remoteClasses = await remoteDataSource!
          .fetchClasses();
      final List<StudentClass> mapped = remoteClasses
          .map(_mapRemoteClass)
          .whereType<StudentClass>()
          .toList();
      _cachedClasses = mapped;
    } on StudentRemoteException {
      _cachedClasses = <StudentClass>[];
    }

    return getClasses();
  }

  @override
  Future<StudentClass> joinClass(String classCode) async {
    if (remoteDataSource == null) {
      throw const StudentRemoteException('수업 참여 API가 연결되지 않았습니다.');
    }

    final Map<String, dynamic> response = await remoteDataSource!.joinClass(
      classCode,
    );
    final StudentClass? joinedClass = _mapRemoteClass(response);

    if (joinedClass == null) {
      throw const StudentRemoteException('참여한 수업 정보를 확인할 수 없습니다.');
    }

    final int existingIndex = _cachedClasses.indexWhere(
      (StudentClass item) => item.id == joinedClass.id,
    );

    if (existingIndex >= 0) {
      _cachedClasses[existingIndex] = joinedClass;
    } else {
      _cachedClasses = <StudentClass>[joinedClass, ..._cachedClasses];
    }

    return joinedClass;
  }

  @override
  Future<StudentClass> fetchClassGroup(String classId) async {
    final StudentClass? currentClass = getClassById(classId);

    if (currentClass == null) {
      throw const StudentRemoteException('수업 정보를 확인할 수 없습니다.');
    }

    if (remoteDataSource == null) {
      return currentClass;
    }

    final String? groupId = currentClass.group?.id?.trim();

    if (groupId == null || groupId.isEmpty) {
      return _replaceCachedClass(
        currentClass.copyWith(
          groupAssigned: false,
          groupName: null,
          group: null,
        ),
      );
    }

    final Map<String, dynamic> groupDetail = await remoteDataSource!
        .fetchGroupDetail(groupId);
    final StudentGroup group = _mapRemoteGroup(
      groupDetail,
      fallbackClassCode: currentClass.classCode,
      fallbackName: currentClass.groupName,
    );

    return _replaceCachedClass(
      currentClass.copyWith(
        groupAssigned: true,
        groupName: group.name,
        group: group,
      ),
    );
  }

  @override
  Future<List<StudentAnnouncement>> fetchGroupNotices(String groupId) async {
    if (remoteDataSource == null) {
      return const <StudentAnnouncement>[];
    }

    final List<Map<String, dynamic>> remoteNotices = await remoteDataSource!
        .fetchGroupNotices(groupId);

    return remoteNotices
        .map(_mapRemoteAnnouncement)
        .whereType<StudentAnnouncement>()
        .toList();
  }

  @override
  Future<StudentPresignedUpload> createPresignedUploadUrl(
    StudentUploadFile file,
  ) async {
    if (remoteDataSource == null) {
      throw const StudentRemoteException('파일 업로드 URL API가 연결되지 않았습니다.');
    }

    final Map<String, dynamic> data = await remoteDataSource!
        .createPresignedUploadUrl(
          fileName: file.fileName,
          contentType: file.contentType,
          purpose: file.purpose,
        );

    return StudentPresignedUpload(
      fileName: file.fileName,
      contentType: file.contentType,
      purpose: file.purpose,
      rawData: data,
      uploadUrl: _firstString(data, const <String>[
        'uploadUrl',
        'presignedUrl',
        'url',
        'signedUrl',
      ]),
      fileUrl: _firstString(data, const <String>[
        'fileUrl',
        'publicUrl',
        'downloadUrl',
        'objectUrl',
      ]),
    );
  }

  @override
  Future<StudentPresignedUpload> uploadAssignmentFile(
    StudentUploadFile file,
  ) async {
    if (remoteDataSource == null) {
      throw const StudentRemoteException('파일 업로드 API가 연결되지 않았습니다.');
    }

    if (file.bytes.isEmpty) {
      throw const StudentRemoteException('업로드할 파일을 읽을 수 없습니다.');
    }

    final StudentPresignedUpload presignedUpload =
        await createPresignedUploadUrl(file);
    final String? uploadUrl = presignedUpload.uploadUrl?.trim();

    if (uploadUrl == null || uploadUrl.isEmpty) {
      throw const StudentRemoteException('파일 업로드 주소를 확인할 수 없습니다.');
    }

    await remoteDataSource!.uploadPresignedFile(
      uploadUrl: uploadUrl,
      contentType: file.contentType,
      bytes: file.bytes,
    );

    return StudentPresignedUpload(
      fileName: presignedUpload.fileName,
      contentType: presignedUpload.contentType,
      purpose: presignedUpload.purpose,
      rawData: presignedUpload.rawData,
      uploadUrl: presignedUpload.uploadUrl,
      fileUrl: _uploadedFileUrl(presignedUpload),
    );
  }

  @override
  Future<void> submitAssignment(StudentSubmissionRequest request) async {
    if (remoteDataSource == null) {
      throw const StudentRemoteException('과제 제출 API가 연결되지 않았습니다.');
    }

    await remoteDataSource!.submitAssignment(
      groupId: request.groupId,
      fileUrl: request.fileUrl,
      link: request.link,
    );
  }

  @override
  Future<StudentSubmission?> fetchMySubmission(String groupId) async {
    if (remoteDataSource == null) {
      return null;
    }

    final Map<String, dynamic>? data = await remoteDataSource!
        .fetchMySubmission(groupId);

    if (data == null) {
      return null;
    }

    return _mapRemoteSubmission(data);
  }

  @override
  Future<StudentGroupNickname> fetchGroupNickname(String groupId) async {
    if (remoteDataSource == null) {
      throw const StudentRemoteException('모둠 닉네임 API가 연결되지 않았습니다.');
    }

    final Map<String, dynamic> data = await remoteDataSource!
        .fetchGroupNickname(groupId);

    return StudentGroupNickname(
      groupId: data['groupId'] as String? ?? groupId,
      nickname: data['nickname'] as String? ?? '알 수 없는 닉네임',
      reason: data['reason'] as String? ?? '닉네임 설명이 제공되지 않았습니다.',
    );
  }

  @override
  Future<StudentChatMessageAdvice> requestChatMessageAdvice({
    required String groupId,
    required String content,
  }) async {
    if (remoteDataSource == null) {
      throw const StudentRemoteException('메시지 AI 조언 API가 연결되지 않았습니다.');
    }

    final Map<String, dynamic> data = await remoteDataSource!
        .requestChatMessageAdvice(groupId: groupId, content: content);

    return _mapRemoteChatMessageAdvice(data, fallbackGroupId: groupId);
  }

  @override
  Future<StudentChatInterventionAdvice> requestChatInterventionAdvice(
    String groupId,
  ) async {
    if (remoteDataSource == null) {
      throw const StudentRemoteException('그룹 대화 AI 조언 API가 연결되지 않았습니다.');
    }

    final Map<String, dynamic> data = await remoteDataSource!
        .requestChatInterventionAdvice(groupId);

    return _mapRemoteChatInterventionAdvice(data, fallbackGroupId: groupId);
  }

  @override
  Future<StudentChatContributionAnalysis> requestChatContributionAnalysis(
    String groupId,
  ) async {
    if (remoteDataSource == null) {
      throw const StudentRemoteException('그룹 대화 기여도 분석 API가 연결되지 않았습니다.');
    }

    final Map<String, dynamic> data = await remoteDataSource!
        .requestChatContributionAnalysis(groupId);

    return _mapRemoteChatContributionAnalysis(data, fallbackGroupId: groupId);
  }

  @override
  List<StudentClass> getClasses() {
    return List<StudentClass>.from(_cachedClasses);
  }

  @override
  Future<StudentProfile> fetchProfile() async {
    if (remoteDataSource == null) {
      return getProfile();
    }

    try {
      final Map<String, dynamic> remoteProfile = await remoteDataSource!
          .fetchSettings();
      _cachedProfile = _mapRemoteProfile(remoteProfile);
    } on StudentRemoteException {
      return getProfile();
    }

    return getProfile();
  }

  @override
  StudentClass? getClassById(String id) {
    try {
      return _cachedClasses
          .followedBy(_dummyClasses)
          .firstWhere((StudentClass item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  StudentProfile getProfile() {
    return _cachedProfile;
  }

  StudentClass? _mapRemoteClass(Map<String, dynamic> json) {
    final String? classId = json['classId'] as String?;
    final String? name = json['name'] as String?;
    final String? description = json['description'] as String?;

    if (classId == null || classId.isEmpty || name == null || name.isEmpty) {
      return null;
    }

    final Map<String, dynamic>? myGroup =
        json['myGroup'] as Map<String, dynamic>?;
    final String classCode =
        (json['classCode'] as String?)?.trim().isNotEmpty == true
        ? (json['classCode'] as String).trim()
        : '코드 미정';
    final String? groupId = (myGroup?['groupId'] as String?)?.trim();
    final String? groupName = (myGroup?['name'] as String?)?.trim();
    final bool groupAssigned =
        (groupId != null && groupId.isNotEmpty) ||
        (groupName != null && groupName.isNotEmpty);
    final String resolvedGroupName = groupName != null && groupName.isNotEmpty
        ? groupName
        : '내 모둠';

    return StudentClass(
      id: classId,
      title: name,
      description: description?.trim().isNotEmpty == true
          ? description!.trim()
          : '수업 설명이 아직 등록되지 않았습니다.',
      classCode: classCode,
      groupAssigned: groupAssigned,
      groupName: groupAssigned ? resolvedGroupName : null,
      assignments: const <StudentAssignment>[],
      announcements: const <StudentAnnouncement>[],
      chatMessages: const <StudentChatMessage>[],
      group: groupAssigned
          ? StudentGroup(
              id: groupId,
              name: resolvedGroupName,
              members: const <String>[],
              classCode: classCode,
            )
          : null,
    );
  }

  StudentClass _replaceCachedClass(StudentClass studentClass) {
    final int existingIndex = _cachedClasses.indexWhere(
      (StudentClass item) => item.id == studentClass.id,
    );

    if (existingIndex >= 0) {
      _cachedClasses[existingIndex] = studentClass;
    }

    return studentClass;
  }

  StudentGroup _mapRemoteGroup(
    Map<String, dynamic> json, {
    required String fallbackClassCode,
    String? fallbackName,
  }) {
    final String? groupName = (json['name'] as String?)?.trim();
    final List<dynamic> rawMembers =
        json['members'] as List<dynamic>? ?? <dynamic>[];
    final List<String> members = rawMembers
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> member) {
          return (member['displayName'] as String?)?.trim();
        })
        .whereType<String>()
        .where((String displayName) => displayName.isNotEmpty)
        .toList();

    return StudentGroup(
      id: json['groupId'] as String?,
      name: groupName != null && groupName.isNotEmpty
          ? groupName
          : fallbackName ?? '내 모둠',
      members: members,
      classCode: fallbackClassCode,
    );
  }

  StudentAnnouncement? _mapRemoteAnnouncement(Map<String, dynamic> json) {
    final String? noticeId = (json['noticeId'] as String?)?.trim();
    final String? title = (json['title'] as String?)?.trim();
    final String? content = (json['content'] as String?)?.trim();

    if (noticeId == null ||
        noticeId.isEmpty ||
        title == null ||
        title.isEmpty) {
      return null;
    }

    return StudentAnnouncement(
      id: noticeId,
      title: title,
      summary: content != null && content.isNotEmpty ? content : '공지 내용이 없습니다.',
      dateLabel: _dateLabel(json['createdAt'] as String?),
    );
  }

  String _dateLabel(String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) {
      return '날짜 미정';
    }

    return isoDate.trim().split('T').first;
  }

  String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  String _uploadedFileUrl(StudentPresignedUpload presignedUpload) {
    final String? fileUrl = presignedUpload.fileUrl?.trim();

    if (fileUrl != null && fileUrl.isNotEmpty) {
      return fileUrl;
    }

    final String? uploadUrl = presignedUpload.uploadUrl?.trim();

    if (uploadUrl == null || uploadUrl.isEmpty) {
      return '';
    }

    final Uri? uri = Uri.tryParse(uploadUrl);

    if (uri == null) {
      return uploadUrl;
    }

    return uri.replace(query: '', fragment: '').toString();
  }

  StudentProfile _mapRemoteProfile(Map<String, dynamic> json) {
    final String? name = (json['name'] as String?)?.trim();
    final String? email = (json['email'] as String?)?.trim();
    final String role = (json['role'] as String?)?.trim().toLowerCase() ?? '';

    return StudentProfile(
      name: name != null && name.isNotEmpty ? name : _cachedProfile.name,
      email: email != null && email.isNotEmpty ? email : _cachedProfile.email,
      roleLabel: _roleLabel(role),
      teacherOnlyVisibility: _cachedProfile.teacherOnlyVisibility,
      isEmailVerified:
          json['isEmailVerified'] as bool? ?? _cachedProfile.isEmailVerified,
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'student':
        return '수강생';
      case 'teacher':
        return '교강사';
      default:
        return _cachedProfile.roleLabel;
    }
  }

  StudentSubmission _mapRemoteSubmission(Map<String, dynamic> json) {
    return StudentSubmission(
      submissionId: json['submissionId'] as String? ?? '',
      groupId: json['groupId'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? '',
      link: json['link'] as String? ?? '',
      submittedBy: json['submittedBy'] as String? ?? '',
      submittedAt: _dateLabel(json['submittedAt'] as String?),
      updatedAt: _dateLabel(json['updatedAt'] as String?),
    );
  }

  StudentChatMessageAdvice _mapRemoteChatMessageAdvice(
    Map<String, dynamic> json, {
    required String fallbackGroupId,
  }) {
    return StudentChatMessageAdvice(
      groupId: json['groupId'] as String? ?? fallbackGroupId,
      riskLevel: ChatMessageRiskLevel.fromValue(json['riskLevel'] as String?),
      shouldBlock: json['shouldBlock'] as bool? ?? false,
      warning: json['warning'] as String? ?? '',
      suggestedRewrite: json['suggestedRewrite'] as String? ?? '',
    );
  }

  StudentChatInterventionAdvice _mapRemoteChatInterventionAdvice(
    Map<String, dynamic> json, {
    required String fallbackGroupId,
  }) {
    return StudentChatInterventionAdvice(
      groupId: json['groupId'] as String? ?? fallbackGroupId,
      interventionNeeded: json['interventionNeeded'] as bool? ?? false,
      interventionType: ChatInterventionType.fromValue(
        json['interventionType'] as String?,
      ),
      reason: json['reason'] as String? ?? '',
      suggestedMessage: json['suggestedMessage'] as String? ?? '',
    );
  }

  StudentChatContributionAnalysis _mapRemoteChatContributionAnalysis(
    Map<String, dynamic> json, {
    required String fallbackGroupId,
  }) {
    final List<dynamic> rawMembers =
        json['members'] as List<dynamic>? ?? <dynamic>[];

    return StudentChatContributionAnalysis(
      groupId: json['groupId'] as String? ?? fallbackGroupId,
      summary: json['summary'] as String? ?? '',
      members: rawMembers
          .whereType<Map<String, dynamic>>()
          .map(_mapRemoteChatContributionMember)
          .toList(),
    );
  }

  StudentChatContributionMember _mapRemoteChatContributionMember(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rawTypes =
        json['contributionTypes'] as List<dynamic>? ?? <dynamic>[];
    final num score = json['contributionScore'] as num? ?? 0;

    return StudentChatContributionMember(
      nickname: json['nickname'] as String? ?? '알 수 없는 닉네임',
      contributionScore: score.round(),
      contributionLevel: ChatContributionLevel.fromValue(
        json['contributionLevel'] as String?,
      ),
      contributionTypes: rawTypes
          .whereType<String>()
          .where((String type) => type.trim().isNotEmpty)
          .map((String type) => type.trim())
          .toList(),
      reason: json['reason'] as String? ?? '',
    );
  }
}
