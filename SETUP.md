# MYAZZ Ecommerce — Setup Guide

## 1. Supabase Configuration

Open `js/config.js` and replace the placeholders with your Supabase project credentials:

```js
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key';
```

Get these from your Supabase project dashboard: **Project Settings > API**.

## 2. Database Schema

1. Go to your Supabase project **SQL Editor**.
2. Open `sql/schema.sql` from this project.
3. Copy the entire contents and run it in the SQL Editor.

This creates:
- `profiles` (extends auth.users)
- `categories`
- `products`
- `orders` & `order_items`
- `cart_items`
- Row Level Security (RLS) policies
- Seed data (4 categories + 4 products)
- Admin stats function

## 3. Auth Settings

In Supabase dashboard:
- **Authentication > Providers**: Enable **Email** provider.
- **Authentication > URL Configuration**: Set Site URL to your domain (e.g., `http://localhost:5500` for local dev).

## 4. Make Yourself Admin

After signing up on the website:

1. Go to Supabase **Table Editor > profiles**.
2. Find your user row.
3. Set `is_admin` to `true`.

Now you can access `/admin.html`.

## 5. File Structure

```
myazz/
├── index.html          # Main shop + landing page
├── login.html          # Login page
├── register.html       # Register page
├── admin.html          # Admin dashboard (orders + products)
├── js/
│   ├── config.js       # Supabase credentials
│   ├── supabase-client.js  # Auth helpers
│   └── config.js       # Cart helpers, wilayas, utils
├── sql/
│   └── schema.sql      # Full database schema
├── img/                # Product images & assets
└── *.mp4               # Video assets
```

## 6. Features

### Public
- Browse products by category
- Add to cart (localStorage for guests)
- Checkout (guest or logged-in)
- Auth (register / login / logout)

### Admin Dashboard (`/admin.html`)
- View all orders with status filtering
- Update order status (pending → confirmed → shipped → delivered → cancelled)
- View product catalog
- Activate / deactivate products
- Stats cards (total orders, revenue, pending, products)

### Security
- RLS policies protect all tables
- Orders: users see only their own; admin sees all
- Products: public sees only active products
- Cart: users manage only their own items
- Admin routes are protected client-side

## 7. Local Development

You can serve this with any static server:

```bash
# VS Code Live Server extension
# OR
python3 -m http.server 5500
# OR
npx serve .
```

Then open `http://localhost:5500`.

## 8. Customization

- Add more products in Supabase **Table Editor > products**
- Add more categories in **Table Editor > categories**
- Upload product images to Supabase Storage and update `image_url` fields
- Customize colors in CSS `:root` variables

## 9. MCP

If you have Supabase MCP configured, you can also manage the database through your AI assistant using the schema provided.
