# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

**Phases 1–3 are done.** Content is migrated, the CV pipeline produces `outputs/default.pdf`, and the Astro site under `site/` is scaffolded with Home / Work / Publications / Blog / About pages, dark mode, SEO, sitemap and RSS. **Phase 4 (GitHub Pages deploy) is the remaining work** — `.github/workflows/` currently only holds the Claude helper workflows; there is no `deploy.yml` yet.

One-time setup is `npm install` at the repo root (for the resolver) plus `npm install` inside `site/` (for Astro). After that:

- `make cv` — default CV → `outputs/default.pdf`
- `make dev` — Astro dev server for the site
- `make build` — runs the CV resolver, copies the PDF into `site/public/cv.pdf`, then builds the site to `site/dist/`

`content/` holds the migrated YAML collections, the default pitch, and related assets — see the "Content conventions" section of `portfolio-plan.md` for the schema decisions (especially `summary` vs `highlights`, `archived:` / `archived_highlights:`, `parent:` on projects, and the flat skills list with `group` field).

Despite the repo name, this project is **not** related to the Prisma ORM. It's a personal portfolio + CV generator for Giovanni Claudio. Don't suggest a rename on that basis (see "deliberately not doing" in the plan).

## What this repo builds

One source of truth (`content/` as YAML) drives two outputs:

1. **Portfolio website** (Astro 5 + Tailwind 4, SSG) under `site/`, targeted at GitHub Pages / `giovanniclaudio.com`. Reads the full `content/` folder unfiltered.
2. **Tailored CV PDFs** (Typst). A "profile" YAML selects and orders which experience / projects / publications / skills appear, and which pitch Markdown gets inlined. The same machinery produces the default CV that the website offers for download (`/cv.pdf`).

The bridge for the CV side is `scripts/resolve-profile.js`: it reads a profile YAML, pulls referenced files from `content/`, applies inclusive (`experience:`) or exclusive (`projects_exclude:`) selection, inlines the pitch, and writes `.build/resolved.json`. Typst then compiles `cv/template.typ` with that JSON as input. Keep this resolver as the single choke point — don't push profile-resolution logic into Typst or into Astro.

The site side does not use the resolver. It reads `content/` directly through Astro content collections (see `site/src/content.config.ts`) and singleton-file helpers in `site/src/lib/content.ts`.

## Commands

All driven by `make`:

```bash
make dev                                                    # Astro dev server (site/)
make cv                                                     # Default CV → outputs/default.pdf
make cv PROFILE=content/profiles/<your-profile>.yaml        # Tailored CV after adding another profile
make build                                                  # CV → copy PDF into site/public/ → astro build → site/dist/
make clean                                                  # rm -rf .build/ outputs/ site/dist/
```

`.build/`, `outputs/`, `site/dist/`, `site/.astro/`, and `site/public/cv.pdf` are gitignored build artefacts; never commit them.

Two profiles are committed: `content/profiles/default.yaml` (public/website CV — hides email and phone) and `content/profiles/private.yaml` (for direct applications — full contact details).

Typography: the CV and site intentionally use different type stacks.

- **CV** — `Source Sans Pro` (body) + `Roboto` (headings) + `Font Awesome 7 Free` (icons). All vendored into `cv/fonts/` and used via `--font-path cv/fonts` in the Makefile, so the CV has zero system-font dependencies. Source Sans Pro was kept over DM Sans after a side-by-side showed DM Sans rendered ~one page longer at the same font size.
- **Site** — `DM Sans` (body) + `Kanit` (display) + `DM Mono` (accent for dates, chips, code). Loaded from Google Fonts in `BaseLayout.astro` at runtime; nothing vendored.

All families are OFL-licensed. Re-fetch the CV set with `scripts/fetch-fonts.sh` if ever needed.

## CV pipeline internals

`scripts/resolve-profile.js` → `.build/resolved.json` → `typst compile --root $(CURDIR) --input data=../.build/resolved.json` → PDF.

The Typst template (`cv/template.typ`) uses the **brilliant-CV** package (`@preview/brilliant-cv:3.3.0`). It builds the `metadata` dict inline from `data.contact` / `data.bio` (no `metadata.toml` needed), and that metadata must follow the upstream structure: top-level `language` / `inject`, plus nested `layout.fonts`, `layout.header`, `layout.entry`, and `layout.footer`.

`scripts/resolve-profile.js` rewrites image paths and the bio photo to paths relative to `cv/template.typ`, not absolute filesystem paths. Keep that behavior aligned with the Makefile compile command.

Sections are rendered by iterating over the JSON arrays with Typst's `for` loops and `cv-entry()` / `cv-skill()` / `cv-honor()` calls. Publications are sorted newest-first by `year` in the resolver. The `--root $(CURDIR)` flag is required so Typst can access `content/assets/` and `.build/resolved.json`; `--font-path cv/fonts` points Typst at the vendored font set (note: when `--font-path` is set, Typst skips user-level font dirs like `~/.local/share/fonts/`, so anything the CV needs must live in `cv/fonts/`).

