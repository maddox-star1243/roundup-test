
-- Roundup V5.5: profiles, friend requests, and shop activity center
-- Run in Supabase SQL Editor.

alter table public.profiles add column if not exists total_realized_pnl numeric default 0;
alter table public.profiles add column if not exists username text;

create table if not exists public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references auth.users(id) on delete cascade,
  addressee_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','declined')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (requester_id, addressee_id)
);

create table if not exists public.shop_activity (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  group_id uuid null,
  item_name text not null,
  cost numeric not null default 0,
  created_at timestamptz not null default now()
);

alter table public.friend_requests enable row level security;
alter table public.shop_activity enable row level security;

-- Profiles: allow logged-in users to search basic public profile info.
drop policy if exists "profiles_select_authenticated" on public.profiles;
create policy "profiles_select_authenticated"
on public.profiles
for select
to authenticated
using (true);

-- Friend request policies.
drop policy if exists "friend_requests_select_own" on public.friend_requests;
create policy "friend_requests_select_own"
on public.friend_requests
for select
to authenticated
using (requester_id = auth.uid() or addressee_id = auth.uid());

drop policy if exists "friend_requests_insert_own" on public.friend_requests;
create policy "friend_requests_insert_own"
on public.friend_requests
for insert
to authenticated
with check (requester_id = auth.uid() and requester_id <> addressee_id);

drop policy if exists "friend_requests_update_received" on public.friend_requests;
create policy "friend_requests_update_received"
on public.friend_requests
for update
to authenticated
using (addressee_id = auth.uid())
with check (addressee_id = auth.uid());

-- Shop activity: users can create their own shop activity; friends can view it.
drop policy if exists "shop_activity_insert_own" on public.shop_activity;
create policy "shop_activity_insert_own"
on public.shop_activity
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "shop_activity_select_self_or_friends" on public.shop_activity;
create policy "shop_activity_select_self_or_friends"
on public.shop_activity
for select
to authenticated
using (
  user_id = auth.uid()
  or exists (
    select 1 from public.friend_requests fr
    where fr.status = 'accepted'
      and (
        (fr.requester_id = auth.uid() and fr.addressee_id = shop_activity.user_id)
        or (fr.addressee_id = auth.uid() and fr.requester_id = shop_activity.user_id)
      )
  )
);

-- Optional but useful for duplicate usernames. This does not enforce uniqueness if duplicates already exist.
create index if not exists profiles_username_idx on public.profiles (lower(username));
create index if not exists friend_requests_requester_idx on public.friend_requests (requester_id);
create index if not exists friend_requests_addressee_idx on public.friend_requests (addressee_id);
create index if not exists shop_activity_user_created_idx on public.shop_activity (user_id, created_at desc);
