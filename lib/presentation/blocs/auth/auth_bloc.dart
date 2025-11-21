import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/auth_repository.dart';

// ==================== EVENTOS ====================
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nombre;
  final String apellido;
  final String rol;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    this.rol = 'vendedor',
  });

  @override
  List<Object?> get props => [email, password, nombre, apellido, rol];
}

class AuthLogoutRequested extends AuthEvent {}

// ==================== ESTADOS ====================
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final Map<String, dynamic>? userData;

  const AuthAuthenticated({required this.user, this.userData});

  @override
  List<Object?> get props => [user, userData];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      final result = await _authRepository.getCurrentUserData();
      result.fold(
        (failure) => emit(AuthAuthenticated(user: user)),
        (userData) => emit(AuthAuthenticated(user: user, userData: userData)),
      );
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signIn(
      email: event.email,
      password: event.password,
    );

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (user) async {
        final userDataResult = await _authRepository.getCurrentUserData();
        userDataResult.fold(
          (failure) => emit(AuthAuthenticated(user: user)),
          (userData) => emit(AuthAuthenticated(user: user, userData: userData)),
        );
      },
    );
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signUp(
      email: event.email,
      password: event.password,
      nombre: event.nombre,
      apellido: event.apellido,
      rol: event.rol,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }
}
