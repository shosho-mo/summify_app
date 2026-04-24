import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// خطأ خاص بقاعدة البيانات (سوبابيز)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// خطأ خاص بالاتصال بالإنترنت
class ConnectionFailure extends Failure {
  const ConnectionFailure() : super('لا يوجد اتصال بالإنترنت');
}

// خطأ غير متوقع
class UnexpectedFailure extends Failure {
  const UnexpectedFailure() : super('حدث خطأ غير متوقع، حاول لاحقاً');
}
