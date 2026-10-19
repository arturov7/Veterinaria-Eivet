-- Diagnóstico de solo lectura antes y después de aplicar los scripts 12 y 13.
-- Ejecutar en el SQL Editor del proyecto Supabase correcto.
-- Devuelve estructura, políticas y conteos agregados; no muestra datos personales.

select esperado.tabla,
       c.oid is not null as existe,
       coalesce(c.relrowsecurity, false) as rls_activa,
       coalesce(c.relforcerowsecurity, false) as rls_forzada
from (values
  ('clientes'), ('mascotas'), ('citas'), ('vacunas'),
  ('historiales_clinicos'), ('notificaciones'), ('perfiles'),
  ('propietarios'), ('consultas'), ('tratamientos')
) as esperado(tabla)
left join pg_namespace n on n.nspname = 'public'
left join pg_class c on c.relnamespace = n.oid
                    and c.relname = esperado.tabla
                    and c.relkind in ('r', 'p')
order by esperado.tabla;

select table_name, column_name, data_type, is_nullable
from information_schema.columns
where table_schema = 'public'
  and table_name in ('mascotas', 'citas')
  and column_name in ('id', 'cliente_id', 'propietario_id', 'mascota_id')
order by table_name, column_name;

select tablename, policyname, permissive, roles, cmd, qual, with_check
from pg_policies
where schemaname = 'public'
  and tablename in ('mascotas', 'citas')
order by tablename, policyname;

select to_regprocedure('public.es_personal()') is not null as existe_es_personal;

select conname, pg_get_constraintdef(oid) as definicion
from pg_constraint
where conrelid = to_regclass('public.mascotas')
  and conname = 'mascotas_un_titular';

-- Ejecutar los siguientes conteos solo si las tablas y columnas anteriores existen.
-- El script 12 exige cero mascotas con cero o dos titulares.
select count(*) as mascotas_total,
       count(*) filter (where num_nonnulls(cliente_id, propietario_id) = 0) as sin_titular,
       count(*) filter (where num_nonnulls(cliente_id, propietario_id) = 2) as dos_titulares
from public.mascotas;

-- El script 13 ocultaría a propietarios las citas incompatibles con su política.
-- Revise las causas antes de aplicarlo; no se modifican filas aquí.
select count(*) filter (where c.cliente_id is not null) as citas_de_clientes,
       count(*) filter (where c.cliente_id is not null
                          and (c.propietario_id is not null
                               or m.id is null
                               or m.cliente_id is distinct from c.cliente_id))
         as citas_de_clientes_incompatibles_13
from public.citas as c
left join public.mascotas as m on m.id = c.mascota_id;
