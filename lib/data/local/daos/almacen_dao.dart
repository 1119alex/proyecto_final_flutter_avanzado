import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'almacen_dao.g.dart';

@DriftAccessor(tables: [Almacenes])
class AlmacenDao extends DatabaseAccessor<AppDatabase> with _$AlmacenDaoMixin {
  AlmacenDao(super.db);

  // Obtener todos los almacenes activos
  Future<List<Almacen>> getAllAlmacenes() {
    return (select(almacenes)
          ..where((a) => a.activo.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.nombre)]))
        .get();
  }

  // Obtener almacén por ID
  Future<Almacen?> getAlmacenById(String id) {
    return (select(almacenes)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  // Insertar almacén
  Future<int> insertAlmacen(AlmacenesCompanion almacen) {
    return into(almacenes).insert(almacen);
  }

  // Actualizar almacén
  Future<bool> updateAlmacen(AlmacenesCompanion almacen) {
    return update(almacenes).replace(
      Almacen(
        id: almacen.id.value,
        nombre: almacen.nombre.value,
        direccion: almacen.direccion.value,
        telefono: almacen.telefono.value,
        activo: almacen.activo.value,
        createdAt: almacen.createdAt.value,
        updatedAt: DateTime.now(),
        syncStatus: almacen.syncStatus.value,
      ),
    );
  }

  // Eliminar almacén (soft delete)
  Future<int> deleteAlmacen(String id) {
    return (update(almacenes)..where((a) => a.id.equals(id))).write(
      const AlmacenesCompanion(activo: Value(false)),
    );
  }

  // Obtener almacenes pendientes de sincronizar
  Future<List<Almacen>> getPendingSync() {
    return (select(
      almacenes,
    )..where((a) => a.syncStatus.equals('pendiente'))).get();
  }

  // Marcar como sincronizado
  Future<int> markAsSynced(String id) {
    return (update(almacenes)..where((a) => a.id.equals(id))).write(
      AlmacenesCompanion(
        syncStatus: const Value('sincronizado'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Stream de almacenes para actualizaciones en tiempo real
  Stream<List<Almacen>> watchAllAlmacenes() {
    return (select(almacenes)
          ..where((a) => a.activo.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.nombre)]))
        .watch();
  }
}
