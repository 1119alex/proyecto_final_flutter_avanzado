import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TransferenciasPage extends StatelessWidget {
  const TransferenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferencias'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          final estados = ['pendiente', 'en_transito', 'completada', 'cancelada'];
          final estado = estados[index % 4];

          Color estadoColor;
          IconData estadoIcon;

          switch (estado) {
            case 'pendiente':
              estadoColor = Colors.orange;
              estadoIcon = Icons.hourglass_empty;
              break;
            case 'en_transito':
              estadoColor = Colors.blue;
              estadoIcon = Icons.local_shipping;
              break;
            case 'completada':
              estadoColor = AppTheme.successColor;
              estadoIcon = Icons.check_circle;
              break;
            case 'cancelada':
              estadoColor = Colors.red;
              estadoIcon = Icons.cancel;
              break;
            default:
              estadoColor = Colors.grey;
              estadoIcon = Icons.help;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transferencia #${3000 + index}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: estadoColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(estadoIcon, size: 16, color: estadoColor),
                            const SizedBox(width: 4),
                            Text(
                              estado.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(color: estadoColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Origen', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const Text('Almacén Principal', style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Destino', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const Text('Almacén Secundario', style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(index + 1) * 5} productos',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        DateTime.now().subtract(Duration(days: index)).toString().substring(0, 10),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarNuevaTransferencia(context),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Nueva Transferencia'),
      ),
    );
  }

  void _mostrarNuevaTransferencia(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const NuevaTransferenciaSheet(),
    );
  }
}

class NuevaTransferenciaSheet extends StatefulWidget {
  const NuevaTransferenciaSheet({super.key});

  @override
  State<NuevaTransferenciaSheet> createState() => _NuevaTransferenciaSheetState();
}

class _NuevaTransferenciaSheetState extends State<NuevaTransferenciaSheet> {
  String? _almacenOrigen;
  String? _almacenDestino;
  final List<Map<String, dynamic>> _productos = [];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nueva Transferencia',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _almacenOrigen,
              decoration: const InputDecoration(
                labelText: 'Almacén Origen *',
                prefixIcon: Icon(Icons.warehouse),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Almacén Principal')),
                DropdownMenuItem(value: '2', child: Text('Almacén Secundario')),
              ],
              onChanged: (v) => setState(() => _almacenOrigen = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _almacenDestino,
              decoration: const InputDecoration(
                labelText: 'Almacén Destino *',
                prefixIcon: Icon(Icons.warehouse_outlined),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Almacén Principal')),
                DropdownMenuItem(value: '2', child: Text('Almacén Secundario')),
              ],
              onChanged: (v) => setState(() => _almacenDestino = v),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Productos a transferir', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _productos.add({
                        'nombre': 'Producto ${_productos.length + 1}',
                        'cantidad': 10,
                      });
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            Expanded(
              child: _productos.isEmpty
                  ? const Center(child: Text('Agrega productos a transferir'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        final producto = _productos[index];
                        return ListTile(
                          title: Text(producto['nombre']),
                          subtitle: Text('Cantidad: ${producto['cantidad']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _productos.removeAt(index)),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _almacenOrigen != null &&
                           _almacenDestino != null &&
                           _almacenOrigen != _almacenDestino &&
                           _productos.isNotEmpty
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transferencia creada'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Crear Transferencia'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
