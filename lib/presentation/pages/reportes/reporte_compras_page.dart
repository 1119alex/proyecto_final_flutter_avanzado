import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/reportes/reportes_bloc.dart';
import '../../blocs/reportes/reportes_event.dart';
import '../../blocs/reportes/reportes_state.dart';
import '../../blocs/almacenes/almacenes_bloc.dart';
import '../../blocs/almacenes/almacenes_state.dart';

class ReporteComprasPage extends StatefulWidget {
  const ReporteComprasPage({super.key});

  @override
  State<ReporteComprasPage> createState() => _ReporteComprasPageState();
}

class _ReporteComprasPageState extends State<ReporteComprasPage> {
  String? _almacenSeleccionado;
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
      LoadReporteCompras(
        almacenId: _almacenSeleccionado,
        fechaInicio: _rangoFechas?.start,
        fechaFin: _rangoFechas?.end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Compras'),
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

          if (state is ReporteComprasLoaded) {
            return _buildContent(state);
          }

          return const Center(child: Text('Cargando reporte de compras...'));
        },
      ),
    );
  }

  Widget _buildContent(ReporteComprasLoaded state) {
    return Column(
      children: [
        // Resumen
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Total', _currencyFormat.format(state.totalCompras)),
              _buildStat('Compras', state.cantidadCompras.toString()),
              _buildStat(
                'Promedio',
                _currencyFormat.format(state.promedioCompra),
              ),
            ],
          ),
        ),

        // Filtros activos
        if (_almacenSeleccionado != null || _rangoFechas != null)
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
                if (_almacenSeleccionado != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text(
                      'Almacén',
                      style: TextStyle(fontSize: 12),
                    ),
                    onDeleted: () {
                      setState(() => _almacenSeleccionado = null);
                      _cargarReporte();
                    },
                  ),
                ],
              ],
            ),
          ),

        // Lista de compras
        Expanded(
          child: state.compras.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay compras en este período',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.compras.length,
                  itemBuilder: (context, index) {
                    final compra = state.compras[index];
                    return _buildCompraCard(compra);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCompraCard(CompraReporte compra) {
    final esCancelada = compra.estado == 'cancelada';
    final color = esCancelada ? Colors.grey : Colors.purple;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            esCancelada ? Icons.cancel : Icons.shopping_cart,
            color: color,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                compra.numeroCompra,
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
            Text(_dateFormat.format(compra.fecha)),
            if (compra.proveedorNombre != null)
              Row(
                children: [
                  Icon(Icons.local_shipping, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      compra.proveedorNombre!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (compra.almacenNombre != null)
              Row(
                children: [
                  Icon(Icons.warehouse, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    compra.almacenNombre!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            Text(
              '${compra.cantidadItems} productos',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Text(
          _currencyFormat.format(compra.total),
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
              'Filtrar Compras',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Filtro por almacén
            BlocBuilder<AlmacenesBloc, AlmacenesState>(
              builder: (context, state) {
                if (state is AlmacenesLoaded) {
                  return DropdownButtonFormField<String?>(
                    value: _almacenSeleccionado,
                    decoration: const InputDecoration(labelText: 'Almacén'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ...state.almacenes.map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.nombre),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      _almacenSeleccionado = v;
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
