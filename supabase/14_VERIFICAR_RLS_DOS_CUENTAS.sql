-- Prueba manual en Supabase SQL Editor. Usar solo dos cuentas ficticias.
-- Reemplaza CUENTA_A_UUID, MASCOTA_A_UUID, CUENTA_B_UUID y MASCOTA_B_UUID
-- por los cuatro UUID reales de las cuentas de prueba y sus mascotas.
-- No incluyas contraseñas ni datos clínicos en capturas o en el repositorio.
-- Ejecutar después de 12_MASCOTAS_TITULAR_SOLO_PERSONAL.sql y
-- 13_CITAS_RLS_PROPIETARIOS.sql.
-- Si necesitas localizar los UUID, ejecuta por separado esta consulta
-- con los correos de las dos cuentas ficticias:
-- select c.id as cuenta_id, m.id as mascota_id
-- from public.clientes c join public.mascotas m on m.cliente_id = c.id
-- where c.correo in ('CORREO_A', 'CORREO_B');

-- Comprobar primero que los UUID seleccionados corresponden a dos cuentas
-- diferentes. Esta consulta se ejecuta con los permisos del SQL Editor.
select id, cliente_id
from public.mascotas
where id in ('MASCOTA_A_UUID'::uuid, 'MASCOTA_B_UUID'::uuid);

-- Para que la prueba de citas sea concluyente, cada mascota debe tener
-- al menos una cita ficticia. Si el conteo es cero, prueba solo mascotas.
select mascota_id, count(*) as citas_de_prueba
from public.citas
where mascota_id in ('MASCOTA_A_UUID'::uuid, 'MASCOTA_B_UUID'::uuid)
group by mascota_id;

-- Simular la cuenta A con el rol authenticated. Se espera:
-- propia = 1, ajena = 0, cita_ajena = 0, filas_modificadas = 0.
-- Un error de permiso en el UPDATE también significa que no pudo modificarla;
-- si ocurre, ejecuta ROLLBACK antes de iniciar la prueba siguiente.
-- El UPDATE usa el mismo valor y ROLLBACK; no guarda modificaciones.
begin;
set local role authenticated;
select set_config('request.jwt.claim.sub', 'CUENTA_A_UUID', true) as identidad_simulada;
select
  (select count(*) from public.mascotas where id = 'MASCOTA_A_UUID'::uuid) as propia,
  (select count(*) from public.mascotas where id = 'MASCOTA_B_UUID'::uuid) as ajena,
  (select count(*) from public.citas where mascota_id = 'MASCOTA_B_UUID'::uuid) as cita_ajena;
with intento as (
  update public.mascotas set nombre = nombre
  where id = 'MASCOTA_B_UUID'::uuid
  returning id
)
select count(*) as filas_modificadas from intento;
rollback;

-- Repetir en sentido inverso para detectar políticas asimétricas.
-- Se espera propia = 1, ajena = 0, cita_ajena = 0,
-- filas_modificadas = 0 (o error de permiso, seguido de ROLLBACK).
begin;
set local role authenticated;
select set_config('request.jwt.claim.sub', 'CUENTA_B_UUID', true) as identidad_simulada;
select
  (select count(*) from public.mascotas where id = 'MASCOTA_B_UUID'::uuid) as propia,
  (select count(*) from public.mascotas where id = 'MASCOTA_A_UUID'::uuid) as ajena,
  (select count(*) from public.citas where mascota_id = 'MASCOTA_A_UUID'::uuid) as cita_ajena;
with intento as (
  update public.mascotas set nombre = nombre
  where id = 'MASCOTA_A_UUID'::uuid
  returning id
)
select count(*) as filas_modificadas from intento;
rollback;
