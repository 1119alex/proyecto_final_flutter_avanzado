import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../../blocs/almacenes/almacenes_bloc.dart';
import '../../blocs/almacenes/almacenes_event.dart';
import '../../blocs/almacenes/almacenes_state.dart';

class AlmacenesPage extends StatefulWidget {
  const AlmacenesPage({super.key});

  @override
  State<AlmacenesPage> createState() => _AlmacenesPageState();
}

class _AlmacenesPageState extends State<AlmacenesPage> {
  @override
  void initState() {
    super.initState();
    context.read<AlmacenesBloc>().add(const LoadAlmacenes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Almacenes')),
      body: BlocConsumer<AlmacenesBloc, AlmacenesState>(
        listener: (context, state) {
          if (state is AlmacenCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Almacén creado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is AlmacenUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Almacén actualizado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is AlmacenDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Almacén eliminado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is AlmacenesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AlmacenesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AlmacenesLoaded) {
            if (state.almacenes.isEmpty) {
              return _buildEmptyState();
            }
            return _buildAlmacenesList(state.almacenes);
          }

          if (state is AlmacenesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar almacenes',
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
                      context.read<AlmacenesBloc>().add(const LoadAlmacenes());
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
        onPressed: () => _mostrarFormularioAlmacen(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warehouse, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay almacenes',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer almacén',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAlmacenesList(List<Almacen> almacenes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: almacenes.length,
      itemBuilder: (context, index) {
        final almacen = almacenes[index];
        final activo = almacen.activo;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: activo
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.warehouse,
                    color: activo ? AppTheme.primaryColor : Colors.grey,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(almacen.nombre)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: activo ? AppTheme.successColor : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activo ? 'Activo' : 'Inactivo',
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
                        Expanded(child: Text(almacen.direccion)),
                      ],
                    ),
                    if (almacen.telefono != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(almacen.telefono!),
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
                      child: Text(activo ? 'Desactivar' : 'Activar'),
                    ),
                    if (activo)
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Text('Eliminar'),
                      ),
                  ],
                  onSelected: (value) {
                    if (value == 'editar') {
                      _mostrarFormularioAlmacen(context, almacen);
                    } else if (value == 'estado') {
                      context.read<AlmacenesBloc>().add(
                        ToggleAlmacenEstado(id: almacen.id, activo: !activo),
                      );
                    } else if (value == 'eliminar') {
                      _confirmarEliminar(context, almacen);
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

  void _confirmarEliminar(BuildContext context, Almacen almacen) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de eliminar el almacén "${almacen.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AlmacenesBloc>().add(DeleteAlmacen(almacen.id));
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

  void _mostrarFormularioAlmacen(BuildContext context, Almacen? almacen) {
    final esEdicion = almacen != null;
    final nombreController = TextEditingController(text: almacen?.nombre ?? '');
    final direccionController = TextEditingController(
      text: almacen?.direccion ?? '',
    );
    final telefonoController = TextEditingController(
      text: almacen?.telefono ?? '',
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(esEdicion ? 'Editar Almacén' : 'Nuevo Almacén'),
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
                    prefixIcon: Icon(Icons.warehouse),
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
                  context.read<AlmacenesBloc>().add(
                    UpdateAlmacen(
                      id: almacen.id,
                      nombre: nombre,
                      direccion: direccion,
                      telefono: telefono.isEmpty ? null : telefono,
                      activo: almacen.activo,
                    ),
                  );
                } else {
                  context.read<AlmacenesBloc>().add(
                    CreateAlmacen(
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
