# Plan: Cursor1C Lab (educational Cursor + 1C MCP/rules)

**Created:** 2026-08-25 19:23
**Orchestration:** orch-cursor1c-lab-20260825
**Goal:** Create a SEPARATE educational project at `C:\Users\Administrator\Documents\Cursor1C_Lab` with Cursor rules (ai_rules_1c, Cursor adapter) and open-source mcp-1c — without modifying `1С_тест` content except this orchestration workspace.
**Total Tasks:** 6
**Priority:** High
**Status:** Ready

## Scope Boundaries

### In scope
- New lab project under `C:\Users\Administrator\Documents\Cursor1C_Lab`
- Download tooling (portable/silent Git **or** ZIP via `Invoke-WebRequest`)
- Scaffold: README, `dump\config\`, `.gitignore`, `tools\`
- Install [comol/ai_rules_1c](https://github.com/comol/ai_rules_1c) via `AGENT-INSTALL.md` / `install.ps1 init -Tools cursor -NonInteractive`
- `.dev.env` from example with empty `INFOBASE_*` placeholders
- Windows binary of [feenlace/mcp-1c](https://github.com/feenlace/mcp-1c) → `tools\mcp-1c\mcp-1c.exe`
- `.cursor\mcp.json` with **only** mcp-1c (`--dump` → `dump\config`)
- Smoke verify + notes under `Cursor1C_Lab\ai_docs\`

### Out of scope (this cycle)
- Installing 1C platform
- Creating an infobase
- mcp-1c `--base` HTTP connection
- BSL VS Code / Cursor language extensions
- Commercial BasesAI MCP bundle
- ai_rules catalog MCP servers on ports 8000–8008 as final MCP config
- Any content changes inside `1С_тест` except `.cursor/workspace/`

### Environment constraints
- No git / winget / choco in PATH on this Windows server
- No 1C under Program Files
- No global `%USERPROFILE%\.cursor\mcp.json`
- Cache clones/ZIPs under `%TEMP%\1c-rules` and `%TEMP%\mcp-1c` — **not** inside the lab project
- Guide context: https://shtruzel.ru/articles/cursor-dlya-1c-nastrojka-mcp-bsl-2026

## Tasks Overview

1. **LAB-001** — Infra: download capability + create lab root  
2. **LAB-002** — Scaffold project layout and README  
3. **LAB-003** — Install ai_rules_1c (Cursor) + `.dev.env`  
4. **LAB-004** — Download mcp-1c Windows binary  
5. **LAB-005** — Replace `.cursor/mcp.json` (mcp-1c only)  
6. **LAB-006** — Smoke verify + document results in lab `ai_docs/`

## Dependencies Graph

```
LAB-001 → LAB-002 → LAB-003 ──┐
                    LAB-004 ──┼→ LAB-005 → LAB-006
