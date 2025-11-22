import 'package:flutter_bloc/flutter_bloc.dart';
import 'tiendas_event.dart';
import 'tiendas_state.dart';
import '../../../data/repositories/tiendas_repository.dart';

class TiendasBloc extends Bloc<TiendasEvent, TiendasState> {
  final TiendasRepository _repository;

  TiendasBloc(this._repository) : super(const TiendasInitial()) {
    on<LoadTiendas>(_onLoadTiendas);
    on<CreateTienda>(_onCreateTienda);
    on<UpdateTienda>(_onUpdateTienda);
    on<DeleteTienda>(_onDeleteTienda);
    on<ToggleTiendaEstado>(_onToggleTiendaEstado);
  }

  Future<void> _onLoadTiendas(
    LoadTiendas event,
    Emitter<TiendasState> emit,
  ) async {
    try {
      emit(const TiendasLoading());
      final tiendas = await _repository.getAllTiendas();
      emit(TiendasLoaded(tiendas));
    } catch (e) {
      emit(TiendasError('Error al cargar tiendas: ${e.toString()}'));
    }
  }

  Future<void> _onCreateTienda(
    CreateTienda event,
    Emitter<TiendasState> emit,
  ) async {
    try {
      emit(const TiendasLoading());
      await _repository.createTienda(
        nombre: event.nombre,
        direccion: event.direccion,
        telefono: event.telefono,
      );
      emit(const TiendaCreated());
      final tiendas = await _repository.getAllTiendas();
      emit(TiendasLoaded(tiendas));
    } catch (e) {
      emit(TiendasError('Error al crear tienda: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTienda(
    UpdateTienda event,
    Emitter<TiendasState> emit,
  ) async {
    try {
      emit(const TiendasLoading());
      final success = await _repository.updateTienda(
        id: event.id,
        nombre: event.nombre,
        direccion: event.direccion,
        telefono: event.telefono,
        activo: event.activo,
      );

      if (success) {
        emit(const TiendaUpdated());
        final tiendas = await _repository.getAllTiendas();
        emit(TiendasLoaded(tiendas));
      } else {
        emit(const TiendasError('No se pudo actualizar la tienda'));
      }
    } catch (e) {
      emit(TiendasError('Error al actualizar tienda: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTienda(
    DeleteTienda event,
    Emitter<TiendasState> emit,
  ) async {
    try {
      emit(const TiendasLoading());
      await _repository.deleteTienda(event.id);
      emit(const TiendaDeleted());
      final tiendas = await _repository.getAllTiendas();
      emit(TiendasLoaded(tiendas));
    } catch (e) {
      emit(TiendasError('Error al eliminar tienda: ${e.toString()}'));
    }
  }

  Future<void> _onToggleTiendaEstado(
    ToggleTiendaEstado event,
    Emitter<TiendasState> emit,
  ) async {
    try {
      emit(const TiendasLoading());
      final success = await _repository.toggleTiendaEstado(
        event.id,
        event.activo,
      );

      if (success) {
        emit(const TiendaUpdated());
        final tiendas = await _repository.getAllTiendas();
        emit(TiendasLoaded(tiendas));
      } else {
        emit(const TiendasError('No se pudo cambiar el estado de la tienda'));
      }
    } catch (e) {
      emit(TiendasError('Error al cambiar estado: ${e.toString()}'));
    }
  }
}
