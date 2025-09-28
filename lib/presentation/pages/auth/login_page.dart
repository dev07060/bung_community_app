import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/core/constants/app_constants.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/mixins/auth_event_mixin.dart';
import 'package:our_bung_play/presentation/mixins/auth_state_mixin.dart';

/// 로그인 페이지
class LoginPage extends BasePage with AuthStateMixin, AuthEventMixin {
  const LoginPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final isLoading = isAuthLoading(ref);
    final errorMessage = getAuthError(ref);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 앱 로고 및 제목
          _buildHeader(context),

          SizedBox(height: 48.h),

          // 에러 메시지 표시
          if (errorMessage != null) ...[
            _buildErrorMessage(context, errorMessage),
            SizedBox(height: 24.h),
          ],

          // 로그인 버튼들
          _buildLoginButtons(context, ref, isLoading),

          SizedBox(height: 32.h),

          // 서비스 설명
          _buildServiceDescription(context),
        ],
      ),
    );
  }

  @override
  Color? get screenBackgroundColor => Colors.white;

  @override
  bool get wrapWithSafeArea => true;

  Widget _buildHeader(BuildContext context) {
    return Column(
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

        SizedBox(height: 24.h),

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
      ],
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 20.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButtons(BuildContext context, WidgetRef ref, bool isLoading) {
    return Column(
      children: [
        // Google 로그인 버튼
        _buildGoogleLoginButton(context, ref, isLoading),

        SizedBox(height: 16.h),

        // Apple 로그인 버튼 (iOS에서만 표시)
        if (Theme.of(context).platform == TargetPlatform.iOS) ...[
          _buildAppleLoginButton(context, ref, isLoading),
          SizedBox(height: 16.h),
        ],

        // 로딩 인디케이터
        if (isLoading) ...[
          SizedBox(height: 24.h),
          const CircularProgressIndicator.adaptive(),
          SizedBox(height: 8.h),
          Text(
            '로그인 중...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGoogleLoginButton(BuildContext context, WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => onGoogleSignInTapped(ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google 아이콘 (실제로는 Google 로고 이미지를 사용해야 함)
            Container(
              width: 24.w,
              height: 24.w,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.g_mobiledata,
                color: Colors.white,
                size: 16.w,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Google로 시작하기',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleLoginButton(BuildContext context, WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => onAppleSignInTapped(ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apple,
              size: 24.w,
            ),
            SizedBox(width: 12.w),
            Text(
              'Apple로 시작하기',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDescription(BuildContext context) {
    return Column(
      children: [
        Text(
          '기존 커뮤니티를 더 효율적으로',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        _buildFeatureItem(
          context,
          Icons.event,
          '벙 관리',
          '모임 일정을 쉽게 만들고 참여하세요',
        ),
        SizedBox(height: 12.h),
        _buildFeatureItem(
          context,
          Icons.payment,
          '간편 정산',
          '모임 비용을 투명하게 정산하세요',
        ),
        SizedBox(height: 12.h),
        _buildFeatureItem(
          context,
          Icons.chat,
          'AI 도우미',
          '모임 규칙을 쉽게 확인하세요',
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            icon,
            size: 20.w,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
