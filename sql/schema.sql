-- MYAZZ Ecommerce Supabase Schema
-- Run this in your Supabase SQL Editor

-- ============================================
-- 1. PROFILES (extends auth.users)
-- ============================================
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text,
  phone text,
  wilaya text,
  is_admin boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Trigger to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 2. CATEGORIES
-- ============================================
create table if not exists public.categories (
  id serial primary key,
  name text not null,
  slug text unique not null,
  image_url text,
  description text,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- ============================================
-- 3. PRODUCTS
-- ============================================
create table if not exists public.products (
  id serial primary key,
  name text not null,
  slug text unique not null,
  description text,
  price integer not null, -- price in cents/DA (store as integer to avoid float issues)
  compare_price integer, -- original price for discounts
  image_url text,
  images text[], -- additional images
  category_id int references public.categories(id) on delete set null,
  stock int default 0,
  sku text,
  featured boolean default false,
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================
-- 4. ORDERS
-- ============================================
create type order_status as enum ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled');

create table if not exists public.orders (
  id serial primary key,
  user_id uuid references public.profiles(id) on delete set null,
  status order_status default 'pending',
  full_name text not null,
  phone text not null,
  wilaya text not null,
  address text,
  notes text,
  total_amount integer not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================
-- 5. ORDER ITEMS
-- ============================================
create table if not exists public.order_items (
  id serial primary key,
  order_id int references public.orders(id) on delete cascade,
  product_id int references public.products(id) on delete set null,
  product_name text not null,
  price integer not null, -- price at time of order
  quantity int not null default 1
);

-- ============================================
-- 6. CART ITEMS (for logged-in users)
-- ============================================
create table if not exists public.cart_items (
  id serial primary key,
  user_id uuid references public.profiles(id) on delete cascade,
  product_id int references public.products(id) on delete cascade,
  quantity int not null default 1,
  created_at timestamptz default now(),
  unique(user_id, product_id)
);

-- ============================================
-- RLS POLICIES
-- ============================================

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.cart_items enable row level security;

-- PROFILES
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admin can update any profile" ON public.profiles
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

-- CATEGORIES
CREATE POLICY "Categories are viewable by everyone" ON public.categories
  FOR SELECT USING (true);

CREATE POLICY "Only admin can modify categories" ON public.categories
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

-- PRODUCTS
CREATE POLICY "Active products are viewable by everyone" ON public.products
  FOR SELECT USING (active = true);

CREATE POLICY "Admin can view all products" ON public.products
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

CREATE POLICY "Only admin can modify products" ON public.products
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

-- ORDERS
CREATE POLICY "Users can view own orders" ON public.orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admin can view all orders" ON public.orders
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

CREATE POLICY "Admin can update orders" ON public.orders
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

CREATE POLICY "Anyone can insert orders (guest checkout)" ON public.orders
  FOR INSERT WITH CHECK (true);

-- ORDER ITEMS
CREATE POLICY "Users can view own order items" ON public.order_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.orders WHERE id = order_items.order_id AND user_id = auth.uid())
  );

CREATE POLICY "Admin can view all order items" ON public.order_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );

CREATE POLICY "Anyone can insert order items" ON public.order_items
  FOR INSERT WITH CHECK (true);

-- CART ITEMS
CREATE POLICY "Users can CRUD own cart" ON public.cart_items
  FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- SEED DATA
-- ============================================
INSERT INTO public.categories (name, slug, image_url, description, sort_order)
VALUES
  ('Montres connectées', 'montres', 'img/WhatsApp_Image_2026-07-23_at_12.57.38-removebg-preview.png', 'Précision et élégance au poignet', 1),
  ('Casques audio', 'casques', 'img/WhatsApp_Image_2026-07-01_at_11.02.39__1_-removebg-preview.png', 'Immersion sonore d''exception', 2),
  ('Écouteurs', 'ecouteurs', null, 'Liberté sans fil', 3),
  ('Enceintes', 'enceintes', null, 'Puissance et clarté', 4)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.products (name, slug, description, price, image_url, category_id, stock, sku, featured, active)
VALUES
  ('MYAZZ PULSE', 'myazz-pulse', 'Écran AMOLED, autonomie 6 jours, boîtier aluminium aéronautique.', 12500, 'img/WhatsApp_Image_2026-07-23_at_12.57.38-removebg-preview.png', 1, 50, 'MYZ-PULSE-001', true, true),
  ('MYAZZ PULSE Pro', 'myazz-pulse-pro', 'Écran AMOLED always-on, autonomie 10 jours, GPS intégré, boîtier titane.', 18500, 'img/WhatsApp_Image_2026-07-01_at_11.02.39__1_-removebg-preview.png', 1, 30, 'MYZ-PULSE-002', true, true),
  ('MYAZZ Sound One', 'myazz-sound-one', 'Casque sans fil à réduction de bruit active, 30h d''autonomie.', 15500, null, 2, 25, 'MYZ-SND-001', false, true),
  ('MYAZZ Buds Air', 'myazz-buds-air', 'Écouteurs true wireless, réduction de bruit, étanchéité IPX4.', 8500, null, 3, 40, 'MYZ-BUDS-001', false, true)
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to get order summary for admin dashboard
CREATE OR REPLACE FUNCTION public.get_admin_stats()
RETURNS TABLE (
  total_orders bigint,
  total_revenue bigint,
  pending_orders bigint,
  total_products bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    (SELECT count(*) FROM public.orders),
    (SELECT COALESCE(sum(total_amount), 0) FROM public.orders WHERE status != 'cancelled'),
    (SELECT count(*) FROM public.orders WHERE status = 'pending'),
    (SELECT count(*) FROM public.products);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant access to authenticated users (admin check done in app layer or via RLS on underlying tables)
GRANT EXECUTE ON FUNCTION public.get_admin_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_stats() TO anon;
