import { DATABASE_URL } from '../_config.js';

export default async function handler(req, res) {
  const segments = req.query.path;
  let path = Array.isArray(segments)
    ? segments.join('/')
    : String(segments ?? '');

  path = path.replace(/^\/+|\/+$/g, '').replace(/\.json$/, '');

  const queryIndex = req.url?.indexOf('?') ?? -1;
  const query = queryIndex >= 0 ? req.url.slice(queryIndex) : '';
  const target = `${DATABASE_URL}/${path}.json${query}`;

  try {
    const init = {
      method: req.method,
      headers: { 'Content-Type': 'application/json' },
    };

    if (req.method !== 'GET' && req.method !== 'DELETE' && req.body) {
      init.body = JSON.stringify(req.body);
    }

    const response = await fetch(target, init);
    const text = await response.text();
    res.status(response.status);
    res.setHeader('Content-Type', 'application/json');
    res.send(text.length > 0 ? text : 'null');
  } catch (error) {
    res.status(500).json({
      message: 'Database proxy failed',
      error: String(error),
    });
  }
}
