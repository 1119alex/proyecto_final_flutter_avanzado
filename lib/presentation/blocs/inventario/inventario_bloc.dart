import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/inventario_repository.dart';
import 'inventario_event.dart';
import 'inventario_state.dart';

class InventarioBloc extends Bloc<InventarioEvent, InventarioState> {
  final InventarioRepository _repository;

  InventarioBloc(this._repository) : super(const InventarioInitial()) {
    on<LoadInventario>(_onLoadInventario);
    on<LoadInventarioByTienda>(_onLoadInventarioByTienda);
    on<LoadInventarioByAlmacen>(_onLoadInventarioByAlmacen);
    on<LoadInventarioByProducto>(_onLoadInventarioByProducto);
    on<LoadProductosStockBajo>(_onLoadProductosStockBajo);
    on<CreateInventario>(_onCreateInventario);
    on<UpdateInventarioCantidad>(_onUpdateInventarioCantidad);
    on<AjustarInventario>(_onAjustarInventario);
    on<DeleteInventario>(_onDeleteInventario);
  }

  Future<void> _onLoadInventario(
    LoadInventario event,
    Emitter<InventarioState> emit,
  ) async {
    try {
      emit(const InventarioLoading());
      final items = await _repository.getAllInventario();
      emit(InventarioLoaded(items));
    } catch (e) {
      emit(InventarioError('Error al cargar inventario: ${e.toString()}'));
    }
  }

  Future<void> _onLoadInventarioByTienda(
    LoadInventarioByTienda event,
    Emitter<InventarioState> emit,
  ) async {
    try {
      emit(const InventarioLoading());
      final items = await _repository.getInventarioByTienda(event.tiendaId);
      emit(InventarioLoaded(items, filtroTiendaId: event.tiendaId));
    } catch (e) {
      emit(InventarioError('Error al cargar inventario: ${e.toString()}'));
    }
  }

  Future<void> _onLoadInventarioByAlmacen(
    LoadInventarioByAlmacen event,
    Emitter<InventarioState> emit,
  ) async {
    try {
      emit(const InventarioLoading());
      final items = await _repository.getInventarioByAlmacen(event.almacenId);
      emit(InventarioLoaded(items, filtroAlmacenId: event.almacenId));
    } catch (e) {
      emit(InventarioError('Error al cargar inventario: ${e.toString()}'));
    }
  }

  Future<void> _onLoadInventarioByProducto(
    LoadInventarioByProducto event,
    Emitter<InventarioState> emit,
  ) async {
    try {
      emit(const InventarioLoading());
      // Este evento carga solo los registros de inventario, no detallados
      final items = await _repository.getAllInventario();
      final filtered = items
          .where((i) => i.producto.id == event.productoId)
          .toList();
      emit(InventarioLoaded(filtered));
    } catch (e) {
      emit(InventarioError('Error al cargar inventario: ${e.toString()}'));
    }
  }

  Future<void> _onLoadProductosStockBajo(
    LoadProductosStockBajo event,
    Emitter<InventarioState> emit,
  ) async {
    try {
      emit(const InventarioLoading());
      final items = await _repository.getProductosStockBajo();
      emit(ProductosStockBajoLoaded(items));
    } catch (e) {
      emit(
        InventarioError(
          'Error al cargar productos con stock bajo: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onCreateInventario(
    CreateInventario event,
    Emitter<InventarioState> emit,
  ) async {
    try {
      final success = await _repository.createInventario(
        productoId: event.productoId,
        varianteId: event.varianteId,
        tiendaId: event.tiendaId,
        almacenId: event.almacenId,
        cantidad: event.cantidad,
      );

      if (success) {
        emit(const InventarioCreated());
        final items = await _repository.getAllInventario();
        emit(InventarioLoaded(items));
      } else {
        emit(
          const InventarioError('No se pudo crear el registro de inventario'),
        );
      }
    } catch (e) {
      emit(InventarioError('Error al crear inventario: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateInventarioCantidad(
    UpdateInventarioCantidad event,
    Emitter<InventarioState> emit,
  ) async {
    try {
      final success = await _repository.updateCantidad(
        event.id,
        event.cantidad,
      );

      if (success) {
        emit(const InventarioUpdated());
        final items = await _repository.getAllInventario();
        emit(InventarioLoaded(items));
      } else {
        emit(const InventarioError('No se pudo actualizar el inventario'));
      }
    } catch (e) {
      emit(InventarioError('Error al actualizar inventario: ${e.toString()}'));
    }
  }

  Future<void> _onAjustarInventario(
    AjustarInventario event,
    Emitter<InventarioState> emit,
  ) async {
    try {
      final success = await _repository.ajustarInventario(
        event.id,
        event.ajuste,
      );

      if (success) {
        emit(const InventarioUpdated());
        final items = await _repository.getAllInventario();
        emit(InventarioLoaded(items));
      } else {
        emit(
          const InventarioError(
            'No se pudo ajustar el inventario. Verifique que la cantidad resultante no sea negativa.',
          ),
        );
      }
    } catch (e) {
      emit(InventarioError('Error al ajustar inventario: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteInventario(
    DeleteInventario event,
    Emitter<InventarioState> emit,
  ) async {
    try {
      final success = await _repository.deleteInventario(event.id);

      if (success) {
        emit(const InventarioDeleted());
        final items = await _repository.getAllInventario();
        emit(InventarioLoaded(items));
      } else {
        emit(
          const InventarioError(
            'No se pudo eliminar el registro de inventario',
          ),
        );
      }
    } catch (e) {
      emit(InventarioError('Error al eliminar inventario: ${e.toString()}'));
    }
  }
}
