insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'product_images',
  'product_images',
  true,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Public read product images" on storage.objects;
create policy "Public read product images"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'product_images');

drop policy if exists "Anon upload product images" on storage.objects;
create policy "Anon upload product images"
on storage.objects for insert
to anon, authenticated
with check (bucket_id = 'product_images');

drop policy if exists "Anon update product images" on storage.objects;
create policy "Anon update product images"
on storage.objects for update
to anon, authenticated
using (bucket_id = 'product_images')
with check (bucket_id = 'product_images');

drop policy if exists "Anon delete product images" on storage.objects;
create policy "Anon delete product images"
on storage.objects for delete
to anon, authenticated
using (bucket_id = 'product_images');
