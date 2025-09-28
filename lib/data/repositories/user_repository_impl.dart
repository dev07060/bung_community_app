import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/domain/entities/user_entity.dart';
import 'package:our_bung_play/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw const NotFoundException('User not found');
      }
      return UserEntity.fromJson(doc.data()!);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Failed to fetch user: ${e.toString()}');
    }
  }
}
