import 'package:equatable/equatable.dart';

abstract class InventarioEvent extends Equatable {
  const InventarioEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventario extends InventarioEvent {
  const LoadInventario();
}

class LoadInventarioByTienda extends InventarioEvent {
  final String tiendaId;

  const LoadInventarioByTienda(this.tiendaId);

  @override
  List<Object?> get props => [tiendaId];
}

class LoadInventarioByAlmacen extends InventarioEvent {
  final String almacenId;

  const LoadInventarioByAlmacen(this.almacenId);

  @override
  List<Object?> get props => [almacenId];
}

class LoadInventarioByProducto extends InventarioEvent {
  final String productoId;

  const LoadInventarioByProducto(this.productoId);

  @override
  List<Object?> get props => [productoId];
}

class LoadProductosStockBajo extends InventarioEvent {
  const LoadProductosStockBajo();
}

class CreateInventario extends InventarioEvent {
  final String productoId;
  final String? varianteId;
  final String? tiendaId;
  final String? almacenId;
  final int cantidad;

  const CreateInventario({
    required this.productoId,
    this.varianteId,
    this.tiendaId,
    this.almacenId,
    required this.cantidad,
  });

  @override
  List<Object?> get props => [
    productoId,
    varianteId,
    tiendaId,
    almacenId,
    cantidad,
  ];
}

class UpdateInventarioCantidad extends InventarioEvent {
  final String id;
  final int cantidad;

  const UpdateInventarioCantidad({required this.id, required this.cantidad});

  @override
  List<Object?> get props => [id, cantidad];
}

class AjustarInventario extends InventarioEvent {
  final String id;
  final int ajuste; // Puede ser positivo o negativo
  final String? motivo;

  const AjustarInventario({
    required this.id,
    required this.ajuste,
    this.motivo,
  });

  @override
  List<Object?> get props => [id, ajuste, motivo];
}

class DeleteInventario extends InventarioEvent {
  final String id;

  const DeleteInventario(this.id);

  @override
  List<Object?> get props => [id];
}
