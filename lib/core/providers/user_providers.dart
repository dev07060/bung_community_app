import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_bung_play/data/repositories/user_repository_impl.dart';
import 'package:our_bung_play/domain/entities/user_entity.dart';
import 'package:our_bung_play/domain/repositories/user_repository.dart';

/// Provides the user repository implementation.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

/// Fetches a single user by their ID.
/// This is a family provider, so you can watch it with a user ID, like so:
/// `ref.watch(userProvider('some-user-id'))`
final userProvider = FutureProvider.family<UserEntity, String>((ref, userId) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserById(userId);
});
