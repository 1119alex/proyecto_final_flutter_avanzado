import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/productos/productos_page.dart';
import '../../presentation/pages/productos/producto_form_page.dart';
import '../../presentation/pages/categorias/categorias_page.dart';
import '../../presentation/pages/ventas/ventas_page.dart';
import '../../presentation/pages/ventas/nueva_venta_page.dart';
import '../../presentation/pages/compras/compras_page.dart';
import '../../presentation/pages/compras/nueva_compra_page.dart';
import '../../presentation/pages/inventario/inventario_page.dart';
import '../../presentation/pages/transferencias/transferencias_page.dart';
import '../../presentation/pages/tiendas/tiendas_page.dart';
import '../../presentation/pages/almacenes/almacenes_page.dart';
import '../../presentation/pages/empleados/empleados_page.dart';
import '../../presentation/pages/clientes/clientes_page.dart';
import '../../presentation/pages/proveedores/proveedores_page.dart';
import '../../presentation/pages/reportes/reportes_page.dart';
import '../../presentation/pages/reportes/reporte_ventas_page.dart';
import '../../presentation/pages/reportes/reporte_compras_page.dart';
import '../../presentation/pages/reportes/reporte_inventario_page.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // Productos
      GoRoute(
        path: '/productos',
        name: 'productos',
        builder: (context, state) => const ProductosPage(),
      ),
      GoRoute(
        path: '/productos/nuevo',
        name: 'producto-nuevo',
        builder: (context, state) => const ProductoFormPage(),
      ),
      GoRoute(
        path: '/productos/:id',
        name: 'producto-editar',
        builder: (context, state) =>
            ProductoFormPage(productoId: state.pathParameters['id']),
      ),

      // Categorías
      GoRoute(
        path: '/categorias',
        name: 'categorias',
        builder: (context, state) => const CategoriasPage(),
      ),

      // Ventas
      GoRoute(
        path: '/ventas',
        name: 'ventas',
        builder: (context, state) => const VentasPage(),
      ),
      GoRoute(
        path: '/ventas/nueva',
        name: 'venta-nueva',
        builder: (context, state) => const NuevaVentaPage(),
      ),

      // Compras
      GoRoute(
        path: '/compras',
        name: 'compras',
        builder: (context, state) => const ComprasPage(),
      ),
      GoRoute(
        path: '/compras/nueva',
        name: 'compra-nueva',
        builder: (context, state) => const NuevaCompraPage(),
      ),

      // Inventario
      GoRoute(
        path: '/inventario',
        name: 'inventario',
        builder: (context, state) => const InventarioPage(),
      ),

      // Transferencias
      GoRoute(
        path: '/transferencias',
        name: 'transferencias',
        builder: (context, state) => const TransferenciasPage(),
      ),

      // Tiendas
      GoRoute(
        path: '/tiendas',
        name: 'tiendas',
        builder: (context, state) => const TiendasPage(),
      ),

      // Almacenes
      GoRoute(
        path: '/almacenes',
        name: 'almacenes',
        builder: (context, state) => const AlmacenesPage(),
      ),

      // Empleados
      GoRoute(
        path: '/empleados',
        name: 'empleados',
        builder: (context, state) => const EmpleadosPage(),
      ),

      // Clientes
      GoRoute(
        path: '/clientes',
        name: 'clientes',
        builder: (context, state) => const ClientesPage(),
      ),

      // Proveedores
      GoRoute(
        path: '/proveedores',
        name: 'proveedores',
        builder: (context, state) => const ProveedoresPage(),
      ),

      // Reportes
      GoRoute(
        path: '/reportes',
        name: 'reportes',
        builder: (context, state) => const ReportesPage(),
      ),
      GoRoute(
        path: '/reportes/ventas',
        name: 'reporte-ventas',
        builder: (context, state) => const ReporteVentasPage(),
      ),
      GoRoute(
        path: '/reportes/compras',
        name: 'reporte-compras',
        builder: (context, state) => const ReporteComprasPage(),
      ),
      GoRoute(
        path: '/reportes/inventario',
        name: 'reporte-inventario',
        builder: (context, state) => const ReporteInventarioPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Página no encontrada: ${state.uri}')),
    ),
  );
}

/// Stream para refrescar el router cuando cambia el estado de auth
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
