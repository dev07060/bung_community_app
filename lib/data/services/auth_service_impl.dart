import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:our_bung_play/core/constants/app_constants.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/core/utils/logger.dart';
import 'package:our_bung_play/domain/entities/user_entity.dart';
import 'package:our_bung_play/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

class AuthServiceImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  AuthServiceImpl({firebase_auth.FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
              // 웹 클라이언트 ID를 명시적으로 설정 (임시)
              serverClientId: '996085390532-9g0vi8mld2qr9469vmvh92dsiuq3t3kr.apps.googleusercontent.com',
            ),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = const Uuid();

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        return await _getUserFromFirestore(firebaseUser.uid) ?? await _createUserInFirestore(firebaseUser);
      } catch (e, stackTrace) {
        Logger.error('Error in auth state changes', e, stackTrace);
        return null;
      }
    });
  }

  @override
  UserEntity? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    // 현재 사용자 정보를 동기적으로 반환 (캐시된 정보)
    // 주의: UUID는 Firestore에서 가져와야 하므로 여기서는 임시값 사용
    return UserEntity(
      id: firebaseUser.uid,
      uuid: 'temp-uuid', // 실제로는 Firestore에서 가져와야 함
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoURL: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      Logger.info('Starting Google sign in');

      // 기존 로그인 상태 확인 및 정리
      await _googleSignIn.signOut();

      // Google 로그인 플로우 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Logger.info('Google sign in cancelled by user');
        return null;
      }

      Logger.info('Google user obtained: ${googleUser.email}');

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw const AuthException('Google 인증 토큰을 가져올 수 없습니다');
      }

      Logger.info('Google auth tokens obtained');

      // Firebase 인증 자격 증명 생성
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      Logger.info('Firebase credential created');

      // Firebase에 로그인
      final firebase_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      final firebase_auth.User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthException('Firebase user is null after Google sign in');
      }

      Logger.info('Firebase sign in successful: ${firebaseUser.uid}');

      // Firestore에서 사용자 정보 가져오기 또는 생성
      UserEntity? user = await _getUserFromFirestore(firebaseUser.uid);
      if (user == null) {
        Logger.info('Creating new user in Firestore');
        user = await _createUserInFirestore(firebaseUser);
      } else {
        Logger.info('Updating existing user login time');
        // 마지막 로그인 시간 업데이트
        user = await _updateLastLoginTime(user);
      }

      Logger.info('Google sign in completed successfully');
      return user;
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      Logger.error('Firebase auth error during Google sign in', e, stackTrace);
      throw AuthException(_getAuthErrorMessage(e.code));
    } on AuthException catch (e, stackTrace) {
      Logger.error('Auth exception during Google sign in', e, stackTrace);
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error during Google sign in', e, stackTrace);

      // PlatformException 처리
      if (e.toString().contains('sign_in_failed')) {
        throw const AuthException('Google 로그인 설정에 문제가 있습니다. Firebase Console에서 Google 로그인이 활성화되어 있는지 확인해주세요.');
      } else if (e.toString().contains('AUTH_ERROR')) {
        throw const AuthException('Google 로그인 인증 오류가 발생했습니다. 앱 설정을 확인해주세요.');
      }

      throw AuthException('Google 로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> signInWithApple() async {
    return null;
  }

  @override
  Future<void> signOut() async {
    try {
      Logger.info('Starting sign out');

      // Google 로그아웃
      await _googleSignIn.signOut();

      // Firebase 로그아웃
      await _firebaseAuth.signOut();

      Logger.info('Sign out successful');
    } catch (e, stackTrace) {
      Logger.error('Error during sign out', e, stackTrace);
      throw AuthException('로그아웃 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // Private helper methods

  Future<UserEntity?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserEntity.fromJson({'id': doc.id, ...data});
    } catch (e, stackTrace) {
      Logger.error('Error getting user from Firestore', e, stackTrace);
      return null;
    }
  }

  Future<UserEntity> _createUserInFirestore(firebase_auth.User firebaseUser, {String? displayName}) async {
    try {
      final now = DateTime.now();
      final userUuid = _uuid.v4(); // UUID 생성

      final user = UserEntity(
        id: firebaseUser.uid,
        uuid: userUuid,
        email: firebaseUser.email ?? '',
        displayName: displayName ?? firebaseUser.displayName ?? '',
        photoURL: firebaseUser.photoURL,
        role: UserRole.member,
        status: UserStatus.active,
        createdAt: firebaseUser.metadata.creationTime ?? now,
        lastLoginAt: now,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(user.toJson()..remove('id')); // id는 문서 ID로 사용

      Logger.info('User created in Firestore: ${firebaseUser.uid}');
      return user;
    } catch (e, stackTrace) {
      Logger.error('Error creating user in Firestore', e, stackTrace);
      throw const AuthException('사용자 정보 저장 중 오류가 발생했습니다');
    }
  }

  Future<UserEntity> _updateLastLoginTime(UserEntity user) async {
    try {
      final now = DateTime.now();
      final updatedUser = user.copyWith(lastLoginAt: now);

      await _firestore.collection(AppConstants.usersCollection).doc(user.id).update({
        'lastLoginAt': now.toIso8601String(),
      });

      return updatedUser;
    } catch (e, stackTrace) {
      Logger.error('Error updating last login time', e, stackTrace);
      // 업데이트 실패해도 로그인은 성공으로 처리
      return user;
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-disabled':
        return '계정이 비활성화되었습니다.';
      case 'user-not-found':
        return '사용자를 찾을 수 없습니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 주소입니다.';
      case 'account-exists-with-different-credential':
        return '다른 로그인 방법으로 가입된 계정입니다.';
      case 'invalid-credential':
        return '인증 정보가 유효하지 않습니다.';
      case 'operation-not-allowed':
        return 'Google 로그인이 활성화되지 않았습니다. Firebase Console에서 Google 로그인을 활성화해주세요.';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'sign_in_failed':
        return 'Google 로그인에 실패했습니다. 앱 설정을 확인해주세요.';
      default:
        return '인증 중 오류가 발생했습니다: $errorCode';
    }
  }
}
