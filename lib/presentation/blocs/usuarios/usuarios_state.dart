import 'package:equatable/equatable.dart';
import '../../../data/local/database/app_database.dart';

abstract class UsuariosState extends Equatable {
  const UsuariosState();

  @override
  List<Object?> get props => [];
}

class UsuariosInitial extends UsuariosState {
  const UsuariosInitial();
}

class UsuariosLoading extends UsuariosState {
  const UsuariosLoading();
}

class UsuariosLoaded extends UsuariosState {
  final List<Usuario> usuarios;
  final Map<String, int> conteoPorRol;
  final String? filtroRol;
  final String? filtroTienda;

  const UsuariosLoaded(
    this.usuarios, {
    this.conteoPorRol = const {},
    this.filtroRol,
    this.filtroTienda,
  });

  @override
  List<Object?> get props => [usuarios, conteoPorRol, filtroRol, filtroTienda];
}

class UsuariosError extends UsuariosState {
  final String message;

  const UsuariosError(this.message);

  @override
  List<Object?> get props => [message];
}

class UsuarioCreated extends UsuariosState {
  final String usuarioId;

  const UsuarioCreated(this.usuarioId);

  @override
  List<Object?> get props => [usuarioId];
}

class UsuarioUpdated extends UsuariosState {
  const UsuarioUpdated();
}

class UsuarioDeleted extends UsuariosState {
  const UsuarioDeleted();
}
