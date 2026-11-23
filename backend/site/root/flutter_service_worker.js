// Retires the service worker the old app registered at the site root: on its next update check the browser
// installs this, which deletes every cache, unregisters itself and reloads the open tabs, so they fetch the
// page fresh from the network (the old address forwards it to the new one). It answers no requests.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (e) => e.waitUntil((async () => {
  for (const k of await caches.keys()) await caches.delete(k);
  await self.registration.unregister();
  for (const c of await self.clients.matchAll({ type: 'window' })) c.navigate(c.url);
})()));
