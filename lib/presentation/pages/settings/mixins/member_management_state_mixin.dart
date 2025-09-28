import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/user_entity.dart';

/// 멤버 관리 화면 상태 관리 Mixin
mixin MemberManagementStateMixin {
  /// 채널 멤버 목록 가져오기
  List<UserEntity> getChannelMembers(WidgetRef ref) {
    // TODO: 실제 채널 멤버 Provider에서 가져오기
    return _getMockMembers();
  }

  /// 필터링된 멤버 목록 가져오기
  List<UserEntity> getFilteredMembers(WidgetRef ref, String searchQuery) {
    final members = getChannelMembers(ref);

    if (searchQuery.isEmpty) {
      return members;
    }

    return members.where((member) {
      final query = searchQuery.toLowerCase();
      return member.displayName.toLowerCase().contains(query) || member.email.toLowerCase().contains(query);
    }).toList();
  }

  /// 멤버 목록 로딩 상태 확인
  bool isMemberListLoading(WidgetRef ref) {
    // TODO: 실제 로딩 상태 확인
    return false;
  }

  /// 멤버 목록 에러 메시지 가져오기
  String? getMemberListError(WidgetRef ref) {
    // TODO: 실제 에러 상태 확인
    return null;
  }

  /// 멤버 액션 로딩 상태 확인
  bool isMemberActionLoading(WidgetRef ref) {
    // TODO: 실제 액션 로딩 상태 확인
    return false;
  }

  /// Mock 데이터 생성 (실제 구현에서는 제거)
  List<UserEntity> _getMockMembers() {
    return [
      UserEntity(
        uuid: '1',
        id: '1',
        email: 'admin@example.com',
        displayName: '관리자',
        photoURL: null,
        role: UserRole.admin,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
      ),
      UserEntity(
        uuid: '2',
        id: '2',
        email: 'user1@example.com',
        displayName: '김철수',
        photoURL: null,
        role: UserRole.member,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      UserEntity(
        uuid: '3',
        id: '3',
        email: 'user2@example.com',
        displayName: '이영희',
        photoURL: null,
        role: UserRole.member,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UserEntity(
        uuid: '4',
        id: '4',
        email: 'user3@example.com',
        displayName: '박민수',
        photoURL: null,
        role: UserRole.member,
        status: UserStatus.restricted,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastLoginAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      UserEntity(
        uuid: '5',
        id: '5',
        email: 'user4@example.com',
        displayName: '최지은',
        photoURL: null,
        role: UserRole.member,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastLoginAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
