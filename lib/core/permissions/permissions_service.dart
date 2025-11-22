/// Servicio para gestionar permisos basados en roles
class PermissionsService {
  /// Roles disponibles en el sistema
  static const String admin = 'admin';
  static const String encargadoTienda = 'encargado_tienda';
  static const String encargadoAlmacen = 'encargado_almacen';
  static const String vendedor = 'vendedor';

  /// Módulos disponibles en el sistema
  static const String productos = 'productos';
  static const String categorias = 'categorias';
  static const String ventas = 'ventas';
  static const String compras = 'compras';
  static const String inventario = 'inventario';
  static const String transferencias = 'transferencias';
  static const String tiendas = 'tiendas';
  static const String almacenes = 'almacenes';
  static const String empleados = 'empleados';
  static const String clientes = 'clientes';
  static const String proveedores = 'proveedores';
  static const String reportes = 'reportes';

  /// Verificar si un rol tiene acceso a un módulo
  static bool canAccess(String rol, String modulo) {
    switch (rol) {
      case admin:
        return true; // Admin tiene acceso a TODO

      case encargadoTienda:
        return [
          productos,
          categorias,
          ventas,
          inventario,
          transferencias,
          clientes,
          reportes,
        ].contains(modulo);

      case encargadoAlmacen:
        return [
          productos,
          categorias,
          compras,
          inventario,
          transferencias,
          proveedores,
          reportes,
        ].contains(modulo);

      case vendedor:
        return [productos, ventas, clientes].contains(modulo);

      default:
        return false;
    }
  }

  /// Verificar si un rol puede crear/editar/eliminar en un módulo
  static bool canWrite(String rol, String modulo) {
    switch (rol) {
      case admin:
        return true; // Admin puede hacer TODO

      case encargadoTienda:
        return [
          productos,
          categorias,
          ventas,
          inventario,
          transferencias,
          clientes,
        ].contains(modulo);

      case encargadoAlmacen:
        return [
          productos,
          categorias,
          compras,
          inventario,
          transferencias,
          proveedores,
        ].contains(modulo);

      case vendedor:
        return [ventas, clientes].contains(modulo);

      default:
        return false;
    }
  }

  /// Verificar si un rol puede ver reportes
  static bool canViewReports(String rol) {
    return [admin, encargadoTienda, encargadoAlmacen].contains(rol);
  }

  /// Verificar si un rol puede gestionar usuarios
  static bool canManageUsers(String rol) {
    return rol == admin;
  }

  /// Verificar si un rol puede gestionar tiendas/almacenes
  static bool canManageLocations(String rol) {
    return rol == admin;
  }

  /// Obtener descripción del rol
  static String getRoleName(String rol) {
    switch (rol) {
      case admin:
        return 'Administrador';
      case encargadoTienda:
        return 'Encargado de Tienda';
      case encargadoAlmacen:
        return 'Encargado de Almacén';
      case vendedor:
        return 'Vendedor';
      default:
        return 'Desconocido';
    }
  }

  /// Obtener lista de permisos de un rol
  static String getPermissionsDescription(String rol) {
    switch (rol) {
      case admin:
        return 'Acceso total a todas las funcionalidades del sistema';
      case encargadoTienda:
        return 'Gestión de productos, ventas, inventario y clientes de su tienda';
      case encargadoAlmacen:
        return 'Gestión de productos, compras, inventario y proveedores de su almacén';
      case vendedor:
        return 'Registro de ventas y gestión de clientes';
      default:
        return '';
    }
  }
}
