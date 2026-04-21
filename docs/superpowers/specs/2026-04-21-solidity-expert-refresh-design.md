# Solidity-Expert 2026 Refresh — Design

**Date:** 2026-04-21
**Branch:** `refresh-2026`
**Author:** duke (dukedaily)
**Target milestone for this plan:** **M1 "Alive again"**

## Context

`solidity-expert` is a Honkit-based Chinese-language Solidity / DApp tutorial published at https://dukedaily.github.io/solidity-expert/. The repo has 18 authored chapters (`cn/00_blockchain基础` … `cn/18_Gas优化80 Tips`), with last substantive activity in August 2024. Four years of blockchain evolution have created visible rot:

- Foundry chapter (`05.1_foundry框架`) is a 1-file stub while Foundry now dominates Solidity development.
- ethers chapter (`06_ethers`) has 3 lessons, no mention of v6 (breaking migration from v5 is mandatory now).
- Protocol deployment chapter (`16_主流项目部署文档`) covers only UniV2 / AaveV2 / CompoundV2 — V3 / V4 exist and are what people deploy in 2026.
- `cn/08_项目实战-世界杯竞猜/code/contracts/node_modules/` is **committed into git** (includes Truffle deps) — repo hygiene bomb.
- Ghost chapter folders `17_Tools` and `18_Gas优化80 Tips` exist on disk but are not wired into `SUMMARY.md` — not rendered.
- Ch 15 "hot tech tracking" contains an `anyswap` lesson (project effectively defunct); landscape moved on (ERC-4337 production, restaking, intents).
- Fundamentals chapters (0–4) are structurally sound, mostly pragma `^0.8.13` — readable, not embarrassing.

The author is at OpenEden (RWA-backed tokenized treasury stablecoin issuer, USDO). This repo is a **public expertise signal** — colleagues, recruiters, and ecosystem contacts land here via `dukeweb3.com` and social.

## Goals

1. Remove signals that the repo is abandoned.
2. Put current expertise (stablecoins / RWA) on the page.
3. Ship artifacts in small independent units, pickable up at any time — no fixed cadence.
4. Preserve existing author voice. Every new/edited lesson must match the established style (see "Style gate").

## Non-goals (this pass)

- Full rewrite of fundamentals chapters (0–4 stay structurally intact).
- English translation of Chinese chapters.
- Platform migration Honkit → Docusaurus / VitePress.
- Rewriting the World Cup (Ch 8) project code.
- Video or code-sandbox integrations.
- Upgrading every pragma. Only upgrade when the lesson touches a feature where version matters.

## Style gate (enforced across all content work)

Every new or edited lesson must match the existing voice. Patterns observed from `cn/01_solidity基础/01_helloworld.md`, `cn/02_solidity进阶/05_call&staticcall.md`, `cn/04_合约攻击/01_重入攻击.md`:

- Opens with promo quote block:
  ```
  > 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
  >
  > 职场进阶: https://dukeweb3.com
  ```
- Title: `# 第N节：<Topic>` (Chinese colon `：`).
- Minimal prose. Code carries the load. `01_helloworld.md` is 18 lines total.
- Numbered lists for enumerations, one sentence per item.
- `**bold**` for the one term the reader must remember.
- Code fences use ` ```js ` (not `solidity`). SPDX + pragma every time.
- Sub-headings sparse — typically only `## 完整demo:` for a closing example.
- Declarative tone. No "let me explain", no "in this lesson we will learn".
- Chinese prose, English code comments (preserve source-material comments).
- Length target: basics lesson 20–60 lines; advanced lesson with multiple demos 100–200 lines.

Saved to memory so the style is enforced across future sessions.

## Workstreams (full catalog)

Each workstream is independently shippable. Sizes are rough. **M1 pulls from W1, W2, and W8 only**; the rest are parked for M2 / M3.

| #   | Workstream                        | Deliverable                                                                                     | Size | Milestone              |
| --- | --------------------------------- | ----------------------------------------------------------------------------------------------- | ---- | ---------------------- |
| W1  | Repo hygiene                      | `node_modules/` removed from Ch 8 `code/`; `.gitignore` tightened; `npm run serve` still builds | S    | **M1**                 |
| W2  | Stablecoin chapter (new Ch 19)    | New chapter with scaffold + progressively filled lessons                                        | L    | **M1 (partial) → M2**  |
| W3  | Foundry chapter (Ch 5.1)          | Stub → 6–8 lessons (quickstart, forge test, cheatcodes, fork, invariants, deploy, verify)       | M–L  | M2                     |
| W4  | ethers v6 rewrite (Ch 6)          | v5→v6 migration page + refreshed code samples                                                   | M    | M2                     |
| W5  | V3 / V4 protocol addendum (Ch 16) | UniV3, UniV4, AaveV3, CompoundV3 added; V2 marked "legacy reference"                            | M    | M3                     |
| W6  | Spot-fix sweep Ch 0–4             | Dead-link fixes, deprecated-syntax fixes, tool-version refreshes                                | M    | M3 (background filler) |
| W7  | Ch 15 prune + extend              | Remove anyswap; date-stamp existing entries; add AA / EIP-7702, restaking, intents              | M    | M3                     |
| W8  | Ch 8 archival                     | "Historical project (2022 World Cup)" banner on chapter README; no code rewrite                 | S    | **M1**                 |

## Milestones (stop-points)

