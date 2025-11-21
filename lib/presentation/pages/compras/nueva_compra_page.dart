import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NuevaCompraPage extends StatefulWidget {
  const NuevaCompraPage({super.key});

  @override
  State<NuevaCompraPage> createState() => _NuevaCompraPageState();
}

class _NuevaCompraPageState extends State<NuevaCompraPage> {
  final List<Map<String, dynamic>> _items = [];
  String? _selectedProveedor;
  String? _selectedAlmacen;

  double get _total => _items.fold(0, (sum, item) => sum + (item['subtotal'] as double));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Compra'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedProveedor,
                  decoration: const InputDecoration(labelText: 'Proveedor *', prefixIcon: Icon(Icons.local_shipping)),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('Editorial Nacional')),
                    DropdownMenuItem(value: '2', child: Text('Distribuidora Escolar')),
                  ],
                  onChanged: (v) => setState(() => _selectedProveedor = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedAlmacen,
                  decoration: const InputDecoration(labelText: 'Almacén destino *', prefixIcon: Icon(Icons.warehouse)),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('Almacén Principal')),
                    DropdownMenuItem(value: '2', child: Text('Almacén Secundario')),
                  ],
                  onChanged: (v) => setState(() => _selectedAlmacen = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('Agrega productos a la compra'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item['nombre']),
                        subtitle: Text('${item['cantidad']} x Bs. ${item['precio']}'),
                        trailing: Text('Bs. ${item['subtotal'].toStringAsFixed(2)}'),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Bs. ${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    onPressed: _items.isEmpty ? null : () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compra registrada'), backgroundColor: Colors.purple));
                      context.pop();
                    },
                    child: const Text('Registrar Compra'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          setState(() {
            _items.add({'nombre': 'Producto ${_items.length + 1}', 'cantidad': 10, 'precio': 15.0, 'subtotal': 150.0});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
