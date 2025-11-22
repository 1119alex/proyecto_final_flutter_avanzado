import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/daos/tienda_dao.dart';
import '../sync/sync_service.dart';
import '../../core/di/injection.dart';

class TiendasRepository {
  final TiendaDao _tiendaDao;
  final _uuid = const Uuid();

  TiendasRepository(this._tiendaDao);

  SyncService get _syncService => getIt<SyncService>();

  Stream<List<Tienda>> watchAllTiendas() {
    return _tiendaDao.watchAllTiendas();
  }

  Future<List<Tienda>> getAllTiendas() {
    return _tiendaDao.getAllTiendas();
  }

  Future<Tienda?> getTiendaById(String id) {
    return _tiendaDao.getTiendaById(id);
  }

  Future<int> createTienda({
    required String nombre,
    required String direccion,
    String? telefono,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = TiendasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      direccion: Value(direccion),
      telefono: Value(telefono),
      activo: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
      syncStatus: const Value('pendiente'),
    );

    final result = await _tiendaDao.insertTienda(companion);

    // Agregar a la cola de sincronización
    await _syncService.queueOperation(
      tableName: 'tiendas',
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

  Future<bool> updateTienda({
    required String id,
    required String nombre,
    required String direccion,
    String? telefono,
    required bool activo,
  }) async {
    final tiendaExistente = await _tiendaDao.getTiendaById(id);
    if (tiendaExistente == null) return false;

    final now = DateTime.now();

    final companion = TiendasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      direccion: Value(direccion),
      telefono: Value(telefono),
      activo: Value(activo),
      createdAt: Value(tiendaExistente.createdAt),
      updatedAt: Value(now),
      syncStatus: const Value('pendiente'),
    );

    final result = await _tiendaDao.updateTienda(companion);

    if (result) {
      // Agregar a la cola de sincronización
      await _syncService.queueOperation(
        tableName: 'tiendas',
        recordId: id,
        operation: 'update',
        data: {
          'id': id,
          'nombre': nombre,
          'direccion': direccion,
          'telefono': telefono,
          'activo': activo,
          'created_at': tiendaExistente.createdAt.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );
    }

    return result;
  }

  Future<int> deleteTienda(String id) async {
    final result = await _tiendaDao.deleteTienda(id);

    if (result > 0) {
      // Agregar a la cola de sincronización
      await _syncService.queueOperation(
        tableName: 'tiendas',
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

  Future<bool> toggleTiendaEstado(String id, bool activo) async {
    final tienda = await _tiendaDao.getTiendaById(id);
    if (tienda == null) return false;

    return await updateTienda(
      id: id,
      nombre: tienda.nombre,
      direccion: tienda.direccion,
      telefono: tienda.telefono,
      activo: activo,
    );
  }

  Future<List<Tienda>> getTiendasActivas() {
    return _tiendaDao.getAllTiendas();
  }
}
