import 'package:drift/drift.dart';
import '../database/app_database.dart';

part 'venta_dao.g.dart';

@DriftAccessor(tables: [Ventas, VentaDetalles, Clientes])
class VentaDao extends DatabaseAccessor<AppDatabase> with _$VentaDaoMixin {
  VentaDao(super.db);

  // ==================== VENTAS ====================

  // Obtener todas las ventas
  Future<List<Venta>> getAllVentas() {
    return (select(ventas)..orderBy([(v) => OrderingTerm.desc(v.fecha)])).get();
  }

  // Obtener ventas por tienda
  Future<List<Venta>> getVentasByTienda(String tiendaId) {
    return (select(ventas)
          ..where((v) => v.tiendaId.equals(tiendaId))
          ..orderBy([(v) => OrderingTerm.desc(v.fecha)]))
        .get();
  }

  // Obtener ventas por fecha
  Future<List<Venta>> getVentasByFecha(DateTime inicio, DateTime fin) {
    return (select(ventas)
          ..where((v) =>
              v.fecha.isBiggerOrEqualValue(inicio) &
              v.fecha.isSmallerOrEqualValue(fin))
          ..orderBy([(v) => OrderingTerm.desc(v.fecha)]))
        .get();
  }

  // Obtener ventas por tienda y fecha
  Future<List<Venta>> getVentasByTiendaAndFecha(
      String tiendaId, DateTime inicio, DateTime fin) {
    return (select(ventas)
          ..where((v) =>
              v.tiendaId.equals(tiendaId) &
              v.fecha.isBiggerOrEqualValue(inicio) &
              v.fecha.isSmallerOrEqualValue(fin))
          ..orderBy([(v) => OrderingTerm.desc(v.fecha)]))
        .get();
  }

  // Obtener venta por ID
  Future<Venta?> getVentaById(String id) {
    return (select(ventas)..where((v) => v.id.equals(id))).getSingleOrNull();
  }

  // Insertar venta
  Future<int> insertVenta(VentasCompanion venta) {
    return into(ventas).insert(venta);
  }

  // Actualizar venta
  Future<int> updateVenta(String id, VentasCompanion venta) {
    return (update(ventas)..where((v) => v.id.equals(id))).write(venta);
  }

  // Obtener ventas del día
  Future<List<Venta>> getVentasHoy() {
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month, now.day);
    final fin = inicio.add(const Duration(days: 1));
    return getVentasByFecha(inicio, fin);
  }

  // Obtener total de ventas del día
  Future<double> getTotalVentasHoy() async {
    final ventasHoy = await getVentasHoy();
    double total = 0.0;
    for (final v in ventasHoy) {
      total += v.total;
    }
    return total;
  }

  // Obtener total de ventas por tienda hoy
  Future<double> getTotalVentasTiendaHoy(String tiendaId) async {
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month, now.day);
    final fin = inicio.add(const Duration(days: 1));
    final ventasTienda = await getVentasByTiendaAndFecha(tiendaId, inicio, fin);
    double total = 0.0;
    for (final v in ventasTienda) {
      total += v.total;
    }
    return total;
  }

  // Stream de ventas
  Stream<List<Venta>> watchVentas() {
    return (select(ventas)..orderBy([(v) => OrderingTerm.desc(v.fecha)])).watch();
  }

  // ==================== DETALLES DE VENTA ====================

  // Obtener detalles por venta
  Future<List<VentaDetalle>> getDetallesByVenta(String ventaId) {
    return (select(ventaDetalles)..where((d) => d.ventaId.equals(ventaId))).get();
  }

  // Insertar detalle
  Future<int> insertDetalle(VentaDetallesCompanion detalle) {
    return into(ventaDetalles).insert(detalle);
  }

  // Insertar múltiples detalles
  Future<void> insertDetalles(List<VentaDetallesCompanion> detalles) async {
    await batch((batch) {
      batch.insertAll(ventaDetalles, detalles.map((d) => VentaDetalle(
        id: d.id.value,
        ventaId: d.ventaId.value,
        productoId: d.productoId.value,
        varianteId: d.varianteId.value,
        cantidad: d.cantidad.value,
        precioUnitario: d.precioUnitario.value,
        descuento: d.descuento.value,
        subtotal: d.subtotal.value,
        createdAt: DateTime.now(),
        syncStatus: 'pendiente',
      )).toList());
    });
  }

  // ==================== CLIENTES ====================

  // Obtener todos los clientes activos
  Future<List<Cliente>> getAllClientes() {
    return (select(clientes)
          ..where((c) => c.activo.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.nombre)]))
        .get();
  }

  // Obtener cliente por ID
  Future<Cliente?> getClienteById(String id) {
    return (select(clientes)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  // Buscar clientes
  Future<List<Cliente>> searchClientes(String query) {
    return (select(clientes)
          ..where((c) =>
              c.activo.equals(true) &
              (c.nombre.contains(query) | c.nit.contains(query)))
          ..orderBy([(c) => OrderingTerm.asc(c.nombre)]))
        .get();
  }

  // Insertar cliente
  Future<int> insertCliente(ClientesCompanion cliente) {
    return into(clientes).insert(cliente);
  }

  // Actualizar cliente
  Future<int> updateCliente(String id, ClientesCompanion cliente) {
    return (update(clientes)..where((c) => c.id.equals(id))).write(cliente);
  }

  // Obtener ventas pendientes de sincronizar
  Future<List<Venta>> getPendingSync() {
    return (select(ventas)..where((v) => v.syncStatus.equals('pendiente'))).get();
  }

  // Marcar como sincronizado
  Future<int> markAsSynced(String id) {
    return (update(ventas)..where((v) => v.id.equals(id))).write(
      VentasCompanion(
        syncStatus: const Value('sincronizado'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
