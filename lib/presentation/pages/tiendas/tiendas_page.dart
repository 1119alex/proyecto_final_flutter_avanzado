import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TiendasPage extends StatelessWidget {
  const TiendasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiendas = [
      {
        'nombre': 'Sucursal Central',
        'direccion': 'Av. Principal #123',
        'telefono': '(2) 2123456',
        'activa': true,
        'ventas_mes': 15600.0,
      },
      {
        'nombre': 'Sucursal Norte',
        'direccion': 'Calle Comercio #456',
        'telefono': '(2) 2654321',
        'activa': true,
        'ventas_mes': 12300.0,
      },
      {
        'nombre': 'Sucursal Sur',
        'direccion': 'Av. Los Pinos #789',
        'telefono': '(2) 2987654',
        'activa': false,
        'ventas_mes': 0.0,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiendas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tiendas.length,
        itemBuilder: (context, index) {
          final tienda = tiendas[index];
          final activa = tienda['activa'] as bool;

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
                      Text(tienda['nombre'] as String),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: activa ? AppTheme.successColor : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activa ? 'Activa' : 'Inactiva',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
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
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(tienda['direccion'] as String),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(tienda['telefono'] as String),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'editar', child: Text('Editar')),
                      const PopupMenuItem(value: 'ver', child: Text('Ver detalles')),
                      PopupMenuItem(
                        value: 'estado',
                        child: Text(activa ? 'Desactivar' : 'Activar'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'editar') {
                        _mostrarFormularioTienda(context, tienda);
                      }
                    },
                  ),
                ),
                if (activa)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEstadistica('Ventas del mes', 'Bs. ${(tienda['ventas_mes'] as double).toStringAsFixed(2)}'),
                        _buildEstadistica('Empleados', '${index + 2}'),
                        _buildEstadistica('Productos', '${(index + 1) * 50}'),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioTienda(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEstadistica(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  void _mostrarFormularioTienda(BuildContext context, Map<String, dynamic>? tienda) {
    final esEdicion = tienda != null;
    final nombreController = TextEditingController(text: tienda?['nombre'] as String? ?? '');
    final direccionController = TextEditingController(text: tienda?['direccion'] as String? ?? '');
    final telefonoController = TextEditingController(text: tienda?['telefono'] as String? ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esEdicion ? 'Editar Tienda' : 'Nueva Tienda'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre *'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
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
                  content: Text(esEdicion ? 'Tienda actualizada' : 'Tienda creada'),
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
