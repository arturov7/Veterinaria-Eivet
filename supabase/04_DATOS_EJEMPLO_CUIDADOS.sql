-- Reemplaza el correo por el usuario creado en Authentication > Users.
-- Ejecuta este script DESPUÉS de registrar al menos una mascota desde la app.

do $$
declare
  cliente uuid;
  mascota uuid;
begin
  select id into cliente from auth.users where email = 'REEMPLAZA_CON_TU_CORREO@ejemplo.com';
  if cliente is null then
    raise exception 'No se encontró el usuario; reemplaza el correo del script.';
  end if;

  select id into mascota from public.mascotas where cliente_id = cliente order by created_at limit 1;
  if mascota is null then
    raise exception 'Registra primero una mascota desde la aplicación.';
  end if;

  insert into public.vacunas (mascota_id, nombre, fecha_aplicacion, proxima_dosis, estado)
  values (mascota, 'Vacuna antirrábica', current_date - 30, current_date + 335, 'Aplicada');

  insert into public.historiales_clinicos (mascota_id, motivo, diagnostico, tratamiento, indicaciones, proximo_control, autorizado)
  values (mascota, 'Control general', 'Seguimiento preventivo', 'Suplemento vitamínico', 'Administrar según indicación del veterinario y mantener agua disponible.', current_date + 15, true);
end $$;
