# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

**Phase 1 (content migration) is done.** `content/` holds 35 YAML files + 1 Markdown pitch + 8 images — see the "Content conventions" section of `portfolio-plan.md` for the schema decisions (especially `summary` vs `highlights`, `archived:` / `archived_highlights:`, `parent:` on projects, and the flat skills list with `group` field). The repo is now ready for **Phase 2 (CV pipeline)**: forking a Typst Universe template into `cv/template.typ` and writing `scripts/resolve-profile.js`. The Astro site under `site/` and the Makefile still don't exist — follow the plan's structure rather than inventing a new one, and keep the plan updated if the approach shifts.

Despite the repo name, this project is **not** related to the Prisma ORM. It's a personal portfolio + CV generator for Giovanni Claudio. Don't suggest a rename on that basis (see "deliberately not doing" in the plan).

## What this repo builds

One source of truth (`content/` as YAML) → two outputs:

1. **Portfolio website** (Astro + Tailwind, SSG) deployed to GitHub Pages at `giovanniclaudio.com`. Renders the full `content/` folder unfiltered.
2. **Tailored CV PDFs** (Typst). A "profile" YAML selects and orders which experience / projects / publications / skills appear, and which pitch Markdown gets inlined. The same machinery produces the default CV that the website offers for download.

The bridge between the two is `scripts/resolve-profile.js`: it reads a profile YAML, pulls referenced files from `content/`, applies inclusive (`experience:`) or exclusive (`projects_exclude:`) selection, inlines the pitch, and writes `.build/resolved.json`. Typst then compiles `cv/template.typ` with that JSON as input. Keep this resolver as the single choke point — don't push profile-resolution logic into Typst or into Astro.

## Commands

All driven by `make` (see plan for the Makefile). Once implemented:

```bash
make dev                                                    # Astro dev server
make cv                                                     # Default CV → outputs/default.pdf
make cv PROFILE=content/profiles/surgical-robotics-lead.yaml  # Tailored CV
make build                                                  # CV + copy PDF into site/public + Astro build
make clean                                                  # rm -rf .build/ outputs/ site/dist/
```

`.build/` and `outputs/` are gitignored build artefacts; never commit them.

## Reference material in `inputs/`

- `inputs/jokla.github.io/` — the **existing Jekyll site** being replaced. Source of truth for bio text, project write-ups, and blog posts to migrate into `content/` (see plan's "Blog Migration" section for the `_posts/` → `content/blog/` conversion rules).
- `inputs/Awesome-CV/` — the **existing LaTeX CV** (Awesome-CV template). Source of truth for career data to migrate into `content/experience/`, `content/education/`, etc., and a visual reference for the Typst CV design.

These are read-only inputs — migrate data out of them, don't modify them.

## Design constraints worth respecting

The plan's "What I'm deliberately not doing" section lists choices that have already been debated — don't re-propose them:

- No framework extraction / template-ification. This is a personal repo.
- No JSON Schema validation on YAML — a failing build is sufficient feedback.
- No config abstraction file. Site identity lives in Astro layouts; CV filename is hardcoded in the Makefile.
- No page-toggle system — delete the `.astro` file and nav link instead.
- **CV-only fields like `phone` must never render on the website.** The Astro side reads `content/contact.yaml` but must skip those fields; only the Typst CV includes them.
