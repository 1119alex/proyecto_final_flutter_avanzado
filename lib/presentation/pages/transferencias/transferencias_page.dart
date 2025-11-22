import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../../blocs/transferencias/transferencias_bloc.dart';
import '../../blocs/transferencias/transferencias_event.dart';
import '../../blocs/transferencias/transferencias_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/almacenes/almacenes_bloc.dart';
import '../../blocs/almacenes/almacenes_event.dart';
import '../../blocs/almacenes/almacenes_state.dart';
import '../../blocs/productos/productos_bloc.dart';
import '../../blocs/productos/productos_event.dart';
import '../../blocs/productos/productos_state.dart';

class TransferenciasPage extends StatefulWidget {
  const TransferenciasPage({super.key});

  @override
  State<TransferenciasPage> createState() => _TransferenciasPageState();
}

class _TransferenciasPageState extends State<TransferenciasPage> {
  String? _filtroEstado;
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    context.read<TransferenciasBloc>().add(const LoadTransferencias());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () {
              setState(() => _filtroEstado = null);
              context.read<TransferenciasBloc>().add(
                const LoadTransferencias(),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TransferenciasBloc, TransferenciasState>(
        listener: (context, state) {
          if (state is TransferenciaCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transferencia creada exitosamente'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          } else if (state is TransferenciaEstadoUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Estado actualizado: ${state.nuevoEstado}'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is TransferenciasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TransferenciasLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransferenciasLoaded) {
            return _buildContent(context, state);
          }

          if (state is TransferenciasError) {
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
                      context.read<TransferenciasBloc>().add(
                        const LoadTransferencias(),
                      );
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
        onPressed: () => _mostrarNuevaTransferencia(context),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Nueva Transferencia'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransferenciasLoaded state) {
    return Column(
      children: [
        // Resumen por estado
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                'Pendientes',
                '${state.conteoPorEstado['pendiente'] ?? 0}',
                Colors.orange,
              ),
              _buildStat(
                'En Transito',
                '${state.conteoPorEstado['en_transito'] ?? 0}',
                Colors.blue,
              ),
              _buildStat(
                'Completadas',
                '${state.conteoPorEstado['completada'] ?? 0}',
                Colors.green,
              ),
            ],
          ),
        ),
        // Filtro activo
        if (_filtroEstado != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Filtro: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    _filtroEstado!.replaceAll('_', ' ').toUpperCase(),
                  ),
                  onDeleted: () {
                    setState(() => _filtroEstado = null);
                    context.read<TransferenciasBloc>().add(
                      const LoadTransferencias(),
                    );
                  },
                ),
              ],
            ),
          ),
        // Lista
        Expanded(
          child: state.transferencias.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_horiz, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay transferencias',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.transferencias.length,
                  itemBuilder: (context, index) {
                    final transferencia = state.transferencias[index];
                    return _buildTransferenciaCard(context, transferencia);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTransferenciaCard(
    BuildContext context,
    Transferencia transferencia,
  ) {
    Color estadoColor;
    IconData estadoIcon;

    switch (transferencia.estado) {
      case 'pendiente':
        estadoColor = Colors.orange;
        estadoIcon = Icons.hourglass_empty;
        break;
      case 'en_transito':
        estadoColor = Colors.blue;
        estadoIcon = Icons.local_shipping;
        break;
      case 'completada':
        estadoColor = AppTheme.successColor;
        estadoIcon = Icons.check_circle;
        break;
      case 'cancelada':
        estadoColor = Colors.red;
        estadoIcon = Icons.cancel;
        break;
      default:
        estadoColor = Colors.grey;
        estadoIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _mostrarDetalleTransferencia(context, transferencia),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transferencia #${transferencia.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: estadoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(estadoIcon, size: 16, color: estadoColor),
                        const SizedBox(width: 4),
                        Text(
                          transferencia.estado
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          style: TextStyle(
                            color: estadoColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Origen',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          transferencia.origenAlmacenId != null
                              ? 'Almacen'
                              : transferencia.origenTiendaId != null
                              ? 'Tienda'
                              : 'No especificado',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Destino',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          transferencia.destinoAlmacenId != null
                              ? 'Almacen'
                              : transferencia.destinoTiendaId != null
                              ? 'Tienda'
                              : 'No especificado',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _dateFormat.format(transferencia.fecha),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
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
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
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
              'Filtrar por Estado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Pendiente', 'pendiente', Colors.orange),
                _buildFilterChip('En Transito', 'en_transito', Colors.blue),
                _buildFilterChip('Completada', 'completada', Colors.green),
                _buildFilterChip('Cancelada', 'cancelada', Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  setState(() => _filtroEstado = null);
                  context.read<TransferenciasBloc>().add(
                    const LoadTransferencias(),
                  );
                },
                child: const Text('Limpiar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String estado, Color color) {
    return ActionChip(
      label: Text(label),
      backgroundColor: _filtroEstado == estado
          ? color.withValues(alpha: 0.2)
          : null,
      onPressed: () {
        Navigator.pop(context);
        setState(() => _filtroEstado = estado);
        context.read<TransferenciasBloc>().add(
          LoadTransferenciasByEstado(estado),
        );
      },
    );
  }

  void _mostrarDetalleTransferencia(
    BuildContext context,
    Transferencia transferencia,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Transferencia #${transferencia.id.substring(0, 8)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleRow(
              'Estado',
              transferencia.estado.replaceAll('_', ' ').toUpperCase(),
            ),
            _buildDetalleRow('Fecha', _dateFormat.format(transferencia.fecha)),
            if (transferencia.observaciones != null &&
                transferencia.observaciones!.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Observaciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(transferencia.observaciones!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
          if (transferencia.estado == 'pendiente') ...[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<TransferenciasBloc>().add(
                  MarcarEnTransito(transferencia.id),
                );
              },
              child: const Text('Marcar En Transito'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<TransferenciasBloc>().add(
                  CancelarTransferencia(transferencia.id),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancelar'),
            ),
          ],
          if (transferencia.estado == 'en_transito')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<TransferenciasBloc>().add(
                  CompletarTransferencia(transferencia.id),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
              ),
              child: const Text('Completar'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  void _mostrarNuevaTransferencia(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const NuevaTransferenciaSheet(),
    );
  }
}

class NuevaTransferenciaSheet extends StatefulWidget {
  const NuevaTransferenciaSheet({super.key});

  @override
  State<NuevaTransferenciaSheet> createState() =>
      _NuevaTransferenciaSheetState();
}

class _NuevaTransferenciaSheetState extends State<NuevaTransferenciaSheet> {
  String? _almacenOrigenId;
  String? _almacenDestinoId;
  final List<_ItemTransferencia> _productos = [];
  final _observacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AlmacenesBloc>().add(const LoadAlmacenes());
    context.read<ProductosBloc>().add(const LoadProductos());
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nueva Transferencia',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Almacen origen
            BlocBuilder<AlmacenesBloc, AlmacenesState>(
              builder: (context, state) {
                if (state is AlmacenesLoaded) {
                  return DropdownButtonFormField<String>(
                    value: _almacenOrigenId,
                    decoration: const InputDecoration(
                      labelText: 'Almacen Origen *',
                      prefixIcon: Icon(Icons.warehouse),
                      border: OutlineInputBorder(),
                    ),
                    items: state.almacenes
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _almacenOrigenId = v),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            // Almacen destino
            BlocBuilder<AlmacenesBloc, AlmacenesState>(
              builder: (context, state) {
                if (state is AlmacenesLoaded) {
                  return DropdownButtonFormField<String>(
                    value: _almacenDestinoId,
                    decoration: const InputDecoration(
                      labelText: 'Almacen Destino *',
                      prefixIcon: Icon(Icons.warehouse_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: state.almacenes
                        .where((a) => a.id != _almacenOrigenId)
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _almacenDestinoId = v),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Productos a transferir',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _agregarProducto,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            Expanded(
              child: _productos.isEmpty
                  ? const Center(child: Text('Agrega productos a transferir'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        final item = _productos[index];
                        return ListTile(
                          title: Text(item.producto.nombre),
                          subtitle: Text('Cantidad: ${item.cantidad}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                setState(() => _productos.removeAt(index)),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _almacenOrigenId != null &&
                        _almacenDestinoId != null &&
                        _almacenOrigenId != _almacenDestinoId &&
                        _productos.isNotEmpty
                    ? _crearTransferencia
                    : null,
                child: const Text('Crear Transferencia'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _agregarProducto() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Seleccionar Producto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductosBloc, ProductosState>(
                builder: (context, state) {
                  if (state is ProductosLoaded) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.productos.length,
                      itemBuilder: (context, index) {
                        final producto = state.productos[index];
                        final yaAgregado = _productos.any(
                          (p) => p.producto.id == producto.id,
                        );

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.inventory_2,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          title: Text(producto.nombre),
                          subtitle: Text(producto.codigo),
                          trailing: yaAgregado
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.successColor,
                                )
                              : const Icon(Icons.add_circle_outline),
                          onTap: () {
                            if (!yaAgregado) {
                              _mostrarCantidad(producto, sheetContext);
                            }
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarCantidad(Producto producto, BuildContext sheetContext) {
    final cantidadController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cantidad: ${producto.nombre}'),
        content: TextField(
          controller: cantidadController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cantidad',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final cantidad = int.tryParse(cantidadController.text) ?? 1;
              setState(() {
                _productos.add(
                  _ItemTransferencia(producto: producto, cantidad: cantidad),
                );
              });
              Navigator.pop(dialogContext);
              Navigator.pop(sheetContext);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _crearTransferencia() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe iniciar sesion'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final detalles = _productos
        .map(
          (item) => TransferenciaDetalleItem(
            productoId: item.producto.id,
            cantidad: item.cantidad,
          ),
        )
        .toList();

    context.read<TransferenciasBloc>().add(
      CreateTransferencia(
        usuarioId: authState.user.id,
        origenAlmacenId: _almacenOrigenId,
        destinoAlmacenId: _almacenDestinoId,
        observaciones: _observacionesController.text.isEmpty
            ? null
            : _observacionesController.text,
        detalles: detalles,
      ),
    );

    Navigator.pop(context);
  }
}

class _ItemTransferencia {
  final Producto producto;
  int cantidad;

  _ItemTransferencia({required this.producto, required this.cantidad});
}
