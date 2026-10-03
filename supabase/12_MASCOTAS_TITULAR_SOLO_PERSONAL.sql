-- Ejecutar después de 10_CLIENTES_EN_PANEL.sql en Supabase SQL Editor.
-- El propietario autenticado solo consulta sus mascotas. El personal con rol
-- administrador o veterinario conserva el CRUD mediante personal_mascotas.

begin;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'mascotas'
      and policyname = 'personal_mascotas'
  ) then
    raise exception 'Falta la política personal_mascotas. Ejecuta primero 05_ADMIN_WEB_SCHEMA_RLS.sql.';
  end if;

  if exists (
    select 1 from public.mascotas
    where num_nonnulls(cliente_id, propietario_id) <> 1
  ) then
    raise exception 'Hay mascotas sin titular o con dos titulares. Corrige esas filas antes de aplicar esta migración.';
  end if;
end;
$$;

drop policy if exists mascotas_crear_propias on public.mascotas;
drop policy if exists mascotas_actualizar_propias on public.mascotas;
drop policy if exists mascotas_eliminar_propias on public.mascotas;

-- La lectura del propietario continúa limitada a su ID de Supabase Auth.
drop policy if exists mascotas_propias on public.mascotas;
create policy mascotas_propias on public.mascotas
  for select to authenticated using (cliente_id = (select auth.uid()));

-- Una mascota pertenece a una cuenta móvil O a una ficha manual, nunca a ambas.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.mascotas'::regclass
      and conname = 'mascotas_un_titular'
  ) then
    alter table public.mascotas
      add constraint mascotas_un_titular
      check (num_nonnulls(cliente_id, propietario_id) = 1);
  end if;
end;
$$;

commit;
