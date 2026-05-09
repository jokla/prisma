// Singleton-file loaders for YAML that doesn't fit the collection model
// (bio, contact, skills, interests, extracurricular).
//
// IMPORTANT: getContact() strips the `phone` field because it is CV-only. Per
// portfolio-plan.md line 221, Astro components must never render it.
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import yaml from 'js-yaml';

const __dirname = dirname(fileURLToPath(import.meta.url));
const CONTENT = resolve(__dirname, '../../../content');

function loadYaml<T>(relativePath: string): T {
  return yaml.load(readFileSync(resolve(CONTENT, relativePath), 'utf8')) as T;
}

// ── Bio ───────────────────────────────────────────────────────────────────

export interface Bio {
  short: string;
  home: string[];
  long: string[];
  origin: string;
  photo: { src: string; alt: string };
  languages: Array<{ name: string; level: string }>;
}

export function getBio(): Bio {
  return loadYaml<Bio>('bio.yaml');
}

// ── Contact ───────────────────────────────────────────────────────────────

export interface Contact {
  name: string;
  location: string;
  linkedin?: string;
  github?: string;
  youtube?: string;
  website?: string;
}

export function getContact(): Contact {
  // Deliberately drop direct contact fields on the way out; CV-only.
  const raw = loadYaml<Contact & { email?: string; phone?: string }>('contact.yaml');
  const { email: _email, phone: _phone, ...rest } = raw;
  return rest;
}

// ── Skills ────────────────────────────────────────────────────────────────

export interface Skill {
  id: string;
  label: string;
  group: string;
}

export function getSkills(): Skill[] {
  const data = loadYaml<{ skills: Skill[] }>('skills.yaml');
  return data.skills;
}

export function getSkillGroups(): Array<{ group: string; skills: Skill[] }> {
  const skills = getSkills();
  const order: string[] = [];
  const bucket = new Map<string, Skill[]>();
  for (const skill of skills) {
    if (!bucket.has(skill.group)) {
      bucket.set(skill.group, []);
      order.push(skill.group);
    }
    bucket.get(skill.group)!.push(skill);
  }
  return order.map((group) => ({ group, skills: bucket.get(group)! }));
}

// ── Interests ─────────────────────────────────────────────────────────────

export interface InterestHighlight {
  title: string;
  date?: string | number | Date;
  location?: string;
  url?: string;
  description: string;
  archived?: boolean;
}

export interface Interests {
  heading: string;
  tagline: string;
  summary: string;
  cv_honors?: Array<{ title: string; issuer: string; location?: string; url?: string }>;
  highlights: InterestHighlight[];
  archive?: string[];
  youtube?: Array<{ id: string; label?: string }>;
  playlist?: string;
}

export function getInterests(): Interests {
  return loadYaml<Interests>('interests.yaml');
}

// ── Extracurricular ───────────────────────────────────────────────────────

export interface ExtracurricularEntry {
  id: string;
  role: string;
  organisation: string;
  url?: string;
  location?: string;
  start?: string | number;
  end?: string | number;
  description: string;
}

export function getExtracurricular(): ExtracurricularEntry[] {
  const data = loadYaml<{ entries: ExtracurricularEntry[] }>('extracurricular.yaml');
  return data.entries;
}
