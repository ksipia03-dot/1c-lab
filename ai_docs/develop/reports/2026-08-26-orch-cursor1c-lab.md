# Report: Cursor1C Lab Orchestration

**Date:** 2026-08-26  
**Orchestration:** orch-cursor1c-lab-20260825  
**Status:** ✅ Completed  
**Target project:** `C:\Users\Administrator\Documents\Cursor1C_Lab`  
**Mode:** temporary (lab outside `1С_тест`; only orchestration workspace touched here)

## Summary

Educational lab project **Cursor1C_Lab** is ready: [comol/ai_rules_1c](https://github.com/comol/ai_rules_1c) Cursor adapter installed, [feenlace/mcp-1c](https://github.com/feenlace/mcp-1c) **v1.18.0** binary wired for `--dump` only, all six tasks **LAB-001..LAB-006** verified. Platform / infobase / `--base` remain deferred.

Detailed smoke notes live in the lab:

- Lab report: [`C:\Users\Administrator\Documents\Cursor1C_Lab\ai_docs\2026-08-26-lab-setup-report.md`](file:///C:/Users/Administrator/Documents/Cursor1C_Lab/ai_docs/2026-08-26-lab-setup-report.md)

## What Was Built

| Deliverable | Location |
|-------------|----------|
| Lab root + scaffold | `Cursor1C_Lab\` (README, `dump\config\`, `tools\`, `.gitignore`) |
| ai_rules_1c Cursor adapter | `AGENTS.md`, `.cursor\rules\` (47), `.cursor\agents\`, skills/commands |
| Env placeholders | `.dev.env` (`INFOBASE_*` / `PLATFORM_*` blank) |
| mcp-1c binary | `tools\mcp-1c\mcp-1c.exe` (v1.18.0) |
| MCP config (single server `1c`) | `.cursor\mcp.json` (`--dump` → `dump\config`; no `--base`) |
| Catalog MCP backup | `.cursor\mcp.json.catalog.bak` |
| Verify scripts | `scripts\verify-lab-001.ps1` … `verify-lab-006.ps1` |
| Lab smoke report | `Cursor1C_Lab\ai_docs\2026-08-26-lab-setup-report.md` |

## Completed Tasks

1. ✅ **LAB-001** — Infra: download capability + create Cursor1C_Lab (~2 min)  
   - Git absent → ZIP-only via `Invoke-WebRequest`; caches under `%TEMP%\1c-rules` / `%TEMP%\mcp-1c`; `ai_rules_1c` ZIP extracted  
   - Verify: `verify-lab-001.ps1` exit 0  

2. ✅ **LAB-002** — Scaffold: README, dump/config, .gitignore, tools (~2 min)  
   - README with purpose, links, next-step checklist, out-of-scope  
   - Verify: `verify-lab-002.ps1` exit 0  

3. ✅ **LAB-003** — Install ai_rules_1c + `.dev.env` (~2 min)  
   - `install.ps1 init -Tools cursor -NonInteractive` (~237 files); catalog `mcp.json` left for LAB-005  
   - Verify: `verify-lab-003.ps1` exit 0  

4. ✅ **LAB-004** — Download Windows mcp-1c binary (~1 min)  
   - Asset `mcp-1c-windows-amd64.exe` → `tools\mcp-1c\mcp-1c.exe`; `--help` exit 0  
   - Verify: `verify-lab-004.ps1` exit 0  

5. ✅ **LAB-005** — Replace `.cursor/mcp.json` with mcp-1c only (~2 min)  
   - Single server `1c`, dump path, no `--base`, no ports 8000–8008; README updated  
   - Verify: `verify-lab-005.ps1` exit 0  

6. ✅ **LAB-006** — Smoke verify + lab `ai_docs` (~3 min)  
   - `--help` / `--version` OK; AGENTS.md + developer agent + 47 rules; lab report written  
   - Verify: `verify-lab-006.ps1` exit 0  

## Technical Decisions

- **ZIP-only downloads** — no Git/winget/choco on the host; caches stay in `%TEMP%`, not in the lab tree  
- **mcp-1c dump-only** — educational MCP without IB/`--base` until platform is installed  
- **Catalog MCP discarded as active config** — ports 8000–8008 kept only as `.catalog.bak`  
- **Isolation** — lab is a separate folder; `1С_тест` sources unchanged except orchestration workspace + this report  

## Metrics

- **Tasks:** 6/6 completed  
- **Started:** 2026-08-25T16:23:00Z  
- **Completed:** 2026-08-26 (documenter archive)  
- **Verification:** all `verify-lab-00N.ps1` scripts exit 0; mcp-1c v1.18.0  
- **Out of scope (unchanged):** 1C platform, IB, `--base`, BSL extensions, BasesAI, catalog MCP as final  

## Deferred / Next Steps

1. Install 1C platform; create educational infobase  
2. DumpConfigToFiles → `dump\config`  
3. `mcp-1c --install` against IB; optionally add `--base` when HTTP service is ready  
4. Install BSL language extensions  
5. **Open `Cursor1C_Lab` in Cursor** and confirm Tools & MCP shows server `1c` green  

## Related Documentation

- Plan: [ai_docs/develop/plans/2026-08-25-cursor1c-lab.md](../plans/2026-08-25-cursor1c-lab.md)  
- Workspace plan (archived with orchestration): `.cursor/workspace/completed/orch-cursor1c-lab-20260825/plan.md`  
- Lab smoke report: `C:\Users\Administrator\Documents\Cursor1C_Lab\ai_docs\2026-08-26-lab-setup-report.md`  
- References: [ai_rules_1c](https://github.com/comol/ai_rules_1c), [mcp-1c](https://github.com/feenlace/mcp-1c), [setup guide](https://shtruzel.ru/articles/cursor-dlya-1c-nastrojka-mcp-bsl-2026)  
