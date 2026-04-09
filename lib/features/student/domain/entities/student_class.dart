enum AssignmentStatus {
  pending,
  submitted,
  overdue;

  String get label {
    switch (this) {
      case AssignmentStatus.pending:
        return '진행 중';
      case AssignmentStatus.submitted:
        return '제출 완료';
      case AssignmentStatus.overdue:
        return '마감 지남';
    }
  }
}

class StudentAssignment {
  const StudentAssignment({
    required this.id,
    required this.title,
    required this.dueDateLabel,
    required this.status,
  });

  final String id;
  final String title;
  final String dueDateLabel;
  final AssignmentStatus status;
}

class StudentAnnouncement {
  const StudentAnnouncement({
    required this.id,
    required this.title,
    required this.summary,
    required this.dateLabel,
  });

  final String id;
  final String title;
  final String summary;
  final String dateLabel;
}

class StudentChatMessage {
  const StudentChatMessage({
    required this.id,
    required this.author,
    required this.message,
    required this.sentAt,
    required this.isMine,
  });

  final String id;
  final String author;
  final String message;
  final String sentAt;
  final bool isMine;

  StudentChatMessage copyWith({
    String? id,
    String? author,
    String? message,
    String? sentAt,
    bool? isMine,
  }) {
    return StudentChatMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      isMine: isMine ?? this.isMine,
    );
  }
}

class StudentGroup {
  const StudentGroup({
    required this.name,
    required this.members,
    required this.classCode,
  });

  final String name;
  final List<String> members;
  final String classCode;
}

class StudentClass {
  const StudentClass({
    required this.id,
    required this.title,
    required this.description,
    required this.classCode,
    required this.groupAssigned,
    required this.groupName,
    required this.assignments,
    required this.announcements,
    required this.chatMessages,
    required this.group,
  });

  final String id;
  final String title;
  final String description;
  final String classCode;
  final bool groupAssigned;
  final String? groupName;
  final List<StudentAssignment> assignments;
  final List<StudentAnnouncement> announcements;
  final List<StudentChatMessage> chatMessages;
  final StudentGroup? group;

  StudentClass copyWith({
    String? id,
    String? title,
    String? description,
    String? classCode,
    bool? groupAssigned,
    String? groupName,
    List<StudentAssignment>? assignments,
    List<StudentAnnouncement>? announcements,
    List<StudentChatMessage>? chatMessages,
    StudentGroup? group,
  }) {
    return StudentClass(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      classCode: classCode ?? this.classCode,
      groupAssigned: groupAssigned ?? this.groupAssigned,
      groupName: groupName ?? this.groupName,
      assignments: assignments ?? this.assignments,
      announcements: announcements ?? this.announcements,
      chatMessages: chatMessages ?? this.chatMessages,
      group: group ?? this.group,
    );
  }
}
