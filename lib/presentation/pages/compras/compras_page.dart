import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../../blocs/compras/compras_bloc.dart';
import '../../blocs/compras/compras_event.dart';
import '../../blocs/compras/compras_state.dart';
import '../../blocs/almacenes/almacenes_bloc.dart';
import '../../blocs/almacenes/almacenes_state.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  String? _filtroAlmacenId;
  DateTime? _filtroFechaInicio;
  DateTime? _filtroFechaFin;
  final _currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    context.read<ComprasBloc>().add(const LoadCompras());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () {
              setState(() {
                _filtroAlmacenId = null;
                _filtroFechaInicio = null;
                _filtroFechaFin = null;
              });
              context.read<ComprasBloc>().add(const LoadCompras());
            },
          ),
        ],
      ),
      body: BlocConsumer<ComprasBloc, ComprasState>(
        listener: (context, state) {
          if (state is CompraCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Compra registrada exitosamente'),
                backgroundColor: Colors.purple,
              ),
            );
          } else if (state is CompraCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Compra cancelada'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is ComprasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ComprasLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ComprasLoaded) {
            return _buildComprasContent(context, state);
          }

          if (state is ComprasError) {
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
                      context.read<ComprasBloc>().add(const LoadCompras());
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
        onPressed: () => context.push('/compras/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Compra'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildComprasContent(BuildContext context, ComprasLoaded state) {
    return Column(
      children: [
        // Resumen
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                'Compras',
                '${state.compras.where((c) => c.estado != 'cancelada').length}',
                Colors.white,
              ),
              _buildStat(
                'Total',
                _currencyFormat.format(state.totalCompras),
                Colors.white,
              ),
            ],
          ),
        ),
        // Filtros activos
        if (_filtroAlmacenId != null ||
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
                if (_filtroAlmacenId != null)
                  Chip(
                    label: const Text('Almacen'),
                    onDeleted: () {
                      setState(() => _filtroAlmacenId = null);
                      context.read<ComprasBloc>().add(const LoadCompras());
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
                      context.read<ComprasBloc>().add(const LoadCompras());
                    },
                  ),
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
                        'No hay compras registradas',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registra tu primera compra',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.compras.length,
                  itemBuilder: (context, index) {
                    final compra = state.compras[index];
                    return _buildCompraCard(context, compra);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCompraCard(BuildContext context, Compra compra) {
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
                'Compra #${compra.id.substring(0, 8)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: esCancelada ? TextDecoration.lineThrough : null,
                ),
                overflow: TextOverflow.ellipsis,
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
            Text(_dateFormat.format(compra.fecha)),
            if (compra.observaciones != null &&
                compra.observaciones!.isNotEmpty)
              Text(
                compra.observaciones!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Text(
          _currencyFormat.format(compra.total),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: esCancelada ? Colors.grey : Colors.purple,
            decoration: esCancelada ? TextDecoration.lineThrough : null,
          ),
        ),
        isThreeLine: true,
        onTap: () => _mostrarDetalleCompra(context, compra),
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
              'Filtrar Compras',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Filtro por almacen
            BlocBuilder<AlmacenesBloc, AlmacenesState>(
              builder: (context, state) {
                if (state is AlmacenesLoaded) {
                  return DropdownButtonFormField<String?>(
                    value: _filtroAlmacenId,
                    decoration: const InputDecoration(labelText: 'Almacen'),
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
                      setState(() => _filtroAlmacenId = v);
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
    if (_filtroAlmacenId != null) {
      context.read<ComprasBloc>().add(LoadComprasByAlmacen(_filtroAlmacenId!));
    } else if (_filtroFechaInicio != null && _filtroFechaFin != null) {
      context.read<ComprasBloc>().add(
        LoadComprasByFecha(
          inicio: _filtroFechaInicio!,
          fin: _filtroFechaFin!.add(const Duration(days: 1)),
        ),
      );
    } else if (_filtroFechaInicio != null) {
      context.read<ComprasBloc>().add(
        LoadComprasByFecha(
          inicio: _filtroFechaInicio!,
          fin: DateTime.now().add(const Duration(days: 1)),
        ),
      );
    } else {
      context.read<ComprasBloc>().add(const LoadCompras());
    }
  }

  void _mostrarDetalleCompra(BuildContext context, Compra compra) {
    final esCancelada = compra.estado == 'cancelada';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Compra #${compra.id.substring(0, 8)}'),
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
                    'COMPRA CANCELADA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              _buildDetalleRow('Fecha', _dateFormat.format(compra.fecha)),
              const Divider(),
              _buildDetalleRow(
                'TOTAL',
                _currencyFormat.format(compra.total),
                isBold: true,
              ),
              if (compra.observaciones != null &&
                  compra.observaciones!.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Observaciones:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(compra.observaciones!),
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
                _confirmarCancelarCompra(context, compra);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancelar Compra'),
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

  void _confirmarCancelarCompra(BuildContext context, Compra compra) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Compra'),
        content: Text(
          'Esta seguro de cancelar la compra #${compra.id.substring(0, 8)}?\n\nEsta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ComprasBloc>().add(CancelCompra(compra.id));
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
