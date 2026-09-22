# Report: ITS Offline Documentation Mirrors (Phase 1)

**Date:** 2026-08-26  
**Orchestration:** `orch-its-docs-phase1`  
**Status:** ✅ Completed  
**Auth gate:** `AUTH_OK` (ITS-001)

> **Secrets:** Password is **not** included in this report. Credentials remain in `.dev.env` only (`ITS_LOGIN` / `ITS_PASSWORD`).

---

## Summary

Phase 1 delivered offline ITS documentation mirrors under `docs/its/`, an agent offline guide, a Cursor rule for dual offline/MCP access, and a Robocopy copy to the lab path. Authentication used a curl + CAS cookie-jar session. Existing `docs/1c-erp-25/` was preserved. Full remaining chapters for v854/v8327 are deferred to Phase 2.

---

## What Was Built

- Authenticated ITS session (cookie jar) for mirroring
- Scaffold and full/partial mirrors: edtdoc, v8327doc, v854doc, metod8dev, v851doc index
- Agent guide `docs/its/AGENT-OFFLINE.md`
- Cursor rule `.cursor/rules/its-offline-docs.mdc`
- Lab mirror at `C:\1C-Lab\docs\its\`

---

## Completed Tasks

1. ✅ **ITS-001** — Write `.dev.env` ITS creds + login to its.1c.ru + verify article body  
   - Result: `AUTH_OK`  
   - Method: `curl.exe` + Netscape cookie jar; CAS form POST to `login.1c.ru`  
   - Session cookies: `BITRIX_SM_LOGIN`, `PHPSESSID`, plus login.1c.ru `TGC`  
   - Evidence: workspace `auth-gate.md`; cookie jar not committed

2. ✅ **ITS-002** — Scaffold `docs/its/` + README + update `docs/README.md` (keep erp-25)  
   - Result: `SCAFFOLD_OK`  
   - Scaffold dirs for edtdoc, v8327doc, v854doc, metod8dev, v851doc; erp-25 untouched

3. ✅ **ITS-003** — Mirror full edtdoc  
   - Result: `MIRROR_OK` — **190** chapters, gaps=0

4. ✅ **ITS-004** — Mirror priority v8327doc  
   - Result: `MIRROR_OK` — **14** priority chapters remirrored from src HTML  
   - Remirror 2026-08-26: improved DCS / Queries / Forms body sizes among others

5. ✅ **ITS-005** — Mirror priority v854doc  
   - Result: `MIRROR_OK` — **14** priority chapter MD files

6. ✅ **ITS-006** — Mirror metod8dev (developers)  
   - Result: `METOD8DEV_OK` — **1006** chapters (dev + recent + selective admin; no full admin tree)

7. ✅ **ITS-007** — v851doc index + `docs/its/AGENT-OFFLINE.md`  
   - Result: `INDEX_OK` — index only (no full body dump); offline-first + MCP policy documented

8. ✅ **ITS-008** — Cursor rule/pointer: offline docs first; MCP for exact API names  
   - Rule: `.cursor/rules/its-offline-docs.mdc`  
   - Offline-first narrative docs; MCP `docsearch` / `docinfo` for exact API names; erp-25 and MCP tooling preserved

9. ✅ **ITS-009** — Robocopy to `C:\1C-Lab\docs\its\` + report stub  
   - Result: `ROBOCOPY_OK` — ~1233 files, ~22.76 MB, exit 1 (success with copies); report path established

---

## Artifact Counts

| DB | Chapters / units | Notes |
|----|------------------|--------|
| **edtdoc** | **190** | Full TOC mirror |
| **v8327doc** | **14** | Priority themes; remirrored from src HTML |
| **v854doc** | **14** | Priority themes |
| **metod8dev** | **1006** | Developers + recent + selective admin |
| **v851doc** | index only | README / TOC; no full article dump |

---

## Paths

| Role | Path |
|------|------|
| Project offline ITS (source of truth) | `docs/its/` |
| Lab copy | `C:\1C-Lab\docs\its\` |
| Agent offline guide | `docs/its/AGENT-OFFLINE.md` |
| Cursor rule | `.cursor/rules/its-offline-docs.mdc` |
| ERP 2.5 docs (preserved) | `docs/1c-erp-25/` and `C:\1C-Lab\docs\1c-erp-25\` |

---

## Dual Access

- **Offline (local)** — Prefer narrative / chapter docs from `docs/its/` (or the lab mirror).
- **MCP (online)** — Exact API names and signatures via `docsearch` / `docinfo`; tooling remains configured.

See `docs/its/AGENT-OFFLINE.md` and rule `its-offline-docs.mdc`.

---

## Technical Decisions

1. Cookie-based CAS session (curl jar) for authenticated fetches — no password in tracked docs.
2. Mirror layout aligned with `docs/1c-erp-25/` (README + `chapters/*.md` with Source URL headers).
3. Additive documentation only — erp-25 and MCP paths unchanged.
4. Priority-only mirrors for v8327/v854 in Phase 1; full chapter sets later.

---

## Metrics

- **Tasks:** 9/9 completed  
- **Robocopy:** ~1233 files, ~22.76 MB to lab path  
- **Secrets in report:** none (password excluded)

---

## Known Gaps / Phase 2

- **Phase 2:** Full remaining chapters for **v854doc** and **v8327doc** (beyond the 14 priority themes each) will be mirrored in a later cycle.
- v851doc remains index-only by design.
- metod8dev admin tree is selective only (not full).

---

## Related Documentation

- Plan: [ai_docs/develop/plans/2026-08-26-its-offline-docs-phase1.md](../plans/2026-08-26-its-offline-docs-phase1.md)
- Offline guide: `docs/its/AGENT-OFFLINE.md`
- Rule: `.cursor/rules/its-offline-docs.mdc`

---

## Next Steps

1. Phase 2 orchestration: complete remaining v854 / v8327 chapters.
2. Optional: scheduled refresh process (out of Phase 1 scope).
3. Re-auth via CAS cookie jar when session expires (keys in `.dev.env` only).
