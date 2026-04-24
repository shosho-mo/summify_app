abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  LoginSubmitted(this.email, this.password);
}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  RegisterSubmitted(this.email, this.password);
}
