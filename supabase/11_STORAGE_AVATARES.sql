-- Ejecutar una sola vez en Supabase SQL Editor para habilitar fotos de perfil.
-- Las imágenes son públicas para que puedan mostrarse como avatar; cada usuario
-- solo puede cargar, reemplazar o eliminar archivos dentro de su propia carpeta.

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'avatars',
  'avatars',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Lectura pública de avatares" on storage.objects;
create policy "Lectura pública de avatares"
on storage.objects for select
to public
using (bucket_id = 'avatars');

drop policy if exists "Cada usuario carga su avatar" on storage.objects;
create policy "Cada usuario carga su avatar"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Cada usuario actualiza su avatar" on storage.objects;
create policy "Cada usuario actualiza su avatar"
on storage.objects for update
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Cada usuario elimina su avatar" on storage.objects;
create policy "Cada usuario elimina su avatar"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);