- **M1 "Alive again":** W1 + W8 + W2 chapter scaffold + W2.1 first real lesson shipped. Repo visibly refreshed. _This plan targets M1._
- **M2 "Current expertise visible":** M1 + W2 lessons 2–6 complete + W3 Foundry complete + W4 ethers v6 complete. The (ii) signal is fully there.
- **M3 "Refresh done":** W5 + W6 + W7 complete. Step back.

## M1 delivery plan

All work stays on branch `refresh-2026`. Commits land incrementally. No fixed schedule.

### M1.1 — Repo hygiene (W1)

**Actions:**

1. Inspect `cn/08_项目实战-世界杯竞猜/code/` structure; identify committed `node_modules` directories.
2. `git rm -r --cached` each committed `node_modules/` tree.
3. Add / tighten `.gitignore` — ensure `node_modules/`, `.env`, build artifacts, OS junk (`.DS_Store`) are ignored everywhere.
4. Verify `npm run serve` still builds the book.
5. Verify Ch 8 code subdirs still usable via `npm i` after fresh clone.

**Commit:** `chore: remove committed node_modules, tighten gitignore`

**Risks & mitigations:**

- Removing node_modules does not rewrite history — historical clones still contain them. That is acceptable. No `git filter-repo` / force-push in M1.
- If `npm run serve` breaks because a node_modules path was referenced by an include plugin, revert and add the path to `.gitignore` only (no `git rm`). The goal is "no more new `node_modules` commits," not a history rewrite.

### M1.2 — Ch 8 archival banner (W8)

**Actions:**

1. Prepend a short banner to `cn/08_项目实战-世界杯竞猜/README.md` noting: historical 2022 World Cup project, not actively maintained, `cd code/contracts && npm i` required for local runs, intended as a reference architecture.

**Commit:** `docs(ch8): mark world cup project as historical`

### M1.3 — Stablecoin chapter scaffold (W2 structural)

**Chapter slot:** `cn/19_稳定币/` — skips the unwired ghost folders `17_Tools` and `18_Gas优化80 Tips` to avoid collision. Wired as `第十九章: 稳定币` in `cn/SUMMARY.md`.

**Topic list** (6 lessons; progresses simple → complex, ends on USDO / RWA for (ii) signal):

| #   | File                        | Topic                                                       |
| --- | --------------------------- | ----------------------------------------------------------- |
| 1   | `01_稳定币概览.md`          | 分类 (法币抵押 / 加密抵押 / 算法 / RWA)、市场格局、主流玩家 |
| 2   | `02_法币抵押稳定币.md`      | USDT / USDC 机制、储备金、铸销与审计                        |
| 3   | `03_加密抵押稳定币.md`      | DAI、超额抵押、CDP / Vault、清算机制                        |
| 4   | `04_算法稳定币与UST崩盘.md` | 算法锚定、死亡螺旋、Terra 复盘                              |
| 5   | `05_收益型稳定币.md`        | Ethena USDe、delta-neutral、funding-rate 套利               |
| 6   | `06_RWA稳定币与USDO.md`     | 代币化国债、USDO 案例、合规考量                             |

**Scaffold deliverables:**

1. `cn/19_稳定币/README.md` — chapter landing page with promo quote, chapter title, one-paragraph chapter overview, TOC of the 6 lessons.
2. `cn/19_稳定币/01_稳定币概览.md` … `06_RWA稳定币与USDO.md` — each stub contains promo quote, `# 第N节：<title>`, one-line topic sentence, `<!-- TODO: content -->` marker.
3. `cn/SUMMARY.md` — add `第十九章: 稳定币` block with 6 sub-entries.

**Commit:** `feat(ch19): add stablecoin chapter scaffold and topic list`

### M1.4 — Stablecoin lesson 1 (W2.1)

**Actions:**

1. Fill `cn/19_稳定币/01_稳定币概览.md` with concise overview matching style gate:
   - Taxonomy (4 types with one-line description each).
   - Market snapshot as a small table (top 5 by market cap, one-line role per entry).
   - Short closing paragraph framing why stablecoins matter.
2. No market report dump. No over-explanation.

**Commit:** `feat(ch19): add 第1节 稳定币概览`

## Verification (before each commit)

- `npm run serve` renders cleanly — no broken includes, no mermaid errors.
- New / changed chapters show up in the sidebar.
- New lesson pages render; images resolve.
- `git status` shows no `node_modules/`, `.DS_Store`, or build artifacts staged.

## Done-enough signal for M1

A visitor landing on https://dukedaily.github.io/solidity-expert/ sees:

- `第十九章: 稳定币` in the sidebar with 6 topics listed.
- The first stablecoin lesson is filled with real content in the author's voice.
- The World Cup chapter carries a "historical" banner, no longer reads as half-broken.
- The repo no longer ships with `node_modules` in the tree.
- The last-commit date is recent.

## Deferred (future considerations, out of M1 scope)

- W2 lessons 2–6 (filled over time per elastic budget).
- W3 Foundry chapter expansion.
- W4 ethers v6 rewrite.
- W5 V3 / V4 protocol addendum.
- W6 Ch 0–4 spot-fix sweep.
- W7 Ch 15 prune + extend.
- Ghost chapter folders `17_Tools` and `18_Gas优化80 Tips` — not touched in M1. Decision deferred (wire in, delete, or keep as draft).
- English translation, Honkit migration, video integration.
