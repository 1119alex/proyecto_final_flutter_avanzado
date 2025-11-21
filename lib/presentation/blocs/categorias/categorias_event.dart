import 'package:equatable/equatable.dart';

abstract class CategoriasEvent extends Equatable {
  const CategoriasEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategorias extends CategoriasEvent {
  const LoadCategorias();
}

class CreateCategoria extends CategoriasEvent {
  final String nombre;
  final String? descripcion;
  final String? icono;

  const CreateCategoria({required this.nombre, this.descripcion, this.icono});

  @override
  List<Object?> get props => [nombre, descripcion, icono];
}

class UpdateCategoria extends CategoriasEvent {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? icono;
  final bool activo;

  const UpdateCategoria({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.icono,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, descripcion, icono, activo];
}

class DeleteCategoria extends CategoriasEvent {
  final String id;

  const DeleteCategoria(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleCategoriaEstado extends CategoriasEvent {
  final String id;
  final bool activo;

  const ToggleCategoriaEstado({required this.id, required this.activo});

  @override
  List<Object?> get props => [id, activo];
}
