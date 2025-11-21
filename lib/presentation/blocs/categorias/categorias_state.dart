import 'package:equatable/equatable.dart';
import '../../../data/local/database/app_database.dart';

abstract class CategoriasState extends Equatable {
  const CategoriasState();

  @override
  List<Object?> get props => [];
}

class CategoriasInitial extends CategoriasState {
  const CategoriasInitial();
}

class CategoriasLoading extends CategoriasState {
  const CategoriasLoading();
}

class CategoriasLoaded extends CategoriasState {
  final List<Categoria> categorias;

  const CategoriasLoaded(this.categorias);

  @override
  List<Object?> get props => [categorias];
}

class CategoriasError extends CategoriasState {
  final String message;

  const CategoriasError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoriaCreated extends CategoriasState {
  const CategoriaCreated();
}

class CategoriaUpdated extends CategoriasState {
  const CategoriaUpdated();
}

class CategoriaDeleted extends CategoriasState {
  const CategoriaDeleted();
}
