-- Ejecutar después de 05_ADMIN_WEB_SCHEMA_RLS.sql.
-- Permite que el cliente móvil lea tratamientos de sus propias mascotas.
drop policy if exists tratamientos_cliente_propios on public.tratamientos;
create policy tratamientos_cliente_propios
on public.tratamientos for select to authenticated
using (
  exists (
    select 1 from public.mascotas as m
    where m.id = mascota_id and m.cliente_id = auth.uid()
  )
);
