-- Photoshop website: run this in Supabase > SQL Editor.
-- Then create a PUBLIC Storage bucket named exactly: post-images.
-- NEVER expose your service_role key in app.js.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Member' check (char_length(display_name) between 1 and 40),
  bio text not null default '' check (char_length(bio) <= 240),
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  description text not null default '' check (char_length(description) <= 2000),
  image_url text not null,
  storage_path text not null,
  created_at timestamptz not null default now()
);

create index if not exists posts_created_at_idx on public.posts (created_at desc);
create index if not exists posts_user_id_idx on public.posts (user_id);

alter table public.profiles enable row level security;
alter table public.posts enable row level security;

drop policy if exists "Profiles are viewable by everyone" on public.profiles;
create policy "Profiles are viewable by everyone" on public.profiles for select using (true);
drop policy if exists "Users can create their own profile" on public.profiles;
create policy "Users can create their own profile" on public.profiles for insert to authenticated with check (auth.uid() = id);
drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Posts are viewable by everyone" on public.posts;
create policy "Posts are viewable by everyone" on public.posts for select using (true);
drop policy if exists "Signed-in users can create posts as themselves" on public.posts;
create policy "Signed-in users can create posts as themselves" on public.posts for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Users can delete their own posts" on public.posts;
create policy "Users can delete their own posts" on public.posts for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "Public can view post images" on storage.objects;
create policy "Public can view post images" on storage.objects for select using (bucket_id = 'post-images');
drop policy if exists "Users upload images to their own folder" on storage.objects;
create policy "Users upload images to their own folder" on storage.objects for insert to authenticated with check (bucket_id = 'post-images' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "Users delete images from their own folder" on storage.objects;
create policy "Users delete images from their own folder" on storage.objects for delete to authenticated using (bucket_id = 'post-images' and (storage.foldername(name))[1] = auth.uid()::text);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(nullif(new.raw_user_meta_data ->> 'display_name', ''), split_part(new.email, '@', 1), 'Member'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();
