# Untru/1c-mcp shortlist — installed vs skipped

**Source catalog:** [Untru/1c-mcp](https://github.com/Untru/1c-mcp) (Awesome 1C MCP Servers)  
**Orchestration:** orch-mcp-free-stack-20260827 · **Task:** MCP-007  
**Live stack:** [docs/mcp-agent-stack.md](../mcp-agent-stack.md) · **Bases:** [infobases.md](infobases.md)

Curated subset for this educational lab (`1cv8t`, free tools only). Not a full mirror of the Awesome list.

## Installed (wired in `.cursor/mcp.json`)

| Cursor name | Catalog / upstream | Why kept |
|-------------|-------------------|----------|
| **`1c-mcp`** | [rcs-kz/mcp-1c](https://github.com/rcs-kz/mcp-1c) (binary under `C:\1C-Lab\tools\mcp-1c`) | Fast dump-based metadata/code search; works without IIS/COM. |
| **`rsv-data`** | MCP-RSV-Data (RSV bridge + `RSVData.cfe`) | Live IB data path when COM or HTTP is available. |
| **`1c-mcp-engine`** | [vladimir-kharin/1c_mcp](https://github.com/vladimir-kharin/1c_mcp) | In-config MCP framework + `mcp_dev`; httppoll without IIS. |
| **`1c-docs`** | [alkoleft/mcp-bsl-platform-context](https://github.com/alkoleft/mcp-bsl-platform-context) | Local platform syntax helper from installed `1cv8t` tree. |
| **`syntaxcheck`** | [phsin/mcp-bsl-ls](https://github.com/phsin/mcp-bsl-ls) (listed as bsl-mcp) + BSL Language Server | Post-edit BSL diagnostics on the ERP dump. |

Also on disk / in IB (supporting): `mcp_dev.cfe`, ERP dump at `C:\1C-Lab\erp-dump\config`, JDKs 17/21 under `C:\1C-Lab\tools\`.

## Skipped (by design)

| Catalog entry | Reason |
|---------------|--------|
| **OneRPA MCP Suite** | Paid / license; needs Docker + comol — **explicit plan skip**. |
| **compose4mcp** / OneRPA-style Docker packs | Overlaps chosen free stdio servers; Docker not required for this stack. |
| **EDT-MCP**, CodePilot1C | Lab uses Cursor + Designer dump, not 1C:EDT as primary IDE. |
| **1c-mcp-toolkit** (ROCTUP) | Overlaps `1c_mcp` / mcp-1c; skipped to avoid duplicate live-metadata paths. |
| **1c-mcp-metacode**, **bsl-graph**, **mcp-1c-v1** | Need Neo4j / Nebula / Qdrant+Docker — heavy for this host. |
| **onec-help-mcp**, **1c-syntax-helper-mcp** | Overlap with `1c-docs` + offline `docs/its/`; extra Docker/ES. |
| **mcp-bsl-lsp-bridge**, **METR** (mcp-onec-test-runner) | Extra surface; `syntaxcheck` covers LS diagnostics for now. |
| **1c-buddy**, **spring-mcp-1c-copilot** | Need code.1c.ai / Напарник token; optional later. |
| **ARQA**, commercial accounting MCP | Not free / not in scope. |
| **1c-log-checker**, sandbox stacks | ClickHouse/Grafana/Docker — out of scope for free stack. |

## Decision summary

- **Free MCP only**, multi-base under `C:\1C-Lab\Bases`, extensions only on **ERP25_MCP**.
- Prefer **stdio** tools that work on educational platform limits (dump + local JAR) over Docker/COM-heavy suites.
- Revisit skipped items only after COM or IIS is available, or if a task explicitly needs graph/RAG/Напарник.
