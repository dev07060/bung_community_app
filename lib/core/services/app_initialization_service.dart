import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:our_bung_play/core/services/error_handler_service.dart';
import 'package:our_bung_play/core/services/network_service.dart';
import 'package:our_bung_play/core/utils/logger.dart';

/// Service responsible for initializing the application
class AppInitializationService {
  static final AppInitializationService _instance = AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  final AppLogger _logger = AppLogger();
  bool _isInitialized = false;

  /// Check if app is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the application
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.warning('App already initialized');
      return;
    }

    try {
      _logger.info('Starting app initialization...');

      // Initialize Firebase
      await _initializeFirebase();

      // Initialize error handling
      await _initializeErrorHandling();

      // Initialize network service
      await _initializeNetworkService();

      // Set system UI overlay style
      _setSystemUIOverlayStyle();

      _isInitialized = true;
      _logger.info('App initialization completed successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'App initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Initialize Firebase services
  Future<void> _initializeFirebase() async {
    try {
      _logger.info('Initializing Firebase...');

      // Initialize Firebase Core
      await Firebase.initializeApp();

      // Initialize Crashlytics
      await _initializeCrashlytics();

      _logger.info('Firebase initialized successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'Firebase initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Initialize Firebase Crashlytics
  Future<void> _initializeCrashlytics() async {
    try {
      final crashlytics = FirebaseCrashlytics.instance;

      // Enable Crashlytics collection in release mode
      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Set up automatic crash reporting
      if (!kDebugMode) {
        // Pass all uncaught "fatal" errors from the framework to Crashlytics
        FlutterError.onError = (errorDetails) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        };

        // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }

      _logger.info('Crashlytics initialized successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'Crashlytics initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      // Don't rethrow as Crashlytics is not critical for app functionality
    }
  }

  /// Initialize error handling service
  Future<void> _initializeErrorHandling() async {
    try {
      _logger.info('Initializing error handling...');

      final errorHandler = ErrorHandlerService();
      await errorHandler.initialize();

      _logger.info('Error handling initialized successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'Error handling initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Initialize network service
  Future<void> _initializeNetworkService() async {
    try {
      _logger.info('Initializing network service...');

      final networkService = NetworkService();
      await networkService.initialize();

      _logger.info('Network service initialized successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'Network service initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      // Don't rethrow as network service will handle its own errors
    }
  }

  /// Set system UI overlay style
  void _setSystemUIOverlayStyle() {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      _logger.info('System UI overlay style set successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to set system UI overlay style',
        error: error,
        stackTrace: stackTrace,
      );
      // Don't rethrow as this is not critical
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      _logger.info('Disposing app services...');

      // Dispose network service
      NetworkService().dispose();

      _isInitialized = false;
      _logger.info('App services disposed successfully');
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to dispose app services',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
