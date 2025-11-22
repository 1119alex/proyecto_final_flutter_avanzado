import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/local/database/app_database.dart';
import '../../../data/repositories/ventas_repository.dart';
import 'ventas_event.dart';
import 'ventas_state.dart';

class VentasBloc extends Bloc<VentasEvent, VentasState> {
  final VentasRepository _repository;

  VentasBloc(this._repository) : super(const VentasInitial()) {
    on<LoadVentas>(_onLoadVentas);
    on<LoadVentasByTienda>(_onLoadVentasByTienda);
    on<LoadVentasByFecha>(_onLoadVentasByFecha);
    on<LoadVentasHoy>(_onLoadVentasHoy);
    on<LoadVentaDetalle>(_onLoadVentaDetalle);
    on<CreateVenta>(_onCreateVenta);
    on<CancelVenta>(_onCancelVenta);
  }

  Future<void> _onLoadVentas(
    LoadVentas event,
    Emitter<VentasState> emit,
  ) async {
    try {
      emit(const VentasLoading());
      final ventas = await _repository.getAllVentas();
      final total = await _repository.calcularTotalVentas(ventas);
      emit(VentasLoaded(ventas, totalVentas: total));
    } catch (e) {
      emit(VentasError('Error al cargar ventas: ${e.toString()}'));
    }
  }

  Future<void> _onLoadVentasByTienda(
    LoadVentasByTienda event,
    Emitter<VentasState> emit,
  ) async {
    try {
      emit(const VentasLoading());
      final ventas = await _repository.getVentasByTienda(event.tiendaId);
      final total = await _repository.calcularTotalVentas(ventas);
      emit(
        VentasLoaded(
          ventas,
          totalVentas: total,
          filtroTiendaId: event.tiendaId,
        ),
      );
    } catch (e) {
      emit(VentasError('Error al cargar ventas: ${e.toString()}'));
    }
  }

  Future<void> _onLoadVentasByFecha(
    LoadVentasByFecha event,
    Emitter<VentasState> emit,
  ) async {
    try {
      emit(const VentasLoading());
      final ventas = await _repository.getVentasByFecha(
        event.inicio,
        event.fin,
      );
      final total = await _repository.calcularTotalVentas(ventas);
      emit(
        VentasLoaded(
          ventas,
          totalVentas: total,
          filtroFechaInicio: event.inicio,
          filtroFechaFin: event.fin,
        ),
      );
    } catch (e) {
      emit(VentasError('Error al cargar ventas: ${e.toString()}'));
    }
  }

  Future<void> _onLoadVentasHoy(
    LoadVentasHoy event,
    Emitter<VentasState> emit,
  ) async {
    try {
      emit(const VentasLoading());
      final ventas = await _repository.getVentasHoy();
      final total = await _repository.calcularTotalVentas(ventas);
      final now = DateTime.now();
      final hoyInicio = DateTime(now.year, now.month, now.day);
      final hoyFin = hoyInicio.add(const Duration(days: 1));
      emit(
        VentasLoaded(
          ventas,
          totalVentas: total,
          filtroFechaInicio: hoyInicio,
          filtroFechaFin: hoyFin,
        ),
      );
    } catch (e) {
      emit(VentasError('Error al cargar ventas de hoy: ${e.toString()}'));
    }
  }

  Future<void> _onLoadVentaDetalle(
    LoadVentaDetalle event,
    Emitter<VentasState> emit,
  ) async {
    try {
      emit(const VentasLoading());
      final venta = await _repository.getVentaById(event.ventaId);
      if (venta == null) {
        emit(const VentasError('Venta no encontrada'));
        return;
      }
      final detalles = await _repository.getDetallesByVenta(event.ventaId);
      Cliente? cliente;
      if (venta.clienteId != null) {
        cliente = await _repository.getClienteById(venta.clienteId!);
      }
      emit(
        VentaDetalleLoaded(venta: venta, detalles: detalles, cliente: cliente),
      );
    } catch (e) {
      emit(VentasError('Error al cargar detalle de venta: ${e.toString()}'));
    }
  }

  Future<void> _onCreateVenta(
    CreateVenta event,
    Emitter<VentasState> emit,
  ) async {
    try {
      // Convertir VentaDetalleItem a VentaDetalleData
      final detallesData = event.detalles
          .map(
            (d) => VentaDetalleData(
              productoId: d.productoId,
              varianteId: d.varianteId,
              cantidad: d.cantidad,
              precioUnitario: d.precioUnitario,
              descuento: d.descuento,
            ),
          )
          .toList();

      final ventaId = await _repository.createVenta(
        clienteId: event.clienteId,
        tiendaId: event.tiendaId,
        usuarioId: event.usuarioId,
        descuento: event.descuento,
        metodoPago: event.metodoPago,
        observaciones: event.observaciones,
        detalles: detallesData,
      );

      if (ventaId != null) {
        emit(VentaCreated(ventaId));
        // Recargar lista de ventas
        final ventas = await _repository.getAllVentas();
        final total = await _repository.calcularTotalVentas(ventas);
        emit(VentasLoaded(ventas, totalVentas: total));
      } else {
        emit(const VentasError('No se pudo crear la venta'));
      }
    } catch (e) {
      emit(VentasError('Error al crear venta: ${e.toString()}'));
    }
  }

  Future<void> _onCancelVenta(
    CancelVenta event,
    Emitter<VentasState> emit,
  ) async {
    try {
      final success = await _repository.cancelVenta(event.id);

      if (success) {
        emit(const VentaCancelled());
        // Recargar lista de ventas
        final ventas = await _repository.getAllVentas();
        final total = await _repository.calcularTotalVentas(ventas);
        emit(VentasLoaded(ventas, totalVentas: total));
      } else {
        emit(const VentasError('No se pudo cancelar la venta'));
      }
    } catch (e) {
      emit(VentasError('Error al cancelar venta: ${e.toString()}'));
    }
  }
}
