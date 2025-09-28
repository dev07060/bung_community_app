import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/shared/components/f_app_bar.dart';
import 'package:our_bung_play/shared/components/f_search_bar.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

import '../../../core/enums/app_enums.dart';
import '../../../domain/entities/user_entity.dart';
import '../../base/base_page.dart';
import 'mixins/member_management_event_mixin.dart';
import 'mixins/member_management_state_mixin.dart';

/// 멤버 관리 페이지 - 관리자가 채널 멤버를 관리하는 화면
class MemberManagementPage extends BasePage with MemberManagementStateMixin, MemberManagementEventMixin {
  const MemberManagementPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return const _MemberManagementContent();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return FAppBar.back(context, title: '멤버 관리');
  }
}

class _MemberManagementContent extends HookConsumerWidget with MemberManagementStateMixin, MemberManagementEventMixin {
  const _MemberManagementContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState<String>('');

    final members = getChannelMembers(ref);
    final filteredMembers = getFilteredMembers(ref, searchQuery.value);
    final isLoading = isMemberListLoading(ref);
    final errorMessage = getMemberListError(ref);

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    useEffect(() {
      if (errorMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
      return null;
    }, [errorMessage]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FSearchBar.normal(
            controller: searchController,
            hintText: '멤버 이름 또는 이메일로 검색',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildStatCard(context, '전체 멤버', '${members.length}명', Icons.people_outline, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard(context, '활성 멤버', '${members.where((m) => m.status == UserStatus.active).length}명', Icons.check_circle_outline, Colors.green),
              const SizedBox(width: 16),
              _buildStatCard(context, '제한 멤버', '${members.where((m) => m.status == UserStatus.restricted).length}명', Icons.person_off_outlined, Colors.orange),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : filteredMembers.isEmpty
                  ? _buildEmptyState(context, searchQuery.value.isNotEmpty)
                  : ListView.separated(
                      itemCount: filteredMembers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return _buildMemberTile(context, ref, member);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: FTextStyles.title2_20.b.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: FTextStyles.bodyS.r.copyWith(color: FColors.of(context).labelAlternative),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? '검색 결과가 없습니다' : '멤버가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          if (isSearching) ...[
            const SizedBox(height: 8),
            Text(
              '다른 검색어를 시도해보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, WidgetRef ref, UserEntity member) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[300],
        backgroundImage: member.photoURL != null ? NetworkImage(member.photoURL!) : null,
        child: member.photoURL == null
            ? Text(member.displayName.isNotEmpty ? member.displayName[0].toUpperCase() : 'U')
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              member.displayName,
              style: FTextStyles.body1_16.m.copyWith(color: FColors.of(context).labelNormal),
            ),
          ),
          _buildRoleBadge(member.role),
          const SizedBox(width: 8),
          _buildStatusBadge(member.status),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(member.email, style: FTextStyles.bodyS.r.copyWith(color: FColors.of(context).labelAlternative)),
          const SizedBox(height: 4),
          Text(
            '가입일: ${_formatDate(member.createdAt)}',
            style: FTextStyles.bodyS.r.copyWith(color: FColors.of(context).labelAssistive),
          ),
        ],
      ),
      trailing: member.role != UserRole.admin
          ? PopupMenuButton<String>(
              onSelected: (value) => _onMemberActionSelected(context, ref, member, value),
              itemBuilder: (context) => [
                if (member.status == UserStatus.active)
                  const PopupMenuItem(
                    value: 'restrict',
                    child: Row(children: [Icon(Icons.person_off, color: Colors.orange), SizedBox(width: 8), Text('활동 제한')]),
                  ),
                if (member.status == UserStatus.restricted)
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('제한 해제')]),
                  ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(children: [Icon(Icons.person_remove, color: Colors.red), SizedBox(width: 8), Text('강제 탈퇴')]),
                ),
              ],
            )
          : null,
      isThreeLine: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final color = role == UserRole.admin ? Colors.purple : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        role.displayName,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusBadge(UserStatus status) {
    Color color;
    switch (status) {
      case UserStatus.active:
        color = Colors.green;
        break;
      case UserStatus.restricted:
        color = Colors.orange;
        break;
      case UserStatus.banned:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _onMemberActionSelected(
    BuildContext context,
    WidgetRef ref,
    UserEntity member,
    String action,
  ) {
    switch (action) {
      case 'restrict':
        onRestrictMember(context, ref, member);
        break;
      case 'activate':
        onActivateMember(context, ref, member);
        break;
      case 'remove':
        onRemoveMember(context, ref, member);
        break;
    }
  }
}
