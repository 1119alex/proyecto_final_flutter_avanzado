import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/network/connectivity_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/categorias_repository.dart';
import 'data/repositories/tiendas_repository.dart';
import 'data/repositories/almacenes_repository.dart';
import 'data/repositories/proveedores_repository.dart';
import 'data/repositories/productos_repository.dart';
import 'data/sync/sync_service.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/connectivity/connectivity_bloc.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/categorias/categorias_bloc.dart';
import 'presentation/blocs/tiendas/tiendas_bloc.dart';
import 'presentation/blocs/almacenes/almacenes_bloc.dart';
import 'presentation/blocs/proveedores/proveedores_bloc.dart';
import 'presentation/blocs/productos/productos_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Configurar inyección de dependencias
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth Bloc
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: getIt<AuthRepository>())
                ..add(AuthCheckRequested()),
        ),

        // Connectivity Bloc
        BlocProvider<ConnectivityBloc>(
          create: (context) => ConnectivityBloc(
            connectivityService: getIt<ConnectivityService>(),
          )..add(ConnectivityStarted()),
        ),

        // Theme Bloc
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(ThemeLoadRequested()),
        ),

        // Categorias Bloc
        BlocProvider<CategoriasBloc>(
          create: (context) => CategoriasBloc(getIt<CategoriasRepository>()),
        ),

        // Tiendas Bloc
        BlocProvider<TiendasBloc>(
          create: (context) => TiendasBloc(getIt<TiendasRepository>()),
        ),

        // Almacenes Bloc
        BlocProvider<AlmacenesBloc>(
          create: (context) => AlmacenesBloc(getIt<AlmacenesRepository>()),
        ),

        // Proveedores Bloc
        BlocProvider<ProveedoresBloc>(
          create: (context) => ProveedoresBloc(getIt<ProveedoresRepository>()),
        ),

        // Productos Bloc
        BlocProvider<ProductosBloc>(
          create: (context) => ProductosBloc(getIt<ProductosRepository>()),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Iniciar servicio de sincronización
          final syncService = getIt<SyncService>();
          syncService.subscribeToRealtimeChanges();

          // Crear router con AuthBloc
          final appRouter = AppRouter(authBloc: context.read<AuthBloc>());

          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp.router(
                title: 'LibroStock',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                routerConfig: appRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
