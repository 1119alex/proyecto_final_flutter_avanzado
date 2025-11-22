import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/daos/proveedor_dao.dart';
import '../sync/sync_service.dart';
import '../../core/di/injection.dart';

class ProveedoresRepository {
  final ProveedorDao _proveedorDao;
  final _uuid = const Uuid();

  ProveedoresRepository(this._proveedorDao);

  SyncService get _syncService => getIt<SyncService>();

  Stream<List<Proveedor>> watchAllProveedores() {
    return _proveedorDao.watchAllProveedores();
  }

  Future<List<Proveedor>> getAllProveedores() {
    return _proveedorDao.getAllProveedores();
  }

  Future<Proveedor?> getProveedorById(String id) {
    return _proveedorDao.getProveedorById(id);
  }

  Future<int> createProveedor({
    required String nombre,
    String? contacto,
    String? telefono,
    String? email,
    String? direccion,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = ProveedoresCompanion(
      id: Value(id),
      nombre: Value(nombre),
      contacto: Value(contacto),
      telefono: Value(telefono),
      email: Value(email),
      direccion: Value(direccion),
      activo: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
      syncStatus: const Value('pendiente'),
    );

    final result = await _proveedorDao.insertProveedor(companion);

    await _syncService.queueOperation(
      tableName: 'proveedores',
      recordId: id,
      operation: 'insert',
      data: {
        'id': id,
        'nombre': nombre,
        'contacto': contacto,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        'activo': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    );

    return result;
  }

  Future<bool> updateProveedor({
    required String id,
    required String nombre,
    String? contacto,
    String? telefono,
    String? email,
    String? direccion,
    required bool activo,
  }) async {
    final proveedorExistente = await _proveedorDao.getProveedorById(id);
    if (proveedorExistente == null) return false;

    final now = DateTime.now();

    final companion = ProveedoresCompanion(
      id: Value(id),
      nombre: Value(nombre),
      contacto: Value(contacto),
      telefono: Value(telefono),
      email: Value(email),
      direccion: Value(direccion),
      activo: Value(activo),
      createdAt: Value(proveedorExistente.createdAt),
      updatedAt: Value(now),
      syncStatus: const Value('pendiente'),
    );

    final result = await _proveedorDao.updateProveedor(companion);

    if (result) {
      await _syncService.queueOperation(
        tableName: 'proveedores',
        recordId: id,
        operation: 'update',
        data: {
          'id': id,
          'nombre': nombre,
          'contacto': contacto,
          'telefono': telefono,
          'email': email,
          'direccion': direccion,
          'activo': activo,
          'created_at': proveedorExistente.createdAt.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );
    }

    return result;
  }

  Future<int> deleteProveedor(String id) async {
    final result = await _proveedorDao.deleteProveedor(id);

    if (result > 0) {
      await _syncService.queueOperation(
        tableName: 'proveedores',
        recordId: id,
        operation: 'update',
        data: {
          'id': id,
          'activo': false,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    }

    return result;
  }

  Future<bool> toggleProveedorEstado(String id, bool activo) async {
    final proveedor = await _proveedorDao.getProveedorById(id);
    if (proveedor == null) return false;

    return await updateProveedor(
      id: id,
      nombre: proveedor.nombre,
      contacto: proveedor.contacto,
      telefono: proveedor.telefono,
      email: proveedor.email,
      direccion: proveedor.direccion,
      activo: activo,
    );
  }
}
