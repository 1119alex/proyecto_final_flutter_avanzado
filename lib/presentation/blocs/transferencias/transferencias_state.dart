import 'package:equatable/equatable.dart';
import '../../../data/local/database/app_database.dart';

abstract class TransferenciasState extends Equatable {
  const TransferenciasState();

  @override
  List<Object?> get props => [];
}

class TransferenciasInitial extends TransferenciasState {
  const TransferenciasInitial();
}

class TransferenciasLoading extends TransferenciasState {
  const TransferenciasLoading();
}

class TransferenciasLoaded extends TransferenciasState {
  final List<Transferencia> transferencias;
  final Map<String, int> conteoPorEstado;
  final String? filtroEstado;
  final DateTime? filtroFechaInicio;
  final DateTime? filtroFechaFin;

  const TransferenciasLoaded(
    this.transferencias, {
    this.conteoPorEstado = const {},
    this.filtroEstado,
    this.filtroFechaInicio,
    this.filtroFechaFin,
  });

  @override
  List<Object?> get props => [
    transferencias,
    conteoPorEstado,
    filtroEstado,
    filtroFechaInicio,
    filtroFechaFin,
  ];
}

class TransferenciaDetalleLoaded extends TransferenciasState {
  final Transferencia transferencia;
  final List<TransferenciaDetalle> detalles;

  const TransferenciaDetalleLoaded({
    required this.transferencia,
    required this.detalles,
  });

  @override
  List<Object?> get props => [transferencia, detalles];
}

class TransferenciasError extends TransferenciasState {
  final String message;

  const TransferenciasError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransferenciaCreated extends TransferenciasState {
  final String transferenciaId;

  const TransferenciaCreated(this.transferenciaId);

  @override
  List<Object?> get props => [transferenciaId];
}

class TransferenciaEstadoUpdated extends TransferenciasState {
  final String nuevoEstado;

  const TransferenciaEstadoUpdated(this.nuevoEstado);

  @override
  List<Object?> get props => [nuevoEstado];
}
