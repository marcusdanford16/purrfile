-- PurrFile Row Level Security policies
--
-- This file does NOT create or alter any tables. It only adds/repairs RLS
-- policies on the EXISTING tables (cats, health_records, reminders,
-- ai_conversations). Run it manually in the Supabase SQL editor after
-- reviewing it — do not run automatically from the app.
--
-- Ownership model:
--   cats.user_id              -> auth.uid() directly
--   health_records.cat_id     -> cats.id -> cats.user_id (indirect)
--   reminders.cat_id          -> cats.id -> cats.user_id (indirect)
--   ai_conversations.user_id  -> auth.uid() directly (and cat_id for scoping)
--
-- Knowing a cat_id must never be sufficient on its own to read/write a
-- health_record or reminder — every policy below re-checks ownership through
-- the parent cat.

-- 1. Make sure RLS is actually turned on (idempotent).
alter table public.cats enable row level security;
alter table public.health_records enable row level security;
alter table public.reminders enable row level security;
alter table public.ai_conversations enable row level security;

-- 2. cats: a user may only see/change their own cats.
drop policy if exists "cats_select_own" on public.cats;
create policy "cats_select_own" on public.cats
  for select using (auth.uid() = user_id);

drop policy if exists "cats_insert_own" on public.cats;
create policy "cats_insert_own" on public.cats
  for insert with check (auth.uid() = user_id);

drop policy if exists "cats_update_own" on public.cats;
create policy "cats_update_own" on public.cats
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "cats_delete_own" on public.cats;
create policy "cats_delete_own" on public.cats
  for delete using (auth.uid() = user_id);

-- 3. health_records: ownership flows through the parent cat.
drop policy if exists "health_records_select_own" on public.health_records;
create policy "health_records_select_own" on public.health_records
  for select using (
    exists (
      select 1 from public.cats
      where cats.id = health_records.cat_id
        and cats.user_id = auth.uid()
    )
  );

drop policy if exists "health_records_insert_own" on public.health_records;
create policy "health_records_insert_own" on public.health_records
  for insert with check (
    exists (
      select 1 from public.cats
      where cats.id = health_records.cat_id
        and cats.user_id = auth.uid()
    )
  );

drop policy if exists "health_records_update_own" on public.health_records;
create policy "health_records_update_own" on public.health_records
  for update using (
    exists (
      select 1 from public.cats
      where cats.id = health_records.cat_id
        and cats.user_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from public.cats
      where cats.id = health_records.cat_id
        and cats.user_id = auth.uid()
    )
  );

drop policy if exists "health_records_delete_own" on public.health_records;
create policy "health_records_delete_own" on public.health_records
  for delete using (
    exists (
      select 1 from public.cats
      where cats.id = health_records.cat_id
        and cats.user_id = auth.uid()
    )
  );

-- 4. reminders: same pattern as health_records.
drop policy if exists "reminders_select_own" on public.reminders;
create policy "reminders_select_own" on public.reminders
  for select using (
    exists (
      select 1 from public.cats
      where cats.id = reminders.cat_id
        and cats.user_id = auth.uid()
    )
  );

drop policy if exists "reminders_insert_own" on public.reminders;
create policy "reminders_insert_own" on public.reminders
  for insert with check (
    exists (
      select 1 from public.cats
      where cats.id = reminders.cat_id
        and cats.user_id = auth.uid()
    )
  );

drop policy if exists "reminders_update_own" on public.reminders;
create policy "reminders_update_own" on public.reminders
  for update using (
    exists (
      select 1 from public.cats
      where cats.id = reminders.cat_id
        and cats.user_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from public.cats
      where cats.id = reminders.cat_id
        and cats.user_id = auth.uid()
    )
  );

drop policy if exists "reminders_delete_own" on public.reminders;
create policy "reminders_delete_own" on public.reminders
  for delete using (
    exists (
      select 1 from public.cats
      where cats.id = reminders.cat_id
        and cats.user_id = auth.uid()
    )
  );

-- 5. ai_conversations: scoped directly by user_id (and implicitly by cat_id,
-- which the app also filters on).
drop policy if exists "ai_conversations_select_own" on public.ai_conversations;
create policy "ai_conversations_select_own" on public.ai_conversations
  for select using (auth.uid() = user_id);

drop policy if exists "ai_conversations_insert_own" on public.ai_conversations;
create policy "ai_conversations_insert_own" on public.ai_conversations
  for insert with check (auth.uid() = user_id);

drop policy if exists "ai_conversations_delete_own" on public.ai_conversations;
create policy "ai_conversations_delete_own" on public.ai_conversations
  for delete using (auth.uid() = user_id);

-- 6. Cat photos: create this public bucket once, then limit uploads to a
-- folder named after the authenticated user's id. Public read access is
-- intentional because cats.photo stores a public URL.
insert into storage.buckets (id, name, public)
values ('cat-photos', 'cat-photos', true)
on conflict (id) do update set public = excluded.public;

drop policy if exists "cat_photos_insert_own" on storage.objects;
create policy "cat_photos_insert_own" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'cat-photos'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );

-- Sanity check after applying: as User A, `select * from health_records
-- where cat_id = '<User B's cat id>'` must return zero rows even though the
-- row exists in the table.
