// MYAZZ Supabase Client
// Uses CDN: https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js

let supabase = null;

function initSupabase() {
  if (typeof window === 'undefined') return null;
  if (supabase) return supabase;
  if (!window.supabase || !window.supabase.createClient) {
    console.error('Supabase library not loaded');
    return null;
  }
  supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  return supabase;
}

async function getCurrentUser() {
  const client = initSupabase();
  if (!client) return null;
  const { data, error } = await client.auth.getUser();
  if (error || !data.user) return null;
  return data.user;
}

async function getUserProfile() {
  const client = initSupabase();
  const user = await getCurrentUser();
  if (!user) return null;
  const { data, error } = await client.from('profiles').select('*').eq('id', user.id).single();
  if (error) return null;
  return data;
}

async function requireAuth() {
  const user = await getCurrentUser();
  if (!user) {
    window.location.href = 'login.html?redirect=' + encodeURIComponent(window.location.pathname + window.location.search);
    return null;
  }
  return user;
}

async function requireAdmin() {
  const client = initSupabase();
  const user = await requireAuth();
  if (!user) return null;
  const { data } = await client.from('profiles').select('is_admin').eq('id', user.id).single();
  if (!data?.is_admin) {
    window.location.href = 'index.html';
    return null;
  }
  return user;
}
