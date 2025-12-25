import 'package:our_bung_play/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signInWithApple();
  Future<void> signOut();
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;

  /// 프로필 업데이트 (닉네임 등)
  Future<UserEntity?> updateProfile({String? nickname, String? photoURL});
}

