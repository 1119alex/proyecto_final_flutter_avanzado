import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'categoria_dao.g.dart';

@DriftAccessor(tables: [Categorias])
class CategoriaDao extends DatabaseAccessor<AppDatabase> with _$CategoriaDaoMixin {
  CategoriaDao(super.db);

  // Obtener todas las categorías activas
  Future<List<Categoria>> getAllCategorias() {
    return (select(categorias)
          ..where((c) => c.activo.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.nombre)]))
        .get();
  }

  // Obtener categoría por ID
  Future<Categoria?> getCategoriaById(String id) {
    return (select(categorias)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  // Insertar categoría
  Future<int> insertCategoria(CategoriasCompanion categoria) {
    return into(categorias).insert(categoria);
  }

  // Actualizar categoría
  Future<bool> updateCategoria(CategoriasCompanion categoria) {
    return update(categorias).replace(Categoria(
      id: categoria.id.value,
      nombre: categoria.nombre.value,
      descripcion: categoria.descripcion.value,
      icono: categoria.icono.value,
      activo: categoria.activo.value,
      createdAt: categoria.createdAt.value,
      updatedAt: DateTime.now(),
      syncStatus: categoria.syncStatus.value,
    ));
  }

  // Eliminar categoría (soft delete)
  Future<int> deleteCategoria(String id) {
    return (update(categorias)..where((c) => c.id.equals(id))).write(
      const CategoriasCompanion(activo: Value(false)),
    );
  }

  // Obtener categorías pendientes de sincronizar
  Future<List<Categoria>> getPendingSync() {
    return (select(categorias)
          ..where((c) => c.syncStatus.equals('pendiente')))
        .get();
  }

  // Marcar como sincronizado
  Future<int> markAsSynced(String id) {
    return (update(categorias)..where((c) => c.id.equals(id))).write(
      CategoriasCompanion(
        syncStatus: const Value('sincronizado'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Stream de categorías para actualizaciones en tiempo real
  Stream<List<Categoria>> watchAllCategorias() {
    return (select(categorias)
          ..where((c) => c.activo.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.nombre)]))
        .watch();
  }
}
