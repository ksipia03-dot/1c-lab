# Report: Free MCP + ERP bases — final (MCP-001…008)

**Date:** 2026-09-03  
**Orchestration:** `orch-mcp-free-stack-20260827`  
**Status:** Completed (with known partial blockers)  
**Platform:** educational `1cv8t` 8.3.27.1688  
**Primary MCP IB:** `C:\1C-Lab\Bases\ERP25_MCP`

## Summary

Free MCP stack is installed and wired into project `.cursor/mcp.json` (**5 servers**). File ERP bases under `C:\1C-Lab\Bases` are present with large `.1CD` files. Dump-based code search (`1c-mcp`), platform API help (`1c-docs`), and BSL syntaxcheck launcher are smoke-OK. Live data / HTTP MCP paths remain blocked on this educational platform (no COM connector, no IIS/web publish).

## MCP-008 smoke results (2026-09-03)

### 1. Infobases under `C:\1C-Lab\Bases`

| Folder | Main `1Cv8.1CD` | Approx. size | Role |
|--------|-----------------|--------------|------|
| `ERP25_DemoUI` | yes | **~3 218 MB** | Classic Demo UI (no MCP extensions) |
| `ERP25_MCP` | yes | **~3 221 MB** | MCP work base (extensions) |
| `ERP2512_Clean` | yes | **~1 447 MB** | Clean 2.5.12 base |
| `ERP25_InfoBase` | yes | **~5 240 MB** | InfoBase unpack |
| `ERP25_Demo` | yes | ~3 MB | Small/stub Demo (not the UI demo) |

**Result:** PASS — DemoUI, MCP, Clean, InfoBase exist with large 1CD as expected.

### 2. `.cursor/mcp.json` — 5 servers

| Server | Purpose |
|--------|---------|
| `1c-mcp` | mcp-1c dump search (`--dump` → `C:\1C-Lab\erp-dump\config`) |
| `rsv-data` | RSV Data COM bridge → `ERP25_MCP` |
| `1c-mcp-engine` | Python `1c_mcp` proxy (httppoll `:9090`) |
| `1c-docs` | Platform API help (Java JAR + JDK 17) |
| `syntaxcheck` | mcp-bsl-ls + BSL LS 1.0.7 (JDK 21) |

**Result:** PASS — count = 5.

### 3. Tool smokes

| Check | Result | Evidence |
|-------|--------|----------|
| `mcp-1c.exe --help` | PASS | Usage printed (flags `-dump`, `-install`, `-version`, …) |
| `mcp-1c.exe -version` | PASS | `mcp-1c version v1.18.0` |
| `1c-docs` JAR initialize | PASS | JSON-RPC `initialize` → `serverInfo.name` = `1C Platform API Server`, protocol `2024-11-05` |
| `syntaxcheck` path | PASS | `C:\1C-Lab\tools\mcp-bsl-ls\run-syntaxcheck.cmd` exists (wraps `python -m mcp_bsl.server`) |
| `rsv-data` bridge | FAIL (expected) | `serve --config …\rsv-data.json` → cannot create `V83.COMConnector` / Invalid class string; PowerShell COM probe: `REGDB_E_CLASSNOTREG` (0x80040154) |

**Note:** bare `rsvdata-bridge ping` without setup also fails looking for `%APPDATA%\MCP-RSV-Data\bridge.json`; the project uses `rsv-data.json` via `serve --config`. Runtime failure is COM, not missing config file for serve.

## Task rollup (MCP-001…008)

| ID | Title | Status | Notes |
|----|-------|--------|-------|
| MCP-001 | Prerequisites | ✅ | JDK 17, paths, `1cv8t`, dirs; IIS off |
| MCP-002 | Unpack/register ERP bases | ✅ | Bases under `C:\1C-Lab\Bases` with large 1CD |
| MCP-003 | mcp-1c on ERP25_MCP | ✅ | Extension install + dump index; dump-only MCP (no HTTP `-base`) |
| MCP-004 | RSV Data | ⚠️ partial | Artifacts + mcp.json; **COM blocked on 1cv8t** |
| MCP-005 | 1c_mcp + mcp_dev | ⚠️ partial | CFE load + Python proxy; **no IIS / live HTTP agent** |
| MCP-006 | Platform help + syntaxcheck | ✅ | JAR + BSL LS + smokes |
| MCP-007 | mcp.json + routing docs | ✅ | 5 servers consolidated |
| MCP-008 | Smoke + report | ✅ | This report |

Per-task write-ups:

- [MCP-001](./2026-09-03-mcp-001-prerequisites.md)
- [MCP-003](./2026-09-03-mcp-003-mcp1c.md)
- [MCP-004](./2026-09-03-mcp-004-rsv.md)
- [MCP-005](./2026-09-03-mcp-005-1c-mcp.md)
- [MCP-006](./2026-09-03-mcp-006-platform-help.md)

