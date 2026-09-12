-- Monee cloud database
-- Run this entire script in Supabase Dashboard -> SQL Editor.

create table if not exists public.entries (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('expense','income')),
  description text not null,
  amount numeric(14,2) not null check (amount > 0),
  category text not null,
  date date not null,
  created_at timestamptz not null default now()
);

create table if not exists public.categories (
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('expense','income')),
  names jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, type)
);

alter table public.entries enable row level security;
alter table public.categories enable row level security;

drop policy if exists "Users can view their entries" on public.entries;
drop policy if exists "Users can insert their entries" on public.entries;
drop policy if exists "Users can update their entries" on public.entries;
drop policy if exists "Users can delete their entries" on public.entries;

create policy "Users can view their entries" on public.entries for select using (auth.uid() = user_id);
create policy "Users can insert their entries" on public.entries for insert with check (auth.uid() = user_id);
create policy "Users can update their entries" on public.entries for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can delete their entries" on public.entries for delete using (auth.uid() = user_id);

drop policy if exists "Users can view their categories" on public.categories;
drop policy if exists "Users can insert their categories" on public.categories;
drop policy if exists "Users can update their categories" on public.categories;
drop policy if exists "Users can delete their categories" on public.categories;

create policy "Users can view their categories" on public.categories for select using (auth.uid() = user_id);
create policy "Users can insert their categories" on public.categories for insert with check (auth.uid() = user_id);
create policy "Users can update their categories" on public.categories for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can delete their categories" on public.categories for delete using (auth.uid() = user_id);

create index if not exists entries_user_date_idx on public.entries(user_id, date desc);
