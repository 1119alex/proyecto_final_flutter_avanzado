import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/daos/almacen_dao.dart';
import '../sync/sync_service.dart';
import '../../core/di/injection.dart';

class AlmacenesRepository {
  final AlmacenDao _almacenDao;
  final _uuid = const Uuid();

  AlmacenesRepository(this._almacenDao);

  SyncService get _syncService => getIt<SyncService>();

  Stream<List<Almacen>> watchAllAlmacenes() {
    return _almacenDao.watchAllAlmacenes();
  }

  Future<List<Almacen>> getAllAlmacenes() {
    return _almacenDao.getAllAlmacenes();
  }

  Future<Almacen?> getAlmacenById(String id) {
    return _almacenDao.getAlmacenById(id);
  }

  Future<int> createAlmacen({
    required String nombre,
    required String direccion,
    String? telefono,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = AlmacenesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      direccion: Value(direccion),
      telefono: Value(telefono),
      activo: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
      syncStatus: const Value('pendiente'),
    );

    final result = await _almacenDao.insertAlmacen(companion);

    // Agregar a la cola de sincronización
    await _syncService.queueOperation(
      tableName: 'almacenes',
      recordId: id,
      operation: 'insert',
      data: {
        'id': id,
        'nombre': nombre,
        'direccion': direccion,
        'telefono': telefono,
        'activo': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    );

    return result;
  }

  Future<bool> updateAlmacen({
    required String id,
    required String nombre,
    required String direccion,
    String? telefono,
    required bool activo,
  }) async {
    final almacenExistente = await _almacenDao.getAlmacenById(id);
    if (almacenExistente == null) return false;

    final now = DateTime.now();

    final companion = AlmacenesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      direccion: Value(direccion),
      telefono: Value(telefono),
      activo: Value(activo),
      createdAt: Value(almacenExistente.createdAt),
      updatedAt: Value(now),
      syncStatus: const Value('pendiente'),
    );

    final result = await _almacenDao.updateAlmacen(companion);

    if (result) {
      // Agregar a la cola de sincronización
      await _syncService.queueOperation(
        tableName: 'almacenes',
        recordId: id,
        operation: 'update',
        data: {
          'id': id,
          'nombre': nombre,
          'direccion': direccion,
          'telefono': telefono,
          'activo': activo,
          'created_at': almacenExistente.createdAt.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );
    }

    return result;
  }

  Future<int> deleteAlmacen(String id) async {
    final result = await _almacenDao.deleteAlmacen(id);

    if (result > 0) {
      // Agregar a la cola de sincronización
      await _syncService.queueOperation(
        tableName: 'almacenes',
        recordId: id,
        operation: 'update', // Soft delete, so it's an update
        data: {
          'id': id,
          'activo': false,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    }

    return result;
  }

  Future<bool> toggleAlmacenEstado(String id, bool activo) async {
    final almacen = await _almacenDao.getAlmacenById(id);
    if (almacen == null) return false;

    return await updateAlmacen(
      id: id,
      nombre: almacen.nombre,
      direccion: almacen.direccion,
      telefono: almacen.telefono,
      activo: activo,
    );
  }

  Future<List<Almacen>> getAlmacenesActivos() {
    return _almacenDao.getAllAlmacenes();
  }
}
