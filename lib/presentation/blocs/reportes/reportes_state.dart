import 'package:equatable/equatable.dart';

abstract class ReportesState extends Equatable {
  const ReportesState();

  @override
  List<Object?> get props => [];
}

class ReportesInitial extends ReportesState {
  const ReportesInitial();
}

class ReportesLoading extends ReportesState {
  const ReportesLoading();
}

// Estado para reporte general
class ReportesGeneralLoaded extends ReportesState {
  final double totalVentas;
  final double totalCompras;
  final double ganancia;
  final int cantidadVentas;
  final int cantidadCompras;
  final int productosVendidos;
  final Map<String, dynamic>? filtros;

  const ReportesGeneralLoaded({
    required this.totalVentas,
    required this.totalCompras,
    required this.ganancia,
    required this.cantidadVentas,
    required this.cantidadCompras,
    required this.productosVendidos,
    this.filtros,
  });

  @override
  List<Object?> get props => [
    totalVentas,
    totalCompras,
    ganancia,
    cantidadVentas,
    cantidadCompras,
    productosVendidos,
    filtros,
  ];
}

// Estado para reporte de ventas
class ReporteVentasLoaded extends ReportesState {
  final List<VentaReporte> ventas;
  final double totalVentas;
  final int cantidadVentas;
  final double promedioVenta;
  final Map<String, dynamic>? filtros;

  const ReporteVentasLoaded({
    required this.ventas,
    required this.totalVentas,
    required this.cantidadVentas,
    required this.promedioVenta,
    this.filtros,
  });

  @override
  List<Object?> get props => [
    ventas,
    totalVentas,
    cantidadVentas,
    promedioVenta,
    filtros,
  ];
}

// Estado para reporte de compras
class ReporteComprasLoaded extends ReportesState {
  final List<CompraReporte> compras;
  final double totalCompras;
  final int cantidadCompras;
  final double promedioCompra;
  final Map<String, dynamic>? filtros;

  const ReporteComprasLoaded({
    required this.compras,
    required this.totalCompras,
    required this.cantidadCompras,
    required this.promedioCompra,
    this.filtros,
  });

  @override
  List<Object?> get props => [
    compras,
    totalCompras,
    cantidadCompras,
    promedioCompra,
    filtros,
  ];
}

// Estado para reporte de inventario
class ReporteInventarioLoaded extends ReportesState {
  final List<InventarioReporte> inventario;
  final int totalProductos;
  final int productosBajoStock;
  final double valorTotalInventario;
  final Map<String, dynamic>? filtros;

  const ReporteInventarioLoaded({
    required this.inventario,
    required this.totalProductos,
    required this.productosBajoStock,
    required this.valorTotalInventario,
    this.filtros,
  });

  @override
  List<Object?> get props => [
    inventario,
    totalProductos,
    productosBajoStock,
    valorTotalInventario,
    filtros,
  ];
}

// Estado para productos más vendidos
class ProductosMasVendidosLoaded extends ReportesState {
  final List<ProductoVendido> productos;
  final int totalProductos;
  final Map<String, dynamic>? filtros;

  const ProductosMasVendidosLoaded({
    required this.productos,
    required this.totalProductos,
    this.filtros,
  });

  @override
  List<Object?> get props => [productos, totalProductos, filtros];
}

// Estado para métricas del dashboard
class DashboardMetricsLoaded extends ReportesState {
  final double ventasHoy;
  final double ventasMes;
  final int productosTotal;
  final int productosBajoStock;
  final int clientesTotal;
  final int ventasPendientes;
  final List<ProductoVendido> topProductos;
  final Map<String, double> ventasPorDia; // Para gráfico de últimos 7 días

  const DashboardMetricsLoaded({
    required this.ventasHoy,
    required this.ventasMes,
    required this.productosTotal,
    required this.productosBajoStock,
    required this.clientesTotal,
    required this.ventasPendientes,
    required this.topProductos,
    required this.ventasPorDia,
  });

  @override
  List<Object?> get props => [
    ventasHoy,
    ventasMes,
    productosTotal,
    productosBajoStock,
    clientesTotal,
    ventasPendientes,
    topProductos,
    ventasPorDia,
  ];
}

class ReportesError extends ReportesState {
  final String message;

  const ReportesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Modelos de datos para los reportes

class VentaReporte {
  final String id;
  final String numeroVenta;
  final DateTime fecha;
  final String? clienteNombre;
  final String? tiendaNombre;
  final double total;
  final String estado;
  final int cantidadItems;

  const VentaReporte({
    required this.id,
    required this.numeroVenta,
    required this.fecha,
    this.clienteNombre,
    this.tiendaNombre,
    required this.total,
    required this.estado,
    required this.cantidadItems,
  });
}

class CompraReporte {
  final String id;
  final String numeroCompra;
  final DateTime fecha;
  final String? proveedorNombre;
  final String? almacenNombre;
  final double total;
  final String estado;
  final int cantidadItems;

  const CompraReporte({
    required this.id,
    required this.numeroCompra,
    required this.fecha,
    this.proveedorNombre,
    this.almacenNombre,
    required this.total,
    required this.estado,
    required this.cantidadItems,
  });
}

class InventarioReporte {
  final String productoId;
  final String productoNombre;
  final String? ubicacionNombre;
  final int cantidad;
  final int stockMinimo;
  final double precioVenta;
  final double valorTotal;
  final bool bajoStock;

  const InventarioReporte({
    required this.productoId,
    required this.productoNombre,
    this.ubicacionNombre,
    required this.cantidad,
    required this.stockMinimo,
    required this.precioVenta,
    required this.valorTotal,
    required this.bajoStock,
  });
}

class ProductoVendido {
  final String productoId;
  final String productoNombre;
  final int cantidadVendida;
  final double totalVentas;
  final double precioPromedio;

  const ProductoVendido({
    required this.productoId,
    required this.productoNombre,
    required this.cantidadVendida,
    required this.totalVentas,
    required this.precioPromedio,
  });
}
