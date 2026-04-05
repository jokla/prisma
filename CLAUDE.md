# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

**Phase 1 (content migration) is done.** **Phase 2 (CV pipeline) is implemented** — `Makefile`, `package.json`, `package-lock.json`, `scripts/resolve-profile.js`, `scripts/copy-default-cv.js`, and `cv/template.typ` all exist. Run `npm install && make cv` to produce `outputs/default.pdf`. The Astro site under `site/` does not exist yet (Phase 3), so `make dev` and `make build` are not usable yet.

`content/` holds the migrated YAML collections, the default pitch, and related assets — see the "Content conventions" section of `portfolio-plan.md` for the schema decisions (especially `summary` vs `highlights`, `archived:` / `archived_highlights:`, `parent:` on projects, and the flat skills list with `group` field).

Despite the repo name, this project is **not** related to the Prisma ORM. It's a personal portfolio + CV generator for Giovanni Claudio. Don't suggest a rename on that basis (see "deliberately not doing" in the plan).

## What this repo builds

One source of truth (`content/` as YAML) is intended to drive two outputs. In the current branch state, only the CV pipeline is implemented:

1. **Portfolio website** (Astro + Tailwind, SSG), planned for Phase 3 and eventual deployment to GitHub Pages at `giovanniclaudio.com`. It will render the full `content/` folder unfiltered.
2. **Tailored CV PDFs** (Typst). A "profile" YAML selects and orders which experience / projects / publications / skills appear, and which pitch Markdown gets inlined. The same machinery produces the default CV that the website offers for download.

The bridge between the two is `scripts/resolve-profile.js`: it reads a profile YAML, pulls referenced files from `content/`, applies inclusive (`experience:`) or exclusive (`projects_exclude:`) selection, inlines the pitch, and writes `.build/resolved.json`. Typst then compiles `cv/template.typ` with that JSON as input. Keep this resolver as the single choke point — don't push profile-resolution logic into Typst or into Astro.

## Commands

All driven by `make`:

```bash
make dev                                                    # Planned Phase 3 target; requires site/
make cv                                                     # Default CV → outputs/default.pdf
make cv PROFILE=content/profiles/<your-profile>.yaml        # Tailored CV after adding another profile
make build                                                  # Planned full build; currently depends on future site/
make clean                                                  # rm -rf .build/ outputs/ site/dist/
```

`.build/` and `outputs/` are gitignored build artefacts; never commit them.

The only committed profile on this branch is `content/profiles/default.yaml`.

Local typography matters for this repo. The current template is tuned for `Roboto` headings, `Source Sans Pro` body text, and Font Awesome 7 desktop OTFs for icons. Upstream `brilliant-CV` recommends `Source Sans 3`; that is an acceptable alternative, but the checked-in template currently uses `Source Sans Pro` by choice.

## CV pipeline internals

`scripts/resolve-profile.js` → `.build/resolved.json` → `typst compile --root $(CURDIR) --input data=../.build/resolved.json` → PDF.

The Typst template (`cv/template.typ`) uses the **brilliant-CV** package (`@preview/brilliant-cv:3.3.0`). It builds the `metadata` dict inline from `data.contact` / `data.bio` (no `metadata.toml` needed), and that metadata must follow the upstream structure: top-level `language` / `inject`, plus nested `layout.fonts`, `layout.header`, `layout.entry`, and `layout.footer`.

`scripts/resolve-profile.js` rewrites image paths and the bio photo to paths relative to `cv/template.typ`, not absolute filesystem paths. Keep that behavior aligned with the Makefile compile command.

Sections are rendered by iterating over the JSON arrays with Typst's `for` loops and `cv-entry()` / `cv-skill()` / `cv-honor()` calls. The `--root $(CURDIR)` flag is required so Typst can access `content/assets/` and `.build/resolved.json`.

## Reference material in `inputs/`

- `inputs/jokla.github.io/` — the **existing Jekyll site** being replaced. Source of truth for bio text, project write-ups, and blog posts to migrate into `content/` (see plan's "Blog Migration" section for the `_posts/` → `content/blog/` conversion rules).
- `inputs/Awesome-CV/` — the **existing LaTeX CV** (Awesome-CV template). Source of truth for career data to migrate into `content/experience/`, `content/education/`, etc., and a visual reference for the Typst CV design.
- `inputs/brilliant-CV/` — the **upstream Typst package repo** cloned locally as reference material for `metadata.toml`, font expectations, and package behavior. Use it as a reference, not as a second source of truth for personal content.

These are read-only inputs — migrate data out of them, don't modify them.

## Design constraints worth respecting

The plan's "What I'm deliberately not doing" section lists choices that have already been debated — don't re-propose them:

- No framework extraction / template-ification. This is a personal repo.
- No JSON Schema validation on YAML — a failing build is sufficient feedback.
- No config abstraction file. Site identity lives in Astro layouts; CV filename is hardcoded in the Makefile.
- No page-toggle system — delete the `.astro` file and nav link instead.
- **CV-only fields like `phone` must never render on the website.** The Astro side reads `content/contact.yaml` but must skip those fields; only the Typst CV includes them.
