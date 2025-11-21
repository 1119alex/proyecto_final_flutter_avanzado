import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Repositorio para autenticación
class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // Usuario actual
  User? get currentUser => _supabase.auth.currentUser;

  // Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Verificar si está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Iniciar sesión con email y contraseña
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Left(AuthFailure(message: 'No se pudo iniciar sesión'));
      }

      return Right(response.user!);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: _getAuthErrorMessage(e.message)));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Registrar nuevo usuario
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String rol = 'vendedor',
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'rol': rol,
        },
      );

      if (response.user == null) {
        return const Left(AuthFailure(message: 'No se pudo crear el usuario'));
      }

      return Right(response.user!);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: _getAuthErrorMessage(e.message)));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Cerrar sesión
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Recuperar contraseña
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: _getAuthErrorMessage(e.message)));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Obtener datos del usuario actual desde la tabla usuarios
  Future<Either<Failure, Map<String, dynamic>>> getCurrentUserData() async {
    try {
      if (currentUser == null) {
        return const Left(AuthFailure(message: 'No hay usuario autenticado'));
      }

      final response = await _supabase
          .from('usuarios')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Actualizar perfil del usuario
  Future<Either<Failure, void>> updateProfile({
    required String nombre,
    required String apellido,
  }) async {
    try {
      if (currentUser == null) {
        return const Left(AuthFailure(message: 'No hay usuario autenticado'));
      }

      await _supabase.from('usuarios').update({
        'nombre': nombre,
        'apellido': apellido,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentUser!.id);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Traducir mensajes de error de autenticación
  String _getAuthErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email o contraseña incorrectos';
    }
    if (message.contains('Email not confirmed')) {
      return 'Por favor confirma tu email antes de iniciar sesión';
    }
    if (message.contains('User already registered')) {
      return 'Este email ya está registrado';
    }
    if (message.contains('Password should be')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return message;
  }
}
