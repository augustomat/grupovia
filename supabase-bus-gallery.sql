-- Ejecutar una sola vez en Supabase > SQL Editor para habilitar la galería de ómnibus.
create table if not exists public.bus_photos (
  id uuid primary key default gen_random_uuid(),
  storage_path text not null unique,
  description text not null default '',
  published boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.bus_photos enable row level security;
revoke all on public.bus_photos from anon, authenticated;
grant select on public.bus_photos to anon, authenticated;
grant insert, update, delete on public.bus_photos to authenticated;

drop policy if exists "Público: ver fotos publicadas de ómnibus" on public.bus_photos;
create policy "Público: ver fotos publicadas de ómnibus"
  on public.bus_photos for select to anon, authenticated
  using (published = true);
drop policy if exists "Equipo: ver toda la galería de ómnibus" on public.bus_photos;
create policy "Equipo: ver toda la galería de ómnibus"
  on public.bus_photos for select to authenticated
  using (true);
drop policy if exists "Equipo: agregar fotos de ómnibus" on public.bus_photos;
create policy "Equipo: agregar fotos de ómnibus"
  on public.bus_photos for insert to authenticated
  with check (true);
drop policy if exists "Equipo: editar fotos de ómnibus" on public.bus_photos;
create policy "Equipo: editar fotos de ómnibus"
  on public.bus_photos for update to authenticated
  using (true) with check (true);
drop policy if exists "Equipo: quitar fotos de ómnibus" on public.bus_photos;
create policy "Equipo: quitar fotos de ómnibus"
  on public.bus_photos for delete to authenticated
  using (true);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('bus-gallery', 'bus-gallery', true, 10485760, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = true, file_size_limit = 10485760,
  allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "Público: descargar fotos de ómnibus" on storage.objects;
create policy "Público: descargar fotos de ómnibus"
  on storage.objects for select to public
  using (bucket_id = 'bus-gallery');
drop policy if exists "Equipo: subir fotos de ómnibus" on storage.objects;
create policy "Equipo: subir fotos de ómnibus"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'bus-gallery');
drop policy if exists "Equipo: eliminar fotos de ómnibus" on storage.objects;
create policy "Equipo: eliminar fotos de ómnibus"
  on storage.objects for delete to authenticated
  using (bucket_id = 'bus-gallery');