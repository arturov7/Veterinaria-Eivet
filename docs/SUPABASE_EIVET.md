# Supabase EIVET

Configura el proyecto en supabase.com y copia Project URL y la publishable key en `config/local.json` (archivo ignorado). Ejecuta `supabase/01_SCHEMA_RLS.sql` desde SQL Editor y luego `flutter pub get`.

Demo: `flutter run --dart-define-from-file=config/demo.json`. Supabase: `flutter run --dart-define-from-file=config/local.json`.

Las tablas son `clientes`, `mascotas`, `servicios`, `citas`, `vacunas`, `historiales_clinicos` y `notificaciones`. El trigger crea el perfil tras el registro y RLS limita cada consulta al cliente autenticado. La autenticación usa Supabase Auth; no se usan secretos de servidor.
