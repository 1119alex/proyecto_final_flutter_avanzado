/// Excepción de servidor
class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException({this.message = 'Error de servidor', this.code});

  @override
  String toString() => 'ServerException: $message (code: $code)';
}

/// Excepción de caché
class CacheException implements Exception {
  final String message;
  final String? code;

  CacheException({this.message = 'Error de caché', this.code});

  @override
  String toString() => 'CacheException: $message (code: $code)';
}

/// Excepción de conexión
class ConnectionException implements Exception {
  final String message;

  ConnectionException({this.message = 'Sin conexión a internet'});

  @override
  String toString() => 'ConnectionException: $message';
}

/// Excepción de autenticación
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({this.message = 'Error de autenticación', this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

/// Excepción de sincronización
class SyncException implements Exception {
  final String message;
  final String? code;

  SyncException({this.message = 'Error de sincronización', this.code});

  @override
  String toString() => 'SyncException: $message (code: $code)';
}
