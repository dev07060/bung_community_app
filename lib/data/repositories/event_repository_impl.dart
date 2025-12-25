import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/domain/repositories/auth_repository.dart';
import 'package:our_bung_play/domain/repositories/event_repository.dart';

/// 벙 CRUD Repository 구현체
/// 생성, 조회, 스트림 기능만 담당
///
/// 참여 관련: [EventParticipationRepositoryImpl]
/// 상태 관련: [EventStatusRepositoryImpl]
class EventRepositoryImpl implements EventRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  EventRepositoryImpl({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

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
        _firestore
            .collection('events')
            .where('organizerId', isEqualTo: userId),
        _firestore
            .collection('events')
            .where('participantIds', arrayContains: userId),
        _firestore
            .collection('events')
            .where('waitingIds', arrayContains: userId),
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
  Future<EventEntity?> getEventById(String eventId) async {
    try {
      final eventDoc =
          await _firestore.collection('events').doc(eventId).get();

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
        .map((snapshot) =>
            snapshot.docs.map((doc) => _eventFromDocument(doc)).toList());
  }

  // === Private Helper Methods ===

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
}

