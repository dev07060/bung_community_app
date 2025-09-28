import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/data/repositories/channel_repository_impl.dart';
import 'package:our_bung_play/domain/entities/channel_entity.dart';
import 'package:our_bung_play/domain/repositories/channel_repository.dart';
import 'package:our_bung_play/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channel_providers.g.dart';

final selectedChannelProvider = StateProvider<ChannelEntity?>((ref) => null);

// Channel Repository Provider
@riverpod
ChannelRepository channelRepository(ChannelRepositoryRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ChannelRepositoryImpl(authRepository: authRepository);
}

// User Channels Provider - 현재 사용자의 채널 목록
@riverpod
class UserChannels extends _$UserChannels {
  @override
  Future<List<ChannelEntity>> build() async {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      throw const AuthException('로그인이 필요합니다.');
    }

    try {
      final repository = ref.watch(channelRepositoryProvider);
      final channels = await repository.getUserChannels(currentUser.id);
      Logger.info('Loaded ${channels.length} channels for user ${currentUser.id}');
      return channels;
    } catch (e, stackTrace) {
      Logger.error('Failed to load user channels', e, stackTrace);
      rethrow;
    }
  }

  // 채널 목록 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  // 새 채널 추가 (로컬 상태 업데이트)
  void addChannel(ChannelEntity channel) {
    state.whenData((channels) {
      state = AsyncValue.data([channel, ...channels]);
    });
  }

  // 채널 업데이트 (로컬 상태 업데이트)
  void updateChannel(ChannelEntity updatedChannel) {
    state.whenData((channels) {
      final updatedChannels = channels.map((channel) {
        return channel.id == updatedChannel.id ? updatedChannel : channel;
      }).toList();
      state = AsyncValue.data(updatedChannels);
    });
  }

  // 채널 제거 (로컬 상태 업데이트)
  void removeChannel(String channelId) {
    state.whenData((channels) {
      final filteredChannels = channels.where((channel) => channel.id != channelId).toList();
      state = AsyncValue.data(filteredChannels);
    });
  }
}

// Individual Channel Provider - 특정 채널 정보
@riverpod
class Channel extends _$Channel {
  @override
  Future<ChannelEntity?> build(String channelId) async {
    try {
      // 먼저 사용자 채널 목록에서 찾기
      final userChannelsAsync = ref.watch(userChannelsProvider);
      return userChannelsAsync.when(
        data: (channels) {
          final channel = channels.where((c) => c.id == channelId).firstOrNull;
          if (channel != null) {
            Logger.info('Found channel $channelId in user channels');
            return channel;
          }
          Logger.info('Channel $channelId not found in user channels');
          return null;
        },
        loading: () => null,
        error: (error, stackTrace) {
          Logger.error('Error loading channel $channelId', error, stackTrace);
          return null;
        },
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to load channel $channelId', e, stackTrace);
      return null;
    }
  }

  // 채널 정보 업데이트
  void updateChannelData(ChannelEntity updatedChannel) {
    if (updatedChannel.id == channelId) {
      state = AsyncValue.data(updatedChannel);
      // 사용자 채널 목록도 업데이트
      ref.read(userChannelsProvider.notifier).updateChannel(updatedChannel);
    }
  }
}

// Channel Creation State Provider - 채널 생성 상태 관리
@riverpod
class ChannelCreation extends _$ChannelCreation {
  @override
  AsyncValue<ChannelEntity?> build() {
    return const AsyncValue.data(null);
  }

  // 채널 생성
  Future<ChannelEntity?> createChannel(String name, String description) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(channelRepositoryProvider);
      final channel = await repository.createChannel(name.trim(), description.trim());

      Logger.info('Channel created successfully: ${channel.id}');

      // 사용자 채널 목록에 추가
      ref.read(userChannelsProvider.notifier).addChannel(channel);

