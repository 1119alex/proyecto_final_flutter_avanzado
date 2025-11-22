import 'package:equatable/equatable.dart';

abstract class UsuariosEvent extends Equatable {
  const UsuariosEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsuarios extends UsuariosEvent {
  const LoadUsuarios();
}

class LoadUsuariosByRol extends UsuariosEvent {
  final String rol;

  const LoadUsuariosByRol(this.rol);

  @override
  List<Object?> get props => [rol];
}

class LoadUsuariosByTienda extends UsuariosEvent {
  final String tiendaId;

  const LoadUsuariosByTienda(this.tiendaId);

  @override
  List<Object?> get props => [tiendaId];
}

class CreateUsuario extends UsuariosEvent {
  final String id; // Viene de Supabase Auth
  final String email;
  final String nombre;
  final String apellido;
  final String rol;
  final String? tiendaId;
  final String? almacenId;

  const CreateUsuario({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.rol,
    this.tiendaId,
    this.almacenId,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    nombre,
    apellido,
    rol,
    tiendaId,
    almacenId,
  ];
}

class UpdateUsuario extends UsuariosEvent {
  final String id;
  final String? nombre;
  final String? apellido;
  final String? rol;
  final String? tiendaId;
  final String? almacenId;

  const UpdateUsuario({
    required this.id,
    this.nombre,
    this.apellido,
    this.rol,
    this.tiendaId,
    this.almacenId,
  });

  @override
  List<Object?> get props => [id, nombre, apellido, rol, tiendaId, almacenId];
}

class ToggleUsuarioActivo extends UsuariosEvent {
  final String id;
  final bool activo;

  const ToggleUsuarioActivo(this.id, this.activo);

  @override
  List<Object?> get props => [id, activo];
}

class DeleteUsuario extends UsuariosEvent {
  final String id;

  const DeleteUsuario(this.id);

  @override
  List<Object?> get props => [id];
}
