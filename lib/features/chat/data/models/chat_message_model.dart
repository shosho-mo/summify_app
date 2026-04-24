import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required super.id,
    required super.text,
    required super.isUser,
    required super.timestamp,
  });

  // تأكدي إن الجزء ده مكتوب بالظبط كدة
  factory ChatMessageModel.fromAI(String text) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // توليد ID فريد
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
