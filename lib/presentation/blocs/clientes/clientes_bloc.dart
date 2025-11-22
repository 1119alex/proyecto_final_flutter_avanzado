import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/clientes_repository.dart';
import 'clientes_event.dart';
import 'clientes_state.dart';

class ClientesBloc extends Bloc<ClientesEvent, ClientesState> {
  final ClientesRepository _repository;

  ClientesBloc(this._repository) : super(const ClientesInitial()) {
    on<LoadClientes>(_onLoadClientes);
    on<SearchClientes>(_onSearchClientes);
    on<CreateCliente>(_onCreateCliente);
    on<UpdateCliente>(_onUpdateCliente);
    on<DeleteCliente>(_onDeleteCliente);
    on<ToggleClienteEstado>(_onToggleClienteEstado);
  }

  Future<void> _onLoadClientes(
    LoadClientes event,
    Emitter<ClientesState> emit,
  ) async {
    try {
      emit(const ClientesLoading());
      final clientes = await _repository.getAllClientes();
      emit(ClientesLoaded(clientes));
    } catch (e) {
      emit(ClientesError('Error al cargar clientes: ${e.toString()}'));
    }
  }

  Future<void> _onSearchClientes(
    SearchClientes event,
    Emitter<ClientesState> emit,
  ) async {
    try {
      emit(const ClientesLoading());
      final clientes = await _repository.searchClientes(event.query);
      emit(ClientesLoaded(clientes));
    } catch (e) {
      emit(ClientesError('Error al buscar clientes: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCliente(
    CreateCliente event,
    Emitter<ClientesState> emit,
  ) async {
    try {
      // Verificar NIT único si se proporciona
      if (event.nit != null && event.nit!.isNotEmpty) {
        final nitExists = await _repository.nitExists(event.nit!);
        if (nitExists) {
          emit(const ClientesError('Ya existe un cliente con ese NIT'));
          final clientes = await _repository.getAllClientes();
          emit(ClientesLoaded(clientes));
          return;
        }
      }

      final success = await _repository.createCliente(
        nombre: event.nombre,
        nit: event.nit,
        telefono: event.telefono,
        email: event.email,
        direccion: event.direccion,
      );

      if (success) {
        emit(const ClienteCreated());
        final clientes = await _repository.getAllClientes();
        emit(ClientesLoaded(clientes));
      } else {
        emit(const ClientesError('No se pudo crear el cliente'));
      }
    } catch (e) {
      emit(ClientesError('Error al crear cliente: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCliente(
    UpdateCliente event,
    Emitter<ClientesState> emit,
  ) async {
    try {
      // Verificar NIT único si se proporciona (excluyendo el cliente actual)
      if (event.nit != null && event.nit!.isNotEmpty) {
        final nitExists = await _repository.nitExists(
          event.nit!,
          excludeId: event.id,
        );
        if (nitExists) {
          emit(const ClientesError('Ya existe otro cliente con ese NIT'));
          final clientes = await _repository.getAllClientes();
          emit(ClientesLoaded(clientes));
          return;
        }
      }

      final success = await _repository.updateCliente(
        id: event.id,
        nombre: event.nombre,
        nit: event.nit,
        telefono: event.telefono,
        email: event.email,
        direccion: event.direccion,
        activo: event.activo,
      );

      if (success) {
        emit(const ClienteUpdated());
        final clientes = await _repository.getAllClientes();
        emit(ClientesLoaded(clientes));
      } else {
        emit(const ClientesError('No se pudo actualizar el cliente'));
      }
    } catch (e) {
      emit(ClientesError('Error al actualizar cliente: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCliente(
    DeleteCliente event,
    Emitter<ClientesState> emit,
  ) async {
    try {
      final success = await _repository.deleteCliente(event.id);

      if (success) {
        emit(const ClienteDeleted());
        final clientes = await _repository.getAllClientes();
        emit(ClientesLoaded(clientes));
      } else {
        emit(const ClientesError('No se pudo eliminar el cliente'));
      }
    } catch (e) {
      emit(ClientesError('Error al eliminar cliente: ${e.toString()}'));
    }
  }

  Future<void> _onToggleClienteEstado(
    ToggleClienteEstado event,
    Emitter<ClientesState> emit,
  ) async {
    try {
      final success = await _repository.toggleEstado(event.id, event.activo);

      if (success) {
        emit(const ClienteUpdated());
        final clientes = await _repository.getAllClientes();
        emit(ClientesLoaded(clientes));
      } else {
        emit(const ClientesError('No se pudo cambiar el estado del cliente'));
      }
    } catch (e) {
      emit(ClientesError('Error al cambiar estado: ${e.toString()}'));
    }
  }
}
