# Déployer MYAZZ sur Vercel — Guide étape par étape

Votre site MYAZZ est un site **statique pur** (HTML/CSS/JS vanilla), ce qui le rend très simple à déployer sur Vercel.

---

## Option A : Via GitHub (recommandé — mises à jour auto)

### Étape 1 : Créer un dépôt GitHub

1. Allez sur [github.com/new](https://github.com/new)
2. Nom du repo : `myazz-ecommerce` (ou ce que vous voulez)
3. **Ne cochez PAS** "Initialize this repository with a README" (on en a déjà un)
4. Cliquez **Create repository**

### Étape 2 : Pousser votre code sur GitHub

Ouvrez un terminal dans le dossier `/home/raouf/myazz` (ou votre dossier local) et exécutez :

```bash
git init
git add .
git commit -m "Initial commit — MYAZZ ecommerce"
git branch -M main
git remote add origin https://github.com/VOTRE_USERNAME/myazz-ecommerce.git
git push -u origin main
```

> Remplacez `VOTRE_USERNAME` par votre nom d'utilisateur GitHub.

### Étape 3 : Connecter Vercel

1. Allez sur [vercel.com](https://vercel.com) et connectez-vous avec votre compte GitHub
2. Cliquez sur **"Add New Project"**
3. Dans la liste, trouvez et sélectionnez votre repo `myazz-ecommerce`
4. Cliquez sur **"Import"**

### Étape 4 : Configurer le déploiement

Sur la page de configuration :

| Paramètre | Valeur |
|---|---|
| **Framework Preset** | Laissez `Other` (Vercel détecte automatiquement un site statique) |
| **Root Directory** | `./` (laissez par défaut) |
| **Build Command** | Laissez vide (pas besoin de build pour HTML statique) |
| **Output Directory** | Laissez vide |

> **Ne touchez pas aux autres paramètres.**

Cliquez sur **"Deploy"**.

### Étape 5 : Récupérer l'URL

Après ~30 secondes, Vercel affiche :

```
🎉  Congratulations! Your site is live at:
    https://myazz-ecommerce-XXXX.vercel.app
```

Cliquez sur l'URL — votre boutique MYAZZ est en ligne !

### Étape 6 : Mettre à jour le site

À chaque modification locale :

```bash
git add .
git commit -m "description de la modif"
git push origin main
```

Vercel redéploie automatiquement en quelques secondes.

---

## Option B : Upload direct (sans Git — pour tester rapidement)

1. Compressez votre dossier `myazz` en `.zip`
2. Allez sur [vercel.com/new](https://vercel.com/new)
3. Cliquez sur **"Import Git Repository"** puis cherchez le lien **"...or upload a directory"**
4. Glissez-déposez votre fichier `.zip`
5. Vercel déploie instantanément et vous donne l'URL

> ⚠️ Cette méthode ne permet pas les mises à jour automatiques. Pour chaque changement, vous devez re-uploader.

---

## Option C : CLI Vercel (pour les utilisateurs avancés)

Installez le CLI Vercel :

```bash
npm i -g vercel
```

Dans votre dossier `myazz` :

```bash
vercel
```

Répondez aux questions :
- **Set up "~/myazz"?** → `Y`
- **Which scope?** → Sélectionnez votre compte
- **Link to existing project?** → `N` (créer un nouveau)
- **What's your project name?** → `myazz-ecommerce`
- **In which directory is your code located?** → `./` (appuyez sur Entrée)

Vercel déploie et vous donne l'URL immédiatement.

Pour les prochains déploiements :

```bash
vercel --prod
```

---

## Configuration importante après déploiement

### 1. Mettre à jour l'URL Supabase Auth

Dans votre dashboard Supabase :
- **Authentication → URL Configuration**
- **Site URL** : mettez votre URL Vercel, par exemple :
  ```
  https://myazz-ecommerce-XXXX.vercel.app
  ```
- **Redirect URLs** : ajoutez aussi :
  ```
  https://myazz-ecommerce-XXXX.vercel.app/login.html
  https://myazz-ecommerce-XXXX.vercel.app/admin.html
  ```

> Sans cette étape, la redirection après connexion/inscription ne fonctionnera pas correctement.

### 2. Vérifier le fonctionnement

Testez ces pages sur votre URL Vercel :
- ✅ `https://votre-url.vercel.app/` → Boutique
- ✅ `https://votre-url.vercel.app/login.html` → Connexion
- ✅ `https://votre-url.vercel.app/register.html` → Inscription
- ✅ `https://votre-url.vercel.app/admin.html` → Admin (après avoir activé `is_admin`)

---

## Ajouter un domaine personnalisé (optionnel)

1. Dans le dashboard Vercel de votre projet, allez dans **Settings → Domains**
2. Entrez votre domaine (ex: `myazz.com`)
3. Suivez les instructions DNS fournies par Vercel
4. Dans Supabase **Authentication → URL Configuration**, remplacez l'URL Vercel par votre domaine perso

---

## Récapitulatif des fichiers déployés

```
myazz/
├── index.html          ✅
├── login.html          ✅
├── register.html       ✅
├── admin.html          ✅
├── js/
│   ├── config.js       ✅
│   └── supabase-client.js  ✅
├── sql/
│   └── schema.sql      ✅ (fichier de référence, pas déployé)
├── img/                ✅ (toutes vos images)
└── *.mp4               ✅ (vidéos)
```

Votre site est prêt pour la production ! 🚀
