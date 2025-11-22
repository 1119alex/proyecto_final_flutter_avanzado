import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'tienda_dao.g.dart';

@DriftAccessor(tables: [Tiendas])
class TiendaDao extends DatabaseAccessor<AppDatabase> with _$TiendaDaoMixin {
  TiendaDao(super.db);

  // Obtener todas las tiendas activas
  Future<List<Tienda>> getAllTiendas() {
    return (select(tiendas)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .get();
  }

  // Obtener tienda por ID
  Future<Tienda?> getTiendaById(String id) {
    return (select(tiendas)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // Insertar tienda
  Future<int> insertTienda(TiendasCompanion tienda) {
    return into(tiendas).insert(tienda);
  }

  // Actualizar tienda
  Future<bool> updateTienda(TiendasCompanion tienda) {
    return update(tiendas).replace(
      Tienda(
        id: tienda.id.value,
        nombre: tienda.nombre.value,
        direccion: tienda.direccion.value,
        telefono: tienda.telefono.value,
        activo: tienda.activo.value,
        createdAt: tienda.createdAt.value,
        updatedAt: DateTime.now(),
        syncStatus: tienda.syncStatus.value,
      ),
    );
  }

  // Eliminar tienda (soft delete)
  Future<int> deleteTienda(String id) {
    return (update(tiendas)..where((t) => t.id.equals(id))).write(
      const TiendasCompanion(activo: Value(false)),
    );
  }

  // Obtener tiendas pendientes de sincronizar
  Future<List<Tienda>> getPendingSync() {
    return (select(
      tiendas,
    )..where((t) => t.syncStatus.equals('pendiente'))).get();
  }

  // Marcar como sincronizado
  Future<int> markAsSynced(String id) {
    return (update(tiendas)..where((t) => t.id.equals(id))).write(
      TiendasCompanion(
        syncStatus: const Value('sincronizado'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Stream de tiendas para actualizaciones en tiempo real
  Stream<List<Tienda>> watchAllTiendas() {
    return (select(tiendas)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .watch();
  }
}
