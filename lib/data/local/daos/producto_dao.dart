import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'producto_dao.g.dart';

@DriftAccessor(tables: [Productos, ProductoVariantes, Inventario])
class ProductoDao extends DatabaseAccessor<AppDatabase> with _$ProductoDaoMixin {
  ProductoDao(super.db);

  // ==================== PRODUCTOS ====================

  // Obtener todos los productos activos
  Future<List<Producto>> getAllProductos() {
    return (select(productos)
          ..where((p) => p.activo.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
        .get();
  }

  // Obtener productos por categoría
  Future<List<Producto>> getProductosByCategoria(String categoriaId) {
    return (select(productos)
          ..where((p) => p.activo.equals(true) & p.categoriaId.equals(categoriaId))
          ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
        .get();
  }

  // Obtener producto por ID
  Future<Producto?> getProductoById(String id) {
    return (select(productos)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  // Obtener producto por código
  Future<Producto?> getProductoByCodigo(String codigo) {
    return (select(productos)..where((p) => p.codigo.equals(codigo))).getSingleOrNull();
  }

  // Buscar productos
  Future<List<Producto>> searchProductos(String query) {
    return (select(productos)
          ..where((p) =>
              p.activo.equals(true) &
              (p.nombre.contains(query) | p.codigo.contains(query)))
          ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
        .get();
  }

  // Insertar producto
  Future<int> insertProducto(ProductosCompanion producto) {
    return into(productos).insert(producto);
  }

  // Actualizar producto
  Future<bool> updateProducto(ProductosCompanion producto) {
    return update(productos).replace(Producto(
      id: producto.id.value,
      codigo: producto.codigo.value,
      nombre: producto.nombre.value,
      descripcion: producto.descripcion.value,
      categoriaId: producto.categoriaId.value,
      precioCompra: producto.precioCompra.value,
      precioVenta: producto.precioVenta.value,
      unidadMedida: producto.unidadMedida.value,
      stockMinimo: producto.stockMinimo.value,
      imagenUrl: producto.imagenUrl.value,
      activo: producto.activo.value,
      createdAt: producto.createdAt.value,
      updatedAt: DateTime.now(),
      syncStatus: producto.syncStatus.value,
    ));
  }

  // Eliminar producto (soft delete)
  Future<int> deleteProducto(String id) {
    return (update(productos)..where((p) => p.id.equals(id))).write(
      const ProductosCompanion(activo: Value(false)),
    );
  }

  // Stream de productos
  Stream<List<Producto>> watchAllProductos() {
    return (select(productos)
          ..where((p) => p.activo.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
        .watch();
  }

  // ==================== VARIANTES ====================

  // Obtener variantes por producto
  Future<List<ProductoVariante>> getVariantesByProducto(String productoId) {
    return (select(productoVariantes)
          ..where((v) => v.activo.equals(true) & v.productoId.equals(productoId)))
        .get();
  }

  // Insertar variante
  Future<int> insertVariante(ProductoVariantesCompanion variante) {
    return into(productoVariantes).insert(variante);
  }

  // Actualizar variante
  Future<int> updateVariante(String id, ProductoVariantesCompanion variante) {
    return (update(productoVariantes)..where((v) => v.id.equals(id))).write(variante);
  }

  // Eliminar variante (soft delete)
  Future<int> deleteVariante(String id) {
    return (update(productoVariantes)..where((v) => v.id.equals(id))).write(
      const ProductoVariantesCompanion(activo: Value(false)),
    );
  }

  // ==================== INVENTARIO ====================

  // Obtener inventario por producto y ubicación
  Future<InventarioData?> getInventario({
    required String productoId,
    String? varianteId,
    String? tiendaId,
    String? almacenId,
  }) {
    return (select(inventario)
          ..where((i) {
            var condition = i.productoId.equals(productoId);
            if (varianteId != null) {
              condition = condition & i.varianteId.equals(varianteId);
            } else {
              condition = condition & i.varianteId.isNull();
            }
            if (tiendaId != null) {
              condition = condition & i.tiendaId.equals(tiendaId);
            }
            if (almacenId != null) {
              condition = condition & i.almacenId.equals(almacenId);
            }
            return condition;
          }))
        .getSingleOrNull();
  }

  // Obtener todo el inventario de una tienda
  Future<List<InventarioData>> getInventarioByTienda(String tiendaId) {
    return (select(inventario)..where((i) => i.tiendaId.equals(tiendaId))).get();
  }

  // Obtener todo el inventario de un almacén
  Future<List<InventarioData>> getInventarioByAlmacen(String almacenId) {
    return (select(inventario)..where((i) => i.almacenId.equals(almacenId))).get();
  }

  // Actualizar stock
  Future<int> updateStock(String inventarioId, int nuevaCantidad) {
    return (update(inventario)..where((i) => i.id.equals(inventarioId))).write(
      InventarioCompanion(
        cantidad: Value(nuevaCantidad),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pendiente'),
      ),
    );
  }

  // Insertar o actualizar inventario
  Future<void> upsertInventario(InventarioCompanion inv) async {
    await into(inventario).insertOnConflictUpdate(inv);
  }

  // Obtener productos con stock bajo
  Future<List<InventarioData>> getProductosStockBajo() {
    return customSelect(
      '''
      SELECT i.* FROM inventario i
      INNER JOIN productos p ON i.producto_id = p.id
      WHERE i.cantidad <= p.stock_minimo AND p.activo = 1
      ''',
      readsFrom: {inventario, productos},
    ).map((row) => InventarioData(
      id: row.read<String>('id'),
      productoId: row.read<String>('producto_id'),
      varianteId: row.readNullable<String>('variante_id'),
      tiendaId: row.readNullable<String>('tienda_id'),
      almacenId: row.readNullable<String>('almacen_id'),
      cantidad: row.read<int>('cantidad'),
      updatedAt: row.read<DateTime>('updated_at'),
      syncStatus: row.read<String>('sync_status'),
    )).get();
  }

  // Obtener productos pendientes de sincronizar
  Future<List<Producto>> getPendingSync() {
    return (select(productos)
          ..where((p) => p.syncStatus.equals('pendiente')))
        .get();
  }

  // Marcar como sincronizado
  Future<int> markAsSynced(String id) {
    return (update(productos)..where((p) => p.id.equals(id))).write(
      ProductosCompanion(
        syncStatus: const Value('sincronizado'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
