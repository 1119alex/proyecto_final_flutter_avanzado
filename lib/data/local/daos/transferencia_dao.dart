import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'transferencia_dao.g.dart';

@DriftAccessor(tables: [Transferencias, TransferenciaDetalles, Tiendas, Almacenes])
class TransferenciaDao extends DatabaseAccessor<AppDatabase> with _$TransferenciaDaoMixin {
  TransferenciaDao(super.db);

  // Obtener todas las transferencias
  Future<List<Transferencia>> getAllTransferencias() {
    return (select(transferencias)..orderBy([(t) => OrderingTerm.desc(t.fecha)])).get();
  }

  // Obtener transferencias por estado
  Future<List<Transferencia>> getTransferenciasByEstado(String estado) {
    return (select(transferencias)
          ..where((t) => t.estado.equals(estado))
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .get();
  }

  // Obtener transferencias por fecha
  Future<List<Transferencia>> getTransferenciasByFecha(DateTime inicio, DateTime fin) {
    return (select(transferencias)
          ..where((t) =>
              t.fecha.isBiggerOrEqualValue(inicio) &
              t.fecha.isSmallerOrEqualValue(fin))
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .get();
  }

  // Obtener transferencia por ID
  Future<Transferencia?> getTransferenciaById(String id) {
    return (select(transferencias)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // Insertar transferencia
  Future<int> insertTransferencia(TransferenciasCompanion transferencia) {
    return into(transferencias).insert(transferencia);
  }

  // Actualizar transferencia
  Future<int> updateTransferencia(String id, TransferenciasCompanion transferencia) {
    return (update(transferencias)..where((t) => t.id.equals(id))).write(transferencia);
  }

  // Actualizar estado de transferencia
  Future<int> updateEstado(String id, String nuevoEstado) {
    return (update(transferencias)..where((t) => t.id.equals(id))).write(
      TransferenciasCompanion(
        estado: Value(nuevoEstado),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pendiente'),
      ),
    );
  }

  // Stream de transferencias
  Stream<List<Transferencia>> watchTransferencias() {
    return (select(transferencias)..orderBy([(t) => OrderingTerm.desc(t.fecha)])).watch();
  }

  // ==================== DETALLES ====================

  // Obtener detalles por transferencia
  Future<List<TransferenciaDetalle>> getDetallesByTransferencia(String transferenciaId) {
    return (select(transferenciaDetalles)
          ..where((d) => d.transferenciaId.equals(transferenciaId)))
        .get();
  }

  // Insertar detalle
  Future<int> insertDetalle(TransferenciaDetallesCompanion detalle) {
    return into(transferenciaDetalles).insert(detalle);
  }

  // Insertar múltiples detalles
  Future<void> insertDetalles(List<TransferenciaDetallesCompanion> detalles) async {
    await batch((batch) {
      batch.insertAll(transferenciaDetalles, detalles.map((d) => TransferenciaDetalle(
        id: d.id.value,
        transferenciaId: d.transferenciaId.value,
        productoId: d.productoId.value,
        varianteId: d.varianteId.value,
        cantidad: d.cantidad.value,
        createdAt: DateTime.now(),
        syncStatus: 'pendiente',
      )).toList());
    });
  }

  // Obtener transferencias pendientes de sincronizar
  Future<List<Transferencia>> getPendingSync() {
    return (select(transferencias)
          ..where((t) => t.syncStatus.equals('pendiente')))
        .get();
  }

  // Marcar como sincronizado
  Future<int> markAsSynced(String id) {
    return (update(transferencias)..where((t) => t.id.equals(id))).write(
      TransferenciasCompanion(
        syncStatus: const Value('sincronizado'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
