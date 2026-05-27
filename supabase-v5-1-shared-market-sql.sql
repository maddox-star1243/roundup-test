
-- Roundup V5.1 shared market fix
-- Run this in Supabase SQL Editor.

-- 1) Make sure there is only one shared row per drink.
-- If you have accidental duplicates, this keeps the newest row by ctid.
delete from public.drink_stocks a
using public.drink_stocks b
where a.drink_name = b.drink_name
  and a.ctid < b.ctid;

create unique index if not exists drink_stocks_drink_name_unique
on public.drink_stocks (drink_name);

alter table public.drink_stocks enable row level security;

drop policy if exists "drink_stocks_select_authenticated" on public.drink_stocks;
create policy "drink_stocks_select_authenticated"
on public.drink_stocks
for select
to authenticated
using (true);

drop policy if exists "drink_stocks_insert_authenticated" on public.drink_stocks;
create policy "drink_stocks_insert_authenticated"
on public.drink_stocks
for insert
to authenticated
with check (true);

drop policy if exists "drink_stocks_update_authenticated" on public.drink_stocks;
create policy "drink_stocks_update_authenticated"
on public.drink_stocks
for update
to authenticated
using (true)
with check (true);

-- 2) Shared tick table: this is what makes every user's chart show the same history.
create table if not exists public.stock_ticks (
  id uuid primary key default gen_random_uuid(),
  drink_name text not null,
  price numeric not null,
  prev_price numeric not null,
  move numeric not null default 0,
  event_type text not null default 'sync',
  actor_id uuid,
  activity_summary text,
  created_at timestamptz not null default now()
);

create index if not exists stock_ticks_drink_created_idx
on public.stock_ticks (drink_name, created_at desc);

alter table public.stock_ticks enable row level security;

drop policy if exists "stock_ticks_select_authenticated" on public.stock_ticks;
create policy "stock_ticks_select_authenticated"
on public.stock_ticks
for select
to authenticated
using (true);

drop policy if exists "stock_ticks_insert_authenticated" on public.stock_ticks;
create policy "stock_ticks_insert_authenticated"
on public.stock_ticks
for insert
to authenticated
with check (auth.uid() = actor_id or actor_id is null);

-- 3) Allow Supabase Realtime if available. Polling still works if this fails.
do $$
begin
  alter publication supabase_realtime add table public.drink_stocks;
exception
  when duplicate_object then null;
  when undefined_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.stock_ticks;
exception
  when duplicate_object then null;
  when undefined_object then null;
end $$;
