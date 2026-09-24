-- Ejecutar después de 05_ADMIN_WEB_SCHEMA_RLS.sql.
-- Vincula las citas existentes al cliente de la mascota y mantiene ese vínculo
-- cuando el personal crea o cambia una cita desde el panel web.

update public.citas as c
set cliente_id = m.cliente_id
from public.mascotas as m
where c.mascota_id = m.id
  and m.cliente_id is not null
  and c.cliente_id is distinct from m.cliente_id;

create or replace function public.vincular_cita_cliente()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  mascota_cliente_id uuid;
begin
  select cliente_id into mascota_cliente_id
  from public.mascotas
  where id = new.mascota_id;

  if mascota_cliente_id is not null then
    new.cliente_id := mascota_cliente_id;
  end if;
  return new;
end;
$$;

drop trigger if exists on_cita_vincular_cliente on public.citas;
create trigger on_cita_vincular_cliente
before insert or update of mascota_id, cliente_id on public.citas
for each row execute function public.vincular_cita_cliente();
