
-- Roundup V5 Connected League Economy SQL
-- Run this in Supabase SQL Editor. It is safe to rerun.

alter table public.profiles add column if not exists total_realized_pnl numeric default 0;
alter table public.groups add column if not exists join_passcode text;
alter table public.groups add column if not exists active_week integer default 1;
alter table public.groups add column if not exists casino_enabled boolean default true;
alter table public.groups add column if not exists stock_market_enabled boolean default true;

create table if not exists public.activity_events (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references public.groups(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  event_type text not null,
  title text,
  body text,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create table if not exists public.coin_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  group_id uuid references public.groups(id) on delete set null,
  kind text not null,
  amount numeric not null default 0,
  description text,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

create table if not exists public.tonight_sessions (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references public.groups(id) on delete cascade,
  name text default 'Tonight',
  started_by uuid references public.profiles(id) on delete set null,
  is_active boolean default true,
  created_at timestamptz default now(),
  ended_at timestamptz
);

create table if not exists public.fantasy_weeks (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references public.groups(id) on delete cascade,
  week_number integer not null,
  starts_at timestamptz default now(),
  ends_at timestamptz,
  is_active boolean default true,
  created_at timestamptz default now(),
  unique(group_id, week_number)
);

create table if not exists public.fantasy_matchups (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references public.groups(id) on delete cascade,
  week_number integer not null,
  player_a uuid references public.profiles(id) on delete cascade,
  player_b uuid references public.profiles(id) on delete cascade,
  score_a numeric default 0,
  score_b numeric default 0,
  winner_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz default now()
);

create table if not exists public.reward_purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  group_id uuid references public.groups(id) on delete set null,
  reward_name text not null,
  cost numeric not null default 0,
  status text default 'active',
  created_at timestamptz default now()
);

alter table public.activity_events enable row level security;
alter table public.coin_transactions enable row level security;
alter table public.tonight_sessions enable row level security;
alter table public.fantasy_weeks enable row level security;
alter table public.fantasy_matchups enable row level security;
alter table public.reward_purchases enable row level security;

-- Activity/events: group members can view, authenticated users can create events for groups they belong to.
drop policy if exists "activity_events_select_group_members" on public.activity_events;
create policy "activity_events_select_group_members" on public.activity_events for select to authenticated using (
  exists (select 1 from public.group_members gm where gm.group_id = activity_events.group_id and gm.user_id = auth.uid())
);
drop policy if exists "activity_events_insert_members" on public.activity_events;
create policy "activity_events_insert_members" on public.activity_events for insert to authenticated with check (
  actor_id = auth.uid() and exists (select 1 from public.group_members gm where gm.group_id = activity_events.group_id and gm.user_id = auth.uid())
);

-- Coin transactions: users can see their own; group members can see group feed transactions.
drop policy if exists "coin_transactions_select_relevant" on public.coin_transactions;
create policy "coin_transactions_select_relevant" on public.coin_transactions for select to authenticated using (
  user_id = auth.uid() or exists (select 1 from public.group_members gm where gm.group_id = coin_transactions.group_id and gm.user_id = auth.uid())
);
drop policy if exists "coin_transactions_insert_own" on public.coin_transactions;
create policy "coin_transactions_insert_own" on public.coin_transactions for insert to authenticated with check (user_id = auth.uid());

-- Tonight sessions and fantasy schedule: group members can view; group creators can create/update.
drop policy if exists "tonight_sessions_select_group_members" on public.tonight_sessions;
create policy "tonight_sessions_select_group_members" on public.tonight_sessions for select to authenticated using (
  exists (select 1 from public.group_members gm where gm.group_id = tonight_sessions.group_id and gm.user_id = auth.uid())
);
drop policy if exists "tonight_sessions_insert_group_members" on public.tonight_sessions;
create policy "tonight_sessions_insert_group_members" on public.tonight_sessions for insert to authenticated with check (
  started_by = auth.uid() and exists (select 1 from public.group_members gm where gm.group_id = tonight_sessions.group_id and gm.user_id = auth.uid())
);
drop policy if exists "tonight_sessions_update_group_members" on public.tonight_sessions;
create policy "tonight_sessions_update_group_members" on public.tonight_sessions for update to authenticated using (
  exists (select 1 from public.group_members gm where gm.group_id = tonight_sessions.group_id and gm.user_id = auth.uid())
) with check (true);

-- Broad read for weekly fantasy objects inside a group.
drop policy if exists "fantasy_weeks_select_group_members" on public.fantasy_weeks;
create policy "fantasy_weeks_select_group_members" on public.fantasy_weeks for select to authenticated using (
  exists (select 1 from public.group_members gm where gm.group_id = fantasy_weeks.group_id and gm.user_id = auth.uid())
);
drop policy if exists "fantasy_matchups_select_group_members" on public.fantasy_matchups;
create policy "fantasy_matchups_select_group_members" on public.fantasy_matchups for select to authenticated using (
  exists (select 1 from public.group_members gm where gm.group_id = fantasy_matchups.group_id and gm.user_id = auth.uid())
);
drop policy if exists "reward_purchases_select_relevant" on public.reward_purchases;
create policy "reward_purchases_select_relevant" on public.reward_purchases for select to authenticated using (
  user_id = auth.uid() or exists (select 1 from public.group_members gm where gm.group_id = reward_purchases.group_id and gm.user_id = auth.uid())
);
drop policy if exists "reward_purchases_insert_own" on public.reward_purchases;
create policy "reward_purchases_insert_own" on public.reward_purchases for insert to authenticated with check (user_id = auth.uid());
