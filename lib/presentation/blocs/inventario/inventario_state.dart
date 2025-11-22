import 'package:equatable/equatable.dart';
import '../../../data/local/daos/inventario_dao.dart';

abstract class InventarioState extends Equatable {
  const InventarioState();

  @override
  List<Object?> get props => [];
}

class InventarioInitial extends InventarioState {
  const InventarioInitial();
}

class InventarioLoading extends InventarioState {
  const InventarioLoading();
}

class InventarioLoaded extends InventarioState {
  final List<InventarioDetallado> items;
  final String? filtroTiendaId;
  final String? filtroAlmacenId;

  const InventarioLoaded(
    this.items, {
    this.filtroTiendaId,
    this.filtroAlmacenId,
  });

  @override
  List<Object?> get props => [items, filtroTiendaId, filtroAlmacenId];
}

class ProductosStockBajoLoaded extends InventarioState {
  final List<InventarioConProducto> items;

  const ProductosStockBajoLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class InventarioError extends InventarioState {
  final String message;

  const InventarioError(this.message);

  @override
  List<Object?> get props => [message];
}

class InventarioCreated extends InventarioState {
  const InventarioCreated();
}

class InventarioUpdated extends InventarioState {
  const InventarioUpdated();
}

class InventarioDeleted extends InventarioState {
  const InventarioDeleted();
}
