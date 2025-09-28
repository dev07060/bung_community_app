import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/rule_entity.dart';
import '../../domain/repositories/rule_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/exceptions/app_exceptions.dart';

class RuleRepositoryImpl implements RuleRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  RuleRepositoryImpl({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _authRepository = authRepository;

  @override
  Future<RuleEntity> createRule(RuleEntity rule) async {
    try {
      final currentUser = _getCurrentUserId();
      
      // Verify user is admin of the channel
      await _verifyChannelAdmin(rule.channelId, currentUser);

      final now = DateTime.now();
      final ruleData = {
        'channelId': rule.channelId,
        'title': rule.title,
        'content': rule.content,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection('rules').add(ruleData);

      return RuleEntity(
        id: docRef.id,
        channelId: rule.channelId,
        title: rule.title,
        content: rule.content,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('회칙 생성에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<RuleEntity?> getChannelRule(String channelId) async {
    try {
      final ruleQuery = await _firestore
          .collection('rules')
          .where('channelId', isEqualTo: channelId)
          .limit(1)
          .get();

      if (ruleQuery.docs.isEmpty) {
        return null;
      }

      final ruleDoc = ruleQuery.docs.first;
      final ruleData = ruleDoc.data();

      return RuleEntity(
        id: ruleDoc.id,
        channelId: ruleData['channelId'],
        title: ruleData['title'],
        content: ruleData['content'],
        createdAt: (ruleData['createdAt'] as Timestamp).toDate(),
        updatedAt: (ruleData['updatedAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      throw ServerException('회칙 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> updateRule(RuleEntity rule) async {
    try {
      final currentUser = _getCurrentUserId();
      
      // Verify user is admin of the channel
      await _verifyChannelAdmin(rule.channelId, currentUser);

      final updateData = {
        'title': rule.title,
        'content': rule.content,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore
          .collection('rules')
          .doc(rule.id)
          .update(updateData);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('회칙 업데이트에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRule(String ruleId) async {
    try {
      final currentUser = _getCurrentUserId();
      
      // Get rule to verify channel admin
      final ruleDoc = await _firestore
          .collection('rules')
          .doc(ruleId)
          .get();

      if (!ruleDoc.exists) {
        throw const ValidationException('회칙을 찾을 수 없습니다.');
      }

      final ruleData = ruleDoc.data()!;
      await _verifyChannelAdmin(ruleData['channelId'], currentUser);

      await _firestore
          .collection('rules')
          .doc(ruleId)
          .delete();
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('회칙 삭제에 실패했습니다: ${e.toString()}');
    }
  }

  // Private helper methods
  Future<void> _verifyChannelAdmin(String channelId, String userId) async {
    try {
      final channelDoc = await _firestore
          .collection('channels')
          .doc(channelId)
          .get();

      if (!channelDoc.exists) {
        throw const ValidationException('채널을 찾을 수 없습니다.');
      }

      final channelData = channelDoc.data()!;
      if (channelData['adminId'] != userId) {
        throw const PermissionException('회칙 관리 권한이 없습니다.');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('권한 확인에 실패했습니다: ${e.toString()}');
    }
  }

  String _getCurrentUserId() {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      throw const AuthException('로그인이 필요합니다.');
    }
    return currentUser.id;
  }
}