import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';
import '../../../data/local/database/app_database.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../blocs/usuarios/usuarios_bloc.dart';
import '../../blocs/usuarios/usuarios_event.dart';
import '../../blocs/usuarios/usuarios_state.dart';
import '../../blocs/tiendas/tiendas_bloc.dart';
import '../../blocs/tiendas/tiendas_event.dart';
import '../../blocs/tiendas/tiendas_state.dart';
import '../../blocs/almacenes/almacenes_bloc.dart';
import '../../blocs/almacenes/almacenes_event.dart';
import '../../blocs/almacenes/almacenes_state.dart';

class EmpleadosPage extends StatefulWidget {
  const EmpleadosPage({super.key});

  @override
  State<EmpleadosPage> createState() => _EmpleadosPageState();
}

class _EmpleadosPageState extends State<EmpleadosPage> {
  String? _filtroRol;

  @override
  void initState() {
    super.initState();
    context.read<UsuariosBloc>().add(const LoadUsuarios());
    // Cargar tiendas y almacenes para mostrar nombres
    context.read<TiendasBloc>().add(const LoadTiendas());
    context.read<AlmacenesBloc>().add(const LoadAlmacenes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
        ],
      ),
      body: BlocConsumer<UsuariosBloc, UsuariosState>(
        listener: (context, state) {
          if (state is UsuarioCreated) {
            // Cerrar loading dialog si está abierto (solo cierra 1 nivel)
            if (Navigator.canPop(context)) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario creado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is UsuarioUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario actualizado'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is UsuarioDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario eliminado'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is UsuariosError) {
            // Cerrar loading dialog si está abierto y el error es de creación
            if (state.message.contains('crear usuario') &&
                Navigator.canPop(context)) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UsuariosLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UsuariosLoaded) {
            final usuarios = state.usuarios;

            if (usuarios.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay empleados',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Los empleados se crean mediante registro',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            // Obtener nombres de tiendas y almacenes
            return BlocBuilder<TiendasBloc, TiendasState>(
              builder: (context, tiendasState) {
                return BlocBuilder<AlmacenesBloc, AlmacenesState>(
                  builder: (context, almacenesState) {
                    // Crear mapas de ID -> Nombre
                    final Map<String, String> tiendaNombres = {};
                    final Map<String, String> almacenNombres = {};

                    if (tiendasState is TiendasLoaded) {
                      for (final tienda in tiendasState.tiendas) {
                        tiendaNombres[tienda.id] = tienda.nombre;
                      }
                    }

                    if (almacenesState is AlmacenesLoaded) {
                      for (final almacen in almacenesState.almacenes) {
                        almacenNombres[almacen.id] = almacen.nombre;
                      }
                    }

                    return Column(
                      children: [
                        // Estadísticas por rol
                        if (state.conteoPorRol.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                _buildRolChip(
                                  'Admin',
                                  state.conteoPorRol['admin'] ?? 0,
                                  Colors.purple,
                                ),
                                const SizedBox(width: 8),
                                _buildRolChip(
                                  'Vendedor',
                                  state.conteoPorRol['vendedor'] ?? 0,
                                  AppTheme.successColor,
                                ),
                                const SizedBox(width: 8),
                                _buildRolChip(
                                  'Enc. Tienda',
                                  state.conteoPorRol['encargado_tienda'] ?? 0,
                                  Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                _buildRolChip(
                                  'Enc. Almacén',
                                  state.conteoPorRol['encargado_almacen'] ?? 0,
                                  Colors.blue,
                                ),
                              ],
                            ),
                          ),

                        // Lista de usuarios
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: usuarios.length,
                            itemBuilder: (context, index) {
                              final usuario = usuarios[index];
                              return _buildUsuarioCard(
                                context,
                                usuario,
                                tiendaNombres: tiendaNombres,
                                almacenNombres: almacenNombres,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          }

          // Estado inicial o desconocido
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioEmpleado(context, null),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildRolChip(String label, int count, Color color) {
    final isSelected =
        _filtroRol == null ||
        label.toLowerCase().contains(_filtroRol!.toLowerCase());

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            if (_filtroRol == label.toLowerCase()) {
              _filtroRol = null;
              context.read<UsuariosBloc>().add(const LoadUsuarios());
            } else {
              _filtroRol = label.toLowerCase();
              String rolFilter = label;
              if (label == 'Enc. Tienda') rolFilter = 'encargado_tienda';
              if (label == 'Enc. Almacén') rolFilter = 'encargado_almacen';
              context.read<UsuariosBloc>().add(
                LoadUsuariosByRol(rolFilter.toLowerCase()),
              );
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey[600],
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? color : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsuarioCard(
    BuildContext context,
    Usuario usuario, {
    Map<String, String>? tiendaNombres,
    Map<String, String>? almacenNombres,
  }) {
    final activo = usuario.activo;
    final rol = usuario.rol;

    Color rolColor;
    String rolLabel;
    switch (rol) {
      case 'admin':
        rolColor = Colors.purple;
        rolLabel = 'ADMIN';
        break;
      case 'vendedor':
        rolColor = AppTheme.successColor;
        rolLabel = 'VENDEDOR';
        break;
      case 'encargado_tienda':
        rolColor = Colors.orange;
        rolLabel = 'ENC. TIENDA';
        break;
      case 'encargado_almacen':
        rolColor = Colors.blue;
        rolLabel = 'ENC. ALMACÉN';
        break;
      default:
        rolColor = Colors.grey;
        rolLabel = rol.toUpperCase();
    }

    // Obtener nombres de tienda y almacén
    final tiendaNombre = usuario.tiendaId != null
        ? (tiendaNombres?[usuario.tiendaId] ?? 'Cargando...')
        : null;
    final almacenNombre = usuario.almacenId != null
        ? (almacenNombres?[usuario.almacenId] ?? 'Cargando...')
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Text(
                '${usuario.nombre[0]}${usuario.apellido[0]}',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!activo)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${usuario.nombre} ${usuario.apellido}',
                style: TextStyle(
                  color: activo ? null : Colors.grey,
                  decoration: activo ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: rolColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rolLabel,
                style: TextStyle(
                  color: rolColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
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
                const Icon(Icons.email, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    usuario.email,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (tiendaNombre != null)
              Row(
                children: [
                  const Icon(Icons.store, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Tienda: $tiendaNombre',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (almacenNombre != null)
              Row(
                children: [
                  const Icon(Icons.warehouse, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Almacén: $almacenNombre',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(
              value: 'estado',
              child: Text(activo ? 'Desactivar' : 'Activar'),
            ),
            const PopupMenuItem(
              value: 'eliminar',
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (value) {
            if (value == 'editar') {
              _mostrarFormularioEmpleado(context, usuario);
            } else if (value == 'estado') {
              context.read<UsuariosBloc>().add(
                ToggleUsuarioActivo(usuario.id, !activo),
              );
            } else if (value == 'eliminar') {
              _confirmarEliminar(context, usuario);
            }
          },
        ),
      ),
    );
  }

  void _mostrarFiltros(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Rol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              leading: Radio<String?>(
                value: null,
                groupValue: _filtroRol,
                onChanged: (value) {
                  setState(() => _filtroRol = value);
                  context.read<UsuariosBloc>().add(const LoadUsuarios());
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Administrador'),
              leading: Radio<String?>(
                value: 'admin',
                groupValue: _filtroRol,
                onChanged: (value) {
                  setState(() => _filtroRol = value);
                  context.read<UsuariosBloc>().add(LoadUsuariosByRol(value!));
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Vendedor'),
              leading: Radio<String?>(
                value: 'vendedor',
                groupValue: _filtroRol,
                onChanged: (value) {
                  setState(() => _filtroRol = value);
                  context.read<UsuariosBloc>().add(LoadUsuariosByRol(value!));
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Encargado Tienda'),
              leading: Radio<String?>(
                value: 'encargado_tienda',
                groupValue: _filtroRol,
                onChanged: (value) {
                  setState(() => _filtroRol = value);
                  context.read<UsuariosBloc>().add(LoadUsuariosByRol(value!));
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Encargado Almacén'),
              leading: Radio<String?>(
                value: 'encargado_almacen',
                groupValue: _filtroRol,
                onChanged: (value) {
                  setState(() => _filtroRol = value);
                  context.read<UsuariosBloc>().add(LoadUsuariosByRol(value!));
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro de eliminar a ${usuario.nombre} ${usuario.apellido}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UsuariosBloc>().add(DeleteUsuario(usuario.id));
              Navigator.pop(context);
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

  void _mostrarFormularioEmpleado(BuildContext context, Usuario? usuario) {
    final esEdicion = usuario != null;
    final nombreController = TextEditingController(text: usuario?.nombre ?? '');
    final apellidoController = TextEditingController(
      text: usuario?.apellido ?? '',
    );
    final emailController = TextEditingController(text: usuario?.email ?? '');
    final passwordController = TextEditingController();
    String? rolSeleccionado = usuario?.rol;
    String? tiendaSeleccionada = usuario?.tiendaId;
    String? almacenSeleccionado = usuario?.almacenId;

    // Cargar tiendas y almacenes
    context.read<TiendasBloc>().add(const LoadTiendas());
    context.read<AlmacenesBloc>().add(const LoadAlmacenes());

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(esEdicion ? 'Editar Empleado' : 'Nuevo Empleado'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre *'),
                  enabled: !esEdicion,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: apellidoController,
                  decoration: const InputDecoration(labelText: 'Apellido *'),
                  enabled: !esEdicion,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !esEdicion,
                ),
                const SizedBox(height: 16),
                if (!esEdicion)
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña *',
                      helperText: 'Mínimo 6 caracteres',
                    ),
                    obscureText: true,
                  ),
                if (!esEdicion) const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Rol *'),
                  value: rolSeleccionado,
                  items: const [
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrador'),
                    ),
                    DropdownMenuItem(
                      value: 'vendedor',
                      child: Text('Vendedor'),
                    ),
                    DropdownMenuItem(
                      value: 'encargado_tienda',
                      child: Text('Encargado de Tienda'),
                    ),
                    DropdownMenuItem(
                      value: 'encargado_almacen',
                      child: Text('Encargado de Almacén'),
                    ),
                  ],
                  onChanged: (v) => setDialogState(() => rolSeleccionado = v),
                ),
                const SizedBox(height: 16),
                // Dropdown de Tiendas con BlocBuilder
                BlocBuilder<TiendasBloc, TiendasState>(
                  builder: (context, state) {
                    if (state is TiendasLoaded) {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Tienda'),
                        value: tiendaSeleccionada,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Ninguna'),
                          ),
                          ...state.tiendas.map(
                            (tienda) => DropdownMenuItem(
                              value: tienda.id,
                              child: Text(tienda.nombre),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setDialogState(() => tiendaSeleccionada = v),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Tienda'),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Cargando...'),
                        ),
                      ],
                      onChanged: null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown de Almacenes con BlocBuilder
                BlocBuilder<AlmacenesBloc, AlmacenesState>(
                  builder: (context, state) {
                    if (state is AlmacenesLoaded) {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Almacén'),
                        value: almacenSeleccionado,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Ninguno'),
                          ),
                          ...state.almacenes.map(
                            (almacen) => DropdownMenuItem(
                              value: almacen.id,
                              child: Text(almacen.nombre),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setDialogState(() => almacenSeleccionado = v),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Almacén'),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Cargando...'),
                        ),
                      ],
                      onChanged: null,
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
              onPressed: () async {
                if (esEdicion) {
                  // Actualizar usuario existente
                  context.read<UsuariosBloc>().add(
                    UpdateUsuario(
                      id: usuario.id,
                      nombre: nombreController.text.isNotEmpty
                          ? nombreController.text
                          : null,
                      apellido: apellidoController.text.isNotEmpty
                          ? apellidoController.text
                          : null,
                      rol: rolSeleccionado,
                      tiendaId: tiendaSeleccionada,
                      almacenId: almacenSeleccionado,
                    ),
                  );
                  Navigator.pop(dialogContext);
                } else {
                  // Crear nuevo usuario con Supabase Auth
                  if (nombreController.text.isEmpty ||
                      apellidoController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      rolSeleccionado == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor complete todos los campos obligatorios',
                        ),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                    return;
                  }

                  if (passwordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La contraseña debe tener al menos 6 caracteres',
                        ),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);

                  // Guardar referencias antes de async gaps
                  final authRepo = getIt<AuthRepository>();
                  final bloc = context.read<UsuariosBloc>();
                  final navigator = Navigator.of(context, rootNavigator: true);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  // Mostrar loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (loadingContext) => PopScope(
                      canPop: false,
                      child: const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Creando usuario...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );

                  try {
                    // Agregar timeout de 30 segundos
                    final result = await authRepo
                        .signUp(
                          email: emailController.text.trim(),
                          password: passwordController.text,
                          nombre: nombreController.text.trim(),
                          apellido: apellidoController.text.trim(),
                          rol: rolSeleccionado!,
                        )
                        .timeout(
                          const Duration(seconds: 30),
                          onTimeout: () {
                            throw Exception(
                              'Timeout: La operación tardó demasiado. Verifica tu conexión.',
                            );
                          },
                        );

                    result.fold(
                      (failure) {
                        // Error al crear usuario en Auth - cerrar loading
                        navigator.pop();

                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Error: ${failure.message}'),
                            backgroundColor: AppTheme.errorColor,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      },
                      (user) {
                        // Usuario creado en Auth, ahora crear en tabla usuarios
                        // Enviar evento al BLoC
                        bloc.add(
                          CreateUsuario(
                            id: user.id,
                            email: emailController.text.trim(),
                            nombre: nombreController.text.trim(),
                            apellido: apellidoController.text.trim(),
                            rol: rolSeleccionado!,
                            tiendaId: tiendaSeleccionada,
                            almacenId: almacenSeleccionado,
                          ),
                        );

                        // El BlocListener (línea 38-72) se encargará de:
                        // 1. Cerrar el loading dialog
                        // 2. Mostrar SnackBar de éxito/error
                        // 3. La lista se actualizará automáticamente con UsuariosLoaded
                      },
                    );
                  } catch (e) {
                    // Cerrar loading si hay error
                    navigator.pop();

                    String errorMessage = e.toString();
                    if (errorMessage.contains('Timeout')) {
                      errorMessage =
                          'La operación tardó demasiado. Verifica tu conexión a internet.';
                    } else if (errorMessage.contains('Exception:')) {
                      errorMessage = errorMessage
                          .replaceAll('Exception:', '')
                          .trim();
                    }

                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: AppTheme.errorColor,
                        duration: const Duration(seconds: 5),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
