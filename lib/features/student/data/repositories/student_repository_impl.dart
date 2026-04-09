import '../../domain/entities/student_class.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  const StudentRepositoryImpl();

  @override
  List<StudentClass> getClasses() {
    return const [
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
  }

  @override
  StudentClass? getClassById(String id) {
    try {
      return getClasses().firstWhere((StudentClass item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  StudentProfile getProfile() {
    return const StudentProfile(
      name: '모두달리기42',
      email: 'runner42@modus.app',
      roleLabel: '수강생',
      teacherOnlyVisibility: '비공개',
      isEmailVerified: true,
    );
  }
}
