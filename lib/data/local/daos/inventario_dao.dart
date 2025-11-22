import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'inventario_dao.g.dart';

@DriftAccessor(tables: [Inventario, Productos, Tiendas, Almacenes])
class InventarioDao extends DatabaseAccessor<AppDatabase>
    with _$InventarioDaoMixin {
  InventarioDao(super.db);

  // Obtener todo el inventario
  Future<List<InventarioData>> getAllInventario() {
    return (select(
      inventario,
    )..orderBy([(i) => OrderingTerm.desc(i.updatedAt)])).get();
  }

  // Obtener inventario por ID
  Future<InventarioData?> getInventarioById(String id) {
    return (select(
      inventario,
    )..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  // Obtener inventario de un producto
  Future<List<InventarioData>> getInventarioByProducto(String productoId) {
    return (select(
      inventario,
    )..where((i) => i.productoId.equals(productoId))).get();
  }

  // Obtener inventario de una tienda
  Future<List<InventarioData>> getInventarioByTienda(String tiendaId) {
    return (select(
      inventario,
    )..where((i) => i.tiendaId.equals(tiendaId))).get();
  }

  // Obtener inventario de un almacen
  Future<List<InventarioData>> getInventarioByAlmacen(String almacenId) {
    return (select(
      inventario,
    )..where((i) => i.almacenId.equals(almacenId))).get();
  }

  // Obtener inventario de un producto en una ubicacion especifica
  Future<InventarioData?> getInventarioByProductoYUbicacion({
    required String productoId,
    String? tiendaId,
    String? almacenId,
    String? varianteId,
  }) {
    return (select(inventario)..where((i) {
          var condition = i.productoId.equals(productoId);
          if (tiendaId != null) {
            condition = condition & i.tiendaId.equals(tiendaId);
          } else {
            condition = condition & i.tiendaId.isNull();
          }
          if (almacenId != null) {
            condition = condition & i.almacenId.equals(almacenId);
          } else {
            condition = condition & i.almacenId.isNull();
          }
          if (varianteId != null) {
            condition = condition & i.varianteId.equals(varianteId);
          } else {
            condition = condition & i.varianteId.isNull();
          }
          return condition;
        }))
        .getSingleOrNull();
  }

  // Obtener stock total de un producto
  // Future<int> getStockTotalProducto(String productoId) async {
  //   final result = await (select(inventario)
  //         ..where((i) => i.productoId.equals(productoId)))
  //       .get();
  //   return result.fold(0, (sum, item) => (sum + item.cantidad));
  // }
  Future<int> getStockTotalProducto(String productoId) async {
    final result = await (select(
      inventario,
    )..where((i) => i.productoId.equals(productoId))).get();

    int total = 0;
    for (final item in result) {
      total += item.cantidad; // Si esto da error, usa la opción 2
    }
    return total;
  }

  // Obtener productos con stock bajo
  Future<List<InventarioConProducto>> getProductosStockBajo() async {
    final query = select(inventario).join([
      innerJoin(productos, productos.id.equalsExp(inventario.productoId)),
    ])..where(inventario.cantidad.isSmallerThan(productos.stockMinimo));

    final results = await query.get();
    return results.map((row) {
      return InventarioConProducto(
        inventario: row.readTable(inventario),
        producto: row.readTable(productos),
      );
    }).toList();
  }

  // Insertar inventario
  Future<int> insertInventario(InventarioCompanion inv) {
    return into(inventario).insert(inv);
  }

  // Actualizar inventario
  Future<bool> updateInventario(InventarioCompanion inv) {
    return update(inventario).replace(inv);
  }

  // Actualizar cantidad de inventario
  Future<int> updateCantidad(String id, int cantidad) {
    return (update(inventario)..where((i) => i.id.equals(id))).write(
      InventarioCompanion(
        cantidad: Value(cantidad),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pendiente'),
      ),
    );
  }

  // Eliminar inventario
  Future<int> deleteInventario(String id) {
    return (delete(inventario)..where((i) => i.id.equals(id))).go();
  }

  // Obtener inventario pendiente de sincronizacion
  Future<List<InventarioData>> getInventarioPendiente() {
    return (select(
      inventario,
    )..where((i) => i.syncStatus.equals('pendiente'))).get();
  }

  // Marcar como sincronizado
  Future<int> marcarComoSincronizado(String id) {
    return (update(inventario)..where((i) => i.id.equals(id))).write(
      const InventarioCompanion(syncStatus: Value('sincronizado')),
    );
  }

  // Stream de inventario
  Stream<List<InventarioData>> watchAllInventario() {
    return (select(
      inventario,
    )..orderBy([(i) => OrderingTerm.desc(i.updatedAt)])).watch();
  }

  // Obtener inventario con detalles de producto y ubicacion
  Future<List<InventarioDetallado>> getInventarioDetallado() async {
    final query = select(inventario).join([
      innerJoin(productos, productos.id.equalsExp(inventario.productoId)),
      leftOuterJoin(tiendas, tiendas.id.equalsExp(inventario.tiendaId)),
      leftOuterJoin(almacenes, almacenes.id.equalsExp(inventario.almacenId)),
    ])..orderBy([OrderingTerm.asc(productos.nombre)]);

    final results = await query.get();
    return results.map((row) {
      return InventarioDetallado(
        inventario: row.readTable(inventario),
        producto: row.readTable(productos),
        tienda: row.readTableOrNull(tiendas),
        almacen: row.readTableOrNull(almacenes),
      );
    }).toList();
  }
}

// Clases auxiliares para datos relacionados
class InventarioConProducto {
  final InventarioData inventario;
  final Producto producto;

  InventarioConProducto({required this.inventario, required this.producto});
}

class InventarioDetallado {
  final InventarioData inventario;
  final Producto producto;
  final Tienda? tienda;
  final Almacen? almacen;

  InventarioDetallado({
    required this.inventario,
    required this.producto,
    this.tienda,
    this.almacen,
  });

  String get ubicacion {
    if (tienda != null) return 'Tienda: ${tienda!.nombre}';
    if (almacen != null) return 'Almacen: ${almacen!.nombre}';
    return 'Sin ubicacion';
  }
}
