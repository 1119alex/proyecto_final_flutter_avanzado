import 'package:flutter/material.dart';

class ProveedoresPage extends StatelessWidget {
  const ProveedoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Conectar con BLoC de proveedores
    final proveedores = <Map<String, dynamic>>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: proveedores.isEmpty
          ? Center(
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
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: proveedores.length,
              itemBuilder: (context, index) {
                final proveedor = proveedores[index];
                final activo = proveedor['activo'] as bool;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: activo
                          ? Colors.purple.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.local_shipping,
                        color: activo ? Colors.purple : Colors.grey,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            proveedor['nombre'] as String,
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
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text('${proveedor['productos']} productos'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.badge,
                              'NIT',
                              proveedor['nit'] as String,
                            ),
                            _buildInfoRow(
                              Icons.phone,
                              'Teléfono',
                              proveedor['telefono'] as String,
                            ),
                            _buildInfoRow(
                              Icons.email,
                              'Email',
                              proveedor['email'] as String,
                            ),
                            _buildInfoRow(
                              Icons.location_on,
                              'Dirección',
                              proveedor['direccion'] as String,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _mostrarFormularioProveedor(
                                    context,
                                    proveedor,
                                  ),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Editar'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.inventory, size: 18),
                                  label: const Text('Productos'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.history, size: 18),
                                  label: const Text('Compras'),
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioProveedor(context, null),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
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

  void _mostrarFormularioProveedor(
    BuildContext context,
    Map<String, dynamic>? proveedor,
  ) {
    final esEdicion = proveedor != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esEdicion ? 'Editar Proveedor' : 'Nuevo Proveedor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nombre/Razón Social *',
                ),
                controller: TextEditingController(
                  text: proveedor?['nombre'] as String? ?? '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'NIT *'),
                controller: TextEditingController(
                  text: proveedor?['nit'] as String? ?? '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                controller: TextEditingController(
                  text: proveedor?['telefono'] as String? ?? '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                controller: TextEditingController(
                  text: proveedor?['email'] as String? ?? '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Dirección'),
                controller: TextEditingController(
                  text: proveedor?['direccion'] as String? ?? '',
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    esEdicion ? 'Proveedor actualizado' : 'Proveedor creado',
                  ),
                  backgroundColor: Colors.purple,
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
