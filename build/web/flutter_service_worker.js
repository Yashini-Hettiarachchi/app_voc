'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "17b8146a1838bdbf05c0b21ed58df6e4",
"assets/AssetManifest.bin.json": "23d17b9f1237604ddad1a9ec5342ce47",
"assets/AssetManifest.json": "d587593b9ce5d38938b18a62aaa7e51f",
"assets/assets/audios/faild.mp3": "e4a6ff5f0bc85327ffce35512d719464",
"assets/assets/audios/normal.mp3": "823264ac4a220baea91958d816cfb330",
"assets/assets/audios/puzzle.mp3": "348411c90ef6229ae13d944e7721ac87",
"assets/assets/audios/success.mp3": "fef5693a5a3ec76100c30a7aed3a445d",
"assets/assets/backgrounds/1737431368844.png_image.png": "09be348742a822582cbed180a5ba0895",
"assets/assets/backgrounds/1737431405692.png_image(1).png": "cbcb7aa378828fb94e6cab4446163b09",
"assets/assets/backgrounds/1737431469670.png_image.png": "88d0633842bee31d659371467b410a93",
"assets/assets/backgrounds/1737431584894.png_image.png": "cfb7772faa9ab3bf7de139f81b4d4009",
"assets/assets/backgrounds/a0f2968d033a232f9101305ce73f44a1.jpg": "869584cac4d440f36385873095ad2a25",
"assets/assets/backgrounds/fb3f8dc3b3e13aebe66e9ae3df8362e9.jpg": "56240c279991b102775de3ec1600a372",
"assets/assets/backgrounds/thisisperfect.png": "0788c85e6936edda9b376d34e894b306",
"assets/assets/fonts/font01/ABeeZee-Regular.ttf": "cb714a0b844e87337aef21078fddcecc",
"assets/assets/fonts/font02/Rubik-Italic-VariableFont_wght.ttf": "b98b18526d653e20777cacb1f43f62c4",
"assets/assets/fonts/font02/Rubik-VariableFont_wght.ttf": "6d3102fa33194bef395536d580f91b56",
"assets/assets/icons/bg-icon-cropped.png": "2dd31a3eac446adf0c48f22aa0303e3d",
"assets/assets/icons/bg-icon.png": "5c8a1ac752e7b8925f4a7d774a161551",
"assets/assets/icons/gift.png": "6d4b1dca9bc2357c6bfd2a2807073b12",
"assets/assets/icons/profile.gif": "5229f9f28d79bd487fd627bf26e4bb9f",
"assets/assets/icons/questions.png": "4daf356515a53694fff0cca5009c4a87",
"assets/assets/icons/royal.png": "11d279b5dc16b07b7aaa6cbd88bf8bb6",
"assets/assets/icons/studymore.gif": "ed4003501c91777bab14bfb21f0fb35c",
"assets/assets/icons/toys.png": "aac16b95624576332e534b124e96914b",
"assets/assets/icons/toys2.png": "5436e0de29de4f2dbe2f7eba9f125983",
"assets/assets/icons/tryagain.gif": "81a230c7b15aa13c2b5bd6af968b778e",
"assets/assets/icons/win.gif": "fc4eb16da4f75e761b0b214eda024279",
"assets/assets/icons/win2.gif": "f638dbe53372caeeff5ad4205c00a3e8",
"assets/assets/icons/win3.gif": "e07908e8c46d6d958d1c37d6a231d48a",
"assets/assets/images/back-chat.jpg": "2900b05fec646d7f4193b4f14f7e77b5",
"assets/assets/images/brain.png": "5e39975f9ad126b297914c4c95913a21",
"assets/assets/images/desk/board.jpg": "2315a0ea205628d2c656f594bce358fa",
"assets/assets/images/desk/book-pack.png": "c299b744ee6f0fbd62f2febab97bf8f1",
"assets/assets/images/desk/book1.png": "459c917f7469aae6bf7a515081e01739",
"assets/assets/images/desk/book2.png": "8637f706459fac4dff2b2bef06898239",
"assets/assets/images/desk/desk.jpg": "141eb69b3d4cff32214df23508fef7ce",
"assets/assets/images/desk/eraser1.png": "678565560b12cae3c59d1f69e4028703",
"assets/assets/images/desk/eraser2.png": "6b95c92f89d3c4da69e1ab0a7150175d",
"assets/assets/images/desk/papers.png": "b1c132cb989a41f70bdc8c5b040eb489",
"assets/assets/images/desk/pen1.png": "657f70a8d74f2a12819ed53fb03016ea",
"assets/assets/images/desk/pen2.png": "c5d5f4d45bd45cc62658f38292035dac",
"assets/assets/images/desk/pen4.png": "f17001105a5d2ff1d819865cb1569cc6",
"assets/assets/images/desk/pencil1.png": "dde15eb205b19857477c60c7924d287d",
"assets/assets/images/desk/stick.png": "455841373336d3f032184f4a72fe5df5",
"assets/assets/images/desk/stick2.png": "5f85b2ffff6120837eb05fed0afca548",
"assets/assets/images/desk/wood-desk.jpg": "6fe8930c37907c183ef268b181080a0d",
"assets/assets/images/kitchen/cup.png": "874c78eaae54eb9d432b88436fb33c7d",
"assets/assets/images/kitchen/cutting.png": "bd2af9e77513d8ee4b0ea4fb43591038",
"assets/assets/images/kitchen/fork.png": "db872ab85c852bbd3a7da18ea6110da9",
"assets/assets/images/kitchen/knife.png": "4f49be3844a8bf5b2eebdc2553d172fd",
"assets/assets/images/kitchen/potatoe.png": "0f38c336bb8c64828edd38e3c21ae0d8",
"assets/assets/images/kitchen/spoon.png": "ae15f8f775ca4643014ade96785cee72",
"assets/assets/images/object.png": "ec1fffff2724f805d5514edccf673fe1",
"assets/assets/images/profile.png": "43fa9635e4b2afc49c1355acd38ce121",
"assets/assets/images/puzzle.png": "012d1edde2f440a8722c5cea8484cd5c",
"assets/assets/images/voca.jpg": "fa7ec8e72eb652e0aa6344688be5c859",
"assets/assets/instructions/vocabulary%2520booklet.pdf": "bde7b58d55e5f5ef646f50756bb52c75",
"assets/assets/videos/difference-demo.mp4": "0674edf4eaa7feb21e6c4997e67b7182",
"assets/FontManifest.json": "a81013db07abfca4fcfa8329b93b3d88",
"assets/fonts/MaterialIcons-Regular.otf": "d2761b98d690e8dcab56601c679f756f",
"assets/NOTICES": "34a69ba5e7a12bada155d68539246d62",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "5fda3f1af7d6433d53b24083e2219fa0",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "87325e67bf77a9b483250e1fb1b54677",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "9fa2ffe90a40d062dd2343c7b84caf01",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "f31737fb005cd3a3c6bd9355efd33061",
"flutter_bootstrap.js": "d14dd78b4921812ecd713e9f20bab10c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "c8e5bd2b69c74c6aa8d3832eaad54a00",
"/": "c8e5bd2b69c74c6aa8d3832eaad54a00",
"main.dart.js": "fc40bb21a585d4c0425b172b8954a59d",
"manifest.json": "f55bb5697e7d4178d10bc43722f4d748",
"test.html": "aff53aeb5b961f6c9db972ad7a5947ea",
"version.json": "3db4d3558c0a11dc4942934a8f4524b7"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
