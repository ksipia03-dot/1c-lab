# Plan: ITS Offline Docs Phase 2 — Max Knowledge Dump

**Created:** 2026-08-26
**Orchestration:** orch-its-docs-phase2-max
**Goal:** Overnight full-max ITS offline knowledge dump — complete platform DB mirrors, built-in language leaf corpus ×3 versions, methodology/BSP/standards, ERP 2.5 ITS DB, AI-agents KB, quality remirror, lab robocopy, and morning report. No mid-run approval gates (user offline overnight).
**Total Tasks:** 9
**Priority:** Critical
**Status:** 🔄 Ready
**Mode:** documentation (permanent plan)
**Predecessor:** orch-its-docs-phase1 (`ai_docs/develop/plans/2026-08-26-its-offline-docs-phase1.md`) — completed

## Scope Boundaries

### In scope
- Reuse Phase 1 auth (`.dev.env` `ITS_LOGIN` / `ITS_PASSWORD`) and scripts under `.cursor/workspace/completed/orch-its-docs-phase1/`
- Unified resume-capable mirror runner + discovery TOC sizing + queue
- **Full** mirrors: `v8327doc`, `v854doc`, `v851doc`, `metod8dev`, `v8std`, `bsp`, `erp25doc`
- Built-in language corpus: `docs/its/builtin-language/` — all ch.4 leaves ×3 platform versions, queries, metod hits, discovery «Описание встроенного языка», local syntax-helper, README
- AI-agents KB: code.1c.ai + ITS AI materials + index
- Quality remirror pass + `AGENT-OFFLINE.md` / top-level README updates
- Final robocopy to `C:\1C-Lab\docs\its\` + morning report + archive workspace

### Out of scope
- Deleting or rewriting `docs/1c-erp-25/` (additive ITS tree only)
- Replacing MCP `docsearch`/`docinfo` with offline-only search
- Asking user for mid-run approvals (execute fully overnight)
- Committing secrets or writing passwords into tracked files

### Security constraints
- Password **never** in `docs/`, plans beyond key names, reports, commit messages, or git-tracked files
- Values only in `.dev.env` (gitignored)
- Cookie jars / session files stay under workspace (not committed)

## Sources (Phase 2 targets)

| ID | Scope | Target path | Notes |
|----|--------|-------------|--------|
| v8327doc | FULL (builtin-language branch first) | `docs/its/v8327doc/` | Stand 8.3.27; expand beyond Phase 1 priority chapters |
| v854doc | FULL | `docs/its/v854doc/` | Expand beyond Phase 1 priority |
| v851doc | FULL bodies | `docs/its/v851doc/` | Phase 1 was index-only |
| metod8dev | COMPLETE (dev + remaining) | `docs/its/metod8dev/` | Complete beyond Phase 1 developers subset |
| v8std | FULL | `docs/its/v8std/` | Standards |
| bsp | FULL | `docs/its/bsp/` | БСП |
| erp25doc | FULL | `docs/its/erp25doc/` | ITS ERP 2.5 DB (separate from `docs/1c-erp-25/`) |
| builtin-language | ch.4 leaves ×3 + queries + metod + discovery + syntax-helper | `docs/its/builtin-language/` | Cross-version corpus |
| ai-agents | code.1c.ai + ITS AI + index | `docs/its/ai-agents/` (or agreed KB path) | Offline agent knowledge base |

## Tasks Overview

1. **P2-001** — Auth + discovery TOC sizes + unified resume mirror runner + queue
2. **P2-002** — Full v8327doc (priority builtin-language branch first)
3. **P2-003** — Full v854doc + full v851doc
4. **P2-LANG** — `docs/its/builtin-language/` corpus (ch.4 ×3, queries, metod, discovery, syntax-helper, README)
5. **P2-004** — Complete metod8dev + v8std + bsp
6. **P2-005** — Full erp25doc → `docs/its/erp25doc/`
7. **P2-006** — AI-agents KB (code.1c.ai + ITS AI + index)
8. **P2-007** — Quality remirror + AGENT-OFFLINE/README updates
9. **P2-008** — Final robocopy `C:\1C-Lab\docs\its\` + morning report + archive

## Dependencies Graph

```
P2-001 ──┬→ P2-002 ──┐
         ├→ P2-003 ──┼→ P2-LANG ──┐
         ├→ P2-004 ──┤            ├→ P2-007 → P2-008
         ├→ P2-005 ──┤            │
         └→ P2-006 ──┘────────────┘
