import 'package:equatable/equatable.dart';

abstract class TiendasEvent extends Equatable {
  const TiendasEvent();

  @override
  List<Object?> get props => [];
}

class LoadTiendas extends TiendasEvent {
  const LoadTiendas();
}

class CreateTienda extends TiendasEvent {
  final String nombre;
  final String direccion;
  final String? telefono;

  const CreateTienda({
    required this.nombre,
    required this.direccion,
    this.telefono,
  });

  @override
  List<Object?> get props => [nombre, direccion, telefono];
}

class UpdateTienda extends TiendasEvent {
  final String id;
  final String nombre;
  final String direccion;
  final String? telefono;
  final bool activo;

  const UpdateTienda({
    required this.id,
    required this.nombre,
    required this.direccion,
    this.telefono,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, direccion, telefono, activo];
}

class DeleteTienda extends TiendasEvent {
  final String id;

  const DeleteTienda(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleTiendaEstado extends TiendasEvent {
  final String id;
  final bool activo;

  const ToggleTiendaEstado({required this.id, required this.activo});

  @override
  List<Object?> get props => [id, activo];
}
