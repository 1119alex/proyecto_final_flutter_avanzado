import 'package:flutter/material.dart';

class CategoriasPage extends StatelessWidget {
  const CategoriasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = [
      {'nombre': 'Libros', 'icon': Icons.book, 'color': Colors.blue, 'count': 45},
      {'nombre': 'Cuadernos', 'icon': Icons.menu_book, 'color': Colors.green, 'count': 32},
      {'nombre': 'Útiles de Escritura', 'icon': Icons.edit, 'color': Colors.orange, 'count': 67},
      {'nombre': 'Arte y Manualidades', 'icon': Icons.palette, 'color': Colors.purple, 'count': 28},
      {'nombre': 'Papelería', 'icon': Icons.folder, 'color': Colors.teal, 'count': 41},
      {'nombre': 'Mochilas y Estuches', 'icon': Icons.backpack, 'color': Colors.pink, 'count': 19},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final cat = categorias[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (cat['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(cat['icon'] as IconData, color: cat['color'] as Color),
              ),
              title: Text(cat['nombre'] as String),
              subtitle: Text('${cat['count']} productos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoriaDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoriaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Guardar')),
        ],
      ),
    );
  }
}
