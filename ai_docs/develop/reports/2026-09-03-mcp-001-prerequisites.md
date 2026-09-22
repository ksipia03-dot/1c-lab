# MCP-001 Prerequisites Report

**Date:** 2026-09-03  
**Orchestration:** orch-mcp-free-stack-20260827

## Disk space (C:)

| Metric | Value |
|--------|-------|
| Free | ~20.7 GiB (22,208,897,024 bytes) |
| Total | ~80.0 GiB |
| Requirement | ≥15 GiB |

**Result:** PASS

## 1C platform (educational 1cv8t)

| Item | Value |
|------|-------|
| Primary path | `C:\Program Files (x86)\1cv8t\8.3.27.1688` |
| Executable | `...\bin\1cv8t.exe` (present) |
| Fallback 8.3.27.1508 | `...\bin\1cv8t.exe` (present) |
| webinst | Not found under 8.3.27.1688 tree |

**Result:** PASS for thick-client / Designer; web publishing may need separate webinst or IIS setup later.

## Runtime dependencies

| Component | Before | After |
|-----------|--------|-------|
| JDK 17+ | Missing from PATH | Temurin OpenJDK 17.0.20.1 installed; `java -version` OK |
| Python 3.10+ | `py -3` → 3.12.8 | No new install (`C:\Program Files\Python312\python.exe`) |
| winget | Not on PATH | Not used (App Installer / winget unavailable in shell) |

## Windows features (IIS)

| Feature | State |
|---------|-------|
| IIS-WebServerRole | Disabled |
| IIS-WebServer | Disabled |
| IIS-CommonHttpFeatures | Disabled |

**Note:** Enable if MCP-002+ requires IIS web publication; not required for file infobase + thick client only.

## Project configuration

- Updated `.dev.env`: `PLATFORM_PATH`, `INFOBASE_PATH`, `INFOSTART_*`, `JAVA_HOME`, `PYTHON`; `IB_USER` / `IB_PASSWORD` left empty for MCP tech user (MCP-003+).
- Updated `.dev.env.example`: key names only (no secrets).

## Directories created

- `C:\1C-Lab\tools\mcp-1c`
- `C:\1C-Lab\tools\mcp-rsv-data`
- `C:\1C-Lab\erp-dump`

## Blockers / risks for MCP-002

1. **ERP archives** must exist in user Downloads (`DemoEnterprise202.zip`, `InfoBase.zip`, `2_5_12_73`, `1Cv8.dt`) — not verified in MCP-001.
2. **Target infobase path** `C:\1C-Lab\Bases\ERP25_MCP` does not exist yet — expected to be created during unpack/register.
3. **IIS disabled** — only a blocker if web publication is part of MCP-002; file bases work without IIS.
4. **webinst absent** on educational platform — may affect HTTP publish steps in later tasks.
5. **Disk ~21 GiB free** — sufficient for prerequisites; monitor during large DT/zip unpack.

## MCP-001 status

**Completed**
