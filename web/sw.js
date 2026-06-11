const CACHE_NAME = 'strmflwpr-pwa-v1';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './web/icons/Icon-192.png',
  './web/icons/Icon-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS);
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
