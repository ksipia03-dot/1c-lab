# MCP lab infobases (MCP-002)

**Orchestration:** orch-mcp-free-stack-20260827  
**Task:** MCP-002 completed 2026-09-03  
**Platform:** `1cv8t` 8.3.27.1688 (educational)  
**Root:** `C:\1C-Lab\Bases`

## Source archives (found)

All located under `C:\Users\Administrator\Downloads` (also scanned `C:\` depth 6 for `DemoEnterprise202.zip`, `InfoBase.zip`, `2_5_12_73*.zip`, `1Cv8.dt`):

| File | Size |
|------|------|
| `DemoEnterprise202.zip` | 3.14 GB |
| `InfoBase.zip` | 5.12 GB |
| `2_5_12_73 16.42.55.zip` | 2.48 GB |
| `1Cv8.dt` | 1.11 GB |

## Registered bases

| Display name (launcher) | Path | Source |
|-------------------------|------|--------|
| ERP 2.5 Демо (UI) | `C:\1C-Lab\Bases\ERP25_DemoUI` | `DemoEnterprise202.zip` |
| ERP 2.5 MCP | `C:\1C-Lab\Bases\ERP25_MCP` | Robocopy of DemoUI (base closed) |
| ERP 2.5.12 Дистрибутив | `C:\1C-Lab\Bases\ERP2512_Clean` | `CREATEINFOBASE` + `DESIGNER /RestoreIB` from `1Cv8.dt` |
| ERP InfoBase | `C:\1C-Lab\Bases\ERP25_InfoBase` | `InfoBase.zip` |

Launcher: `%AppData%\1C\1CEStart\ibases.v8i` and `%AppData%\1C\1CEStartt\ibases.v8i`.

Legacy stub **ERP25_Demo** (~3 MB `1Cv8.1CD`) removed from launcher lists; folder may remain on disk unregistered.

## `1Cv8.1CD` sizes (verified)

| Base | `1Cv8.1CD` path | Size |
|------|-----------------|------|
| ERP 2.5 Демо (UI) | `C:\1C-Lab\Bases\ERP25_DemoUI\1Cv8.1CD` | **3.14 GB** |
| ERP 2.5 MCP | `C:\1C-Lab\Bases\ERP25_MCP\1Cv8.1CD` | **3.14 GB** |
| ERP 2.5.12 Дистрибутив | `C:\1C-Lab\Bases\ERP2512_Clean\1Cv8.1CD` | **1.41 GB** |
| ERP InfoBase | `C:\1C-Lab\Bases\ERP25_InfoBase\1Cv8.1CD` | **5.12 GB** |

## ERP2512_Clean notes

- No `ibcmd.exe` in training kit; used `1cv8t.exe CREATEINFOBASE` and `1cv8t.exe DESIGNER /F ... /RestoreIB` with `C:\Users\Administrator\Downloads\1Cv8.dt`.
- Headless restore reported non-zero exit; `1Cv8.1CD` is ~1.41 GB (not a stub). Re-check in Designer if data looks incomplete.
- Distributive zip `2_5_12_73 16.42.55.zip` is platform/media layout (alternate `1cv8.dt` inside); primary restore used Downloads `1Cv8.dt`.

## MCP usage

- MCP extensions only on **ERP25_MCP** (MCP-003+).
- **ERP 2.5 Демо (UI)** is the interactive demo; keep MCP off Demo UI per plan.