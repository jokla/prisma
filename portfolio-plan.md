# Giovanni Claudio — Portfolio & CV

## Goal

A personal repo that produces two things from one folder of YAML data:

1. A **portfolio website** at `giovanniclaudio.com` — deployed to GitHub Pages
2. A **professional PDF CV** — with a profile system to tailor it per job application

This is a personal project, not a framework. If it ever makes sense to extract a reusable template, that's a future decision — not a design constraint now.

---

## Stack

| Layer | Tool | Why |
|---|---|---|
| Website | [Astro](https://astro.build) | Fast SSG, zero JS by default, great for static portfolios |
| CV | [Typst](https://typst.app) | Modern LaTeX alternative, millisecond compiles, clean output |
| Data | YAML | Human-readable, native Astro support, easy Git diffs |
| Styling | Tailwind CSS | Utility-first, mobile-first, pairs well with Astro |
| CI/CD | GitHub Actions | Free, builds site + CV on push to `main` |
| Hosting | GitHub Pages | Free, custom domain, already in use |
| Task runner | Make | Simple, no dependencies |

---

## Repository Structure

```
/
├── content/                     ← All personal data
│   ├── experience/              ← One file per role (Arrival is split at 2021-03)
│   ├── education/
│   ├── projects/                ← Work projects + archived academic/OSS work
│   ├── publications/
│   ├── presentations/           ← Conference/workshop talks
│   ├── pitches/
│   │   ├── generic.md           ← Default pitch for website & general CV
│   │   └── surgical-robotics-lead.md
│   ├── profiles/
│   │   ├── default.yaml         ← Used for the website CV download
│   │   └── surgical-robotics-lead.yaml
│   ├── assets/                  ← Images referenced by YAML entries
│   ├── blog/                    ← Markdown posts (Phase 3 migration target)
│   ├── bio.yaml
│   ├── contact.yaml
│   ├── skills.yaml
│   ├── interests.yaml           ← Music/hobbies (optional site section)
│   └── extracurricular.yaml     ← Student clubs etc.
│
├── site/                        ← Astro site
│   ├── src/
│   │   ├── components/
│   │   │   ├── Timeline.astro
│   │   │   ├── JobCard.astro
│   │   │   └── SkillGrid.astro
│   │   ├── layouts/
│   │   │   ├── BaseLayout.astro
│   │   │   └── BlogPost.astro
│   │   ├── pages/
│   │   │   ├── index.astro
│   │   │   ├── work.astro
│   │   │   ├── projects.astro
│   │   │   ├── publications.astro
│   │   │   ├── blog/
│   │   │   └── about.astro
│   │   └── styles/
│   ├── astro.config.mjs
│   └── package.json
│
├── cv/                          ← Typst CV template
│   └── template.typ
│
├── scripts/                     ← Build helpers
│   ├── resolve-profile.js       ← Resolves profile refs into flat JSON for Typst
│   └── copy-default-cv.js       ← Copies default CV PDF into site/public/
│
├── Makefile
│
└── .github/
    └── workflows/
        └── deploy.yml
```

### `.gitignore`

```gitignore
.build/
outputs/
site/dist/
node_modules/
```

---

## Data Format

### Experience (`content/experience/medtronic.yaml`)

```yaml
id: medtronic
company: Medtronic - Digital Surgery
role: Senior Principal Software Engineer — AI-Video Technical Lead
location: London, UK
start: 2023-06
end: present
tags:
  - computer-vision
  - deep-learning
  - medical-robotics
  - edge-deployment
  - c++
  - python
summary: >
  Leading the development of real-time AI and video processing pipelines
  for robotic-assisted and conventional laparoscopic surgery.
highlights:
  - Designing and implementing a high-performance video pipeline for surgical guidance
  - Deploying object detection and segmentation networks on edge devices with Nvidia GPUs
  - Working with a multidisciplinary team of ML researchers, embedded engineers and designers
images:
  - src: medtronic-logo.png
    alt: Medtronic logo
youtube:
  - id: dQw4w9WgXcQ
    label: Demo video
website: https://www.medtronic.com/digital-surgery
```

### Contact (`content/contact.yaml`)

```yaml
name: Giovanni Claudio
email: giovanni@example.com
linkedin: giovanniclaudio
github: giovanniclaudio
website: https://giovanniclaudio.com
phone: "+44 ..."            # CV-only — never rendered on the website
location: London, UK
```

### Profile (`content/profiles/surgical-robotics-lead.yaml`)

Profiles select and order content for a specific CV. Supports inclusive (list what to include) and exclusive (include all except) selection.

```yaml
pitch: pitches/surgical-robotics-lead.md

# Inclusive — list exactly what to include:
experience:
  - medtronic
  - arrival
  - italdesign
skills:
  - computer-vision
  - deep-learning
  - c++
  - ros

# Exclusive — include all except these:
projects_exclude:
  - romeo

publications:
  - popup-icra
highlight: [medtronic]   # Extra visual weight in the PDF (list — supports multiple)
```

---

## Content conventions

Decisions made during Phase 1. These shape how the resolver and both renderers (Astro and Typst) consume `content/`.

### `summary` vs `highlights`

Experience and project entries carry both:

- **`summary`** — first-person prose, 2–6 sentences. What the website renders in the expanded card.
- **`highlights`** — a flat list of terse CV-style bullets. What the Typst CV renders.

Both live in the same YAML file. Each consumer picks the one it needs; the other is ignored. No per-field stripping in the resolver.

### `archived: true`

A soft-delete flag on any entry (experience, project, presentation, or an individual item inside `interests.yaml`). Meaning: "preserved in `content/` for historical reference, but off by default in both outputs." The default profile omits archived entries; the website renders them only in an explicit "archive" section (if the page chooses to opt them in).

Currently used on: the 2008 Spack IT role, 6 old academic/student projects, 2 INRIA-era OSS bridges, and one 2014 workshop talk.

### `archived_highlights`

Sibling list to `highlights` that holds bullets which were previously in the CV but commented out later (e.g. the MPC bullet on the Italdesign autonomous car, the Pepper demos at INRIA). Preserved as data, not rendered by default. If a future profile wants one of them back, copy the line into `highlights`.

### `parent:` on projects

Projects link to a parent career period via a single `parent: <id>` field that resolves against **either** `content/experience/` or `content/education/`. The 9 work-era projects point to an experience id (`italdesign`, `inria`, etc.); the 4 academic projects point to an education id (`unige-bachelor`, `udacity-sdcn`). The Astro site uses this to group projects under the relevant timeline period.

### Skills: flat list, grouped by `group`

`content/skills.yaml` is a single flat list of `{id, label, group}` objects. Profiles reference skills by `id`. The CV template groups them for rendering using the `group` field (matching Awesome-CV's section conventions: Programming, Libraries, Tools, OS, Robots, Sensors). Human languages live in `bio.yaml`, not in skills.

### Bio photo

`bio.yaml` carries a `photo: { src, alt }` field pointing into `content/assets/`. Both the Typst CV header and the website hero component read it. The headshot file is `bio-photo22.jpg`, carried over from the 2025 LaTeX CV render.

### Contact field visibility

`content/contact.yaml` has `phone` as a CV-only field — Astro components must skip it. All other fields render on both surfaces. See the field-visibility table in the CV Pipeline section below for the full list.

### Extra collections beyond the original plan

Phase 1 added three collections that weren't in the original tree:

- **`content/presentations/`** — conference/workshop talks (3 active + 1 archived). Enables a small "Talks" section on the website.
- **`content/interests.yaml`** — music/singing/hobbies. Single file with nested `highlights` + `archive` lists, since the content is too unstructured to fan out into separate files.
- **`content/extracurricular.yaml`** — student clubs (currently just OpenLab).

No `awards.yaml` — the only notable award (a singing competition) lives in `interests.yaml` as a music highlight, and there are no professional honours to track separately yet.

---

## CV Pipeline

The key piece: a resolver script bridges YAML content and Typst.

```
profile YAML + content/ → resolve-profile.js → .build/resolved.json → typst compile → PDF
```

`resolve-profile.js`:
1. Reads the profile YAML.
2. Loads referenced experience/project/publication files from `content/`.
3. Filters `skills.yaml` by profile's skill list.
4. Handles `*_exclude` logic (load all, remove excluded).
5. Inlines the pitch text (see "Pitch format" below).
6. Rewrites `images[].src` to absolute filesystem paths so Typst can load them (see "Asset paths").
7. Reads contact info from `content/contact.yaml`.
8. Writes `.build/resolved.json` for Typst.

The resolver lives at the repo root and has its own `package.json` (deps: `js-yaml`, a CLI arg parser). The Astro site under `site/` has a separate `package.json`. Two lockfiles, two `npm ci` steps — acceptable because the resolver and the site have no shared dependencies.

### Pitch format

Pitches are **plain paragraphs** — no headings, no lists, no Markdown emphasis. Paragraphs are separated by blank lines. The resolver passes the text through unchanged; the Typst template wraps it in a paragraph block, and Astro renders it the same way. This keeps the resolver trivial and avoids bolting a Markdown-to-Typst converter onto a personal project. If a pitch ever needs richer formatting, revisit this decision then.

### Field visibility (website vs CV)

Both outputs read from the same YAML files, but not every field is meant for both surfaces. Rule of thumb: **the consumer ignores fields it doesn't care about.** No resolver-side stripping.

| Field | Website | CV | Notes |
|---|---|---|---|
| `contact.phone` | **no** | yes | Astro components must never render this. |
| `contact.email`, `linkedin`, `github`, `website`, `location` | yes | yes | |
| `experience.images`, `experience.youtube` | yes | no | Typst template ignores them. |
| `experience.website` | yes | no | (Company link on the site; noise on a CV.) |
| `experience.highlights`, `summary`, `tags`, `start`, `end`, `role`, `company`, `location` | yes | yes | Core shared data. |

If a new field is added, decide its visibility and extend this table.

### Asset paths

Images live in `content/assets/` and are referenced by bare filename in YAML (e.g. `src: medtronic-logo.png`). The two consumers resolve that filename differently:

- **Typst** needs a filesystem path relative to the `.typ` file, or an absolute path. The resolver rewrites each `src` to an absolute path when writing `.build/resolved.json`.
- **Astro** uses a small helper that maps the bare filename onto an ESM import from `content/assets/`, so Astro's image pipeline can hash and optimise the asset at build time. Do not put these images under `site/public/` — they'd skip the pipeline.

### Generating a CV

```bash
# Default CV (used on website)
make cv

# Tailored CV for a specific application
make cv PROFILE=content/profiles/surgical-robotics-lead.yaml
# → outputs/surgical-robotics-lead.pdf
```

---

## Website

Built by Astro from the full `content/` folder — no filtering, everything renders.

**Pages:**
- **Home** — bio, current role, links
- **Work** — interactive experience timeline with expandable detail panels (highlights, images, videos, tags)
- **Projects** — personal and academic projects with media
- **Publications** — papers and conference presentations
- **Blog** — Markdown posts (Astro content collection)
- **About** — education, skills, awards/certifications

**Features:**
- Dark mode (Tailwind `dark:` + system preference toggle)
- OpenGraph / Twitter Card meta tags
- Sitemap (`@astrojs/sitemap`) and RSS (`@astrojs/rss`)
- Default CV PDF bundled for download

---

## Makefile

```makefile
PROFILE ?= content/profiles/default.yaml

.PHONY: dev build cv clean

dev:                             ## Start Astro dev server
	cd site && npm run dev

cv:                              ## Generate CV PDF from a profile
	mkdir -p .build outputs
	node scripts/resolve-profile.js --profile $(PROFILE) --out .build/resolved.json
	typst compile --input data=.build/resolved.json cv/template.typ \
	  outputs/$(notdir $(basename $(PROFILE))).pdf

build: cv                        ## Full production build (CV + site)
	node scripts/copy-default-cv.js
	cd site && npm run build

clean:
	rm -rf .build/ outputs/ site/dist/
```

---

## GitHub Actions

The workflow delegates to `make build` so CI and local builds run the exact same steps. Any change to the build sequence goes into the Makefile, not the workflow.

```yaml
# .github/workflows/deploy.yml
name: Build and deploy

on:
  push:
    branches: [main]

permissions:
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci                       # resolver deps (root package.json)
      - run: npm ci
        working-directory: site           # Astro deps
      - uses: typst-community/setup-typst@v3
      - run: make build                   # resolve profile → compile CV → copy PDF → Astro build
      - uses: actions/upload-pages-artifact@v3
        with: { path: site/dist }

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

---

## Blog Migration (from Jekyll)

1. Copy posts from `_posts/` to `content/blog/`. Rename `YYYY-MM-DD-slug.md` → `slug.md`.
2. Replace `layout: post` with nothing. Add `pubDate` from the filename date.
3. Convert `{% highlight lang %}...{% endhighlight %}` → fenced code blocks.
4. Move images to `content/assets/blog/`, update paths.
5. `make dev` and verify.

---

## Build Phases

### Phase 1 — Content migration ✅ DONE

Populated `content/` by migrating data from the existing Awesome-CV LaTeX sources and the old Jekyll site. Final inventory:

- **35 YAML files + 1 Markdown pitch** (~740 lines) — 7 experience, 3 education, 13 projects, 2 publications, 4 presentations, plus `bio`, `contact`, `skills`, `interests`, `extracurricular` and the `default` profile.
- **8 images** under `content/assets/` — all referenced, no orphans.
- **Audit passed**: every profile ref, every `parent:` ref, every image src, and every id/filename pair resolves cleanly.

**Milestone reached:** all career data lives in `content/` as structured YAML.

See the "Content conventions" section above for the schema decisions made during this phase.

### Phase 2 — CV pipeline
Write `resolve-profile.js` and the Typst template `cv/template.typ`. **Fork an existing Typst CV template** from Typst Universe (`basic-resume`, `modernpro`, `imprecv`, `vantage-typst` are all reasonable starting points) rather than building the layout from scratch — the goal here is content plumbing, not a layout engine. Get `make cv` producing a clean PDF from real content.

**Milestone:** `make cv` outputs a professional PDF. Tailored CVs work via `make cv PROFILE=...`.

### Phase 3 — Astro website
Scaffold the Astro project. Build pages: Home, Work (timeline), Projects, Publications, About. Configure content collections for blog. Add SEO basics (meta tags, sitemap). Implement dark mode. Migrate blog posts from Jekyll.

**Milestone:** `make dev` shows a complete portfolio site.

### Phase 4 — Deploy
Wire up the GitHub Actions workflow. Copy `CNAME` from `inputs/jokla.github.io/CNAME` to `site/public/CNAME` so the custom domain survives the first deploy. Push to `main` → CV compiled → site built → deployed to `giovanniclaudio.com`.

**Milestone:** live at `giovanniclaudio.com`.

---

## Day-to-day Workflow

| Situation | What to do |
|---|---|
| New job or promotion | Add/edit a file in `content/experience/`, push |
| New project or publication | Add a `.yaml` file, push |
| New blog post | Add a `.md` to `content/blog/`, push |
| Applying for a job | Write a pitch in `content/pitches/`, create a profile in `content/profiles/`, run `make cv PROFILE=...` |
| Change CV design | Edit `cv/template.typ` |
| Change website design | Edit Astro components/styles |

---

## What I'm deliberately not doing

- **No framework extraction.** This is a personal repo. No `content.example/`, no `init.js`, no template repo.
- **No JSON Schema validation.** Overkill for one person editing their own files. If a YAML field is wrong, the build will fail and that's enough.
- **No config abstraction.** No `prisma.config.yaml`. Site identity goes directly in Astro layouts. CV filename is hardcoded in the Makefile.
- **No page toggle system.** If I don't want a page, I delete the `.astro` file and the nav link.
- **No generic naming.** This repo is called what it is, not a product name that conflicts with Prisma ORM.

If this turns out to be useful to others, I can extract a template later — from working code, not from architecture diagrams.
