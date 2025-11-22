import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/clientes/clientes_bloc.dart';
import '../../blocs/clientes/clientes_event.dart';
import '../../blocs/clientes/clientes_state.dart';
import '../../blocs/productos/productos_bloc.dart';
import '../../blocs/productos/productos_event.dart';
import '../../blocs/productos/productos_state.dart';
import '../../blocs/tiendas/tiendas_bloc.dart';
import '../../blocs/tiendas/tiendas_event.dart';
import '../../blocs/tiendas/tiendas_state.dart';
import '../../blocs/ventas/ventas_bloc.dart';
import '../../blocs/ventas/ventas_event.dart';
import '../../blocs/ventas/ventas_state.dart';

class NuevaVentaPage extends StatefulWidget {
  const NuevaVentaPage({super.key});

  @override
  State<NuevaVentaPage> createState() => _NuevaVentaPageState();
}

class _NuevaVentaPageState extends State<NuevaVentaPage> {
  final List<_ItemVenta> _items = [];
  String? _selectedClienteId;
  String? _selectedTiendaId;
  String _metodoPago = 'Efectivo';
  double _descuento = 0;
  final _observacionesController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(
    locale: 'es_BO',
    symbol: '',
    decimalDigits: 2,
  );

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get _total => _subtotal - _descuento;

