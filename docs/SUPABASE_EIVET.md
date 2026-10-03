# Supabase EIVET

## Ruta de salud

Ejecuta `supabase/salud.sql` en el SQL Editor del proyecto para crear la RPC de solo lectura `public.salud()`. Después despliega la Edge Function `salud` con `supabase functions deploy salud`. Responde `{"status":"online"}` (HTTP 200) cuando Postgres responde al `SELECT 1`, o `{"status":"offline"}` (HTTP 503) si la comprobación falla. Solo admite GET y HEAD. El endpoint es público y no revela información interna; úsalo para comprobar la conectividad de la base de datos, no otros servicios Supabase.

URL: `https://<project-ref>.supabase.co/functions/v1/salud`.

Supabase es el backend y la base de datos del proyecto. Configura `.env` con la URL del proyecto y su publishable key; este archivo es local y está excluido del repositorio.

## Esquema

Ejecuta los scripts SQL desde el editor SQL de Supabase en este orden:

1. `supabase/01_SCHEMA_RLS.sql`
2. `supabase/02_MASCOTAS_CRUD_RLS.sql`
3. `supabase/05_ADMIN_WEB_SCHEMA_RLS.sql`
4. `supabase/06_VINCULAR_CITAS_CLIENTES.sql`
5. `supabase/09_TRATAMIENTOS_CLIENTES_RLS.sql`
6. `supabase/10_CLIENTES_EN_PANEL.sql`
7. `supabase/12_MASCOTAS_TITULAR_SOLO_PERSONAL.sql`

`supabase/04_DATOS_EJEMPLO_CUIDADOS.sql` es opcional y requiere un usuario y una mascota existentes. Las tablas esperadas son `clientes`, `mascotas`, `servicios`, `citas`, `vacunas`, `historiales_clinicos`, `notificaciones`, `perfiles`, `propietarios`, `consultas` y `tratamientos`. `perfiles` almacena el nombre, correo y rol del personal; las contraseñas permanecen en Supabase Auth.

## Clientes y propietarios

Una cuenta creada en **Authentication > Users** tiene un ID de Auth. El disparador `crear_cliente` crea su fila en `public.clientes` con ese mismo ID. La cuenta de un propietario puede iniciar sesión en la app móvil y sus mascotas se vinculan con `mascotas.cliente_id`. El script `10_CLIENTES_EN_PANEL.sql` agrega el correo a `clientes` y recupera las cuentas de Auth ya existentes. Como el disparador también crea filas para cuentas del personal, el panel excluye de **Clientes y propietarios** los IDs que aparecen en `public.perfiles`. Ejecuta el script en SQL Editor y recarga el panel web.

El propietario puede **consultar** las mascotas vinculadas a su cuenta y solicitar citas. El registro, la edición y la eliminación de mascotas corresponden al personal autenticado con rol `administrador` o `veterinario` en `public.perfiles`. El script `12_MASCOTAS_TITULAR_SOLO_PERSONAL.sql` retira las políticas antiguas de escritura del propietario, conserva su lectura filtrada por `auth.uid()` y exige que cada mascota tenga exactamente un titular: `cliente_id` o `propietario_id`. Si hay filas sin titular o con dos titulares, la migración se detiene sin cambiar las políticas; primero hay que corregir esas filas. No basta con ocultar los botones en Flutter: aplica este script en el proyecto Supabase usado por la app.

Para crear propietarios con acceso móvil desde la web, despliega la función `supabase/functions/crear-propietario/index.ts` en el mismo proyecto Supabase. Con Supabase CLI enlazada al proyecto: `supabase functions deploy crear-propietario`. La configuración `supabase/config.toml` permite que el navegador envíe `OPTIONS`; el `POST` sigue exigiendo dentro de la función un JWT válido y rol `administrador`. La función crea la cuenta en Supabase Auth y completa su perfil en `clientes`. Usa la clave de servicio **solo en el servidor**; Supabase la inyecta en la función. Si no se despliega, el formulario mostrará un error y no creará una ficha manual en su lugar. El correo queda confirmado al crear la cuenta, por lo que el propietario puede entrar en la app móvil con el correo y contraseña asignados.

Los **propietarios manuales** creados antes de este cambio siguen en `public.propietarios`. Son fichas de contacto sin contraseña ni acceso a la app móvil; sus mascotas se vinculan con `mascotas.propietario_id`. En el listado, la etiqueta **App móvil** identifica las cuentas de `clientes` y la etiqueta **Manual** identifica las fichas antiguas de `propietarios`. El botón **Crear cuenta de propietario** ahora crea usuarios de Auth. Al crear una mascota desde la web, selecciona la cuenta **App móvil** correcta si quieres que esa mascota aparezca al iniciar sesión con esa cuenta en el teléfono. Las mascotas de fichas antiguas no se migran automáticamente porque pueden existir personas con nombres repetidos; vincúlalas explícitamente después de revisar la identidad.

Para revisar la vinculación en SQL Editor:

```sql
select c.id, c.nombre, c.correo, m.nombre as mascota
from public.clientes c
left join public.mascotas m on m.cliente_id = c.id
order by c.nombre, m.nombre;
```

Antes de aplicar la migración, identifica mascotas con vínculos ambiguos:

```sql
select id, nombre, cliente_id, propietario_id
from public.mascotas
where num_nonnulls(cliente_id, propietario_id) <> 1;
```

La consulta debe devolver cero filas. Después de aplicar el script, comprueba las políticas activas con `select policyname, cmd from pg_policies where schemaname = 'public' and tablename = 'mascotas';`: `mascotas_propias` debe ser solo `SELECT`, y el CRUD del personal se realiza mediante `personal_mascotas`.

Para diagnosticar la sincronización, ejecuta la consulta única `supabase/08_DIAGNOSTICO_VACUNAS_CITAS.sql`. Una mascota puede existir aunque no haya ninguna fila guardada en `vacunas` o `citas`. Si `citas_guardadas` es mayor que cero pero `citas_visibles_para_cliente` es cero, aplica primero `supabase/06_VINCULAR_CITAS_CLIENTES.sql`.

Los archivos SQL declaran el esquema esperado; comprueba en Supabase que la ejecución haya terminado y que las tablas y políticas estén presentes.

## Ejecutar

- Móvil/Web con Supabase: `flutter run --dart-define-from-file=.env`
- Android release: `flutter build apk --release --dart-define-from-file=.env`
- Windows: `scripts/03_EJECUTAR_SUPABASE_WINDOWS.bat`

No pongas claves privadas ni `service_role` en la app Flutter. Usa únicamente la publishable/anon key y políticas RLS.
