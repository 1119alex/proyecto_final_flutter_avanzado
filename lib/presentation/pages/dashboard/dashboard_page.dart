import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/connectivity/connectivity_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../../core/theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LibroStock'),
        actions: [
          // Indicador de conectividad
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, state) {
              final isOnline = state is ConnectivityOnline;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Chip(
                  avatar: Icon(
                    isOnline ? Icons.cloud_done : Icons.cloud_off,
                    size: 18,
                    color: isOnline ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                  label: Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                  ),
                  backgroundColor: (isOnline ? AppTheme.successColor : AppTheme.errorColor)
                      .withOpacity(0.1),
                ),
              );
            },
          ),
          // Toggle tema
          IconButton(
            icon: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return Icon(
                  state.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                );
              },
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(ThemeToggled());
            },
          ),
          // Menú usuario
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              } else if (value == 'profile') {
                context.push('/profile');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      final userData = state.userData;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${userData?['nombre'] ?? ''} ${userData?['apellido'] ?? ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            state.user.email ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }
                    return const Text('Mi Perfil');
                  },
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen del día
              _buildSummaryCards(context),
              const SizedBox(height: 24),

              // Menú principal
              Text(
                'Menú Principal',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildMainMenu(context),

              const SizedBox(height: 24),

              // Accesos rápidos
              Text(
                'Operaciones Rápidas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _SummaryCard(
          title: 'Ventas Hoy',
          value: 'Bs. 0.00',
          icon: Icons.point_of_sale,
          color: AppTheme.successColor,
        ),
        _SummaryCard(
          title: 'Productos',
          value: '0',
          icon: Icons.inventory_2,
          color: AppTheme.primaryColor,
        ),
        _SummaryCard(
          title: 'Stock Bajo',
          value: '0',
          icon: Icons.warning_amber,
          color: AppTheme.warningColor,
        ),
        _SummaryCard(
          title: 'Pendientes',
          value: '0',
          icon: Icons.sync_problem,
          color: AppTheme.infoColor,
        ),
      ],
    );
  }

  Widget _buildMainMenu(BuildContext context) {
    final menuItems = [
      _MenuItem(
        title: 'Productos',
        subtitle: 'Gestionar catálogo',
        icon: Icons.inventory_2_outlined,
        color: AppTheme.primaryColor,
        route: '/productos',
      ),
      _MenuItem(
        title: 'Categorías',
        subtitle: 'Organizar productos',
        icon: Icons.category_outlined,
        color: Colors.orange,
        route: '/categorias',
      ),
      _MenuItem(
        title: 'Ventas',
        subtitle: 'Registrar ventas',
        icon: Icons.point_of_sale_outlined,
        color: AppTheme.successColor,
        route: '/ventas',
      ),
      _MenuItem(
        title: 'Compras',
        subtitle: 'Registrar compras',
        icon: Icons.shopping_cart_outlined,
        color: Colors.purple,
        route: '/compras',
      ),
      _MenuItem(
        title: 'Inventario',
        subtitle: 'Control de stock',
        icon: Icons.warehouse_outlined,
        color: Colors.teal,
        route: '/inventario',
      ),
      _MenuItem(
        title: 'Transferencias',
        subtitle: 'Mover productos',
        icon: Icons.swap_horiz_outlined,
        color: Colors.indigo,
        route: '/transferencias',
      ),
      _MenuItem(
        title: 'Tiendas',
        subtitle: 'Gestionar sucursales',
        icon: Icons.store_outlined,
        color: Colors.pink,
        route: '/tiendas',
      ),
      _MenuItem(
        title: 'Almacenes',
        subtitle: 'Gestionar depósitos',
        icon: Icons.warehouse,
        color: Colors.brown,
        route: '/almacenes',
      ),
      _MenuItem(
        title: 'Empleados',
        subtitle: 'Gestionar personal',
        icon: Icons.people_outline,
        color: Colors.cyan,
        route: '/empleados',
      ),
      _MenuItem(
        title: 'Clientes',
        subtitle: 'Gestionar clientes',
        icon: Icons.person_outline,
        color: Colors.amber,
        route: '/clientes',
      ),
      _MenuItem(
        title: 'Proveedores',
        subtitle: 'Gestionar proveedores',
        icon: Icons.local_shipping_outlined,
        color: Colors.deepOrange,
        route: '/proveedores',
      ),
      _MenuItem(
        title: 'Reportes',
        subtitle: 'Ver estadísticas',
        icon: Icons.bar_chart_outlined,
        color: Colors.blue,
        route: '/reportes',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _MenuCard(item: item);
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/ventas/nueva'),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Nueva Venta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/compras/nueva'),
            icon: const Icon(Icons.add_business),
            label: const Text('Nueva Compra'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up, color: color, size: 16),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
