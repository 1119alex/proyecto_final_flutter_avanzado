-- =====================================================
-- SCRIPT SQL PARA SUPABASE - SISTEMA LIBROSTOCK
-- Librería/Papelería - Sistema de Inventario Offline-First
-- =====================================================

-- Habilitar UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLAS PRINCIPALES
-- =====================================================

-- Tabla de tiendas/sucursales
CREATE TABLE IF NOT EXISTS tiendas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    direccion TEXT NOT NULL,
    telefono TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de almacenes
CREATE TABLE IF NOT EXISTS almacenes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    direccion TEXT NOT NULL,
    telefono TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de usuarios/empleados
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    apellido TEXT NOT NULL,
    rol TEXT NOT NULL CHECK (rol IN ('admin', 'encargado_tienda', 'encargado_almacen', 'vendedor')),
    tienda_id UUID REFERENCES tiendas(id) ON DELETE SET NULL,
    almacen_id UUID REFERENCES almacenes(id) ON DELETE SET NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de categorías
CREATE TABLE IF NOT EXISTS categorias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    icono TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de productos
CREATE TABLE IF NOT EXISTS productos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    categoria_id UUID REFERENCES categorias(id) ON DELETE SET NULL,
    precio_compra DECIMAL(10,2) DEFAULT 0,
    precio_venta DECIMAL(10,2) DEFAULT 0,
    unidad_medida TEXT DEFAULT 'unidad',
    stock_minimo INTEGER DEFAULT 0,
    imagen_url TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de variantes de productos
CREATE TABLE IF NOT EXISTS producto_variantes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id UUID NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    sku TEXT UNIQUE NOT NULL,
    precio_adicional DECIMAL(10,2) DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de inventario
CREATE TABLE IF NOT EXISTS inventario (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id UUID NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
    variante_id UUID REFERENCES producto_variantes(id) ON DELETE CASCADE,
    tienda_id UUID REFERENCES tiendas(id) ON DELETE CASCADE,
    almacen_id UUID REFERENCES almacenes(id) ON DELETE CASCADE,
    cantidad INTEGER DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT chk_ubicacion CHECK (
        (tienda_id IS NOT NULL AND almacen_id IS NULL) OR
        (tienda_id IS NULL AND almacen_id IS NOT NULL)
    )
);

-- Tabla de proveedores
CREATE TABLE IF NOT EXISTS proveedores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    contacto TEXT,
    telefono TEXT,
    email TEXT,
    direccion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS clientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre TEXT NOT NULL,
    nit TEXT,
    telefono TEXT,
    email TEXT,
    direccion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de compras (cabecera)
CREATE TABLE IF NOT EXISTS compras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proveedor_id UUID NOT NULL REFERENCES proveedores(id),
    almacen_id UUID NOT NULL REFERENCES almacenes(id),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    fecha TIMESTAMP WITH TIME ZONE NOT NULL,
    total DECIMAL(10,2) DEFAULT 0,
    observaciones TEXT,
    estado TEXT DEFAULT 'completada',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de detalle de compras
CREATE TABLE IF NOT EXISTS compra_detalles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    compra_id UUID NOT NULL REFERENCES compras(id) ON DELETE CASCADE,
    producto_id UUID NOT NULL REFERENCES productos(id),
    variante_id UUID REFERENCES producto_variantes(id),
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de ventas (cabecera)
CREATE TABLE IF NOT EXISTS ventas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id UUID REFERENCES clientes(id),
    tienda_id UUID NOT NULL REFERENCES tiendas(id),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    fecha TIMESTAMP WITH TIME ZONE NOT NULL,
    subtotal DECIMAL(10,2) DEFAULT 0,
    descuento DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) DEFAULT 0,
    metodo_pago TEXT DEFAULT 'efectivo',
    estado TEXT DEFAULT 'completada',
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de detalle de ventas
CREATE TABLE IF NOT EXISTS venta_detalles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venta_id UUID NOT NULL REFERENCES ventas(id) ON DELETE CASCADE,
    producto_id UUID NOT NULL REFERENCES productos(id),
    variante_id UUID REFERENCES producto_variantes(id),
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) DEFAULT 0,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de transferencias
CREATE TABLE IF NOT EXISTS transferencias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    origen_tienda_id UUID REFERENCES tiendas(id),
    origen_almacen_id UUID REFERENCES almacenes(id),
    destino_tienda_id UUID REFERENCES tiendas(id),
    destino_almacen_id UUID REFERENCES almacenes(id),
    fecha TIMESTAMP WITH TIME ZONE NOT NULL,
    estado TEXT DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'en_transito', 'completada', 'cancelada')),
    observaciones TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de detalle de transferencias
