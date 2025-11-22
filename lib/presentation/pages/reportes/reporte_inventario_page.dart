import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/reportes/reportes_bloc.dart';
import '../../blocs/reportes/reportes_event.dart';
import '../../blocs/reportes/reportes_state.dart';
import '../../blocs/tiendas/tiendas_bloc.dart';
import '../../blocs/tiendas/tiendas_state.dart';
import '../../blocs/almacenes/almacenes_bloc.dart';
import '../../blocs/almacenes/almacenes_state.dart';

class ReporteInventarioPage extends StatefulWidget {
  const ReporteInventarioPage({super.key});

  @override
  State<ReporteInventarioPage> createState() => _ReporteInventarioPageState();
}

class _ReporteInventarioPageState extends State<ReporteInventarioPage> {
  String? _ubicacionSeleccionada;
  bool _soloStockBajo = false;
  final _currencyFormat = NumberFormat.currency(
    symbol: 'Bs. ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _cargarReporte();
  }

  void _cargarReporte() {
    context.read<ReportesBloc>().add(
      LoadReporteInventario(ubicacionId: _ubicacionSeleccionada),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
        ],
      ),
      body: BlocBuilder<ReportesBloc, ReportesState>(
        builder: (context, state) {
          if (state is ReportesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReportesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarReporte,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is ReporteInventarioLoaded) {
            return _buildContent(state);
          }

          return const Center(child: Text('Cargando reporte de inventario...'));
        },
      ),
    );
  }

  Widget _buildContent(ReporteInventarioLoaded state) {
    // Filtrar por stock bajo si está activo
    final inventarioFiltrado = _soloStockBajo
        ? state.inventario.where((i) => i.bajoStock).toList()
        : state.inventario;

    return Column(
      children: [
        // Resumen
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Productos', state.totalProductos.toString()),
              _buildStat('Stock Bajo', state.productosBajoStock.toString()),
              _buildStat(
                'Valor Total',
                _currencyFormat.format(state.valorTotalInventario),
              ),
            ],
          ),
        ),

        // Filtros activos
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Solo stock bajo'),
                selected: _soloStockBajo,
                onSelected: (v) => setState(() => _soloStockBajo = v),
                selectedColor: Colors.orange.withValues(alpha: 0.3),
              ),
              if (_ubicacionSeleccionada != null) ...[
                const SizedBox(width: 8),
                Chip(
                  label: const Text(
                    'Ubicación',
                    style: TextStyle(fontSize: 12),
                  ),
                  onDeleted: () {
                    setState(() => _ubicacionSeleccionada = null);
                    _cargarReporte();
                  },
                ),
              ],
            ],
          ),
        ),

        // Lista de inventario
        Expanded(
          child: inventarioFiltrado.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _soloStockBajo
                            ? 'No hay productos con stock bajo'
                            : 'No hay productos en inventario',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: inventarioFiltrado.length,
                  itemBuilder: (context, index) {
                    final item = inventarioFiltrado[index];
                    return _buildInventarioCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInventarioCard(InventarioReporte item) {
    Color stockColor;
    String stockText;
    IconData stockIcon;

    if (item.cantidad == 0) {
      stockColor = Colors.red;
      stockText = 'Sin stock';
      stockIcon = Icons.error;
    } else if (item.bajoStock) {
      stockColor = Colors.orange;
      stockText = 'Stock bajo';
      stockIcon = Icons.warning;
    } else {
      stockColor = AppTheme.successColor;
      stockText = 'Normal';
      stockIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: stockColor.withValues(alpha: 0.1),
          child: Icon(stockIcon, color: stockColor),
        ),
        title: Text(
          item.productoNombre,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.ubicacionNombre ?? 'Sin ubicación',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Stock: ${item.cantidad}',
                  style: TextStyle(
                    fontSize: 12,
                    color: stockColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(Mín: ${item.stockMinimo})',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: stockColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                stockText,
                style: TextStyle(
                  fontSize: 10,
                  color: stockColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _currencyFormat.format(item.precioVenta),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              _currencyFormat.format(item.valorTotal),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  void _mostrarFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar Inventario',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Filtro por tienda
            BlocBuilder<TiendasBloc, TiendasState>(
              builder: (context, tiendasState) {
                return BlocBuilder<AlmacenesBloc, AlmacenesState>(
                  builder: (context, almacenesState) {
                    final items = <DropdownMenuItem<String?>>[];
                    items.add(
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas las ubicaciones'),
                      ),
                    );

                    if (tiendasState is TiendasLoaded) {
                      for (final tienda in tiendasState.tiendas) {
                        items.add(
                          DropdownMenuItem<String?>(
                            value: tienda.id,
                            child: Text('Tienda: ${tienda.nombre}'),
                          ),
                        );
                      }
                    }

                    if (almacenesState is AlmacenesLoaded) {
                      for (final almacen in almacenesState.almacenes) {
                        items.add(
                          DropdownMenuItem<String?>(
                            value: almacen.id,
                            child: Text('Almacén: ${almacen.nombre}'),
                          ),
                        );
                      }
                    }

                    return DropdownButtonFormField<String?>(
                      value: _ubicacionSeleccionada,
                      decoration: const InputDecoration(labelText: 'Ubicación'),
                      items: items,
                      onChanged: (v) {
                        _ubicacionSeleccionada = v;
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _cargarReporte();
                },
                child: const Text('Aplicar Filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
