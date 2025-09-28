import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/settings/mixins/settings_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/settings/mixins/settings_state_mixin.dart';
import 'package:our_bung_play/shared/components/f_app_bar.dart';
import 'package:our_bung_play/shared/components/f_switch.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

/// 설정 페이지 - 사용자 설정 및 관리자 기능을 제공
class SettingsPage extends BasePage with SettingsStateMixin, SettingsEventMixin {
  const SettingsPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildUserProfileSection(context, ref),
          _buildAdminSection(context, ref),
          _buildGeneralSettingsSection(context, ref),
          _buildNotificationSettingsSection(context, ref),
          _buildAccountSection(context, ref),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return FAppBar.back(
      context,
      title: '설정',
    );
  }

  Widget _buildUserProfileSection(BuildContext context, WidgetRef ref) {
    final userProfile = getUserProfile(ref);
    final isLoadingState = isLoading(ref);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.grey[300],
            backgroundImage: userProfile['photoURL'] != null ? NetworkImage(userProfile['photoURL']!) : null,
            child: userProfile['photoURL'] == null ? const Icon(Icons.person, size: 36) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProfile['displayName'] ?? '사용자',
                  style: FTextStyles.title2_20.b.copyWith(color: FColors.of(context).labelNormal),
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile['email'] ?? 'user@example.com',
                  style: FTextStyles.bodyL.r.copyWith(color: FColors.of(context).labelAlternative),
                ),
              ],
            ),
          ),
          IconButton(
            icon: isLoadingState
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Icon(Icons.edit_outlined),
            onPressed: isLoadingState ? null : () => onEditProfile(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection(BuildContext context, WidgetRef ref) {
    final isAdminUser = isUserAdmin(ref);
    if (!isAdminUser) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '모임 관리'),
        _buildNavigationTile(
          context,
          icon: Icons.people_outline,
          title: '멤버 관리',
          subtitle: '멤버 목록 조회, 검색, 관리',
          onTap: () => onMemberManagement(context, ref),
        ),
        _buildDivider(),
        _buildNavigationTile(
          context,
          icon: Icons.announcement_outlined,
          title: '공지사항 발송',
          subtitle: '모든 멤버에게 공지사항 전송',
          onTap: () => onAnnouncement(context, ref),
        ),
        _buildDivider(),
        _buildNavigationTile(
          context,
          icon: Icons.rule_outlined,
          title: '회칙 관리',
          subtitle: '모임 회칙 작성 및 수정',
          onTap: () => onRuleManagement(context, ref),
        ),
        _buildDivider(),
        _buildNavigationTile(
          context,
          icon: Icons.info_outline,
          title: '모임 정보 수정',
          subtitle: '모임 이름, 설명 변경',
          onTap: () => onChannelInfo(context, ref),
        ),
        _buildDivider(),
        _buildNavigationTile(
          context,
          icon: Icons.link_outlined,
          title: '초대 링크 재생성',
          subtitle: '새로운 초대 링크 생성',
          onTap: () => onInviteLink(context, ref),
        ),
      ],
    );
  }

  Widget _buildGeneralSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '일반 설정'),
        _buildNavigationTile(
          context,
          icon: Icons.chat_bubble_outline,
          title: '회칙 문의',
          subtitle: 'AI 챗봇을 통한 회칙 문의',
          onTap: () => onChatbot(context, ref),
        ),
        _buildDivider(),
        _buildNavigationTile(
          context,
          icon: Icons.language_outlined,
          title: '언어 설정',
          subtitle: '한국어',
          onTap: () => _showNotImplementedSnackBar(context, '언어 설정'),
        ),
      ],
    );
  }

  Widget _buildNotificationSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '알림 설정'),
        _buildSwitchTile(
          context,
          title: '푸시 알림',
          subtitle: '새 벙, 공지사항 등의 알림 수신',
          value: getNotificationSetting(ref, 'push_notifications'),
          onChanged: (value) => onNotificationToggle(context, ref, 'push_notifications', value),
        ),
        _buildDivider(),
        _buildSwitchTile(
          context,
          title: '벙 알림',
          subtitle: '벙 생성, 수정, 취소 알림',
          value: getNotificationSetting(ref, 'event_notifications'),
          onChanged: (value) => onNotificationToggle(context, ref, 'event_notifications', value),
        ),
        _buildDivider(),
        _buildSwitchTile(
          context,
          title: '정산 알림',
          subtitle: '정산 관련 알림',
          value: getNotificationSetting(ref, 'settlement_notifications'),
          onChanged: (value) => onNotificationToggle(context, ref, 'settlement_notifications', value),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '계정 관리'),
        _buildNavigationTile(
          context,
          icon: Icons.logout,
          title: '로그아웃',
          onTap: () => onLogout(context, ref),
          color: Colors.orange,
        ),
        _buildDivider(),
        _buildNavigationTile(
          context,
          icon: Icons.delete_forever_outlined,
          title: '회원 탈퇴',
          onTap: () => onDeleteAccount(context, ref),
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: FTextStyles.title2_20.b.copyWith(color: FColors.of(context).labelNormal),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tileColor = color ?? FColors.of(context).labelNormal;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: tileColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FTextStyles.body1_16.r.copyWith(color: tileColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: FTextStyles.body3_13.r.copyWith(color: FColors.of(context).labelAlternative),
                    ),
                  ],
                ],
              ),
            ),
            if (color == null) Icon(Icons.arrow_forward_ios, size: 16, color: FColors.current.labelAlternative),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FTextStyles.body1_16.r.copyWith(color: FColors.of(context).labelNormal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: FTextStyles.body3_13.r.copyWith(color: FColors.of(context).labelAlternative),
                  ),
                ],
              ),
            ),
            FSwitch.normal(
              context,
              active: value,
              onTap: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, thickness: 1),
    );
  }

  void _showNotImplementedSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature (추후 구현)')),
    );
  }
}
