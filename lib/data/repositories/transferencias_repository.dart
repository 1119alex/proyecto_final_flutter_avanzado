import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/di/injection.dart';
import '../local/daos/transferencia_dao.dart';
import '../local/database/app_database.dart';
import '../sync/sync_service.dart';

class TransferenciasRepository {
  final TransferenciaDao _transferenciaDao;

  // Lazy getter para SyncService
  SyncService get _syncService => getIt<SyncService>();

  TransferenciasRepository(this._transferenciaDao);

  // ==================== TRANSFERENCIAS ====================

  Future<List<Transferencia>> getAllTransferencias() async {
    return await _transferenciaDao.getAllTransferencias();
  }

  Future<List<Transferencia>> getTransferenciasByEstado(String estado) async {
    return await _transferenciaDao.getTransferenciasByEstado(estado);
  }

  Future<List<Transferencia>> getTransferenciasByFecha(
    DateTime inicio,
    DateTime fin,
  ) async {
    return await _transferenciaDao.getTransferenciasByFecha(inicio, fin);
  }

  Future<Transferencia?> getTransferenciaById(String id) async {
    return await _transferenciaDao.getTransferenciaById(id);
  }

  Future<List<TransferenciaDetalle>> getDetallesByTransferencia(
    String transferenciaId,
  ) async {
    return await _transferenciaDao.getDetallesByTransferencia(transferenciaId);
  }

  /// Crear una transferencia completa con sus detalles
  Future<String?> createTransferencia({
    required String usuarioId,
    String? origenTiendaId,
    String? origenAlmacenId,
    String? destinoTiendaId,
    String? destinoAlmacenId,
    String? observaciones,
    required List<TransferenciaDetalleData> detalles,
  }) async {
    try {
      final transferenciaId = const Uuid().v4();
      final now = DateTime.now();

      // Crear la transferencia
      final transferenciaCompanion = TransferenciasCompanion(
        id: Value(transferenciaId),
        usuarioId: Value(usuarioId),
        origenTiendaId: Value(origenTiendaId),
        origenAlmacenId: Value(origenAlmacenId),
        destinoTiendaId: Value(destinoTiendaId),
        destinoAlmacenId: Value(destinoAlmacenId),
        fecha: Value(now),
        estado: const Value('pendiente'),
        observaciones: Value(observaciones),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pendiente'),
      );

      await _transferenciaDao.insertTransferencia(transferenciaCompanion);

      // Crear los detalles
      final detallesCompanion = <TransferenciaDetallesCompanion>[];
      for (final d in detalles) {
        final detalleId = const Uuid().v4();
        detallesCompanion.add(
          TransferenciaDetallesCompanion(
            id: Value(detalleId),
            transferenciaId: Value(transferenciaId),
            productoId: Value(d.productoId),
            varianteId: Value(d.varianteId),
            cantidad: Value(d.cantidad),
            createdAt: Value(now),
            syncStatus: const Value('pendiente'),
          ),
        );
      }

      await _transferenciaDao.insertDetalles(detallesCompanion);

      // Encolar para sincronizacion
      await _syncService.queueOperation(
        tableName: 'transferencias',
        recordId: transferenciaId,
        operation: 'insert',
        data: {
          'id': transferenciaId,
          'usuario_id': usuarioId,
          'origen_tienda_id': origenTiendaId,
          'origen_almacen_id': origenAlmacenId,
          'destino_tienda_id': destinoTiendaId,
          'destino_almacen_id': destinoAlmacenId,
          'fecha': now.toIso8601String(),
          'estado': 'pendiente',
          'observaciones': observaciones,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );

      // Encolar detalles
      for (int i = 0; i < detalles.length; i++) {
        final d = detalles[i];
        final detalleId = detallesCompanion[i].id.value;
        await _syncService.queueOperation(
          tableName: 'transferencia_detalles',
          recordId: detalleId,
          operation: 'insert',
          data: {
            'id': detalleId,
            'transferencia_id': transferenciaId,
            'producto_id': d.productoId,
            'variante_id': d.varianteId,
            'cantidad': d.cantidad,
            'created_at': now.toIso8601String(),
          },
        );
      }

      return transferenciaId;
    } catch (e) {
      return null;
    }
  }

  /// Actualizar estado de transferencia
  Future<bool> updateEstado(String id, String nuevoEstado) async {
    try {
      final now = DateTime.now();

      await _transferenciaDao.updateTransferencia(
        id,
        TransferenciasCompanion(
          estado: Value(nuevoEstado),
          updatedAt: Value(now),
          syncStatus: const Value('pendiente'),
        ),
      );

      await _syncService.queueOperation(
        tableName: 'transferencias',
        recordId: id,
        operation: 'update',
        data: {'estado': nuevoEstado, 'updated_at': now.toIso8601String()},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Completar transferencia (actualiza inventario)
  Future<bool> completarTransferencia(String id) async {
    return await updateEstado(id, 'completada');
  }

  /// Cancelar transferencia
  Future<bool> cancelarTransferencia(String id) async {
    return await updateEstado(id, 'cancelada');
  }

  /// Marcar en transito
  Future<bool> marcarEnTransito(String id) async {
    return await updateEstado(id, 'en_transito');
  }

  /// Contar transferencias por estado
  Future<Map<String, int>> contarPorEstado() async {
    final todas = await getAllTransferencias();
    final conteo = <String, int>{
      'pendiente': 0,
      'en_transito': 0,
      'completada': 0,
      'cancelada': 0,
    };

    for (final t in todas) {
      conteo[t.estado] = (conteo[t.estado] ?? 0) + 1;
    }

    return conteo;
  }
}

/// Clase auxiliar para datos de detalle de transferencia
class TransferenciaDetalleData {
  final String productoId;
  final String? varianteId;
  final int cantidad;

  TransferenciaDetalleData({
    required this.productoId,
    this.varianteId,
    required this.cantidad,
  });
}
