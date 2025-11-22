import 'package:flutter_bloc/flutter_bloc.dart';
import 'proveedores_event.dart';
import 'proveedores_state.dart';
import '../../../data/repositories/proveedores_repository.dart';

class ProveedoresBloc extends Bloc<ProveedoresEvent, ProveedoresState> {
  final ProveedoresRepository _repository;

  ProveedoresBloc(this._repository) : super(const ProveedoresInitial()) {
    on<LoadProveedores>(_onLoadProveedores);
    on<CreateProveedor>(_onCreateProveedor);
    on<UpdateProveedor>(_onUpdateProveedor);
    on<DeleteProveedor>(_onDeleteProveedor);
    on<ToggleProveedorEstado>(_onToggleProveedorEstado);
  }

  Future<void> _onLoadProveedores(
    LoadProveedores event,
    Emitter<ProveedoresState> emit,
  ) async {
    try {
      emit(const ProveedoresLoading());
      final proveedores = await _repository.getAllProveedores();
      emit(ProveedoresLoaded(proveedores));
    } catch (e) {
      emit(ProveedoresError('Error al cargar proveedores: ${e.toString()}'));
    }
  }

  Future<void> _onCreateProveedor(
    CreateProveedor event,
    Emitter<ProveedoresState> emit,
  ) async {
    try {
      emit(const ProveedoresLoading());
      await _repository.createProveedor(
        nombre: event.nombre,
        contacto: event.contacto,
        telefono: event.telefono,
        email: event.email,
        direccion: event.direccion,
      );
      emit(const ProveedorCreated());
      final proveedores = await _repository.getAllProveedores();
      emit(ProveedoresLoaded(proveedores));
    } catch (e) {
      emit(ProveedoresError('Error al crear proveedor: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProveedor(
    UpdateProveedor event,
    Emitter<ProveedoresState> emit,
  ) async {
    try {
      emit(const ProveedoresLoading());
      final success = await _repository.updateProveedor(
        id: event.id,
        nombre: event.nombre,
        contacto: event.contacto,
        telefono: event.telefono,
        email: event.email,
        direccion: event.direccion,
        activo: event.activo,
      );

      if (success) {
        emit(const ProveedorUpdated());
        final proveedores = await _repository.getAllProveedores();
        emit(ProveedoresLoaded(proveedores));
      } else {
        emit(const ProveedoresError('No se pudo actualizar el proveedor'));
      }
    } catch (e) {
      emit(ProveedoresError('Error al actualizar proveedor: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProveedor(
    DeleteProveedor event,
    Emitter<ProveedoresState> emit,
  ) async {
    try {
      emit(const ProveedoresLoading());
      await _repository.deleteProveedor(event.id);
      emit(const ProveedorDeleted());
      final proveedores = await _repository.getAllProveedores();
      emit(ProveedoresLoaded(proveedores));
    } catch (e) {
      emit(ProveedoresError('Error al eliminar proveedor: ${e.toString()}'));
    }
  }

  Future<void> _onToggleProveedorEstado(
    ToggleProveedorEstado event,
    Emitter<ProveedoresState> emit,
  ) async {
    try {
      emit(const ProveedoresLoading());
      final success = await _repository.toggleProveedorEstado(
        event.id,
        event.activo,
      );

      if (success) {
        emit(const ProveedorUpdated());
        final proveedores = await _repository.getAllProveedores();
        emit(ProveedoresLoaded(proveedores));
      } else {
        emit(
          const ProveedoresError('No se pudo cambiar el estado del proveedor'),
        );
      }
    } catch (e) {
      emit(ProveedoresError('Error al cambiar estado: ${e.toString()}'));
    }
  }
}
