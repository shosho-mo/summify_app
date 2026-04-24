import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message_usecase.dart';

// --- States Definition ---
abstract class ChatState {
  final List<ChatMessage> messages;
  ChatState(this.messages);
}

class ChatInitial extends ChatState {
  ChatInitial() : super([]);
}

class ChatLoading extends ChatState {
  ChatLoading(super.messages);
}

class ChatSuccess extends ChatState {
  ChatSuccess(super.messages);
}

class ChatError extends ChatState {
  final String errorMessage;
  ChatError(super.messages, this.errorMessage);
}

// --- Cubit Logic ---
class ChatCubit extends Cubit<ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final List<ChatMessage> _messages = [];

  ChatCubit(this.sendMessageUseCase) : super(ChatInitial());

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. إضافة رسالة المستخدم فوراً
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    emit(ChatLoading(List.from(_messages)));

    try {
      // 2. طلب الرد الحقيقي من الـ AI
      final aiResponse = await sendMessageUseCase(text);

      // 3. إضافة رد الـ AI للقائمة
      _messages.add(aiResponse);
      emit(ChatSuccess(List.from(_messages)));
    } catch (e) {
      // 4. طباعة الخطأ في الـ Console للتشخيص
      print('خطأ الـ API الحقيقي: $e');

      // 5. إرسال حالة الخطأ مع الاحتفاظ بالرسائل السابقة
      emit(ChatError(List.from(_messages),
          'حدث خطأ في الاتصال بـ Summify: ${e.toString()}'));
    }
  }

  void clearChat() {
    _messages.clear();
    emit(ChatInitial());
  }
}
