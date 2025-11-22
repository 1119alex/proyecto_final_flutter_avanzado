import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/usuarios_repository.dart';
import 'usuarios_event.dart';
import 'usuarios_state.dart';

class UsuariosBloc extends Bloc<UsuariosEvent, UsuariosState> {
  final UsuariosRepository _repository;

  UsuariosBloc(this._repository) : super(const UsuariosInitial()) {
    on<LoadUsuarios>(_onLoadUsuarios);
    on<LoadUsuariosByRol>(_onLoadUsuariosByRol);
    on<LoadUsuariosByTienda>(_onLoadUsuariosByTienda);
    on<CreateUsuario>(_onCreateUsuario);
    on<UpdateUsuario>(_onUpdateUsuario);
    on<ToggleUsuarioActivo>(_onToggleUsuarioActivo);
    on<DeleteUsuario>(_onDeleteUsuario);
  }

  Future<void> _onLoadUsuarios(
    LoadUsuarios event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      emit(const UsuariosLoading());
      final usuarios = await _repository.getAllUsuarios();
      final conteo = await _repository.contarPorRol();
      emit(UsuariosLoaded(usuarios, conteoPorRol: conteo));
    } catch (e) {
      emit(UsuariosError('Error al cargar usuarios: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUsuariosByRol(
    LoadUsuariosByRol event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      emit(const UsuariosLoading());
      final usuarios = await _repository.getUsuariosByRol(event.rol);
      final conteo = await _repository.contarPorRol();
      emit(
        UsuariosLoaded(usuarios, conteoPorRol: conteo, filtroRol: event.rol),
      );
    } catch (e) {
      emit(UsuariosError('Error al cargar usuarios: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUsuariosByTienda(
    LoadUsuariosByTienda event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      emit(const UsuariosLoading());
      final usuarios = await _repository.getUsuariosByTienda(event.tiendaId);
      final conteo = await _repository.contarPorRol();
      emit(
        UsuariosLoaded(
          usuarios,
          conteoPorRol: conteo,
          filtroTienda: event.tiendaId,
        ),
      );
    } catch (e) {
      emit(UsuariosError('Error al cargar usuarios: ${e.toString()}'));
    }
  }

  Future<void> _onCreateUsuario(
    CreateUsuario event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      final usuarioId = await _repository.createUsuario(
        id: event.id,
        email: event.email,
        nombre: event.nombre,
        apellido: event.apellido,
        rol: event.rol,
        tiendaId: event.tiendaId,
        almacenId: event.almacenId,
      );

      if (usuarioId != null) {
        emit(UsuarioCreated(usuarioId));
        // Recargar lista
        final usuarios = await _repository.getAllUsuarios();
        final conteo = await _repository.contarPorRol();
        emit(UsuariosLoaded(usuarios, conteoPorRol: conteo));
      } else {
        emit(const UsuariosError('No se pudo crear el usuario'));
      }
    } catch (e) {
      emit(UsuariosError('Error al crear usuario: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUsuario(
    UpdateUsuario event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      final success = await _repository.updateUsuario(
        id: event.id,
        nombre: event.nombre,
        apellido: event.apellido,
        rol: event.rol,
        tiendaId: event.tiendaId,
        almacenId: event.almacenId,
      );

      if (success) {
        emit(const UsuarioUpdated());
        // Recargar lista
        final usuarios = await _repository.getAllUsuarios();
        final conteo = await _repository.contarPorRol();
        emit(UsuariosLoaded(usuarios, conteoPorRol: conteo));
      } else {
        emit(const UsuariosError('No se pudo actualizar el usuario'));
      }
    } catch (e) {
      emit(UsuariosError('Error al actualizar usuario: ${e.toString()}'));
    }
  }

  Future<void> _onToggleUsuarioActivo(
    ToggleUsuarioActivo event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      final success = await _repository.toggleActivo(event.id, event.activo);

      if (success) {
        // Recargar lista
        final usuarios = await _repository.getAllUsuarios();
        final conteo = await _repository.contarPorRol();
        emit(UsuariosLoaded(usuarios, conteoPorRol: conteo));
      } else {
        emit(const UsuariosError('No se pudo cambiar el estado'));
      }
    } catch (e) {
      emit(UsuariosError('Error al cambiar estado: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteUsuario(
    DeleteUsuario event,
    Emitter<UsuariosState> emit,
  ) async {
    try {
      final success = await _repository.deleteUsuario(event.id);

      if (success) {
        emit(const UsuarioDeleted());
        // Recargar lista
        final usuarios = await _repository.getAllUsuarios();
        final conteo = await _repository.contarPorRol();
        emit(UsuariosLoaded(usuarios, conteoPorRol: conteo));
      } else {
        emit(const UsuariosError('No se pudo eliminar el usuario'));
      }
    } catch (e) {
      emit(UsuariosError('Error al eliminar usuario: ${e.toString()}'));
    }
  }
}
