const express = require('express');
const admin = require('firebase-admin');

const app = express();
app.use(express.json());

const port = process.env.PORT || 8080;
const apiKey =
  process.env.FIREBASE_API_KEY || 'AIzaSyD1I95KKfloDM1G2BulHstckZ1nT17q040';
const databaseURL =
  process.env.FIREBASE_DATABASE_URL ||
  'https://quran-book-30ddf-default-rtdb.firebaseio.com';

if (!admin.apps.length) {
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (serviceAccountJson) {
    admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(serviceAccountJson)),
    });
  } else {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
  }
}

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

app.post('/login', async (req, res) => {
  const email = String(req.body?.email ?? '').trim();
  const password = String(req.body?.password ?? '');

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    const authResponse = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email,
          password,
          returnSecureToken: true,
        }),
      },
    );

    const payload = await authResponse.json();
    if (!authResponse.ok) {
      return res.status(authResponse.status).json(payload);
    }

    const uid = payload.localId;
    if (!uid) {
      return res.status(500).json({ message: 'Auth response missing user id' });
    }

    const customToken = await admin.auth().createCustomToken(uid);
    return res.json({ customToken });
  } catch (error) {
    console.error('Login proxy failed:', error);
    return res.status(500).json({ message: 'Login proxy failed' });
  }
});

app.post('/register', async (req, res) => {
  const email = String(req.body?.email ?? '').trim();
  const password = String(req.body?.password ?? '');

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  try {
    const authResponse = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email,
          password,
          returnSecureToken: true,
        }),
      },
    );

    const payload = await authResponse.json();
    if (!authResponse.ok) {
      return res.status(authResponse.status).json(payload);
    }

    const uid = payload.localId;
    if (!uid) {
      return res.status(500).json({ message: 'Auth response missing user id' });
    }

    const customToken = await admin.auth().createCustomToken(uid);
    return res.json({ customToken });
  } catch (error) {
    console.error('Register proxy failed:', error);
    return res.status(500).json({ message: 'Register proxy failed' });
  }
});

async function forwardDatabaseRequest(req, res, method) {
  const path = String(req.params.path ?? '').replace(/^\/+|\/+$/g, '');
  const queryIndex = req.originalUrl.indexOf('?');
  const query = queryIndex >= 0 ? req.originalUrl.slice(queryIndex) : '';
  const url = `${databaseURL}/${path}.json${query}`;

  try {
    const response = await fetch(url, {
      method,
      headers: { 'Content-Type': 'application/json' },
      body: method === 'GET' || method === 'DELETE' ? undefined : JSON.stringify(req.body ?? {}),
    });

    const text = await response.text();
    res.status(response.status);
    res.type('application/json');
    return res.send(text.length > 0 ? text : 'null');
  } catch (error) {
    console.error('Database proxy failed:', error);
    return res.status(500).json({ message: 'Database proxy failed' });
  }
}

app.get('/db/*', (req, res) => {
  req.params.path = req.params[0];
  forwardDatabaseRequest(req, res, 'GET');
});
app.put('/db/*', (req, res) => {
  req.params.path = req.params[0];
  forwardDatabaseRequest(req, res, 'PUT');
});
app.patch('/db/*', (req, res) => {
  req.params.path = req.params[0];
  forwardDatabaseRequest(req, res, 'PATCH');
});
app.delete('/db/*', (req, res) => {
  req.params.path = req.params[0];
  forwardDatabaseRequest(req, res, 'DELETE');
});

app.get('/storage', async (req, res) => {
  const targetUrl = String(req.query.url ?? '').trim();
  if (!targetUrl) {
    return res.status(400).json({ message: 'url query parameter is required' });
  }

  let parsed;
  try {
    parsed = new URL(targetUrl);
  } catch (_) {
    return res.status(400).json({ message: 'Invalid storage url' });
  }

  const host = parsed.hostname.toLowerCase();
  const allowed =
    host.endsWith('firebasestorage.googleapis.com') ||
    host.endsWith('firebasestorage.app') ||
    host.endsWith('storage.googleapis.com');

  if (!allowed) {
    return res.status(400).json({ message: 'Storage host is not allowed' });
  }

  try {
    const response = await fetch(parsed.toString());
    if (!response.ok) {
      return res.status(response.status).send(await response.text());
    }

    const contentType = response.headers.get('content-type');
    if (contentType) {
      res.setHeader('Content-Type', contentType);
    }
    res.setHeader('Cache-Control', 'public, max-age=3600');

    const buffer = Buffer.from(await response.arrayBuffer());
    return res.send(buffer);
  } catch (error) {
    console.error('Storage proxy failed:', error);
    return res.status(500).json({ message: 'Storage proxy failed' });
  }
});

app.listen(port, () => {
  console.log(`Auth proxy listening on port ${port}`);
});
