import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/daos/categoria_dao.dart';

class CategoriasRepository {
  final CategoriaDao _categoriaDao;
  final _uuid = const Uuid();

  CategoriasRepository(this._categoriaDao);

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
    final companion = CategoriasCompanion(
      id: Value(_uuid.v4()),
      nombre: Value(nombre),
      descripcion: Value(descripcion),
      icono: Value(icono),
      activo: const Value(true),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pendiente'),
    );

    return await _categoriaDao.insertCategoria(companion);
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

    final companion = CategoriasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      descripcion: Value(descripcion),
      icono: Value(icono),
      activo: Value(activo),
      createdAt: Value(categoriaExistente.createdAt),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pendiente'),
    );

    return await _categoriaDao.updateCategoria(companion);
  }

  Future<int> deleteCategoria(String id) {
    return _categoriaDao.deleteCategoria(id);
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
