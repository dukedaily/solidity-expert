# Solidity-Expert Refresh M1 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship M1 "Alive again" — remove repo rot, add Ch 8 historical banner, scaffold new Ch 19 稳定币 chapter, and fill the first lesson.

**Architecture:** This is a content repo (Honkit book), not application code. Each task produces a visible change to the published book at https://dukedaily.github.io/solidity-expert/. Verification is `npm run serve` + visual check in browser, not automated tests. Commits are small and independent.

**Tech Stack:** Honkit (GitBook fork), Markdown, npm. No test framework — verification = build success + sidebar visibility + rendered page check.

**Spec:** `docs/superpowers/specs/2026-04-21-solidity-expert-refresh-design.md`
**Branch:** `refresh-2026` (already created)
**Style memory:** `~/.claude/projects/-Users-duke-du-mybooks-solidity-expert/memory/feedback_writing_style.md`

**Global constraints for every task:**

- All edits stay on branch `refresh-2026`.
- Commit messages follow `<type>: <subject>` convention seen in repo history (`add day_18…`, `update SUMMARY`). No attribution trailers (user global setting already suppresses them).
- Every new/edited lesson file must match the style gate (see spec §"Style gate"). The style memory is loaded automatically when the working directory is `/Users/duke.du/mybooks/solidity-expert`.
- When in doubt about any prose decision, default to **shorter**. The author's style is terse.

---

## File Structure

**Files created:**

- `cn/19_稳定币/README.md` — chapter landing page.
- `cn/19_稳定币/01_稳定币概览.md` — first lesson (real content).
- `cn/19_稳定币/02_法币抵押稳定币.md` — stub.
- `cn/19_稳定币/03_加密抵押稳定币.md` — stub.
- `cn/19_稳定币/04_算法稳定币与UST崩盘.md` — stub.
- `cn/19_稳定币/05_收益型稳定币.md` — stub.
- `cn/19_稳定币/06_RWA稳定币与USDO.md` — stub.

**Files modified:**

- `.gitignore` — add `.env` (defense in depth; `node_modules/`, `_book`, `.DS_Store` already present).
- `cn/SUMMARY.md` — append `第十九章:稳定币` block with 6 sub-entries.
- `cn/08_项目实战-世界杯竞猜/README.md` — prepend historical banner.

**Files NOT modified (intentionally):**

- `cn/08_项目实战-世界杯竞猜/code/contracts/node_modules/` — already correctly ignored by a subdirectory `.gitignore` at `cn/08_项目实战-世界杯竞猜/code/contracts/.gitignore`. Nothing to untrack. Baseline `git ls-files | grep -c 'node_modules/'` returns `0`.

**Out of scope for M1:**

- Ghost folders `cn/17_Tools/` and `cn/18_Gas优化80 Tips/` — do not touch.
- Any other chapter content.

---

## Task 1: Pre-flight baseline

**Purpose:** Confirm the book builds cleanly _before_ any changes, so if a later task breaks the build we know the cause.

**Files:** None modified. Read-only verification.

- [ ] **Step 1: Confirm branch**

Run:

```bash
cd /Users/duke.du/mybooks/solidity-expert && git branch --show-current
```

Expected output: `refresh-2026`

If output differs, stop and ask the user — do not create / switch branches as part of this task.

- [ ] **Step 2: Confirm workspace state**

Run:

```bash
git status -s
```

Expected: may include existing uncommitted changes (e.g. `M cn/02_solidity进阶/05_call&staticcall.md`, `M en/solana_beginner/00_Tools/README.md`, `?? CLAUDE.md`). This is fine — they are pre-existing and not part of this plan. Do not stage or commit them.

- [ ] **Step 3: Confirm no node_modules are tracked**

Run:

```bash
git ls-files | grep -c 'node_modules/'
```

Expected output: `0`.

Confirms that no `node_modules/` tree is under git version control anywhere in the repo. The Ch 8 subdirectory has its own `.gitignore` handling the on-disk files. If this prints a non-zero number, stop and report — the plan assumes hygiene at the tracking layer is already correct.

