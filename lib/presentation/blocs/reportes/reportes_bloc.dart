import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/reportes_repository.dart';
import 'reportes_event.dart';
import 'reportes_state.dart';

class ReportesBloc extends Bloc<ReportesEvent, ReportesState> {
  final ReportesRepository _repository;

  ReportesBloc(this._repository) : super(const ReportesInitial()) {
    on<LoadReportesGeneral>(_onLoadReportesGeneral);
    on<LoadReporteVentas>(_onLoadReporteVentas);
    on<LoadReporteCompras>(_onLoadReporteCompras);
    on<LoadReporteInventario>(_onLoadReporteInventario);
    on<LoadProductosMasVendidos>(_onLoadProductosMasVendidos);
    on<LoadDashboardMetrics>(_onLoadDashboardMetrics);
  }

  Future<void> _onLoadReportesGeneral(
    LoadReportesGeneral event,
    Emitter<ReportesState> emit,
  ) async {
    try {
      emit(const ReportesLoading());

      final result = await _repository.getReporteGeneral(
        tiendaId: event.tiendaId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );

      emit(
        ReportesGeneralLoaded(
          totalVentas: result['totalVentas'] ?? 0.0,
          totalCompras: result['totalCompras'] ?? 0.0,
          ganancia: result['ganancia'] ?? 0.0,
          cantidadVentas: result['cantidadVentas'] ?? 0,
          cantidadCompras: result['cantidadCompras'] ?? 0,
          productosVendidos: result['productosVendidos'] ?? 0,
          filtros: {
            'tiendaId': event.tiendaId,
            'fechaInicio': event.fechaInicio,
            'fechaFin': event.fechaFin,
          },
        ),
      );
    } catch (e) {
      emit(ReportesError('Error al cargar reporte general: ${e.toString()}'));
    }
  }

  Future<void> _onLoadReporteVentas(
    LoadReporteVentas event,
    Emitter<ReportesState> emit,
  ) async {
    try {
      emit(const ReportesLoading());

      final ventas = await _repository.getReporteVentas(
        tiendaId: event.tiendaId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );

      final totalVentas = ventas.fold<double>(
        0.0,
        (sum, venta) => sum + venta.total,
      );
      final cantidadVentas = ventas.length;
      final promedioVenta = cantidadVentas > 0
          ? totalVentas / cantidadVentas
          : 0.0;

      emit(
        ReporteVentasLoaded(
          ventas: ventas,
          totalVentas: totalVentas,
          cantidadVentas: cantidadVentas,
          promedioVenta: promedioVenta,
          filtros: {
            'tiendaId': event.tiendaId,
            'fechaInicio': event.fechaInicio,
            'fechaFin': event.fechaFin,
          },
        ),
      );
    } catch (e) {
      emit(ReportesError('Error al cargar reporte de ventas: ${e.toString()}'));
    }
  }

  Future<void> _onLoadReporteCompras(
    LoadReporteCompras event,
    Emitter<ReportesState> emit,
  ) async {
    try {
      emit(const ReportesLoading());

      final compras = await _repository.getReporteCompras(
        almacenId: event.almacenId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
      );

      final totalCompras = compras.fold<double>(
        0.0,
        (sum, compra) => sum + compra.total,
      );
      final cantidadCompras = compras.length;
      final promedioCompra = cantidadCompras > 0
          ? totalCompras / cantidadCompras
          : 0.0;

      emit(
        ReporteComprasLoaded(
          compras: compras,
          totalCompras: totalCompras,
          cantidadCompras: cantidadCompras,
          promedioCompra: promedioCompra,
          filtros: {
            'almacenId': event.almacenId,
            'fechaInicio': event.fechaInicio,
            'fechaFin': event.fechaFin,
          },
        ),
      );
    } catch (e) {
      emit(
        ReportesError('Error al cargar reporte de compras: ${e.toString()}'),
      );
    }
  }

  Future<void> _onLoadReporteInventario(
    LoadReporteInventario event,
    Emitter<ReportesState> emit,
  ) async {
    try {
      emit(const ReportesLoading());

      final inventario = await _repository.getReporteInventario(
        ubicacionId: event.ubicacionId,
      );

      final totalProductos = inventario.length;
      final productosBajoStock = inventario
          .where((item) => item.bajoStock)
          .length;
      final valorTotalInventario = inventario.fold<double>(
        0.0,
        (sum, item) => sum + item.valorTotal,
      );

      emit(
        ReporteInventarioLoaded(
          inventario: inventario,
          totalProductos: totalProductos,
          productosBajoStock: productosBajoStock,
          valorTotalInventario: valorTotalInventario,
          filtros: {'ubicacionId': event.ubicacionId},
        ),
      );
    } catch (e) {
      emit(
        ReportesError('Error al cargar reporte de inventario: ${e.toString()}'),
      );
    }
  }

  Future<void> _onLoadProductosMasVendidos(
    LoadProductosMasVendidos event,
    Emitter<ReportesState> emit,
  ) async {
    try {
      emit(const ReportesLoading());

      final productos = await _repository.getProductosMasVendidos(
        tiendaId: event.tiendaId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
        limit: event.limit,
      );

      emit(
        ProductosMasVendidosLoaded(
          productos: productos,
          totalProductos: productos.length,
          filtros: {
            'tiendaId': event.tiendaId,
            'fechaInicio': event.fechaInicio,
            'fechaFin': event.fechaFin,
            'limit': event.limit,
          },
        ),
      );
    } catch (e) {
      emit(
        ReportesError(
          'Error al cargar productos más vendidos: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadDashboardMetrics(
    LoadDashboardMetrics event,
    Emitter<ReportesState> emit,
  ) async {
    try {
      emit(const ReportesLoading());

      final metrics = await _repository.getDashboardMetrics();

      emit(
        DashboardMetricsLoaded(
          ventasHoy: metrics['ventasHoy'] ?? 0.0,
          ventasMes: metrics['ventasMes'] ?? 0.0,
          productosTotal: metrics['productosTotal'] ?? 0,
          productosBajoStock: metrics['productosBajoStock'] ?? 0,
          clientesTotal: metrics['clientesTotal'] ?? 0,
          ventasPendientes: metrics['ventasPendientes'] ?? 0,
          topProductos: metrics['topProductos'] ?? [],
          ventasPorDia: metrics['ventasPorDia'] ?? {},
        ),
      );
    } catch (e) {
      emit(
        ReportesError(
          'Error al cargar métricas del dashboard: ${e.toString()}',
        ),
      );
    }
  }
}
