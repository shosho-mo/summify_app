import '../repositories/chat_repository.dart';
import '../entities/chat_message.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository); // الـ Constructor لازم يكون موجود

  Future<ChatMessage> call(String prompt) async {
    return await repository.getChatResponse(prompt);
  }
}
