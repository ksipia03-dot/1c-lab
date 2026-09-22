# MCP-006: Platform help + syntaxcheck

**Date:** 2026-09-03  
**Orchestration:** orch-mcp-free-stack-20260827  
**Platform:** `C:\Program Files (x86)\1cv8t\8.3.27.1688`  
**Status:** Complete (install + mcp.json + smoke)

## Installed

| Component | Location | Version / notes |
|-----------|----------|-----------------|
| alkoleft/mcp-bsl-platform-context | `C:\1C-Lab\tools\mcp-bsl-platform-context\mcp-bsl-context-0.3.2.jar` | GitHub release **v0.3.2** (42 487 021 bytes) |
| JDK for 1c-docs | `C:\1C-Lab\tools\jdk-17.0.20.1+1` | Temurin 17.0.20.1+1 as specified |
| phsin/mcp-bsl-ls | `C:\1C-Lab\tools\mcp-bsl-ls` | zipball of `main` (no git on PATH); venv Python 3.12; `pip install -r requirements.txt` and `pip install -e .` |
| BSL Language Server | `C:\1C-Lab\tools\bsl-language-server\bsl-language-server-1.0.7-exec.jar` | **v1.0.7** (130 181 674 bytes) |
| JDK for BSL LS | `C:\1C-Lab\tools\jdk-21` | Temurin **21.0.12.1+1** - required: 1.0.7 is class file 65 (Java 21). JDK 17 cannot run this JAR. Wrapper `mcp-bsl-ls\run-syntaxcheck.cmd` prepends this JDK to PATH because bsl_runner.py calls `java` by name. |

## `.cursor/mcp.json` servers added

Kept existing: `1c-mcp`, `rsv-data`, `1c-mcp-engine`.

Added:

- **`1c-docs`** - stdio `java -jar mcp-bsl-context-0.3.2.jar --platform-path "C:\Program Files (x86)\1cv8t\8.3.27.1688"` via JDK 17.
- **`syntaxcheck`** - `run-syntaxcheck.cmd` to `python -m mcp_bsl.server`, cwd = `C:\1C-Lab\erp-dump\config`, `BSL_JAR` / `BSL_CONFIG` under `C:\1C-Lab\tools\bsl-language-server\`.

## Smoke

### 1c-docs (search / info)

This JAR exposes MCP tools **search** and **info** (plus getMember / getMembers / getConstructors). There is no `docsearch` tool name; Cursor should call **search** then **info** for a hit.

Stdio `initialize` against the live JAR (JDK 17, `--platform-path` as above) returned:

- `serverInfo.name`: `1C Platform API Server`
- `protocolVersion`: `2024-11-05`
- tools capability `listChanged: true`

Conceptual Cursor usage after reload:

1. Tool **search** - query e.g. a platform method name (`Message`), type `method`, small `limit`.
2. Tool **info** - pass the selected API id from search results for signature / description.

### syntaxcheck

Dump contains `.bsl` under `C:\1C-Lab\erp-dump\config\CommonModules\...\Ext\Module.bsl`. Direct BSL LS `--analyze` on the first `Module.bsl` (one file, ~37 KB):

- Exit code **0**
- `Analyzing files... 100% ... 1/1`
- JSON report written (`bsl-json.json` next to the working directory of the smoke process)

Full-dump analysis via MCP `bsl_analyze` with `srcDir` = `C:\1C-Lab\erp-dump\config` would be very heavy (~44k files); use a single module path for interactive checks.

## Orchestration

- `plan.md`: MCP-006 checked complete.
- `progress.json`: `tasksCompleted` = 6, `currentTask` = MCP-007.

## Next

- MCP-007: routing docs for all mcp.json servers.