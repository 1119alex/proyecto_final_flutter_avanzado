import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/di/injection.dart';
import '../local/daos/venta_dao.dart';
import '../local/database/app_database.dart';
import '../sync/sync_service.dart';

class VentasRepository {
  final VentaDao _ventaDao;

  // Lazy getter para SyncService
  SyncService get _syncService => getIt<SyncService>();

  VentasRepository(this._ventaDao);

  // ==================== VENTAS ====================

  Future<List<Venta>> getAllVentas() async {
    return await _ventaDao.getAllVentas();
  }

  Future<List<Venta>> getVentasByTienda(String tiendaId) async {
    return await _ventaDao.getVentasByTienda(tiendaId);
  }

  Future<List<Venta>> getVentasByFecha(DateTime inicio, DateTime fin) async {
    return await _ventaDao.getVentasByFecha(inicio, fin);
  }

  Future<List<Venta>> getVentasHoy() async {
    return await _ventaDao.getVentasHoy();
  }

  Future<double> getTotalVentasHoy() async {
    return await _ventaDao.getTotalVentasHoy();
  }

  Future<Venta?> getVentaById(String id) async {
    return await _ventaDao.getVentaById(id);
  }

  Future<List<VentaDetalle>> getDetallesByVenta(String ventaId) async {
    return await _ventaDao.getDetallesByVenta(ventaId);
  }

  Future<Cliente?> getClienteById(String clienteId) async {
    return await _ventaDao.getClienteById(clienteId);
  }

  /// Crear una venta completa con sus detalles
  Future<String?> createVenta({
    String? clienteId,
    required String tiendaId,
    required String usuarioId,
    double descuento = 0,
    required String metodoPago,
    String? observaciones,
    required List<VentaDetalleData> detalles,
  }) async {
    try {
      final ventaId = const Uuid().v4();
      final now = DateTime.now();

      // Calcular subtotal y total
      double subtotalVenta = 0;
      for (final d in detalles) {
        subtotalVenta += d.subtotal;
      }
      final totalVenta = subtotalVenta - descuento;

      // Crear la venta
      final ventaCompanion = VentasCompanion(
        id: Value(ventaId),
        clienteId: Value(clienteId),
        tiendaId: Value(tiendaId),
        usuarioId: Value(usuarioId),
        fecha: Value(now),
        subtotal: Value(subtotalVenta),
        descuento: Value(descuento),
        total: Value(totalVenta),
        metodoPago: Value(metodoPago),
        estado: const Value('completada'),
        observaciones: Value(observaciones),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pendiente'),
      );

      await _ventaDao.insertVenta(ventaCompanion);

      // Crear los detalles
      final detallesCompanion = <VentaDetallesCompanion>[];
      for (final d in detalles) {
        final detalleId = const Uuid().v4();
        detallesCompanion.add(
          VentaDetallesCompanion(
            id: Value(detalleId),
            ventaId: Value(ventaId),
            productoId: Value(d.productoId),
            varianteId: Value(d.varianteId),
            cantidad: Value(d.cantidad),
            precioUnitario: Value(d.precioUnitario),
            descuento: Value(d.descuento),
            subtotal: Value(d.subtotal),
          ),
        );
      }

      await _ventaDao.insertDetalles(detallesCompanion);

      // Encolar para sincronizacion
      print('=== CREANDO VENTA ===');
      print('Venta ID: $ventaId');
      print('Tienda ID: $tiendaId');
      print('Usuario ID: $usuarioId');

      await _syncService.queueOperation(
        tableName: 'ventas',
        recordId: ventaId,
        operation: 'insert',
        data: {
          'id': ventaId,
          'cliente_id': clienteId,
          'tienda_id': tiendaId,
          'usuario_id': usuarioId,
          'fecha': now.toIso8601String(),
          'subtotal': subtotalVenta,
          'descuento': descuento,
          'total': totalVenta,
          'metodo_pago': metodoPago,
          'estado': 'completada',
          'observaciones': observaciones,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );
      print('Venta encolada para sync');

      // Encolar detalles
      for (int i = 0; i < detalles.length; i++) {
        final d = detalles[i];
        final detalleId = detallesCompanion[i].id.value;
        await _syncService.queueOperation(
          tableName: 'venta_detalles',
          recordId: detalleId,
          operation: 'insert',
          data: {
            'id': detalleId,
            'venta_id': ventaId,
            'producto_id': d.productoId,
            'variante_id': d.varianteId,
            'cantidad': d.cantidad,
            'precio_unitario': d.precioUnitario,
            'descuento': d.descuento,
            'subtotal': d.subtotal,
            'created_at': now.toIso8601String(),
          },
        );
      }

      return ventaId;
    } catch (e) {
      return null;
    }
  }

  /// Cancelar una venta
  Future<bool> cancelVenta(String id) async {
    try {
      final now = DateTime.now();

      await _ventaDao.updateVenta(
        id,
        VentasCompanion(
          estado: const Value('cancelada'),
          updatedAt: Value(now),
          syncStatus: const Value('pendiente'),
        ),
      );

      await _syncService.queueOperation(
        tableName: 'ventas',
        recordId: id,
        operation: 'update',
        data: {'estado': 'cancelada', 'updated_at': now.toIso8601String()},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Calcular total de ventas en un rango
  Future<double> calcularTotalVentas(List<Venta> ventas) async {
    double total = 0;
    for (final v in ventas) {
      if (v.estado != 'cancelada') {
        total += v.total;
      }
    }
    return total;
  }
}

/// Clase auxiliar para datos de detalle de venta
class VentaDetalleData {
  final String productoId;
  final String? varianteId;
  final int cantidad;
  final double precioUnitario;
  final double descuento;

  VentaDetalleData({
    required this.productoId,
    this.varianteId,
    required this.cantidad,
    required this.precioUnitario,
    this.descuento = 0,
  });

  double get subtotal => (precioUnitario * cantidad) - descuento;
}