- [ ] **Step 4: Confirm Ch 19 slot is free**

Run:

```bash
ls cn/ | grep -E '^(稳定币|19_)'
```

Expected: no output (empty). Confirms the old `cn/稳定币/` draft is gone and `cn/19_稳定币/` does not yet exist.

- [ ] **Step 5: Baseline build**

Run:

```bash
npm run build 2>&1 | tail -20
```

Expected: completes without error. Last lines typically include a summary like `> honkit build` followed by build stats. If the build fails, stop and report — fix baseline before proceeding.

No commit for this task.

---

## Task 2: W1 — Repo hygiene (add .env to root .gitignore)

**Purpose:** Defense-in-depth. The root `.gitignore` currently covers `node_modules/`, `_book`, `.DS_Store`, `.vscode`, `.obsidian`, and `publish.sh`, but lacks `.env` — any future chapter code subdirectory that uses dotenv could leak secrets at the root level. This is a one-line change.

**Files:**

- Modify: `.gitignore` (add `.env`)

**Note:** The original spec premise that Ch 8 had committed `node_modules` was incorrect — verified via `git ls-files | grep -c 'node_modules/'` → `0`. Files exist on disk but are ignored by a subdirectory `.gitignore` at `cn/08_项目实战-世界杯竞猜/code/contracts/.gitignore`. No untracking is needed.

- [ ] **Step 1: Add `.env` to root `.gitignore`**

Use Edit tool on `.gitignore`:

**Old content:**

```
node_modules/
_book
.DS_Store
publish.sh
.vscode
.obsidian
```

**New content:**

```
node_modules/
_book
.DS_Store
publish.sh
.vscode
.obsidian
.env
```

- [ ] **Step 2: Verify build still works**

Run:

```bash
npm run build 2>&1 | tail -20
```

Expected: completes without error, same as baseline in Task 1 Step 5.

- [ ] **Step 3: Review staged changes**

Run:

```bash
git diff --cached --stat .gitignore
```

