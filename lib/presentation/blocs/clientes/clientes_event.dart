import 'package:equatable/equatable.dart';

abstract class ClientesEvent extends Equatable {
  const ClientesEvent();

  @override
  List<Object?> get props => [];
}

class LoadClientes extends ClientesEvent {
  const LoadClientes();
}

class SearchClientes extends ClientesEvent {
  final String query;

  const SearchClientes(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateCliente extends ClientesEvent {
  final String nombre;
  final String? nit;
  final String? telefono;
  final String? email;
  final String? direccion;

  const CreateCliente({
    required this.nombre,
    this.nit,
    this.telefono,
    this.email,
    this.direccion,
  });

  @override
  List<Object?> get props => [nombre, nit, telefono, email, direccion];
}

class UpdateCliente extends ClientesEvent {
  final String id;
  final String nombre;
  final String? nit;
  final String? telefono;
  final String? email;
  final String? direccion;
  final bool activo;

  const UpdateCliente({
    required this.id,
    required this.nombre,
    this.nit,
    this.telefono,
    this.email,
    this.direccion,
    required this.activo,
  });

  @override
  List<Object?> get props => [
    id,
    nombre,
    nit,
    telefono,
    email,
    direccion,
    activo,
  ];
}

class DeleteCliente extends ClientesEvent {
  final String id;

  const DeleteCliente(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleClienteEstado extends ClientesEvent {
  final String id;
  final bool activo;

  const ToggleClienteEstado({required this.id, required this.activo});

  @override
  List<Object?> get props => [id, activo];
}
