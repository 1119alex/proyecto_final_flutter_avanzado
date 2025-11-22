import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/proveedores/proveedores_bloc.dart';
import '../../blocs/proveedores/proveedores_event.dart';
import '../../blocs/proveedores/proveedores_state.dart';
import '../../blocs/productos/productos_bloc.dart';
import '../../blocs/productos/productos_event.dart';
import '../../blocs/productos/productos_state.dart';
import '../../blocs/almacenes/almacenes_bloc.dart';
import '../../blocs/almacenes/almacenes_event.dart';
import '../../blocs/almacenes/almacenes_state.dart';
import '../../blocs/compras/compras_bloc.dart';
import '../../blocs/compras/compras_event.dart';
import '../../blocs/compras/compras_state.dart';

class NuevaCompraPage extends StatefulWidget {
  const NuevaCompraPage({super.key});

  @override
  State<NuevaCompraPage> createState() => _NuevaCompraPageState();
}

class _NuevaCompraPageState extends State<NuevaCompraPage> {
  final List<_ItemCompra> _items = [];
  String? _selectedProveedorId;
  String? _selectedAlmacenId;
  final _observacionesController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(
    locale: 'es_BO',
    symbol: '',
    decimalDigits: 2,
  );

  double get _total => _items.fold(0, (sum, item) => sum + item.subtotal);

  @override
  void initState() {
    super.initState();
    // Cargar datos necesarios
    context.read<ProveedoresBloc>().add(const LoadProveedores());
    context.read<ProductosBloc>().add(const LoadProductos());
    context.read<AlmacenesBloc>().add(const LoadAlmacenes());
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComprasBloc, ComprasState>(
      listener: (context, state) {
        if (state is CompraCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compra registrada exitosamente'),
              backgroundColor: Colors.purple,
            ),
          );
          context.pop();
        } else if (state is ComprasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nueva Compra'),
          backgroundColor: Colors.purple,
        ),
        body: Column(
          children: [
            // Formulario superior
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Seleccionar proveedor (obligatorio)
                  BlocBuilder<ProveedoresBloc, ProveedoresState>(
                    builder: (context, state) {
                      if (state is ProveedoresLoaded &&
                          state.proveedores.isNotEmpty) {
                        // Auto-seleccionar primer proveedor si no hay seleccionado
                        if (_selectedProveedorId == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _selectedProveedorId == null) {
                              setState(() {
                                _selectedProveedorId =
                                    state.proveedores.first.id;
                              });
                            }
                          });
                        }
                        return DropdownButtonFormField<String>(
                          value: _selectedProveedorId,
                          decoration: const InputDecoration(
                            labelText: 'Proveedor *',
                            prefixIcon: Icon(Icons.local_shipping),
                            border: OutlineInputBorder(),
                          ),
                          items: state.proveedores
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.nombre),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedProveedorId = value);
                          },
                        );
                      }
                      // Mostrar mensaje si no hay proveedores
                      if (state is ProveedoresLoaded &&
                          state.proveedores.isEmpty) {
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
                              Text('No hay proveedores registrados'),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Seleccionar almacen destino (obligatorio)
                  BlocBuilder<AlmacenesBloc, AlmacenesState>(
                    builder: (context, state) {
                      if (state is AlmacenesLoaded &&
                          state.almacenes.isNotEmpty) {
                        // Auto-seleccionar primer almacen si no hay seleccionado
                        if (_selectedAlmacenId == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _selectedAlmacenId == null) {
                              setState(() {
                                _selectedAlmacenId = state.almacenes.first.id;
                              });
                            }
                          });
                        }
                        return DropdownButtonFormField<String>(
                          value: _selectedAlmacenId,
                          decoration: const InputDecoration(
                            labelText: 'Almacen destino *',
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
                          onChanged: (value) {
                            setState(() => _selectedAlmacenId = value);
                          },
                        );
                      }
                      // Mostrar mensaje si no hay almacenes
                      if (state is AlmacenesLoaded && state.almacenes.isEmpty) {
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
                              Text('No hay almacenes registrados'),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
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
                            'Agrega productos a la compra',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _agregarProducto,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Producto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                            ),
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
                              foregroundColor: Colors.purple,
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
                                          color: Colors.purple,
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
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Boton confirmar compra
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            _items.isEmpty ||
                                _selectedProveedorId == null ||
                                _selectedAlmacenId == null
                            ? null
                            : _confirmarCompra,
                        icon: const Icon(Icons.check_circle),
                        label: const Text(
                          'CONFIRMAR COMPRA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
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
                            backgroundColor: Colors.purple.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.inventory_2,
                              color: Colors.purple,
                            ),
                          ),
                          title: Text(producto.nombre),
                          subtitle: Text(
                            '${producto.codigo} - Costo: ${_currencyFormat.format(producto.precioCompra)} Bs.',
                          ),
                          trailing: yaAgregado
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.purple,
                                )
                              : const Icon(Icons.add_circle_outline),
                          onTap: () {
                            if (!yaAgregado) {
                              _mostrarDialogoPrecio(producto, sheetContext);
                            } else {
                              Navigator.pop(sheetContext);
                            }
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

  void _mostrarDialogoPrecio(Producto producto, BuildContext sheetContext) {
    final precioController = TextEditingController(
      text: producto.precioCompra.toStringAsFixed(2),
    );
    final cantidadController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Agregar: ${producto.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio unitario (Bs.)',
                border: OutlineInputBorder(),
              ),
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
              final cantidad = int.tryParse(cantidadController.text) ?? 1;
              final precio =
                  double.tryParse(precioController.text) ??
                  producto.precioCompra;

              setState(() {
                _items.add(
                  _ItemCompra(
                    producto: producto,
                    cantidad: cantidad,
                    precioUnitario: precio,
                  ),
                );
              });

              Navigator.pop(dialogContext);
              Navigator.pop(sheetContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _confirmarCompra() {
    if (_selectedProveedorId == null || _selectedAlmacenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar proveedor y almacen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Productos: ${_items.length}'),
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
              _procesarCompra();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _procesarCompra() {
    // Obtener el usuario autenticado
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe iniciar sesion para realizar compras'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final usuarioId = authState.user.id;

    final detalles = _items
        .map(
          (item) => CompraDetalleItem(
            productoId: item.producto.id,
            cantidad: item.cantidad,
            precioUnitario: item.precioUnitario,
          ),
        )
        .toList();

    context.read<ComprasBloc>().add(
      CreateCompra(
        proveedorId: _selectedProveedorId!,
        almacenId: _selectedAlmacenId!,
        usuarioId: usuarioId,
        observaciones: _observacionesController.text.isEmpty
            ? null
            : _observacionesController.text,
        detalles: detalles,
      ),
    );
  }
}

class _ItemCompra {
  final Producto producto;
  int cantidad;
  final double precioUnitario;

  _ItemCompra({
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
  });

  double get subtotal => precioUnitario * cantidad;
}
