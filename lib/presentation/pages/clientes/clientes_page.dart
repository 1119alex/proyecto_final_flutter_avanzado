import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../../blocs/clientes/clientes_bloc.dart';
import '../../blocs/clientes/clientes_event.dart';
import '../../blocs/clientes/clientes_state.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ClientesBloc>().add(const LoadClientes());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: Column(
        children: [
          // Barra de busqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar clientes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ClientesBloc>().add(
                            const LoadClientes(),
                          );
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  context.read<ClientesBloc>().add(const LoadClientes());
                } else {
                  context.read<ClientesBloc>().add(SearchClientes(value));
                }
                setState(() {});
              },
            ),
          ),

          // Lista de clientes
          Expanded(
            child: BlocConsumer<ClientesBloc, ClientesState>(
              listener: (context, state) {
                if (state is ClienteCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cliente creado exitosamente'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (state is ClienteUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cliente actualizado exitosamente'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (state is ClienteDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cliente eliminado exitosamente'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (state is ClientesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ClientesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ClientesLoaded) {
                  if (state.clientes.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildClientesList(state.clientes);
                }

                if (state is ClientesError) {
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
                            context.read<ClientesBloc>().add(
                              const LoadClientes(),
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
        onPressed: () => _mostrarFormularioCliente(context, null),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Cliente'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay clientes',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer cliente usando el boton +',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildClientesList(List<Cliente> clientes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: clientes.length,
      itemBuilder: (context, index) {
        final cliente = clientes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppTheme.primaryColor),
            ),
            title: Text(
              cliente.nombre,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: cliente.nit != null ? Text('NIT: ${cliente.nit}') : null,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (cliente.telefono != null)
                      _buildInfoRow(Icons.phone, 'Telefono', cliente.telefono!),
                    if (cliente.email != null)
                      _buildInfoRow(Icons.email, 'Email', cliente.email!),
                    if (cliente.direccion != null)
                      _buildInfoRow(
                        Icons.location_on,
                        'Direccion',
                        cliente.direccion!,
                      ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              _mostrarFormularioCliente(context, cliente),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            final activo = cliente.activo;
                            context.read<ClientesBloc>().add(
                              ToggleClienteEstado(
                                id: cliente.id,
                                activo: !activo,
                              ),
                            );
                          },
                          icon: Icon(
                            cliente.activo ? Icons.block : Icons.check_circle,
                            size: 18,
                          ),
                          label: Text(
                            cliente.activo ? 'Desactivar' : 'Activar',
                          ),
                        ),
                        if (cliente.activo)
                          OutlinedButton.icon(
                            onPressed: () =>
                                _confirmarEliminar(context, cliente),
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
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Cliente cliente) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('Estas seguro de eliminar "${cliente.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ClientesBloc>().add(DeleteCliente(cliente.id));
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

  void _mostrarFormularioCliente(BuildContext context, Cliente? cliente) {
    final esEdicion = cliente != null;
    final nombreController = TextEditingController(text: cliente?.nombre ?? '');
    final nitController = TextEditingController(text: cliente?.nit ?? '');
    final telefonoController = TextEditingController(
      text: cliente?.telefono ?? '',
    );
    final emailController = TextEditingController(text: cliente?.email ?? '');
    final direccionController = TextEditingController(
      text: cliente?.direccion ?? '',
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(esEdicion ? 'Editar Cliente' : 'Nuevo Cliente'),
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
                    prefixIcon: Icon(Icons.person),
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
                TextFormField(
                  controller: nitController,
                  decoration: const InputDecoration(
                    labelText: 'NIT/CI',
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Telefono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Direccion',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
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
                  context.read<ClientesBloc>().add(
                    UpdateCliente(
                      id: cliente.id,
                      nombre: nombreController.text.trim(),
                      nit: nitController.text.trim().isEmpty
                          ? null
                          : nitController.text.trim(),
                      telefono: telefonoController.text.trim().isEmpty
                          ? null
                          : telefonoController.text.trim(),
                      email: emailController.text.trim().isEmpty
                          ? null
                          : emailController.text.trim(),
                      direccion: direccionController.text.trim().isEmpty
                          ? null
                          : direccionController.text.trim(),
                      activo: cliente.activo,
                    ),
                  );
                } else {
                  context.read<ClientesBloc>().add(
                    CreateCliente(
                      nombre: nombreController.text.trim(),
                      nit: nitController.text.trim().isEmpty
                          ? null
                          : nitController.text.trim(),
                      telefono: telefonoController.text.trim().isEmpty
                          ? null
                          : telefonoController.text.trim(),
                      email: emailController.text.trim().isEmpty
                          ? null
                          : emailController.text.trim(),
                      direccion: direccionController.text.trim().isEmpty
                          ? null
                          : direccionController.text.trim(),
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
