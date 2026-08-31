-- Ejecutar una vez en Supabase SQL Editor después de 01_SCHEMA_RLS.sql.
-- Permite CRUD solo sobre las mascotas del cliente autenticado.

drop policy if exists mascotas_propias on public.mascotas;
drop policy if exists mascotas_crear_propias on public.mascotas;
drop policy if exists mascotas_actualizar_propias on public.mascotas;
drop policy if exists mascotas_eliminar_propias on public.mascotas;

create policy mascotas_propias
on public.mascotas for select
using (cliente_id = auth.uid());

create policy mascotas_crear_propias
on public.mascotas for insert
with check (cliente_id = auth.uid());

create policy mascotas_actualizar_propias
on public.mascotas for update
using (cliente_id = auth.uid())
with check (cliente_id = auth.uid());

create policy mascotas_eliminar_propias
on public.mascotas for delete
using (cliente_id = auth.uid());
