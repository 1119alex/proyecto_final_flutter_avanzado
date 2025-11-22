import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/compras_repository.dart';
import 'compras_event.dart';
import 'compras_state.dart';

class ComprasBloc extends Bloc<ComprasEvent, ComprasState> {
  final ComprasRepository _repository;

  ComprasBloc(this._repository) : super(const ComprasInitial()) {
    on<LoadCompras>(_onLoadCompras);
    on<LoadComprasByAlmacen>(_onLoadComprasByAlmacen);
    on<LoadComprasByFecha>(_onLoadComprasByFecha);
    on<LoadCompraDetalle>(_onLoadCompraDetalle);
    on<CreateCompra>(_onCreateCompra);
    on<CancelCompra>(_onCancelCompra);
  }

  Future<void> _onLoadCompras(
    LoadCompras event,
    Emitter<ComprasState> emit,
  ) async {
    try {
      emit(const ComprasLoading());
      final compras = await _repository.getAllCompras();
      final total = await _repository.calcularTotalCompras(compras);
      emit(ComprasLoaded(compras, totalCompras: total));
    } catch (e) {
      emit(ComprasError('Error al cargar compras: ${e.toString()}'));
    }
  }

  Future<void> _onLoadComprasByAlmacen(
    LoadComprasByAlmacen event,
    Emitter<ComprasState> emit,
  ) async {
    try {
      emit(const ComprasLoading());
      final compras = await _repository.getComprasByAlmacen(event.almacenId);
      final total = await _repository.calcularTotalCompras(compras);
      emit(
        ComprasLoaded(
          compras,
          totalCompras: total,
          filtroAlmacenId: event.almacenId,
        ),
      );
    } catch (e) {
      emit(ComprasError('Error al cargar compras: ${e.toString()}'));
    }
  }

  Future<void> _onLoadComprasByFecha(
    LoadComprasByFecha event,
    Emitter<ComprasState> emit,
  ) async {
    try {
      emit(const ComprasLoading());
      final compras = await _repository.getComprasByFecha(
        event.inicio,
        event.fin,
      );
      final total = await _repository.calcularTotalCompras(compras);
      emit(
        ComprasLoaded(
          compras,
          totalCompras: total,
          filtroFechaInicio: event.inicio,
          filtroFechaFin: event.fin,
        ),
      );
    } catch (e) {
      emit(ComprasError('Error al cargar compras: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCompraDetalle(
    LoadCompraDetalle event,
    Emitter<ComprasState> emit,
  ) async {
    try {
      emit(const ComprasLoading());
      final compra = await _repository.getCompraById(event.compraId);
      if (compra == null) {
        emit(const ComprasError('Compra no encontrada'));
        return;
      }
      final detalles = await _repository.getDetallesByCompra(event.compraId);
      final proveedor = await _repository.getProveedorById(compra.proveedorId);
      emit(
        CompraDetalleLoaded(
          compra: compra,
          detalles: detalles,
          proveedor: proveedor,
        ),
      );
    } catch (e) {
      emit(ComprasError('Error al cargar detalle de compra: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCompra(
    CreateCompra event,
    Emitter<ComprasState> emit,
  ) async {
    try {
      // Convertir CompraDetalleItem a CompraDetalleData
      final detallesData = event.detalles
          .map(
            (d) => CompraDetalleData(
              productoId: d.productoId,
              varianteId: d.varianteId,
              cantidad: d.cantidad,
              precioUnitario: d.precioUnitario,
            ),
          )
          .toList();

      final compraId = await _repository.createCompra(
        proveedorId: event.proveedorId,
        almacenId: event.almacenId,
        usuarioId: event.usuarioId,
        observaciones: event.observaciones,
        detalles: detallesData,
      );

      if (compraId != null) {
        emit(CompraCreated(compraId));
        // Recargar lista de compras
        final compras = await _repository.getAllCompras();
        final total = await _repository.calcularTotalCompras(compras);
        emit(ComprasLoaded(compras, totalCompras: total));
      } else {
        emit(const ComprasError('No se pudo crear la compra'));
      }
    } catch (e) {
      emit(ComprasError('Error al crear compra: ${e.toString()}'));
    }
  }

  Future<void> _onCancelCompra(
    CancelCompra event,
    Emitter<ComprasState> emit,
  ) async {
    try {
      final success = await _repository.cancelCompra(event.id);

      if (success) {
        emit(const CompraCancelled());
        // Recargar lista de compras
        final compras = await _repository.getAllCompras();
        final total = await _repository.calcularTotalCompras(compras);
        emit(ComprasLoaded(compras, totalCompras: total));
      } else {
        emit(const ComprasError('No se pudo cancelar la compra'));
      }
    } catch (e) {
      emit(ComprasError('Error al cancelar compra: ${e.toString()}'));
    }
  }
}
