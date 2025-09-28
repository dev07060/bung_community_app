import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/enums/app_enums.dart';

part 'chat_message_entity.freezed.dart';
part 'chat_message_entity.g.dart';

@freezed
class ChatMessageEntity with _$ChatMessageEntity {
  const factory ChatMessageEntity({
    required String id,
    required String userId,
    required String channelId,
    required String content,
    required MessageType type,
    @Default(MessageStatus.sent) MessageStatus status,
    required DateTime timestamp,
  }) = _ChatMessageEntity;

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageEntityFromJson(json);
}