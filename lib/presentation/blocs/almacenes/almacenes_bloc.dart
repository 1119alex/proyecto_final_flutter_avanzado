import 'package:flutter_bloc/flutter_bloc.dart';
import 'almacenes_event.dart';
import 'almacenes_state.dart';
import '../../../data/repositories/almacenes_repository.dart';

class AlmacenesBloc extends Bloc<AlmacenesEvent, AlmacenesState> {
  final AlmacenesRepository _repository;

  AlmacenesBloc(this._repository) : super(const AlmacenesInitial()) {
    on<LoadAlmacenes>(_onLoadAlmacenes);
    on<CreateAlmacen>(_onCreateAlmacen);
    on<UpdateAlmacen>(_onUpdateAlmacen);
    on<DeleteAlmacen>(_onDeleteAlmacen);
    on<ToggleAlmacenEstado>(_onToggleAlmacenEstado);
  }

  Future<void> _onLoadAlmacenes(
    LoadAlmacenes event,
    Emitter<AlmacenesState> emit,
  ) async {
    try {
      emit(const AlmacenesLoading());
      final almacenes = await _repository.getAllAlmacenes();
      emit(AlmacenesLoaded(almacenes));
    } catch (e) {
      emit(AlmacenesError('Error al cargar almacenes: ${e.toString()}'));
    }
  }

  Future<void> _onCreateAlmacen(
    CreateAlmacen event,
    Emitter<AlmacenesState> emit,
  ) async {
    try {
      emit(const AlmacenesLoading());
      await _repository.createAlmacen(
        nombre: event.nombre,
        direccion: event.direccion,
        telefono: event.telefono,
      );
      emit(const AlmacenCreated());
      final almacenes = await _repository.getAllAlmacenes();
      emit(AlmacenesLoaded(almacenes));
    } catch (e) {
      emit(AlmacenesError('Error al crear almacén: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAlmacen(
    UpdateAlmacen event,
    Emitter<AlmacenesState> emit,
  ) async {
    try {
      emit(const AlmacenesLoading());
      final success = await _repository.updateAlmacen(
        id: event.id,
        nombre: event.nombre,
        direccion: event.direccion,
        telefono: event.telefono,
        activo: event.activo,
      );

      if (success) {
        emit(const AlmacenUpdated());
        final almacenes = await _repository.getAllAlmacenes();
        emit(AlmacenesLoaded(almacenes));
      } else {
        emit(const AlmacenesError('No se pudo actualizar el almacén'));
      }
    } catch (e) {
      emit(AlmacenesError('Error al actualizar almacén: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAlmacen(
    DeleteAlmacen event,
    Emitter<AlmacenesState> emit,
  ) async {
    try {
      emit(const AlmacenesLoading());
      await _repository.deleteAlmacen(event.id);
      emit(const AlmacenDeleted());
      final almacenes = await _repository.getAllAlmacenes();
      emit(AlmacenesLoaded(almacenes));
    } catch (e) {
      emit(AlmacenesError('Error al eliminar almacén: ${e.toString()}'));
    }
  }

  Future<void> _onToggleAlmacenEstado(
    ToggleAlmacenEstado event,
    Emitter<AlmacenesState> emit,
  ) async {
    try {
      emit(const AlmacenesLoading());
      final success = await _repository.toggleAlmacenEstado(
        event.id,
        event.activo,
      );

      if (success) {
        emit(const AlmacenUpdated());
        final almacenes = await _repository.getAllAlmacenes();
        emit(AlmacenesLoaded(almacenes));
      } else {
        emit(const AlmacenesError('No se pudo cambiar el estado del almacén'));
      }
    } catch (e) {
      emit(AlmacenesError('Error al cambiar estado: ${e.toString()}'));
    }
  }
}
