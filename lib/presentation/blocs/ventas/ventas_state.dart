import 'package:equatable/equatable.dart';
import '../../../data/local/database/app_database.dart';

abstract class VentasState extends Equatable {
  const VentasState();

  @override
  List<Object?> get props => [];
}

class VentasInitial extends VentasState {
  const VentasInitial();
}

class VentasLoading extends VentasState {
  const VentasLoading();
}

class VentasLoaded extends VentasState {
  final List<Venta> ventas;
  final double totalVentas;
  final String? filtroTiendaId;
  final DateTime? filtroFechaInicio;
  final DateTime? filtroFechaFin;

  const VentasLoaded(
    this.ventas, {
    this.totalVentas = 0,
    this.filtroTiendaId,
    this.filtroFechaInicio,
    this.filtroFechaFin,
  });

  @override
  List<Object?> get props => [
    ventas,
    totalVentas,
    filtroTiendaId,
    filtroFechaInicio,
    filtroFechaFin,
  ];
}

class VentaDetalleLoaded extends VentasState {
  final Venta venta;
  final List<VentaDetalle> detalles;
  final Cliente? cliente;

  const VentaDetalleLoaded({
    required this.venta,
    required this.detalles,
    this.cliente,
  });

  @override
  List<Object?> get props => [venta, detalles, cliente];
}

class VentasError extends VentasState {
  final String message;

  const VentasError(this.message);

  @override
  List<Object?> get props => [message];
}

class VentaCreated extends VentasState {
  final String ventaId;

  const VentaCreated(this.ventaId);

  @override
  List<Object?> get props => [ventaId];
}

class VentaCancelled extends VentasState {
  const VentaCancelled();
}
