#!/usr/bin/env node
// Copies the default CV PDF into site/public/ so it's served on the website.
import { copyFileSync, existsSync, mkdirSync } from 'node:fs';
import { resolve, join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');

const src = join(ROOT, 'outputs', 'default.pdf');
const dest = join(ROOT, 'site', 'public', 'cv.pdf');

if (!existsSync(src)) {
    console.error(`✗ Source PDF not found: ${src}`);
    process.exit(1);
}

mkdirSync(dirname(dest), { recursive: true });
copyFileSync(src, dest);
console.log(`✓ Copied ${src} → ${dest}`);
