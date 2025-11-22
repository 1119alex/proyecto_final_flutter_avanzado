# Sistema de Permisos por Roles - LibroStock

## Resumen del Sistema

LibroStock implementa un sistema de control de acceso basado en roles (RBAC - Role-Based Access Control). Cada usuario tiene asignado un rol que determina qué módulos puede ver y qué acciones puede realizar.

## Roles Disponibles

### 1. **Administrador** (`admin`)
**Descripción**: Acceso total a todas las funcionalidades del sistema.

**Permisos**:
- ✅ Ver y gestionar **TODOS** los módulos
- ✅ Crear, editar y eliminar en todos los módulos
- ✅ Gestionar empleados (crear, editar, desactivar)
- ✅ Gestionar tiendas y almacenes
- ✅ Ver datos de todas las tiendas y almacenes
- ✅ Ver todos los reportes y estadísticas

**Módulos disponibles**:
- Productos
- Categorías
- Ventas
- Compras
- Inventario
- Transferencias
- Tiendas
- Almacenes
- Empleados
- Clientes
- Proveedores
- Reportes

---

### 2. **Encargado de Tienda** (`encargado_tienda`)
**Descripción**: Gestión de productos, ventas, inventario y clientes de su tienda asignada.

**Permisos**:
- ✅ Ver y gestionar productos y categorías
- ✅ Registrar y gestionar ventas (solo de su tienda)
- ✅ Ver y gestionar inventario (solo de su tienda)
- ✅ Realizar transferencias (solo desde/hacia su tienda)
- ✅ Gestionar clientes
- ✅ Ver reportes (filtrados por su tienda)
- ❌ NO puede ver compras, proveedores, empleados
- ❌ NO puede gestionar tiendas ni almacenes

**Módulos disponibles**:
- Productos (lectura y escritura)
- Categorías (lectura y escritura)
- Ventas (lectura y escritura - solo su tienda)
- Inventario (lectura y escritura - solo su tienda)
- Transferencias (lectura y escritura - solo su tienda)
- Clientes (lectura y escritura)
- Reportes (solo visualización - filtrado por su tienda)

**Restricciones**:
- Solo ve ventas de su tienda asignada
- Solo ve inventario de su tienda
- Solo puede hacer transferencias desde/hacia su tienda

---

### 3. **Encargado de Almacén** (`encargado_almacen`)
**Descripción**: Gestión de productos, compras, inventario y proveedores de su almacén asignado.

**Permisos**:
- ✅ Ver y gestionar productos y categorías
- ✅ Registrar y gestionar compras (solo de su almacén)
- ✅ Ver y gestionar inventario (solo de su almacén)
- ✅ Realizar transferencias (solo desde/hacia su almacén)
- ✅ Gestionar proveedores
- ✅ Ver reportes (filtrados por su almacén)
- ❌ NO puede ver ventas, clientes, empleados
- ❌ NO puede gestionar tiendas ni almacenes

**Módulos disponibles**:
- Productos (lectura y escritura)
- Categorías (lectura y escritura)
- Compras (lectura y escritura - solo su almacén)
- Inventario (lectura y escritura - solo su almacén)
- Transferencias (lectura y escritura - solo su almacén)
- Proveedores (lectura y escritura)
- Reportes (solo visualización - filtrado por su almacén)

**Restricciones**:
- Solo ve compras de su almacén asignado
- Solo ve inventario de su almacén
- Solo puede hacer transferencias desde/hacia su almacén

---

### 4. **Vendedor** (`vendedor`)
**Descripción**: Registro de ventas y gestión de clientes. Acceso más limitado.

**Permisos**:
- ✅ Ver productos (solo lectura)
- ✅ Registrar ventas (solo crear)
- ✅ Gestionar clientes
- ❌ NO puede editar productos
- ❌ NO puede ver compras, inventario, transferencias
- ❌ NO puede ver reportes
- ❌ NO puede gestionar empleados, tiendas, almacenes

**Módulos disponibles**:
- Productos (SOLO lectura - para consultar al vender)
- Ventas (lectura y escritura - solo crear ventas)
- Clientes (lectura y escritura)

**Restricciones**:
- No puede modificar productos ni precios
- Solo puede crear nuevas ventas
- No tiene acceso a reportes ni estadísticas

---

## Implementación Técnica

### Archivos Clave

1. **`lib/core/permissions/permissions_service.dart`**
   - Define los roles y módulos
   - Métodos `canAccess()` y `canWrite()` para verificar permisos
   - Centraliza toda la lógica de permisos

2. **`lib/presentation/pages/dashboard/dashboard_page.dart`**
   - Filtra opciones del menú según el rol del usuario
   - Obtiene el rol desde `AuthBloc.state.userData['rol']`

### Uso del Servicio de Permisos

