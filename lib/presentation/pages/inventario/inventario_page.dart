import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  String _filtroAlmacen = 'todos';
  String _filtroCategoria = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exportando inventario...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen de inventario
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResumenItem('Total Items', '156', Icons.inventory_2),
                _buildResumenItem('Bajo Stock', '12', Icons.warning),
                _buildResumenItem('Sin Stock', '3', Icons.error),
              ],
            ),
          ),
          // Filtros activos
          if (_filtroAlmacen != 'todos' || _filtroCategoria != 'todos')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Filtros: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (_filtroAlmacen != 'todos')
                    Chip(
                      label: Text('Almacén: $_filtroAlmacen'),
                      onDeleted: () => setState(() => _filtroAlmacen = 'todos'),
                    ),
                  const SizedBox(width: 8),
                  if (_filtroCategoria != 'todos')
                    Chip(
                      label: Text('Categoría: $_filtroCategoria'),
                      onDeleted: () => setState(() => _filtroCategoria = 'todos'),
                    ),
                ],
              ),
            ),
          // Lista de inventario
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 20,
              itemBuilder: (context, index) {
                final stockLevel = index % 4;
                Color stockColor;
                String stockText;

                switch (stockLevel) {
                  case 0:
                    stockColor = Colors.red;
                    stockText = 'Sin stock';
                    break;
                  case 1:
                    stockColor = Colors.orange;
                    stockText = 'Bajo';
                    break;
                  default:
                    stockColor = AppTheme.successColor;
                    stockText = 'Normal';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: stockColor.withValues(alpha: 0.1),
                      child: Icon(Icons.inventory, color: stockColor),
                    ),
                    title: Text('Producto ${index + 1}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SKU: PRD-${1000 + index}'),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: stockColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                stockText,
                                style: TextStyle(color: stockColor, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(index + 1) * 5} unid.',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Min: 10',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    onTap: () => _mostrarDetalleInventario(context, index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtrar Inventario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _filtroAlmacen,
              decoration: const InputDecoration(labelText: 'Almacén'),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'principal', child: Text('Almacén Principal')),
                DropdownMenuItem(value: 'secundario', child: Text('Almacén Secundario')),
              ],
              onChanged: (v) => setState(() => _filtroAlmacen = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _filtroCategoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todas')),
                DropdownMenuItem(value: 'libros', child: Text('Libros')),
                DropdownMenuItem(value: 'cuadernos', child: Text('Cuadernos')),
                DropdownMenuItem(value: 'utiles', child: Text('Útiles de Escritura')),
              ],
              onChanged: (v) => setState(() => _filtroCategoria = v!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aplicar Filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleInventario(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Producto ${index + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalleRow('SKU', 'PRD-${1000 + index}'),
            _buildDetalleRow('Stock actual', '${(index + 1) * 5} unidades'),
            _buildDetalleRow('Stock mínimo', '10 unidades'),
            _buildDetalleRow('Stock máximo', '100 unidades'),
            const Divider(),
            const Text('Distribución por almacén:', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildDetalleRow('Almacén Principal', '${(index + 1) * 3} unid.'),
            _buildDetalleRow('Almacén Secundario', '${(index + 1) * 2} unid.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a ajuste de inventario
            },
            child: const Text('Ajustar Stock'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
