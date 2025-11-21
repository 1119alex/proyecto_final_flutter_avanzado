import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/connectivity_service.dart';
import '../../data/local/database/app_database.dart';
import '../../data/sync/sync_service.dart';
import '../../data/repositories/auth_repository.dart';

final getIt = GetIt.instance;

/// Configurar inyección de dependencias
Future<void> configureDependencies() async {
  // Servicios core
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(),
  );

  // Base de datos local
  getIt.registerLazySingleton<AppDatabase>(
    () => AppDatabase.instance,
  );

  // Supabase client
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // Repositorios
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<SupabaseClient>()),
  );

  // Servicio de sincronización
  getIt.registerLazySingleton<SyncService>(
    () => SyncService(
      db: getIt<AppDatabase>(),
      supabase: getIt<SupabaseClient>(),
      connectivity: getIt<ConnectivityService>(),
    ),
  );
}
