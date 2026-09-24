-- Solo lectura. Ejecutar en Supabase SQL Editor para comprobar la propiedad
-- de mascotas y citas después de aplicar 06_VINCULAR_CITAS_CLIENTES.sql.

select
  m.id as mascota_id,
  m.nombre as mascota,
  u.email as correo_cliente,
  m.cliente_id,
  m.propietario_id
from public.mascotas as m
left join auth.users as u on u.id = m.cliente_id
order by m.created_at desc;

select
  c.id as cita_id,
  m.nombre as mascota,
  u.email as correo_cliente_cita,
  c.cliente_id as cliente_cita,
  m.cliente_id as cliente_mascota,
  c.fecha_hora,
  c.estado
from public.citas as c
join public.mascotas as m on m.id = c.mascota_id
left join auth.users as u on u.id = c.cliente_id
order by c.fecha_hora desc;