`scripts/copy-default-cv.js` is the glue between the two outputs: it copies `outputs/default.pdf` → `site/public/cv.pdf` so the site's "Download CV" button serves the freshly built PDF. `make build` runs it between `make cv` and `astro build`.

## Astro site internals

The site lives entirely under `site/` with its own `package.json` / `package-lock.json`. It is a fully static Astro 5 site (`output: 'static'`) with `@astrojs/sitemap` and `@astrojs/rss` integrations and Tailwind 4 via `@tailwindcss/vite`.

### Pages (`site/src/pages/`)

- `index.astro` — Home: bio, photo, social links, "Currently" card showing the latest active experience.
- `work.astro` — Work: sticky TOC on wide screens, `JobCard` per active experience with related projects grouped by `parent:`, archived roles collapsed in a `<details>`.
- `publications.astro` — Papers (sorted by `year`) and Talks (from `presentations/`, archived filtered out).
- `blog/index.astro` + `blog/[...slug].astro` — Blog list + post layout. The collection is wired and will render any Markdown file dropped into `content/blog/`; old Jekyll posts under `inputs/jokla.github.io/_posts/` are **not** being migrated.
- `about.astro` — Long bio, skills grid, education cards, interests.
- `rss.xml.ts` — RSS feed of blog posts.

There is deliberately **no `/projects` page**. Projects render under their parent experience on `/work/` via `JobCard`'s `relatedProjects` prop, grouped by the `parent:` field.

### Components (`site/src/components/`)

`JobCard`, `WorkProjectCard`, `YouTubeEmbed`, `SkillGrid`, `PublicationEntry`, `DarkModeToggle`. `Hero.astro` exists but is currently unused (Home inlines its own hero).

### Layouts (`site/src/layouts/`)

`BaseLayout.astro` handles the shell: OG / Twitter meta, canonical URL, sitemap + RSS links, Google Fonts preconnect, and a pre-paint dark-mode script that reads `localStorage.theme` or the system preference. `BlogPost.astro` wraps MD posts in a prose container.

### Content loading

- Collections defined in `site/src/content.config.ts` with Zod schemas. Loaded from `../content/<collection>/*.yaml` via `glob`. YAML dates are normalised via `dateString` (accepts number or string and stringifies them) because YAML parses `2011` as a number.
- Singletons (`bio.yaml`, `contact.yaml`, `skills.yaml`, `interests.yaml`, `extracurricular.yaml`) are **not** collections — they live in `site/src/lib/content.ts` as typed `getBio()` / `getContact()` / `getSkills()` / `getSkillGroups()` / `getInterests()` / `getExtracurricular()` helpers.
- **The `phone` visibility rule is enforced inside `getContact()`** — it destructures `phone` out before returning. Do not add other CV-only fields to `Contact` without extending that filter.
- `site/src/lib/dates.ts` mirrors the resolver's date formatting (`formatDate`, `formatRange`, `dateKey`) so site and CV render dates identically.
- `site/src/lib/location.ts` maps a trailing country in a location string (e.g. "London, UK") to a flag emoji.

### Assets

`site/src/lib/assets.ts` uses `import.meta.glob` to pre-import every `content/assets/*.{png,jpg,jpeg,svg,webp,gif}` as an `ImageMetadata`, keyed by bare filename. Components look up a YAML `src:` via `getAsset(filename)` / `requireAsset(filename)` and pass the resulting `ImageMetadata` to Astro's `<Image>` for hashing + optimisation. **Never place these images under `site/public/`** — that skips the image pipeline. The only things in `site/public/` are static files (`robots.txt`, the generated `cv.pdf`, future `favicon.svg` / `og-default.png`).

## Reference material in `inputs/`

- `inputs/jokla.github.io/` — the **existing Jekyll site** being replaced. Kept as a historical reference only; the old `_posts/` are deliberately not being migrated, the blog starts fresh in `content/blog/`.
- `inputs/Awesome-CV/` — the **existing LaTeX CV** (Awesome-CV template). Source of truth for career data that was migrated into `content/experience/`, `content/education/`, etc., and a visual reference for the Typst CV design.
- `inputs/brilliant-CV/` — the **upstream Typst package repo** cloned locally as reference material for `metadata.toml`, font expectations, and package behavior. Use it as a reference, not as a second source of truth for personal content.

These are read-only inputs — migrate data out of them, don't modify them.

## Design constraints worth respecting

The plan's "What I'm deliberately not doing" section lists choices that have already been debated — don't re-propose them:

- No framework extraction / template-ification. This is a personal repo.
- No JSON Schema validation on YAML — the Zod schemas in `content.config.ts` and a failing build are sufficient feedback.
- No config abstraction file. Site identity lives in Astro layouts; CV filename is hardcoded in the Makefile.
- No page-toggle system — delete the `.astro` file and nav link instead.
- No `/projects` page — projects surface under their parent experience on `/work/`.
- **CV-only fields like `phone` must never render on the website.** The Astro side reads `content/contact.yaml` through `getContact()`, which strips those fields; only the Typst CV includes them.
