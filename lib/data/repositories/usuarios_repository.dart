import 'package:drift/drift.dart';
import '../../core/di/injection.dart';
import '../local/daos/usuario_dao.dart';
import '../local/database/app_database.dart';
import '../sync/sync_service.dart';

class UsuariosRepository {
  final UsuarioDao _usuarioDao;

  // Lazy getter para SyncService
  SyncService get _syncService => getIt<SyncService>();

  UsuariosRepository(this._usuarioDao);

  // ==================== USUARIOS ====================

  Future<List<Usuario>> getAllUsuarios() async {
    return await _usuarioDao.getAllUsuarios();
  }

  Future<Usuario?> getUsuarioById(String id) async {
    return await _usuarioDao.getUsuarioById(id);
  }

  Future<Usuario?> getUsuarioByEmail(String email) async {
    return await _usuarioDao.getUsuarioByEmail(email);
  }

  Future<List<Usuario>> getUsuariosByRol(String rol) async {
    return await _usuarioDao.getUsuariosByRol(rol);
  }

  Future<List<Usuario>> getUsuariosByTienda(String tiendaId) async {
    return await _usuarioDao.getUsuariosByTienda(tiendaId);
  }

  /// Crear un usuario
  Future<String?> createUsuario({
    required String id, // Viene de Supabase Auth
    required String email,
    required String nombre,
    required String apellido,
    required String rol,
    String? tiendaId,
    String? almacenId,
  }) async {
    try {
      final now = DateTime.now();

      final usuarioCompanion = UsuariosCompanion(
        id: Value(id),
        email: Value(email),
        nombre: Value(nombre),
        apellido: Value(apellido),
        rol: Value(rol),
        tiendaId: Value(tiendaId),
        almacenId: Value(almacenId),
        activo: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pendiente'),
      );

      await _usuarioDao.insertUsuario(usuarioCompanion);

      // Encolar para sincronizacion
      await _syncService.queueOperation(
        tableName: 'usuarios',
        recordId: id,
        operation: 'insert',
        data: {
          'id': id,
          'email': email,
          'nombre': nombre,
          'apellido': apellido,
          'rol': rol,
          'tienda_id': tiendaId,
          'almacen_id': almacenId,
          'activo': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );

      return id;
    } catch (e) {
      return null;
    }
  }

  /// Actualizar usuario
  Future<bool> updateUsuario({
    required String id,
    String? nombre,
    String? apellido,
    String? rol,
    String? tiendaId,
    String? almacenId,
  }) async {
    try {
      final now = DateTime.now();

      final usuarioCompanion = UsuariosCompanion(
        nombre: nombre != null ? Value(nombre) : const Value.absent(),
        apellido: apellido != null ? Value(apellido) : const Value.absent(),
        rol: rol != null ? Value(rol) : const Value.absent(),
        tiendaId: tiendaId != null ? Value(tiendaId) : const Value.absent(),
        almacenId: almacenId != null ? Value(almacenId) : const Value.absent(),
        updatedAt: Value(now),
        syncStatus: const Value('pendiente'),
      );

      await _usuarioDao.updateUsuario(id, usuarioCompanion);

      // Preparar datos para sync (solo campos no nulos)
      final syncData = <String, dynamic>{'updated_at': now.toIso8601String()};
      if (nombre != null) syncData['nombre'] = nombre;
      if (apellido != null) syncData['apellido'] = apellido;
      if (rol != null) syncData['rol'] = rol;
      if (tiendaId != null) syncData['tienda_id'] = tiendaId;
      if (almacenId != null) syncData['almacen_id'] = almacenId;

      await _syncService.queueOperation(
        tableName: 'usuarios',
        recordId: id,
        operation: 'update',
        data: syncData,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Activar/Desactivar usuario
  Future<bool> toggleActivo(String id, bool activo) async {
    try {
      final now = DateTime.now();

      await _usuarioDao.updateUsuario(
        id,
        UsuariosCompanion(
          activo: Value(activo),
          updatedAt: Value(now),
          syncStatus: const Value('pendiente'),
        ),
      );

      await _syncService.queueOperation(
        tableName: 'usuarios',
        recordId: id,
        operation: 'update',
        data: {'activo': activo, 'updated_at': now.toIso8601String()},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Eliminar usuario (soft delete)
  Future<bool> deleteUsuario(String id) async {
    try {
      await _usuarioDao.deleteUsuario(id);

      await _syncService.queueOperation(
        tableName: 'usuarios',
        recordId: id,
        operation: 'update',
        data: {'activo': false, 'updated_at': DateTime.now().toIso8601String()},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Contar usuarios por rol
  Future<Map<String, int>> contarPorRol() async {
    final usuarios = await getAllUsuarios();
    final conteo = <String, int>{
      'admin': 0,
      'encargado_tienda': 0,
      'encargado_almacen': 0,
      'vendedor': 0,
    };

    for (final u in usuarios) {
      conteo[u.rol] = (conteo[u.rol] ?? 0) + 1;
    }

    return conteo;
  }
}
