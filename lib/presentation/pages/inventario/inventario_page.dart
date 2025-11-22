import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/daos/inventario_dao.dart';
import '../../blocs/inventario/inventario_bloc.dart';
import '../../blocs/inventario/inventario_event.dart';
import '../../blocs/inventario/inventario_state.dart';
import '../../blocs/tiendas/tiendas_bloc.dart';
import '../../blocs/tiendas/tiendas_event.dart';
import '../../blocs/tiendas/tiendas_state.dart';
import '../../blocs/almacenes/almacenes_bloc.dart';
import '../../blocs/almacenes/almacenes_event.dart';
import '../../blocs/almacenes/almacenes_state.dart';
import '../../blocs/productos/productos_bloc.dart';
import '../../blocs/productos/productos_event.dart';
import '../../blocs/productos/productos_state.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  String? _filtroTiendaId;
  String? _filtroAlmacenId;

  @override
  void initState() {
    super.initState();
    context.read<InventarioBloc>().add(const LoadInventario());
    context.read<TiendasBloc>().add(const LoadTiendas());
    context.read<AlmacenesBloc>().add(const LoadAlmacenes());
    context.read<ProductosBloc>().add(const LoadProductos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
          IconButton(
            icon: const Icon(Icons.warning_amber),
            tooltip: 'Ver stock bajo',
            onPressed: () {
              context.read<InventarioBloc>().add(
                const LoadProductosStockBajo(),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<InventarioBloc, InventarioState>(
        listener: (context, state) {
          if (state is InventarioCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inventario registrado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is InventarioUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inventario actualizado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is InventarioDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro eliminado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is InventarioError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InventarioLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductosStockBajoLoaded) {
            return _buildStockBajoList(state.items);
          }

          if (state is InventarioLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyState();
            }
            return _buildInventarioList(state.items);
          }

          if (state is InventarioError) {
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
                      context.read<InventarioBloc>().add(
                        const LoadInventario(),
                      );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioInventario(context),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Stock'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay registros de inventario',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega stock a tus productos',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInventarioList(List<InventarioDetallado> items) {
    return Column(
      children: [
        // Filtros activos
        if (_filtroTiendaId != null || _filtroAlmacenId != null)
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
                      context.read<InventarioBloc>().add(
                        const LoadInventario(),
                      );
                    },
                  ),
                if (_filtroAlmacenId != null)
                  Chip(
                    label: const Text('Almacen'),
                    onDeleted: () {
                      setState(() => _filtroAlmacenId = null);
                      context.read<InventarioBloc>().add(
                        const LoadInventario(),
                      );
                    },
                  ),
              ],
            ),
          ),
        // Lista
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final stockBajo =
                  item.inventario.cantidad < item.producto.stockMinimo;
              final sinStock = item.inventario.cantidad == 0;

              Color stockColor;
              String stockText;
              if (sinStock) {
                stockColor = Colors.red;
                stockText = 'Sin stock';
              } else if (stockBajo) {
                stockColor = Colors.orange;
                stockText = 'Bajo';
              } else {
                stockColor = AppTheme.successColor;
                stockText = 'Normal';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: stockColor.withValues(alpha: 0.1),
                    child: Icon(Icons.inventory, color: stockColor),
                  ),
                  title: Text(
                    item.producto.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Codigo: ${item.producto.codigo}'),
                      Text(item.ubicacion),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: stockColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stockText,
                          style: TextStyle(color: stockColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.inventario.cantidad}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Min: ${item.producto.stockMinimo}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () => _mostrarDetalleInventario(context, item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStockBajoList(List<InventarioConProducto> items) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange.withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Productos con stock bajo: ${items.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.read<InventarioBloc>().add(const LoadInventario());
                },
                child: const Text('Ver todo'),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.green[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos con stock bajo',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.warning,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(item.producto.nombre),
                        subtitle: Text('Codigo: ${item.producto.codigo}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${item.inventario.cantidad}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.orange,
                              ),
                            ),
                            Text('Min: ${item.producto.stockMinimo}'),
                          ],
                        ),
                      ),
                    );
                  },
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
              'Filtrar Inventario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
                      setState(() {
                        _filtroTiendaId = v;
                        _filtroAlmacenId = null;
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
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
                      setState(() {
                        _filtroAlmacenId = v;
                        _filtroTiendaId = null;
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  if (_filtroTiendaId != null) {
                    context.read<InventarioBloc>().add(
                      LoadInventarioByTienda(_filtroTiendaId!),
                    );
                  } else if (_filtroAlmacenId != null) {
                    context.read<InventarioBloc>().add(
                      LoadInventarioByAlmacen(_filtroAlmacenId!),
                    );
                  } else {
                    context.read<InventarioBloc>().add(const LoadInventario());
                  }
                },
                child: const Text('Aplicar Filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleInventario(
    BuildContext context,
    InventarioDetallado item,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.producto.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleRow('Codigo', item.producto.codigo),
            _buildDetalleRow('Ubicacion', item.ubicacion),
            _buildDetalleRow(
              'Stock actual',
              '${item.inventario.cantidad} unidades',
            ),
            _buildDetalleRow(
              'Stock minimo',
              '${item.producto.stockMinimo} unidades',
            ),
            const Divider(),
            const Text(
              'Ajustar cantidad:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  iconSize: 36,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<InventarioBloc>().add(
                      AjustarInventario(id: item.inventario.id, ajuste: -1),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  '${item.inventario.cantidad}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  iconSize: 36,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<InventarioBloc>().add(
                      AjustarInventario(id: item.inventario.id, ajuste: 1),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _mostrarAjusteManual(context, item);
            },
            child: const Text('Ajuste manual'),
          ),
        ],
      ),
    );
  }

  void _mostrarAjusteManual(BuildContext context, InventarioDetallado item) {
    final controller = TextEditingController(
      text: '${item.inventario.cantidad}',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajuste Manual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Producto: ${item.producto.nombre}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nueva cantidad',
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nuevaCantidad = int.tryParse(controller.text);
              if (nuevaCantidad != null && nuevaCantidad >= 0) {
                Navigator.pop(dialogContext);
                context.read<InventarioBloc>().add(
                  UpdateInventarioCantidad(
                    id: item.inventario.id,
                    cantidad: nuevaCantidad,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarFormularioInventario(BuildContext context) {
    String? productoSeleccionado;
    String? tiendaSeleccionada;
    String? almacenSeleccionado;
    final cantidadController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Agregar Stock'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<ProductosBloc, ProductosState>(
                builder: (context, state) {
                  if (state is ProductosLoaded) {
                    return DropdownButtonFormField<String>(
                      value: productoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Producto *',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      items: state.productos
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => productoSeleccionado = v,
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<TiendasBloc, TiendasState>(
                builder: (context, state) {
                  if (state is TiendasLoaded) {
                    return DropdownButtonFormField<String?>(
                      value: tiendaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Tienda (opcional)',
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Ninguna'),
                        ),
                        ...state.tiendas.map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.nombre),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        tiendaSeleccionada = v;
                        if (v != null) almacenSeleccionado = null;
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),
              BlocBuilder<AlmacenesBloc, AlmacenesState>(
                builder: (context, state) {
                  if (state is AlmacenesLoaded) {
                    return DropdownButtonFormField<String?>(
                      value: almacenSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Almacen (opcional)',
                        prefixIcon: Icon(Icons.warehouse),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Ninguno'),
                        ),
                        ...state.almacenes.map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.nombre),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        almacenSeleccionado = v;
                        if (v != null) tiendaSeleccionada = null;
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad *',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (productoSeleccionado == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seleccione un producto')),
                );
                return;
              }
              final cantidad = int.tryParse(cantidadController.text) ?? 0;
              if (cantidad <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese una cantidad valida')),
                );
                return;
              }

              Navigator.pop(dialogContext);
              context.read<InventarioBloc>().add(
                CreateInventario(
                  productoId: productoSeleccionado!,
                  tiendaId: tiendaSeleccionada,
                  almacenId: almacenSeleccionado,
                  cantidad: cantidad,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
