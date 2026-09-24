-- Ejecutar después de 05_ADMIN_WEB_SCHEMA_RLS.sql.
-- Las cuentas de Auth/Clientes se muestran en el panel junto a los
-- propietarios registrados manualmente, sin copiar contraseñas.

alter table public.clientes add column if not exists correo text;

insert into public.clientes (id, nombre, correo)
select
  u.id,
  coalesce(nullif(trim(u.raw_user_meta_data->>'full_name'), ''),
           split_part(u.email, '@', 1), ''),
  u.email
from auth.users as u
on conflict (id) do update
set correo = excluded.correo,
    nombre = case
      when trim(public.clientes.nombre) = '' then excluded.nombre
      else public.clientes.nombre
    end;

create or replace function public.crear_cliente()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.clientes (id, nombre, correo)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data->>'full_name'), ''),
             split_part(new.email, '@', 1), ''),
    new.email
  )
  on conflict (id) do update set correo = excluded.correo;
  return new;
end;
$$;

drop policy if exists personal_clientes_leer on public.clientes;
create policy personal_clientes_leer
on public.clientes for select to authenticated
using (public.es_personal());
