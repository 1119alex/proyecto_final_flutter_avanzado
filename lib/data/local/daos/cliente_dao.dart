import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'cliente_dao.g.dart';

@DriftAccessor(tables: [Clientes])
class ClienteDao extends DatabaseAccessor<AppDatabase> with _$ClienteDaoMixin {
  ClienteDao(super.db);

  // Obtener todos los clientes activos
  Future<List<Cliente>> getAllClientes() {
    return (select(clientes)
          ..where((c) => c.activo.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.nombre)]))
        .get();
  }

  // Obtener todos los clientes (incluyendo inactivos)
  Future<List<Cliente>> getAllClientesIncluyendoInactivos() {
    return (select(
      clientes,
    )..orderBy([(c) => OrderingTerm.asc(c.nombre)])).get();
  }

  // Obtener cliente por ID
  Future<Cliente?> getClienteById(String id) {
    return (select(clientes)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  // Obtener cliente por NIT
  Future<Cliente?> getClienteByNit(String nit) {
    return (select(
      clientes,
    )..where((c) => c.nit.equals(nit))).getSingleOrNull();
  }

  // Buscar clientes por nombre o NIT
  Future<List<Cliente>> searchClientes(String query) {
    final searchPattern = '%$query%';
    return (select(clientes)
          ..where(
            (c) =>
                c.activo.equals(true) &
                (c.nombre.like(searchPattern) | c.nit.like(searchPattern)),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.nombre)]))
        .get();
  }

  // Insertar cliente
  Future<int> insertCliente(ClientesCompanion cliente) {
    return into(clientes).insert(cliente);
  }

  // Actualizar cliente
  Future<bool> updateCliente(ClientesCompanion cliente) {
    return update(clientes).replace(cliente);
  }

  // Eliminar cliente (soft delete)
  Future<int> softDeleteCliente(String id) {
    return (update(clientes)..where((c) => c.id.equals(id))).write(
      ClientesCompanion(
        activo: const Value(false),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pendiente'),
      ),
    );
  }

  // Eliminar cliente permanentemente
  Future<int> deleteCliente(String id) {
    return (delete(clientes)..where((c) => c.id.equals(id))).go();
  }

  // Obtener clientes pendientes de sincronización
  Future<List<Cliente>> getClientesPendientes() {
    return (select(
      clientes,
    )..where((c) => c.syncStatus.equals('pendiente'))).get();
  }

  // Marcar cliente como sincronizado
  Future<int> marcarComoSincronizado(String id) {
    return (update(clientes)..where((c) => c.id.equals(id))).write(
      const ClientesCompanion(syncStatus: Value('sincronizado')),
    );
  }

  // Stream de clientes para actualizaciones en tiempo real
  Stream<List<Cliente>> watchAllClientes() {
    return (select(clientes)
          ..where((c) => c.activo.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.nombre)]))
        .watch();
  }
}