  @override
  void initState() {
    super.initState();
    // Cargar datos necesarios
    context.read<ClientesBloc>().add(const LoadClientes());
    context.read<ProductosBloc>().add(const LoadProductos());
    context.read<TiendasBloc>().add(const LoadTiendas());
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VentasBloc, VentasState>(
      listener: (context, state) {
        if (state is VentaCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Venta registrada exitosamente'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.pop();
        } else if (state is VentasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nueva Venta')),
        body: Column(
          children: [
            // Formulario superior
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Seleccionar tienda (obligatorio)
                  BlocBuilder<TiendasBloc, TiendasState>(
                    builder: (context, state) {
                      if (state is TiendasLoaded && state.tiendas.isNotEmpty) {
                        // Auto-seleccionar primera tienda si no hay seleccionada
                        if (_selectedTiendaId == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _selectedTiendaId == null) {
                              setState(() {
                                _selectedTiendaId = state.tiendas.first.id;
                              });
                            }
                          });
                        }
                        return DropdownButtonFormField<String>(
                          value: _selectedTiendaId,
                          decoration: const InputDecoration(
                            labelText: 'Tienda *',
                            prefixIcon: Icon(Icons.store),
                            border: OutlineInputBorder(),
                          ),
                          items: state.tiendas
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t.id,
                                  child: Text(t.nombre),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedTiendaId = value);
                          },
                        );
                      }
                      // Mostrar mensaje si no hay tiendas
                      if (state is TiendasLoaded && state.tiendas.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('No hay tiendas registradas'),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Seleccionar cliente (opcional)
                  BlocBuilder<ClientesBloc, ClientesState>(
                    builder: (context, state) {
                      if (state is ClientesLoaded) {
                        return DropdownButtonFormField<String?>(
                          value: _selectedClienteId,
                          decoration: const InputDecoration(
                            labelText: 'Cliente (opcional)',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Cliente General'),
                            ),
                            ...state.clientes.map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  c.nit != null
                                      ? '${c.nombre} - NIT: ${c.nit}'
                                      : c.nombre,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedClienteId = value);
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Metodo de pago
                  DropdownButtonFormField<String>(
                    value: _metodoPago,
                    decoration: const InputDecoration(
                      labelText: 'Metodo de Pago',
                      prefixIcon: Icon(Icons.payment),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Efectivo',
                        child: Text('Efectivo'),
                      ),
                      DropdownMenuItem(
                        value: 'Tarjeta',
                        child: Text('Tarjeta'),
                      ),
                      DropdownMenuItem(
                        value: 'Transferencia',
                        child: Text('Transferencia'),
                      ),
                      DropdownMenuItem(value: 'QR', child: Text('QR')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _metodoPago = value);
                      }
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Lista de productos agregados
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Agrega productos a la venta',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _agregarProducto,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Producto'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Boton agregar mas productos
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: OutlinedButton.icon(
                            onPressed: _agregarProducto,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar mas productos'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 40),
                            ),
                          ),
                        ),
                        // Lista de items
                        Expanded(
                          child: ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  title: Text(
                                    item.producto.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed: item.cantidad > 1
                                            ? () => _cambiarCantidad(index, -1)
                                            : null,
                                        iconSize: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '${item.cantidad}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed: () =>
                                            _cambiarCantidad(index, 1),
                                        iconSize: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'x ${_currencyFormat.format(item.precioUnitario)} Bs.',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_currencyFormat.format(item.subtotal)} Bs.',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.successColor,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(
                                            () => _items.removeAt(index),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),

            // Totales y boton confirmar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('${_currencyFormat.format(_subtotal)} Bs.'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Descuento:'),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            decoration: const InputDecoration(
                              suffixText: ' Bs.',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              setState(
                                () => _descuento = double.tryParse(v) ?? 0,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '${_currencyFormat.format(_total)} Bs.',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Boton confirmar venta
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _items.isEmpty || _selectedTiendaId == null
                            ? null
                            : _confirmarVenta,
                        icon: const Icon(Icons.check_circle),
                        label: const Text(
                          'CONFIRMAR VENTA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cambiarCantidad(int index, int delta) {
    setState(() {
      _items[index].cantidad += delta;
    });
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
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Seleccionar Producto',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        context.read<ProductosBloc>().add(
                          const LoadProductos(),
                        );
                      } else {
                        context.read<ProductosBloc>().add(
                          SearchProductos(value),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductosBloc, ProductosState>(
                builder: (context, state) {
                  if (state is ProductosLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProductosLoaded) {
                    if (state.productos.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay productos disponibles',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.productos.length,
                      itemBuilder: (context, index) {
                        final producto = state.productos[index];
                        final yaAgregado = _items.any(
                          (i) => i.producto.id == producto.id,
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
                          subtitle: Text(
                            '${producto.codigo} - ${_currencyFormat.format(producto.precioVenta)} Bs.',
                          ),
                          trailing: yaAgregado
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.successColor,
                                )
                              : const Icon(Icons.add_circle_outline),
                          onTap: () {
                            if (!yaAgregado) {
                              setState(() {
                                _items.add(
                                  _ItemVenta(
                                    producto: producto,
                                    cantidad: 1,
                                    precioUnitario: producto.precioVenta,
                                  ),
                                );
                              });
                            }
                            Navigator.pop(sheetContext);
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarVenta() {
    if (_selectedTiendaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una tienda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Productos: ${_items.length}'),
            Text('Metodo de pago: $_metodoPago'),
            const Divider(),
            Text(
              'Total: ${_currencyFormat.format(_total)} Bs.',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
              Navigator.pop(dialogContext);
              _procesarVenta();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _procesarVenta() {
    // Obtener el usuario autenticado
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe iniciar sesion para realizar ventas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final usuarioId = authState.user.id;

    final detalles = _items
        .map(
          (item) => VentaDetalleItem(
            productoId: item.producto.id,
            cantidad: item.cantidad,
            precioUnitario: item.precioUnitario,
            descuento: 0,
          ),
        )
        .toList();

    context.read<VentasBloc>().add(
      CreateVenta(
        clienteId: _selectedClienteId,
        tiendaId: _selectedTiendaId!,
        usuarioId: usuarioId,
        descuento: _descuento,
        metodoPago: _metodoPago,
        observaciones: _observacionesController.text.isEmpty
            ? null
            : _observacionesController.text,
        detalles: detalles,
      ),
    );
  }
}

class _ItemVenta {
  final Producto producto;
  int cantidad;
  final double precioUnitario;

  _ItemVenta({
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => precioUnitario * cantidad;
}
