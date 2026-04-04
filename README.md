# Giovanni Claudio — Portfolio & CV

Personal repo for generating two outputs from one YAML content source:

1. A tailored Typst CV PDF.
2. An Astro portfolio site to be added in Phase 3.

Phase 1 content migration is done. Phase 2 CV generation is working. The Astro site is not scaffolded yet.

## Current Status

- `content/` is the source of truth for experience, education, projects, publications, presentations, skills, contact details, and pitches.
- `scripts/resolve-profile.js` resolves a profile YAML into `.build/resolved.json`.
- `cv/template.typ` renders that JSON using `@preview/brilliant-cv:3.3.0`.
- `make cv` builds `outputs/default.pdf`.

## Requirements

- Node.js 20
- Typst 0.14 or newer
- Local fonts:
  - `Roboto`
  - `Source Sans Pro` for body text
  - Font Awesome 7 desktop OTF fonts for icons

`brilliant-CV` upstream recommends `Source Sans 3`; this repo currently keeps `Source Sans Pro` after local comparison.

## Quick Start

```bash
npm install
make cv
```

Result:

```bash
outputs/default.pdf
```

To build a tailored CV:

```bash
make cv PROFILE=content/profiles/surgical-robotics-lead.yaml
```

## How It Works

```text
content/ + content/profiles/*.yaml
  -> scripts/resolve-profile.js
  -> .build/resolved.json
  -> typst compile
  -> outputs/*.pdf
```

Important implementation detail: Typst resolves `sys.inputs.at("data")` relative to `cv/template.typ`, so the Makefile uses:

```bash
typst compile --root $(CURDIR) --input data=../.build/resolved.json cv/template.typ outputs/default.pdf
```

The resolver also rewrites image paths to be relative to `cv/template.typ`.

## Repository Layout

```text
content/      Personal data in YAML and Markdown
cv/           Typst template
scripts/      Profile resolver and build helpers
inputs/       Read-only reference material
outputs/      Generated PDFs
.build/       Intermediate resolved JSON
```

## Reference Material

- `inputs/Awesome-CV/`: prior LaTeX CV used as source/reference during migration
- `inputs/brilliant-CV/`: upstream Typst package repo used to verify metadata shape, font configuration, and troubleshooting guidance
- `inputs/jokla.github.io/`: prior Jekyll portfolio site

These folders are reference inputs only. Do not edit them as part of normal project work.

## Commands

```bash
make cv
make cv PROFILE=content/profiles/default.yaml
make build
make clean
```

`make build` is intended for the future Astro site build as well. Right now, only the CV pipeline is fully implemented.