```dart
// Verificar si el usuario puede acceder a un módulo
if (PermissionsService.canAccess(userRole, PermissionsService.ventas)) {
  // Mostrar módulo de ventas
}

// Verificar si el usuario puede crear/editar/eliminar
if (PermissionsService.canWrite(userRole, PermissionsService.productos)) {
  // Mostrar botones de edición
}

// Verificar permisos específicos
if (PermissionsService.canManageUsers(userRole)) {
  // Mostrar gestión de empleados
}
```

---

## Flujo de Autenticación y Permisos

1. Usuario inicia sesión
2. `AuthBloc` obtiene datos del usuario de Supabase (incluyendo `rol`, `tienda_id`, `almacen_id`)
3. `AuthState` guarda el rol en `userData['rol']`
4. El dashboard lee el rol y filtra las opciones del menú
5. Cada página puede verificar permisos adicionales usando `PermissionsService`

---

## Datos de Usuario en AuthState

Cuando un usuario se autentica, el `AuthState` contiene:

```dart
AuthAuthenticated(
  user: User, // Usuario de Supabase Auth
  userData: {
    'id': 'uuid',
    'email': 'usuario@example.com',
    'nombre': 'Juan',
    'apellido': 'Pérez',
    'rol': 'vendedor',           // ← ROL DEL USUARIO
    'tienda_id': 'uuid-tienda',   // ← Para filtrar datos
    'almacen_id': null,
    'activo': true,
  }
)
```

---

## Próximas Mejoras Sugeridas

### 1. Protección de Rutas
Actualmente el dashboard oculta opciones, pero un usuario podría navegar directamente a una ruta escribiendo la URL. Se recomienda:
- Agregar guards en el router para verificar permisos antes de navegar
- Redirigir a una página de "Acceso Denegado" si no tiene permisos

### 2. Filtrado de Datos por Ubicación
Implementar filtros automáticos en los repositorios:
- Ventas: filtrar por `tienda_id` del usuario
- Compras: filtrar por `almacen_id` del usuario
- Inventario: filtrar por ubicación del usuario

### 3. Botones Contextuales
Ocultar/deshabilitar botones de edición según permisos:
```dart
if (PermissionsService.canWrite(userRole, PermissionsService.productos)) {
  // Mostrar botones de Editar/Eliminar
}
```

### 4. Auditoría
Registrar quién realiza cada acción:
- Al crear/editar/eliminar, guardar el `usuario_id`
- Permite rastrear cambios y responsabilidades

---

## Ejemplo de Uso en una Página

```dart
class ProductosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userRole = (authState as AuthAuthenticated).userData?['rol'];

    return Scaffold(
      appBar: AppBar(title: Text('Productos')),
      body: ProductosList(),
      floatingActionButton: PermissionsService.canWrite(userRole, PermissionsService.productos)
        ? FloatingActionButton(
            onPressed: () => context.push('/productos/nuevo'),
            child: Icon(Icons.add),
          )
        : null, // No mostrar botón si no puede crear
    );
  }
}
```

---

## Tabla de Resumen de Permisos

| Módulo         | Admin | Enc. Tienda | Enc. Almacén | Vendedor |
|----------------|-------|-------------|--------------|----------|
| Productos      | ✅ RW  | ✅ RW       | ✅ RW        | ✅ R     |
| Categorías     | ✅ RW  | ✅ RW       | ✅ RW        | ❌       |
| Ventas         | ✅ RW  | ✅ RW       | ❌           | ✅ W     |
| Compras        | ✅ RW  | ❌          | ✅ RW        | ❌       |
| Inventario     | ✅ RW  | ✅ RW       | ✅ RW        | ❌       |
| Transferencias | ✅ RW  | ✅ RW       | ✅ RW        | ❌       |
| Tiendas        | ✅ RW  | ❌          | ❌           | ❌       |
| Almacenes      | ✅ RW  | ❌          | ❌           | ❌       |
| Empleados      | ✅ RW  | ❌          | ❌           | ❌       |
| Clientes       | ✅ RW  | ✅ RW       | ❌           | ✅ RW    |
| Proveedores    | ✅ RW  | ❌          | ✅ RW        | ❌       |
| Reportes       | ✅ R   | ✅ R        | ✅ R         | ❌       |

**Leyenda**:
- ✅ RW = Puede ver, crear, editar y eliminar
- ✅ R = Solo puede ver (lectura)
- ✅ W = Solo puede crear (escritura limitada)
- ❌ = Sin acceso

---

## Notas de Seguridad

⚠️ **IMPORTANTE**:
- Los permisos del frontend (ocultar botones/menús) son solo para UX
- **SIEMPRE** debes validar permisos en el backend (Supabase RLS)
- Row Level Security (RLS) en Supabase debe replicar estas reglas
- No confíes solo en la validación del frontend

---

Generado automáticamente por LibroStock
Última actualización: 2025-11-22
