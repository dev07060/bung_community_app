// This file demonstrates how to use the error handling system
// It should be removed in production
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/core/repositories/base_repository.dart';
import 'package:our_bung_play/core/services/error_handler_service.dart';
import 'package:our_bung_play/core/services/network_service.dart';
import 'package:our_bung_play/core/widgets/error_widgets.dart';

/// Example repository showing error handling patterns
class ExampleRepository extends BaseRepository {
  /// Example method with comprehensive error handling
  Future<String> fetchData(String id) async {
    return executeFirestoreOperation(
      () async {
        // Validate input
        if (id.isEmpty) {
          throw ValidationException.required('ID');
        }

        // Simulate network operation
        final doc = await firestore.collection('examples').doc(id).get();

        if (!doc.exists) {
          throw const NotFoundException('데이터를 찾을 수 없습니다.');
        }

        return doc.data()?['value'] as String? ?? '';
      },
      operationName: 'fetchData',
      retryConfig: const RetryConfig(maxRetries: 2),
    );
  }

  /// Example method with storage operation
  Future<String> uploadFile(String path, List<int> data) async {
    return executeStorageOperation(
      () async {
        // Validate file size (5MB limit)
        if (data.length > 5 * 1024 * 1024) {
          throw StorageException.fileTooLarge(5);
        }

        final ref = storage.ref().child(path);
        await ref.putData(Uint8List.fromList(data));
        return await ref.getDownloadURL();
      },
      operationName: 'uploadFile',
    );
  }

  /// Example method with auth operation
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    return executeAuthOperation(
      () async {
        final user = currentUser; // This will throw if not authenticated

        // Update user document
        await firestore.collection('users').doc(user.uid).update(data);
      },
      operationName: 'updateUserProfile',
    );
  }
}

/// Example provider using error handling
final exampleRepositoryProvider = Provider<ExampleRepository>((ref) {
  return ExampleRepository();
});

final exampleDataProvider = FutureProvider.family<String, String>((ref, id) async {
  final repository = ref.read(exampleRepositoryProvider);

  try {
    return await repository.fetchData(id);
  } catch (error) {
    // Handle error using the extension
    // ref.handleError(error, stackTrace: stackTrace, context: 'fetchData');
    rethrow;
  }
});

/// Example widget showing error handling patterns
class ErrorHandlingExampleWidget extends ConsumerStatefulWidget {
  const ErrorHandlingExampleWidget({super.key});

  @override
  ConsumerState<ErrorHandlingExampleWidget> createState() => _ErrorHandlingExampleWidgetState();
}

class _ErrorHandlingExampleWidgetState extends ConsumerState<ErrorHandlingExampleWidget>
    with ErrorHandlerMixin, LoadingStateMixin, NetworkAwareMixin {
  final String _exampleId = 'example123';

  @override
  Widget build(BuildContext context) {
    final exampleData = ref.watch(exampleDataProvider(_exampleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handling Example'),
      ),
      body: Column(
        children: [
          // Network status indicator
          const NetworkStatusIndicator(),

          // Main content with error handling
          Expanded(
            child: buildLoadingOverlay(
              child: AsyncValueWidget<String>(
                value: exampleData,
                data: (data) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Data: $data'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _uploadExampleFile,
                        child: const Text('Upload File'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _updateProfile,
                        child: const Text('Update Profile'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _triggerError,
                        child: const Text('Trigger Error'),
                      ),
                    ],
                  ),
                ),
                onRetry: () => ref.invalidate(exampleDataProvider(_exampleId)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Example of handling async operation with loading state
  Future<void> _uploadExampleFile() async {
    await executeWithLoading(() async {
      await executeNetworkOperation(
        () async {
          final repository = ref.read(exampleRepositoryProvider);
          final data = List.generate(100, (i) => i); // Example data

          final url = await repository.uploadFile('example.txt', data);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File uploaded: $url')),
            );
          }
        },
        operationName: 'uploadFile',
      );
    });
  }

  /// Example of handling operation with error dialog
  Future<void> _updateProfile() async {
    try {
      await executeWithLoading(() async {
        final repository = ref.read(exampleRepositoryProvider);
        await repository.updateUserProfile({'lastUpdated': DateTime.now().toIso8601String()});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      });
    } catch (error) {
      if (error is AppException) {
        showErrorDialog(
          error,
          onRetry: _updateProfile,
        );
      } else {
        handleError(error, context: 'updateProfile');
      }
    }
  }

  /// Example of triggering different types of errors
  Future<void> _triggerError() async {
    final errorTypes = [
      () => throw NetworkException.noConnection(),
      () => throw AuthException.userNotFound(),
      () => throw ValidationException.required('Test Field'),
      () => throw PermissionException.accessDenied(),
      () => throw NotFoundException.channel(),
      () => throw ServerException.internalError(),
      () => throw StorageException.uploadFailed(),
      () => throw UnknownException.fromError('Unknown error'),
    ];

    final randomError = errorTypes[DateTime.now().millisecond % errorTypes.length];

    try {
      randomError();
    } catch (error) {
      handleError(error, context: 'triggerError');
    }
  }
}

/// Example of using ErrorBoundary
class ErrorBoundaryExample extends StatelessWidget {
  const ErrorBoundaryExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: (error) {
        // Log error or send to analytics
        debugPrint('Error caught by boundary: $error');
      },
      errorBuilder: (error, retry) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: ErrorStateWidget(
          exception: error,
          onRetry: retry,
          showDetails: true,
        ),
      ),
      child: const ErrorHandlingExampleWidget(),
    );
  }
}

/// Example of custom error handling in a provider
final customErrorProvider = StateNotifierProvider<CustomErrorNotifier, AsyncValue<String>>((ref) {
  return CustomErrorNotifier(ref.read(exampleRepositoryProvider));
});

class CustomErrorNotifier extends StateNotifier<AsyncValue<String>> {
  final ExampleRepository _repository;

  CustomErrorNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadData(String id) async {
    state = const AsyncValue.loading();

    try {
      final data = await _repository.fetchData(id);
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      // Custom error handling logic
      if (error is NetworkException) {
        // Retry after delay for network errors
        await Future.delayed(const Duration(seconds: 2));
        return loadData(id); // Retry once
      }

      state = AsyncValue.error(error, stackTrace);
    }
  }

  void retry(String id) {
    loadData(id);
  }
}
