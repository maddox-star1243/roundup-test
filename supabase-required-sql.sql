-- Required for optional group passcodes in this version
alter table public.groups
add column if not exists join_passcode text;

-- Optional but recommended: only expose passcodes to users who know the invite code through the app flow.
-- This test app stores passcodes as plain text, which is okay for friend testing, not production security.
