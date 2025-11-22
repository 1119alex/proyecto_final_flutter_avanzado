import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/daos/producto_dao.dart';
import '../sync/sync_service.dart';
import '../../core/di/injection.dart';

class ProductosRepository {
  final ProductoDao _productoDao;
  final _uuid = const Uuid();

  ProductosRepository(this._productoDao);

  SyncService get _syncService => getIt<SyncService>();

  Stream<List<Producto>> watchAllProductos() {
    return _productoDao.watchAllProductos();
  }

  Future<List<Producto>> getAllProductos() {
    return _productoDao.getAllProductos();
  }

  Future<List<Producto>> getProductosByCategoria(String categoriaId) {
    return _productoDao.getProductosByCategoria(categoriaId);
  }

  Future<List<Producto>> searchProductos(String query) {
    return _productoDao.searchProductos(query);
  }

  Future<Producto?> getProductoById(String id) {
    return _productoDao.getProductoById(id);
  }

  Future<Producto?> getProductoByCodigo(String codigo) {
    return _productoDao.getProductoByCodigo(codigo);
  }

  Future<int> createProducto({
    required String codigo,
    required String nombre,
    String? descripcion,
    required String categoriaId,
    required double precioCompra,
    required double precioVenta,
    String unidadMedida = 'unidad',
    int stockMinimo = 0,
    String? imagenUrl,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = ProductosCompanion(
      id: Value(id),
      codigo: Value(codigo),
      nombre: Value(nombre),
      descripcion: Value(descripcion),
      categoriaId: Value(categoriaId),
      precioCompra: Value(precioCompra),
      precioVenta: Value(precioVenta),
      unidadMedida: Value(unidadMedida),
      stockMinimo: Value(stockMinimo),
      imagenUrl: Value(imagenUrl),
      activo: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
      syncStatus: const Value('pendiente'),
    );

    final result = await _productoDao.insertProducto(companion);

    await _syncService.queueOperation(
      tableName: 'productos',
      recordId: id,
      operation: 'insert',
      data: {
        'id': id,
        'codigo': codigo,
        'nombre': nombre,
        'descripcion': descripcion,
        'categoria_id': categoriaId,
        'precio_compra': precioCompra,
        'precio_venta': precioVenta,
        'unidad_medida': unidadMedida,
        'stock_minimo': stockMinimo,
        'imagen_url': imagenUrl,
        'activo': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    );

    return result;
  }

  Future<bool> updateProducto({
    required String id,
    required String codigo,
    required String nombre,
    String? descripcion,
    required String categoriaId,
    required double precioCompra,
    required double precioVenta,
    String unidadMedida = 'unidad',
    int stockMinimo = 0,
    String? imagenUrl,
    required bool activo,
  }) async {
    final productoExistente = await _productoDao.getProductoById(id);
    if (productoExistente == null) return false;

    final now = DateTime.now();

    final companion = ProductosCompanion(
      id: Value(id),
      codigo: Value(codigo),
      nombre: Value(nombre),
      descripcion: Value(descripcion),
      categoriaId: Value(categoriaId),
      precioCompra: Value(precioCompra),
      precioVenta: Value(precioVenta),
      unidadMedida: Value(unidadMedida),
      stockMinimo: Value(stockMinimo),
      imagenUrl: Value(imagenUrl),
      activo: Value(activo),
      createdAt: Value(productoExistente.createdAt),
      updatedAt: Value(now),
      syncStatus: const Value('pendiente'),
    );

    final result = await _productoDao.updateProducto(companion);

    if (result) {
      await _syncService.queueOperation(
        tableName: 'productos',
        recordId: id,
        operation: 'update',
        data: {
          'id': id,
          'codigo': codigo,
          'nombre': nombre,
          'descripcion': descripcion,
          'categoria_id': categoriaId,
          'precio_compra': precioCompra,
          'precio_venta': precioVenta,
          'unidad_medida': unidadMedida,
          'stock_minimo': stockMinimo,
          'imagen_url': imagenUrl,
          'activo': activo,
          'created_at': productoExistente.createdAt.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );
    }

    return result;
  }

  Future<int> deleteProducto(String id) async {
    final result = await _productoDao.deleteProducto(id);

    if (result > 0) {
      await _syncService.queueOperation(
        tableName: 'productos',
        recordId: id,
        operation: 'update',
        data: {
          'id': id,
          'activo': false,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    }

    return result;
  }

  Future<bool> toggleProductoEstado(String id, bool activo) async {
    final producto = await _productoDao.getProductoById(id);
    if (producto == null) return false;

    return await updateProducto(
      id: id,
      codigo: producto.codigo,
      nombre: producto.nombre,
      descripcion: producto.descripcion,
      categoriaId: producto.categoriaId,
      precioCompra: producto.precioCompra,
      precioVenta: producto.precioVenta,
      unidadMedida: producto.unidadMedida,
      stockMinimo: producto.stockMinimo,
      imagenUrl: producto.imagenUrl,
      activo: activo,
    );
  }

  Future<bool> codigoExists(String codigo, {String? excludeId}) async {
    final producto = await _productoDao.getProductoByCodigo(codigo);
    if (producto == null) return false;
    if (excludeId != null && producto.id == excludeId) return false;
    return true;
  }
}
