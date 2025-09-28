import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/repositories/auth_repository.dart';
import 'package:our_bung_play/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  Timer? _statusUpdateTimer;

  EventRepositoryImpl({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository {
    _startStatusUpdateTimer();
  }

  @override
  Future<EventEntity> createEvent(EventEntity event) async {
    try {
      final currentUser = _getCurrentUserId();

      if (!_isValidForCreation(event)) {
        throw const ValidationException('유효하지 않은 벙 정보입니다.');
      }

      if (event.organizerId != currentUser) {
        throw const PermissionException('벙 생성 권한이 없습니다.');
      }

      final now = DateTime.now();
      final eventData = {
        'channelId': event.channelId,
        'organizerId': event.organizerId,
        'title': event.title,
        'description': event.description,
        'scheduledAt': Timestamp.fromDate(event.scheduledAt),
        'location': event.location,
        'maxParticipants': event.maxParticipants,
        'participantIds': event.participantIds,
        'waitingIds': event.waitingIds,
        'status': event.status.name,
        'requiresSettlement': event.requiresSettlement,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection('events').add(eventData);

      return event.copyWith(
        id: docRef.id,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      log('벙 생성에 실패했습니다: ${e.toString()}');
      throw ServerException('벙 생성에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<List<EventEntity>> getChannelEvents(String channelId) async {
    try {
      final query = await _firestore
          .collection('events')
          .where('channelId', isEqualTo: channelId)
          .orderBy('scheduledAt', descending: false)
          .get();

      return query.docs.map((doc) => _eventFromDocument(doc)).toList();
    } catch (e) {
      throw ServerException('채널 벙 목록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<List<EventEntity>> getUserEvents(String userId) async {
    try {
      final eventIds = <String>{};
      final events = <EventEntity>[];

      final queries = [
        _firestore.collection('events').where('organizerId', isEqualTo: userId),
        _firestore.collection('events').where('participantIds', arrayContains: userId),
        _firestore.collection('events').where('waitingIds', arrayContains: userId),
      ];

      final querySnapshots = await Future.wait(queries.map((q) => q.get()));

      for (final snapshot in querySnapshots) {
        for (final doc in snapshot.docs) {
          if (!eventIds.contains(doc.id)) {
            eventIds.add(doc.id);
            events.add(_eventFromDocument(doc));
          }
        }
      }

      events.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      return events;
    } catch (e) {
      throw ServerException('사용자 벙 목록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    try {
      final currentUser = _getCurrentUserId();
      if (userId != currentUser) {
        throw const PermissionException('다른 사용자를 대신해 벙에 참여할 수 없습니다.');
      }

      // START: Participation Rules Check
      final eventDocForChannel = await _firestore.collection('events').doc(eventId).get();
      if (!eventDocForChannel.exists) throw const NotFoundException('벙을 찾을 수 없습니다.');
      final channelId = eventDocForChannel.data()?['channelId'];
      if (channelId == null) throw const ServerException('이벤트에 채널 정보가 없습니다.');

      final channelDoc = await _firestore.collection('channels').doc(channelId).get();
      final channelData = channelDoc.data();
      final settings = channelData?['settings'];

      final limitEventHopping = settings?['limitEventHopping'] ?? false;
      final maxEventsPerDay = settings?['maxEventsPerDay'] ?? 0;

      if (limitEventHopping || maxEventsPerDay > 0) {
        final today = DateTime.now();
        final startOfDay = Timestamp.fromDate(DateTime(today.year, today.month, today.day));

        final participationLogs = await _firestore
            .collection('event_participations')
            .where('userId', isEqualTo: userId)
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .get();

        if (limitEventHopping) {
          final hasLeftEventToday = participationLogs.docs.any((doc) => doc.data()['action'] == 'leave');
          if (hasLeftEventToday) {
            throw const ValidationException('오늘은 이미 다른 벙에서 나갔기 때문에 새로운 벙에 참여할 수 없습니다.');
          }
        }

        if (maxEventsPerDay > 0) {
          final joinedEventsToday = participationLogs.docs.where((doc) => doc.data()['action'] == 'join').length;
          if (joinedEventsToday >= maxEventsPerDay) {
            throw ValidationException('하루에 참여할 수 있는 최대 벙 개수($maxEventsPerDay개)에 도달했습니다.');
          }
        }
      }
      // END: Participation Rules Check

      await _firestore.runTransaction((transaction) async {
        final eventRef = _firestore.collection('events').doc(eventId);
        final eventDoc = await transaction.get(eventRef);

        if (!eventDoc.exists) throw const NotFoundException('벙을 찾을 수 없습니다.');

        final event = _eventFromDocument(eventDoc);

        if (event.isCancelled || event.isCompleted) {
          throw const ValidationException('참여할 수 없는 벙입니다.');
        }
        // if (event.isClosed) {
        //   throw const ValidationException('마감된 벙에는 참여할 수 없습니다. 대기열을 이용해주세요.');
        // }
        if (event.isParticipant(userId)) {
          throw const ValidationException('이미 참여 중인 벙입니다.');
        }

        if (event.isWaiting(userId)) {
          if (event.isFull) {
            throw const ValidationException('아직 자리가 나지 않았습니다. 대기 상태가 유지됩니다.');
          } else {
            transaction.update(eventRef, {
              'waitingIds': FieldValue.arrayRemove([userId]),
              'participantIds': FieldValue.arrayUnion([userId]),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        } else {
          if (event.isFull) {
            throw const ValidationException('인원이 가득 차 참여할 수 없습니다. 대기열을 이용해주세요.');
          }
          transaction.update(eventRef, {
            'participantIds': FieldValue.arrayUnion([userId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      // Add a "join" record to the participation log
      await _firestore.collection('event_participations').add({
        'userId': userId,
        'eventId': eventId,
        'channelId': channelId,
        'action': 'join',
        'timestamp': FieldValue.serverTimestamp(),
      });
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

        if (!eventDoc.exists) throw const NotFoundException('벙을 찾을 수 없습니다.');

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

      String? channelId; // To store channelId for logging

      await _firestore.runTransaction((transaction) async {
        final eventRef = _firestore.collection('events').doc(eventId);
        final eventDoc = await transaction.get(eventRef);

        if (!eventDoc.exists) throw const NotFoundException('벙을 찾을 수 없습니다.');

        final event = _eventFromDocument(eventDoc);
        channelId = event.channelId; // Get channelId

        if (event.isOrganizer(userId)) {
          throw const ValidationException('벙 주최자는 벙을 나갈 수 없습니다. 벙을 취소해주세요.');
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

      // Add a "leave" record to the participation log
      if (channelId != null) {
        await _firestore.collection('event_participations').add({
          'userId': userId,
          'eventId': eventId,
          'channelId': channelId,
          'action': 'leave',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('벙 나가기에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> updateEventStatus(String eventId, EventStatus status) async {
    try {
      final currentUser = _getCurrentUserId();

      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        throw const NotFoundException('벙을 찾을 수 없습니다.');
      }

      final event = _eventFromDocument(eventDoc);

      if (!event.isOrganizer(currentUser)) {
        throw const PermissionException('벙 상태 변경 권한이 없습니다.');
      }

      _validateStatusTransition(event.status, status);

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
  Future<EventEntity?> getEventById(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) {
        return null;
      }

      return _eventFromDocument(eventDoc);
    } catch (e) {
      throw ServerException('벙 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Stream<List<EventEntity>> watchChannelEvents(String channelId) {
    return _firestore
        .collection('events')
        .where('channelId', isEqualTo: channelId)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _eventFromDocument(doc)).toList());
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

  void _validateStatusTransition(EventStatus currentStatus, EventStatus newStatus) {
    final validTransitions = {
      EventStatus.scheduled: [EventStatus.closed, EventStatus.cancelled],
      EventStatus.closed: [EventStatus.scheduled, EventStatus.cancelled],
      EventStatus.ongoing: [EventStatus.completed, EventStatus.cancelled],
      EventStatus.completed: [],
      EventStatus.cancelled: [],
    };

    if (!validTransitions[currentStatus]!.contains(newStatus)) {
      throw const ValidationException('유효하지 않은 상태 변경입니다.');
    }
  }

  void _startStatusUpdateTimer() {
    _statusUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateEventStatuses();
    });
  }

  Future<void> _updateEventStatuses() async {
    try {
      final now = DateTime.now();

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

      final fourHoursAgo = now.subtract(const Duration(hours: 4));
      final ongoingQuery = await _firestore
          .collection('events')
          .where('status', isEqualTo: EventStatus.ongoing.name)
          .where('scheduledAt', isLessThanOrEqualTo: Timestamp.fromDate(fourHoursAgo))
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

  bool _isValidForCreation(EventEntity event) {
    return event.channelId.isNotEmpty &&
        event.organizerId.isNotEmpty &&
        event.title.trim().isNotEmpty &&
        event.description.trim().isNotEmpty &&
        event.location.trim().isNotEmpty &&
        event.maxParticipants > 0 &&
        event.scheduledAt.isAfter(DateTime.now());
  }

  void dispose() {
    _statusUpdateTimer?.cancel();
  }
}
