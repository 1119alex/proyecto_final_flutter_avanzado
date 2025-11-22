import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/transferencias_repository.dart';
import 'transferencias_event.dart';
import 'transferencias_state.dart';

class TransferenciasBloc
    extends Bloc<TransferenciasEvent, TransferenciasState> {
  final TransferenciasRepository _repository;

  TransferenciasBloc(this._repository) : super(const TransferenciasInitial()) {
    on<LoadTransferencias>(_onLoadTransferencias);
    on<LoadTransferenciasByEstado>(_onLoadTransferenciasByEstado);
    on<LoadTransferenciasByFecha>(_onLoadTransferenciasByFecha);
    on<LoadTransferenciaDetalle>(_onLoadTransferenciaDetalle);
    on<CreateTransferencia>(_onCreateTransferencia);
    on<UpdateTransferenciaEstado>(_onUpdateTransferenciaEstado);
    on<CompletarTransferencia>(_onCompletarTransferencia);
    on<CancelarTransferencia>(_onCancelarTransferencia);
    on<MarcarEnTransito>(_onMarcarEnTransito);
  }

  Future<void> _onLoadTransferencias(
    LoadTransferencias event,
    Emitter<TransferenciasState> emit,
  ) async {
    try {
      emit(const TransferenciasLoading());
      final transferencias = await _repository.getAllTransferencias();
      final conteo = await _repository.contarPorEstado();
      emit(TransferenciasLoaded(transferencias, conteoPorEstado: conteo));
    } catch (e) {
      emit(
        TransferenciasError('Error al cargar transferencias: ${e.toString()}'),
      );
    }
  }

  Future<void> _onLoadTransferenciasByEstado(
    LoadTransferenciasByEstado event,
    Emitter<TransferenciasState> emit,
  ) async {
    try {
      emit(const TransferenciasLoading());
      final transferencias = await _repository.getTransferenciasByEstado(
        event.estado,
      );
      final conteo = await _repository.contarPorEstado();
      emit(
        TransferenciasLoaded(
          transferencias,
          conteoPorEstado: conteo,
          filtroEstado: event.estado,
        ),
      );
    } catch (e) {
      emit(
        TransferenciasError('Error al cargar transferencias: ${e.toString()}'),
      );
    }
  }

  Future<void> _onLoadTransferenciasByFecha(
    LoadTransferenciasByFecha event,
    Emitter<TransferenciasState> emit,
  ) async {
    try {
      emit(const TransferenciasLoading());
      final transferencias = await _repository.getTransferenciasByFecha(
        event.inicio,
        event.fin,
      );
      final conteo = await _repository.contarPorEstado();
      emit(
        TransferenciasLoaded(
          transferencias,
          conteoPorEstado: conteo,
          filtroFechaInicio: event.inicio,
          filtroFechaFin: event.fin,
        ),
      );
    } catch (e) {
      emit(
        TransferenciasError('Error al cargar transferencias: ${e.toString()}'),
      );
    }
  }

  Future<void> _onLoadTransferenciaDetalle(
    LoadTransferenciaDetalle event,
    Emitter<TransferenciasState> emit,
  ) async {
    try {
      emit(const TransferenciasLoading());
      final transferencia = await _repository.getTransferenciaById(
        event.transferenciaId,
      );
      if (transferencia == null) {
        emit(const TransferenciasError('Transferencia no encontrada'));
        return;
      }
      final detalles = await _repository.getDetallesByTransferencia(
        event.transferenciaId,
      );
      emit(
        TransferenciaDetalleLoaded(
          transferencia: transferencia,
          detalles: detalles,
        ),
      );
    } catch (e) {
      emit(TransferenciasError('Error al cargar detalle: ${e.toString()}'));
    }
  }

  Future<void> _onCreateTransferencia(
    CreateTransferencia event,
    Emitter<TransferenciasState> emit,
  ) async {
    try {
      final detallesData = event.detalles
          .map(
            (d) => TransferenciaDetalleData(
              productoId: d.productoId,
              varianteId: d.varianteId,
              cantidad: d.cantidad,
            ),
          )
          .toList();

      final transferenciaId = await _repository.createTransferencia(
        usuarioId: event.usuarioId,
        origenTiendaId: event.origenTiendaId,
        origenAlmacenId: event.origenAlmacenId,
        destinoTiendaId: event.destinoTiendaId,
        destinoAlmacenId: event.destinoAlmacenId,
        observaciones: event.observaciones,
        detalles: detallesData,
      );

      if (transferenciaId != null) {
        emit(TransferenciaCreated(transferenciaId));
        // Recargar lista
        final transferencias = await _repository.getAllTransferencias();
        final conteo = await _repository.contarPorEstado();
        emit(TransferenciasLoaded(transferencias, conteoPorEstado: conteo));
      } else {
        emit(const TransferenciasError('No se pudo crear la transferencia'));
      }
    } catch (e) {
      emit(
        TransferenciasError('Error al crear transferencia: ${e.toString()}'),
      );
    }
  }

  Future<void> _onUpdateTransferenciaEstado(
    UpdateTransferenciaEstado event,
    Emitter<TransferenciasState> emit,
  ) async {
    try {
      final success = await _repository.updateEstado(
        event.id,
        event.nuevoEstado,
      );

      if (success) {
        emit(TransferenciaEstadoUpdated(event.nuevoEstado));
        // Recargar lista
        final transferencias = await _repository.getAllTransferencias();
        final conteo = await _repository.contarPorEstado();
        emit(TransferenciasLoaded(transferencias, conteoPorEstado: conteo));
      } else {
        emit(const TransferenciasError('No se pudo actualizar el estado'));
      }
    } catch (e) {
      emit(TransferenciasError('Error al actualizar estado: ${e.toString()}'));
    }
  }

  Future<void> _onCompletarTransferencia(
    CompletarTransferencia event,
    Emitter<TransferenciasState> emit,
  ) async {
    try {
      final success = await _repository.completarTransferencia(event.id);

      if (success) {
        emit(const TransferenciaEstadoUpdated('completada'));
        // Recargar lista
        final transferencias = await _repository.getAllTransferencias();
        final conteo = await _repository.contarPorEstado();
        emit(TransferenciasLoaded(transferencias, conteoPorEstado: conteo));
      } else {
        emit(
          const TransferenciasError('No se pudo completar la transferencia'),
        );
      }
    } catch (e) {
      emit(
        TransferenciasError(
          'Error al completar transferencia: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onCancelarTransferencia(
    CancelarTransferencia event,
    Emitter<TransferenciasState> emit,
  ) async {
    try {
      final success = await _repository.cancelarTransferencia(event.id);

      if (success) {
        emit(const TransferenciaEstadoUpdated('cancelada'));
        // Recargar lista
        final transferencias = await _repository.getAllTransferencias();
        final conteo = await _repository.contarPorEstado();
        emit(TransferenciasLoaded(transferencias, conteoPorEstado: conteo));
      } else {
        emit(const TransferenciasError('No se pudo cancelar la transferencia'));
      }
    } catch (e) {
      emit(
        TransferenciasError('Error al cancelar transferencia: ${e.toString()}'),
      );
    }
  }

  Future<void> _onMarcarEnTransito(
    MarcarEnTransito event,
    Emitter<TransferenciasState> emit,
  ) async {
    try {
      final success = await _repository.marcarEnTransito(event.id);

      if (success) {
        emit(const TransferenciaEstadoUpdated('en_transito'));
        // Recargar lista
        final transferencias = await _repository.getAllTransferencias();
        final conteo = await _repository.contarPorEstado();
        emit(TransferenciasLoaded(transferencias, conteoPorEstado: conteo));
      } else {
        emit(const TransferenciasError('No se pudo marcar en transito'));
      }
    } catch (e) {
      emit(TransferenciasError('Error al marcar en transito: ${e.toString()}'));
    }
  }
}
