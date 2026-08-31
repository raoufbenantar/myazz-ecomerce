// MYAZZ Supabase Configuration
const SUPABASE_URL = 'https://qjqjlbxociboxrmrhaig.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_wOEIvlTdJarILKE95dYoEQ_Vactzei8';

// Admin check helper
async function isAdmin(supabase) {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return false;
  const { data } = await supabase.from('profiles').select('is_admin').eq('id', user.id).single();
  return data?.is_admin === true;
}

// Format price in Algerian Dinar
function formatPrice(value) {
  if (value == null) return '0 DA';
  return value.toLocaleString('fr-FR') + ' DA';
}

// Cart helpers (localStorage for guests)
const CART_KEY = 'myazz_cart';

function getLocalCart() {
  try {
    return JSON.parse(localStorage.getItem(CART_KEY)) || [];
  } catch {
    return [];
  }
}

function setLocalCart(cart) {
  localStorage.setItem(CART_KEY, JSON.stringify(cart));
}

function addToLocalCart(product, qty = 1) {
  const cart = getLocalCart();
  const existing = cart.find(item => String(item.product_id) === String(product.id));
  if (existing) {
    existing.quantity += qty;
  } else {
    cart.push({
      product_id: product.id,
      name: product.name,
      price: product.price,
      image_url: product.image_url,
      quantity: qty
    });
  }
  setLocalCart(cart);
  window.dispatchEvent(new Event('cart-updated'));
}

function removeFromLocalCart(productId) {
  const cart = getLocalCart().filter(item => String(item.product_id) !== String(productId));
  setLocalCart(cart);
  window.dispatchEvent(new Event('cart-updated'));
}

function updateLocalCartQty(productId, qty) {
  const cart = getLocalCart();
  const item = cart.find(i => String(i.product_id) === String(productId));
  if (item) {
    if (qty <= 0) {
      removeFromLocalCart(productId);
      return;
    }
    item.quantity = qty;
    setLocalCart(cart);
    window.dispatchEvent(new Event('cart-updated'));
  }
}

function getCartTotal() {
  return getLocalCart().reduce((sum, item) => sum + (item.price * item.quantity), 0);
}

function getCartCount() {
  return getLocalCart().reduce((sum, item) => sum + item.quantity, 0);
}

// Wilayas list (Algeria)
const WILAYAS = [
  "01 - Adrar", "02 - Chlef", "03 - Laghouat", "04 - Oum El Bouaghi", "05 - Batna",
  "06 - Béjaïa", "07 - Biskra", "08 - Béchar", "09 - Blida", "10 - Bouira",
  "11 - Tamanrasset", "12 - Tébessa", "13 - Tlemcen", "14 - Tiaret", "15 - Tizi Ouzou",
  "16 - Alger", "17 - Djelfa", "18 - Jijel", "19 - Sétif", "20 - Saïda",
  "21 - Skikda", "22 - Sidi Bel Abbès", "23 - Annaba", "24 - Guelma", "25 - Constantine",
  "26 - Médéa", "27 - Mostaganem", "28 - M'Sila", "29 - Mascara", "30 - Ouargla",
  "31 - Oran", "32 - El Bayadh", "33 - Illizi", "34 - Bordj Bou Arréridj", "35 - Boumerdès",
  "36 - El Tarf", "37 - Tindouf", "38 - Tissemsilt", "39 - El Oued", "40 - Khenchela",
  "41 - Souk Ahras", "42 - Tipaza", "43 - Mila", "44 - Aïn Defla", "45 - Naâma",
  "46 - Aïn Témouchent", "47 - Ghardaïa", "48 - Relizane", "49 - Timimoun", "50 - Bordj Badji Mokhtar",
  "51 - Ouled Djellal", "52 - Béni Abbès", "53 - In Salah", "54 - In Guezzam", "55 - Touggourt",
  "56 - Djanet", "57 - El M'Ghair", "58 - El Meniaa"
];