CREATE TABLE IF NOT EXISTS transferencia_detalles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transferencia_id UUID NOT NULL REFERENCES transferencias(id) ON DELETE CASCADE,
    producto_id UUID NOT NULL REFERENCES productos(id),
    variante_id UUID REFERENCES producto_variantes(id),
    cantidad INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de movimientos de inventario (historial)
CREATE TABLE IF NOT EXISTS movimientos_inventario (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id UUID NOT NULL REFERENCES productos(id),
    variante_id UUID REFERENCES producto_variantes(id),
    tienda_id UUID REFERENCES tiendas(id),
    almacen_id UUID REFERENCES almacenes(id),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    tipo_movimiento TEXT NOT NULL CHECK (tipo_movimiento IN ('entrada', 'salida', 'transferencia', 'ajuste')),
    cantidad INTEGER NOT NULL,
    stock_anterior INTEGER NOT NULL,
    stock_nuevo INTEGER NOT NULL,
    referencia_id UUID,
    referencia_tipo TEXT,
    observaciones TEXT,
    fecha TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ÍNDICES PARA MEJOR RENDIMIENTO
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_productos_codigo ON productos(codigo);
CREATE INDEX IF NOT EXISTS idx_inventario_producto ON inventario(producto_id);
CREATE INDEX IF NOT EXISTS idx_inventario_tienda ON inventario(tienda_id);
CREATE INDEX IF NOT EXISTS idx_inventario_almacen ON inventario(almacen_id);
CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON ventas(fecha);
CREATE INDEX IF NOT EXISTS idx_ventas_tienda ON ventas(tienda_id);
CREATE INDEX IF NOT EXISTS idx_compras_fecha ON compras(fecha);
CREATE INDEX IF NOT EXISTS idx_movimientos_fecha ON movimientos_inventario(fecha);
CREATE INDEX IF NOT EXISTS idx_movimientos_producto ON movimientos_inventario(producto_id);

-- =====================================================
-- FUNCIONES Y TRIGGERS
-- =====================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_tiendas_updated_at BEFORE UPDATE ON tiendas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_almacenes_updated_at BEFORE UPDATE ON almacenes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categorias_updated_at BEFORE UPDATE ON categorias FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_productos_updated_at BEFORE UPDATE ON productos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_producto_variantes_updated_at BEFORE UPDATE ON producto_variantes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_inventario_updated_at BEFORE UPDATE ON inventario FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_proveedores_updated_at BEFORE UPDATE ON proveedores FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_clientes_updated_at BEFORE UPDATE ON clientes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_compras_updated_at BEFORE UPDATE ON compras FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ventas_updated_at BEFORE UPDATE ON ventas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_transferencias_updated_at BEFORE UPDATE ON transferencias FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE tiendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE almacenes ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE producto_variantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventario ENABLE ROW LEVEL SECURITY;
ALTER TABLE proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE compra_detalles ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE venta_detalles ENABLE ROW LEVEL SECURITY;
ALTER TABLE transferencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE transferencia_detalles ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_inventario ENABLE ROW LEVEL SECURITY;

-- Políticas para usuarios autenticados (pueden ver y modificar todo)
-- En producción, se deberían crear políticas más específicas por rol

CREATE POLICY "Usuarios autenticados pueden ver tiendas" ON tiendas FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar tiendas" ON tiendas FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver almacenes" ON almacenes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar almacenes" ON almacenes FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver usuarios" ON usuarios FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar usuarios" ON usuarios FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver categorias" ON categorias FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar categorias" ON categorias FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver productos" ON productos FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar productos" ON productos FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver variantes" ON producto_variantes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar variantes" ON producto_variantes FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver inventario" ON inventario FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar inventario" ON inventario FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver proveedores" ON proveedores FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar proveedores" ON proveedores FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver clientes" ON clientes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar clientes" ON clientes FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver compras" ON compras FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar compras" ON compras FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver compra_detalles" ON compra_detalles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar compra_detalles" ON compra_detalles FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver ventas" ON ventas FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar ventas" ON ventas FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver venta_detalles" ON venta_detalles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar venta_detalles" ON venta_detalles FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver transferencias" ON transferencias FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar transferencias" ON transferencias FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver transferencia_detalles" ON transferencia_detalles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar transferencia_detalles" ON transferencia_detalles FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Usuarios autenticados pueden ver movimientos" ON movimientos_inventario FOR SELECT TO authenticated USING (true);
CREATE POLICY "Usuarios autenticados pueden modificar movimientos" ON movimientos_inventario FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- =====================================================
-- DATOS INICIALES DE PRUEBA
-- =====================================================

-- Insertar categorías de ejemplo
INSERT INTO categorias (id, nombre, descripcion, icono) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Libros', 'Libros de texto, novelas, cuentos', 'book'),
    ('22222222-2222-2222-2222-222222222222', 'Cuadernos', 'Cuadernos escolares y profesionales', 'notebook'),
    ('33333333-3333-3333-3333-333333333333', 'Útiles de Escritura', 'Lapiceros, lápices, marcadores', 'pencil'),
    ('44444444-4444-4444-4444-444444444444', 'Arte y Manualidades', 'Pinturas, pinceles, cartulinas', 'palette'),
    ('55555555-5555-5555-5555-555555555555', 'Papelería', 'Hojas, sobres, carpetas', 'folder'),
    ('66666666-6666-6666-6666-666666666666', 'Mochilas y Estuches', 'Mochilas escolares y estuches', 'backpack')
ON CONFLICT (id) DO NOTHING;

-- Insertar tiendas de ejemplo
INSERT INTO tiendas (id, nombre, direccion, telefono) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'LibroStock Central', 'Av. Principal #123, Centro', '77712345'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'LibroStock Norte', 'Calle Norte #456, Zona Norte', '77754321'),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'LibroStock Sur', 'Av. Sur #789, Zona Sur', '77798765')
ON CONFLICT (id) DO NOTHING;

-- Insertar almacenes de ejemplo
INSERT INTO almacenes (id, nombre, direccion, telefono) VALUES
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Almacén Principal', 'Zona Industrial, Galpón 1', '77711111'),
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Almacén Secundario', 'Zona Industrial, Galpón 2', '77722222')
ON CONFLICT (id) DO NOTHING;

-- Insertar proveedores de ejemplo
INSERT INTO proveedores (id, nombre, contacto, telefono, email) VALUES
    ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'Editorial Nacional', 'Juan Pérez', '77733333', 'contacto@editorial.com'),
    ('00000000-0000-0000-0000-000000000001', 'Distribuidora Escolar', 'María López', '77744444', 'ventas@distribuidora.com')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- FUNCIÓN PARA CREAR USUARIO ADMIN DESPUÉS DEL REGISTRO
-- =====================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.usuarios (id, email, nombre, apellido, rol)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'nombre', 'Usuario'),
        COALESCE(NEW.raw_user_meta_data->>'apellido', 'Nuevo'),
        COALESCE(NEW.raw_user_meta_data->>'rol', 'vendedor')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear usuario automáticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
