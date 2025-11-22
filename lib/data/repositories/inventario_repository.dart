import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../local/database/app_database.dart';
import '../local/daos/inventario_dao.dart';
import '../sync/sync_service.dart';
import '../../core/di/injection.dart';

class InventarioRepository {
  final InventarioDao _inventarioDao;

  SyncService get _syncService => getIt<SyncService>();

  InventarioRepository(this._inventarioDao);

  Future<List<InventarioDetallado>> getAllInventario() async {
    return await _inventarioDao.getInventarioDetallado();
  }

  Future<List<InventarioDetallado>> getInventarioByTienda(
    String tiendaId,
  ) async {
    final all = await _inventarioDao.getInventarioDetallado();
    return all.where((i) => i.tienda?.id == tiendaId).toList();
  }

  Future<List<InventarioDetallado>> getInventarioByAlmacen(
    String almacenId,
  ) async {
    final all = await _inventarioDao.getInventarioDetallado();
    return all.where((i) => i.almacen?.id == almacenId).toList();
  }

  Future<List<InventarioData>> getInventarioByProducto(
    String productoId,
  ) async {
    return await _inventarioDao.getInventarioByProducto(productoId);
  }

  Future<List<InventarioConProducto>> getProductosStockBajo() async {
    return await _inventarioDao.getProductosStockBajo();
  }

  Future<int> getStockTotalProducto(String productoId) async {
    return await _inventarioDao.getStockTotalProducto(productoId);
  }

  Future<bool> createInventario({
    required String productoId,
    String? varianteId,
    String? tiendaId,
    String? almacenId,
    required int cantidad,
  }) async {
    try {
      // Verificar si ya existe un registro para esta combinacion
      final existente = await _inventarioDao.getInventarioByProductoYUbicacion(
        productoId: productoId,
        tiendaId: tiendaId,
        almacenId: almacenId,
        varianteId: varianteId,
      );

      if (existente != null) {
        // Si existe, actualizar cantidad
        return await updateCantidad(
          existente.id,
          existente.cantidad + cantidad,
        );
      }

      final id = const Uuid().v4();
      final now = DateTime.now();

      final inv = InventarioCompanion(
        id: Value(id),
        productoId: Value(productoId),
        varianteId: Value(varianteId),
        tiendaId: Value(tiendaId),
        almacenId: Value(almacenId),
        cantidad: Value(cantidad),
        updatedAt: Value(now),
        syncStatus: const Value('pendiente'),
      );

      await _inventarioDao.insertInventario(inv);

      await _syncService.queueOperation(
        tableName: 'inventario',
        recordId: id,
        operation: 'insert',
        data: {
          'id': id,
          'producto_id': productoId,
          'variante_id': varianteId,
          'tienda_id': tiendaId,
          'almacen_id': almacenId,
          'cantidad': cantidad,
          'updated_at': now.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCantidad(String id, int cantidad) async {
    try {
      await _inventarioDao.updateCantidad(id, cantidad);

      await _syncService.queueOperation(
        tableName: 'inventario',
        recordId: id,
        operation: 'update',
        data: {
          'id': id,
          'cantidad': cantidad,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> ajustarInventario(String id, int ajuste) async {
    try {
      final inventario = await _inventarioDao.getInventarioById(id);
      if (inventario == null) return false;

      final nuevaCantidad = inventario.cantidad + ajuste;
      if (nuevaCantidad < 0) return false;

      return await updateCantidad(id, nuevaCantidad);
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteInventario(String id) async {
    try {
      await _inventarioDao.deleteInventario(id);

      await _syncService.queueOperation(
        tableName: 'inventario',
        recordId: id,
        operation: 'delete',
        data: {'id': id},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<InventarioData>> watchAllInventario() {
    return _inventarioDao.watchAllInventario();
  }
}
