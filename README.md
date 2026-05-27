# Roundup V3 League — No-Cache Test Build

This build is meant for testing on GitHub Pages. It disables/unregisters the service worker and clears browser caches so login/UI updates do not get stuck behind an old PWA cache.

Upload the files inside this folder to GitHub, not the ZIP itself.

After uploading, open the site and do a hard refresh. If the old version still appears, use Chrome DevTools → Application → Service Workers → Unregister, then Storage → Clear site data.
