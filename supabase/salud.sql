-- Comprueba conectividad a Postgres sin leer datos de la aplicación.
create or replace function public.salud()
returns integer
language sql
stable
security invoker
set search_path = ''
as $$
  select 1;
$$;

grant execute on function public.salud() to anon, authenticated;
