-- Fix for: infinite recursion detected in policy for relation "profiles"
-- Run once in Supabase SQL Editor.

-- This function runs with its owner's privileges, so its lookup of profiles
-- does not invoke the profiles RLS policies again.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid() and is_admin = true
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- Remove policies whose EXISTS (SELECT ... FROM profiles) caused recursion.
drop policy if exists "Admin can update any profile" on public.profiles;
drop policy if exists "Only admin can modify categories" on public.categories;
drop policy if exists "Admin can view all products" on public.products;
drop policy if exists "Only admin can modify products" on public.products;
drop policy if exists "Admin can view all orders" on public.orders;
drop policy if exists "Admin can update orders" on public.orders;
drop policy if exists "Admin can view all order items" on public.order_items;

create policy "Admin can update any profile"
on public.profiles for update
using (public.is_admin())
with check (public.is_admin());

create policy "Only admin can modify categories"
on public.categories for all
using (public.is_admin())
with check (public.is_admin());

create policy "Admin can view all products"
on public.products for select
using (public.is_admin());

create policy "Only admin can modify products"
on public.products for all
using (public.is_admin())
with check (public.is_admin());

create policy "Admin can view all orders"
on public.orders for select
using (public.is_admin());

create policy "Admin can update orders"
on public.orders for update
using (public.is_admin())
with check (public.is_admin());

create policy "Admin can view all order items"
on public.order_items for select
using (public.is_admin());
