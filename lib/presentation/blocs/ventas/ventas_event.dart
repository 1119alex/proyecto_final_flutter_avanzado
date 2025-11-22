import 'package:equatable/equatable.dart';

abstract class VentasEvent extends Equatable {
  const VentasEvent();

  @override
  List<Object?> get props => [];
}

class LoadVentas extends VentasEvent {
  const LoadVentas();
}

class LoadVentasByTienda extends VentasEvent {
  final String tiendaId;

  const LoadVentasByTienda(this.tiendaId);

  @override
  List<Object?> get props => [tiendaId];
}

class LoadVentasByFecha extends VentasEvent {
  final DateTime inicio;
  final DateTime fin;

  const LoadVentasByFecha({required this.inicio, required this.fin});

  @override
  List<Object?> get props => [inicio, fin];
}

class LoadVentasHoy extends VentasEvent {
  const LoadVentasHoy();
}

class LoadVentaDetalle extends VentasEvent {
  final String ventaId;

  const LoadVentaDetalle(this.ventaId);

  @override
  List<Object?> get props => [ventaId];
}

class CreateVenta extends VentasEvent {
  final String? clienteId;
  final String tiendaId;
  final String usuarioId;
  final double descuento;
  final String metodoPago;
  final String? observaciones;
  final List<VentaDetalleItem> detalles;

  const CreateVenta({
    this.clienteId,
    required this.tiendaId,
    required this.usuarioId,
    this.descuento = 0,
    required this.metodoPago,
    this.observaciones,
    required this.detalles,
  });

  @override
  List<Object?> get props => [
    clienteId,
    tiendaId,
    usuarioId,
    descuento,
    metodoPago,
    observaciones,
    detalles,
  ];
}

class CancelVenta extends VentasEvent {
  final String id;

  const CancelVenta(this.id);

  @override
  List<Object?> get props => [id];
}

// Clase auxiliar para detalles de venta
class VentaDetalleItem {
  final String productoId;
  final String? varianteId;
  final int cantidad;
  final double precioUnitario;
  final double descuento;

  const VentaDetalleItem({
    required this.productoId,
    this.varianteId,
    required this.cantidad,
    required this.precioUnitario,
    this.descuento = 0,
  });

  double get subtotal => (precioUnitario * cantidad) - descuento;
}
