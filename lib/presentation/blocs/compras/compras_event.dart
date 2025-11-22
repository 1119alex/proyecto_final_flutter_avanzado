import 'package:equatable/equatable.dart';

abstract class ComprasEvent extends Equatable {
  const ComprasEvent();

  @override
  List<Object?> get props => [];
}

class LoadCompras extends ComprasEvent {
  const LoadCompras();
}

class LoadComprasByAlmacen extends ComprasEvent {
  final String almacenId;

  const LoadComprasByAlmacen(this.almacenId);

  @override
  List<Object?> get props => [almacenId];
}

class LoadComprasByFecha extends ComprasEvent {
  final DateTime inicio;
  final DateTime fin;

  const LoadComprasByFecha({required this.inicio, required this.fin});

  @override
  List<Object?> get props => [inicio, fin];
}

class LoadCompraDetalle extends ComprasEvent {
  final String compraId;

  const LoadCompraDetalle(this.compraId);

  @override
  List<Object?> get props => [compraId];
}

class CreateCompra extends ComprasEvent {
  final String proveedorId;
  final String almacenId;
  final String usuarioId;
  final String? observaciones;
  final List<CompraDetalleItem> detalles;

  const CreateCompra({
    required this.proveedorId,
    required this.almacenId,
    required this.usuarioId,
    this.observaciones,
    required this.detalles,
  });

  @override
  List<Object?> get props => [
    proveedorId,
    almacenId,
    usuarioId,
    observaciones,
    detalles,
  ];
}

class CancelCompra extends ComprasEvent {
  final String id;

  const CancelCompra(this.id);

  @override
  List<Object?> get props => [id];
}

/// Clase auxiliar para detalles de compra en eventos
class CompraDetalleItem {
  final String productoId;
  final String? varianteId;
  final int cantidad;
  final double precioUnitario;

  const CompraDetalleItem({
    required this.productoId,
    this.varianteId,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => precioUnitario * cantidad;
}
