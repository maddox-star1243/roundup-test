-- Optional safety columns for newer Roundup versions.
-- Run this if you still see schema/cache errors from older deployed code.
alter table public.ou_lines add column if not exists final_count integer;
alter table public.profiles add column if not exists total_realized_pnl numeric default 0;
