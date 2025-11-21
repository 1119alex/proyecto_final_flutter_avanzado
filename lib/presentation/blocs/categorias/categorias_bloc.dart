import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/categorias_repository.dart';
import 'categorias_event.dart';
import 'categorias_state.dart';

class CategoriasBloc extends Bloc<CategoriasEvent, CategoriasState> {
  final CategoriasRepository _repository;

  CategoriasBloc(this._repository) : super(const CategoriasInitial()) {
    on<LoadCategorias>(_onLoadCategorias);
    on<CreateCategoria>(_onCreateCategoria);
    on<UpdateCategoria>(_onUpdateCategoria);
    on<DeleteCategoria>(_onDeleteCategoria);
    on<ToggleCategoriaEstado>(_onToggleCategoriaEstado);
  }

  Future<void> _onLoadCategorias(
    LoadCategorias event,
    Emitter<CategoriasState> emit,
  ) async {
    try {
      emit(const CategoriasLoading());
      final categorias = await _repository.getAllCategorias();
      emit(CategoriasLoaded(categorias));
    } catch (e) {
      emit(CategoriasError('Error al cargar categorías: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCategoria(
    CreateCategoria event,
    Emitter<CategoriasState> emit,
  ) async {
    try {
      await _repository.createCategoria(
        nombre: event.nombre,
        descripcion: event.descripcion,
        icono: event.icono,
      );
      emit(const CategoriaCreated());
      // Recargar categorías
      final categorias = await _repository.getAllCategorias();
      emit(CategoriasLoaded(categorias));
    } catch (e) {
      emit(CategoriasError('Error al crear categoría: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategoria(
    UpdateCategoria event,
    Emitter<CategoriasState> emit,
  ) async {
    try {
      final success = await _repository.updateCategoria(
        id: event.id,
        nombre: event.nombre,
        descripcion: event.descripcion,
        icono: event.icono,
        activo: event.activo,
      );

      if (success) {
        emit(const CategoriaUpdated());
        // Recargar categorías
        final categorias = await _repository.getAllCategorias();
        emit(CategoriasLoaded(categorias));
      } else {
        emit(const CategoriasError('No se pudo actualizar la categoría'));
      }
    } catch (e) {
      emit(CategoriasError('Error al actualizar categoría: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategoria(
    DeleteCategoria event,
    Emitter<CategoriasState> emit,
  ) async {
    try {
      await _repository.deleteCategoria(event.id);
      emit(const CategoriaDeleted());
      // Recargar categorías
      final categorias = await _repository.getAllCategorias();
      emit(CategoriasLoaded(categorias));
    } catch (e) {
      emit(CategoriasError('Error al eliminar categoría: ${e.toString()}'));
    }
  }

  Future<void> _onToggleCategoriaEstado(
    ToggleCategoriaEstado event,
    Emitter<CategoriasState> emit,
  ) async {
    try {
      final success = await _repository.toggleCategoriaEstado(
        event.id,
        event.activo,
      );

      if (success) {
        // Recargar categorías
        final categorias = await _repository.getAllCategorias();
        emit(CategoriasLoaded(categorias));
      } else {
        emit(const CategoriasError('No se pudo cambiar el estado'));
      }
    } catch (e) {
      emit(CategoriasError('Error al cambiar estado: ${e.toString()}'));
    }
  }
}
