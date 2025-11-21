import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'usuario_dao.g.dart';

@DriftAccessor(tables: [Usuarios, Tiendas, Almacenes])
class UsuarioDao extends DatabaseAccessor<AppDatabase> with _$UsuarioDaoMixin {
  UsuarioDao(super.db);

  // Obtener todos los usuarios activos
  Future<List<Usuario>> getAllUsuarios() {
    return (select(usuarios)
          ..where((u) => u.activo.equals(true))
          ..orderBy([(u) => OrderingTerm.asc(u.nombre)]))
        .get();
  }

  // Obtener usuario por ID
  Future<Usuario?> getUsuarioById(String id) {
    return (select(usuarios)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  // Obtener usuario por email
  Future<Usuario?> getUsuarioByEmail(String email) {
    return (select(usuarios)..where((u) => u.email.equals(email))).getSingleOrNull();
  }

  // Obtener usuarios por rol
  Future<List<Usuario>> getUsuariosByRol(String rol) {
    return (select(usuarios)
          ..where((u) => u.activo.equals(true) & u.rol.equals(rol))
          ..orderBy([(u) => OrderingTerm.asc(u.nombre)]))
        .get();
  }

  // Obtener usuarios por tienda
  Future<List<Usuario>> getUsuariosByTienda(String tiendaId) {
    return (select(usuarios)
          ..where((u) => u.activo.equals(true) & u.tiendaId.equals(tiendaId))
          ..orderBy([(u) => OrderingTerm.asc(u.nombre)]))
        .get();
  }

  // Insertar usuario
  Future<int> insertUsuario(UsuariosCompanion usuario) {
    return into(usuarios).insert(usuario);
  }

  // Actualizar usuario
  Future<int> updateUsuario(String id, UsuariosCompanion usuario) {
    return (update(usuarios)..where((u) => u.id.equals(id))).write(usuario);
  }

  // Eliminar usuario (soft delete)
  Future<int> deleteUsuario(String id) {
    return (update(usuarios)..where((u) => u.id.equals(id))).write(
      const UsuariosCompanion(activo: Value(false)),
    );
  }

  // ==================== TIENDAS ====================

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
  Future<int> updateTienda(String id, TiendasCompanion tienda) {
    return (update(tiendas)..where((t) => t.id.equals(id))).write(tienda);
  }

  // Stream de tiendas
  Stream<List<Tienda>> watchTiendas() {
    return (select(tiendas)
          ..where((t) => t.activo.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .watch();
  }

  // ==================== ALMACENES ====================

  // Obtener todos los almacenes activos
  Future<List<Almacene>> getAllAlmacenes() {
    return (select(almacenes)
          ..where((a) => a.activo.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.nombre)]))
        .get();
  }

  // Obtener almacén por ID
  Future<Almacene?> getAlmacenById(String id) {
    return (select(almacenes)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  // Insertar almacén
  Future<int> insertAlmacen(AlmacenesCompanion almacen) {
    return into(almacenes).insert(almacen);
  }

  // Actualizar almacén
  Future<int> updateAlmacen(String id, AlmacenesCompanion almacen) {
    return (update(almacenes)..where((a) => a.id.equals(id))).write(almacen);
  }

  // Stream de almacenes
  Stream<List<Almacene>> watchAlmacenes() {
    return (select(almacenes)
          ..where((a) => a.activo.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.nombre)]))
        .watch();
  }

  // Obtener usuarios pendientes de sincronizar
  Future<List<Usuario>> getPendingSync() {
    return (select(usuarios)..where((u) => u.syncStatus.equals('pendiente'))).get();
  }

  // Marcar como sincronizado
  Future<int> markAsSynced(String id) {
    return (update(usuarios)..where((u) => u.id.equals(id))).write(
      UsuariosCompanion(
        syncStatus: const Value('sincronizado'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
