import 'package:equatable/equatable.dart';

abstract class ProductosEvent extends Equatable {
  const ProductosEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductos extends ProductosEvent {
  const LoadProductos();
}

class LoadProductosByCategoria extends ProductosEvent {
  final String categoriaId;

  const LoadProductosByCategoria(this.categoriaId);

  @override
  List<Object?> get props => [categoriaId];
}

class SearchProductos extends ProductosEvent {
  final String query;

  const SearchProductos(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateProducto extends ProductosEvent {
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String categoriaId;
  final double precioCompra;
  final double precioVenta;
  final String unidadMedida;
  final int stockMinimo;
  final String? imagenUrl;

  const CreateProducto({
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.categoriaId,
    required this.precioCompra,
    required this.precioVenta,
    this.unidadMedida = 'unidad',
    this.stockMinimo = 0,
    this.imagenUrl,
  });

  @override
  List<Object?> get props => [
    codigo,
    nombre,
    descripcion,
    categoriaId,
    precioCompra,
    precioVenta,
    unidadMedida,
    stockMinimo,
    imagenUrl,
  ];
}

class UpdateProducto extends ProductosEvent {
  final String id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String categoriaId;
  final double precioCompra;
  final double precioVenta;
  final String unidadMedida;
  final int stockMinimo;
  final String? imagenUrl;
  final bool activo;

  const UpdateProducto({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.categoriaId,
    required this.precioCompra,
    required this.precioVenta,
    this.unidadMedida = 'unidad',
    this.stockMinimo = 0,
    this.imagenUrl,
    required this.activo,
  });

  @override
  List<Object?> get props => [
    id,
    codigo,
    nombre,
    descripcion,
    categoriaId,
    precioCompra,
    precioVenta,
    unidadMedida,
    stockMinimo,
    imagenUrl,
    activo,
  ];
}

class DeleteProducto extends ProductosEvent {
  final String id;

  const DeleteProducto(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleProductoEstado extends ProductosEvent {
  final String id;
  final bool activo;

  const ToggleProductoEstado({required this.id, required this.activo});

  @override
  List<Object?> get props => [id, activo];
}
