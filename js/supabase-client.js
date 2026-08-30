// MYAZZ Supabase Client — Version robuste avec retry et validation
// Chargée APRÈS : 1) CDN Supabase  2) config.js

// The CDN also exposes `window.supabase`; never redeclare that global name.
window.MYAZZ = window.MYAZZ || {};
var myazzSupabaseClient = window.MYAZZ.client || null;

function initSupabase() {
  if (typeof window === 'undefined') {
    console.error('[MYAZZ] initSupabase: window non disponible');
    return null;
  }
  // Si déjà initialisé, retourner l'instance
  if (myazzSupabaseClient) return myazzSupabaseClient;

  // Vérifier que la librairie CDN est présente
  if (!window.supabase) {
    console.error('[MYAZZ] initSupabase: window.supabase absent. La librairie CDN n\'est pas chargée. Vérifiez que le script https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js est bien dans le <head> et qu\'aucun bloqueur ne le bloque.');
    return null;
  }
  if (!window.supabase.createClient) {
    console.error('[MYAZZ] initSupabase: window.supabase.createClient absent. Version incompatible de la librairie.');
    return null;
  }

  // Vérifier que les credentials sont définis dans config.js
  if (typeof SUPABASE_URL === 'undefined' || typeof SUPABASE_ANON_KEY === 'undefined') {
    console.error('[MYAZZ] initSupabase: SUPABASE_URL ou SUPABASE_ANON_KEY non définis. Vérifiez que js/config.js est bien chargé AVANT js/supabase-client.js.');
    return null;
  }
  if (!SUPABASE_URL || SUPABASE_URL === 'https://your-project.supabase.co') {
    console.error('[MYAZZ] initSupabase: SUPABASE_URL non configuré. Mettez à jour js/config.js avec votre URL Supabase.');
    return null;
  }
  if (!SUPABASE_ANON_KEY || SUPABASE_ANON_KEY === 'your-anon-key') {
    console.error('[MYAZZ] initSupabase: SUPABASE_ANON_KEY non configuré. Mettez à jour js/config.js avec votre clé anon.');
    return null;
  }

  try {
    myazzSupabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    window.MYAZZ.client = myazzSupabaseClient;
    console.log('[MYAZZ] Supabase client initialisé avec succès');
    return myazzSupabaseClient;
  } catch (e) {
    console.error('[MYAZZ] initSupabase: Erreur lors de la création du client:', e);
    return null;
  }
}

/* ---- Attendre que Supabase soit prêt (retry) ---- */
function waitForSupabase(maxRetries, callback) {
  var attempt = 0;
  function tryInit() {
    attempt++;
    var client = initSupabase();
    if (client) {
      callback(null, client);
      return;
    }
    if (attempt < maxRetries) {
      setTimeout(tryInit, 250);
    } else {
      var err = new Error('Impossible de se connecter au service. Vérifiez votre connexion internet ou ouvrez la console (F12) pour plus de détails.');
      callback(err, null);
    }
  }
  tryInit();
}

// Explicit exports keep the API available even if another script uses a module scope.
window.initSupabase = initSupabase;
window.waitForSupabase = waitForSupabase;
window.getCurrentUser = getCurrentUser;
window.getUserProfile = getUserProfile;
window.requireAuth = requireAuth;
window.requireAdmin = requireAdmin;

async function getCurrentUser() {
  var client = initSupabase();
  if (!client) return null;
  try {
    var res = await client.auth.getUser();
    if (res.error || !res.data.user) return null;
    return res.data.user;
  } catch (e) {
    console.error('[MYAZZ] getCurrentUser error:', e);
    return null;
  }
}

async function getUserProfile() {
  var client = initSupabase();
  var user = await getCurrentUser();
  if (!user) return null;
  try {
    var res = await client.from('profiles').select('*').eq('id', user.id).single();
    if (res.error) return null;
    return res.data;
  } catch (e) {
    console.error('[MYAZZ] getUserProfile error:', e);
    return null;
  }
}

async function requireAuth() {
  var user = await getCurrentUser();
  if (!user) {
    window.location.href = 'login.html?redirect=' + encodeURIComponent(window.location.pathname + window.location.search);
    return null;
  }
  return user;
}

async function requireAdmin() {
  var client = initSupabase();
  var user = await requireAuth();
  if (!user) return null;
  try {
    var res = await client.from('profiles').select('is_admin').eq('id', user.id).single();
    if (!res.data || !res.data.is_admin) {
      window.location.href = 'index.html';
      return null;
    }
    return user;
  } catch (e) {
    console.error('[MYAZZ] requireAdmin error:', e);
    window.location.href = 'index.html';
    return null;
  }
}
