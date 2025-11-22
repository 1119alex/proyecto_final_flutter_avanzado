import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/connectivity_service.dart';
import '../local/database/app_database.dart';

/// Servicio de sincronización offline-first
class SyncService {
  final AppDatabase _db;
  final SupabaseClient _supabase;
  final ConnectivityService _connectivity;

  Timer? _syncTimer;
  bool _isSyncing = false;

  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  SyncService({
    required AppDatabase db,
    required SupabaseClient supabase,
    required ConnectivityService connectivity,
  }) : _db = db,
       _supabase = supabase,
       _connectivity = connectivity {
    _init();
  }

  void _init() {
    // Escuchar cambios de conectividad
    _connectivity.connectionStatus.listen((isConnected) {
      if (isConnected) {
        syncAll();
      }
    });

    // Iniciar sincronización periódica
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) => syncAll());
  }

  /// Sincronizar todos los datos pendientes
  Future<void> syncAll() async {
    if (_isSyncing || !_connectivity.isConnected) return;

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      // Obtener operaciones pendientes de la cola
      final pendingOps = await _db.select(_db.syncQueue).get();

      for (final op in pendingOps) {
        try {
          await _processOperation(op);
          // Eliminar de la cola si fue exitoso
          await (_db.delete(
            _db.syncQueue,
          )..where((s) => s.id.equals(op.id))).go();
        } catch (e) {
          // Incrementar contador de reintentos
          await (_db.update(
            _db.syncQueue,
          )..where((s) => s.id.equals(op.id))).write(
            SyncQueueCompanion(
              retryCount: Value(op.retryCount + 1),
              errorMessage: Value(e.toString()),
            ),
          );
          debugPrint('Error sincronizando operación ${op.id}: $e');
        }
      }

      // Descargar datos nuevos del servidor
      await _pullFromServer();

      _syncStatusController.add(SyncStatus.completed);
    } catch (e) {
      debugPrint('Error en sincronización: $e');
      _syncStatusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Procesar una operación de la cola
  Future<void> _processOperation(SyncQueueData op) async {
    final data = jsonDecode(op.data) as Map<String, dynamic>;

    switch (op.operation) {
      case 'insert':
        await _supabase.from(op.targetTable).insert(data);
        break;
      case 'update':
        await _supabase.from(op.targetTable).update(data).eq('id', op.recordId);
        break;
      case 'delete':
        await _supabase.from(op.targetTable).delete().eq('id', op.recordId);
        break;
    }
  }

  /// Descargar datos del servidor
  Future<void> _pullFromServer() async {
    try {
      // Sincronizar categorías
      await _syncTable('categorias', (data) async {
        for (final item in data) {
          await _db
              .into(_db.categorias)
              .insertOnConflictUpdate(
                CategoriasCompanion.insert(
                  id: item['id'],
                  nombre: item['nombre'],
                  descripcion: Value(item['descripcion']),
                  icono: Value(item['icono']),
                  activo: Value(item['activo'] ?? true),
                  syncStatus: const Value('sincronizado'),
                ),
              );
        }
      });

      // Sincronizar tiendas
      await _syncTable('tiendas', (data) async {
        for (final item in data) {
          await _db
              .into(_db.tiendas)
              .insertOnConflictUpdate(
                TiendasCompanion.insert(
                  id: item['id'],
                  nombre: item['nombre'],
                  direccion: item['direccion'],
                  telefono: Value(item['telefono']),
                  activo: Value(item['activo'] ?? true),
                  syncStatus: const Value('sincronizado'),
                ),
              );
        }
      });

      // Sincronizar almacenes
      await _syncTable('almacenes', (data) async {
        for (final item in data) {
          await _db
              .into(_db.almacenes)
              .insertOnConflictUpdate(
                AlmacenesCompanion.insert(
                  id: item['id'],
                  nombre: item['nombre'],
                  direccion: item['direccion'],
                  telefono: Value(item['telefono']),
                  activo: Value(item['activo'] ?? true),
                  syncStatus: const Value('sincronizado'),
                ),
              );
        }
      });

      // Sincronizar productos
      await _syncTable('productos', (data) async {
        for (final item in data) {
          await _db
              .into(_db.productos)
              .insertOnConflictUpdate(
                ProductosCompanion.insert(
                  id: item['id'],
                  codigo: item['codigo'],
                  nombre: item['nombre'],
                  descripcion: Value(item['descripcion']),
                  categoriaId: item['categoria_id'],
                  precioCompra: Value(item['precio_compra']?.toDouble() ?? 0),
                  precioVenta: Value(item['precio_venta']?.toDouble() ?? 0),
                  unidadMedida: Value(item['unidad_medida'] ?? 'unidad'),
                  stockMinimo: Value(item['stock_minimo'] ?? 0),
                  imagenUrl: Value(item['imagen_url']),
                  activo: Value(item['activo'] ?? true),
                  syncStatus: const Value('sincronizado'),
                ),
              );
        }
      });

      // Sincronizar inventario
      await _syncTable('inventario', (data) async {
        for (final item in data) {
          await _db
              .into(_db.inventario)
              .insertOnConflictUpdate(
                InventarioCompanion.insert(
                  id: item['id'],
                  productoId: item['producto_id'],
                  varianteId: Value(item['variante_id']),
                  tiendaId: Value(item['tienda_id']),
                  almacenId: Value(item['almacen_id']),
                  cantidad: Value(item['cantidad'] ?? 0),
                  syncStatus: const Value('sincronizado'),
                ),
              );
        }
      });
    } catch (e) {
      debugPrint('Error descargando datos: $e');
    }
  }

  /// Helper para sincronizar una tabla
  Future<void> _syncTable(
    String tableName,
    Future<void> Function(List<dynamic>) handler,
  ) async {
    try {
      final data = await _supabase.from(tableName).select();
      await handler(data);
    } catch (e) {
      debugPrint('Error sincronizando tabla $tableName: $e');
    }
  }

  /// Agregar operación a la cola de sincronización
  Future<void> queueOperation({
    required String tableName,
    required String recordId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .into(_db.syncQueue)
        .insert(
          SyncQueueCompanion.insert(
            targetTable: tableName,
            recordId: recordId,
            operation: operation,
            data: jsonEncode(data),
          ),
        );

    // Intentar sincronizar inmediatamente si hay conexión
    if (_connectivity.isConnected) {
      syncAll();
    }
  }

  /// Suscribirse a cambios en tiempo real
  void subscribeToRealtimeChanges() {
    // Suscribirse a cambios en categorías
    _supabase
        .channel('public:categorias')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'categorias',
          callback: (payload) {
            debugPrint('Cambio en categorías: ${payload.eventType}');
            _pullFromServer();
          },
        )
        .subscribe();

    // Suscribirse a cambios en tiendas
    _supabase
        .channel('public:tiendas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tiendas',
          callback: (payload) {
            debugPrint('Cambio en tiendas: ${payload.eventType}');
            _pullFromServer();
          },
        )
        .subscribe();

    // Suscribirse a cambios en almacenes
    _supabase
        .channel('public:almacenes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'almacenes',
          callback: (payload) {
            debugPrint('Cambio en almacenes: ${payload.eventType}');
            _pullFromServer();
          },
        )
        .subscribe();

    // Suscribirse a cambios en proveedores
    _supabase
        .channel('public:proveedores')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'proveedores',
          callback: (payload) {
            debugPrint('Cambio en proveedores: ${payload.eventType}');
            _pullFromServer();
          },
        )
        .subscribe();

    // Suscribirse a cambios en productos
    _supabase
        .channel('public:productos')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'productos',
          callback: (payload) {
            debugPrint('Cambio en productos: ${payload.eventType}');
            _pullFromServer();
          },
        )
        .subscribe();

    // Suscribirse a cambios en inventario
    _supabase
        .channel('public:inventario')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'inventario',
          callback: (payload) {
            debugPrint('Cambio en inventario: ${payload.eventType}');
            _pullFromServer();
          },
        )
        .subscribe();

    // Suscribirse a cambios en clientes
    _supabase
        .channel('public:clientes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'clientes',
          callback: (payload) {
            debugPrint('Cambio en clientes: ${payload.eventType}');
            _pullFromServer();
          },
        )
        .subscribe();
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}

/// Estados de sincronización
enum SyncStatus { idle, syncing, completed, error }
