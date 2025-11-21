import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class NuevaVentaPage extends StatefulWidget {
  const NuevaVentaPage({super.key});

  @override
  State<NuevaVentaPage> createState() => _NuevaVentaPageState();
}

class _NuevaVentaPageState extends State<NuevaVentaPage> {
  final List<Map<String, dynamic>> _items = [];
  String? _selectedCliente;
  double _descuento = 0;

  double get _subtotal => _items.fold(0, (sum, item) => sum + (item['subtotal'] as double));
  double get _total => _subtotal - _descuento;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        actions: [
          TextButton(
            onPressed: _items.isEmpty ? null : _confirmarVenta,
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Seleccionar cliente
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedCliente,
              decoration: const InputDecoration(
                labelText: 'Cliente (opcional)',
                prefixIcon: Icon(Icons.person),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Cliente General')),
                DropdownMenuItem(value: '2', child: Text('Juan Pérez')),
                DropdownMenuItem(value: '3', child: Text('María García')),
              ],
              onChanged: (value) => setState(() => _selectedCliente = value),
            ),
          ),

          // Lista de productos
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Agrega productos a la venta', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item['nombre']),
                        subtitle: Text('${item['cantidad']} x Bs. ${item['precio']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Bs. ${item['subtotal'].toStringAsFixed(2)}'),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => _items.removeAt(index)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Totales
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text('Bs. ${_subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Descuento:'),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(prefixText: 'Bs. ', isDense: true),
                        onChanged: (v) => setState(() => _descuento = double.tryParse(v) ?? 0),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Bs. ${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.successColor)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarProducto,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _agregarProducto() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(hintText: 'Buscar producto...', prefixIcon: Icon(Icons.search)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 20,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text('Producto ${index + 1}'),
                  subtitle: Text('Bs. ${(index + 1) * 10}.00'),
                  onTap: () {
                    setState(() {
                      _items.add({
                        'nombre': 'Producto ${index + 1}',
                        'cantidad': 1,
                        'precio': (index + 1) * 10.0,
                        'subtotal': (index + 1) * 10.0,
                      });
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarVenta() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Venta'),
        content: Text('Total: Bs. ${_total.toStringAsFixed(2)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venta registrada'), backgroundColor: AppTheme.successColor));
              context.pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
