import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/daos/categoria_dao.dart';
import '../sync/sync_service.dart';
import '../../core/di/injection.dart';

class CategoriasRepository {
  final CategoriaDao _categoriaDao;
  final _uuid = const Uuid();

  CategoriasRepository(this._categoriaDao);

  SyncService get _syncService => getIt<SyncService>();

  Stream<List<Categoria>> watchAllCategorias() {
    return _categoriaDao.watchAllCategorias();
  }

  Future<List<Categoria>> getAllCategorias() {
    return _categoriaDao.getAllCategorias();
  }

  Future<Categoria?> getCategoriaById(String id) {
    return _categoriaDao.getCategoriaById(id);
  }

  Future<int> createCategoria({
    required String nombre,
    String? descripcion,
    String? icono,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = CategoriasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      descripcion: Value(descripcion),
      icono: Value(icono),
      activo: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
      syncStatus: const Value('pendiente'),
    );

    final result = await _categoriaDao.insertCategoria(companion);

    // Agregar a la cola de sincronización
    await _syncService.queueOperation(
      tableName: 'categorias',
      recordId: id,
      operation: 'insert',
      data: {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'icono': icono,
        'activo': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    );

    return result;
  }

  Future<bool> updateCategoria({
    required String id,
    required String nombre,
    String? descripcion,
    String? icono,
    required bool activo,
  }) async {
    final categoriaExistente = await _categoriaDao.getCategoriaById(id);
    if (categoriaExistente == null) return false;

    final now = DateTime.now();

    final companion = CategoriasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      descripcion: Value(descripcion),
      icono: Value(icono),
      activo: Value(activo),
      createdAt: Value(categoriaExistente.createdAt),
      updatedAt: Value(now),
      syncStatus: const Value('pendiente'),
    );

    final result = await _categoriaDao.updateCategoria(companion);

    if (result) {
      // Agregar a la cola de sincronización
      await _syncService.queueOperation(
        tableName: 'categorias',
        recordId: id,
        operation: 'update',
        data: {
          'id': id,
          'nombre': nombre,
          'descripcion': descripcion,
          'icono': icono,
          'activo': activo,
          'created_at': categoriaExistente.createdAt.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );
    }

    return result;
  }

  Future<int> deleteCategoria(String id) async {
    final result = await _categoriaDao.deleteCategoria(id);

    if (result > 0) {
      // Agregar a la cola de sincronización
      await _syncService.queueOperation(
        tableName: 'categorias',
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

  Future<bool> toggleCategoriaEstado(String id, bool activo) async {
    final categoria = await _categoriaDao.getCategoriaById(id);
    if (categoria == null) return false;

    return await updateCategoria(
      id: id,
      nombre: categoria.nombre,
      descripcion: categoria.descripcion,
      icono: categoria.icono,
      activo: activo,
    );
  }

  Future<List<Categoria>> getCategoriasActivas() {
    return _categoriaDao.getAllCategorias();
  }
}
