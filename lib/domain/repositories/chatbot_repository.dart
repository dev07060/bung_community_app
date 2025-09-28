import 'package:our_bung_play/domain/entities/chat_message_entity.dart';

abstract class ChatbotRepository {
  Future<String> askQuestion(String channelId, String question);
  Future<List<ChatMessageEntity>> getChatHistory(String userId, String channelId);
  Future<void> saveChatMessage(ChatMessageEntity message);
}
