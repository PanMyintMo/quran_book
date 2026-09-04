#!/usr/bin/env node
/**
 * Syncs Firebase RTDB + Storage images to public_data/ for jsDelivr.
 * Runs on GitHub Actions (cloud) — users never need VPN.
 */
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const DATABASE_URL =
  process.env.FIREBASE_DATABASE_URL ||
  'https://quran-book-30ddf-default-rtdb.firebaseio.com';

const ROOT = path.join(__dirname, '..', '..', 'public_data');
const IMAGES_DIR = path.join(ROOT, 'images');

async function fetchJson(path) {
  const url = `${DATABASE_URL}/${path}.json`;
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`Failed to fetch ${url}: ${res.status}`);
  }
  const data = await res.json();
  return data ?? null;
}

function mapToArray(data) {
  if (!data || typeof data !== 'object') return [];
  return Object.values(data).filter((v) => v && typeof v === 'object');
}

function imageKey(url) {
  return crypto.createHash('md5').update(url).digest('hex');
}

async function mirrorImage(url, owner, repo, branch) {
  if (!url || typeof url !== 'string' || !url.startsWith('http')) return url;

  const key = imageKey(url);
  const ext = url.includes('.png') ? 'png' : url.includes('.webp') ? 'webp' : 'jpg';
  const filename = `${key}.${ext}`;
  const filePath = path.join(IMAGES_DIR, filename);

  if (!fs.existsSync(filePath)) {
    const res = await fetch(url);
    if (!res.ok) return url;
    const buffer = Buffer.from(await res.arrayBuffer());
    fs.writeFileSync(filePath, buffer);
  }

  return `https://cdn.jsdelivr.net/gh/${owner}/${repo}@${branch}/public_data/images/${filename}`;
}

async function rewriteImages(items, owner, repo, branch) {
  for (const item of items) {
    if (item.image) {
      item.image = await mirrorImage(item.image, owner, repo, branch);
    }
  }
}

async function main() {
  const owner = process.env.CONTENT_MIRROR_OWNER || 'PanMyintMo';
  const repo = process.env.CONTENT_MIRROR_REPO || 'quran_book';
  const branch = process.env.CONTENT_MIRROR_BRANCH || 'master';

  fs.mkdirSync(IMAGES_DIR, { recursive: true });

  console.log('Fetching books, categories, banners from Firebase...');
  const [booksRaw, categoriesRaw, bannersRaw] = await Promise.all([
    fetchJson('books'),
    fetchJson('categories'),
    fetchJson('banners'),
  ]);

  const books = mapToArray(booksRaw);
  const categories = mapToArray(categoriesRaw);
  const banners = mapToArray(bannersRaw);

  console.log(`Mirroring images (${books.length + categories.length + banners.length} items)...`);
  await rewriteImages(books, owner, repo, branch);
  await rewriteImages(categories, owner, repo, branch);
  await rewriteImages(banners, owner, repo, branch);

  fs.writeFileSync(path.join(ROOT, 'books.json'), JSON.stringify(books, null, 2));
  fs.writeFileSync(
    path.join(ROOT, 'categories.json'),
    JSON.stringify(categories, null, 2),
  );
  fs.writeFileSync(path.join(ROOT, 'banners.json'), JSON.stringify(banners, null, 2));
  fs.writeFileSync(
    path.join(ROOT, 'meta.json'),
    JSON.stringify(
      {
        syncedAt: new Date().toISOString(),
        counts: {
          books: books.length,
          categories: categories.length,
          banners: banners.length,
        },
      },
      null,
      2,
    ),
  );

  console.log('Done:', {
    books: books.length,
    categories: categories.length,
    banners: banners.length,
  });
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
