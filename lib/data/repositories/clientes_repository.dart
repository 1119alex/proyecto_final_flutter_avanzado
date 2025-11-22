import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../local/database/app_database.dart';
import '../local/daos/cliente_dao.dart';
import '../sync/sync_service.dart';
import '../../core/di/injection.dart';

class ClientesRepository {
  final ClienteDao _clienteDao;

  // Usar getter para obtener SyncService de forma lazy
  SyncService get _syncService => getIt<SyncService>();

  ClientesRepository(this._clienteDao);

  Future<List<Cliente>> getAllClientes() async {
    return await _clienteDao.getAllClientes();
  }

  Future<List<Cliente>> searchClientes(String query) async {
    return await _clienteDao.searchClientes(query);
  }

  Future<Cliente?> getClienteById(String id) async {
    return await _clienteDao.getClienteById(id);
  }

  Future<Cliente?> getClienteByNit(String nit) async {
    return await _clienteDao.getClienteByNit(nit);
  }

  // Verificar si el NIT ya existe
  Future<bool> nitExists(String nit, {String? excludeId}) async {
    if (nit.isEmpty) return false;
    final cliente = await _clienteDao.getClienteByNit(nit);
    if (cliente == null) return false;
    if (excludeId != null && cliente.id == excludeId) return false;
    return true;
  }

  Future<bool> createCliente({
    required String nombre,
    String? nit,
    String? telefono,
    String? email,
    String? direccion,
  }) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final cliente = ClientesCompanion(
        id: Value(id),
        nombre: Value(nombre),
        nit: Value(nit),
        telefono: Value(telefono),
        email: Value(email),
        direccion: Value(direccion),
        activo: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pendiente'),
      );

      await _clienteDao.insertCliente(cliente);

      // Encolar para sincronización
      await _syncService.queueOperation(
        tableName: 'clientes',
        recordId: id,
        operation: 'insert',
        data: {
          'id': id,
          'nombre': nombre,
          'nit': nit,
          'telefono': telefono,
          'email': email,
          'direccion': direccion,
          'activo': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCliente({
    required String id,
    required String nombre,
    String? nit,
    String? telefono,
    String? email,
    String? direccion,
    required bool activo,
  }) async {
    try {
      final now = DateTime.now();

      final cliente = ClientesCompanion(
        id: Value(id),
        nombre: Value(nombre),
        nit: Value(nit),
        telefono: Value(telefono),
        email: Value(email),
        direccion: Value(direccion),
        activo: Value(activo),
        updatedAt: Value(now),
        syncStatus: const Value('pendiente'),
      );

      await _clienteDao.updateCliente(cliente);

      // Encolar para sincronización
      await _syncService.queueOperation(
        tableName: 'clientes',
        recordId: id,
        operation: 'update',
        data: {
          'id': id,
          'nombre': nombre,
          'nit': nit,
          'telefono': telefono,
          'email': email,
          'direccion': direccion,
          'activo': activo,
          'updated_at': now.toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCliente(String id) async {
    try {
      await _clienteDao.softDeleteCliente(id);

      // Encolar para sincronización (soft delete)
      await _syncService.queueOperation(
        tableName: 'clientes',
        recordId: id,
        operation: 'update',
        data: {
          'id': id,
          'activo': false,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleEstado(String id, bool activo) async {
    try {
      final cliente = await _clienteDao.getClienteById(id);
      if (cliente == null) return false;

      return await updateCliente(
        id: id,
        nombre: cliente.nombre,
        nit: cliente.nit,
        telefono: cliente.telefono,
        email: cliente.email,
        direccion: cliente.direccion,
        activo: activo,
      );
    } catch (e) {
      return false;
    }
  }

  Stream<List<Cliente>> watchAllClientes() {
    return _clienteDao.watchAllClientes();
  }
}
