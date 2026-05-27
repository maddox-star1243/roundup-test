# Roundup PWA Test Build

This folder is ready to upload to GitHub Pages or Cloudflare Pages.

Files included:
- index.html — your app file with PWA tags added
- manifest.json — app install metadata
- service-worker.js — makes the site installable and caches the app shell
- icon-192.png and icon-512.png — placeholder app icons

Free publish option: GitHub Pages
1. Create a new GitHub repository, for example `roundup-test`.
2. Upload every file in this folder to the root of the repository.
3. In GitHub, open Settings > Pages.
4. Set Source to "Deploy from a branch".
5. Select branch `main` and folder `/root`, then Save.
6. Wait for GitHub to show the public Pages URL.
7. Open the URL on your phone and use Share > Add to Home Screen.

Supabase reminder:
- Keep Supabase on the Free plan.
- Add your final GitHub Pages URL in Supabase Authentication URL settings if email confirmation or redirects are used.
- Make sure your database tables and Row Level Security policies allow the app actions your friends need.
