import 'package:flutter_bloc/flutter_bloc.dart';
import 'productos_event.dart';
import 'productos_state.dart';
import '../../../data/repositories/productos_repository.dart';

class ProductosBloc extends Bloc<ProductosEvent, ProductosState> {
  final ProductosRepository _repository;

  ProductosBloc(this._repository) : super(const ProductosInitial()) {
    on<LoadProductos>(_onLoadProductos);
    on<LoadProductosByCategoria>(_onLoadProductosByCategoria);
    on<SearchProductos>(_onSearchProductos);
    on<CreateProducto>(_onCreateProducto);
    on<UpdateProducto>(_onUpdateProducto);
    on<DeleteProducto>(_onDeleteProducto);
    on<ToggleProductoEstado>(_onToggleProductoEstado);
  }

  Future<void> _onLoadProductos(
    LoadProductos event,
    Emitter<ProductosState> emit,
  ) async {
    try {
      emit(const ProductosLoading());
      final productos = await _repository.getAllProductos();
      emit(ProductosLoaded(productos));
    } catch (e) {
      emit(ProductosError('Error al cargar productos: ${e.toString()}'));
    }
  }

  Future<void> _onLoadProductosByCategoria(
    LoadProductosByCategoria event,
    Emitter<ProductosState> emit,
  ) async {
    try {
      emit(const ProductosLoading());
      final productos = await _repository.getProductosByCategoria(
        event.categoriaId,
      );
      emit(ProductosLoaded(productos, categoriaIdFiltro: event.categoriaId));
    } catch (e) {
      emit(ProductosError('Error al cargar productos: ${e.toString()}'));
    }
  }

  Future<void> _onSearchProductos(
    SearchProductos event,
    Emitter<ProductosState> emit,
  ) async {
    try {
      emit(const ProductosLoading());
      final productos = await _repository.searchProductos(event.query);
      emit(ProductosLoaded(productos));
    } catch (e) {
      emit(ProductosError('Error al buscar productos: ${e.toString()}'));
    }
  }

  Future<void> _onCreateProducto(
    CreateProducto event,
    Emitter<ProductosState> emit,
  ) async {
    try {
      emit(const ProductosLoading());

      // Verificar si el código ya existe
      final codigoExists = await _repository.codigoExists(event.codigo);
      if (codigoExists) {
        emit(const ProductosError('El código del producto ya existe'));
        return;
      }

      await _repository.createProducto(
        codigo: event.codigo,
        nombre: event.nombre,
        descripcion: event.descripcion,
        categoriaId: event.categoriaId,
        precioCompra: event.precioCompra,
        precioVenta: event.precioVenta,
        unidadMedida: event.unidadMedida,
        stockMinimo: event.stockMinimo,
        imagenUrl: event.imagenUrl,
      );
      emit(const ProductoCreated());
      final productos = await _repository.getAllProductos();
      emit(ProductosLoaded(productos));
    } catch (e) {
      emit(ProductosError('Error al crear producto: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProducto(
    UpdateProducto event,
    Emitter<ProductosState> emit,
  ) async {
    try {
      emit(const ProductosLoading());

      // Verificar si el código ya existe (excluyendo el producto actual)
      final codigoExists = await _repository.codigoExists(
        event.codigo,
        excludeId: event.id,
      );
      if (codigoExists) {
        emit(const ProductosError('El código del producto ya existe'));
        return;
      }

      final success = await _repository.updateProducto(
        id: event.id,
        codigo: event.codigo,
        nombre: event.nombre,
        descripcion: event.descripcion,
        categoriaId: event.categoriaId,
        precioCompra: event.precioCompra,
        precioVenta: event.precioVenta,
        unidadMedida: event.unidadMedida,
        stockMinimo: event.stockMinimo,
        imagenUrl: event.imagenUrl,
        activo: event.activo,
      );

      if (success) {
        emit(const ProductoUpdated());
        final productos = await _repository.getAllProductos();
        emit(ProductosLoaded(productos));
      } else {
        emit(const ProductosError('No se pudo actualizar el producto'));
      }
    } catch (e) {
      emit(ProductosError('Error al actualizar producto: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProducto(
    DeleteProducto event,
    Emitter<ProductosState> emit,
  ) async {
    try {
      emit(const ProductosLoading());
      await _repository.deleteProducto(event.id);
      emit(const ProductoDeleted());
      final productos = await _repository.getAllProductos();
      emit(ProductosLoaded(productos));
    } catch (e) {
      emit(ProductosError('Error al eliminar producto: ${e.toString()}'));
    }
  }

  Future<void> _onToggleProductoEstado(
    ToggleProductoEstado event,
    Emitter<ProductosState> emit,
  ) async {
    try {
      emit(const ProductosLoading());
      final success = await _repository.toggleProductoEstado(
        event.id,
        event.activo,
      );

      if (success) {
        emit(const ProductoUpdated());
        final productos = await _repository.getAllProductos();
        emit(ProductosLoaded(productos));
      } else {
        emit(const ProductosError('No se pudo cambiar el estado del producto'));
      }
    } catch (e) {
      emit(ProductosError('Error al cambiar estado: ${e.toString()}'));
    }
  }
}
