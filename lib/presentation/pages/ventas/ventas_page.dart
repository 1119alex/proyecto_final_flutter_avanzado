import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../../blocs/ventas/ventas_bloc.dart';
import '../../blocs/ventas/ventas_event.dart';
import '../../blocs/ventas/ventas_state.dart';
import '../../blocs/tiendas/tiendas_bloc.dart';
import '../../blocs/tiendas/tiendas_state.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  String? _filtroTiendaId;
  DateTime? _filtroFechaInicio;
  DateTime? _filtroFechaFin;
  final _currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    context.read<VentasBloc>().add(const LoadVentasHoy());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Ventas de hoy',
            onPressed: () {
              setState(() {
                _filtroTiendaId = null;
                _filtroFechaInicio = null;
                _filtroFechaFin = null;
              });
              context.read<VentasBloc>().add(const LoadVentasHoy());
            },
          ),
        ],
      ),
      body: BlocConsumer<VentasBloc, VentasState>(
        listener: (context, state) {
          if (state is VentaCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Venta registrada exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is VentaCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Venta cancelada'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is VentasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VentasLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VentasLoaded) {
            return _buildVentasContent(context, state);
          }

          if (state is VentasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VentasBloc>().add(const LoadVentasHoy());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ventas/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Venta'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Widget _buildVentasContent(BuildContext context, VentasLoaded state) {
    return Column(
      children: [
        // Resumen
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                'Ventas',
                '${state.ventas.where((v) => v.estado != 'cancelada').length}',
                Colors.white,
              ),
              _buildStat(
                'Total',
                _currencyFormat.format(state.totalVentas),
                Colors.white,
              ),
            ],
          ),
        ),
        // Filtros activos
        if (_filtroTiendaId != null ||
            _filtroFechaInicio != null ||
            _filtroFechaFin != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Filtros: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_filtroTiendaId != null)
                  Chip(
                    label: const Text('Tienda'),
                    onDeleted: () {
                      setState(() => _filtroTiendaId = null);
                      context.read<VentasBloc>().add(const LoadVentasHoy());
                    },
                  ),
                if (_filtroFechaInicio != null)
                  Chip(
                    label: Text(
                      '${DateFormat('dd/MM').format(_filtroFechaInicio!)} - ${DateFormat('dd/MM').format(_filtroFechaFin ?? DateTime.now())}',
                    ),
                    onDeleted: () {
                      setState(() {
                        _filtroFechaInicio = null;
                        _filtroFechaFin = null;
                      });
                      context.read<VentasBloc>().add(const LoadVentasHoy());
                    },
                  ),
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
                        'No hay ventas registradas',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea tu primera venta',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.ventas.length,
                  itemBuilder: (context, index) {
                    final venta = state.ventas[index];
                    return _buildVentaCard(context, venta);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVentaCard(BuildContext context, Venta venta) {
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
            Text(
              'Venta #${venta.id.substring(0, 8)}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                decoration: esCancelada ? TextDecoration.lineThrough : null,
              ),
            ),
            if (esCancelada) ...[
              const SizedBox(width: 8),
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
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_dateFormat.format(venta.fecha)),
            Text(
              'Pago: ${venta.metodoPago}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Text(
          _currencyFormat.format(venta.total),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: esCancelada ? Colors.grey : AppTheme.successColor,
            decoration: esCancelada ? TextDecoration.lineThrough : null,
          ),
        ),
        isThreeLine: true,
        onTap: () => _mostrarDetalleVenta(context, venta),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.8))),
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
                    value: _filtroTiendaId,
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
                      setState(() => _filtroTiendaId = v);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
            // Filtro por fecha
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _filtroFechaInicio != null
                          ? DateFormat('dd/MM/yyyy').format(_filtroFechaInicio!)
                          : 'Fecha inicio',
                    ),
                    onPressed: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: _filtroFechaInicio ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (fecha != null) {
                        setState(() => _filtroFechaInicio = fecha);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _filtroFechaFin != null
                          ? DateFormat('dd/MM/yyyy').format(_filtroFechaFin!)
                          : 'Fecha fin',
                    ),
                    onPressed: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: _filtroFechaFin ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (fecha != null) {
                        setState(() => _filtroFechaFin = fecha);
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
                  _aplicarFiltros();
                },
                child: const Text('Aplicar Filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _aplicarFiltros() {
    if (_filtroTiendaId != null) {
      context.read<VentasBloc>().add(LoadVentasByTienda(_filtroTiendaId!));
    } else if (_filtroFechaInicio != null && _filtroFechaFin != null) {
      context.read<VentasBloc>().add(
        LoadVentasByFecha(
          inicio: _filtroFechaInicio!,
          fin: _filtroFechaFin!.add(const Duration(days: 1)),
        ),
      );
    } else if (_filtroFechaInicio != null) {
      context.read<VentasBloc>().add(
        LoadVentasByFecha(
          inicio: _filtroFechaInicio!,
          fin: DateTime.now().add(const Duration(days: 1)),
        ),
      );
    } else {
      context.read<VentasBloc>().add(const LoadVentas());
    }
  }

  void _mostrarDetalleVenta(BuildContext context, Venta venta) {
    final esCancelada = venta.estado == 'cancelada';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Venta #${venta.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (esCancelada)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'VENTA CANCELADA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              _buildDetalleRow('Fecha', _dateFormat.format(venta.fecha)),
              _buildDetalleRow('Metodo de pago', venta.metodoPago),
              _buildDetalleRow(
                'Subtotal',
                _currencyFormat.format(venta.subtotal),
              ),
              if (venta.descuento > 0)
                _buildDetalleRow(
                  'Descuento',
                  '-${_currencyFormat.format(venta.descuento)}',
                ),
              const Divider(),
              _buildDetalleRow(
                'TOTAL',
                _currencyFormat.format(venta.total),
                isBold: true,
              ),
              if (venta.observaciones != null &&
                  venta.observaciones!.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Observaciones:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(venta.observaciones!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
          if (!esCancelada)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _confirmarCancelarVenta(context, venta);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancelar Venta'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarCancelarVenta(BuildContext context, Venta venta) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Venta'),
        content: Text(
          'Esta seguro de cancelar la venta #${venta.id.substring(0, 8)}?\n\nEsta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<VentasBloc>().add(CancelVenta(venta.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Si, Cancelar'),
          ),
        ],
      ),
    );
  }
}
