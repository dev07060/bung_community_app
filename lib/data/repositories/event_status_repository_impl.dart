import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/domain/repositories/auth_repository.dart';
import 'package:our_bung_play/domain/repositories/event_status_repository.dart';

/// 벙 상태 관리 Repository 구현체
/// 상태 변경, 상태 전환 검증, 자동 상태 업데이트 담당
class EventStatusRepositoryImpl implements EventStatusRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  Timer? _statusUpdateTimer;

  EventStatusRepositoryImpl({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

  @override
  Future<void> updateEventStatus(String eventId, EventStatus status) async {
    try {
      final currentUser = _getCurrentUserId();

      final eventDoc =
          await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw const NotFoundException('벙을 찾을 수 없습니다.');
      }

      final data = eventDoc.data() as Map<String, dynamic>;
      final organizerId = data['organizerId'] as String;
      final currentStatusName = data['status'] as String;
      final currentStatus =
          EventStatus.values.firstWhere((s) => s.name == currentStatusName);

      if (organizerId != currentUser) {
        throw const PermissionException('벙 상태 변경 권한이 없습니다.');
      }

      _validateStatusTransition(currentStatus, status);

      await _firestore.collection('events').doc(eventId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('벙 상태 업데이트에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  void startAutoStatusUpdate() {
    _statusUpdateTimer?.cancel();
    _statusUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateEventStatuses();
    });
  }

  @override
  void stopAutoStatusUpdate() {
    _statusUpdateTimer?.cancel();
    _statusUpdateTimer = null;
  }

  @override
  void dispose() {
    stopAutoStatusUpdate();
  }

  // === Private Helper Methods ===

  /// 상태 전환 검증
  void _validateStatusTransition(
    EventStatus currentStatus,
    EventStatus newStatus,
  ) {
    final validTransitions = {
      EventStatus.scheduled: [EventStatus.closed, EventStatus.cancelled],
      EventStatus.closed: [EventStatus.scheduled, EventStatus.cancelled],
      EventStatus.ongoing: [EventStatus.completed, EventStatus.cancelled],
      EventStatus.settlement: [EventStatus.completed],
      EventStatus.completed: <EventStatus>[],
      EventStatus.cancelled: <EventStatus>[],
    };

    if (!validTransitions[currentStatus]!.contains(newStatus)) {
      throw const ValidationException('유효하지 않은 상태 변경입니다.');
    }
  }

  /// 자동 상태 업데이트 (scheduled → ongoing → completed)
  Future<void> _updateEventStatuses() async {
    try {
      final now = DateTime.now();

      // scheduled → ongoing (예정 시간이 지난 벙)
      final scheduledQuery = await _firestore
          .collection('events')
          .where('status', isEqualTo: EventStatus.scheduled.name)
          .where('scheduledAt', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      final batch = _firestore.batch();

      for (final doc in scheduledQuery.docs) {
        batch.update(doc.reference, {
          'status': EventStatus.ongoing.name,
          'updatedAt': Timestamp.fromDate(now),
        });
      }

      // ongoing → completed (4시간 경과한 벙, 정산 불필요 시)
      final fourHoursAgo = now.subtract(const Duration(hours: 4));
      final ongoingQuery = await _firestore
          .collection('events')
          .where('status', isEqualTo: EventStatus.ongoing.name)
          .where(
            'scheduledAt',
            isLessThanOrEqualTo: Timestamp.fromDate(fourHoursAgo),
          )
          .get();

      for (final doc in ongoingQuery.docs) {
        final data = doc.data();
        final requiresSettlement = data['requiresSettlement'] ?? false;

        if (!requiresSettlement) {
          batch.update(doc.reference, {
            'status': EventStatus.completed.name,
            'updatedAt': Timestamp.fromDate(now),
          });
        }
      }

      if (scheduledQuery.docs.isNotEmpty || ongoingQuery.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      log('Error updating event statuses: $e');
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
