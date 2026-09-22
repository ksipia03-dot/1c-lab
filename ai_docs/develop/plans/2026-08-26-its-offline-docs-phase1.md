# Plan: ITS Offline Documentation Mirrors (Phase 1 + platform 8.3.27)

**Created:** 2026-08-26
**Orchestration:** orch-its-docs-phase1
**Goal:** Build offline ITS documentation mirrors under `docs/its/` (Phase 1 + platform 8.3.27), copy to `C:\1C-Lab\docs\its\`, keep MCP `docsearch`/`docinfo` as the online API path, and add links only — do **not** delete `docs/1c-erp-25/` or other existing docs.
**Total Tasks:** 9
**Priority:** High
**Status:** ✅ Completed

## Scope Boundaries

### In scope
- Store ITS credentials in gitignored `.dev.env` as `ITS_LOGIN` / `ITS_PASSWORD` (training stand; owner-authorized)
- Scaffold `docs/its/` with README; update `docs/README.md` with links (keep ERP 2.5)
- Mirror sources into `docs/its/<db>/` using the same shape as `docs/1c-erp-25/`:
  - README with ITS root links + chapter index
  - `chapters/*.md` with **Source URL** header (and download timestamp)
- Full **edtdoc**; priority chapters for **v8327doc** and **v854doc**; **metod8dev** (Developers + recent changes; admin selectively); **v851doc** index only
- Agent guide `docs/its/AGENT-OFFLINE.md`
- Cursor rule/pointer: prefer offline `docs/its` first; MCP for exact API names
- Robocopy mirror to `C:\1C-Lab\docs\its\` + report stub path under `ai_docs/develop/reports/`

### Out of scope (this cycle)
- Deleting or rewriting `docs/1c-erp-25/` content
- Replacing MCP online docsearch/docinfo with offline-only search
- Full mirror of v851doc article bodies
- Full admin tree of metod8dev (only selective admin when needed)
- Automating continuous sync / scheduled refresh (Phase 1 is one-shot + documented process)

### Security constraints
- Password **never** in `docs/`, plans beyond key names, reports, commit messages, or git-tracked files
- Values only in `.dev.env` (must remain gitignored)
- Plan and reports may reference keys `ITS_LOGIN` / `ITS_PASSWORD` and login username if already public in other local docs — not the password string

## Sources

| ID | Scope | URL |
|----|--------|-----|
| edtdoc | FULL | https://its.1c.ru/db/edtdoc#content:10000:hdoc |
| v8327doc | Priority chapters (stand 8.3.27) | https://its.1c.ru/db/v8327doc/browse/13/-1/1 |
| v854doc | Priority chapters | https://its.1c.ru/db/v854doc#bookmark:dev:TI000000129 |
| metod8dev | Developers + recent; admin selective | https://its.1c.ru/db/metod8dev#browse:13:-1:3199 |
| v851doc | INDEX ONLY | https://its.1c.ru/db/v851doc#browse:13:-1:1 |

### Priority chapter themes (v8327doc / v854doc)
concept, metadata, built-in language, queries, managed forms, command interface, registers, posting, locks/transactions, DCS/reports, rights/RLS, data exchange, HTTP/web services, background jobs, client-server, extensions (if present).

## Tasks Overview

1. **ITS-001** (T1) — Write `.dev.env` ITS creds + login to its.1c.ru + verify article body  
2. **ITS-002** (T2) — Scaffold `docs/its/` + README + update `docs/README.md` (keep erp-25)  
3. **ITS-003** (T3) — Mirror full edtdoc  
4. **ITS-004** (T4) — Mirror priority v8327doc  
5. **ITS-005** (T5) — Mirror priority v854doc  
6. **ITS-006** (T6) — Mirror metod8dev (developers)  
7. **ITS-007** (T7) — v851doc index + `docs/its/AGENT-OFFLINE.md`  
8. **ITS-008** (T8) — Cursor rule/pointer: offline `docs/its` first; MCP for exact API names  
9. **ITS-009** (T9) — Robocopy to `C:\1C-Lab\docs\its\` + report stub path  

## Dependencies Graph

```
ITS-001 → ITS-002 → ITS-003 ──┐
                    ITS-004 ──┤
                    ITS-005 ──┼→ ITS-007 → ITS-008 → ITS-009
                    ITS-006 ──┘
```

- **ITS-001** blocks all mirrors (auth must work)
- **ITS-002** blocks mirror tasks (target tree + README conventions)
- **ITS-003 … ITS-006** may run **in parallel** after ITS-002 (rate-limit / session courtesy recommended)
- **ITS-007** after at least the intended mirrors for index cross-links; preferably after ITS-003…ITS-006
- **ITS-008** after ITS-007 (guide + tree exist)
- **ITS-009** after mirrors + guide + rule (copy complete offline set)

## Progress (updated by orchestrator)

- ✅ ITS-001: .dev.env ITS creds + ITS login verify (Completed)
- ✅ ITS-002: Scaffold docs/its + docs/README links (Completed)
- ✅ ITS-003: Mirror full edtdoc (Completed)
- ✅ ITS-004: Mirror priority v8327doc (Completed)
- ✅ ITS-005: Mirror priority v854doc (Completed)
- ✅ ITS-006: Mirror metod8dev developers (Completed)
- ✅ ITS-007: v851doc index + AGENT-OFFLINE.md (Completed)
- ✅ ITS-008: Cursor offline-docs pointer rule (Completed)
- ✅ ITS-009: Robocopy to 1C-Lab + report stub (Completed)

---

## Architecture Decisions

1. **Offline first for narrative docs; MCP for exact API** — Agents read `docs/its/` for concepts/chapters; use MCP `docsearch`/`docinfo` when precise platform API signatures are required.
2. **Mirror layout matches `docs/1c-erp-25/`** — Per-DB folder with README (ITS links + TOC) and `chapters/*.md` starting with Source URL (+ download timestamp).
3. **Additive only** — Existing `docs/1c-erp-25/` and other trees stay; `docs/README.md` gains links.
4. **Lab copy** — Project mirror is source of truth in-repo; `C:\1C-Lab\docs\its\` is a Robocopy destination for the Cursor1C lab machine path.
5. **Credentials** — `ITS_LOGIN` / `ITS_PASSWORD` in `.dev.env` only; never embed in mirrored markdown beyond what ITS pages already show publicly.

## Implementation Notes

- Prefer authenticated browser or documented ITS scrape approach already used for ERP 2.5 chapters; keep Source URL headers consistent with `docs/1c-erp-25/chapters/*.md`.
- Respect ITS session limits; parallel mirrors should not hammer the site (serialize requests within each DB if needed).
- For priority chapters: map theme names to actual ITS bookmarks/browse nodes during ITS-004/ITS-005; record mapping in each DB’s README.
- Report stub (ITS-009): create path under `ai_docs/develop/reports/` (e.g. `2026-08-26-its-offline-docs-phase1.md`) with mirror stats placeholders — full narrative report can wait for documenter at orchestration end.
- Ensure `.dev.env` is listed in `.gitignore` before writing secrets (ITS-001).

---

## Task Details

### ITS-001 (T1): Write `.dev.env` ITS creds + login to its.1c.ru + verify article body
- **Priority:** Critical
- **Complexity:** Simple
- **Dependencies:** None
- **Estimated time:** 20–40 min
- **Agent:** worker / shell
- **Affects:** `.dev.env`, `.gitignore` (if needed)
- **Actions:**
  1. Confirm `.dev.env` is gitignored; add ignore rule if missing.
  2. Write `ITS_LOGIN` and `ITS_PASSWORD` from the owner-authorized training-stand brief (do not echo password into chat logs, plans, or reports).
  3. Log in to `https://its.1c.ru` with those credentials.
  4. Open a sample article (e.g. edtdoc root or a known chapter) and verify the **article body** is visible (not a login wall / empty shell).
- **Acceptance criteria:**
  - `.dev.env` contains `ITS_LOGIN` and `ITS_PASSWORD`; file is not tracked by git.
  - Authenticated ITS session can load a real article body.
  - No password string appears in any new git-tracked file.

### ITS-002 (T2): Scaffold `docs/its/` + README + update `docs/README.md` (keep erp-25)
- **Priority:** Critical
- **Complexity:** Simple
- **Dependencies:** ITS-001
- **Estimated time:** 20–30 min
- **Agent:** worker
- **Affects:** `docs/its/`, `docs/README.md`
- **Actions:**
  1. Create `docs/its/` with top-level README describing Phase 1 scope, DBs, and offline-vs-MCP policy.
  2. Create placeholder subdirs: `edtdoc/`, `v8327doc/`, `v854doc/`, `metod8dev/`, `v851doc/` (each ready for README + `chapters/`).
  3. Update `docs/README.md` to link `docs/its/` **without** removing or rewriting `docs/1c-erp-25/` entries.
- **Acceptance criteria:**
  - `docs/its/README.md` exists and lists planned DBs + source URLs.
  - `docs/1c-erp-25/` still present and linked from `docs/README.md`.
  - Scaffold dirs exist for all five DBs.

### ITS-003 (T3): Mirror full edtdoc
- **Priority:** High
- **Complexity:** Complex
- **Dependencies:** ITS-002
- **Estimated time:** 2–4 h (volume-dependent)
- **Agent:** worker
- **Affects:** `docs/its/edtdoc/`
- **Source:** https://its.1c.ru/db/edtdoc#content:10000:hdoc
- **Actions:**
  1. Crawl/export full edtdoc tree into `docs/its/edtdoc/chapters/*.md`.
  2. Write `docs/its/edtdoc/README.md` with ITS links + chapter index.
  3. Each chapter file: Source URL header (+ timestamp), body content.
- **Acceptance criteria:**
  - Full edtdoc coverage (or documented gap list if ITS blocks a node).
  - README + chapters match erp-25 mirror conventions.
  - Spot-check: ≥1 chapter body non-empty and Source URL correct.

### ITS-004 (T4): Mirror priority v8327doc
- **Priority:** High
- **Complexity:** Complex
- **Dependencies:** ITS-002
- **Estimated time:** 1.5–3 h
- **Agent:** worker
- **Affects:** `docs/its/v8327doc/`
- **Source:** https://its.1c.ru/db/v8327doc/browse/13/-1/1
- **Actions:**
  1. Map priority themes to v8327doc nodes/bookmarks.
  2. Mirror those chapters to `docs/its/v8327doc/chapters/*.md`.
  3. README with ITS links + priority chapter index (note stand = 8.3.27).
- **Acceptance criteria:**
  - All listed priority themes present or explicitly marked N/A if absent in v8327doc.
  - README + Source URL headers consistent with erp-25 format.
  - Spot-check article body for ≥2 themes (e.g. queries, managed forms).

### ITS-005 (T5): Mirror priority v854doc
- **Priority:** High
- **Complexity:** Complex
- **Dependencies:** ITS-002
- **Estimated time:** 1.5–3 h
- **Agent:** worker
- **Affects:** `docs/its/v854doc/`
- **Source:** https://its.1c.ru/db/v854doc#bookmark:dev:TI000000129
- **Actions:**
  1. Map same priority themes to v854doc bookmarks.
  2. Mirror to `docs/its/v854doc/chapters/*.md` + README index.
- **Acceptance criteria:**
  - Priority themes mirrored (or N/A documented).
  - README + Source URL headers OK.
  - Spot-check ≥2 chapter bodies.

### ITS-006 (T6): Mirror metod8dev (developers)
- **Priority:** High
- **Complexity:** Moderate–Complex
- **Dependencies:** ITS-002
- **Estimated time:** 1–2.5 h
- **Agent:** worker
- **Affects:** `docs/its/metod8dev/`
- **Source:** https://its.1c.ru/db/metod8dev#browse:13:-1:3199
- **Actions:**
  1. Mirror **Developers** branch + recent changes.
  2. Include admin materials only selectively (document selection criteria in README).
  3. README + chapters with Source URL headers.
- **Acceptance criteria:**
  - Developers branch content present under `docs/its/metod8dev/`.
  - Recent-changes section or index included.
  - Admin subset (if any) listed in README; no claim of full admin tree.

### ITS-007 (T7): v851doc index + `docs/its/AGENT-OFFLINE.md`
- **Priority:** High
- **Complexity:** Moderate
- **Dependencies:** ITS-003, ITS-004, ITS-005, ITS-006 (preferred); hard dep: ITS-002
- **Estimated time:** 45–90 min
- **Agent:** worker / documenter
- **Affects:** `docs/its/v851doc/`, `docs/its/AGENT-OFFLINE.md`
- **Source (index only):** https://its.1c.ru/db/v851doc#browse:13:-1:1
- **Actions:**
  1. Capture v851doc **index/TOC only** (no full article bodies).
  2. Write `docs/its/AGENT-OFFLINE.md`: how agents should use offline mirrors, priority DB order, when to fall back to MCP.
- **Acceptance criteria:**
  - `docs/its/v851doc/` has index README (and optional TOC md) without full body dump.
  - `AGENT-OFFLINE.md` documents offline-first + MCP-for-API-names policy.
  - Cross-links to edtdoc / v8327 / v854 / metod8dev paths.

### ITS-008 (T8): Cursor rule/pointer — offline `docs/its` first; MCP for exact API names
- **Priority:** High
- **Complexity:** Simple
- **Dependencies:** ITS-007
- **Estimated time:** 20–40 min
- **Agent:** worker
- **Affects:** `.cursor/rules/` (or project pointer per existing rule conventions)
- **Actions:**
  1. Add a concise Cursor rule/pointer: prefer `docs/its/` offline mirrors for platform/ITS narrative docs.
  2. State MCP `docsearch`/`docinfo` remain the path for exact API names/signatures.
  3. Do not remove existing MCP tooling config.
- **Acceptance criteria:**
  - Rule file exists and is discoverable by agents.
  - Explicit offline-first + MCP-for-exact-API guidance.
  - No instruction to delete MCP or `docs/1c-erp-25/`.

### ITS-009 (T9): Robocopy to `C:\1C-Lab\docs\its\` + report stub path
- **Priority:** High
- **Complexity:** Simple–Moderate
- **Dependencies:** ITS-008 (and completed mirrors)
- **Estimated time:** 20–40 min
- **Agent:** shell / worker
- **Affects:** `C:\1C-Lab\docs\its\`, `ai_docs/develop/reports/` stub
- **Actions:**
  1. Ensure `C:\1C-Lab\docs\its\` exists (create parents as needed).
  2. Robocopy `docs\its\` → `C:\1C-Lab\docs\its\` (mirror or /E as appropriate; document flags used).
  3. Create report stub at `ai_docs/develop/reports/2026-08-26-its-offline-docs-phase1.md` with paths, DB list, and placeholders for counts / known gaps (no secrets).
- **Acceptance criteria:**
  - Lab path contains the offline ITS tree after copy.
  - Report stub path exists and references orchestration `orch-its-docs-phase1`.
  - Password not present in report stub.

---

## Risks

| Risk | Mitigation |
|------|------------|
| ITS rate-limit / session expiry mid-mirror | Re-auth from `.dev.env`; resume by chapter; serialize requests |
| Priority theme names ≠ ITS TOC labels | Map during mirror; document N/A in README |
| Accidental commit of `.dev.env` | Verify gitignore in ITS-001; never `git add .dev.env` |
| Overwrite of erp-25 or lab docs | Additive links only; Robocopy target is `docs\its` subtree only |
| Huge edtdoc volume | Full mirror still required; track progress in README / report stub |

## Verification Strategy

- Per-task acceptance criteria above
- Spot-check random chapters for Source URL + non-empty body
- Confirm `docs/1c-erp-25/` untouched except possible parent README link addition
- Confirm MCP remains configured for online API lookups
- Confirm Robocopy destination listing matches source DB folders

## Next Steps (after plan ready)

Execute with: `/orchestrate execute orch-its-docs-phase1`
Or simply: `/orchestrate execute` (uses latest active)
)
