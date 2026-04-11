import '../../domain/entities/student_class.dart';
import '../../domain/entities/student_profile.dart';
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

    final Map<String, dynamic> myGroup = await remoteDataSource!.fetchMyGroup(
      classId,
    );
    final bool hasGroup = myGroup['hasGroup'] as bool? ?? false;

    if (!hasGroup) {
      return _replaceCachedClass(
        currentClass.copyWith(
          groupAssigned: false,
          groupName: null,
          group: null,
        ),
      );
    }

    final Map<String, dynamic>? groupSummary =
        myGroup['group'] as Map<String, dynamic>?;
    final String? groupId = (groupSummary?['groupId'] as String?)?.trim();

    if (groupId == null || groupId.isEmpty) {
      throw const StudentRemoteException('내 모둠 식별자를 확인할 수 없습니다.');
    }

    final Map<String, dynamic> groupDetail = await remoteDataSource!
        .fetchGroupDetail(groupId);
    final StudentGroup group = _mapRemoteGroup(
      groupDetail,
      fallbackClassCode: currentClass.classCode,
      fallbackName: groupSummary?['name'] as String?,
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
    final String? groupName = (myGroup?['name'] as String?)?.trim();
    final bool groupAssigned = groupName != null && groupName.isNotEmpty;
    final String resolvedGroupName = groupName ?? '';

    return StudentClass(
      id: classId,
      title: name,
      description: description?.trim().isNotEmpty == true
          ? description!.trim()
          : '수업 설명이 아직 등록되지 않았습니다.',
      classCode: classCode,
      groupAssigned: groupAssigned,
      groupName: groupAssigned ? groupName : null,
      assignments: const <StudentAssignment>[],
      announcements: const <StudentAnnouncement>[],
      chatMessages: const <StudentChatMessage>[],
      group: groupAssigned
          ? StudentGroup(
              id: myGroup?['groupId'] as String?,
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
}
