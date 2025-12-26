import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/constants/app_constants.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/presentation/mixins/auth_state_mixin.dart';
import 'package:our_bung_play/presentation/pages/auth/login_page.dart';
import 'package:our_bung_play/presentation/pages/auth/profile_setup_page.dart';
import 'package:our_bung_play/presentation/pages/channel/no_channel_page.dart';
import 'package:our_bung_play/presentation/pages/main/main_navigation_page.dart';
import 'package:our_bung_play/presentation/providers/channel_providers.dart';
import 'package:our_bung_play/shared/components/f_dialog.dart';

/// 인증 상태에 따라 적절한 화면을 보여주는 래퍼
class AuthWrapper extends ConsumerWidget with AuthStateMixin {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = getAuthState(ref);

    return authState.when(
      // 로딩 중일 때 스플래시 화면 표시
      loading: () {
        Logger.info('AuthWrapper - authState is loading...');
        return const _SplashScreen();
      },

      // 에러 발생 시 로그인 화면으로 이동
      error: (error, stackTrace) {
        Logger.error('AuthWrapper - authState error', error, stackTrace);
        return const LoginPage();
      },

      // 데이터가 있을 때 사용자 상태에 따라 분기
      data: (user) {
        if (user == null) {
          // 로그인되지 않은 경우 로그인 화면
          return const LoginPage();
        }

        // 디버그 로그
        Logger.info('AuthWrapper - user: ${user.id}');
        Logger.info('AuthWrapper - nickname: ${user.nickname}');
        Logger.info('AuthWrapper - hasNickname: ${user.hasNickname}');

        if (!user.isActive) {
          // 사용자가 비활성 상태인 경우 제한 화면
          return const _UserRestrictedScreen();
        }

        // 닉네임 미설정 시 프로필 설정 화면
        if (!user.hasNickname) {
          Logger.info('AuthWrapper - Redirecting to ProfileSetupPage');
          return const ProfileSetupPage();
        }

        // 채널 정보 확인
        final userChannels = ref.watch(userChannelsProvider);
        return userChannels.when(
          loading: () => const _SplashScreen(),
          error: (error, stack) => const LoginPage(), // Or a specific error screen
          data: (channels) {
            if (channels.isEmpty) {
              return const NoChannelPage();
            }
            return const MainNavigationPage();
          },
        );
      },
    );
  }
}



/// 스플래시 화면
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 아이콘
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: Icon(
                Icons.group,
                size: 60.w,
                color: Theme.of(context).primaryColor,
              ),
            ),

            SizedBox(height: 32.h),

            // 앱 이름
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),

            SizedBox(height: 8.h),

            // 앱 설명
            Text(
              '커뮤니티 관리의 새로운 시작',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 48.h),

            // 로딩 인디케이터
            const CircularProgressIndicator.adaptive(),

            SizedBox(height: 16.h),

            Text(
              '로딩 중...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 사용자 제한 화면
class _UserRestrictedScreen extends StatelessWidget {
  const _UserRestrictedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 제한 아이콘
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60.r),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 60.w,
                  color: Colors.orange,
                ),
              ),

              SizedBox(height: 32.h),

              // 제목
              Text(
                '계정 이용이 제한되었습니다',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              // 설명
              Text(
                '현재 계정의 이용이 제한된 상태입니다.\n자세한 내용은 관리자에게 문의해 주세요.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 48.h),

              // 문의하기 버튼
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () => _showContactDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '관리자에게 문의하기',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // 로그아웃 버튼
              TextButton(
                onPressed: () => _showLogoutDialog(context),
                child: Text(
                  '다른 계정으로 로그인',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    FDialog.oneButton(
      title: '관리자 문의',
      description: '관리자 문의 기능은 준비 중입니다.\n이메일로 문의해 주세요.\n\nsupport@ourbungplay.com',
      confirmText: '확인',
      onConfirm: () {},
    ).show(context);
  }

  void _showLogoutDialog(BuildContext context) {
    FDialog.twoButton(
      context,
      title: '로그아웃',
      description: '현재 계정에서 로그아웃하고\n다른 계정으로 로그인하시겠습니까?',
      confirmText: '로그아웃',
      onConfirm: () {
        // TODO: 로그아웃 로직 구현
        // ref.read(authStateProvider.notifier).signOut();
      },
    ).show(context);
  }
}
