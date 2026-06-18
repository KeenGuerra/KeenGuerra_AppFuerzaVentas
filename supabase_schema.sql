-- ====================================================================
-- ESQUEMA DE BASE DE DATOS PARA SUPABASE (ecosistema Banco Andino)
-- ====================================================================

-- Limpiar tablas antiguas si existen para evitar conflictos de columnas
DROP TABLE IF EXISTS transmisiones CASCADE;
DROP TABLE IF EXISTS documentos CASCADE;
DROP TABLE IF EXISTS historial_crediticio CASCADE;
DROP TABLE IF EXISTS productos_activos CASCADE;
DROP TABLE IF EXISTS buro_credito CASCADE;
DROP TABLE IF EXISTS solicitudes_credito CASCADE;
DROP TABLE IF EXISTS cartera_diaria CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS oficiales CASCADE;

-- 1. Tabla de Oficiales de Crédito
CREATE TABLE IF NOT EXISTS oficiales (
    id VARCHAR(100) PRIMARY KEY,
    codigo_empleado VARCHAR(50) UNIQUE NOT NULL,
    clave VARCHAR(100) NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    cargo VARCHAR(50) NOT NULL DEFAULT 'OPERADOR',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabla de Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id VARCHAR(100) PRIMARY KEY, -- DNI del cliente
    oficial_id VARCHAR(100) REFERENCES oficiales(id) ON DELETE SET NULL,
    dni VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(50),
    direccion TEXT,
    negocio VARCHAR(150),
    actividad_economica VARCHAR(150),
    latitud NUMERIC(10, 6),
    longitud NUMERIC(10, 6),
    estado VARCHAR(50) DEFAULT 'ACTIVO'
);

