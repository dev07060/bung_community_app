import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/repositories/auth_repository.dart';
import 'package:our_bung_play/domain/repositories/event_participation_repository.dart';

/// 벙 참여 관리 Repository 구현체
/// 참여, 대기열 참여, 나가기 로직 및 참여 규칙 검증 담당
class EventParticipationRepositoryImpl implements EventParticipationRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  EventParticipationRepositoryImpl({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    try {
      final currentUser = _getCurrentUserId();
      if (userId != currentUser) {
        throw const PermissionException('다른 사용자를 대신해 벙에 참여할 수 없습니다.');
      }

      // 참여 규칙 검증
      await _validateParticipationRules(eventId, userId);

      await _firestore.runTransaction((transaction) async {
        final eventRef = _firestore.collection('events').doc(eventId);
        final eventDoc = await transaction.get(eventRef);

        if (!eventDoc.exists) {
          throw const NotFoundException('벙을 찾을 수 없습니다.');
        }

        final event = _eventFromDocument(eventDoc);

        if (event.isCancelled || event.isCompleted) {
          throw const ValidationException('참여할 수 없는 벙입니다.');
        }
        if (event.isParticipant(userId)) {
          throw const ValidationException('이미 참여 중인 벙입니다.');
        }

        if (event.isWaiting(userId)) {
          if (event.isFull) {
            throw const ValidationException(
              '아직 자리가 나지 않았습니다. 대기 상태가 유지됩니다.',
            );
          } else {
            transaction.update(eventRef, {
              'waitingIds': FieldValue.arrayRemove([userId]),
              'participantIds': FieldValue.arrayUnion([userId]),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        } else {
          if (event.isFull) {
            throw const ValidationException(
              '인원이 가득 차 참여할 수 없습니다. 대기열을 이용해주세요.',
            );
          }
          transaction.update(eventRef, {
            'participantIds': FieldValue.arrayUnion([userId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      // 참여 로그 기록
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      final channelId = eventDoc.data()?['channelId'];
      if (channelId != null) {
        await _logParticipation(userId, eventId, channelId, 'join');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('벙 참여에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> joinWaitingList(String eventId, String userId) async {
    try {
      final currentUser = _getCurrentUserId();
      if (userId != currentUser) {
        throw const PermissionException('다른 사용자를 대신해 대기할 수 없습니다.');
      }

      await _firestore.runTransaction((transaction) async {
        final eventRef = _firestore.collection('events').doc(eventId);
        final eventDoc = await transaction.get(eventRef);

        if (!eventDoc.exists) {
          throw const NotFoundException('벙을 찾을 수 없습니다.');
        }

        final event = _eventFromDocument(eventDoc);

        if (event.isCancelled || event.isCompleted || event.isOngoing) {
          throw const ValidationException('대기할 수 없는 벙입니다.');
        }
        if (event.isParticipant(userId) || event.isWaiting(userId)) {
          throw const ValidationException('이미 참여 중이거나 대기 중인 벙입니다.');
        }

        transaction.update(eventRef, {
          'waitingIds': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('벙 대기열 참여에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> leaveEvent(String eventId, String userId) async {
    try {
      final currentUser = _getCurrentUserId();
      if (userId != currentUser) {
        throw const PermissionException('다른 사용자를 대신해 벙에서 나갈 수 없습니다.');
      }

      String? channelId;

      await _firestore.runTransaction((transaction) async {
        final eventRef = _firestore.collection('events').doc(eventId);
        final eventDoc = await transaction.get(eventRef);

        if (!eventDoc.exists) {
          throw const NotFoundException('벙을 찾을 수 없습니다.');
        }

        final event = _eventFromDocument(eventDoc);
        channelId = event.channelId;

        if (event.isOrganizer(userId)) {
          throw const ValidationException(
            '벙 주최자는 벙을 나갈 수 없습니다. 벙을 취소해주세요.',
          );
        }
        if (!event.isParticipant(userId) && !event.isWaiting(userId)) {
          throw const ValidationException('참여하지 않은 벙입니다.');
        }

        List<String> newParticipantIds = List.from(event.participantIds);
        List<String> newWaitingIds = List.from(event.waitingIds);
        EventStatus newStatus = event.status;

        final wasParticipant = newParticipantIds.remove(userId);
        if (!wasParticipant) {
          newWaitingIds.remove(userId);
        }

        // 마감된 벙에서 참가자가 나가면 상태를 scheduled로 변경
        if (wasParticipant && event.status == EventStatus.closed) {
          if (newParticipantIds.length < event.maxParticipants) {
            newStatus = EventStatus.scheduled;
          }
        }

        transaction.update(eventRef, {
          'participantIds': newParticipantIds,
          'waitingIds': newWaitingIds,
          'status': newStatus.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // 나가기 로그 기록
      if (channelId != null) {
        await _logParticipation(userId, eventId, channelId!, 'leave');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('벙 나가기에 실패했습니다: ${e.toString()}');
    }
  }

  // === Private Helper Methods ===

  /// 참여 규칙 검증 (채널 설정 기반)
  Future<void> _validateParticipationRules(
    String eventId,
    String userId,
  ) async {
    final eventDoc =
        await _firestore.collection('events').doc(eventId).get();
    if (!eventDoc.exists) {
      throw const NotFoundException('벙을 찾을 수 없습니다.');
    }

    final channelId = eventDoc.data()?['channelId'];
    if (channelId == null) {
      throw const ServerException('이벤트에 채널 정보가 없습니다.');
    }

    final channelDoc =
        await _firestore.collection('channels').doc(channelId).get();
    final channelData = channelDoc.data();
    final settings = channelData?['settings'];

    final limitEventHopping = settings?['limitEventHopping'] ?? false;
    final maxEventsPerDay = settings?['maxEventsPerDay'] ?? 0;

    if (!limitEventHopping && maxEventsPerDay <= 0) {
      return; // 규칙 없음
    }

    final today = DateTime.now();
    final startOfDay = Timestamp.fromDate(
      DateTime(today.year, today.month, today.day),
    );

    final participationLogs = await _firestore
        .collection('event_participations')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();

    if (limitEventHopping) {
      final hasLeftEventToday =
          participationLogs.docs.any((doc) => doc.data()['action'] == 'leave');
      if (hasLeftEventToday) {
        throw const ValidationException(
          '오늘은 이미 다른 벙에서 나갔기 때문에 새로운 벙에 참여할 수 없습니다.',
        );
      }
    }

    if (maxEventsPerDay > 0) {
      final joinedEventsToday = participationLogs.docs
          .where((doc) => doc.data()['action'] == 'join')
          .length;
      if (joinedEventsToday >= maxEventsPerDay) {
        throw ValidationException(
          '하루에 참여할 수 있는 최대 벙 개수($maxEventsPerDay개)에 도달했습니다.',
        );
      }
    }
  }

  /// 참여 로그 기록
  Future<void> _logParticipation(
    String userId,
    String eventId,
    String channelId,
    String action,
  ) async {
    await _firestore.collection('event_participations').add({
      'userId': userId,
      'eventId': eventId,
      'channelId': channelId,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String _getCurrentUserId() {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      throw const AuthException('로그인이 필요합니다.');
    }
    return currentUser.id;
  }

  EventEntity _eventFromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EventEntity(
      id: doc.id,
      channelId: data['channelId'],
      organizerId: data['organizerId'],
      title: data['title'],
      description: data['description'],
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      location: data['location'],
      maxParticipants: data['maxParticipants'],
      participantIds: List<String>.from(data['participantIds'] ?? []),
      waitingIds: List<String>.from(data['waitingIds'] ?? []),
      status: EventStatus.values.firstWhere((s) => s.name == data['status']),
      requiresSettlement: data['requiresSettlement'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
