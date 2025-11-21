import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductoFormPage extends StatefulWidget {
  final String? productoId;

  const ProductoFormPage({super.key, this.productoId});

  @override
  State<ProductoFormPage> createState() => _ProductoFormPageState();
}

class _ProductoFormPageState extends State<ProductoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockMinimoController = TextEditingController();

  String? _selectedCategoria;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.productoId != null;
    if (_isEditing) {
      _loadProducto();
    }
  }

  void _loadProducto() {
    // TODO: Cargar datos del producto
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // TODO: Guardar producto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Producto actualizado' : 'Producto creado'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Código
            TextFormField(
              controller: _codigoController,
              decoration: const InputDecoration(
                labelText: 'Código *',
                prefixIcon: Icon(Icons.qr_code),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el código del producto';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el nombre del producto';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Categoría
            DropdownButtonFormField<String>(
              value: _selectedCategoria,
              decoration: const InputDecoration(
                labelText: 'Categoría *',
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Libros')),
                DropdownMenuItem(value: '2', child: Text('Cuadernos')),
                DropdownMenuItem(value: '3', child: Text('Útiles de Escritura')),
                DropdownMenuItem(value: '4', child: Text('Arte y Manualidades')),
                DropdownMenuItem(value: '5', child: Text('Papelería')),
                DropdownMenuItem(value: '6', child: Text('Mochilas y Estuches')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoria = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Seleccione una categoría';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Precios
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioCompraController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio Compra *',
                      prefixText: 'Bs. ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _precioVentaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio Venta *',
                      prefixText: 'Bs. ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stock mínimo
            TextFormField(
              controller: _stockMinimoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock Mínimo',
                prefixIcon: Icon(Icons.inventory),
                helperText: 'Alerta cuando el stock sea menor a este valor',
              ),
            ),
            const SizedBox(height: 32),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    child: Text(_isEditing ? 'Actualizar' : 'Crear Producto'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
