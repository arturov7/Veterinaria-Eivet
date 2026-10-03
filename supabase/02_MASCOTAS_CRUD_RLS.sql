-- Ejecutar una vez en Supabase SQL Editor después de 01_SCHEMA_RLS.sql.
-- El cliente autenticado solo puede leer sus mascotas.
-- El CRUD del administrador/veterinario se habilita en 05_ADMIN_WEB_SCHEMA_RLS.sql.

drop policy if exists mascotas_propias on public.mascotas;
drop policy if exists mascotas_crear_propias on public.mascotas;
drop policy if exists mascotas_actualizar_propias on public.mascotas;
drop policy if exists mascotas_eliminar_propias on public.mascotas;

create policy mascotas_propias
on public.mascotas for select
using (cliente_id = auth.uid());
