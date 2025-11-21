import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/categorias/categorias_bloc.dart';
import '../../blocs/categorias/categorias_event.dart';
import '../../blocs/categorias/categorias_state.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  @override
  void initState() {
    super.initState();
    // Cargar categorías al iniciar
    context.read<CategoriasBloc>().add(const LoadCategorias());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: BlocConsumer<CategoriasBloc, CategoriasState>(
        listener: (context, state) {
          if (state is CategoriaCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Categoría creada exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is CategoriaUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Categoría actualizada'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is CategoriaDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Categoría eliminada'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is CategoriasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoriasLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoriasLoaded) {
            if (state.categorias.isEmpty) {
              return _buildEmptyState();
            }
            return _buildCategoriasList(state.categorias);
          }

          if (state is CategoriasError) {
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
                      context.read<CategoriasBloc>().add(
                        const LoadCategorias(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioCategoria(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay categorías',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primera categoría',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriasList(List categorias) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final categoria = categorias[index];

        IconData iconData = Icons.category;
        if (categoria.icono != null) {
          switch (categoria.icono) {
            case 'book':
              iconData = Icons.book;
              break;
            case 'school':
              iconData = Icons.school;
              break;
            case 'create':
              iconData = Icons.create;
              break;
            case 'palette':
              iconData = Icons.palette;
              break;
            case 'calculate':
              iconData = Icons.calculate;
              break;
            case 'attach_file':
              iconData = Icons.attach_file;
              break;
            default:
              iconData = Icons.category;
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Icon(iconData, color: AppTheme.primaryColor),
            ),
            title: Text(
              categoria.nombre,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: categoria.descripcion != null
                ? Text(categoria.descripcion!)
                : null,
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'estado',
                  child: Row(
                    children: [
                      Icon(
                        categoria.activo
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(categoria.activo ? 'Desactivar' : 'Activar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'editar') {
                  _mostrarFormularioCategoria(context, categoria);
                } else if (value == 'estado') {
                  context.read<CategoriasBloc>().add(
                    ToggleCategoriaEstado(
                      id: categoria.id,
                      activo: !categoria.activo,
                    ),
                  );
                } else if (value == 'eliminar') {
                  _confirmarEliminacion(context, categoria);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _mostrarFormularioCategoria(BuildContext context, dynamic categoria) {
    final esEdicion = categoria != null;
    final nombreController = TextEditingController(
      text: categoria?.nombre ?? '',
    );
    final descripcionController = TextEditingController(
      text: categoria?.descripcion ?? '',
    );
    String? iconoSeleccionado = categoria?.icono;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(esEdicion ? 'Editar Categoría' : 'Nueva Categoría'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: iconoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Icono',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Sin icono')),
                      DropdownMenuItem(
                        value: 'book',
                        child: Row(
                          children: [
                            Icon(Icons.book),
                            SizedBox(width: 8),
                            Text('Libro'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'school',
                        child: Row(
                          children: [
                            Icon(Icons.school),
                            SizedBox(width: 8),
                            Text('Escolar'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'create',
                        child: Row(
                          children: [
                            Icon(Icons.create),
                            SizedBox(width: 8),
                            Text('Escritura'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'palette',
                        child: Row(
                          children: [
                            Icon(Icons.palette),
                            SizedBox(width: 8),
                            Text('Arte'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'calculate',
                        child: Row(
                          children: [
                            Icon(Icons.calculate),
                            SizedBox(width: 8),
                            Text('Cálculo'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'attach_file',
                        child: Row(
                          children: [
                            Icon(Icons.attach_file),
                            SizedBox(width: 8),
                            Text('Archivo'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        iconoSeleccionado = value;
                      });
                    },
                  );
                },
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
              final nombre = nombreController.text.trim();
              if (nombre.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El nombre es requerido'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              if (esEdicion) {
                context.read<CategoriasBloc>().add(
                  UpdateCategoria(
                    id: categoria.id,
                    nombre: nombre,
                    descripcion: descripcionController.text.trim().isEmpty
                        ? null
                        : descripcionController.text.trim(),
                    icono: iconoSeleccionado,
                    activo: categoria.activo,
                  ),
                );
              } else {
                context.read<CategoriasBloc>().add(
                  CreateCategoria(
                    nombre: nombre,
                    descripcion: descripcionController.text.trim().isEmpty
                        ? null
                        : descripcionController.text.trim(),
                    icono: iconoSeleccionado,
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

  void _confirmarEliminacion(BuildContext context, dynamic categoria) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la categoría "${categoria.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CategoriasBloc>().add(DeleteCategoria(categoria.id));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
