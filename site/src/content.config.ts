import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// Date strings used in content/ come in three shapes:
//   - "YYYY-MM"  (e.g. 2025-01)
//   - "YYYY"     (e.g. 2011)
//   - "present"  (end dates only)
// YAML loads YYYY as a number, so accept both.
const dateString = z.union([z.string(), z.number()]).transform((v) => String(v));

const imageRef = z.object({
  src: z.string(),
  alt: z.string(),
});

const youtubeRef = z.object({
  id: z.string(),
  label: z.string().optional(),
});

const experience = defineCollection({
  loader: glob({ pattern: '*.yaml', base: '../content/experience' }),
  schema: z.object({
    id: z.string(),
    company: z.string(),
    role: z.string(),
    location: z.string(),
    start: dateString,
    end: dateString,
    website: z.string().url().optional(),
    tags: z.array(z.string()).default([]),
    tagline: z.string().optional(),
    summary: z.string(),
    highlights: z.array(z.string()).default([]),
    archived_highlights: z.array(z.string()).optional(),
    images: z.array(imageRef).optional(),
    youtube: z.array(youtubeRef).optional(),
    archived: z.boolean().optional(),
  }),
});

const education = defineCollection({
  loader: glob({ pattern: '*.yaml', base: '../content/education' }),
  schema: z.object({
    id: z.string(),
    institution: z.string(),
    degree: z.string(),
    location: z.string().optional(),
    start: dateString,
    end: dateString,
    courses: z.array(z.string()).optional(),
    thesis: z
      .object({
        title: z.string(),
        summary: z.string().optional(),
        stack: z.array(z.string()).optional(),
      })
      .optional(),
    images: z.array(imageRef).optional(),
    archived: z.boolean().optional(),
  }),
});

const projects = defineCollection({
  loader: glob({ pattern: '*.yaml', base: '../content/projects' }),
  schema: z.object({
    id: z.string(),
    name: z.string(),
    subtitle: z.string().optional(),
    organisation: z.string().optional(),
    parent: z.string().optional(),
    location: z.string().optional(),
    start: dateString.optional(),
    end: dateString.optional(),
    stack: z.array(z.string()).optional(),
    tags: z.array(z.string()).optional(),
    url: z.string().optional(),
    partners: z.array(z.string()).optional(),
    summary: z.string().optional(),
    highlights: z.array(z.string()).optional(),
    archived_highlights: z.array(z.string()).optional(),
    images: z.array(imageRef).optional(),
    youtube: z.array(youtubeRef).optional(),
    archived: z.boolean().optional(),
  }),
});

const publications = defineCollection({
  loader: glob({ pattern: '*.yaml', base: '../content/publications' }),
  schema: z.object({
    id: z.string(),
    title: z.string(),
    authors: z.array(z.string()),
    venue: z.string(),
    venue_short: z.string().optional(),
    type: z.enum(['journal', 'conference', 'workshop', 'preprint']),
    year: z.number(),
    volume: z.union([z.string(), z.number()]).optional(),
    issue: z.union([z.string(), z.number()]).optional(),
    pages: z.string().optional(),
    doi: z.string().optional(),
    url: z.string().url().optional(),
    note: z.string().optional(),
    tags: z.array(z.string()).optional(),
  }),
});

const presentations = defineCollection({
  loader: glob({ pattern: '*.yaml', base: '../content/presentations' }),
  schema: z.object({
    id: z.string(),
    title: z.string(),
    event: z.string(),
    location: z.string().optional(),
    date: dateString,
    tags: z.array(z.string()).optional(),
    summary: z.string().optional(),
    archived: z.boolean().optional(),
  }),
});

// Blog scaffolded — empty for now, posts migrate from Jekyll later.
const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: '../content/blog' }),
  schema: z.object({
    title: z.string(),
    pubDate: z.coerce.date(),
    description: z.string().optional(),
    tags: z.array(z.string()).optional(),
    draft: z.boolean().optional(),
  }),
});

export const collections = { experience, education, projects, publications, presentations, blog };
