export default async function handler(req, res) {
  const target = String(req.query.url ?? '').trim();
  if (!target) {
    return res.status(400).json({ message: 'url query parameter is required' });
  }

  try {
    const parsed = new URL(target);
    const host = parsed.hostname.toLowerCase();
    const allowed =
      host.endsWith('firebasestorage.googleapis.com') ||
      host.endsWith('firebasestorage.app') ||
      host.endsWith('storage.googleapis.com');

    if (!allowed) {
      return res.status(400).json({ message: 'Storage host is not allowed' });
    }

    const response = await fetch(parsed.toString());
    if (!response.ok) {
      const text = await response.text();
      return res.status(response.status).send(text);
    }

    const contentType = response.headers.get('content-type');
    if (contentType) {
      res.setHeader('Content-Type', contentType);
    }
    res.setHeader('Cache-Control', 'public, max-age=3600');

    const buffer = Buffer.from(await response.arrayBuffer());
    res.status(200).send(buffer);
  } catch (error) {
    res.status(500).json({
      message: 'Storage proxy failed',
      error: String(error),
    });
  }
}