```

- `LAB-003` and `LAB-004` may run **in parallel** after `LAB-002`
- `LAB-005` requires both `LAB-003` (rules may rewrite mcp.json) and `LAB-004` (binary path exists)
- `LAB-006` requires `LAB-005`

## Progress (updated by orchestrator)

- ⏳ LAB-001: Infra — download capability + create Cursor1C_Lab (Pending)
- ⏳ LAB-002: Scaffold README / dump / gitignore / tools (Pending)
- ⏳ LAB-003: Install ai_rules_1c + .dev.env (Pending)
- ⏳ LAB-004: Download mcp-1c binary (Pending)
- ⏳ LAB-005: Replace mcp.json (mcp-1c only) (Pending)
- ⏳ LAB-006: Smoke verify + lab ai_docs (Pending)

---

## Task Details

### LAB-001: Infra — download capability + create lab root
- **Priority:** Critical
- **Complexity:** Simple
- **Dependencies:** None
- **Estimated time:** 20–40 min
- **Agent:** worker / shell
- **Affects:** Host filesystem only (lab root + `%TEMP%`); **not** `1С_тест` sources
- **Actions:**
  1. Detect whether `git` is available; if not, either install portable/silent Git into a PATH-visible location **or** commit to ZIP-only workflow (`Invoke-WebRequest` + Expand-Archive).
  2. Ensure `%TEMP%\1c-rules` and `%TEMP%\mcp-1c` cache directories exist.
  3. Create `C:\Users\Administrator\Documents\Cursor1C_Lab` if missing.
- **Acceptance criteria:**
  - Lab root exists.
  - At least one reliable download path works (Git clone **or** GitHub ZIP).
  - Cache dirs under `%TEMP%` ready; nothing cached inside the lab project.

### LAB-002: Scaffold project layout and README
- **Priority:** High
- **Complexity:** Simple
- **Dependencies:** LAB-001
- **Estimated time:** 20–30 min
- **Agent:** worker
- **Affects (lab project):**
  - `README.md`
  - `dump\config\` (empty placeholder for config dump)
  - `.gitignore`
  - `tools\` (directory for mcp-1c binary)
- **Actions:**
  1. Write README: lab purpose, links (ai_rules_1c, mcp-1c, shtruzel guide), out-of-scope notes, next-step checklist (platform/IB/`--base`/extensions later).
  2. Create `dump\config\`, `tools\`, `.gitignore` (ignore `.dev.env` secrets if any, binaries optional policy, temp artifacts).
- **Acceptance criteria:**
  - All four scaffold items exist.
  - README clearly states this is educational and separate from `1С_тест`.

### LAB-003: Install ai_rules_1c (Cursor adapter) + `.dev.env`
- **Priority:** Critical
- **Complexity:** Moderate
- **Dependencies:** LAB-002
- **Estimated time:** 30–60 min
- **Agent:** worker / shell
- **Cache:** `%TEMP%\1c-rules` (clone or ZIP extract of comol/ai_rules_1c)
- **Actions:**
  1. Obtain ai_rules_1c into `%TEMP%\1c-rules` (not into lab).
  2. Follow `AGENT-INSTALL.md`; run equivalent of:
     `install.ps1 init -Tools cursor -NonInteractive`
     targeting `C:\Users\Administrator\Documents\Cursor1C_Lab`.
  3. Create `.dev.env` from the shipped example; leave `INFOBASE_*` (and related) placeholders empty.
- **Acceptance criteria:**
  - Lab has Cursor adapter artifacts: `.cursor\`, `AGENTS.md`, agents/rules as installed by the script.
  - `.dev.env` exists with empty INFOBASE placeholders.
  - Do not treat catalog MCP servers (8000–8008) as the final desired MCP setup (will be replaced in LAB-005).

### LAB-004: Download Windows mcp-1c release binary
- **Priority:** Critical
- **Complexity:** Moderate
- **Dependencies:** LAB-002
- **Estimated time:** 20–40 min
- **Agent:** worker / shell
- **Cache:** `%TEMP%\mcp-1c`
- **Actions:**
  1. Resolve latest/suitable Windows release asset from feenlace/mcp-1c (ZIP/binary via GitHub API or releases page download).
  2. Extract/cache under `%TEMP%\mcp-1c`.
  3. Place executable at `Cursor1C_Lab\tools\mcp-1c\mcp-1c.exe`.
- **Acceptance criteria:**
  - `tools\mcp-1c\mcp-1c.exe` exists and is runnable.
  - Source is open-source feenlace/mcp-1c — **not** BasesAI commercial bundle.

### LAB-005: Replace `.cursor/mcp.json` (mcp-1c only)
- **Priority:** Critical
- **Complexity:** Simple
- **Dependencies:** LAB-003, LAB-004
- **Estimated time:** 15–25 min
- **Agent:** worker
- **Affects:** `Cursor1C_Lab\.cursor\mcp.json` only (project-level; no global mcp.json)
- **Actions:**
  1. After rules install, **replace** `.cursor\mcp.json` so the only server is mcp-1c.
  2. Configure:
     - `command` = path to `tools\mcp-1c\mcp-1c.exe` (prefer relative to project if Cursor supports it; otherwise absolute lab path)
     - `args` = `--dump` pointing at `dump\config`
  3. Remove any conflicting catalog / multi-port MCP entries left by ai_rules install.
- **Acceptance criteria:**
  - Single MCP server entry for mcp-1c.
  - No leftover 8000–8008 catalog servers as active final config.
  - Dump path resolves to lab `dump\config`.

### LAB-006: Smoke verify + document in lab `ai_docs/`
- **Priority:** High
- **Complexity:** Simple
- **Dependencies:** LAB-005
- **Estimated time:** 20–30 min
- **Agent:** worker / documenter (lab-local docs only)
- **Affects:** `Cursor1C_Lab\ai_docs\` (create if needed)
- **Actions:**
  1. Run `tools\mcp-1c\mcp-1c.exe --help` (or equivalent) and capture exit/output summary.
  2. Confirm key rule files: `AGENTS.md`, `.cursor\agents` (or agents path from install), `.cursor\rules`.
  3. Write a short verification note under `Cursor1C_Lab\ai_docs\` (e.g. setup smoke results + next checklist).
- **Acceptance criteria:**
  - `--help` succeeds.
  - Key rule files present and listed in the note.
  - Results documented in lab `ai_docs\` (not in `1С_тест` docs unless orchestration report later).

---

## Architecture Decisions

1. **Separate lab project** — zero coupling to `1С_тест` configuration sources; only orchestration tracking lives under `1С_тест\.cursor\workspace\`.
2. **MCP option A** — feenlace/mcp-1c offline dump mode (`--dump`), not commercial BasesAI, not ai_rules catalog ports as final MCP.
3. **Rules** — comol/ai_rules_1c Cursor adapter only; then overwrite mcp.json so rules and MCP concerns stay clean.
4. **Caches outside lab** — `%TEMP%\1c-rules`, `%TEMP%\mcp-1c` keep the educational project small and reproducible.
5. **No IB / platform this cycle** — empty INFOBASE_* placeholders document intent without requiring 1C on the machine.

## Implementation Notes for Executor

- Prefer PowerShell `Invoke-WebRequest` / `Expand-Archive` if Git remains unavailable after LAB-001.
- GitHub ZIP URLs: `https://github.com/<org>/<repo>/archive/refs/heads/main.zip` (or tagged release assets for mcp-1c binary).
- After `install.ps1`, treat generated mcp.json as disposable — LAB-005 is mandatory.
- Do not create or edit files under `1С_тест` except updating this orchestration workspace statuses.
- Do not install 1C platform, create IB, wire `--base`, or install BSL extensions in this orchestration.

## Verification Strategy

| Check | Task |
|-------|------|
| Lab root + download path | LAB-001 |
| Scaffold files | LAB-002 |
| AGENTS.md + rules/agents + `.dev.env` | LAB-003 |
| `mcp-1c.exe` present | LAB-004 |
| mcp.json single-server | LAB-005 |
| `--help` + documented smoke | LAB-006 |

## Risks

| Risk | Mitigation |
|------|------------|
| No Git in PATH | ZIP download path in LAB-001 |
| install.ps1 writes multi-MCP config | Hard replace in LAB-005 |
| Wrong mcp-1c asset (non-Windows) | Explicit Windows release selection in LAB-004 |
| Accidental edits to 1С_тест | Executor ban: only `.cursor/workspace/` under 1С_тест |

## Next Steps After This Orchestration

1. Install 1C platform (separate cycle)
2. Create educational infobase + dump to `dump\config`
3. Optionally add mcp-1c `--base` HTTP
4. Optionally add BSL language tooling in Cursor/VS Code
