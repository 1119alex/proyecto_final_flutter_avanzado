import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  String _tiendaSeleccionada = 'todas';
  DateTimeRange? _rangoFechas;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _tiendaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Tienda',
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'todas', child: Text('Todas las tiendas')),
                        DropdownMenuItem(value: '1', child: Text('Sucursal Central')),
                        DropdownMenuItem(value: '2', child: Text('Sucursal Norte')),
                      ],
                      onChanged: (v) => setState(() => _tiendaSeleccionada = v!),
                    ),
                    const SizedBox(height: 16),
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
                              ? '${_rangoFechas!.start.toString().substring(0, 10)} - ${_rangoFechas!.end.toString().substring(0, 10)}'
                              : 'Seleccionar fechas',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Resumen de ventas
            const Text('Resumen de Ventas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildResumenCard('Total Ventas', 'Bs. 45,600.00', Icons.attach_money, AppTheme.successColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildResumenCard('Transacciones', '256', Icons.receipt, AppTheme.primaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildResumenCard('Ticket Promedio', 'Bs. 178.13', Icons.trending_up, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildResumenCard('Productos Vendidos', '1,245', Icons.inventory, Colors.purple)),
              ],
            ),
            const SizedBox(height: 24),

            // Productos más vendidos
            const Text('Productos Más Vendidos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: List.generate(5, (index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Text('${index + 1}', style: const TextStyle(color: AppTheme.primaryColor)),
                    ),
                    title: Text('Producto ${index + 1}'),
                    subtitle: Text('${100 - (index * 15)} unidades vendidas'),
                    trailing: Text(
                      'Bs. ${(1000 - (index * 150)).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Ventas por categoría
            const Text('Ventas por Categoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCategoriaBar('Libros', 0.35, Colors.blue, 'Bs. 15,960.00'),
                    const SizedBox(height: 12),
                    _buildCategoriaBar('Cuadernos', 0.25, Colors.green, 'Bs. 11,400.00'),
                    const SizedBox(height: 12),
                    _buildCategoriaBar('Útiles de Escritura', 0.20, Colors.orange, 'Bs. 9,120.00'),
                    const SizedBox(height: 12),
                    _buildCategoriaBar('Arte y Manualidades', 0.12, Colors.purple, 'Bs. 5,472.00'),
                    const SizedBox(height: 12),
                    _buildCategoriaBar('Otros', 0.08, Colors.grey, 'Bs. 3,648.00'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reportes disponibles
            const Text('Reportes Disponibles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _buildReporteItem(context, 'Reporte de Ventas', 'Detalle de todas las ventas', Icons.point_of_sale),
            _buildReporteItem(context, 'Reporte de Compras', 'Historial de compras a proveedores', Icons.shopping_cart),
            _buildReporteItem(context, 'Reporte de Inventario', 'Estado actual del inventario', Icons.inventory_2),
            _buildReporteItem(context, 'Reporte de Movimientos', 'Transferencias y ajustes', Icons.swap_horiz),
            _buildReporteItem(context, 'Reporte de Clientes', 'Análisis de clientes', Icons.people),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenCard(String titulo, String valor, IconData icon, Color color) {
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(titulo, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaBar(String nombre, double porcentaje, Color color, String monto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(nombre),
            Text(monto, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: porcentaje,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${(porcentaje * 100).round()}%', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildReporteItem(BuildContext context, String titulo, String descripcion, IconData icon) {
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
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Generando $titulo...')),
          );
        },
      ),
    );
  }
}
