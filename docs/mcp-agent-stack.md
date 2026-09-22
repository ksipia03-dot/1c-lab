# MCP agent stack (lab)

**Orchestration:** orch-mcp-free-stack-20260827 · **Task:** MCP-007  
**Config:** `.cursor/mcp.json`  
**Bases:** [docs/mcp/infobases.md](mcp/infobases.md)  
**Catalog shortlist:** [docs/mcp/untru-shortlist.md](mcp/untru-shortlist.md)

Free, non-overlapping Cursor MCP servers for the educational `1cv8t` lab. Extensions and live MCP work only on **ERP25_MCP** (not on Demo UI).

## Servers in `.cursor/mcp.json`

| Cursor name | Upstream | Role | When to use |
|-------------|----------|------|-------------|
| **`1c-mcp`** | mcp-1c (`C:\1C-Lab\tools\mcp-1c`) | Metadata / code search over a **config dump** | Explore ERP objects, find modules, metadata shape without a live COM/HTTP base. Points at `C:\1C-Lab\erp-dump\config`. |
| **`rsv-data`** | MCP-RSV-Data bridge | Live IB queries / describe via COM or HTTP | Read/query **ERP25_MCP** data when COM or IIS publish works. **Currently blocked** on this host (see below). |
| **`1c-mcp-engine`** | vladimir-kharin/1c_mcp Python proxy | In-IB MCP tools via httppoll (or HTTP after publish) | Custom / extension tools (`MCP_Сервер`, `mcp_dev`) on ERP25_MCP. Needs 1C-side agent; full E2E not verified without publish. |
| **`1c-docs`** | alkoleft/mcp-bsl-platform-context | Platform syntax / object model | Exact API names: tool **`search`** then **`info`** (not `docsearch`/`docinfo` on this JAR). Offline ITS first — see [docs/its/AGENT-OFFLINE.md](its/AGENT-OFFLINE.md). |
| **`syntaxcheck`** | phsin/mcp-bsl-ls + BSL LS | BSL diagnostics / format | After editing `.bsl`; prefer a **single module** path — full dump (~44k files) is too heavy. |

Servers are scoped so they do not compete for the same job: dump search ≠ live data ≠ in-IB tools ≠ platform help ≠ syntax.

## Routing cheat sheet

| Need | Use |
|------|-----|
| Find catalog/document/module in ERP dump | `1c-mcp` |
| Live query / balance / document data | `rsv-data` (after COM or HTTP) |
| Tools exposed by 1C MCP extensions | `1c-mcp-engine` |
| Platform method signature / type members | `1c-docs` (`search` → `info`) |
| BSL syntax / LS diagnostics | `syntaxcheck` |
| Methodology / ITS narrative | Local `docs/its/` first, then live docs MCP if needed |

## Known blockers (this lab)

1. **COM on educational `1cv8t`** — no `comcntr.dll` / `V83.COMConnector` under `C:\Program Files (x86)\1cv8t\8.3.27.1688`. **`rsv-data`** bridge ping fails (`Invalid class string`). Workaround: full platform with COM, or HTTP path below.
2. **No IIS / web publish** — IIS roles disabled; `webinst` absent on `1cv8t`. Live HTTP MCP (`.../hs/rsvdata/mcp`, `.../hs/mcp/`) and mcp-1c `-base` are unavailable. `1c-mcp` stays **dump-only**.
3. **`1c-mcp-engine`** — stdio + httppoll proxy starts, but end-to-end tools need extensions active in ERP25_MCP and a 1C polling agent; not smoke-tested against live ERP without publish.
4. Confirm extensions in **Конфигуратор → Расширения** on ERP25_MCP (`RSVData`, `MCP_Сервер`, `mcp_dev`) if headless load looked ambiguous.

## Related paths

| Path | Purpose |
|------|---------|
| `C:\1C-Lab\Bases\` | File infobases (see [infobases.md](mcp/infobases.md)) |
| `C:\1C-Lab\erp-dump\config` | Designer dump for `1c-mcp` / `syntaxcheck` cwd |
| `C:\1C-Lab\tools\` | mcp-1c, mcp-rsv-data, 1c_mcp, mcp-bsl-*, JDKs, BSL LS |
| `ai_docs/develop/reports/2026-09-03-mcp-00*.md` | Per-task install reports (MCP-001…006) |

## After blockers clear

- Enable COM (full platform) **or** IIS + publish ERP25_MCP.
- Re-smoke `rsv-data` (`ping` / `config` / `describe`) and `1c-mcp-engine` tools/list.
- Optionally add mcp-1c `-base` (and credentials) alongside `--dump`.
