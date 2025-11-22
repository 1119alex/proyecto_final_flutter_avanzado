import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../../blocs/proveedores/proveedores_bloc.dart';
import '../../blocs/proveedores/proveedores_event.dart';
import '../../blocs/proveedores/proveedores_state.dart';

class ProveedoresPage extends StatefulWidget {
  const ProveedoresPage({super.key});

  @override
  State<ProveedoresPage> createState() => _ProveedoresPageState();
}

class _ProveedoresPageState extends State<ProveedoresPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProveedoresBloc>().add(const LoadProveedores());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores')),
      body: BlocConsumer<ProveedoresBloc, ProveedoresState>(
        listener: (context, state) {
          if (state is ProveedorCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Proveedor creado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is ProveedorUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Proveedor actualizado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is ProveedorDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Proveedor eliminado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is ProveedoresError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProveedoresLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProveedoresLoaded) {
            if (state.proveedores.isEmpty) {
              return _buildEmptyState();
            }
            return _buildProveedoresList(state.proveedores);
          }

          if (state is ProveedoresError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar proveedores',
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
                      context.read<ProveedoresBloc>().add(
                        const LoadProveedores(),
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
        onPressed: () => _mostrarFormularioProveedor(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay proveedores',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer proveedor',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProveedoresList(List<Proveedor> proveedores) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: proveedores.length,
      itemBuilder: (context, index) {
        final proveedor = proveedores[index];
        final activo = proveedor.activo;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: activo
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              child: Icon(
                Icons.local_shipping,
                color: activo ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    proveedor.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: activo ? null : Colors.grey,
                    ),
                  ),
                ),
                if (!activo)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'INACTIVO',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
              ],
            ),
            subtitle: proveedor.contacto != null
                ? Text('Contacto: ${proveedor.contacto}')
                : null,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (proveedor.telefono != null)
                      _buildInfoRow(
                        Icons.phone,
                        'Teléfono',
                        proveedor.telefono!,
                      ),
                    if (proveedor.email != null)
                      _buildInfoRow(Icons.email, 'Email', proveedor.email!),
                    if (proveedor.direccion != null)
                      _buildInfoRow(
                        Icons.location_on,
                        'Dirección',
                        proveedor.direccion!,
                      ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              _mostrarFormularioProveedor(context, proveedor),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.read<ProveedoresBloc>().add(
                              ToggleProveedorEstado(
                                id: proveedor.id,
                                activo: !activo,
                              ),
                            );
                          },
                          icon: Icon(
                            activo ? Icons.block : Icons.check_circle,
                            size: 18,
                          ),
                          label: Text(activo ? 'Desactivar' : 'Activar'),
                        ),
                        if (activo)
                          OutlinedButton.icon(
                            onPressed: () =>
                                _confirmarEliminar(context, proveedor),
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Eliminar'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Proveedor proveedor) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de eliminar el proveedor "${proveedor.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProveedoresBloc>().add(
                DeleteProveedor(proveedor.id),
              );
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

  void _mostrarFormularioProveedor(BuildContext context, Proveedor? proveedor) {
    final esEdicion = proveedor != null;
    final nombreController = TextEditingController(
      text: proveedor?.nombre ?? '',
    );
    final contactoController = TextEditingController(
      text: proveedor?.contacto ?? '',
    );
    final telefonoController = TextEditingController(
      text: proveedor?.telefono ?? '',
    );
    final emailController = TextEditingController(text: proveedor?.email ?? '');
    final direccionController = TextEditingController(
      text: proveedor?.direccion ?? '',
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(esEdicion ? 'Editar Proveedor' : 'Nuevo Proveedor'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre/Razón Social *',
                    prefixIcon: Icon(Icons.business),
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
                  controller: contactoController,
                  decoration: const InputDecoration(
                    labelText: 'Persona de contacto',
                    prefixIcon: Icon(Icons.person),
                  ),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.words,
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
                final contacto = contactoController.text.trim();
                final telefono = telefonoController.text.trim();
                final email = emailController.text.trim();
                final direccion = direccionController.text.trim();

                if (esEdicion) {
                  context.read<ProveedoresBloc>().add(
                    UpdateProveedor(
                      id: proveedor.id,
                      nombre: nombre,
                      contacto: contacto.isEmpty ? null : contacto,
                      telefono: telefono.isEmpty ? null : telefono,
                      email: email.isEmpty ? null : email,
                      direccion: direccion.isEmpty ? null : direccion,
                      activo: proveedor.activo,
                    ),
                  );
                } else {
                  context.read<ProveedoresBloc>().add(
                    CreateProveedor(
                      nombre: nombre,
                      contacto: contacto.isEmpty ? null : contacto,
                      telefono: telefono.isEmpty ? null : telefono,
                      email: email.isEmpty ? null : email,
                      direccion: direccion.isEmpty ? null : direccion,
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
