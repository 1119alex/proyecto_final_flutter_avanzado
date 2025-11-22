import 'package:equatable/equatable.dart';

abstract class TransferenciasEvent extends Equatable {
  const TransferenciasEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransferencias extends TransferenciasEvent {
  const LoadTransferencias();
}

class LoadTransferenciasByEstado extends TransferenciasEvent {
  final String estado;

  const LoadTransferenciasByEstado(this.estado);

  @override
  List<Object?> get props => [estado];
}

class LoadTransferenciasByFecha extends TransferenciasEvent {
  final DateTime inicio;
  final DateTime fin;

  const LoadTransferenciasByFecha({required this.inicio, required this.fin});

  @override
  List<Object?> get props => [inicio, fin];
}

class LoadTransferenciaDetalle extends TransferenciasEvent {
  final String transferenciaId;

  const LoadTransferenciaDetalle(this.transferenciaId);

  @override
  List<Object?> get props => [transferenciaId];
}

class CreateTransferencia extends TransferenciasEvent {
  final String usuarioId;
  final String? origenTiendaId;
  final String? origenAlmacenId;
  final String? destinoTiendaId;
  final String? destinoAlmacenId;
  final String? observaciones;
  final List<TransferenciaDetalleItem> detalles;

  const CreateTransferencia({
    required this.usuarioId,
    this.origenTiendaId,
    this.origenAlmacenId,
    this.destinoTiendaId,
    this.destinoAlmacenId,
    this.observaciones,
    required this.detalles,
  });

  @override
  List<Object?> get props => [
    usuarioId,
    origenTiendaId,
    origenAlmacenId,
    destinoTiendaId,
    destinoAlmacenId,
    observaciones,
    detalles,
  ];
}

class UpdateTransferenciaEstado extends TransferenciasEvent {
  final String id;
  final String nuevoEstado;

  const UpdateTransferenciaEstado({
    required this.id,
    required this.nuevoEstado,
  });

  @override
  List<Object?> get props => [id, nuevoEstado];
}

class CompletarTransferencia extends TransferenciasEvent {
  final String id;

  const CompletarTransferencia(this.id);

  @override
  List<Object?> get props => [id];
}

class CancelarTransferencia extends TransferenciasEvent {
  final String id;

  const CancelarTransferencia(this.id);

  @override
  List<Object?> get props => [id];
}

class MarcarEnTransito extends TransferenciasEvent {
  final String id;

  const MarcarEnTransito(this.id);

  @override
  List<Object?> get props => [id];
}

/// Clase auxiliar para items de detalle en eventos
class TransferenciaDetalleItem {
  final String productoId;
  final String? varianteId;
  final int cantidad;

  const TransferenciaDetalleItem({
    required this.productoId,
    this.varianteId,
    required this.cantidad,
  });
}