-- 3. Tabla de Cartera Diaria
CREATE TABLE IF NOT EXISTS cartera_diaria (
    id VARCHAR(100) PRIMARY KEY,
    oficial_id VARCHAR(100) REFERENCES oficiales(id) ON DELETE CASCADE,
    cliente_id VARCHAR(100) REFERENCES clientes(id) ON DELETE CASCADE,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    tipo_gestion VARCHAR(50) NOT NULL, -- NUEVA_SOLICITUD, Cobranza, Renovación
    estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente', -- Pendiente, Visitado, Reprogramado
    prioridad INTEGER NOT NULL DEFAULT 1, -- 1=Baja, 2=Media, 3=Alta
    observacion TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Tabla de Solicitudes de Crédito
CREATE TABLE IF NOT EXISTS solicitudes_credito (
    id VARCHAR(100) PRIMARY KEY,
    oficial_id VARCHAR(100) REFERENCES oficiales(id) ON DELETE SET NULL,
    cliente_id VARCHAR(100) REFERENCES clientes(id) ON DELETE CASCADE,
    monto_solicitado NUMERIC(12, 2) NOT NULL,
    plazo_meses INTEGER NOT NULL,
    destino_credito TEXT NOT NULL,
    garantia VARCHAR(100) DEFAULT 'sin garantia',
    seguro_desgravamen BOOLEAN DEFAULT FALSE,
    tea NUMERIC(5, 2) NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'enviado', -- borrador, enviado, recibido_comite, en_evaluacion, aprobado, condicionado, rechazado, desembolsado
    sync_status VARCHAR(50) DEFAULT 'SINCRONIZADO',
    monto_aprobado NUMERIC(12, 2),
    motivo_rechazo TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Tabla de Buró de Crédito
CREATE TABLE IF NOT EXISTS buro_credito (
    id VARCHAR(100) PRIMARY KEY,
    cliente_id VARCHAR(100) REFERENCES clientes(id) ON DELETE CASCADE,
    oficial_id VARCHAR(100) REFERENCES oficiales(id) ON DELETE SET NULL,
    score INTEGER NOT NULL,
    resultado VARCHAR(100) NOT NULL, -- APTO, RECHAZADO, CON CONDICIONES
    fuente VARCHAR(50) DEFAULT 'SIMULADO',
    payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Tabla de Productos Activos (Saldos Vigentes)
CREATE TABLE IF NOT EXISTS productos_activos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id VARCHAR(100) REFERENCES clientes(id) ON DELETE CASCADE,
    producto VARCHAR(100) NOT NULL,
    saldo NUMERIC(12, 2) NOT NULL
);

-- 7. Tabla de Historial Crediticio
CREATE TABLE IF NOT EXISTS historial_crediticio (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id VARCHAR(100) REFERENCES clientes(id) ON DELETE CASCADE,
    producto VARCHAR(100) NOT NULL,
    monto NUMERIC(12, 2) NOT NULL,
    estado VARCHAR(50) NOT NULL
);

-- 8. Tabla de Documentos adjuntos
CREATE TABLE IF NOT EXISTS documentos (
    id VARCHAR(100) PRIMARY KEY,
    solicitud_id VARCHAR(100) REFERENCES solicitudes_credito(id) ON DELETE CASCADE,
    tipo_documento VARCHAR(100) NOT NULL, -- dni_anverso, dni_reverso, sustento_negocio, foto_visita, firma_digital
    url TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Tabla de Outbox de Transmisión
CREATE TABLE IF NOT EXISTS transmisiones (
    id VARCHAR(100) PRIMARY KEY,
    solicitud_id VARCHAR(100) REFERENCES solicitudes_credito(id) ON DELETE CASCADE,
    estado VARCHAR(50) NOT NULL,
    sync_log TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-- ====================================================================
-- SEMILLA DE DATOS DE PRUEBA (Oficiales y Clientes de los 30 casos)
-- ====================================================================

-- Insertar Asesores (Oficiales de Negocio)
INSERT INTO oficiales (id, codigo_empleado, clave, nombre_completo, cargo)
VALUES 
('ofi_001', 'ofi001', 'supabase123', 'Luis Alberto Bazán', 'SUPER OPERADOR')
ON CONFLICT (id) DO UPDATE SET nombre_completo = EXCLUDED.nombre_completo;

-- Sembrar Clientes para los casos de práctica
INSERT INTO clientes (id, oficial_id, dni, nombres, apellidos, telefono, direccion, negocio, actividad_economica, latitud, longitud, estado)
VALUES
('40118120', 'ofi_001', '40118120', 'Anaximandro', 'Quispe', '964110201', 'Av. Huancavelica 1420, El Tambo', 'Bodega Don Anaxi', 'Bodega', -12.058100, -75.202700, 'ACTIVO'),
('41223341', 'ofi_001', '41223341', 'Eulalia', 'Mamani', '964110202', 'Jr. Junin 425, Chilca', 'Picanteria La Eulalia', 'Restaurante', -12.092100, -75.210500, 'ACTIVO'),
('42330336', 'ofi_001', '42330336', 'Teofilo', 'Huaman', '964110203', 'Jr. Arica 102, Pilcomayo', 'Maderas Huaman', 'Carpinteria', -12.049600, -75.248600, 'ACTIVO'),
('43440349', 'ofi_001', '43440349', 'Casandra', 'Flores', '964110204', 'Jr. Puno 330, Huancayo', 'Distribuidora Casandra', 'Abarrotes', -12.065100, -75.204900, 'ACTIVO'),
('40556071', 'ofi_001', '40556071', 'Demostenes', 'Rojas', '964110205', 'Jr. La Union 120, San Agustin de Cajas', 'Ferreteria El Constructor', 'Ferreteria', -12.018800, -75.227100, 'ACTIVO'),
('41669066', 'ofi_001', '41669066', 'Hipatia', 'Condori', '964110206', 'Av. Real 512, El Tambo', 'Confecciones Hipatia', 'Textil', -12.061200, -75.211800, 'ACTIVO'),
('43773379', 'ofi_001', '43773379', 'Anibal', 'Vargas', '964110207', 'Jr. Tarapaca 304, Concepcion', 'Transportes Anibal', 'Transporte', -11.918200, -75.314200, 'ACTIVO'),
('40886086', 'ofi_001', '40886086', 'Penelope', 'Apaza', '964110208', 'Jr. Lima 112, Sapallanga', 'Granja Penelope', 'Avicola', -12.158100, -75.176200, 'ACTIVO'),
('41990091', 'ofi_001', '41990091', 'Heraclito', 'Ccahua', '964110209', 'Jr. Cusco 450, Huancayo', 'Importaciones Heraclito', 'Comercio', -12.066800, -75.210300, 'ACTIVO'),
('43003039', 'ofi_001', '43003039', 'Cleopatra', 'Soto', '964110210', 'Jr. Bolognesi 214, Chupaca', 'Botica Cleopatra', 'Farmacia', -12.056000, -75.287000, 'ACTIVO'),
('40110010', 'ofi_001', '40110010', 'Esquilo', 'Ramos', '964110211', 'Av. Panamericana 540, Huayucachi', 'Minimarket Esquilo', 'Bodega', -12.133900, -75.209000, 'ACTIVO'),
('41226021', 'ofi_001', '41226021', 'Ariadna', 'Quispe', '964110212', 'Jr. Callao 112, El Tambo', 'Estilos Ariadna', 'Peluqueria', -12.057300, -75.216100, 'ACTIVO'),
('43336033', 'ofi_001', '43336033', 'Sofocles', 'Huanca', '964110213', 'Jr. Libertad 210, Sicaya', 'Panaderia Sofocles', 'Panaderia', -12.022800, -75.313400, 'ACTIVO'),
('40550055', 'ofi_001', '40550055', 'Casiopea', 'Torres', '964110214', 'Jr. Jose Olaya 340, Pilcomayo', 'Taller Casiopea', 'Mecanica', -12.051200, -75.245100, 'ACTIVO'),
('41669166', 'ofi_001', '41669166', 'Aristofanes', 'Cruz', '964110215', 'Jr. Grau 501, Orcotuna', 'Insumos Aristofanes', 'Agropecuario', -11.976000, -75.336100, 'ACTIVO'),
('43880088', 'ofi_001', '43880088', 'Calipso', 'Mendoza', '964110216', 'Jr. Ica 280, Huancayo', 'Calzados Calipso', 'Calzado', -12.068900, -75.205500, 'ACTIVO'),
('40119019', 'ofi_001', '40119019', 'Demetrio', 'Quispe', '964110217', 'Av. Francisco Carle 820, Jauja', 'Mayorista Demetrio', 'Comercio', -11.775200, -75.499500, 'ACTIVO'),
('41226126', 'ofi_001', '41226126', 'Antigona', 'Flores', '964110218', 'Jr. Jorge Chavez 115, Concepcion', 'Recreo Antigona', 'Restaurante', -11.920100, -75.311000, 'ACTIVO'),
('43339033', 'ofi_001', '43339033', 'Pitagoras', 'Rojas', '964110219', 'Jr. Ancash 640, El Tambo', 'Ferreteria Pitagoras', 'Ferreteria', -12.059900, -75.214300, 'ACTIVO'),
('40556056', 'ofi_001', '40556056', 'Berenice', 'Apaza', '964110220', 'Jr. Centenario 202, San Jeronimo de Tunan', 'Tejidos Berenice', 'Textil', -11.987100, -75.289900, 'ACTIVO'),
('43889089', 'ofi_001', '43889089', 'Anaxagoras', 'Huaman', '964110221', 'Av. Giraldez 304, Huancayo', 'Carga Anaxagoras', 'Transporte', -12.064400, -75.208800, 'ACTIVO'),
('41003001', 'ofi_001', '41003001', 'Climene', 'Vargas', '964110222', 'Jr. Alfonso Ugarte 510, Sapallanga', 'Avicola Climene', 'Avicola', -12.156000, -75.179000, 'ACTIVO'),
('40115011', 'ofi_001', '40115011', 'Epaminondas', 'Soto', '964110223', 'Jr. Progreso 105, Pucara', 'Bodega Epaminondas', 'Bodega', -12.170100, -75.161100, 'ACTIVO'),
('41336036', 'ofi_001', '41336036', 'Lisistrata', 'Ramos', '964110224', 'Jr. Ayacucho 442, Huancayo', 'Variedades Lisistrata', 'Comercio', -12.063300, -75.207100, 'ACTIVO'),
('41552052', 'ofi_001', '41552052', 'Filoctetes', 'Cruz', '964110225', 'Av. Jacinto Ibarra 810, Chilca', 'Cevicheria Filoctetes', 'Restaurante', -12.093000, -75.209000, 'ACTIVO'),
('41888088', 'ofi_001', '41888088', 'Calirroe', 'Mendoza', '964110226', 'Jr. Tarapaca 820, El Tambo', 'Calzados Calirroe', 'Calzado', -12.058800, -75.212900, 'ACTIVO'),
('42220022', 'ofi_001', '42220022', 'Tucidides', 'Quispe', '964110227', 'Jr. Leoncio Prado 205, Concepcion', 'Ferreteria Tucidides', 'Ferreteria', -11.917600, -75.315500, 'ACTIVO'),
('43337037', 'ofi_001', '43337037', 'Aquiles', 'Mamani', '964110228', 'Av. Huancavelica 930, Huancayo', 'Comercial Aquiles', 'Comercio', -12.065700, -75.209900, 'ACTIVO'),
('41884084', 'ofi_001', '41884084', 'Medea', 'Apaza', '964110229', 'Jr. San Martin 120, Pilcomayo', 'Bodega Medea', 'Bodega', -12.048900, -75.247000, 'ACTIVO'),
('43334034', 'ofi_001', '43334034', 'Esquines', 'Rojas', '964110230', 'Av. Jauja 1500, Jauja', 'Fletes Esquines', 'Transporte', -11.774000, -75.501000, 'ACTIVO')
ON CONFLICT (id) DO NOTHING;

-- Sembrar productos activos y saldos para buró SBS
INSERT INTO productos_activos (cliente_id, producto, saldo)
VALUES
('40118120', 'Préstamo Convenio', 4500.00),
('41223341', 'Tarjeta Oro', 5000.00),
('41223341', 'Crédito Consumo', 7000.00),
('42330336', 'Tarjeta Clásica', 6000.00),
('43440349', 'Microcrédito', 14000.00),
('40556071', 'Crédito Pyme', 12000.00),
('41669066', 'Microcrédito', 6000.00),
('43773379', 'Crédito Consumo', 14000.00),
('40886086', 'Microcrédito', 6000.00),
('41990091', 'Préstamo Personal', 12000.00),
('43003039', 'Crédito Vehicular', 14000.00),
('40110010', 'Préstamo Convenio', 4500.00),
('41226021', 'Línea de Crédito', 12000.00),
('40550055', 'Microcrédito', 16000.00),
('41669166', 'Préstamo Campaña', 6000.00),
('43880088', 'Crédito Consumo', 9000.00),
('40119019', 'Línea Comercial', 14000.00),
('41226126', 'Crédito Personal', 6000.00),
('40556056', 'Préstamo Activo', 6000.00),
('43889089', 'Línea Pyme', 14000.00),
('41003001', 'Crédito Consumo', 12000.00),
('40115011', 'Préstamo Efectivo', 12000.00),
('41336036', 'Tarjeta de Crédito', 6000.00),
('41552052', 'Tarjeta Platinum', 8000.00),
('41552052', 'Préstamo Personal', 10000.00),
('41888088', 'Línea de Crédito', 9000.00),
('42220022', 'Microcrédito', 18000.00),
('43337037', 'Crédito Consumo', 20000.00),
('43337037', 'Línea Comercial', 20000.00),
('41884084', 'Préstamo Personal', 25000.00),
('43334034', 'Crédito Pyme', 25000.00)
ON CONFLICT (id) DO NOTHING;

-- Sembrar Cartera Diaria para que aparezcan clientes en el listado del Oficial
INSERT INTO cartera_diaria (id, oficial_id, cliente_id, fecha, tipo_gestion, estado, prioridad, observacion)
VALUES
('cart_40118120', 'ofi_001', '40118120', CURRENT_DATE, 'NUEVA_SOLICITUD', 'Pendiente', 3, 'Caso 1: Solicita capital de trabajo para Bodega Don Anaxi. Alta prioridad.'),
('cart_41223341', 'ofi_001', '41223341', CURRENT_DATE, 'Cobranza', 'Pendiente', 2, 'Caso 2: Cobranza de cuota vencida de Picanteria La Eulalia.'),
('cart_42330336', 'ofi_001', '42330336', CURRENT_DATE, 'Renovación', 'Pendiente', 1, 'Caso 3: Renovación de línea de crédito para Maderas Huaman.'),
('cart_43440349', 'ofi_001', '43440349', CURRENT_DATE, 'NUEVA_SOLICITUD', 'Pendiente', 2, 'Caso 4: Ampliación de local para Distribuidora Casandra.'),
('cart_40556071', 'ofi_001', '40556071', CURRENT_DATE, 'Cobranza', 'Visitado', 1, 'Caso 5: Visita de rutina a Ferreteria El Constructor.'),
('cart_41669066', 'ofi_001', '41669066', CURRENT_DATE, 'Renovación', 'Pendiente', 2, 'Caso 6: Renovación de campaña escolar para Confecciones Hipatia.'),
('cart_43773379', 'ofi_001', '43773379', CURRENT_DATE, 'NUEVA_SOLICITUD', 'Pendiente', 3, 'Caso 7: Compra de camión para Transportes Anibal.'),
('cart_40886086', 'ofi_001', '40886086', CURRENT_DATE, 'Cobranza', 'Pendiente', 1, 'Caso 8: Inspección de granja avícola para Penelope Apaza.'),
('cart_41990091', 'ofi_001', '41990091', CURRENT_DATE, 'Renovación', 'Pendiente', 2, 'Caso 9: Campaña navideña para Importaciones Heraclito.'),
('cart_43003039', 'ofi_001', '43003039', CURRENT_DATE, 'NUEVA_SOLICITUD', 'Pendiente', 1, 'Caso 10: Adquisición de vitrinas para Botica Cleopatra.'),
('cart_40110010', 'ofi_001', '40110010', CURRENT_DATE, 'Cobranza', 'Pendiente', 2, 'Caso 11: Cobranza de saldo vencido para Minimarket Esquilo.'),
('cart_41226021', 'ofi_001', '41226021', CURRENT_DATE, 'Renovación', 'Pendiente', 3, 'Caso 12: Renovación de equipos para Estilos Ariadna.'),
('cart_43336033', 'ofi_001', '43336033', CURRENT_DATE, 'NUEVA_SOLICITUD', 'Pendiente', 2, 'Caso 13: Horno industrial para Panaderia Sofocles.'),
('cart_40550055', 'ofi_001', '40550055', CURRENT_DATE, 'Cobranza', 'Visitado', 1, 'Caso 14: Registro de taller mecánico Casiopea.'),
('cart_41669166', 'ofi_001', '41669166', CURRENT_DATE, 'Renovación', 'Pendiente', 2, 'Caso 15: Campaña agrícola para Insumos Aristofanes.'),
('cart_43880088', 'ofi_001', '43880088', CURRENT_DATE, 'NUEVA_SOLICITUD', 'Pendiente', 3, 'Caso 16: Compra de lote de calzado para Calzados Calipso.'),
('cart_40119019', 'ofi_001', '40119019', CURRENT_DATE, 'Cobranza', 'Pendiente', 1, 'Caso 17: Supervisión de mercadería para Mayorista Demetrio.'),
('cart_41226126', 'ofi_001', '41226126', CURRENT_DATE, 'Renovación', 'Pendiente', 2, 'Caso 18: Ampliación de salón de eventos para Recreo Antigona.'),
('cart_43339033', 'ofi_001', '43339033', CURRENT_DATE, 'NUEVA_SOLICITUD', 'Pendiente', 3, 'Caso 19: Adquisición de fierros de construcción para Ferreteria Pitagoras.'),
('cart_40556056', 'ofi_001', '40556056', CURRENT_DATE, 'Cobranza', 'Pendiente', 1, 'Caso 20: Visita de cobranza preventiva para Tejidos Berenice.'),
('cart_43889089', 'ofi_001', '43889089', CURRENT_DATE, 'Renovación', 'Pendiente', 2, 'Caso 21: Renovación de unidad de reparto para Carga Anaxagoras.'),
('cart_41003001', 'ofi_001', '41003001', CURRENT_DATE, 'NUEVA_SOLICITUD', 'Pendiente', 1, 'Caso 22: Compra de alimento balanceado para Avicola Climene.'),
('cart_40115011', 'ofi_001', '40115011', CURRENT_DATE, 'Cobranza', 'Pendiente', 2, 'Caso 23: Cobranza de cuota 3 para Bodega Epaminondas.'),
('cart_41336036', 'ofi_001', '41336036', CURRENT_DATE, 'Renovación', 'Pendiente', 3, 'Caso 24: Compra de mercadería importada para Variedades Lisistrata.'),
('cart_41552052', 'ofi_001', '41552052', CURRENT_DATE, 'NUEVA_SOLICITUD', 'Pendiente', 2, 'Caso 25: Remodelación de cocina para Cevicheria Filoctetes.'),
('cart_41888088', 'ofi_001', '41888088', CURRENT_DATE, 'Cobranza', 'Visitado', 1, 'Caso 26: Cobranza de cuota de local para Calzados Calirroe.'),
('cart_42220022', 'ofi_001', '42220022', CURRENT_DATE, 'Renovación', 'Pendiente', 2, 'Caso 27: Renovación de stock de fierros para Ferreteria Tucidides.'),
('cart_43337037', 'ofi_001', '43337037', CURRENT_DATE, 'NUEVA_SOLICITUD', 'Pendiente', 3, 'Caso 28: Compra de mercadería mayorista para Comercial Aquiles.'),
('cart_41884084', 'ofi_001', '41884084', CURRENT_DATE, 'Cobranza', 'Pendiente', 1, 'Caso 29: Cobranza de saldo vencido para Bodega Medea.'),
('cart_43334034', 'ofi_001', '43334034', CURRENT_DATE, 'Renovación', 'Pendiente', 2, 'Caso 30: Renovación de camión de fletes para Esquines Rojas.')
ON CONFLICT (id) DO NOTHING;

