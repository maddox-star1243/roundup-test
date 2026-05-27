-- Roundup V5.6: Friend Challenge Shop
-- Run in Supabase SQL Editor after prior V5/V5.5 SQL files.

create table if not exists public.friend_challenges (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references auth.users(id) on delete cascade,
  target_id uuid not null references auth.users(id) on delete cascade,
  group_id uuid null,
  item_key text,
  item_name text not null,
  description text,
  cost numeric not null default 0,
  status text not null default 'pending' check (status in ('pending','accepted','declined','completed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz null
);

alter table public.friend_challenges enable row level security;

-- Users can view challenges they sent/received. Friends can also view completed/accepted challenges as activity context.
drop policy if exists "friend_challenges_select_relevant" on public.friend_challenges;
create policy "friend_challenges_select_relevant"
on public.friend_challenges
for select
to authenticated
using (
  sender_id = auth.uid()
  or target_id = auth.uid()
  or exists (
    select 1 from public.friend_requests fr
    where fr.status = 'accepted'
      and (
        (fr.requester_id = auth.uid() and (fr.addressee_id = friend_challenges.sender_id or fr.addressee_id = friend_challenges.target_id))
        or (fr.addressee_id = auth.uid() and (fr.requester_id = friend_challenges.sender_id or fr.requester_id = friend_challenges.target_id))
      )
  )
);

-- You can send challenges only as yourself to an accepted friend.
drop policy if exists "friend_challenges_insert_to_friend" on public.friend_challenges;
create policy "friend_challenges_insert_to_friend"
on public.friend_challenges
for insert
to authenticated
with check (
  sender_id = auth.uid()
  and sender_id <> target_id
  and exists (
    select 1 from public.friend_requests fr
    where fr.status = 'accepted'
      and (
        (fr.requester_id = auth.uid() and fr.addressee_id = friend_challenges.target_id)
        or (fr.addressee_id = auth.uid() and fr.requester_id = friend_challenges.target_id)
      )
  )
);

-- Only the target can accept/decline/complete a challenge.
drop policy if exists "friend_challenges_target_update" on public.friend_challenges;
create policy "friend_challenges_target_update"
on public.friend_challenges
for update
to authenticated
using (target_id = auth.uid())
with check (target_id = auth.uid());

create index if not exists friend_challenges_sender_idx on public.friend_challenges (sender_id, created_at desc);
create index if not exists friend_challenges_target_idx on public.friend_challenges (target_id, created_at desc);
create index if not exists friend_challenges_group_idx on public.friend_challenges (group_id, created_at desc);
