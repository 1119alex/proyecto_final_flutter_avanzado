import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AlmacenesPage extends StatelessWidget {
  const AlmacenesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final almacenes = [
      {
        'nombre': 'Almacén Principal',
        'tienda': 'Sucursal Central',
        'capacidad': 1000,
        'ocupado': 750,
        'productos': 156,
      },
      {
        'nombre': 'Almacén Secundario',
        'tienda': 'Sucursal Central',
        'capacidad': 500,
        'ocupado': 320,
        'productos': 89,
      },
      {
        'nombre': 'Almacén Norte',
        'tienda': 'Sucursal Norte',
        'capacidad': 800,
        'ocupado': 600,
        'productos': 120,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacenes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: almacenes.length,
        itemBuilder: (context, index) {
          final almacen = almacenes[index];
          final capacidad = almacen['capacidad'] as int;
          final ocupado = almacen['ocupado'] as int;
          final porcentaje = (ocupado / capacidad * 100).round();

          Color barColor;
          if (porcentaje >= 90) {
            barColor = Colors.red;
          } else if (porcentaje >= 70) {
            barColor = Colors.orange;
          } else {
            barColor = AppTheme.successColor;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.warehouse, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                almacen['nombre'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                almacen['tienda'] as String,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'editar', child: Text('Editar')),
                          const PopupMenuItem(value: 'inventario', child: Text('Ver inventario')),
                          const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                        ],
                        onSelected: (value) {
                          if (value == 'editar') {
                            _mostrarFormularioAlmacen(context, almacen);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Barra de capacidad
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Capacidad utilizada'),
                          Text(
                            '$porcentaje%',
                            style: TextStyle(fontWeight: FontWeight.bold, color: barColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ocupado / capacidad,
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$ocupado / $capacidad unidades',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Estadísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Productos', '${almacen['productos']}', Icons.inventory_2),
                      _buildStat('Disponible', '${capacidad - ocupado}', Icons.check_circle),
                      _buildStat('Movimientos', '${(index + 1) * 12}', Icons.swap_horiz),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioAlmacen(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  void _mostrarFormularioAlmacen(BuildContext context, Map<String, dynamic>? almacen) {
    final esEdicion = almacen != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esEdicion ? 'Editar Almacén' : 'Nuevo Almacén'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nombre *'),
                controller: TextEditingController(text: almacen?['nombre'] as String? ?? ''),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tienda *'),
                value: almacen != null ? '1' : null,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Sucursal Central')),
                  DropdownMenuItem(value: '2', child: Text('Sucursal Norte')),
                ],
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Capacidad máxima'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: almacen?['capacidad']?.toString() ?? '',
                ),
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
                  content: Text(esEdicion ? 'Almacén actualizado' : 'Almacén creado'),
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
