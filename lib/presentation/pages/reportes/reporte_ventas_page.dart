import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/reportes/reportes_bloc.dart';
import '../../blocs/reportes/reportes_event.dart';
import '../../blocs/reportes/reportes_state.dart';
import '../../blocs/tiendas/tiendas_bloc.dart';
import '../../blocs/tiendas/tiendas_state.dart';

class ReporteVentasPage extends StatefulWidget {
  const ReporteVentasPage({super.key});

  @override
  State<ReporteVentasPage> createState() => _ReporteVentasPageState();
}

class _ReporteVentasPageState extends State<ReporteVentasPage> {
  String? _tiendaSeleccionada;
  DateTimeRange? _rangoFechas;
  final _currencyFormat = NumberFormat.currency(
    symbol: 'Bs. ',
    decimalDigits: 2,
  );
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _cargarReporte();
  }

  void _cargarReporte() {
    context.read<ReportesBloc>().add(
      LoadReporteVentas(
        tiendaId: _tiendaSeleccionada,
        fechaInicio: _rangoFechas?.start,
        fechaFin: _rangoFechas?.end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ventas'),
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

          if (state is ReporteVentasLoaded) {
            return _buildContent(state);
          }

          return const Center(child: Text('Cargando reporte de ventas...'));
        },
      ),
    );
  }

  Widget _buildContent(ReporteVentasLoaded state) {
    return Column(
      children: [
        // Resumen
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.successColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Total', _currencyFormat.format(state.totalVentas)),
              _buildStat('Ventas', state.cantidadVentas.toString()),
              _buildStat(
                'Promedio',
                _currencyFormat.format(state.promedioVenta),
              ),
            ],
          ),
        ),

        // Filtros activos
        if (_tiendaSeleccionada != null || _rangoFechas != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.filter_alt, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                if (_rangoFechas != null)
                  Chip(
                    label: Text(
                      '${DateFormat('dd/MM').format(_rangoFechas!.start)} - ${DateFormat('dd/MM').format(_rangoFechas!.end)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () {
                      setState(() => _rangoFechas = null);
                      _cargarReporte();
                    },
                  ),
                if (_tiendaSeleccionada != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('Tienda', style: TextStyle(fontSize: 12)),
                    onDeleted: () {
                      setState(() => _tiendaSeleccionada = null);
                      _cargarReporte();
                    },
                  ),
                ],
              ],
            ),
          ),

        // Lista de ventas
        Expanded(
          child: state.ventas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay ventas en este período',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.ventas.length,
                  itemBuilder: (context, index) {
                    final venta = state.ventas[index];
                    return _buildVentaCard(venta);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVentaCard(VentaReporte venta) {
    final esCancelada = venta.estado == 'cancelada';
    final color = esCancelada ? Colors.grey : AppTheme.successColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(esCancelada ? Icons.cancel : Icons.receipt, color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                venta.numeroVenta,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: esCancelada ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (esCancelada)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CANCELADA',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_dateFormat.format(venta.fecha)),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    venta.clienteNombre ?? 'Cliente general',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (venta.tiendaNombre != null)
              Row(
                children: [
                  Icon(Icons.store, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    venta.tiendaNombre!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            Text(
              '${venta.cantidadItems} productos',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Text(
          _currencyFormat.format(venta.total),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
            decoration: esCancelada ? TextDecoration.lineThrough : null,
          ),
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
              'Filtrar Ventas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Filtro por tienda
            BlocBuilder<TiendasBloc, TiendasState>(
              builder: (context, state) {
                if (state is TiendasLoaded) {
                  return DropdownButtonFormField<String?>(
                    value: _tiendaSeleccionada,
                    decoration: const InputDecoration(labelText: 'Tienda'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      ...state.tiendas.map(
                        (t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.nombre),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      _tiendaSeleccionada = v;
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            // Filtro por fecha
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _rangoFechas != null
                          ? '${DateFormat('dd/MM').format(_rangoFechas!.start)} - ${DateFormat('dd/MM').format(_rangoFechas!.end)}'
                          : 'Seleccionar fechas',
                    ),
                    onPressed: () async {
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
                  ),
                ),
              ],
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
