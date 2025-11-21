import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'compra_dao.g.dart';

@DriftAccessor(tables: [Compras, CompraDetalles, Proveedores])
class CompraDao extends DatabaseAccessor<AppDatabase> with _$CompraDaoMixin {
  CompraDao(super.db);

  // ==================== COMPRAS ====================

  // Obtener todas las compras
  Future<List<Compra>> getAllCompras() {
    return (select(compras)..orderBy([(c) => OrderingTerm.desc(c.fecha)])).get();
  }

  // Obtener compras por almacén
  Future<List<Compra>> getComprasByAlmacen(String almacenId) {
    return (select(compras)
          ..where((c) => c.almacenId.equals(almacenId))
          ..orderBy([(c) => OrderingTerm.desc(c.fecha)]))
        .get();
  }

  // Obtener compras por fecha
  Future<List<Compra>> getComprasByFecha(DateTime inicio, DateTime fin) {
    return (select(compras)
          ..where((c) =>
              c.fecha.isBiggerOrEqualValue(inicio) &
              c.fecha.isSmallerOrEqualValue(fin))
          ..orderBy([(c) => OrderingTerm.desc(c.fecha)]))
        .get();
  }

  // Obtener compra por ID
  Future<Compra?> getCompraById(String id) {
    return (select(compras)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  // Insertar compra
  Future<int> insertCompra(ComprasCompanion compra) {
    return into(compras).insert(compra);
  }

  // Actualizar compra
  Future<int> updateCompra(String id, ComprasCompanion compra) {
    return (update(compras)..where((c) => c.id.equals(id))).write(compra);
  }

  // Stream de compras
  Stream<List<Compra>> watchCompras() {
    return (select(compras)..orderBy([(c) => OrderingTerm.desc(c.fecha)])).watch();
  }

  // ==================== DETALLES DE COMPRA ====================

  // Obtener detalles por compra
  Future<List<CompraDetalle>> getDetallesByCompra(String compraId) {
    return (select(compraDetalles)..where((d) => d.compraId.equals(compraId))).get();
  }

  // Insertar detalle
  Future<int> insertDetalle(CompraDetallesCompanion detalle) {
    return into(compraDetalles).insert(detalle);
  }

  // Insertar múltiples detalles
  Future<void> insertDetalles(List<CompraDetallesCompanion> detalles) async {
    await batch((batch) {
      batch.insertAll(compraDetalles, detalles.map((d) => CompraDetalle(
        id: d.id.value,
        compraId: d.compraId.value,
        productoId: d.productoId.value,
        varianteId: d.varianteId.value,
        cantidad: d.cantidad.value,
        precioUnitario: d.precioUnitario.value,
        subtotal: d.subtotal.value,
        createdAt: DateTime.now(),
        syncStatus: 'pendiente',
      )).toList());
    });
  }

  // ==================== PROVEEDORES ====================

  // Obtener todos los proveedores activos
  Future<List<Proveedore>> getAllProveedores() {
    return (select(proveedores)
          ..where((p) => p.activo.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
        .get();
  }

  // Obtener proveedor por ID
  Future<Proveedore?> getProveedorById(String id) {
    return (select(proveedores)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  // Insertar proveedor
  Future<int> insertProveedor(ProveedoresCompanion proveedor) {
    return into(proveedores).insert(proveedor);
  }

  // Actualizar proveedor
  Future<int> updateProveedor(String id, ProveedoresCompanion proveedor) {
    return (update(proveedores)..where((p) => p.id.equals(id))).write(proveedor);
  }

  // Eliminar proveedor (soft delete)
  Future<int> deleteProveedor(String id) {
    return (update(proveedores)..where((p) => p.id.equals(id))).write(
      const ProveedoresCompanion(activo: Value(false)),
    );
  }

  // Obtener compras pendientes de sincronizar
  Future<List<Compra>> getPendingSync() {
    return (select(compras)..where((c) => c.syncStatus.equals('pendiente'))).get();
  }

  // Marcar como sincronizado
  Future<int> markAsSynced(String id) {
    return (update(compras)..where((c) => c.id.equals(id))).write(
      ComprasCompanion(
        syncStatus: const Value('sincronizado'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
