import 'package:drift/drift.dart';
import '../local/database/app_database.dart';
import '../../presentation/blocs/reportes/reportes_state.dart';

class ReportesRepository {
  final AppDatabase _db;

  ReportesRepository(this._db);

  // ==================== REPORTE GENERAL ====================

  Future<Map<String, dynamic>> getReporteGeneral({
    String? tiendaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    // Aplicar filtros de fecha si existen
    final inicio =
        fechaInicio ?? DateTime.now().subtract(const Duration(days: 30));
    final fin = fechaFin ?? DateTime.now();

    // Total de ventas
    final ventasQuery = _db.select(_db.ventas).join([]);
    if (tiendaId != null) {
      ventasQuery.where(_db.ventas.tiendaId.equals(tiendaId));
    }
    ventasQuery.where(_db.ventas.fecha.isBetweenValues(inicio, fin));

    final ventasResult = await ventasQuery.get();
    final totalVentas = ventasResult.fold<double>(
      0.0,
      (sum, row) => sum + (row.readTable(_db.ventas).total),
    );
    final cantidadVentas = ventasResult.length;

    // Total de compras
    final comprasQuery = _db.select(_db.compras).join([]);
    comprasQuery.where(_db.compras.fecha.isBetweenValues(inicio, fin));

    final comprasResult = await comprasQuery.get();
    final totalCompras = comprasResult.fold<double>(
      0.0,
      (sum, row) => sum + (row.readTable(_db.compras).total),
    );
    final cantidadCompras = comprasResult.length;

    // Productos vendidos (suma de cantidades de detalles de venta)
    final detallesQuery = _db.select(_db.ventaDetalles).join([
      innerJoin(_db.ventas, _db.ventas.id.equalsExp(_db.ventaDetalles.ventaId)),
    ]);

    if (tiendaId != null) {
      detallesQuery.where(_db.ventas.tiendaId.equals(tiendaId));
    }
    detallesQuery.where(_db.ventas.fecha.isBetweenValues(inicio, fin));

    final detallesResult = await detallesQuery.get();
    final productosVendidos = detallesResult.fold<int>(
      0,
      (sum, row) => sum + row.readTable(_db.ventaDetalles).cantidad,
    );

    return {
      'totalVentas': totalVentas,
      'totalCompras': totalCompras,
      'ganancia': totalVentas - totalCompras,
      'cantidadVentas': cantidadVentas,
      'cantidadCompras': cantidadCompras,
      'productosVendidos': productosVendidos,
    };
  }

  // ==================== REPORTE DE VENTAS ====================

  Future<List<VentaReporte>> getReporteVentas({
    String? tiendaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final inicio =
        fechaInicio ?? DateTime.now().subtract(const Duration(days: 30));
    final fin = fechaFin ?? DateTime.now();

    final query = _db.select(_db.ventas).join([
      leftOuterJoin(
        _db.clientes,
        _db.clientes.id.equalsExp(_db.ventas.clienteId),
      ),
      leftOuterJoin(_db.tiendas, _db.tiendas.id.equalsExp(_db.ventas.tiendaId)),
    ]);

    if (tiendaId != null) {
      query.where(_db.ventas.tiendaId.equals(tiendaId));
    }
    query.where(_db.ventas.fecha.isBetweenValues(inicio, fin));
    query.orderBy([OrderingTerm.desc(_db.ventas.fecha)]);

    final results = await query.get();

    final reportes = <VentaReporte>[];
    for (final row in results) {
      final venta = row.readTable(_db.ventas);
      final cliente = row.readTableOrNull(_db.clientes);
      final tienda = row.readTableOrNull(_db.tiendas);

      // Contar items de esta venta
      final detalles = await (_db.select(
        _db.ventaDetalles,
      )..where((t) => t.ventaId.equals(venta.id))).get();
      final cantidadItems = detalles.length;

      reportes.add(
        VentaReporte(
          id: venta.id,
          numeroVenta: 'V-${venta.id.substring(0, 8)}',
          fecha: venta.fecha,
          clienteNombre: cliente?.nombre ?? 'Cliente general',
          tiendaNombre: tienda?.nombre,
          total: venta.total,
          estado: venta.estado,
          cantidadItems: cantidadItems,
        ),
      );
    }

    return reportes;
  }

  // ==================== REPORTE DE COMPRAS ====================

  Future<List<CompraReporte>> getReporteCompras({
    String? almacenId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final inicio =
        fechaInicio ?? DateTime.now().subtract(const Duration(days: 30));
    final fin = fechaFin ?? DateTime.now();

    final query = _db.select(_db.compras).join([
      leftOuterJoin(
        _db.proveedores,
        _db.proveedores.id.equalsExp(_db.compras.proveedorId),
      ),
      leftOuterJoin(
        _db.almacenes,
        _db.almacenes.id.equalsExp(_db.compras.almacenId),
      ),
    ]);

    if (almacenId != null) {
      query.where(_db.compras.almacenId.equals(almacenId));
    }
    query.where(_db.compras.fecha.isBetweenValues(inicio, fin));
    query.orderBy([OrderingTerm.desc(_db.compras.fecha)]);

    final results = await query.get();

    final reportes = <CompraReporte>[];
    for (final row in results) {
      final compra = row.readTable(_db.compras);
      final proveedor = row.readTableOrNull(_db.proveedores);
      final almacen = row.readTableOrNull(_db.almacenes);

      // Contar items de esta compra
      final detalles = await (_db.select(
        _db.compraDetalles,
      )..where((t) => t.compraId.equals(compra.id))).get();
      final cantidadItems = detalles.length;

      reportes.add(
        CompraReporte(
          id: compra.id,
          numeroCompra: 'C-${compra.id.substring(0, 8)}',
          fecha: compra.fecha,
          proveedorNombre: proveedor?.nombre,
          almacenNombre: almacen?.nombre,
          total: compra.total,
          estado: compra.estado,
          cantidadItems: cantidadItems,
        ),
      );
    }

    return reportes;
  }

  // ==================== REPORTE DE INVENTARIO ====================

  Future<List<InventarioReporte>> getReporteInventario({
    String? ubicacionId,
  }) async {
    final query = _db.select(_db.inventario).join([
      innerJoin(
        _db.productos,
        _db.productos.id.equalsExp(_db.inventario.productoId),
      ),
      leftOuterJoin(
        _db.tiendas,
        _db.tiendas.id.equalsExp(_db.inventario.tiendaId),
        useColumns: false,
      ),
      leftOuterJoin(
        _db.almacenes,
        _db.almacenes.id.equalsExp(_db.inventario.almacenId),
        useColumns: false,
      ),
    ]);

    if (ubicacionId != null) {
      query.where(
        _db.inventario.tiendaId.equals(ubicacionId) |
            _db.inventario.almacenId.equals(ubicacionId),
      );
    }

    final results = await query.get();

    final reportes = <InventarioReporte>[];
    for (final row in results) {
      final inventario = row.readTable(_db.inventario);
      final producto = row.readTable(_db.productos);
      final tienda = row.readTableOrNull(_db.tiendas);
      final almacen = row.readTableOrNull(_db.almacenes);

      final valorTotal = inventario.cantidad * producto.precioVenta;
      final bajoStock = inventario.cantidad < producto.stockMinimo;

      reportes.add(
        InventarioReporte(
          productoId: producto.id,
          productoNombre: producto.nombre,
          ubicacionNombre: tienda?.nombre ?? almacen?.nombre ?? 'Sin ubicación',
          cantidad: inventario.cantidad,
          stockMinimo: producto.stockMinimo,
          precioVenta: producto.precioVenta,
          valorTotal: valorTotal,
          bajoStock: bajoStock,
        ),
      );
    }

    return reportes;
  }

  // ==================== PRODUCTOS MÁS VENDIDOS ====================

  Future<List<ProductoVendido>> getProductosMasVendidos({
    String? tiendaId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int limit = 10,
  }) async {
    final inicio =
        fechaInicio ?? DateTime.now().subtract(const Duration(days: 30));
    final fin = fechaFin ?? DateTime.now();

    // Query para obtener productos más vendidos
    final query = _db.select(_db.ventaDetalles).join([
      innerJoin(
        _db.productos,
        _db.productos.id.equalsExp(_db.ventaDetalles.productoId),
      ),
      innerJoin(_db.ventas, _db.ventas.id.equalsExp(_db.ventaDetalles.ventaId)),
    ]);

    if (tiendaId != null) {
      query.where(_db.ventas.tiendaId.equals(tiendaId));
    }
    query.where(_db.ventas.fecha.isBetweenValues(inicio, fin));

    final results = await query.get();

    // Agrupar por producto y calcular totales
    final Map<String, _ProductoStats> productosMap = {};

    for (final row in results) {
      final detalle = row.readTable(_db.ventaDetalles);
      final producto = row.readTable(_db.productos);

      if (productosMap.containsKey(producto.id)) {
        productosMap[producto.id]!.cantidadVendida += detalle.cantidad;
        productosMap[producto.id]!.totalVentas += detalle.subtotal;
      } else {
        productosMap[producto.id] = _ProductoStats(
          productoId: producto.id,
          productoNombre: producto.nombre,
          cantidadVendida: detalle.cantidad,
          totalVentas: detalle.subtotal,
        );
      }
    }

    // Convertir a lista y ordenar por cantidad vendida
    final productosVendidos = productosMap.values
        .map(
          (stats) => ProductoVendido(
            productoId: stats.productoId,
            productoNombre: stats.productoNombre,
            cantidadVendida: stats.cantidadVendida,
            totalVentas: stats.totalVentas,
            precioPromedio: stats.cantidadVendida > 0
                ? stats.totalVentas / stats.cantidadVendida
                : 0.0,
          ),
        )
        .toList();

    productosVendidos.sort(
      (a, b) => b.cantidadVendida.compareTo(a.cantidadVendida),
    );

    return productosVendidos.take(limit).toList();
  }

  // ==================== MÉTRICAS DEL DASHBOARD ====================

  Future<Map<String, dynamic>> getDashboardMetrics() async {
    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final finHoy = inicioHoy.add(const Duration(days: 1));

    final inicioMes = DateTime(hoy.year, hoy.month, 1);
    final finMes = DateTime(hoy.year, hoy.month + 1, 1);

    // Ventas de hoy
    final ventasHoyQuery = _db.select(_db.ventas)
      ..where((t) => t.fecha.isBetweenValues(inicioHoy, finHoy));
    final ventasHoyList = await ventasHoyQuery.get();
    final ventasHoy = ventasHoyList.fold<double>(
      0.0,
      (sum, venta) => sum + venta.total,
    );

    // Ventas del mes
    final ventasMesQuery = _db.select(_db.ventas)
      ..where((t) => t.fecha.isBetweenValues(inicioMes, finMes));
    final ventasMesList = await ventasMesQuery.get();
    final ventasMes = ventasMesList.fold<double>(
      0.0,
      (sum, venta) => sum + venta.total,
    );

    // Total de productos
    final productosTotal = await (_db.select(
      _db.productos,
    )..where((t) => t.activo.equals(true))).get();

    // Productos bajo stock
    final inventarioQuery = _db.select(_db.inventario).join([
      innerJoin(
        _db.productos,
        _db.productos.id.equalsExp(_db.inventario.productoId),
      ),
    ]);
    final inventarioResults = await inventarioQuery.get();
    final productosBajoStock = inventarioResults.where((row) {
      final inventario = row.readTable(_db.inventario);
      final producto = row.readTable(_db.productos);
      return inventario.cantidad < producto.stockMinimo;
    }).length;

    // Total de clientes
    final clientesTotal = await (_db.select(
      _db.clientes,
    )..where((t) => t.activo.equals(true))).get();

    // Ventas pendientes
    final ventasPendientes = await (_db.select(
      _db.ventas,
    )..where((t) => t.estado.equals('pendiente'))).get();

    // Top 5 productos más vendidos del mes
    final topProductos = await getProductosMasVendidos(
      fechaInicio: inicioMes,
      fechaFin: finMes,
      limit: 5,
    );

    // Ventas por día (últimos 7 días)
    final Map<String, double> ventasPorDia = {};
    for (int i = 6; i >= 0; i--) {
      final dia = hoy.subtract(Duration(days: i));
      final inicioDia = DateTime(dia.year, dia.month, dia.day);
      final finDia = inicioDia.add(const Duration(days: 1));

      final ventasDiaQuery = _db.select(_db.ventas)
        ..where((t) => t.fecha.isBetweenValues(inicioDia, finDia));
      final ventasDiaList = await ventasDiaQuery.get();
      final totalDia = ventasDiaList.fold<double>(
        0.0,
        (sum, venta) => sum + venta.total,
      );

      final fecha = '${dia.day}/${dia.month}';
      ventasPorDia[fecha] = totalDia;
    }

    return {
      'ventasHoy': ventasHoy,
      'ventasMes': ventasMes,
      'productosTotal': productosTotal.length,
      'productosBajoStock': productosBajoStock,
      'clientesTotal': clientesTotal.length,
      'ventasPendientes': ventasPendientes.length,
      'topProductos': topProductos,
      'ventasPorDia': ventasPorDia,
    };
  }
}

// Clase auxiliar para agrupar estadísticas de productos
class _ProductoStats {
  final String productoId;
  final String productoNombre;
  int cantidadVendida;
  double totalVentas;

  _ProductoStats({
    required this.productoId,
    required this.productoNombre,
    required this.cantidadVendida,
    required this.totalVentas,
  });
}
