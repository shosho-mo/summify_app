import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<ChatMessage> getChatResponse(String prompt);
}
