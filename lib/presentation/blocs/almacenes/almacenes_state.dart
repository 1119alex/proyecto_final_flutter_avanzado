import 'package:equatable/equatable.dart';
import '../../../data/local/database/app_database.dart';

abstract class AlmacenesState extends Equatable {
  const AlmacenesState();

  @override
  List<Object?> get props => [];
}

class AlmacenesInitial extends AlmacenesState {
  const AlmacenesInitial();
}

class AlmacenesLoading extends AlmacenesState {
  const AlmacenesLoading();
}

class AlmacenesLoaded extends AlmacenesState {
  final List<Almacen> almacenes;

  const AlmacenesLoaded(this.almacenes);

  @override
  List<Object?> get props => [almacenes];
}

class AlmacenesError extends AlmacenesState {
  final String message;

  const AlmacenesError(this.message);

  @override
  List<Object?> get props => [message];
}

class AlmacenCreated extends AlmacenesState {
  const AlmacenCreated();
}

class AlmacenUpdated extends AlmacenesState {
  const AlmacenUpdated();
}

class AlmacenDeleted extends AlmacenesState {
  const AlmacenDeleted();
}
