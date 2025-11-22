import 'package:equatable/equatable.dart';
import '../../../data/local/database/app_database.dart';

abstract class ComprasState extends Equatable {
  const ComprasState();

  @override
  List<Object?> get props => [];
}

class ComprasInitial extends ComprasState {
  const ComprasInitial();
}

class ComprasLoading extends ComprasState {
  const ComprasLoading();
}

class ComprasLoaded extends ComprasState {
  final List<Compra> compras;
  final double totalCompras;
  final String? filtroAlmacenId;
  final DateTime? filtroFechaInicio;
  final DateTime? filtroFechaFin;

  const ComprasLoaded(
    this.compras, {
    this.totalCompras = 0,
    this.filtroAlmacenId,
    this.filtroFechaInicio,
    this.filtroFechaFin,
  });

  @override
  List<Object?> get props => [
    compras,
    totalCompras,
    filtroAlmacenId,
    filtroFechaInicio,
    filtroFechaFin,
  ];
}

class CompraDetalleLoaded extends ComprasState {
  final Compra compra;
  final List<CompraDetalle> detalles;
  final Proveedor? proveedor;

  const CompraDetalleLoaded({
    required this.compra,
    required this.detalles,
    this.proveedor,
  });

  @override
  List<Object?> get props => [compra, detalles, proveedor];
}

class ComprasError extends ComprasState {
  final String message;

  const ComprasError(this.message);

  @override
  List<Object?> get props => [message];
}

class CompraCreated extends ComprasState {
  final String compraId;

  const CompraCreated(this.compraId);

  @override
  List<Object?> get props => [compraId];
}

class CompraCancelled extends ComprasState {
  const CompraCancelled();
}
