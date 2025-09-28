import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:our_bung_play/core/config/firebase_config.dart';
import 'package:our_bung_play/core/constants/app_constants.dart';
import 'package:our_bung_play/core/providers/global_providers.dart';
import 'package:our_bung_play/core/router.dart';
import 'package:our_bung_play/core/services/app_initialization_service.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/core/widgets/error_widgets.dart';
import 'package:our_bung_play/data/services/notification_handler_service.dart';
import 'package:our_bung_play/firebase_options.dart';
import 'package:our_bung_play/presentation/providers/notification_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize app services with comprehensive error handling
    final appInitService = AppInitializationService();
    await appInitService.initialize();

    // Initialize Firebase (if not already done by app init service)
    await FirebaseConfig.initialize();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Logger.info('Firebase initialized successfully');

    // Initialize global container
    initializeGlobalContainer();
    Logger.info('Global container initialized');

    // Initialize notification system
    await globalContainer.read(notificationInitializationProvider.future);
    Logger.info('Notification system initialized');

    runApp(
      UncontrolledProviderScope(
        container: globalContainer,
        child: const ProviderScope(
          child: MyApp(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    Logger.error('Failed to initialize app', e, stackTrace);
    runApp(ErrorApp(error: e, stackTrace: stackTrace));
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 12 기준
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: AppRouter.router,
          title: AppConstants.appName,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Pretendard', // 한국어 폰트
          ),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            // Set navigator context for notification handler
            NotificationHandlerService.setNavigatorContext(context);

            return Column(
              children: [
                // Network status indicator at the top
                const NetworkStatusIndicator(),
                // Main app content
                Expanded(child: child!),
              ],
            );
          },
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group,
              size: 100.w,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 24.h),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '커뮤니티 관리의 새로운 시작',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 48.h),
            const CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final dynamic error;
  final StackTrace? stackTrace;

  const ErrorApp({
    super.key,
    this.error,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  '앱 초기화 중 오류가 발생했습니다.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  '앱을 다시 시작해 주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '오류 정보: ${error.toString()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Restart the app (this is a simplified approach)
                    // In a real app, you might want to use a package like restart_app
                    main();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