## What works today

1. **Offline / dump MCP (`1c-mcp`)** — search against `C:\1C-Lab\erp-dump\config` without running 1C HTTP.
2. **Platform API docs (`1c-docs`)** — stdio MCP; tools `search` / `info` (and related members APIs).
3. **Syntaxcheck launcher** — path and JDK 21 wiring ready; prefer single-module analyze over full ~44k-file dump.
4. **File bases** — thick client / Designer against DemoUI and MCP bases.
5. **Tooling layout** — `C:\1C-Lab\tools\{mcp-1c,mcp-rsv-data,1c_mcp,mcp-bsl-platform-context,mcp-bsl-ls,bsl-language-server,jdk-17…,jdk-21}`.

## Blockers / partial paths

| Blocker | Impact | Workaround |
|---------|--------|------------|
| Educational `1cv8t` has **no COM** (`comcntr.dll` / `V83.COMConnector`) | `rsv-data` bridge cannot connect | Install full platform 8.3.27 with COM, **or** publish IB and use HTTP RSV MCP |
| **IIS / webinst** unavailable | No `…/hs/mcp/` or RSV HTTP URL; mcp-1c cannot use `-base` live queries | Enable IIS + web publish, or keep dump-only / httppoll with 1C agent |
| **httppoll** needs 1C-side agent | `1c-mcp-engine` listens but E2E tools against live ERP not verified | Run thick client with MCP extensions active; or switch to HTTP after publish |
| Designer exit code quirks on 1cv8t | Headless `/Extension /LoadCfg` may exit 1 | Confirm extensions in **Конфигуратор → Расширения**, F7 if needed |
| Disk pressure | Large multi-GB bases | Monitor free space on `C:` |

## How to open classic ERP UI (Demo)

Use the **Demo UI** base (not the MCP base) so UI demos stay clean of MCP extensions.

**Option A — command line (Enterprise / thick client):**

```bat
"C:\Program Files (x86)\1cv8t\8.3.27.1688\bin\1cv8t.exe" ENTERPRISE /F"C:\1C-Lab\Bases\ERP25_DemoUI"
```

With admin user (if required by the demo):

```bat
"C:\Program Files (x86)\1cv8t\8.3.27.1688\bin\1cv8t.exe" ENTERPRISE /F"C:\1C-Lab\Bases\ERP25_DemoUI" /N"Администратор" /P""
```

**Option B — Designer (configuration / extensions):**

```bat
"C:\Program Files (x86)\1cv8t\8.3.27.1688\bin\1cv8t.exe" DESIGNER /F"C:\1C-Lab\Bases\ERP25_MCP" /N"Администратор" /P""
```

**Option C — 1C start dialog:** launch `1cv8t.exe` without args → add file IB → path `C:\1C-Lab\Bases\ERP25_DemoUI` → mode **1С:Предприятие**.

**MCP work base:** `C:\1C-Lab\Bases\ERP25_MCP` (same `ENTERPRISE` / `DESIGNER` pattern). Project `.dev.env` already points `INFOBASE_PATH` there.

There is **no web UI** on this lab until IIS + publication are set up.

## Cursor MCP usage (after reload)

1. Reload MCP / restart Cursor so all five servers from `.cursor/mcp.json` appear.
2. Prefer **`1c-mcp`** + **`1c-docs`** + **`syntaxcheck`** for day-to-day offline work.
3. Treat **`rsv-data`** and live **`1c-mcp-engine`** as pending until COM or HTTP publish is fixed.
4. After COM or publish: re-smoke RSV `serve` / ping and `1c-mcp-engine` `tools/list`.

## Metrics (orchestration)

- **Tasks:** 8/8 closed (2 with documented partial runtime)
- **mcp.json servers:** 5
- **Bases with large 1CD:** DemoUI, MCP, Clean, InfoBase (+ small Demo stub)
- **Smoke:** mcp-1c OK; 1c-docs initialize OK; syntaxcheck path OK; RSV COM fail documented

## Related paths

| Item | Path |
|------|------|
| Plan (workspace) | `.cursor/workspace/…/orch-mcp-free-stack-20260827/plan.md` |
| Project MCP config | `.cursor/mcp.json` |
| Config dump | `C:\1C-Lab\erp-dump\config` |
| RSV config | `%APPDATA%\MCP-RSV-Data\rsv-data.json` |

## Next steps (optional follow-ups)

1. Full platform or IIS publish → unlock RSV + HTTP MCP.
2. Verify MCP / RSV / mcp_dev extensions in Designer on `ERP25_MCP`.
3. Interactive Cursor tool smokes once servers stay green in the MCP panel.
4. Archive this orchestration workspace under `.cursor/workspace/completed/`.

---

**Orchestration status:** completed  
**MCP-008:** done
