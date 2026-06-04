# README.md — App Fuerza de Ventas (Roadmap Completo para Antigravity)

## Objetivo
Desarrollar una aplicación móvil Flutter + Supabase para asesores de negocios de microfinanzas en campo, con arquitectura Offline-First, MVVM (Riverpod), geolocalización, captura documental, solicitudes de crédito, cobranza y reportes.

---

# Stack Tecnológico

## Frontend
- Flutter
- Riverpod (StateNotifier)
- GoRouter
- SQLite
- Google Maps Flutter
- Geolocator
- Geocoding
- Camera
- Photo View
- FL Chart
- Firebase Messaging
- Flutter Local Notifications
- WorkManager

## Backend
- Supabase Auth
- Supabase Database
- Supabase Storage
- Supabase Realtime
- Supabase Edge Functions

---

# Arquitectura

MVVM

View
↓
ViewModel (Riverpod)
↓
Repository
↓
Supabase + SQLite

Regla:
- Si hay internet → Supabase
- Si no hay internet → SQLite
- Al recuperar conexión → sincronización automática

---

# Módulos a Implementar

## M0 Autenticación
- Login con código empleado
- Persistencia de sesión
- Bloqueo por intentos fallidos
- Roles:
  - Operador
  - Super Operador
  - Supervisor
  - Administrador
- Logout seguro

## M1 Cartera Diaria
- Lista de clientes asignados
- Filtros
- Búsqueda
- Sincronización nocturna
- Priorización automática
- Registro de visitas

## M2 Ruta y Geolocalización
- Google Maps
- Optimización de rutas
- Navegación Waze/Google Maps
- Geocercas
- Actualización GPS del negocio

## M3 Ficha Cliente
- Información completa
- Historial crediticio
- Semáforo de riesgo
- Gráfico de pagos
- Ofertas preaprobadas
- Alertas de cartera

## M4 Prospección
- Registro de prospectos
- Pre-evaluación
- Campañas comerciales

## M5 Solicitudes de Crédito
Formulario en 4 pasos:

### Paso 1
Datos del solicitante

### Paso 2
Datos del negocio

### Paso 3
Condiciones del crédito

### Paso 4
Confirmación y firma

Incluye:
- Offline First
- Borradores
- Simulador financiero
- Historial de solicitudes

## M6 Captura Documental
- DNI Anverso
- DNI Reverso
- Foto negocio
- Foto cliente

Características:
- Validación de nitidez
- Compresión automática
- Reemplazo de fotos
- Visor con zoom

## M7 Buro de Crédito
- Consulta SBS
- Consulta Equifax simulada
- Consentimiento firmado
- Listas negras
- Detección de fraude

## M8 Transmisión Electrónica
- Validación integral
- Subida paralela
- Reanudación de procesos
- Expediente automático

## M9 Estados de Solicitud
- Tablero Kanban
- Timeline
- PDF de estado
- Notificaciones en tiempo real

## M10 Cobranza
- Mora diaria
- Acciones de cobranza
- Compromisos de pago
- Recordatorios automáticos

## M11 Supervisión
- Monitor en tiempo real
- Productividad mensual
- Exportación PDF

---

# Funcionalidades Offline First

SQLite Local

Tablas:

- solicitudes_borrador
- visitas_pendientes

Comportamiento:

1. Guardar localmente
2. Marcar pendiente_sync=true
3. Detectar reconexión
4. Sincronizar en lote
5. Marcar pendiente_sync=false

---

# Funcionalidades de Geolocalización

## GPS
- Captura de ubicación actual
- Actualización de ubicación de negocio
- Coordenadas en visitas

## Geocodificación Inversa
Convertir:

Latitud + Longitud
→ Dirección legible

## Geocercas
- Polígonos por asesor
- Validación mediante Ray Casting
- Aviso fuera de zona

## Optimización de Ruta
Algoritmo:
- Nearest Neighbor

---

# Simulador Financiero

Cálculo de cuotas con amortización francesa.

Variables:

- Monto
- TEA
- Plazo

Mostrar:

- Cuota estimada
- Total a pagar
- Costo financiero

---

# Notificaciones

## Firebase Cloud Messaging
Estados:
- recibido_comite
- aprobado
- condicionado
- rechazado
- desembolsado

## Local Notifications
- Sincronización nocturna
- Recordatorios de cobranza
- Alertas de cartera

---

# Supabase Storage

documentos-solicitudes/{solicitud_id}/{tipo_documento}.jpg

Documentos:
- dni_anverso
- dni_reverso
- ruc
- recibo_servicios
- foto_negocio
- foto_visita
- contrato_arrendamiento

---

# Base de Datos Principal

## Tablas

### Identidad
- agencias
- asesores_negocio

### Clientes
- clientes
- creditos
- creditos_preaprobados
- campanas_activas

### Operación
- cartera_diaria
- solicitudes_credito
- solicitudes_documentos
- consultas_buro
- acciones_cobranza
- alertas_cartera
- solicitudes_notas_internas

---

# Estructura Flutter

lib/
├── app/
├── core/
├── features/
│
├── auth/
├── cartera/
├── ruta/
├── ficha_cliente/
├── prospeccion/
├── solicitudes/
├── documentos/
├── buro/
├── estados/
├── cobranza/
├── reportes/

---

# Prioridad de Desarrollo

FASE 1
- Auth
- Roles
- Cartera
- Cliente
- GPS

FASE 2
- Solicitudes
- Offline First
- Documentos
- Firma Digital

FASE 3
- Buro
- Transmisión
- Estados

FASE 4
- Cobranza
- Supervisión
- Reportes

---

# Objetivo Final

Aplicación móvil completa para fuerza de ventas microfinanciera con:
- Flutter
- Supabase
- MVVM
- Offline First
- Geolocalización avanzada
- Captura documental
- Gestión crediticia completa
- Supervisión en tiempo real
