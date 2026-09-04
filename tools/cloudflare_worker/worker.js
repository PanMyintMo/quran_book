/**
 * Free Firebase proxy for Cloudflare Workers (no monthly trial limit).
 *
 * Deploy:
 * 1. https://workers.cloudflare.com → Create Worker
 * 2. Paste this file → Deploy
 * 3. flutter run --dart-define=AUTH_PROXY_URL=https://YOUR-WORKER.workers.dev
 */

const DATABASE_URL =
  'https://quran-book-30ddf-default-rtdb.firebaseio.com';

export default {
  async fetch(request) {
    const url = new URL(request.url);

    if (url.pathname === '/health') {
      return json({ ok: true });
    }

    if (url.pathname.startsWith('/db/')) {
      const path = url.pathname.slice(4).replace(/^\/+|\/+$/g, '');
      const query = url.search || '';
      const target = `${DATABASE_URL}/${path}.json${query}`;
      return proxyFetch(request.method, target, request);
    }

    if (url.pathname === '/storage') {
      const target = url.searchParams.get('url');
      if (!target) {
        return json({ message: 'url query parameter is required' }, 400);
      }
      try {
        const parsed = new URL(target);
        const host = parsed.hostname.toLowerCase();
        const allowed =
          host.endsWith('firebasestorage.googleapis.com') ||
          host.endsWith('firebasestorage.app') ||
          host.endsWith('storage.googleapis.com');
        if (!allowed) {
          return json({ message: 'Storage host is not allowed' }, 400);
        }
      } catch (_) {
        return json({ message: 'Invalid storage url' }, 400);
      }
      return proxyFetch('GET', target);
    }

    return json({ message: 'Not found' }, 404);
  },
};

async function proxyFetch(method, target, request) {
  try {
    const init = { method, headers: { 'Content-Type': 'application/json' } };
    if (request && method !== 'GET' && method !== 'DELETE') {
      init.body = await request.text();
    }

    const response = await fetch(target, init);
    const body = await response.text();
    return new Response(body.length > 0 ? body : 'null', {
      status: response.status,
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'public, max-age=60',
      },
    });
  } catch (error) {
    return json({ message: 'Proxy fetch failed', error: String(error) }, 500);
  }
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
