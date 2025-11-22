import 'package:equatable/equatable.dart';
import '../../../data/local/database/app_database.dart';

abstract class ProveedoresState extends Equatable {
  const ProveedoresState();

  @override
  List<Object?> get props => [];
}

class ProveedoresInitial extends ProveedoresState {
  const ProveedoresInitial();
}

class ProveedoresLoading extends ProveedoresState {
  const ProveedoresLoading();
}

class ProveedoresLoaded extends ProveedoresState {
  final List<Proveedor> proveedores;

  const ProveedoresLoaded(this.proveedores);

  @override
  List<Object?> get props => [proveedores];
}

class ProveedoresError extends ProveedoresState {
  final String message;

  const ProveedoresError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProveedorCreated extends ProveedoresState {
  const ProveedorCreated();
}

class ProveedorUpdated extends ProveedoresState {
  const ProveedorUpdated();
}

class ProveedorDeleted extends ProveedoresState {
  const ProveedorDeleted();
}
