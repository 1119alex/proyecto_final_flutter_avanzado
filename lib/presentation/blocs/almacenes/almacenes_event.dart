import 'package:equatable/equatable.dart';

abstract class AlmacenesEvent extends Equatable {
  const AlmacenesEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlmacenes extends AlmacenesEvent {
  const LoadAlmacenes();
}

class CreateAlmacen extends AlmacenesEvent {
  final String nombre;
  final String direccion;
  final String? telefono;

  const CreateAlmacen({
    required this.nombre,
    required this.direccion,
    this.telefono,
  });

  @override
  List<Object?> get props => [nombre, direccion, telefono];
}

class UpdateAlmacen extends AlmacenesEvent {
  final String id;
  final String nombre;
  final String direccion;
  final String? telefono;
  final bool activo;

  const UpdateAlmacen({
    required this.id,
    required this.nombre,
    required this.direccion,
    this.telefono,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, direccion, telefono, activo];
}

class DeleteAlmacen extends AlmacenesEvent {
  final String id;

  const DeleteAlmacen(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleAlmacenEstado extends AlmacenesEvent {
  final String id;
  final bool activo;

  const ToggleAlmacenEstado({required this.id, required this.activo});

  @override
  List<Object?> get props => [id, activo];
}
