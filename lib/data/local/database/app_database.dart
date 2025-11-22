import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ==================== TABLAS ====================

/// Tabla de usuarios/empleados
class Usuarios extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get nombre => text()();
  TextColumn get apellido => text()();
  TextColumn get rol =>
      text()(); // admin, encargado_tienda, encargado_almacen, vendedor
  TextColumn get tiendaId => text().nullable().references(Tiendas, #id)();
  TextColumn get almacenId => text().nullable().references(Almacenes, #id)();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de tiendas/sucursales
class Tiendas extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get direccion => text()();
  TextColumn get telefono => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de almacenes
@DataClassName('Almacen')
class Almacenes extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get direccion => text()();
  TextColumn get telefono => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de categorías de productos
class Categorias extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get icono => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de productos
@DataClassName('Producto')
class Productos extends Table {
  TextColumn get id => text()();
  TextColumn get codigo => text().unique()();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();
  TextColumn get categoriaId => text().references(Categorias, #id)();
  RealColumn get precioCompra => real().withDefault(const Constant(0))();
  RealColumn get precioVenta => real().withDefault(const Constant(0))();
  TextColumn get unidadMedida => text().withDefault(const Constant('unidad'))();
  IntColumn get stockMinimo => integer().withDefault(const Constant(0))();
  TextColumn get imagenUrl => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de variantes de productos (ej: color, tamaño)
class ProductoVariantes extends Table {
  TextColumn get id => text()();
  TextColumn get productoId => text().references(Productos, #id)();
  TextColumn get nombre => text()(); // ej: "Tapa dura", "Azul", "A4"
  TextColumn get sku => text().unique()();
  RealColumn get precioAdicional => real().withDefault(const Constant(0))();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de inventario (stock por ubicación)
class Inventario extends Table {
  TextColumn get id => text()();
  TextColumn get productoId => text().references(Productos, #id)();
  TextColumn get varianteId =>
      text().nullable().references(ProductoVariantes, #id)();
  TextColumn get tiendaId => text().nullable().references(Tiendas, #id)();
  TextColumn get almacenId => text().nullable().references(Almacenes, #id)();
  IntColumn get cantidad => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de proveedores
@DataClassName('Proveedor')
class Proveedores extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get contacto => text().nullable()();
  TextColumn get telefono => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get direccion => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de compras (cabecera)
class Compras extends Table {
  TextColumn get id => text()();
  TextColumn get proveedorId => text().references(Proveedores, #id)();
  TextColumn get almacenId => text().references(Almacenes, #id)();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  DateTimeColumn get fecha => dateTime()();
  RealColumn get total => real().withDefault(const Constant(0))();
  TextColumn get observaciones => text().nullable()();
  TextColumn get estado => text().withDefault(const Constant('completada'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de detalle de compras
class CompraDetalles extends Table {
  TextColumn get id => text()();
  TextColumn get compraId => text().references(Compras, #id)();
  TextColumn get productoId => text().references(Productos, #id)();
  TextColumn get varianteId =>
      text().nullable().references(ProductoVariantes, #id)();
  IntColumn get cantidad => integer()();
  RealColumn get precioUnitario => real()();
  RealColumn get subtotal => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de clientes
class Clientes extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get nit => text().nullable()();
  TextColumn get telefono => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get direccion => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de ventas (cabecera)
class Ventas extends Table {
  TextColumn get id => text()();
  TextColumn get clienteId => text().nullable().references(Clientes, #id)();
  TextColumn get tiendaId => text().references(Tiendas, #id)();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  DateTimeColumn get fecha => dateTime()();
  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get descuento => real().withDefault(const Constant(0))();
  RealColumn get total => real().withDefault(const Constant(0))();
  TextColumn get metodoPago => text().withDefault(const Constant('efectivo'))();
  TextColumn get estado => text().withDefault(const Constant('completada'))();
  TextColumn get observaciones => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de detalle de ventas
class VentaDetalles extends Table {
  TextColumn get id => text()();
  TextColumn get ventaId => text().references(Ventas, #id)();
  TextColumn get productoId => text().references(Productos, #id)();
  TextColumn get varianteId =>
      text().nullable().references(ProductoVariantes, #id)();
  IntColumn get cantidad => integer()();
  RealColumn get precioUnitario => real()();
  RealColumn get descuento => real().withDefault(const Constant(0))();
  RealColumn get subtotal => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de transferencias entre ubicaciones
class Transferencias extends Table {
  TextColumn get id => text()();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  TextColumn get origenTiendaId => text().nullable().references(Tiendas, #id)();
  TextColumn get origenAlmacenId =>
      text().nullable().references(Almacenes, #id)();
  TextColumn get destinoTiendaId =>
      text().nullable().references(Tiendas, #id)();
  TextColumn get destinoAlmacenId =>
      text().nullable().references(Almacenes, #id)();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get estado => text().withDefault(
    const Constant('pendiente'),
  )(); // pendiente, en_transito, completada, cancelada
  TextColumn get observaciones => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de detalle de transferencias
class TransferenciaDetalles extends Table {
  TextColumn get id => text()();
  TextColumn get transferenciaId => text().references(Transferencias, #id)();
  TextColumn get productoId => text().references(Productos, #id)();
  TextColumn get varianteId =>
      text().nullable().references(ProductoVariantes, #id)();
  IntColumn get cantidad => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de movimientos de inventario (historial)
class MovimientosInventario extends Table {
  TextColumn get id => text()();
  TextColumn get productoId => text().references(Productos, #id)();
  TextColumn get varianteId =>
      text().nullable().references(ProductoVariantes, #id)();
  TextColumn get tiendaId => text().nullable().references(Tiendas, #id)();
  TextColumn get almacenId => text().nullable().references(Almacenes, #id)();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  TextColumn get tipoMovimiento =>
      text()(); // entrada, salida, transferencia, ajuste
  IntColumn get cantidad => integer()();
  IntColumn get stockAnterior => integer()();
  IntColumn get stockNuevo => integer()();
  TextColumn get referenciaId =>
      text().nullable()(); // ID de compra, venta o transferencia
  TextColumn get referenciaTipo =>
      text().nullable()(); // compra, venta, transferencia
  TextColumn get observaciones => text().nullable()();
  DateTimeColumn get fecha => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendiente'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cola de sincronización para operaciones offline
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetTable => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // insert, update, delete
  TextColumn get data => text()(); // JSON con los datos
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get processedAt => dateTime().nullable()();
}

// ==================== DATABASE ====================

@DriftDatabase(
  tables: [
    Usuarios,
    Tiendas,
    Almacenes,
    Categorias,
    Productos,
    ProductoVariantes,
    Inventario,
    Proveedores,
    Compras,
    CompraDetalles,
    Clientes,
    Ventas,
    VentaDetalles,
    Transferencias,
    TransferenciaDetalles,
    MovimientosInventario,
    SyncQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Método para obtener instancia singleton
  static AppDatabase? _instance;
  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'librostock.db'));
    return NativeDatabase.createInBackground(file);
  });
}
