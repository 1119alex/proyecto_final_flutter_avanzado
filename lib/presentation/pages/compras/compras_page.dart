import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ComprasPage extends StatelessWidget {
  const ComprasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withValues(alpha: 0.1),
                child: const Icon(Icons.shopping_cart, color: Colors.purple),
              ),
              title: Text('Compra #${2000 + index}'),
              subtitle: Text('Proveedor ${index + 1} - ${DateTime.now().toString().substring(0, 10)}'),
              trailing: Text('Bs. ${(index + 1) * 500}.00', style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/compras/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Compra'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
