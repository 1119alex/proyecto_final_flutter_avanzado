import 'package:equatable/equatable.dart';

abstract class ReportesEvent extends Equatable {
  const ReportesEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportesGeneral extends ReportesEvent {
  final String? tiendaId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const LoadReportesGeneral({this.tiendaId, this.fechaInicio, this.fechaFin});

  @override
  List<Object?> get props => [tiendaId, fechaInicio, fechaFin];
}

class LoadReporteVentas extends ReportesEvent {
  final String? tiendaId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const LoadReporteVentas({this.tiendaId, this.fechaInicio, this.fechaFin});

  @override
  List<Object?> get props => [tiendaId, fechaInicio, fechaFin];
}

class LoadReporteCompras extends ReportesEvent {
  final String? almacenId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const LoadReporteCompras({this.almacenId, this.fechaInicio, this.fechaFin});

  @override
  List<Object?> get props => [almacenId, fechaInicio, fechaFin];
}

class LoadReporteInventario extends ReportesEvent {
  final String? ubicacionId;

  const LoadReporteInventario({this.ubicacionId});

  @override
  List<Object?> get props => [ubicacionId];
}

class LoadProductosMasVendidos extends ReportesEvent {
  final String? tiendaId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int limit;

  const LoadProductosMasVendidos({
    this.tiendaId,
    this.fechaInicio,
    this.fechaFin,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [tiendaId, fechaInicio, fechaFin, limit];
}

class LoadDashboardMetrics extends ReportesEvent {
  const LoadDashboardMetrics();
}
