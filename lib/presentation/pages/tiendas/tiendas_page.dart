import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../../blocs/tiendas/tiendas_bloc.dart';
import '../../blocs/tiendas/tiendas_event.dart';
import '../../blocs/tiendas/tiendas_state.dart';

class TiendasPage extends StatefulWidget {
  const TiendasPage({super.key});

  @override
  State<TiendasPage> createState() => _TiendasPageState();
}

class _TiendasPageState extends State<TiendasPage> {
  @override
  void initState() {
    super.initState();
    context.read<TiendasBloc>().add(const LoadTiendas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiendas')),
      body: BlocConsumer<TiendasBloc, TiendasState>(
        listener: (context, state) {
          if (state is TiendaCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tienda creada exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is TiendaUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tienda actualizada exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is TiendaDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tienda eliminada exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is TiendasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TiendasLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TiendasLoaded) {
            if (state.tiendas.isEmpty) {
              return _buildEmptyState();
            }
            return _buildTiendasList(state.tiendas);
          }

          if (state is TiendasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar tiendas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TiendasBloc>().add(const LoadTiendas());
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
        onPressed: () => _mostrarFormularioTienda(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay tiendas',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primera tienda',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTiendasList(List<Tienda> tiendas) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tiendas.length,
      itemBuilder: (context, index) {
        final tienda = tiendas[index];
        final activa = tienda.activo;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: activa
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.store,
                    color: activa ? AppTheme.primaryColor : Colors.grey,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(tienda.nombre)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: activa ? AppTheme.successColor : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activa ? 'Activa' : 'Inactiva',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: Text(tienda.direccion)),
                      ],
                    ),
                    if (tienda.telefono != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(tienda.telefono!),
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(
                      value: 'estado',
                      child: Text(activa ? 'Desactivar' : 'Activar'),
                    ),
                    if (activa)
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Text('Eliminar'),
                      ),
                  ],
                  onSelected: (value) {
                    if (value == 'editar') {
                      _mostrarFormularioTienda(context, tienda);
                    } else if (value == 'estado') {
                      context.read<TiendasBloc>().add(
                        ToggleTiendaEstado(id: tienda.id, activo: !activa),
                      );
                    } else if (value == 'eliminar') {
                      _confirmarEliminar(context, tienda);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarEliminar(BuildContext context, Tienda tienda) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de eliminar la tienda "${tienda.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TiendasBloc>().add(DeleteTienda(tienda.id));
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

  void _mostrarFormularioTienda(BuildContext context, Tienda? tienda) {
    final esEdicion = tienda != null;
    final nombreController = TextEditingController(text: tienda?.nombre ?? '');
    final direccionController = TextEditingController(
      text: tienda?.direccion ?? '',
    );
    final telefonoController = TextEditingController(
      text: tienda?.telefono ?? '',
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(esEdicion ? 'Editar Tienda' : 'Nueva Tienda'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección *',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La dirección es requerida';
                    }
                    return null;
                  },
                  maxLines: 2,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
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

                final nombre = nombreController.text.trim();
                final direccion = direccionController.text.trim();
                final telefono = telefonoController.text.trim();

                if (esEdicion) {
                  context.read<TiendasBloc>().add(
                    UpdateTienda(
                      id: tienda.id,
                      nombre: nombre,
                      direccion: direccion,
                      telefono: telefono.isEmpty ? null : telefono,
                      activo: tienda.activo,
                    ),
                  );
                } else {
                  context.read<TiendasBloc>().add(
                    CreateTienda(
                      nombre: nombre,
                      direccion: direccion,
                      telefono: telefono.isEmpty ? null : telefono,
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
