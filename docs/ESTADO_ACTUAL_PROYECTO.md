# Estado actual del proyecto EIVET

## Backend y base de datos

Supabase es el backend y la base de datos elegidos para el proyecto. La app inicializa Supabase con `APP_MODE=supabase`, `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`, y usa Supabase Auth y repositorios para las funciones conectadas.

Los scripts SQL propios del proyecto están en `supabase/`:

- `01_SCHEMA_RLS.sql`: tablas base de clientes, mascotas, servicios, citas, vacunas, historiales clínicos y notificaciones; trigger de perfil de cliente y políticas RLS.
- `02_MASCOTAS_CRUD_RLS.sql`: políticas de lectura, creación, edición y eliminación de mascotas del cliente autenticado.
- `04_DATOS_EJEMPLO_CUIDADOS.sql`: datos de ejemplo para vacunas e historial clínico.
- `05_ADMIN_WEB_SCHEMA_RLS.sql`: perfiles y roles, propietarios, consultas y tratamientos; ampliaciones para el panel web y políticas de personal.

La tabla `perfiles` guarda los roles del personal del panel (`administrador` o `veterinario`). La contraseña la administra Supabase Auth y no se copia a esta tabla.

Los scripts describen el esquema esperado; la existencia efectiva de las tablas en el proyecto remoto debe verificarse en Supabase. Ejecutar SQL no equivale a confirmar que ya fue aplicado.

## Módulos Flutter

- App móvil para clientes: autenticación, mascotas, solicitudes de citas, cuidados clínicos, preferencias y contexto de ubicación/clima/mapa.
- Panel administrativo web: acceso de personal y gestión de propietarios, mascotas, citas, consultas, tratamientos y vacunas.
- Interfaces de referencia: `stitch_eivet_panel_administrativo_web/` y `stitch_veterinary_app_interface_design/`.
- Ejecución local de la app con Supabase: `scripts/03_EJECUTAR_SUPABASE_WINDOWS.bat`.

## Pendientes de integración

- Confirmar en el dashboard de Supabase que las tablas y políticas de los SQL están aplicadas.
- Unificar las relaciones entre clientes móviles y propietarios del panel.
- Revisar permisos por rol y RLS para todas las operaciones administrativas.
- Alinear los datos de historiales clínicos, consultas y tratamientos entre app y panel.
- Integrar los módulos de servicios y notificaciones, o dejar documentado que están pendientes.
- Mantener este documento alineado con la implementación real.
