import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/di/injection.dart';
import '../local/daos/compra_dao.dart';
import '../local/database/app_database.dart';
import '../sync/sync_service.dart';

class ComprasRepository {
  final CompraDao _compraDao;

  // Lazy getter para SyncService
  SyncService get _syncService => getIt<SyncService>();

  ComprasRepository(this._compraDao);

  // ==================== COMPRAS ====================

  Future<List<Compra>> getAllCompras() async {
    return await _compraDao.getAllCompras();
  }

  Future<List<Compra>> getComprasByAlmacen(String almacenId) async {
    return await _compraDao.getComprasByAlmacen(almacenId);
  }

  Future<List<Compra>> getComprasByFecha(DateTime inicio, DateTime fin) async {
    return await _compraDao.getComprasByFecha(inicio, fin);
  }

  Future<Compra?> getCompraById(String id) async {
    return await _compraDao.getCompraById(id);
  }

  Future<List<CompraDetalle>> getDetallesByCompra(String compraId) async {
    return await _compraDao.getDetallesByCompra(compraId);
  }

  Future<Proveedor?> getProveedorById(String proveedorId) async {
    return await _compraDao.getProveedorById(proveedorId);
  }

  /// Crear una compra completa con sus detalles
  Future<String?> createCompra({
    required String proveedorId,
    required String almacenId,
    required String usuarioId,
    String? observaciones,
    required List<CompraDetalleData> detalles,
  }) async {
    try {
      final compraId = const Uuid().v4();
      final now = DateTime.now();

      // Calcular total
      double totalCompra = 0;
      for (final d in detalles) {
        totalCompra += d.subtotal;
      }

      // Crear la compra
      final compraCompanion = ComprasCompanion(
        id: Value(compraId),
        proveedorId: Value(proveedorId),
        almacenId: Value(almacenId),
        usuarioId: Value(usuarioId),
        fecha: Value(now),
        total: Value(totalCompra),
        observaciones: Value(observaciones),
        estado: const Value('completada'),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pendiente'),
      );

      await _compraDao.insertCompra(compraCompanion);

      // Crear los detalles
      final detallesCompanion = <CompraDetallesCompanion>[];
      for (final d in detalles) {
        final detalleId = const Uuid().v4();
        detallesCompanion.add(
          CompraDetallesCompanion(
            id: Value(detalleId),
            compraId: Value(compraId),
            productoId: Value(d.productoId),
            varianteId: Value(d.varianteId),
            cantidad: Value(d.cantidad),
            precioUnitario: Value(d.precioUnitario),
            subtotal: Value(d.subtotal),
          ),
        );
      }

      await _compraDao.insertDetalles(detallesCompanion);

      // Encolar para sincronizacion
      await _syncService.queueOperation(
        tableName: 'compras',
        recordId: compraId,
        operation: 'insert',
        data: {
          'id': compraId,
          'proveedor_id': proveedorId,
          'almacen_id': almacenId,
          'usuario_id': usuarioId,
          'fecha': now.toIso8601String(),
          'total': totalCompra,
          'observaciones': observaciones,
          'estado': 'completada',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );

      // Encolar detalles
      for (int i = 0; i < detalles.length; i++) {
        final d = detalles[i];
        final detalleId = detallesCompanion[i].id.value;
        await _syncService.queueOperation(
          tableName: 'compra_detalles',
          recordId: detalleId,
          operation: 'insert',
          data: {
            'id': detalleId,
            'compra_id': compraId,
            'producto_id': d.productoId,
            'variante_id': d.varianteId,
            'cantidad': d.cantidad,
            'precio_unitario': d.precioUnitario,
            'subtotal': d.subtotal,
            'created_at': now.toIso8601String(),
          },
        );
      }

      return compraId;
    } catch (e) {
      return null;
    }
  }

  /// Cancelar una compra
  Future<bool> cancelCompra(String id) async {
    try {
      final now = DateTime.now();

      await _compraDao.updateCompra(
        id,
        ComprasCompanion(
          estado: const Value('cancelada'),
          updatedAt: Value(now),
          syncStatus: const Value('pendiente'),
        ),
      );

      await _syncService.queueOperation(
        tableName: 'compras',
        recordId: id,
        operation: 'update',
        data: {'estado': 'cancelada', 'updated_at': now.toIso8601String()},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Calcular total de compras en un rango
  Future<double> calcularTotalCompras(List<Compra> compras) async {
    double total = 0;
    for (final c in compras) {
      if (c.estado != 'cancelada') {
        total += c.total;
      }
    }
    return total;
  }
}

/// Clase auxiliar para datos de detalle de compra
class CompraDetalleData {
  final String productoId;
  final String? varianteId;
  final int cantidad;
  final double precioUnitario;

  CompraDetalleData({
    required this.productoId,
    this.varianteId,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => precioUnitario * cantidad;
}
