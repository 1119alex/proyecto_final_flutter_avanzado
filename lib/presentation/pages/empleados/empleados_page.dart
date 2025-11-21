import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EmpleadosPage extends StatelessWidget {
  const EmpleadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Conectar con BLoC de empleados
    final empleados = <Map<String, dynamic>>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: empleados.isEmpty
          ? Center(
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
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: empleados.length,
              itemBuilder: (context, index) {
                final empleado = empleados[index];
                final activo = empleado['activo'] as bool;
                final rol = empleado['rol'] as String;

                Color rolColor;
                switch (rol) {
                  case 'admin':
                    rolColor = Colors.purple;
                    break;
                  case 'vendedor':
                    rolColor = AppTheme.successColor;
                    break;
                  case 'almacenero':
                    rolColor = Colors.orange;
                    break;
                  default:
                    rolColor = Colors.grey;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            (empleado['nombre'] as String)
                                .split(' ')
                                .map((e) => e[0])
                                .take(2)
                                .join(),
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            empleado['nombre'] as String,
                            style: TextStyle(
                              color: activo ? null : Colors.grey,
                              decoration: activo
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: rolColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            rol.toUpperCase(),
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
                            const Icon(
                              Icons.email,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              empleado['email'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.store,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              empleado['tienda'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'permisos',
                          child: Text('Permisos'),
                        ),
                        PopupMenuItem(
                          value: 'estado',
                          child: Text(activo ? 'Desactivar' : 'Activar'),
                        ),
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'editar') {
                          _mostrarFormularioEmpleado(context, empleado);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioEmpleado(context, null),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _mostrarFormularioEmpleado(
    BuildContext context,
    Map<String, dynamic>? empleado,
  ) {
    final esEdicion = empleado != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esEdicion ? 'Editar Empleado' : 'Nuevo Empleado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nombre completo *',
                ),
                controller: TextEditingController(
                  text: empleado?['nombre'] as String? ?? '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
                controller: TextEditingController(
                  text: empleado?['email'] as String? ?? '',
                ),
              ),
              const SizedBox(height: 16),
              if (!esEdicion)
                TextField(
                  decoration: const InputDecoration(labelText: 'Contraseña *'),
                  obscureText: true,
                ),
              if (!esEdicion) const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Rol *'),
                value: empleado?['rol'] as String?,
                items: const [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administrador'),
                  ),
                  DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
                  DropdownMenuItem(
                    value: 'almacenero',
                    child: Text('Almacenero'),
                  ),
                ],
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tienda *'),
                value: '1',
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Sucursal Central')),
                  DropdownMenuItem(value: '2', child: Text('Sucursal Norte')),
                ],
                onChanged: (v) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    esEdicion ? 'Empleado actualizado' : 'Empleado creado',
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
