import 'package:equatable/equatable.dart';

abstract class ProveedoresEvent extends Equatable {
  const ProveedoresEvent();

  @override
  List<Object?> get props => [];
}

class LoadProveedores extends ProveedoresEvent {
  const LoadProveedores();
}

class CreateProveedor extends ProveedoresEvent {
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final String? direccion;

  const CreateProveedor({
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.direccion,
  });

  @override
  List<Object?> get props => [nombre, contacto, telefono, email, direccion];
}

class UpdateProveedor extends ProveedoresEvent {
  final String id;
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final bool activo;

  const UpdateProveedor({
    required this.id,
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.direccion,
    required this.activo,
  });

  @override
  List<Object?> get props => [
    id,
    nombre,
    contacto,
    telefono,
    email,
    direccion,
    activo,
  ];
}

class DeleteProveedor extends ProveedoresEvent {
  final String id;

  const DeleteProveedor(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleProveedorEstado extends ProveedoresEvent {
  final String id;
  final bool activo;

  const ToggleProveedorEstado({required this.id, required this.activo});

  @override
  List<Object?> get props => [id, activo];
}
