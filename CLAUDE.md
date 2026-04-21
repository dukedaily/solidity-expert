# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is **not a software project** — it is a Honkit (GitBook fork) book: a Solidity / EVM / DApp full-stack tutorial published at https://dukedaily.github.io/solidity-expert/. All content lives in Markdown files; there is no application source code, test suite, or CI. Work in this repo is overwhelmingly **authoring, editing, and reorganizing Markdown**, plus occasional build/preview to verify rendering.

## Commands

Run from the repo root. `npm install` once, then:

- `npm run serve` — local preview at http://localhost:4000 with live reload (Honkit).
- `npm run build` — render the book into `_book/`.
- `npm run deploy` — publish `_book/` to GitHub Pages via `gh-pages`.
- `./publish.sh` — convenience wrapper: clean `_book/`, build, deploy.

There are no tests, linters, or type checks. `_book/` and `node_modules/` are gitignored build output — never edit files there.

## Content architecture

Two language roots share one Honkit instance, selected via the `language-picker` plugin:

- `cn/` — primary, complete Chinese tutorial (00_blockchain基础 … 18_Gas优化80 Tips).
- `en/` — partial English content (currently only `solana_beginner/`).
- `LANGS.md` (root) — declares the two languages to Honkit.
- `book.json` (root) — Honkit plugin + config (GA, GitHub link, language picker, etc.).

Each language root has its own `README.md` (cover page) and `SUMMARY.md` (table of contents / sidebar). Honkit **only renders pages listed in `SUMMARY.md`** — a Markdown file that isn't linked from SUMMARY will exist on disk but won't appear in the built book. When adding a new chapter or section, you must also add its entry to the matching `SUMMARY.md`.

Chapter folders follow a consistent convention:

- `NN_<topic>/` (e.g. `cn/02_solidity进阶/`) with a `README.md` landing page and numbered lesson files `NN_<slug>.md`.
- Images live in a sibling `assets/` folder (most commonly `cn/assets/`); reference them with relative paths from the Markdown file.
- Filenames and folder names use Chinese characters freely — preserve them verbatim in links and `SUMMARY.md` entries.

When a section contains code snippets, they are illustrative Solidity / JS samples for the tutorial — they are not built or executed by the book pipeline. Treat them as prose: accuracy matters, but there is no compiler to satisfy.

## Authoring conventions (observed in existing content)

- Follow the numbering scheme of the surrounding chapter when adding lessons; don't renumber existing files (links in `SUMMARY.md` and cross-references will break).
- New top-level areas (e.g. the in-progress `cn/稳定币/`) only become visible in the rendered book once they are wired into `cn/SUMMARY.md`.
- The `honkit-plugin-mermaid` plugin is enabled via `package.json` — Mermaid diagrams in fenced ```mermaid blocks render in the built book.
- Do not add attribution / "Generated with" footers to Markdown pages — the book is authored voice.

## What to avoid

- Do not add tests, CI, linters, or application scaffolding — this repo intentionally has none.
- Do not edit `_book/`, `node_modules/`, or `package-lock.json` directly.
- Do not rename or restructure chapter folders without updating every referencing entry in `SUMMARY.md` and any inter-chapter links.
