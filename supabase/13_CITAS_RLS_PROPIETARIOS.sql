-- Ejecutar después de 12_MASCOTAS_TITULAR_SOLO_PERSONAL.sql.
-- Una cuenta móvil solo puede ver y modificar citas de sus propias mascotas.
-- El personal conserva sus permisos mediante la política personal_citas.

begin;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'citas'
      and policyname = 'personal_citas'
  ) then
    raise exception 'Falta la política personal_citas. Ejecuta primero 05_ADMIN_WEB_SCHEMA_RLS.sql.';
  end if;
end;
$$;

drop policy if exists citas_propias on public.citas;
drop policy if exists citas_crear_propias on public.citas;
drop policy if exists citas_cancelar_propias on public.citas;

create policy citas_propias on public.citas
  for select to authenticated
  using (
    cliente_id = (select auth.uid())
    and propietario_id is null
    and exists (
      select 1 from public.mascotas as m
      where m.id = mascota_id and m.cliente_id = (select auth.uid())
    )
  );

create policy citas_crear_propias on public.citas
  for insert to authenticated
  with check (
    cliente_id = (select auth.uid())
    and propietario_id is null
    and exists (
      select 1 from public.mascotas as m
      where m.id = mascota_id and m.cliente_id = (select auth.uid())
    )
  );

create policy citas_cancelar_propias on public.citas
  for update to authenticated
  using (
    cliente_id = (select auth.uid())
    and propietario_id is null
    and exists (
      select 1 from public.mascotas as m
      where m.id = mascota_id and m.cliente_id = (select auth.uid())
    )
  )
  with check (
    cliente_id = (select auth.uid())
    and propietario_id is null
    and exists (
      select 1 from public.mascotas as m
      where m.id = mascota_id and m.cliente_id = (select auth.uid())
    )
  );

commit;
