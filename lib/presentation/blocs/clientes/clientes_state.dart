import 'package:equatable/equatable.dart';
import '../../../data/local/database/app_database.dart';

abstract class ClientesState extends Equatable {
  const ClientesState();

  @override
  List<Object?> get props => [];
}

class ClientesInitial extends ClientesState {
  const ClientesInitial();
}

class ClientesLoading extends ClientesState {
  const ClientesLoading();
}

class ClientesLoaded extends ClientesState {
  final List<Cliente> clientes;

  const ClientesLoaded(this.clientes);

  @override
  List<Object?> get props => [clientes];
}

class ClientesError extends ClientesState {
  final String message;

  const ClientesError(this.message);

  @override
  List<Object?> get props => [message];
}

class ClienteCreated extends ClientesState {
  const ClienteCreated();
}

class ClienteUpdated extends ClientesState {
  const ClienteUpdated();
}

class ClienteDeleted extends ClientesState {
  const ClienteDeleted();
}
