import 'package:equatable/equatable.dart';
import '../../../data/local/database/app_database.dart';

abstract class ProductosState extends Equatable {
  const ProductosState();

  @override
  List<Object?> get props => [];
}

class ProductosInitial extends ProductosState {
  const ProductosInitial();
}

class ProductosLoading extends ProductosState {
  const ProductosLoading();
}

class ProductosLoaded extends ProductosState {
  final List<Producto> productos;
  final String? categoriaIdFiltro;

  const ProductosLoaded(this.productos, {this.categoriaIdFiltro});

  @override
  List<Object?> get props => [productos, categoriaIdFiltro];
}

class ProductosError extends ProductosState {
  final String message;

  const ProductosError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductoCreated extends ProductosState {
  const ProductoCreated();
}

class ProductoUpdated extends ProductosState {
  const ProductoUpdated();
}

class ProductoDeleted extends ProductosState {
  const ProductoDeleted();
}
