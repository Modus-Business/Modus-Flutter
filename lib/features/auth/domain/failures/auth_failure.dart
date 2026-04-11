enum AuthFailureType {
  invalidCredentials,
  network,
  server,
  configuration,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.type = AuthFailureType.unknown});

  final String message;
  final AuthFailureType type;

  @override
  String toString() => 'AuthFailure(type: $type, message: $message)';
}
