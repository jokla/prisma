#!/usr/bin/env node
// resolve-profile.js
// Reads a profile YAML + content/ files and writes .build/resolved.json for Typst.
//
// Usage:
//   node scripts/resolve-profile.js --profile <path> --out <path>

import { readFileSync, writeFileSync, readdirSync } from 'fs';
import { resolve, join, dirname, basename } from 'path';
import { fileURLToPath } from 'url';
import yaml from 'js-yaml';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');
const CONTENT = join(ROOT, 'content');
const TYPST_BASE = '..';

// ── CLI args ──────────────────────────────────────────────────────────────

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i].startsWith('--')) {
      args[argv[i].slice(2)] = argv[i + 1];
      i++;
    }
  }
  return args;
}

const args = parseArgs(process.argv.slice(2));
if (!args.profile || !args.out) {
  console.error('Usage: node scripts/resolve-profile.js --profile <path> --out <path>');
  process.exit(1);
}

const profilePath = resolve(args.profile);
const outPath = resolve(args.out);
// ── Helpers ───────────────────────────────────────────────────────────────

function loadYaml(path) {
  return yaml.load(readFileSync(path, 'utf8'));
}

// Format a YYYY-MM (or YYYY) date string to "Mon YYYY" / "YYYY".
// "present" / null / undefined → "Present".
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

function formatDate(d) {
  if (!d || d === 'present') return 'Present';
  const s = String(d);
  const [year, month] = s.split('-');
  return month ? `${MONTHS[parseInt(month, 10) - 1]} ${year}` : year;
}

// Rewrite image src fields to paths relative to cv/template.typ for Typst.
function resolveImages(images) {
  if (!images) return images;
  return images.map(img => ({
    ...img,
    src: join(TYPST_BASE, 'content', 'assets', basename(img.src)),
  }));
}

// Enrich an entry: add formatted dates + rewrite image paths.
function enrich(entry) {
  const out = { ...entry };
  if ('start' in out) out.start_formatted = formatDate(out.start);
  if ('end' in out) out.end_formatted = formatDate(out.end);
  if (out.images) out.images = resolveImages(out.images);
  return out;
}

function loadEntry(dir, id) {
  return enrich(loadYaml(join(CONTENT, dir, `${id}.yaml`)));
}

function loadAll(dir) {
  return readdirSync(join(CONTENT, dir))
    .filter(f => f.endsWith('.yaml'))
    .map(f => enrich(loadYaml(join(CONTENT, dir, f))));
}

function loadList(dir, ids) {
  return (ids || []).map(id => loadEntry(dir, id));
}

function loadExcluding(dir, excludeIds) {
  const excludeSet = new Set(excludeIds || []);
  return loadAll(dir).filter(e => !e.archived && !excludeSet.has(e.id));
}

// ── Load core data ────────────────────────────────────────────────────────

const profile = loadYaml(profilePath);
const contact = loadYaml(join(CONTENT, 'contact.yaml'));
const bio = loadYaml(join(CONTENT, 'bio.yaml'));

// Resolve photo to a path relative to cv/template.typ.
if (bio.photo?.src) {
  bio.photo = {
    ...bio.photo,
    src: join(TYPST_BASE, 'content', 'assets', bio.photo.src),
  };
}

// Load pitch text (plain paragraphs, no Markdown formatting).
let pitch = '';
if (profile.pitch) {
  pitch = readFileSync(join(CONTENT, profile.pitch), 'utf8').trim();
}

// ── Resolve collections ───────────────────────────────────────────────────

const experience = loadList('experience', profile.experience);
const education = loadList('education', profile.education);
const publications = loadList('publications', profile.publications);

let projects;
if (profile.projects) {
  // Explicit whitelist (ordered).
  projects = loadList('projects', profile.projects);
} else {
  // Include all non-archived, optionally excluding specific ids.
  projects = loadExcluding('projects', profile.projects_exclude);
}

// ── Resolve skills ────────────────────────────────────────────────────────

const allSkills = loadYaml(join(CONTENT, 'skills.yaml')).skills;
let skills;
if (profile.skills) {
  const skillSet = new Set(profile.skills);
  skills = allSkills.filter(s => skillSet.has(s.id));
} else {
  skills = allSkills;
}

// ── Write output ──────────────────────────────────────────────────────────

const resolved = {
  contact,
  bio,
  pitch,
  experience,
  education,
  projects,
  publications,
  skills,
  highlight: profile.highlight || [],
};

writeFileSync(outPath, JSON.stringify(resolved, null, 2));
console.log(`✓ Resolved ${profilePath} → ${outPath}`);
