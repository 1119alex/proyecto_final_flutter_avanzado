import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/reportes/reportes_bloc.dart';
import '../../blocs/reportes/reportes_event.dart';
import '../../blocs/reportes/reportes_state.dart';
import '../../blocs/tiendas/tiendas_bloc.dart';
import '../../blocs/tiendas/tiendas_event.dart';
import '../../blocs/tiendas/tiendas_state.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  String? _tiendaSeleccionada;
  DateTimeRange? _rangoFechas;
  final _currencyFormat = NumberFormat.currency(
    symbol: 'Bs. ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    // Cargar tiendas para el filtro
    context.read<TiendasBloc>().add(const LoadTiendas());
    // Cargar reporte general inicial
    _cargarReporte();
  }

  void _cargarReporte() {
    context.read<ReportesBloc>().add(
      LoadReportesGeneral(
        tiendaId: _tiendaSeleccionada,
        fechaInicio: _rangoFechas?.start,
        fechaFin: _rangoFechas?.end,
      ),
    );

    // También cargar productos más vendidos
    context.read<ReportesBloc>().add(
      LoadProductosMasVendidos(
        tiendaId: _tiendaSeleccionada,
        fechaInicio: _rangoFechas?.start,
        fechaFin: _rangoFechas?.end,
        limit: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exportando reporte...')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ReportesBloc, ReportesState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtros
                _buildFiltros(),
                const SizedBox(height: 24),

                // Estado de carga o error
                if (state is ReportesLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is ReportesError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _cargarReporte,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is ReportesGeneralLoaded)
                  _buildReporteGeneral(state)
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Selecciona filtros y presiona "Aplicar"'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltros() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Filtro de tienda
            BlocBuilder<TiendasBloc, TiendasState>(
              builder: (context, state) {
                if (state is TiendasLoaded) {
                  return DropdownButtonFormField<String>(
                    value: _tiendaSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Tienda',
                      prefixIcon: Icon(Icons.store),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todas las tiendas'),
                      ),
                      ...state.tiendas.map(
                        (tienda) => DropdownMenuItem<String>(
                          value: tienda.id,
                          child: Text(tienda.nombre),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _tiendaSeleccionada = v),
                  );
                }
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tienda',
                    prefixIcon: Icon(Icons.store),
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Cargando...'),
                    ),
                  ],
                  onChanged: null,
                );
              },
            ),
            const SizedBox(height: 16),

            // Filtro de fechas
            InkWell(
              onTap: () async {
                final rango = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _rangoFechas,
                );
                if (rango != null) {
                  setState(() => _rangoFechas = rango);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Rango de fechas',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _rangoFechas != null
                      ? '${DateFormat('dd/MM/yyyy').format(_rangoFechas!.start)} - ${DateFormat('dd/MM/yyyy').format(_rangoFechas!.end)}'
                      : 'Últimos 30 días',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón aplicar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cargarReporte,
                icon: const Icon(Icons.refresh),
                label: const Text('Aplicar Filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReporteGeneral(ReportesGeneralLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen de ventas
        const Text(
          'Resumen General',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildResumenCard(
                'Total Ventas',
                _currencyFormat.format(state.totalVentas),
                Icons.attach_money,
                AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildResumenCard(
                'Transacciones',
                state.cantidadVentas.toString(),
                Icons.receipt,
                AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildResumenCard(
                'Total Compras',
                _currencyFormat.format(state.totalCompras),
                Icons.shopping_cart,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildResumenCard(
                'Productos Vendidos',
                state.productosVendidos.toString(),
                Icons.inventory,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          color: state.ganancia >= 0
              ? AppTheme.successColor.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  state.ganancia >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: state.ganancia >= 0
                      ? AppTheme.successColor
                      : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.ganancia >= 0 ? 'Ganancia' : 'Pérdida',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        _currencyFormat.format(state.ganancia.abs()),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: state.ganancia >= 0
                              ? AppTheme.successColor
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Productos más vendidos
        _buildProductosMasVendidos(),
        const SizedBox(height: 24),

        // Reportes disponibles
        const Text(
          'Reportes Disponibles',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        _buildReporteItem(
          context,
          'Reporte de Ventas',
          'Detalle de todas las ventas',
          Icons.point_of_sale,
          () {
            // Navegar al reporte de ventas detallado
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad en desarrollo')),
            );
          },
        ),
        _buildReporteItem(
          context,
          'Reporte de Compras',
          'Historial de compras a proveedores',
          Icons.shopping_cart,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad en desarrollo')),
            );
          },
        ),
        _buildReporteItem(
          context,
          'Reporte de Inventario',
          'Estado actual del inventario',
          Icons.inventory_2,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad en desarrollo')),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProductosMasVendidos() {
    return BlocBuilder<ReportesBloc, ReportesState>(
      builder: (context, state) {
        if (state is ProductosMasVendidosLoaded) {
          if (state.productos.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos vendidos en este período',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Productos Más Vendidos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: state.productos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final producto = entry.value;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                      title: Text(producto.productoNombre),
                      subtitle: Text(
                        '${producto.cantidadVendida} unidades vendidas',
                      ),
                      trailing: Text(
                        _currencyFormat.format(producto.totalVentas),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildResumenCard(
    String titulo,
    String valor,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(titulo, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildReporteItem(
    BuildContext context,
    String titulo,
    String descripcion,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(titulo),
        subtitle: Text(descripcion),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
