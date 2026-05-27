-- Roundup V4.7 shared market policies
-- Run this in Supabase SQL Editor if one account's stock purchase does not update other accounts.

alter table public.drink_stocks enable row level security;

create policy if not exists "drink_stocks_select_authenticated"
on public.drink_stocks for select
to authenticated
using (true);

create policy if not exists "drink_stocks_insert_authenticated"
on public.drink_stocks for insert
to authenticated
with check (true);

create policy if not exists "drink_stocks_update_authenticated"
on public.drink_stocks for update
to authenticated
using (true)
with check (true);

-- Optional but recommended: allow users to read group member stock holdings if your app displays group portfolios.
alter table public.stock_holdings enable row level security;

create policy if not exists "stock_holdings_select_authenticated"
on public.stock_holdings for select
to authenticated
using (true);

create policy if not exists "stock_holdings_insert_own"
on public.stock_holdings for insert
to authenticated
with check (auth.uid() = user_id);

create policy if not exists "stock_holdings_update_own"
on public.stock_holdings for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
