-- Una sola consulta de lectura para ver qué hay realmente en Supabase.
-- Ejecutar completa en SQL Editor y revisar las columnas de vacunas y citas.
select
  m.id as mascota_id,
  m.nombre as mascota,
  u.email as correo_cliente,
  count(distinct v.id) as vacunas_guardadas,
  string_agg(distinct v.nombre, ', ') as nombres_vacunas,
  count(distinct c.id) as citas_guardadas,
  count(distinct c.id) filter (
    where c.cliente_id = m.cliente_id
  ) as citas_visibles_para_cliente,
  string_agg(distinct c.estado, ', ') as estados_citas
from public.mascotas as m
left join auth.users as u on u.id = m.cliente_id
left join public.vacunas as v on v.mascota_id = m.id
left join public.citas as c on c.mascota_id = m.id
group by m.id, m.nombre, u.email
order by m.nombre;
