class NoInternetException implements Exception {
  final String message;
  NoInternetException([this.message = 'No Internet Connection']);

  @override
  String toString() => message;
}

class InvalidCredentialsException implements Exception {
  final String message;
  InvalidCredentialsException([this.message = 'Invalid credentials']);

  @override
  String toString() => message;
}

class UnexpectedException implements Exception {
  final String message;
  UnexpectedException([this.message = 'Unexpected error occurred']);

  @override
  String toString() => message;
}

class GeneralException implements Exception {
  final String message;
  GeneralException([this.message = 'An error occurred']);

  @override
  String toString() => message;
}

class AuthRepositoryException implements Exception {
  final String message;
  AuthRepositoryException(this.message);

  @override
  String toString() => message;
}
