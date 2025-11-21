/// Constantes de la aplicación
class AppConstants {
  // App Info
  static const String appName = 'LibroStock';
  static const String appVersion = '1.0.0';

  // Sync
  static const int syncIntervalMinutes = 5;
  static const int maxRetryAttempts = 3;

  // Pagination
  static const int defaultPageSize = 20;

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleEncargadoTienda = 'encargado_tienda';
  static const String roleEncargadoAlmacen = 'encargado_almacen';
  static const String roleVendedor = 'vendedor';

  // Tipos de movimiento
  static const String movimientoEntrada = 'entrada';
  static const String movimientoSalida = 'salida';
  static const String movimientoTransferencia = 'transferencia';
  static const String movimientoAjuste = 'ajuste';

  // Estados de sincronización
  static const String syncPendiente = 'pendiente';
  static const String syncEnviado = 'enviado';
  static const String syncError = 'error';

  // Tipos de ubicación
  static const String ubicacionTienda = 'tienda';
  static const String ubicacionAlmacen = 'almacen';
}
