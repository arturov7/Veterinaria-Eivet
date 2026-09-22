-- EIVET: módulo administrativo. Ejecutar después de 01_SCHEMA_RLS.sql y 02_MASCOTAS_CRUD_RLS.sql.
-- No contiene service_role ni secretos. Cree el usuario en Auth y su perfil al final.
create extension if not exists "pgcrypto";
create table if not exists public.perfiles (id uuid primary key references auth.users(id) on delete cascade, nombre text not null default '', correo text, rol text not null default 'veterinario' check (rol in ('administrador','veterinario')), fecha_creacion timestamptz not null default now());
create table if not exists public.propietarios (id uuid primary key default gen_random_uuid(), nombre_completo text not null, ci text, telefono text, correo text, direccion text, created_at timestamptz not null default now());

-- Compatibilidad: la app móvil usa cliente_id y el panel propietario_id.
alter table public.mascotas alter column cliente_id drop not null;
alter table public.mascotas add column if not exists propietario_id uuid references public.propietarios(id) on delete cascade;
alter table public.mascotas add column if not exists peso numeric, add column if not exists color text, add column if not exists observaciones text;
alter table public.citas alter column cliente_id drop not null;
alter table public.citas add column if not exists propietario_id uuid references public.propietarios(id) on delete cascade, add column if not exists observaciones text;
create table if not exists public.consultas (id uuid primary key default gen_random_uuid(), mascota_id uuid not null references public.mascotas(id) on delete cascade, veterinario_id uuid references public.perfiles(id), fecha date not null default current_date, motivo text not null, diagnostico text, observaciones text, created_at timestamptz not null default now());
create table if not exists public.tratamientos (id uuid primary key default gen_random_uuid(), mascota_id uuid not null references public.mascotas(id) on delete cascade, consulta_id uuid references public.consultas(id) on delete set null, nombre text not null, indicaciones text, fecha_inicio date, fecha_fin date, estado text, created_at timestamptz not null default now());
alter table public.vacunas add column if not exists observaciones text;
create index if not exists mascotas_propietario_idx on public.mascotas(propietario_id); create index if not exists citas_fecha_idx on public.citas(fecha_hora); create index if not exists consultas_mascota_idx on public.consultas(mascota_id); create index if not exists vacunas_proxima_dosis_idx on public.vacunas(proxima_dosis);

create or replace function public.es_personal() returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from public.perfiles where id=auth.uid() and rol in ('administrador','veterinario'))$$;
alter table public.perfiles enable row level security; alter table public.propietarios enable row level security; alter table public.consultas enable row level security; alter table public.tratamientos enable row level security;
drop policy if exists perfiles_personal on public.perfiles; create policy perfiles_personal on public.perfiles for select using (id=auth.uid() or public.es_personal());
drop policy if exists personal_propietarios on public.propietarios; create policy personal_propietarios on public.propietarios for all using (public.es_personal()) with check (public.es_personal());
drop policy if exists personal_consultas on public.consultas; create policy personal_consultas on public.consultas for all using (public.es_personal()) with check (public.es_personal());
drop policy if exists personal_tratamientos on public.tratamientos; create policy personal_tratamientos on public.tratamientos for all using (public.es_personal()) with check (public.es_personal());
drop policy if exists personal_mascotas on public.mascotas; create policy personal_mascotas on public.mascotas for all using (public.es_personal()) with check (public.es_personal());
drop policy if exists personal_citas on public.citas; create policy personal_citas on public.citas for all using (public.es_personal()) with check (public.es_personal());
drop policy if exists personal_vacunas on public.vacunas; create policy personal_vacunas on public.vacunas for all using (public.es_personal()) with check (public.es_personal());

-- Tras crear el usuario en Authentication > Users, asigne su rol (cambie correo/nombre):
-- insert into public.perfiles (id,nombre,correo,rol) select id,'Personal EIVET',email,'administrador' from auth.users where email='admin@ejemplo.com' on conflict (id) do update set rol=excluded.rol;
