# Supabase EIVET

Supabase es el backend y la base de datos del proyecto. Configura `config/local.json` con la URL del proyecto y su publishable key; este archivo es local y está excluido del repositorio.

## Esquema

Ejecuta los scripts SQL desde el editor SQL de Supabase en este orden:

1. `supabase/01_SCHEMA_RLS.sql`
2. `supabase/02_MASCOTAS_CRUD_RLS.sql`
3. `supabase/05_ADMIN_WEB_SCHEMA_RLS.sql`

`supabase/04_DATOS_EJEMPLO_CUIDADOS.sql` es opcional y requiere un usuario y una mascota existentes. Las tablas esperadas son `clientes`, `mascotas`, `servicios`, `citas`, `vacunas`, `historiales_clinicos`, `notificaciones`, `perfiles`, `propietarios`, `consultas` y `tratamientos`. `perfiles` almacena el nombre, correo y rol del personal; las contraseñas permanecen en Supabase Auth.

Los archivos SQL declaran el esquema esperado; comprueba en Supabase que la ejecución haya terminado y que las tablas y políticas estén presentes.

## Ejecutar

- Móvil/Web con Supabase: `flutter run --dart-define-from-file=config/local.json`
- Android release: `flutter build apk --release --dart-define-from-file=config/local.json`
- Windows: `scripts/03_EJECUTAR_SUPABASE_WINDOWS.bat`

No pongas claves privadas ni `service_role` en la app Flutter. Usa únicamente la publishable/anon key y políticas RLS.
