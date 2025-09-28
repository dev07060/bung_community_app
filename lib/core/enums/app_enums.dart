// User related enums
enum UserRole {
  master, // 모임장 (채널 생성자, 최고 권한)
  admin, // 관리자 (운영진, 관리 권한)
  opMember, // 운영진 멤버 (일부 관리 권한)
  member // 일반 멤버
}

enum UserStatus {
  active, // 활성
  restricted, // 활동 제한
  banned // 강제 탈퇴
}

// Event related enums
enum EventStatus {
  scheduled, // 예정됨
  closed, // 마감됨
  ongoing, // 진행중
  settlement, // 정산중
  completed, // 완료됨
  cancelled // 취소됨
}

extension EventStatusExtension on EventStatus {
  String get displayName {
    switch (this) {
      case EventStatus.scheduled:
        return '예정됨';
      case EventStatus.closed:
        return '마감됨';
      case EventStatus.ongoing:
        return '진행중';
      case EventStatus.settlement:
        return '정산중';
      case EventStatus.completed:
        return '완료됨';
      case EventStatus.cancelled:
        return '취소됨';
    }
  }
}

enum ParticipationStatus {
  participating, // 참여중
  waiting, // 대기중
  cancelled // 참여취소
}

// Settlement related enums
enum SettlementStatus {
  pending, // 정산 대기
  completed // 정산 완료
}

enum PaymentStatus {
  pending, // 입금 대기
  completed, // 입금 완료
  overdue // 연체
}

// Channel related enums
enum ChannelStatus {
  active, // 활성
  inactive, // 비활성
  archived // 보관됨
}

// Notification related enums
enum NotificationType {
  eventCreated, // 새 벙 생성
  eventUpdated, // 벙 정보 변경
  eventCancelled, // 벙 취소
  eventJoined, // 벙 참여
  eventLeft, // 벙 참여 취소
  settlementCreated, // 정산 생성
  paymentReceived, // 입금 완료
  announcement, // 공지사항
  memberJoined, // 새 멤버 가입
  memberLeft // 멤버 탈퇴
}

enum NotificationStatus {
  pending, // 대기중
  sent, // 전송됨
  delivered, // 전달됨
  read, // 읽음
  failed // 실패
}

// Chat related enums
enum MessageStatus {
  sent, // 전송됨
  delivered, // 전달됨
  failed // 실패
}

enum MessageType {
  question, // 질문
  answer // 답변
}

// Error related enums
enum ErrorType {
  auth, // 인증 에러
  network, // 네트워크 에러
  validation, // 유효성 검사 에러
  permission, // 권한 에러
  notFound, // 데이터 없음
  serverError, // 서버 에러
  security // 보안 에러
}

// Extensions for Korean display names
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.master:
        return '모임장';
      case UserRole.admin:
        return '관리자';
      case UserRole.opMember:
        return '운영진';
      case UserRole.member:
        return '멤버';
    }
  }

  // 권한 레벨 (숫자가 높을수록 높은 권한)
  int get level {
    switch (this) {
      case UserRole.master:
        return 4;
      case UserRole.admin:
        return 3;
      case UserRole.opMember:
        return 2;
      case UserRole.member:
        return 1;
    }
  }

  // 권한 확인 메서드들
  bool get canManageMembers => level >= 3; // admin 이상
  bool get canManageEvents => level >= 2; // opMember 이상
  bool get canCreateEvents => level >= 1; // member 이상
  bool get canDeleteChannel => level >= 4; // master만
  bool get canChangeRoles => level >= 4; // master만
  bool get canSendAnnouncements => level >= 3; // admin 이상
}

extension UserStatusExtension on UserStatus {
  String get displayName {
    switch (this) {
      case UserStatus.active:
        return '활성';
      case UserStatus.restricted:
        return '활동 제한';
      case UserStatus.banned:
        return '강제 탈퇴';
    }
  }
}

extension SettlementStatusExtension on SettlementStatus {
  String get displayName {
    switch (this) {
      case SettlementStatus.pending:
        return '정산 대기';
      case SettlementStatus.completed:
        return '정산 완료';
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return '입금 대기';
      case PaymentStatus.completed:
        return '입금 완료';
      case PaymentStatus.overdue:
        return '연체';
    }
  }
}
