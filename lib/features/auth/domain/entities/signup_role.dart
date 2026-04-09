enum SignupRole {
  student,
  teacher;

  String get label {
    switch (this) {
      case SignupRole.student:
        return '수강생';
      case SignupRole.teacher:
        return '교강사';
    }
  }

  String get description {
    switch (this) {
      case SignupRole.student:
        return '수업에 참여하고 과제와 공지를 확인합니다.';
      case SignupRole.teacher:
        return '수업을 운영하고 팀과 공지를 관리합니다.';
    }
  }
}