(Nothing yet, since we haven't staged.) Then stage and show:

```bash
git add .gitignore
git diff --cached -- .gitignore
```

Expected: one-line addition (`+.env`), no other changes.

- [ ] **Step 4: Commit**

Run:

```bash
git commit -m "chore: add .env to gitignore"
```

Expected: commit succeeds. `git log --oneline -1` shows the new commit.

---

## Task 3: W8 — Ch 8 archival banner

**Files:**

- Modify: `cn/08_项目实战-世界杯竞猜/README.md` (prepend banner after existing promo quote)

- [ ] **Step 1: Read current README head**

Read `cn/08_项目实战-世界杯竞猜/README.md` lines 1–10 to confirm the promo quote block is at lines 3–5 (author-standard) and the first prose paragraph starts around line 9.

- [ ] **Step 2: Insert archival banner**

Use Edit tool. Insert the banner **between** the closing `> 职场进阶: https://dukeweb3.com` line and the first prose paragraph. The banner should itself use a blockquote (`>`) so it renders visually similar to other notes, but with bolded text to stand out.

**Old content** (match exactly, including the blank line after the promo):

```
> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com



前面介绍了很多语法内容
```

**New content:**

````
> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

> **历史项目归档（2022 世界杯）**：本章作为 DApp 全栈开发参考架构保留，不再主动维护。本地运行合约部分前需执行：
>
> ```
> cd code/contracts && npm i
> ```
>
> 前端代码请参考章节内 `code/` 目录。新读者建议先学习第 5 章（Hardhat 框架）和第 5.1 章（Foundry 框架）再回看本章。

前面介绍了很多语法内容
````

- [ ] **Step 3: Verify build**

Run:

```bash
npm run build 2>&1 | tail -10
```

Expected: completes without error.

- [ ] **Step 4: Serve and visually confirm**

Run in background:

```bash
npm run serve
```

Open http://localhost:4000/cn/08\_项目实战-世界杯竞猜/ in a browser. Confirm the banner renders as a block-quoted callout above the first paragraph, with the bolded "历史项目归档" label visible. Stop the serve process.

If you cannot open a browser in the environment, verify instead by:

```bash
grep -n '历史项目归档' cn/08_项目实战-世界杯竞猜/README.md
```

Expected: one match showing the inserted banner line.

- [ ] **Step 5: Commit**

Run:

```bash
git add cn/08_项目实战-世界杯竞猜/README.md
git commit -m "docs(ch8): mark world cup project as historical"
```

---

## Task 4: W2 — Ch 19 稳定币 scaffold (chapter dir, README, 6 stubs, SUMMARY wiring)

**Files:**

- Create: `cn/19_稳定币/README.md`
- Create: `cn/19_稳定币/01_稳定币概览.md` (stub — real content lands in Task 5)
- Create: `cn/19_稳定币/02_法币抵押稳定币.md` (stub)
- Create: `cn/19_稳定币/03_加密抵押稳定币.md` (stub)
- Create: `cn/19_稳定币/04_算法稳定币与UST崩盘.md` (stub)
- Create: `cn/19_稳定币/05_收益型稳定币.md` (stub)
- Create: `cn/19_稳定币/06_RWA稳定币与USDO.md` (stub)
- Modify: `cn/SUMMARY.md` (append Ch 19 block)

**Style reminder:** every file begins with the promo quote block, then title, then content. No exceptions.

- [ ] **Step 1: Create chapter README**

Create `cn/19_稳定币/README.md` with this exact content:

```markdown
# 第十九章：稳定币

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

稳定币是加密市场的"美元"，也是链上金融基础设施的底座。本章按抵押模式分类，逐一拆解主流稳定币的机制、风险与设计权衡，并以 RWA 稳定币 USDO 为案例收尾。

## 目录

1. [第1节：稳定币概览](01_稳定币概览.md)
2. [第2节：法币抵押稳定币](02_法币抵押稳定币.md)
3. [第3节：加密抵押稳定币](03_加密抵押稳定币.md)
4. [第4节：算法稳定币与UST崩盘](04_算法稳定币与UST崩盘.md)
5. [第5节：收益型稳定币](05_收益型稳定币.md)
6. [第6节：RWA稳定币与USDO](06_RWA稳定币与USDO.md)
```

- [ ] **Step 2: Create 6 lesson stubs**

Each stub has exactly this structure — promo quote, title, one-line topic sentence, TODO marker. Create each file with the content shown.

**File: `cn/19_稳定币/01_稳定币概览.md`** (will be overwritten with real content in Task 5 — create as stub for now so SUMMARY wiring works):

```markdown
# 第1节：稳定币概览

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

按抵押模式对稳定币做整体分类，看清市场格局与主要玩家。

<!-- TODO: content -->
```

**File: `cn/19_稳定币/02_法币抵押稳定币.md`**:

```markdown
# 第2节：法币抵押稳定币

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

USDT 与 USDC 的铸销流程、储备金构成与审计机制。

<!-- TODO: content -->
```

**File: `cn/19_稳定币/03_加密抵押稳定币.md`**:

```markdown
# 第3节：加密抵押稳定币

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

DAI 的超额抵押模型、CDP / Vault 结构与清算机制。

<!-- TODO: content -->
```

**File: `cn/19_稳定币/04_算法稳定币与UST崩盘.md`**:

```markdown
# 第4节：算法稳定币与UST崩盘

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

算法锚定机制、死亡螺旋成因，以及 Terra / UST 崩盘复盘。

<!-- TODO: content -->
```

**File: `cn/19_稳定币/05_收益型稳定币.md`**:

```markdown
# 第5节：收益型稳定币

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

Ethena USDe 的 delta-neutral 架构与 funding-rate 套利逻辑。

<!-- TODO: content -->
```

**File: `cn/19_稳定币/06_RWA稳定币与USDO.md`**:

```markdown
# 第6节：RWA稳定币与USDO

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

代币化国债作为抵押资产、USDO 的架构案例与合规要点。

<!-- TODO: content -->
```

- [ ] **Step 3: Wire Ch 19 into SUMMARY.md**

Append the Ch 19 block to `cn/SUMMARY.md`. The existing file ends with the Ch 16 block — append directly after it. Match the exact indentation used elsewhere (4 spaces for sub-entries).

Use Edit tool. Insert **at end of file**, keeping the trailing newline hygienic.

**Old content** (match the last line of Ch 16 verbatim):

```
    * [第16节: compound V2部署步骤文档](16_主流项目部署文档/03_compoundV2部署.md)
```

**New content:**

```
    * [第16节: compound V2部署步骤文档](16_主流项目部署文档/03_compoundV2部署.md)
* [第十九章:稳定币](19_稳定币/README.md)
    * [第1节:稳定币概览](19_稳定币/01_稳定币概览.md)
    * [第2节:法币抵押稳定币](19_稳定币/02_法币抵押稳定币.md)
    * [第3节:加密抵押稳定币](19_稳定币/03_加密抵押稳定币.md)
    * [第4节:算法稳定币与UST崩盘](19_稳定币/04_算法稳定币与UST崩盘.md)
    * [第5节:收益型稳定币](19_稳定币/05_收益型稳定币.md)
    * [第6节:RWA稳定币与USDO](19_稳定币/06_RWA稳定币与USDO.md)
```

- [ ] **Step 4: Build and verify**

Run:

```bash
npm run build 2>&1 | tail -15
```

Expected: completes without error. Honkit warnings about unused pages are OK.

- [ ] **Step 5: Serve and visually confirm**

Run in background:

```bash
npm run serve
```

Open http://localhost:4000/ in a browser. Confirm:

1. Sidebar shows `第十九章:稳定币` below Ch 16.
2. Expanding it reveals the 6 sub-lessons.
3. Clicking `第1节:稳定币概览` loads the stub page.

Stop the serve process.

Terminal-only fallback:

```bash
grep -c '19_稳定币' cn/SUMMARY.md
ls cn/19_稳定币/
```

Expected: `grep` prints `7` (1 chapter + 6 lessons); `ls` shows 7 files.

- [ ] **Step 6: Commit**

Run:

```bash
git add cn/19_稳定币/ cn/SUMMARY.md
git commit -m "feat(ch19): add stablecoin chapter scaffold"
```

---

## Task 5: W2.1 — Fill 第1节 稳定币概览

**Files:**

- Modify: `cn/19_稳定币/01_稳定币概览.md` (replace stub body with full lesson content)

**Style checkpoint before writing:** re-read `cn/01_solidity基础/01_helloworld.md` and `cn/02_solidity进阶/05_call&staticcall.md` to recalibrate to the author's voice. The first is minimal (18 lines). The second is code-heavy with short numbered prose. The lesson below is a non-code overview lesson, so it will look different from those — closer in density to Ch 15 entries — but still: short sentences, bold for emphasis, numbered list for the taxonomy, no long paragraphs.

- [ ] **Step 1: Replace the stub with real content**

Overwrite `cn/19_稳定币/01_稳定币概览.md` with this exact content:

```markdown
# 第1节：稳定币概览

> 小白入门：https://github.com/dukedaily/solidity-expert ，欢迎star转发，文末加V入群。
>
> 职场进阶: https://dukeweb3.com

稳定币是加密市场的"美元"：日交易量超 650 亿美元，总市值突破 2400 亿美元。按抵押模式可分为四类：

1. **法币抵押型**：以 USDT、USDC 为代表，发行方持有等值法币或短债作为储备。市占率最高。
2. **加密抵押型**：以 DAI 为代表，用 ETH 等加密资产超额抵押铸币。去中心化，但在极端行情下易清算。
3. **算法型**：以 UST（已崩盘）为代表，依赖套利与燃烧机制维持锚定。风险最高。
4. **RWA（现实资产）型**：以 USDO、BUIDL 为代表，抵押代币化国债等真实资产。新兴类别，监管友好。

## 市场格局

| 稳定币 | 发行方   | 市值（2025） | 类型                    |
| ------ | -------- | ------------ | ----------------------- |
| USDT   | Tether   | ~1500 亿     | 法币抵押                |
| USDC   | Circle   | ~610 亿      | 法币抵押                |
| USDe   | Ethena   | ~50 亿       | 收益型（delta-neutral） |
| DAI    | MakerDAO | ~41 亿       | 加密抵押                |

近两年变化：USDT + USDC 合计份额从 2023 年的 **92% 降至 85%**，**收益型与 RWA 型快速崛起**。

稳定币正从"交易媒介"演变为"链上美元基础设施"。后续章节将逐类深入其机制、风险与设计权衡。
```

- [ ] **Step 2: Style self-check**

Before moving on, re-read the file you just wrote. Confirm:

1. Promo quote block present at top, exactly matching the boilerplate.
2. Title is `# 第1节：稳定币概览` (Chinese colon `：`, not `:`).
3. Every prose sentence is short (target ≤ 30 Chinese characters per clause).
4. No "让我来解释 / 我们将学习" framing.
5. Bold used only on high-signal terms: the four taxonomy labels + the market-share movement.
6. Total lines ≤ 30 body lines (excluding the promo quote).

If any check fails, edit and recheck.

- [ ] **Step 3: Build and verify**

Run:

```bash
npm run build 2>&1 | tail -10
```

Expected: clean build.

- [ ] **Step 4: Serve and visually confirm**

Run in background:

```bash
npm run serve
```

Open http://localhost:4000/cn/19*稳定币/01*稳定币概览.html in a browser. Confirm:

1. Title renders as `第1节：稳定币概览`.
2. Numbered list (1–4) renders with bolded labels.
3. Market table renders with 4 rows and aligned columns.
4. No broken Markdown (stray backticks, unclosed blockquote, etc.).

Stop the serve process.

Terminal-only fallback:

```bash
wc -l cn/19_稳定币/01_稳定币概览.md
grep -c '^##' cn/19_稳定币/01_稳定币概览.md
```

Expected: wc line count in the 20–35 range; grep prints `1` (one `## 市场格局` heading).

- [ ] **Step 5: Commit**

Run:

```bash
git add cn/19_稳定币/01_稳定币概览.md
git commit -m "feat(ch19): add 第1节 稳定币概览"
```

---

## Task 6: M1 completion verification

**Purpose:** Sanity-check that M1 objectives are met before declaring done.

**Files:** None modified.

- [ ] **Step 1: Confirm commit series on refresh-2026**

Run:

```bash
git log --oneline main..HEAD
```

Expected: shows the commits added in this plan (hygiene, Ch 8 banner, Ch 19 scaffold, 第1节 content) plus the earlier spec commits. No stray commits.

- [ ] **Step 2: Confirm no leaked state**

Run:

```bash
git status -s
```

Expected: may show only the pre-existing un-touched modifications from Task 1 Step 2 (`cn/02_solidity进阶/05_call&staticcall.md`, `en/solana_beginner/00_Tools/README.md`, `CLAUDE.md`). No new unstaged file from this plan.

- [ ] **Step 3: Confirm all M1 done-enough signals**

Open http://localhost:4000/ after `npm run serve` and verify:

1. `第十九章:稳定币` appears in sidebar with 6 lessons listed.
2. Clicking `第1节:稳定币概览` shows real content (not a TODO stub).
3. Clicking `第八章:世界杯竞猜` shows the historical banner above the first paragraph.
4. No `node_modules/` tree is tracked in git (confirm: `git ls-files | grep -c 'node_modules/'`; expected `0` — unchanged from baseline, which was already `0`).

- [ ] **Step 4: Report M1 complete**

Report to the user:

> **M1 complete.** Commits on `refresh-2026`:
>
> - `chore: add .env to gitignore`
> - `docs(ch8): mark world cup project as historical`
> - `feat(ch19): add stablecoin chapter scaffold`
> - `feat(ch19): add 第1节 稳定币概览`
>
> Next actions: (a) review the branch, (b) merge to `main` when ready, (c) decide whether to pursue M2 (W2 lessons 2–6, Foundry, ethers v6) now or later.

Do not merge to `main` automatically — leave that for the user.
