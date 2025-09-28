import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';

abstract class EventRepository {
  Future<EventEntity> createEvent(EventEntity event);
  Future<List<EventEntity>> getChannelEvents(String channelId);
  Future<List<EventEntity>> getUserEvents(String userId);
  Future<void> joinEvent(String eventId, String userId);
  Future<void> joinWaitingList(String eventId, String userId);
  Future<void> leaveEvent(String eventId, String userId);
  Future<void> updateEventStatus(String eventId, EventStatus status);
  Future<EventEntity?> getEventById(String eventId);
  Stream<List<EventEntity>> watchChannelEvents(String channelId);
}
