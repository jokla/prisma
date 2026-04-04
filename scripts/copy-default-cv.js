#!/usr/bin/env node
// Copies the default CV PDF into site/public/ so it's served on the website.
import { copyFileSync, mkdirSync } from 'fs';
import { resolve, join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');

const src = join(ROOT, 'outputs', 'default.pdf');
const dest = join(ROOT, 'site', 'public', 'cv.pdf');

mkdirSync(dirname(dest), { recursive: true });
copyFileSync(src, dest);
console.log(`✓ Copied ${src} → ${dest}`);
