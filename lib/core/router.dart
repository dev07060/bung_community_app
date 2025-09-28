import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/pages/auth/auth_wrapper.dart';
import 'package:our_bung_play/presentation/pages/auth/login_page.dart';
import 'package:our_bung_play/presentation/pages/channel/create_channel_page.dart';
import 'package:our_bung_play/presentation/pages/channel/no_channel_page.dart';
import 'package:our_bung_play/presentation/pages/event/create_event_page.dart';
import 'package:our_bung_play/presentation/pages/event_detail/event_detail_page.dart';
import 'package:our_bung_play/presentation/pages/event_list/event_list_page.dart';
import 'package:our_bung_play/presentation/pages/home/home_page.dart';
import 'package:our_bung_play/presentation/pages/main/main_navigation_page.dart';
import 'package:our_bung_play/presentation/pages/settings/announcement_page.dart';
import 'package:our_bung_play/presentation/pages/settings/channel_info_page.dart';
import 'package:our_bung_play/presentation/pages/settings/member_management_page.dart';
import 'package:our_bung_play/presentation/pages/settings/notification_settings_page.dart';
import 'package:our_bung_play/presentation/pages/settings/rule_management_page.dart';
import 'package:our_bung_play/presentation/pages/settings/settings_page.dart';
import 'package:our_bung_play/presentation/providers/event_providers.dart';

enum AppRoutePath {
  authWrapper,
  login,
  mainNavigation,
  home,
  eventList,
  eventDetail,
  createEvent,
  createChannel,
  noChannel,
  settings,
  announcement,
  channelInfo,
  memberManagement,
  notificationSettings,
  ruleManagement,
  createSettlement,
  settlementDetail,
  settlementManagement;

  String get relativePath {
    switch (this) {
      case authWrapper:
        return '/';
      case login:
        return '/login';
      case mainNavigation:
        return '/main';
      case home:
        return 'home'; // Nested under mainNavigation
      case eventList:
        return 'event-list'; // Nested under mainNavigation
      case eventDetail:
        return '/event-detail/:eventId';
      case createEvent:
        return '/create-event';
      case createChannel:
        return '/create-channel';
      case noChannel:
        return '/no-channel';
      case settings:
        return 'settings'; // Nested under mainNavigation
      case announcement:
        return '/settings/announcement';
      case channelInfo:
        return '/settings/channel-info';
      case memberManagement:
        return '/settings/member-management';
      case notificationSettings:
        return '/settings/notification-settings';
      case ruleManagement:
        return '/settings/rule-management';
      case createSettlement:
        return '/create-settlement';
      case settlementDetail:
        return '/settlement-detail/:settlementId';
      case settlementManagement:
        return '/settlement-management';
    }
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;

  GoRouterRefreshStream(Stream<User?> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((user) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutePath.authWrapper.relativePath,
    routes: [
      GoRoute(
        path: AppRoutePath.authWrapper.relativePath,
        name: AppRoutePath.authWrapper.name,
        builder: (context, state) => const AuthWrapper(),
      ),
      GoRoute(
        path: AppRoutePath.login.relativePath,
        name: AppRoutePath.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutePath.mainNavigation.relativePath,
        name: AppRoutePath.mainNavigation.name,
        builder: (context, state) => const MainNavigationPage(),
        routes: [
          GoRoute(
            path: AppRoutePath.home.relativePath,
            name: AppRoutePath.home.name,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutePath.eventList.relativePath,
            name: AppRoutePath.eventList.name,
            builder: (context, state) => const EventListPage(),
          ),
          GoRoute(
            path: AppRoutePath.settings.relativePath,
            name: AppRoutePath.settings.name,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePath.eventDetail.relativePath,
        name: AppRoutePath.eventDetail.name,
        builder: (context, state) {
          final uuid = state.pathParameters['eventId']!;
          return ProviderScope(
            overrides: EventArgumentProviders.eventDetailOverrides(uuid),
            child: EventDetailPage(eventId: uuid),
          );
        },
      ),
      GoRoute(
        path: AppRoutePath.createEvent.relativePath,
        name: AppRoutePath.createEvent.name,
        builder: (context, state) => const CreateEventPage(),
      ),
      GoRoute(
        path: AppRoutePath.createChannel.relativePath,
        name: AppRoutePath.createChannel.name,
        builder: (context, state) => const CreateChannelPage(),
      ),
      GoRoute(
        path: AppRoutePath.noChannel.relativePath,
        name: AppRoutePath.noChannel.name,
        builder: (context, state) => const NoChannelPage(),
      ),
      GoRoute(
        path: AppRoutePath.announcement.relativePath,
        name: AppRoutePath.announcement.name,
        builder: (context, state) => const AnnouncementPage(),
      ),
      GoRoute(
        path: AppRoutePath.channelInfo.relativePath,
        name: AppRoutePath.channelInfo.name,
        builder: (context, state) => const ChannelInfoPage(),
      ),
      GoRoute(
        path: AppRoutePath.memberManagement.relativePath,
        name: AppRoutePath.memberManagement.name,
        builder: (context, state) => const MemberManagementPage(),
      ),
      GoRoute(
        path: AppRoutePath.notificationSettings.relativePath,
        name: AppRoutePath.notificationSettings.name,
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: AppRoutePath.ruleManagement.relativePath,
        name: AppRoutePath.ruleManagement.name,
        builder: (context, state) => const RuleManagementPage(),
      ),
      // GoRoute(
      //   path: AppRoutePath.createSettlement.relativePath,
      //   name: AppRoutePath.createSettlement.name,
      //   builder: (context, state) => const CreateSettlementPage(event: ,),
      // ),
      // GoRoute(
      //   path: AppRoutePath.settlementDetail.relativePath,
      //   name: AppRoutePath.settlementDetail.name,
      //   builder: (context, state) {
      //     final settlementId = state.pathParameters['settlementId']!;
      //     return SettlementDetailPage(event: , settlement: settlementId);
      //   },
      // ),
      // GoRoute(
      //   path: AppRoutePath.settlementManagement.relativePath,
      //   name: AppRoutePath.settlementManagement.name,
      //   builder: (context, state) => const SettlementManagementPage(),
      // ),
    ],
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingIn = state.matchedLocation == AppRoutePath.login.relativePath;
      final goingToAuthWrapper = state.matchedLocation == AppRoutePath.authWrapper.relativePath;

      if (!loggedIn && !loggingIn && !goingToAuthWrapper) {
        return AppRoutePath.login.relativePath;
      }
      if (loggedIn && (loggingIn || goingToAuthWrapper)) {
        return AppRoutePath.mainNavigation.relativePath;
      }

      return null;
    },
  );
}
