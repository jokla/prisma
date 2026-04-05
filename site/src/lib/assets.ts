// Asset helper — maps bare filenames from YAML (e.g. "medtronic.png") onto
// ESM-imported ImageMetadata objects so Astro's image pipeline can hash and
// optimise them. Per portfolio-plan.md, do NOT put these under site/public/.
import type { ImageMetadata } from 'astro';

const modules = import.meta.glob<{ default: ImageMetadata }>(
  '../../../content/assets/*.{png,jpg,jpeg,svg,webp,gif}',
  { eager: true }
);

const byFilename = new Map<string, ImageMetadata>();
for (const [path, mod] of Object.entries(modules)) {
  const filename = path.split('/').pop()!;
  byFilename.set(filename, mod.default);
}

export function getAsset(filename: string): ImageMetadata | undefined {
  return byFilename.get(filename);
}

export function requireAsset(filename: string): ImageMetadata {
  const asset = byFilename.get(filename);
  if (!asset) {
    throw new Error(`Asset not found: ${filename} (in content/assets/)`);
  }
  return asset;
}
