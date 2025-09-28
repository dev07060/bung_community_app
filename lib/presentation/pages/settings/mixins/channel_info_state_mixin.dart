import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/channel_entity.dart';

/// 채널 정보 수정 화면 상태 관리 Mixin
mixin ChannelInfoStateMixin {
  /// 현재 채널 정보 가져오기
  ChannelEntity? getCurrentChannelInfo(WidgetRef ref) {
    // TODO: 실제 채널 정보 Provider에서 가져오기
    return _getMockChannelInfo();
  }

  /// 채널 정보 로딩 상태 확인
  bool isChannelInfoLoading(WidgetRef ref) {
    // TODO: 실제 로딩 상태 확인
    return false;
  }

  /// 채널 정보 업데이트 중 상태 확인
  bool isChannelInfoUpdating(WidgetRef ref) {
    // TODO: 실제 업데이트 상태 확인
    return false;
  }

  /// 채널 정보 업데이트 에러 메시지 가져오기
  String? getChannelInfoUpdateError(WidgetRef ref) {
    // TODO: 실제 에러 상태 확인
    return null;
  }

  /// Mock 채널 데이터 생성 (실제 구현에서는 제거)
  ChannelEntity _getMockChannelInfo() {
    return ChannelEntity(
      id: 'channel_1',
      name: '우리 동네 축구 모임',
      description: '매주 토요일 오후에 축구를 즐기는 모임입니다. 초보자도 환영합니다!',
      adminId: 'admin_1',
      inviteCode: 'ABC123',
      members: [
        ChannelMember(
          userId: 'admin_1',
          role: UserRole.admin,
          status: UserStatus.active,
          joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        ChannelMember(
          userId: 'user_1',
          role: UserRole.member,
          status: UserStatus.active,
          joinedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        ChannelMember(
          userId: 'user_2',
          role: UserRole.member,
          status: UserStatus.active,
          joinedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        ChannelMember(
          userId: 'user_3',
          role: UserRole.member,
          status: UserStatus.restricted,
          joinedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        ChannelMember(
          userId: 'user_4',
          role: UserRole.member,
          status: UserStatus.active,
          joinedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
      status: ChannelStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    );
  }
}
