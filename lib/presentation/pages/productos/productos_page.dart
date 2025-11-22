import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../../blocs/productos/productos_bloc.dart';
import '../../blocs/productos/productos_event.dart';
import '../../blocs/productos/productos_state.dart';
import '../../blocs/categorias/categorias_bloc.dart';
import '../../blocs/categorias/categorias_event.dart';
import '../../blocs/categorias/categorias_state.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final _searchController = TextEditingController();
  String? _categoriaFiltro;

  @override
  void initState() {
    super.initState();
    context.read<ProductosBloc>().add(const LoadProductos());
    context.read<CategoriasBloc>().add(const LoadCategorias());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductosBloc>().add(
                            const LoadProductos(),
                          );
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  context.read<ProductosBloc>().add(const LoadProductos());
                } else {
                  context.read<ProductosBloc>().add(SearchProductos(value));
                }
                setState(() {});
              },
            ),
          ),

          // Lista de productos
          Expanded(
            child: BlocConsumer<ProductosBloc, ProductosState>(
              listener: (context, state) {
                if (state is ProductoCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto creado exitosamente'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (state is ProductoUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto actualizado exitosamente'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (state is ProductoDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto eliminado exitosamente'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (state is ProductosError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProductosLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductosLoaded) {
                  if (state.productos.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildProductosList(state.productos);
                }

                if (state is ProductosError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProductosBloc>().add(
                              const LoadProductos(),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioProducto(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Producto'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay productos',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer producto usando el botón +',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductosList(List<Producto> productos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: const Icon(
                Icons.inventory_2,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(
              producto.nombre,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Código: ${producto.codigo}'),
                Text(
                  'Precio: Bs. ${producto.precioVenta.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'editar', child: Text('Editar')),
                const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ],
              onSelected: (value) {
                if (value == 'editar') {
                  _mostrarFormularioProducto(context, producto);
                } else if (value == 'eliminar') {
                  _confirmarEliminar(context, producto);
                }
              },
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _confirmarEliminar(BuildContext context, Producto producto) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProductosBloc>().add(DeleteProducto(producto.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => BlocBuilder<CategoriasBloc, CategoriasState>(
        builder: (context, state) {
          List<Categoria> categorias = [];
          if (state is CategoriasLoaded) {
            categorias = state.categorias;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar por categoría',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _categoriaFiltro == null,
                      onSelected: (_) {
                        setState(() => _categoriaFiltro = null);
                        context.read<ProductosBloc>().add(
                          const LoadProductos(),
                        );
                        Navigator.pop(sheetContext);
                      },
                    ),
                    ...categorias.map(
                      (cat) => FilterChip(
                        label: Text(cat.nombre),
                        selected: _categoriaFiltro == cat.id,
                        onSelected: (_) {
                          setState(() => _categoriaFiltro = cat.id);
                          context.read<ProductosBloc>().add(
                            LoadProductosByCategoria(cat.id),
                          );
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _mostrarFormularioProducto(BuildContext context, Producto? producto) {
    final esEdicion = producto != null;
    final codigoController = TextEditingController(
      text: producto?.codigo ?? '',
    );
    final nombreController = TextEditingController(
      text: producto?.nombre ?? '',
    );
    final descripcionController = TextEditingController(
      text: producto?.descripcion ?? '',
    );
    final precioCompraController = TextEditingController(
      text: producto?.precioCompra.toString() ?? '0',
    );
    final precioVentaController = TextEditingController(
      text: producto?.precioVenta.toString() ?? '0',
    );
    final stockMinimoController = TextEditingController(
      text: producto?.stockMinimo.toString() ?? '0',
    );

    String? categoriaSeleccionada = producto?.categoriaId;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<CategoriasBloc, CategoriasState>(
        builder: (context, catState) {
          List<Categoria> categorias = [];
          if (catState is CategoriasLoaded) {
            categorias = catState.categorias;
          }

          return AlertDialog(
            title: Text(esEdicion ? 'Editar Producto' : 'Nuevo Producto'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codigoController,
                      decoration: const InputDecoration(
                        labelText: 'Código *',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El código es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre *',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: categoriaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoría *',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: categorias
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => categoriaSeleccionada = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Seleccione una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: precioCompraController,
                            decoration: const InputDecoration(
                              labelText: 'P. Compra *',
                              prefixText: 'Bs. ',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Número inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: precioVentaController,
                            decoration: const InputDecoration(
                              labelText: 'P. Venta *',
                              prefixText: 'Bs. ',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Número inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockMinimoController,
                      decoration: const InputDecoration(
                        labelText: 'Stock mínimo',
                        prefixIcon: Icon(Icons.warning_amber),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(dialogContext);

                    if (esEdicion) {
                      context.read<ProductosBloc>().add(
                        UpdateProducto(
                          id: producto.id,
                          codigo: codigoController.text.trim(),
                          nombre: nombreController.text.trim(),
                          descripcion: descripcionController.text.trim().isEmpty
                              ? null
                              : descripcionController.text.trim(),
                          categoriaId: categoriaSeleccionada!,
                          precioCompra: double.parse(
                            precioCompraController.text,
                          ),
                          precioVenta: double.parse(precioVentaController.text),
                          stockMinimo:
                              int.tryParse(stockMinimoController.text) ?? 0,
                          activo: producto.activo,
                        ),
                      );
                    } else {
                      context.read<ProductosBloc>().add(
                        CreateProducto(
                          codigo: codigoController.text.trim(),
                          nombre: nombreController.text.trim(),
                          descripcion: descripcionController.text.trim().isEmpty
                              ? null
                              : descripcionController.text.trim(),
                          categoriaId: categoriaSeleccionada!,
                          precioCompra: double.parse(
                            precioCompraController.text,
                          ),
                          precioVenta: double.parse(precioVentaController.text),
                          stockMinimo:
                              int.tryParse(stockMinimoController.text) ?? 0,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