```

- **P2-001** blocks all mirror/KB tasks (auth verify + runner + queue must exist)
- **P2-002, P2-003, P2-004, P2-005, P2-006** may run **in parallel** after P2-001 (serialize HTTP within each DB; shared session courtesy / rate limits)
- **P2-LANG** prefers P2-002 + P2-003 done (or at least builtin-language branches available); hard dep: P2-001; soft/preferred: P2-002, P2-003
- **P2-007** after all content tasks (P2-002…P2-006 + P2-LANG)
- **P2-008** after P2-007

## Progress (updated by orchestrator)

- ⏳ P2-001: Auth + discovery TOC sizes + unified resume mirror runner + queue (Pending)
- ⏳ P2-002: Full v8327doc — builtin-language branch first (Pending)
- ⏳ P2-003: Full v854doc + full v851doc (Pending)
- ⏳ P2-LANG: builtin-language corpus ×3 versions + helpers (Pending)
- ⏳ P2-004: Complete metod8dev + v8std + bsp (Pending)
- ⏳ P2-005: Full erp25doc (Pending)
- ⏳ P2-006: AI-agents KB (Pending)
- ⏳ P2-007: Quality remirror + AGENT-OFFLINE/README (Pending)
- ⏳ P2-008: Robocopy + morning report + archive (Pending)

---

## Architecture Decisions

1. **Resume-first runner** — Single unified mirror runner with queue + TOC discovery + crash resume; do not invent one-off scrapers per DB when Phase 1 patterns can be generalized.
2. **Reuse Phase 1** — Auth jar / curl+CAS patterns, Source URL headers, erp-25-compatible `README` + `chapters/*.md` layout from `orch-its-docs-phase1`.
3. **Builtin-language priority** — Within full v8327doc, mirror the built-in language branch first so P2-LANG can start earlier if sequential capacity is limited.
4. **erp25doc vs docs/1c-erp-25** — ITS DB mirror lands in `docs/its/erp25doc/`; existing `docs/1c-erp-25/` remains untouched.
5. **Overnight autonomy** — On auth/rate-limit failure: re-auth from `.dev.env`, backoff, resume queue; log gaps; do not wait for user approval.
6. **Offline first remains** — MCP still used for exact API names; Phase 2 expands narrative/offline corpus only.

## Implementation Notes

- **Creds:** Already in `.dev.env` as `ITS_LOGIN` / `ITS_PASSWORD` — verify only; do not rewrite unless missing.
- **Scripts to reuse:** `.cursor/workspace/completed/orch-its-docs-phase1/` — e.g. `mirror-edtdoc.ps1`, `mirror-v8327doc.py`, `remirror-v8327-src.py`, `mirror-metod8dev.ps1`, `tmp-v854/mirror_v854.py`, auth/cookie patterns (`its-cookies.txt`, `verify/verify-its-001.ps1`).
- **Workspace for Phase 2 runners:** Prefer writing new unified runner + queue state under `.cursor/workspace/active/orch-its-docs-phase2-max/` (keep Phase 1 completed tree read-only).
- **Rate limits:** Serialize article fetches per session; exponential backoff on HTTP 429/403/login walls; re-login and continue.
- **Gap policy:** Document blocked/empty nodes in per-DB `gaps.md` or README; never claim 100% if ITS blocks content.
- **Chapter format:** Each `chapters/*.md` starts with Source URL + download timestamp (match Phase 1 / erp-25).
- **Morning report:** `ai_docs/develop/reports/2026-08-27-its-offline-docs-phase2-max.md` (or date-of-completion) with counts, gaps, robocopy stats — no secrets.

---

## Task Details

### P2-001: Auth + discovery TOC sizes + unified resume mirror runner + queue
- **Priority:** Critical
- **Complexity:** Complex
- **Dependencies:** None
- **Estimated time:** 1.5–3 h
- **Agent:** worker / shell
- **Affects:** `.cursor/workspace/active/orch-its-docs-phase2-max/` (runner, queue, TOC probes), cookie jar (workspace-local)
- **Actions:**
  1. Verify `.dev.env` `ITS_LOGIN` / `ITS_PASSWORD`; login to its.1c.ru; confirm article body (reuse Phase 1 auth gate).
  2. Discovery pass: fetch TOC / browse trees for Phase 2 DBs; record approximate leaf counts / sizes into queue metadata.
  3. Build **unified resume mirror runner** (generalize Phase 1 scripts): queue file, per-URL status, skip-completed, remirror-failed.
  4. Seed overnight queue for P2-002…P2-006 (+ P2-LANG inputs).
- **Acceptance criteria:**
  - Authenticated session loads a real article body.
  - TOC size estimates exist for each Phase 2 DB target.
  - Resume runner can start/stop and skip already-mirrored chapters.
  - Queue file present under Phase 2 workspace; no password in tracked files.

### P2-002: Full v8327doc (priority builtin-language branch first)
- **Priority:** Critical
- **Complexity:** Complex
- **Dependencies:** P2-001
- **Estimated time:** 3–8 h (volume-dependent)
- **Agent:** worker
- **Affects:** `docs/its/v8327doc/`
- **Actions:**
  1. Queue builtin-language / ch.4 branch first; mirror to completion (or documented gaps).
  2. Mirror remaining full v8327doc tree into `chapters/*.md`.
  3. Update README with full TOC index + stand note (8.3.27).
- **Acceptance criteria:**
  - Builtin-language branch mirrored before or clearly prioritized in logs before rest of tree.
  - Full v8327doc coverage or explicit gap list.
  - README + Source URL headers consistent with Phase 1 conventions.
  - Spot-check ≥3 non-empty chapter bodies including ≥1 language leaf.

### P2-003: Full v854doc + full v851doc
- **Priority:** High
- **Complexity:** Complex
- **Dependencies:** P2-001
- **Estimated time:** 4–10 h
- **Agent:** worker
- **Affects:** `docs/its/v854doc/`, `docs/its/v851doc/`
- **Actions:**
  1. Expand v854doc from Phase 1 priority set to full DB mirror.
  2. Expand v851doc from index-only to full article bodies.
  3. READMEs + chapter indexes for both.
- **Acceptance criteria:**
  - v854doc and v851doc claim full (or gap-documented) coverage.
  - v851doc contains article bodies (not TOC-only).
  - Spot-check ≥2 chapters per DB.

### P2-LANG: docs/its/builtin-language/ — all ch.4 leaves ×3 versions, queries, metod hits, discovery, syntax-helper, README
- **Priority:** Critical
- **Complexity:** Complex
- **Dependencies:** P2-001 (hard); P2-002, P2-003 (preferred)
- **Estimated time:** 3–6 h
- **Agent:** worker
- **Affects:** `docs/its/builtin-language/`
- **Actions:**
  1. Collect all built-in language ch.4 leaves across **three** platform doc versions (align with v8327 / v854 / v851 as available).
  2. Include queries-related language material and metod8dev hits relevant to built-in language.
  3. Capture discovery entry «Описание встроенного языка».
  4. Add/refresh local syntax-helper material under the corpus tree.
  5. Write corpus README with cross-version map and Source URLs.
- **Acceptance criteria:**
  - `docs/its/builtin-language/` exists with README and leaf chapters for all three versions (gaps documented if a version lacks a leaf).
  - Queries + metod hits + discovery «Описание встроенного языка» present or gap-listed.
  - Local syntax-helper included and linked from README.
  - Spot-check cross-version leaf for one shared topic.

### P2-004: Complete metod8dev + v8std + bsp
- **Priority:** High
- **Complexity:** Complex
- **Dependencies:** P2-001
- **Estimated time:** 4–10 h
- **Agent:** worker
- **Affects:** `docs/its/metod8dev/`, `docs/its/v8std/`, `docs/its/bsp/`
- **Actions:**
  1. Complete metod8dev beyond Phase 1 developers subset (remaining trees as licensed/available; document admin/other branches).
  2. Full mirror `v8std` → `docs/its/v8std/`.
  3. Full mirror `bsp` → `docs/its/bsp/`.
  4. Per-DB README + indexes.
- **Acceptance criteria:**
  - metod8dev completion status documented (counts vs Phase 1 baseline).
  - v8std and bsp full (or gap-documented) under their folders.
  - Spot-check ≥1 chapter each DB.

### P2-005: Full erp25doc → docs/its/erp25doc/
- **Priority:** High
- **Complexity:** Complex
- **Dependencies:** P2-001
- **Estimated time:** 3–8 h
- **Agent:** worker
- **Affects:** `docs/its/erp25doc/`
- **Actions:**
  1. Mirror full ITS erp25doc DB into `docs/its/erp25doc/` (do **not** modify `docs/1c-erp-25/`).
  2. README with ITS links + chapter index; note relationship to existing erp-25 tree.
- **Acceptance criteria:**
  - `docs/its/erp25doc/` populated with chapters + README.
  - `docs/1c-erp-25/` unchanged.
  - Spot-check ≥2 chapter bodies with Source URLs.

### P2-006: AI-agents KB (code.1c.ai + ITS AI + index)
- **Priority:** Medium
- **Complexity:** Moderate–Complex
- **Dependencies:** P2-001
- **Estimated time:** 2–5 h
- **Agent:** worker
- **Affects:** `docs/its/ai-agents/` (or path recorded in README if adjusted)
- **Actions:**
  1. Collect/mirror available code.1c.ai agent-oriented materials (respect auth/ToS; document source).
  2. Collect ITS AI-related articles/pages into the KB tree.
  3. Build index README linking offline KB entries.
- **Acceptance criteria:**
  - KB folder with index exists under `docs/its/`.
  - At least code.1c.ai and ITS AI sections present or explicitly gap-documented if unreachable overnight.
  - No secrets in KB files.

### P2-007: Quality remirror + AGENT-OFFLINE/README updates
- **Priority:** High
- **Complexity:** Moderate
- **Dependencies:** P2-002, P2-003, P2-LANG, P2-004, P2-005, P2-006
- **Estimated time:** 1–3 h
- **Agent:** worker / documenter
- **Affects:** `docs/its/**` (thin/TOC-only remirrors), `docs/its/AGENT-OFFLINE.md`, `docs/its/README.md`
- **Actions:**
  1. Scan for TOC-heavy / empty / suspiciously small chapter files; remirror via src HTML path (Phase 1 lesson).
  2. Update `AGENT-OFFLINE.md` for Phase 2 paths (builtin-language, erp25doc, v8std, bsp, ai-agents, full DBs).
  3. Update top-level `docs/its/README.md` inventory + counts.
- **Acceptance criteria:**
  - Known thin chapters remirrored or listed as residual gaps.
  - AGENT-OFFLINE + docs/its README reflect Phase 2 layout.
  - Offline-first + MCP-for-exact-API policy preserved.

### P2-008: Final robocopy C:\1C-Lab\docs\its\ + morning report + archive
- **Priority:** High
- **Complexity:** Simple–Moderate
- **Dependencies:** P2-007
- **Estimated time:** 30–60 min
- **Agent:** shell / documenter
- **Affects:** `C:\1C-Lab\docs\its\`, `ai_docs/develop/reports/`, workspace archive
- **Actions:**
  1. Robocopy `docs\its\` → `C:\1C-Lab\docs\its\` (`/E` or documented flags).
  2. Write morning report under `ai_docs/develop/reports/` with per-DB counts, gaps, runner stats, robocopy exit — **no passwords**.
  3. Mark orchestration completed; move workspace `active/` → `completed/`.
- **Acceptance criteria:**
  - Lab path contains Phase 2 ITS tree.
  - Morning report exists and references `orch-its-docs-phase2-max`.
  - Workspace archived to `.cursor/workspace/completed/orch-its-docs-phase2-max/`.

---

## Risks

| Risk | Mitigation |
|------|------------|
| Overnight session expiry / rate limits | Auto re-auth from `.dev.env`; resume queue; backoff |
| Huge TOC volumes (v851 full, erp25doc) | Runner resume; prioritize P2-LANG inputs; gap log if truncated by time |
| code.1c.ai / ITS AI unreachable | Gap-document in P2-006; do not block P2-007/P2-008 |
| Thin TOC-only HTML (Phase 1 failure mode) | Prefer src HTML remirror; P2-007 quality pass |
| Accidental touch of `docs/1c-erp-25/` | Only write under `docs/its/`; robocopy source is `docs\its` only |
| Secret leakage | Never echo password; keep cookies in workspace |

## Verification Strategy

- Per-task acceptance criteria above
- Spot-check random chapters per DB for Source URL + non-empty body
- Confirm `docs/1c-erp-25/` untouched
- Confirm MCP offline-first rule still valid after AGENT-OFFLINE update
- Robocopy destination listing matches source DB folders
- Morning report: counts + gaps + no secrets

## Overnight Execution Policy

- **Do not ask for approvals** mid-run.
- On blocker: log, re-auth, backoff, skip-and-gap, continue queue.
- Prefer completing P2-LANG and platform full mirrors before optional KB polish if time-constrained near morning.
- Finalize with P2-007 → P2-008 even if some gaps remain (document them).

## Next Steps

Execute with: `/orchestrate execute orch-its-docs-phase2-max`  
Or simply: `/orchestrate execute` (uses latest active)
)