      state = AsyncValue.data(channel);
      return channel;
    } catch (e, stackTrace) {
      Logger.error('Failed to create channel', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  // 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Channel Join State Provider - 채널 가입 상태 관리
@riverpod
class ChannelJoin extends _$ChannelJoin {
  @override
  AsyncValue<ChannelEntity?> build() {
    return const AsyncValue.data(null);
  }

  // 초대 코드로 채널 가입
  Future<ChannelEntity?> joinByInviteCode(String inviteCode) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(channelRepositoryProvider);
      final channel = await repository.joinChannelByInviteCode(inviteCode.trim());

      if (channel != null) {
        Logger.info('Successfully joined channel: ${channel.id}');

        // 사용자 채널 목록 새로고침
        ref.read(userChannelsProvider.notifier).refresh();

        state = AsyncValue.data(channel);
        return channel;
      } else {
        throw const ValidationException('유효하지 않은 초대 코드입니다.');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to join channel', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  // 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Channel Update State Provider - 채널 업데이트 상태 관리
@riverpod
class ChannelUpdate extends _$ChannelUpdate {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  // 채널 정보 업데이트
  Future<bool> updateChannel(ChannelEntity channel) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(channelRepositoryProvider);
      await repository.updateChannel(channel);

      Logger.info('Channel updated successfully: ${channel.id}');

      // 로컬 상태 업데이트
      ref.read(channelProvider(channel.id).notifier).updateChannelData(channel);

      state = const AsyncValue.data(true);
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to update channel', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // 새 초대 코드 생성
  Future<String?> generateNewInviteCode(String channelId) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(channelRepositoryProvider);
      final newInviteCode = await repository.generateNewInviteCode(channelId);

      Logger.info('New invite code generated for channel: $channelId');

      // 채널 정보 새로고침
      ref.invalidate(channelProvider(channelId));
      ref.read(userChannelsProvider.notifier).refresh();

      state = const AsyncValue.data(true);
      return newInviteCode;
    } catch (e, stackTrace) {
      Logger.error('Failed to generate new invite code', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  // 상태 초기화
  void reset() {
    state = const AsyncValue.data(false);
  }
}

// Channel Member Management Provider - 멤버 관리 상태
@riverpod
class ChannelMemberManagement extends _$ChannelMemberManagement {
  @override
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  // 멤버 제거
  Future<bool> removeMember(String channelId, String userId) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(channelRepositoryProvider);
      await repository.removeMember(channelId, userId);

      Logger.info('Member removed successfully: $userId from $channelId');

      // 채널 정보 새로고침
      ref.invalidate(channelProvider(channelId));
      ref.read(userChannelsProvider.notifier).refresh();

      state = const AsyncValue.data(true);
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to remove member', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // 멤버 상태 업데이트
  Future<bool> updateMemberStatus(String channelId, String userId, String status) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(channelRepositoryProvider);
      await repository.updateMemberStatus(channelId, userId, status);

      Logger.info('Member status updated: $userId in $channelId to $status');

      // 채널 정보 새로고침
      ref.invalidate(channelProvider(channelId));
      ref.read(userChannelsProvider.notifier).refresh();

      state = const AsyncValue.data(true);
      return true;
    } catch (e, stackTrace) {
      Logger.error('Failed to update member status', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  // 상태 초기화
  void reset() {
    state = const AsyncValue.data(false);
  }
}

// Channel Search Provider - 채널 검색
@riverpod
class ChannelSearch extends _$ChannelSearch {
  @override
  List<ChannelEntity> build() {
    return [];
  }

  // 채널 검색
  void search(String query) {
    final userChannelsAsync = ref.read(userChannelsProvider);
    userChannelsAsync.whenData((channels) {
      if (query.isEmpty) {
        state = channels;
      } else {
        final filteredChannels = channels
            .where((channel) =>
                channel.name.toLowerCase().contains(query.toLowerCase()) ||
                channel.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
        state = filteredChannels;
      }
    });
  }

  // 검색 결과 초기화
  void clear() {
    state = [];
  }
}

// Current Channel Provider - 현재 선택된 채널 (ProviderScope용)
@riverpod
String? currentChannelId(CurrentChannelIdRef ref) {
  // ProviderScope를 통해 주입될 값
  return null;
}

// Current Channel Entity Provider - 현재 선택된 채널 엔티티
@riverpod
Future<ChannelEntity?> currentChannel(CurrentChannelRef ref) async {
  final channelId = ref.watch(currentChannelIdProvider);
  if (channelId == null) return null;

  return ref.watch(channelProvider(channelId).future);
}

// Channel Argument Providers - ProviderScope를 통한 인자 전달
class ChannelArgumentProviders {
  /// 채널 ID를 ProviderScope에 주입하기 위한 오버라이드 생성
  static Override channelIdOverride(String channelId) {
    return currentChannelIdProvider.overrideWith((ref) => channelId);
  }

  /// 채널 생성 페이지용 오버라이드들
  static List<Override> channelCreationOverrides() {
    return [
      // 채널 생성 상태 초기화
      channelCreationProvider.overrideWith(() => ChannelCreation()),
    ];
  }

  /// 채널 상세 페이지용 오버라이드들
  static List<Override> channelDetailOverrides(String channelId) {
    return [
      channelIdOverride(channelId),
      // 채널 업데이트 상태 초기화
      channelUpdateProvider.overrideWith(() => ChannelUpdate()),
      // 멤버 관리 상태 초기화
      channelMemberManagementProvider.overrideWith(() => ChannelMemberManagement()),
    ];
  }

  /// 채널 가입 페이지용 오버라이드들
  static List<Override> channelJoinOverrides() {
    return [
      // 채널 가입 상태 초기화
      channelJoinProvider.overrideWith(() => ChannelJoin()),
    ];
  }

  /// 채널 관리 페이지용 오버라이드들
  static List<Override> channelManagementOverrides(String channelId) {
    return [
      channelIdOverride(channelId),
      // 채널 업데이트 상태 초기화
      channelUpdateProvider.overrideWith(() => ChannelUpdate()),
      // 멤버 관리 상태 초기화
      channelMemberManagementProvider.overrideWith(() => ChannelMemberManagement()),
    ];
  }
}
