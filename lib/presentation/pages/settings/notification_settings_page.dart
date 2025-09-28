import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/providers/notification_providers.dart';
import 'package:our_bung_play/shared/components/f_app_bar.dart';
import 'package:our_bung_play/shared/components/f_switch.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

class NotificationSettingsPage extends BasePage {
  const NotificationSettingsPage({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return FAppBar.back(context, title: '알림 설정');
  }

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationSettingsProvider);

    return notificationSettings.when(
      data: (settings) => _buildSettingsContent(context, ref, settings),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16.h),
            const Text('설정을 불러올 수 없습니다'),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () => ref.refresh(notificationSettingsProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, bool> settings,
  ) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      children: [
        _buildSectionHeader(context, '알림 권한'),
        _buildPermissionsSection(context, ref),
        _buildSectionHeader(context, '알림 유형'),
        _buildNotificationTypesSection(context, ref, settings),
      ],
    );
  }

  Widget _buildPermissionsSection(BuildContext context, WidgetRef ref) {
    final notificationPermissions = ref.watch(notificationPermissionsProvider);
    return notificationPermissions.when(
      data: (isEnabled) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              isEnabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
              color: isEnabled ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isEnabled ? '알림이 허용되었습니다' : '알림이 차단되었습니다',
                style: FTextStyles.body1_16.r.copyWith(color: FColors.of(context).labelNormal),
              ),
            ),
            if (!isEnabled)
              ElevatedButton(
                onPressed: () => _requestPermissions(ref),
                child: const Text('허용하기'),
              ),
          ],
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
            SizedBox(width: 16),
            Text('권한 확인 중...'),
          ],
        ),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            SizedBox(width: 16),
            Text('권한 확인 실패'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypesSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, bool> settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNotificationGroup(
          context,
          ref,
          '벙 관련 알림',
          [
            _NotificationSetting(
              key: 'eventCreated',
              title: '새 벙 생성',
              subtitle: '새로운 벙이 생성되었을 때',
              value: settings['eventCreated'] ?? true,
            ),
            _NotificationSetting(
              key: 'eventUpdated',
              title: '벙 정보 변경',
              subtitle: '참여한 벙의 정보가 변경되었을 때',
              value: settings['eventUpdated'] ?? true,
            ),
            _NotificationSetting(
              key: 'eventJoined',
              title: '벙 참여 알림',
              subtitle: '내가 만든 벙에 누군가 참여했을 때',
              value: settings['eventJoined'] ?? true,
            ),
            _NotificationSetting(
              key: 'eventCancelled',
              title: '벙 취소 알림',
              subtitle: '참여한 벙이 취소되었을 때',
              value: settings['eventCancelled'] ?? true,
            ),
          ],
        ),
        _buildDivider(),
        _buildNotificationGroup(
          context,
          ref,
          '정산 관련 알림',
          [
            _NotificationSetting(
              key: 'settlementCreated',
              title: '정산 생성',
              subtitle: '새로운 정산이 생성되었을 때',
              value: settings['settlementCreated'] ?? true,
            ),
            _NotificationSetting(
              key: 'paymentReceived',
              title: '입금 완료',
              subtitle: '정산 입금이 완료되었을 때',
              value: settings['paymentReceived'] ?? true,
            ),
          ],
        ),
        _buildDivider(),
        _buildNotificationGroup(
          context,
          ref,
          '커뮤니티 알림',
          [
            _NotificationSetting(
              key: 'announcement',
              title: '공지사항',
              subtitle: '관리자가 공지사항을 발송했을 때',
              value: settings['announcement'] ?? true,
            ),
            _NotificationSetting(
              key: 'memberJoined',
              title: '새 멤버 가입',
              subtitle: '새로운 멤버가 가입했을 때',
              value: settings['memberJoined'] ?? false,
            ),
            _NotificationSetting(
              key: 'memberLeft',
              title: '멤버 탈퇴',
              subtitle: '멤버가 탈퇴했을 때',
              value: settings['memberLeft'] ?? false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationGroup(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<_NotificationSetting> settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title,
            style: FTextStyles.bodyL.m.copyWith(color: FColors.of(context).labelAlternative),
          ),
        ),
        ...settings.map((setting) => _buildSwitchTile(context, ref, setting)),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    WidgetRef ref,
    _NotificationSetting setting,
  ) {
    return InkWell(
      onTap: () => _updateNotificationSetting(ref, setting.key, !setting.value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    setting.title,
                    style: FTextStyles.body1_16.r.copyWith(color: FColors.of(context).labelNormal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    setting.subtitle,
                    style: FTextStyles.body3_13.r.copyWith(color: FColors.of(context).labelAlternative),
                  ),
                ],
              ),
            ),
            FSwitch.normal(
              context,
              active: setting.value,
              onTap: (value) => _updateNotificationSetting(ref, setting.key, value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: FTextStyles.title2_20.b.copyWith(color: FColors.of(context).labelNormal),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Divider(height: 1, thickness: 1),
    );
  }

  Future<void> _requestPermissions(WidgetRef ref) async {
    try {
      final granted = await ref.read(notificationPermissionsProvider.notifier).request();

      if (!granted) {
        _showPermissionDialog();
      }
    } catch (e) {
      Logger.error('Failed to request notification permissions: $e');
    }
  }

  Future<void> _updateNotificationSetting(
    WidgetRef ref,
    String key,
    bool value,
  ) async {
    try {
      await ref.read(notificationSettingsProvider.notifier).updateSetting(key, value);
    } catch (e) {
      Logger.error('Failed to update notification setting: $e');
    }
  }

  void _showPermissionDialog() {
    // This would show a dialog guiding user to app settings
  }
}

class _NotificationSetting {
  final String key;
  final String title;
  final String subtitle;
  final bool value;

  const _NotificationSetting({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.value,
  });
}
