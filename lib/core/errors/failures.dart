// Failure types for error handling
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  AuthFailure(String message) : super(message);
} 