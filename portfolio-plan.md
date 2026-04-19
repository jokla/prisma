# Giovanni Claudio — Portfolio & CV

## Goal

A personal repo that produces two things from one folder of YAML data:

1. A **portfolio website** at `giovanniclaudio.com` — deployed to GitHub Pages
2. A **professional PDF CV** — with a profile system to tailor it per job application

This is a personal project, not a framework. If it ever makes sense to extract a reusable template, that's a future decision — not a design constraint now.

Current branch state: Phases 1–3 are complete. `content/` is populated, `make cv` produces `outputs/default.pdf`, and the Astro site under `site/` is scaffolded with Home / Work / Publications / Blog / About pages, dark mode, sitemap and RSS. The GitHub Pages deploy workflow (Phase 4) is not yet in place — `.github/workflows/` currently only contains Claude helper workflows.

---

## Stack

| Layer | Tool | Why |
|---|---|---|
| Website | [Astro](https://astro.build) | Fast SSG, zero JS by default, great for static portfolios |
| CV | [Typst](https://typst.app) | Modern LaTeX alternative, millisecond compiles, clean output |
| Data | YAML | Human-readable, native Astro support, easy Git diffs |
| Styling | Tailwind CSS | Utility-first, mobile-first, pairs well with Astro |
| CI/CD | GitHub Actions | Free, planned for site + CV builds on push to `master` |
| Hosting | GitHub Pages | Free, custom domain, already in use |
| Task runner | Make | Simple, no dependencies |

---

## Target Repository Structure

The current repo contains `content/`, `cv/`, `scripts/`, `site/`, `Makefile`, and the root `package.json` for the resolver. `.github/workflows/deploy.yml` shown below is the planned Phase 4 addition.

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
│   │   └── <application>.md     ← Example future tailored pitch
│   ├── profiles/
│   │   ├── default.yaml         ← Used for the website CV download
│   │   └── <application>.yaml   ← Example future tailored profile
│   ├── assets/                  ← Images referenced by YAML entries
│   ├── blog/                    ← Markdown posts (starts empty; blog begins fresh)
│   ├── bio.yaml
│   ├── contact.yaml
│   ├── skills.yaml
│   ├── interests.yaml           ← Music/hobbies (optional site section)
│   └── extracurricular.yaml     ← Student clubs etc.
│
├── site/                        ← Astro 5 + Tailwind 4 static site
│   ├── src/
│   │   ├── components/          ← JobCard, WorkProjectCard, YouTubeEmbed,
│   │   │                          SkillGrid, PublicationEntry, DarkModeToggle
│   │   ├── content.config.ts    ← Zod-typed content collections
│   │   ├── layouts/             ← BaseLayout, BlogPost
│   │   ├── lib/                 ← content.ts (singletons), assets.ts,
│   │   │                          dates.ts, location.ts
│   │   ├── pages/
│   │   │   ├── index.astro      ← Home
│   │   │   ├── work.astro       ← Work + related projects per role
│   │   │   ├── publications.astro
│   │   │   ├── blog/
│   │   │   ├── about.astro
│   │   │   └── rss.xml.ts
│   │   └── styles/global.css
│   ├── public/                  ← robots.txt; cv.pdf is generated, not committed
│   ├── astro.config.mjs
│   ├── tsconfig.json
│   └── package.json
│
├── cv/                          ← Typst CV template
│   ├── template.typ
│   └── fonts/                   ← Vendored OFL fonts (Source Sans Pro / Roboto / FA7)
│
├── scripts/                     ← Build helpers
│   ├── resolve-profile.js       ← Resolves profile refs into flat JSON for Typst
│   ├── copy-default-cv.js       ← Copies default CV PDF into site/public/
│   └── fetch-fonts.sh           ← Re-fetches the vendored CV fonts
│
├── Makefile
├── package.json
├── package-lock.json
│
├── inputs/                      ← Read-only reference sources
│   ├── Awesome-CV/
│   ├── brilliant-CV/
│   └── jokla.github.io/
│
└── .github/
    └── workflows/
        └── deploy.yml
```

### `.gitignore`

```gitignore
/inputs/**
.build/
outputs/
site/dist/
site/.astro/
site/public/cv.pdf
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

### Profile (`content/profiles/<application>.yaml`)

Profiles select and order content for a specific CV. Supports inclusive (list what to include) and exclusive (include all except) selection. The current repo only commits `content/profiles/default.yaml`; additional tailored profiles follow the same format.

```yaml
pitch: pitches/generic.md

# Inclusive — list exactly what to include:
experience:
  - medtronic-sr-principal
  - medtronic-principal
  - arrival-senior
  - italdesign
skills:
  - cpp
  - python
  - detection
  - ros

# Exclusive — include all except these:
projects_exclude:
  - pepper-visual-navigation

publications:
  - visual-servoing-ral-2017
highlight: [medtronic-sr-principal]   # Extra visual weight in the PDF (list — supports multiple)
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

`content/skills.yaml` is a single flat list of `{id, label, group}` objects. Profiles reference skills by `id`. The CV template groups them for rendering using the `group` field (matching Awesome-CV's section conventions: Programming, Libraries, Tools, OS, Robots, Sensors). Human languages still live in `bio.yaml`, but the CV renders them as a separate `Languages` row alongside the grouped technical skills so the `Programming` label stays unambiguous.

### Bio photo

`bio.yaml` carries a `photo: { src, alt }` field pointing into `content/assets/`. Both the Typst CV header and the website hero component read it. The headshot file is `bio-photo.jpg`, carried over from the 2025 LaTeX CV render.

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
6. Rewrites `images[].src` to paths relative to `cv/template.typ` so Typst can load them reliably (see "Asset paths").
7. Reads contact info from `content/contact.yaml`.
8. Writes `.build/resolved.json` for Typst.

The resolver lives at the repo root and has its own `package.json` / `package-lock.json` (currently `js-yaml` only). The Astro site under `site/` has a separate `package.json` / `package-lock.json`. Two lockfiles and two `npm ci` steps are acceptable because the resolver and the site have no shared dependencies.

### Typst / brilliant-CV integration

The CV template is built on top of `@preview/brilliant-cv:3.3.0`, but it does **not** use a checked-in `metadata.toml`. Instead, `cv/template.typ` builds the upstream metadata structure inline from the resolved JSON.

That inline metadata must match the upstream package shape:

- top-level `language`
- top-level `inject`
- `layout.fonts`
- `layout.header`
- `layout.entry`
- `layout.footer`

The current CV font choice:

- body: `Source Sans Pro`
- header: `Roboto`
- icons: `Font Awesome 7 Free`

All three are **vendored under `cv/fonts/`** (all OFL). The Makefile passes `--font-path cv/fonts`, so the CV has no system-font dependencies. One gotcha worth remembering: when `--font-path` is set, Typst stops searching user-level font dirs (`~/.local/share/fonts/`), so **anything the CV needs must live in `cv/fonts/`** — including Font Awesome. `scripts/fetch-fonts.sh` documents where each file came from and can re-fetch if needed.

DM Sans / Kanit / DM Mono were briefly tested as a unified stack for CV + site, but DM Sans rendered the CV a page longer than Source Sans Pro at the same point size, so the CV kept its original stack. Upstream `brilliant-CV` recommends `Source Sans 3`; `Source Sans Pro` is an acceptable fallback and the current house choice.

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

- **Typst** resolves these assets relative to `cv/template.typ`. The resolver rewrites each `src` to a path like `../content/assets/<file>` when writing `.build/resolved.json`.
- **Astro** uses a small helper that maps the bare filename onto an ESM import from `content/assets/`, so Astro's image pipeline can hash and optimise the asset at build time. Do not put these images under `site/public/` — they'd skip the pipeline.

Typst input handling follows the same rule: the `data` input passed via `sys.inputs.at("data")` is resolved from the `.typ` file location, so the compile command must pass `--input data=../.build/resolved.json` together with `--root $(CURDIR)`.

### Generating a CV

```bash
# Default CV (used on website)
make cv

# Tailored CV for a specific application, after adding a profile file
make cv PROFILE=content/profiles/<application>.yaml
# → outputs/<application>.pdf
```

---

## Website (Phase 3)

Astro 5 + Tailwind 4 static site built from the full `content/` folder — no filtering, everything renders. Lives under `site/` with its own `package.json` and `npm install`.

**Pages:**
- **Home** (`/`) — bio, photo, social links, "Currently" card showing the latest active experience.
- **Work** (`/work/`) — `JobCard` per active experience with related projects grouped under their parent via the `parent:` field, archived roles collapsed behind a `<details>`. Sticky table of contents on wide screens.
- **Publications** (`/publications/`) — papers sorted newest-first, followed by a Talks section pulled from `content/presentations/` (archived entries filtered out).
- **Blog** (`/blog/` and `/blog/<slug>/`) — Astro content collection + RSS feed at `/rss.xml`. Starts empty; old Jekyll posts are not being migrated, new posts are written directly into `content/blog/`.
- **About** (`/about/`) — long bio, skills grid, education cards, interests highlights.

There is deliberately **no `/projects` page** — projects surface under their parent role on `/work/` through `JobCard.relatedProjects`.

**Features:**
- Dark mode via a pre-paint inline script in `BaseLayout.astro` (reads `localStorage.theme` or `prefers-color-scheme`), toggled by `DarkModeToggle`.
- OpenGraph / Twitter Card meta tags, canonical URLs, and sitemap + RSS links in `<head>`.
- `@astrojs/sitemap` integration and `@astrojs/rss` feed for the blog.
- Default CV PDF served at `/cv.pdf`, written by `scripts/copy-default-cv.js` during `make build`.
- Typography: DM Sans body / Kanit display / DM Mono accent, loaded from Google Fonts in `BaseLayout.astro`. The CV uses a different stack (Source Sans Pro + Roboto, vendored under `cv/fonts/`) because DM Sans pushed the PDF from two pages to three at the same point size.

**Content loading:**
- Collections (`experience`, `education`, `projects`, `publications`, `presentations`, `blog`) are defined with Zod schemas in `site/src/content.config.ts` and loaded via `glob` from `../content/<collection>/*.yaml`. YAML dates parse as either string or number, so a shared `dateString` transform stringifies them.
- Singleton YAML files go through `site/src/lib/content.ts`: `getBio()`, `getContact()`, `getSkills()`, `getSkillGroups()`, `getInterests()`, `getExtracurricular()`.
- `getContact()` is the enforcement point for the CV-only `phone` field — it destructures `phone` out before returning. Any future CV-only contact field must extend this filter.
- `site/src/lib/assets.ts` pre-imports every `content/assets/*` file via `import.meta.glob` so components look images up by bare filename and get an optimised `ImageMetadata` back.
- `site/src/lib/dates.ts` mirrors the resolver's `formatDate` / `formatRange` and adds `dateKey()` for sorting.

---

## Makefile

All four targets work today. `make build` chains the CV resolver, `scripts/copy-default-cv.js`, and `astro build` — the same sequence Phase 4 CI will run.

```makefile
PROFILE ?= content/profiles/default.yaml

.PHONY: dev build cv clean

dev:                             ## Start Astro dev server
	cd site && npm run dev

cv:                              ## Generate CV PDF from a profile
	mkdir -p .build outputs
	node scripts/resolve-profile.js --profile $(PROFILE) --out .build/resolved.json
	typst compile --root $(CURDIR) --font-path cv/fonts \
	  --input data=../.build/resolved.json \
	  cv/template.typ outputs/$(notdir $(basename $(PROFILE))).pdf

build: cv                        ## Full production build (CV + site)
	node scripts/copy-default-cv.js
	cd site && npm run build

clean:
	rm -rf .build/ outputs/ site/dist/
```

---

## GitHub Actions

Planned Phase 4 workflow. The repo currently contains only Claude helper workflows; the Pages deploy workflow below is the target shape. It delegates to `make build` so CI and local builds run the exact same steps. Any change to the build sequence goes into the Makefile, not the workflow.

```yaml
# .github/workflows/deploy.yml
name: Build and deploy

on:
  push:
    branches: [master]

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

## Build Phases

### Phase 1 — Content migration ✅ DONE

Populated `content/` by migrating data from the existing Awesome-CV LaTeX sources and the old Jekyll site. Final inventory:

- Structured collections for experience, education, projects, publications, presentations, bio/contact/skills, interests, extracurricular activity, the default profile, and the default pitch.
- Related assets under `content/assets/`, all referenced with no known orphans.
- **Audit passed**: every profile ref, every `parent:` ref, every image src, and every id/filename pair resolves cleanly.

**Milestone reached:** all career data lives in `content/` as structured YAML.

See the "Content conventions" section above for the schema decisions made during this phase.

### Phase 2 — CV pipeline ✅ DONE
`resolve-profile.js` and `cv/template.typ` are implemented. The CV uses the `brilliant-CV` Typst package with inline metadata derived from resolved YAML content rather than a standalone `metadata.toml`. `make cv` produces a working PDF from real content, and the resolver supports additional tailored CVs via more files under `content/profiles/`.

**Milestone reached:** `make cv` outputs a professional PDF. Tailored CVs work via `make cv PROFILE=...`.

### Phase 3 — Astro website ✅ DONE
Astro 5 + Tailwind 4 static site is scaffolded under `site/`. Home, Work, Publications, Blog and About pages are live; blog collection and RSS feed are wired and render whatever Markdown is dropped into `content/blog/` (starts empty; old Jekyll posts are not being migrated). Dark mode, OG/Twitter meta, sitemap and RSS are all in place. Content collections are defined in `site/src/content.config.ts`; singleton YAML files load through `site/src/lib/content.ts`, where `getContact()` strips the CV-only `phone` field. Projects intentionally do not get their own page — they render under their parent experience on `/work/`.

**Milestone reached:** `make dev` serves a complete portfolio site; `make build` produces `site/dist/` with the freshly-compiled default CV at `/cv.pdf`.

### Phase 4 — Deploy
Outstanding work:

1. Add `site/public/favicon.svg` and `site/public/og-default.png` — both are referenced from `BaseLayout.astro` but not yet committed.
2. Copy `inputs/jokla.github.io/CNAME` to `site/public/CNAME` so the custom domain survives the first deploy.
3. Add `.github/workflows/deploy.yml` per the "GitHub Actions" section and enable GitHub Pages on the repo.
4. Push to `master` → CV compiled → site built → deployed to `giovanniclaudio.com`.

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
