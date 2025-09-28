# Error Handling System

This directory contains the comprehensive error handling system for the Our Bung Play application.

## Overview

The error handling system provides:
- Structured exception classes with user-friendly messages
- Global error handling and logging
- Network retry logic with exponential backoff
- Firebase Crashlytics integration
- Offline mode support
- UI components for error display

## Components

### Exception Classes (`app_exceptions.dart`)

#### Base Exception
- `AppException`: Base class for all application exceptions
- Provides error type, code, message, and user-friendly Korean messages

#### Specific Exception Types
- `AuthException`: Authentication related errors
- `NetworkException`: Network connectivity issues
- `ValidationException`: Input validation errors
- `PermissionException`: Access permission errors
- `NotFoundException`: Data not found errors
- `ServerException`: Server-side errors
- `StorageException`: File storage errors
- `UnknownException`: Fallback for unexpected errors

### Services

#### Error Handler Service (`../services/error_handler_service.dart`)
- Global error handling and recording
- Firebase Crashlytics integration
- User feedback through snackbars and dialogs
- Error context tracking

#### Network Service (`../services/network_service.dart`)
- Network connectivity monitoring
- Retry logic with exponential backoff
- Offline mode detection
- Connection status streaming

#### App Initialization Service (`../services/app_initialization_service.dart`)
- Centralized app initialization
- Error handling setup
- Firebase services initialization
- System UI configuration

### Repository Base Class (`../repositories/base_repository.dart`)
- Common error handling for Firebase operations
- Automatic error conversion and retry logic
- Logging integration
- Operation context tracking

### UI Components (`../widgets/error_widgets.dart`)
- `ErrorStateWidget`: Display error states with retry options
- `AsyncValueWidget`: Handle AsyncValue states with error handling
- `NetworkStatusIndicator`: Show network connectivity status
- `ErrorBoundary`: Catch and display widget errors
- Various mixins for error handling in widgets

### Providers (`../providers/error_providers.dart`)
- Global error state management
- Network status providers
- Error handling extensions for Ref

## Usage Examples

### Basic Error Handling in Repository

```dart
class MyRepository extends BaseRepository {
  Future<String> fetchData(String id) async {
    return executeFirestoreOperation(
      () async {
        if (id.isEmpty) {
          throw ValidationException.required('ID');
        }
        
        final doc = await firestore.collection('data').doc(id).get();
        if (!doc.exists) {
          throw NotFoundException('Data not found');
        }
        
        return doc.data()?['value'] as String;
      },
      operationName: 'fetchData',
      retryConfig: const RetryConfig(maxRetries: 2),
    );
  }
}
```

### Error Handling in Providers

```dart
final dataProvider = FutureProvider.family<String, String>((ref, id) async {
  final repository = ref.read(myRepositoryProvider);
  
  try {
    return await repository.fetchData(id);
  } catch (error, stackTrace) {
    ref.handleError(error, stackTrace: stackTrace, context: 'fetchData');
    rethrow;
  }
});
```

### Error Handling in Widgets

```dart
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget>
    with ErrorHandlerMixin, LoadingStateMixin, NetworkAwareMixin {
  
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider('123'));
    
    return Scaffold(
      body: Column(
        children: [
          buildOfflineIndicator(),
          Expanded(
            child: buildLoadingOverlay(
              child: AsyncValueWidget<String>(
                value: data,
                data: (value) => Text(value),
                onRetry: () => ref.invalidate(dataProvider('123')),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _performAction() async {
    try {
      await executeWithLoading(() async {
        await executeNetworkOperation(
          () async {
            // Your network operation here
          },
          operationName: 'performAction',
        );
      });
    } catch (error) {
      handleError(error, context: 'performAction');
    }
  }
}
```

### Using Error Boundary

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ErrorBoundary(
        onError: (error) {
          // Log error or send to analytics
        },
        child: MyHomePage(),
      ),
    );
  }
}
```

## Error Types and User Messages

| Error Type | Korean Message                   | Use Case                |
| ---------- | -------------------------------- | ----------------------- |
| Auth       | 로그인에 문제가 발생했습니다     | Authentication failures |
| Network    | 네트워크 연결을 확인해주세요     | Connectivity issues     |
| Validation | [Field specific message]         | Input validation        |
| Permission | 권한이 없습니다                  | Access denied           |
| NotFound   | 요청한 정보를 찾을 수 없습니다   | Data not found          |
| Server     | 서버에 문제가 발생했습니다       | Server errors           |
| Storage    | 파일 처리 중 문제가 발생했습니다 | File operations         |
| Unknown    | 알 수 없는 오류가 발생했습니다   | Fallback                |

## Configuration

### Retry Configuration

```dart
const RetryConfig(
  maxRetries: 3,                              // Maximum retry attempts
  initialDelay: Duration(seconds: 1),         // Initial delay
  backoffMultiplier: 2.0,                     // Exponential backoff
  maxDelay: Duration(seconds: 10),            // Maximum delay
)
```

### Network Service Setup

The network service automatically monitors connectivity and provides:
- Real-time network status updates
- Automatic retry for network-related failures
- Offline mode detection
- Connection waiting functionality

## Best Practices

1. **Always use specific exception types** instead of generic Exception
2. **Provide context** when handling errors for better debugging
3. **Use retry logic** for network operations
4. **Show user-friendly messages** using the built-in Korean translations
5. **Log errors** with appropriate detail levels
6. **Handle offline scenarios** gracefully
7. **Use loading states** for better UX during operations
8. **Implement error boundaries** for critical UI sections

## Integration with Firebase Crashlytics

The system automatically:
- Records all errors to Crashlytics in release mode
- Sets user identifiers for better tracking
- Logs custom events and parameters
- Provides crash-free user metrics

## Testing

The error handling system includes:
- Unit tests for exception classes
- Integration tests for network retry logic
- Widget tests for error UI components
- Mock implementations for testing

## Monitoring and Analytics

Errors are automatically tracked with:
- Error type and code
- User context and session information
- Network status at time of error
- Custom parameters and breadcrumbs
- Performance impact metrics