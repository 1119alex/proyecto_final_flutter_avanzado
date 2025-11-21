import 'package:equatable/equatable.dart';

/// Clase base para errores de la aplicación
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Error de servidor/red
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Error de servidor', super.code});
}

/// Error de caché/base de datos local
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Error de caché local', super.code});
}

/// Error de conexión
class ConnectionFailure extends Failure {
  const ConnectionFailure({
    super.message = 'Sin conexión a internet',
    super.code,
  });
}

/// Error de autenticación
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Error de autenticación',
    super.code,
  });
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Error de validación',
    super.code,
  });
}

/// Error de sincronización
class SyncFailure extends Failure {
  const SyncFailure({
    super.message = 'Error de sincronización',
    super.code,
  });
}

/// Error no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Recurso no encontrado',
    super.code,
  });
}

/// Error de permisos
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'No tiene permisos para esta acción',
    super.code,
  });
}
