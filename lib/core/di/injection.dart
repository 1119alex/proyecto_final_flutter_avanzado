import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/connectivity_service.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/daos/categoria_dao.dart';
import '../../data/local/daos/tienda_dao.dart';
import '../../data/local/daos/almacen_dao.dart';
import '../../data/local/daos/proveedor_dao.dart';
import '../../data/local/daos/producto_dao.dart';
import '../../data/sync/sync_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/categorias_repository.dart';
import '../../data/repositories/tiendas_repository.dart';
import '../../data/repositories/almacenes_repository.dart';
import '../../data/repositories/proveedores_repository.dart';
import '../../data/repositories/productos_repository.dart';

final getIt = GetIt.instance;

/// Configurar inyección de dependencias
Future<void> configureDependencies() async {
  // Servicios core
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // Base de datos local
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  // Supabase client
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // DAOs
  getIt.registerLazySingleton<CategoriaDao>(
    () => CategoriaDao(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<TiendaDao>(() => TiendaDao(getIt<AppDatabase>()));

  getIt.registerLazySingleton<AlmacenDao>(
    () => AlmacenDao(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ProveedorDao>(
    () => ProveedorDao(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ProductoDao>(
    () => ProductoDao(getIt<AppDatabase>()),
  );

  // Servicio de sincronización (debe registrarse antes de repositorios que lo usen)
  getIt.registerLazySingleton<SyncService>(
    () => SyncService(
      db: getIt<AppDatabase>(),
      supabase: getIt<SupabaseClient>(),
      connectivity: getIt<ConnectivityService>(),
    ),
  );

  // Repositorios
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<CategoriasRepository>(
    () => CategoriasRepository(getIt<CategoriaDao>()),
  );

  getIt.registerLazySingleton<TiendasRepository>(
    () => TiendasRepository(getIt<TiendaDao>()),
  );

  getIt.registerLazySingleton<AlmacenesRepository>(
    () => AlmacenesRepository(getIt<AlmacenDao>()),
  );

  getIt.registerLazySingleton<ProveedoresRepository>(
    () => ProveedoresRepository(getIt<ProveedorDao>()),
  );

  getIt.registerLazySingleton<ProductosRepository>(
    () => ProductosRepository(getIt<ProductoDao>()),
  );
}
