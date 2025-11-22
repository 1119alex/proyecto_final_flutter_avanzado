import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'proveedor_dao.g.dart';

@DriftAccessor(tables: [Proveedores])
class ProveedorDao extends DatabaseAccessor<AppDatabase>
    with _$ProveedorDaoMixin {
  ProveedorDao(super.db);

  // Obtener todos los proveedores activos
  Future<List<Proveedor>> getAllProveedores() {
    return (select(proveedores)
          ..where((p) => p.activo.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
        .get();
  }

  // Obtener proveedor por ID
  Future<Proveedor?> getProveedorById(String id) {
    return (select(
      proveedores,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  // Insertar proveedor
  Future<int> insertProveedor(ProveedoresCompanion proveedor) {
    return into(proveedores).insert(proveedor);
  }

  // Actualizar proveedor
  Future<bool> updateProveedor(ProveedoresCompanion proveedor) {
    return update(proveedores).replace(
      Proveedor(
        id: proveedor.id.value,
        nombre: proveedor.nombre.value,
        contacto: proveedor.contacto.value,
        telefono: proveedor.telefono.value,
        email: proveedor.email.value,
        direccion: proveedor.direccion.value,
        activo: proveedor.activo.value,
        createdAt: proveedor.createdAt.value,
        updatedAt: DateTime.now(),
        syncStatus: proveedor.syncStatus.value,
      ),
    );
  }

  // Eliminar proveedor (soft delete)
  Future<int> deleteProveedor(String id) {
    return (update(proveedores)..where((p) => p.id.equals(id))).write(
      const ProveedoresCompanion(activo: Value(false)),
    );
  }

  // Obtener proveedores pendientes de sincronizar
  Future<List<Proveedor>> getPendingSync() {
    return (select(
      proveedores,
    )..where((p) => p.syncStatus.equals('pendiente'))).get();
  }

  // Marcar como sincronizado
  Future<int> markAsSynced(String id) {
    return (update(proveedores)..where((p) => p.id.equals(id))).write(
      ProveedoresCompanion(
        syncStatus: const Value('sincronizado'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Stream de proveedores para actualizaciones en tiempo real
  Stream<List<Proveedor>> watchAllProveedores() {
    return (select(proveedores)
          ..where((p) => p.activo.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
        .watch();
  }
}
