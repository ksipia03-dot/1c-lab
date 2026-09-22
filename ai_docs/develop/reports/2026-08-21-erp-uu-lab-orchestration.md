# Report: ERP 2.5 + UU Exam Lab orchestration

**Date:** 2026-08-21  
**Orchestration:** orch-2026-08-21-1646-erp-uu-lab  
**Status:** `completed_with_blockers`  
**Prior orch:** orch-2026-08-21-11-34-1c-erp-setup  
**Portal user:** `Kuleshov_Sergey` (AUTH_OK)

## Done

| Item | Evidence |
|------|----------|
| **DOC-001** | `docs/README.md` — ERP 2.5 learning + Cursor/1C AI lab purpose |
| **GATE AUTH_OK** | releases.1c.ru / ITS / UC1 session OK; **no** Platform83/ERP product download rights (ISS-001) |
| **DOC-002** | `docs/1c-erp-25/README.md` lists all on-disk chapter mirrors; mirrored → `C:\1C-Lab\docs\` |
| **OpenSSH (SRV-001)** | `sshd` **Running** (Automatic); Windows FW inbound Allow TCP **22**; **8080** not public |
| **Ports for Mac** | **3389** RDP + **22** SSH — see [2026-08-21-server-ports-mac.md](2026-08-21-server-ports-mac.md) |
| **ITS chapters** | Local UU-focus mirrors in `docs/1c-erp-25/chapters/` (TOC, Introduction, DemoBase, Planning, Sale, Purchase, Budgeting, Treasury, IFRSAccounting) + ITS URLs in README |
| **Exam public pages (EXAM-001)** | Completed as **public materials only**: `SOURCE.md` + public HTML in `exam/materials/official/`; no paid PDF/EPUB |

### EXAM-001 recheck (Chrome CDP `:9222`, one pass)

| Check | Result |
|-------|--------|
| URL | https://online.1c.ru/books/book/36275450/ |
| Paywall / «после оплаты» | **Yes** (`hasPaywall=true`) |
| Direct PDF/EPUB download links | **No** (`hasPdfLink=false`) |
| Price / SKU | 750 руб.; Online015254; files `1C_UU_v_ERP_2026.pdf` / `.epub` after purchase |
| Outcome | Keep **ISS-002** open; EXAM-001 closed as public materials only |
| Pirate copies | **Not** downloaded |

## Blocked

| Item | Why |
|------|-----|
| **Full ERP 2.5 `.dt` from releases** | ISS-001 — AUTH_OK but no product rights on `releases.1c.ru/project/ERP2` |
| **DL-001 / DEP-001 (ERP config load)** | No legal `.dt`/`.cf` in drop zone; empty IB only |
| **Exam PDF purchase (ISS-002)** | Book requires buyer session / purchase on online.1c.ru |

## Educational platform download status

Source: `C:\1C-Lab\downloads\DOWNLOAD-STATUS.md` (present).

| Artifact | Status |
|----------|--------|
| UC1 educational platform `training_8_3_27_1688.zip` | ✅ Downloaded (~543 MB) |
| Linux zip `training64_8_3_27_1688.zip` | On disk; not used on Windows |
| Install `1cv8t` **8.3.27.1688** | ✅ `C:\Program Files (x86)\1cv8t\8.3.27.1688\` |
| IB `C:\1C-Lab\Bases\ERP25_Demo\` | ✅ Exists (`1Cv8.1CD`); **EMPTY** — no ERP config |
| Commercial Platform83 / ERP 2.5 demo | ❌ No rights / no files |

Educational platform ≠ commercial ERP configuration.

## Task tracker snapshot

| ID | Status |
|----|--------|
| DOC-001 | completed |
| GATE-001 | completed (AUTH_OK) |
| DOC-002 | completed |
| EXAM-001 | completed — **public materials only** |
| SRV-001 | completed |
| QA-001 | completed |
| DL-001 | blocked (ISS-001; edu platform only) |
| DEP-001 | blocked (no ERP `.dt`/`.cf`) |

## Next user actions

1. **Timeweb:** open inbound **TCP 22** if Mac SSH still times out (local `sshd` + Windows FW already OK).
2. **ERP config:** register product with download rights **or** drop legal `.dt`/`.cf` into `C:\1C-Lab\downloads\`, then load into `ERP25_Demo`.
3. **Exam book:** buy digital edition (код 4601546149909 / Online015254) → place PDF/EPUB in `exam/materials/official/` → update `SOURCE.md`.

## Paths written / mirrored this close-out

- `docs/1c-erp-25/README.md` (verified vs `chapters/`)
- `C:\1C-Lab\docs\` (robocopy mirror of workspace `docs/`)
- `exam/materials/official/SOURCE.md` + public HTML (retained)
- `.cursor/workspace/active/orch-2026-08-21-1646-erp-uu-lab/tasks.json`
- `.cursor/workspace/active/orch-2026-08-21-1646-erp-uu-lab/progress.json`
- `.cursor/workspace/active/orch-2026-08-21-1646-erp-uu-lab/plan.md` (checklist; not `.cursor/plans/*`)
- This report: `ai_docs/develop/reports/2026-08-21-erp-uu-lab-orchestration.md`

## Related

- Ports: [2026-08-21-server-ports-mac.md](2026-08-21-server-ports-mac.md)
- ISS-001: `ai_docs/develop/issues/ISS-001-releases-auth-blocked.md`
- ISS-002: `ai_docs/develop/issues/ISS-002-exam-collection-purchase.md`
- Downloads: `C:\1C-Lab\downloads\DOWNLOAD-STATUS.md`

**Constraint honored:** no pirate software / no unofficial ERP or exam PDF mirrors.
