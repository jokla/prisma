# Giovanni Claudio — Portfolio & CV

Personal repo for generating two outputs from one YAML content source:

1. A tailored Typst CV PDF.
2. An Astro portfolio site.

Phases 1–3 are done: content migration, CV generation, and the Astro site. Phase 4 (GitHub Pages deploy) is the remaining step.

## Current Status

- `content/` is the source of truth for experience, education, projects, publications, presentations, skills, contact details, and pitches.
- `scripts/resolve-profile.js` resolves a profile YAML into `.build/resolved.json`.
- `cv/template.typ` renders that JSON using `@preview/brilliant-cv:3.3.0`.
- `site/` is an Astro 5 + Tailwind 4 static site with Home, Work, Publications, Blog and About pages, dark mode, OG/Twitter meta, sitemap and RSS.
- `make cv` builds `outputs/default.pdf`; `make dev` starts the site dev server; `make build` runs the CV, copies the PDF into `site/public/cv.pdf`, and builds the site to `site/dist/`.

## Requirements

- Node.js 20
- Typst 0.14 or newer

No system fonts needed. The CV fonts are vendored in `cv/fonts/` (Source Sans Pro, Roboto, Font Awesome 7 Free — all OFL-licensed) and the Makefile passes `--font-path cv/fonts` to Typst. The site uses a different stack (DM Sans / Kanit / DM Mono) loaded from Google Fonts at runtime. If you need to refresh the CV set, run `scripts/fetch-fonts.sh`.

## Quick Start

```bash
# Resolver deps
npm install

# Site deps
cd site && npm install && cd ..

# Build the CV
make cv

# Run the site locally
make dev

# Full production build (CV + site → site/dist/)
make build
```

Result of `make cv`:

```bash
outputs/default.pdf
```

To build a tailored CV, add another profile file under `content/profiles/` and run:

```bash
make cv PROFILE=content/profiles/<your-profile>.yaml
```

## How It Works

### CV pipeline

```text
content/ + content/profiles/*.yaml
  -> scripts/resolve-profile.js
  -> .build/resolved.json
  -> typst compile
  -> outputs/*.pdf
```

Important implementation details:

- Typst resolves `sys.inputs.at("data")` relative to `cv/template.typ`, so the Makefile uses `--root $(CURDIR) --input data=../.build/resolved.json`.
- `--font-path cv/fonts` is also required — Typst loses access to user-level fonts once `--font-path` is set, so every font the CV needs must live in that directory.
- The resolver rewrites image paths to be relative to `cv/template.typ`.

### Site pipeline

The Astro site under `site/` reads `content/` directly:

- Collections (`experience`, `education`, `projects`, `publications`, `presentations`, `blog`) are defined in `site/src/content.config.ts` with Zod schemas.
- Singleton files (`bio.yaml`, `contact.yaml`, `skills.yaml`, `interests.yaml`, `extracurricular.yaml`) are loaded through typed helpers in `site/src/lib/content.ts`.
- Assets under `content/assets/` are pre-imported by `site/src/lib/assets.ts` and served through Astro's image pipeline (not from `site/public/`).
- `make build` chains the CV resolver, `scripts/copy-default-cv.js` (copies `outputs/default.pdf` → `site/public/cv.pdf`), and `astro build`.

## Repository Layout

```text
content/      Personal data in YAML and Markdown (source of truth)
cv/           Typst template (brilliant-CV based)
cv/fonts/     Vendored OFL fonts used by the CV
site/         Astro 5 + Tailwind 4 static site
scripts/      Profile resolver, CV copy helper, font fetcher
inputs/       Read-only reference material
outputs/      Generated PDFs (gitignored)
.build/       Intermediate resolved JSON (gitignored)
```

## Reference Material

- `inputs/Awesome-CV/` — prior LaTeX CV used as source/reference during migration
- `inputs/brilliant-CV/` — upstream Typst package repo used to verify metadata shape, font configuration, and troubleshooting guidance
- `inputs/jokla.github.io/` — prior Jekyll portfolio site, kept as historical reference. Old posts are not being migrated; the new blog starts fresh.

These folders are reference inputs only. Do not edit them as part of normal project work.

## Commands

```bash
make cv                                              # Default CV
make cv PROFILE=content/profiles/default.yaml        # Explicit profile
make dev                                             # Astro dev server
make build                                           # CV + site → site/dist/
make clean                                           # Remove .build/, outputs/, site/dist/
```
