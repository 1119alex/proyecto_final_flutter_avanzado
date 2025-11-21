import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class VentasPage extends StatelessWidget {
  const VentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Resumen del día
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Ventas Hoy', '15', Colors.white),
                _buildStat('Total', 'Bs. 2,450.00', Colors.white),
              ],
            ),
          ),
          // Lista de ventas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.receipt, color: AppTheme.successColor),
                    ),
                    title: Text('Venta #${1000 + index}'),
                    subtitle: Text('Cliente ${index + 1} - ${DateTime.now().toString().substring(0, 16)}'),
                    trailing: Text(
                      'Bs. ${(index + 1) * 50}.00',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successColor),
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ventas/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Venta'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.8))),
      ],
    );
  }
}
