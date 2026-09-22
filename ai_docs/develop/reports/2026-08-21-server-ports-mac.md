# Server ports for Mac access — 2026-08-21

**Server:** `201.34.129.230` (Brave Smew, Timeweb) · **OS:** Windows Server 2022  
**Sources:** `docs/timeweb-firewall-rules.md`, `docs/quick-start.md`, `docs/zero-touch-setup.md`, `scripts/server-access/setup-server.ps1`, live listen/firewall check, Mac probe `connectivity-report-20260821-1426.txt`

**Layering:** Timeweb Cloud Firewall (FWaaS) sits **in front of** Windows Firewall. Whitelist group with missing rules = packet never reaches the VM.

---

## Ports table (Mac client)

| Port | Protocol | Purpose | Must open to Internet? | Notes for Mac access |
|------|----------|---------|------------------------|----------------------|
| **3389** | TCP (UDP optional) | RDP — practice desktop + thick client 1С | **Yes** | Primary path. Use `ERP-Uchebny-plain.rdp` / plain RDP (no alternate shell). **Already open** (Mac TCP PASS + FreeRDP NLA/desktop PASS). |
| **22** | TCP | SSH — Cursor agent bootstrap / MCP tunnel | **Yes** (for automation) | Required by docs Phase 1. **Not working now:** OpenSSH.Server **NotPresent**, nothing listens on 22, no Windows FW rule `OpenSSH-Server-In-TCP`, Mac probe **timeout**. Open in Timeweb **and** run `setup-server.ps1` (or userdata) to install sshd. |
| **5985** | TCP | WinRM HTTP — optional remote PowerShell | Optional | Docs: «по желанию». Service **Stopped/Disabled**; Windows has Allow rules, but Mac still timeouts → likely **Timeweb** still blocks. Not needed if SSH works. |
| **5986** | TCP | WinRM HTTPS | **No** | Docs: explicitly not required. |
| **8080** | TCP | MCP HTTP (1С) | **No** | Localhost only after bootstrap; Mac reaches MCP via **SSH tunnel**, not public 8080. |
| **1540–1541** | TCP | 1С ragent | Only if thin client from other PCs | Skip for RDP + thick client **on this server**. |
| **1560–1591** | TCP | 1С worker processes | Same as above | Skip for current lab scenario. |
| **445** | TCP | SMB | **No** | Not needed for bootstrap. |
| **10050** | TCP | Host monitoring (Zabbix-style; listening) | N/A | Reachable from Mac; **not** for user/Cursor workflow. Leave as-is. |
| ICMP | — | Ping | Optional | Useful for diagnostics; Mac ping already PASS. |

---

## Live status on this VM (readonly check)

| Check | Result |
|-------|--------|
| Listen **3389** | Yes (`TermService` Running); Windows FW Allow Any profile |
| Listen **22** | **No** — OpenSSH.Server capability **NotPresent**; `sshd` service absent |
| Listen **5985/5986** | **No** — WinRM Disabled/Stopped |
| Listen **8080** | **No** (MCP not installed yet) |
| Windows FW profiles | Domain/Private/Public all **Enabled** |
| OpenSSH inbound FW rule | **Missing** (created by `setup-server.ps1`) |
| Mac external probe (~14:26) | **3389 open**; **22/5985/8080 filtered**; plain RDP OK; SSH timeout |

---

## Firewall gaps (what Mac needs)

1. **Timeweb inbound (must):** TCP **3389** (done) + TCP **22** (missing — Mac timeout). Optional: TCP **5985**.
2. **Do not add Timeweb rules for:** 8080, 5986, 445, 1540–1591 (unless thin-client-from-elsewhere).
3. **Do not add outbound rules** in Timeweb whitelist mode (blocks unlisted egress).
4. **Windows side after first access:** run bootstrap (`setup-server.ps1`) so OpenSSH installs, port 22 FW rule appears, MCP 8080 stays localhost-only.
5. **RDP session errors on Mac:** prefer plain `.rdp`; alternate-shell bootstrap files are a separate issue from firewall.

**SSH currently working?** **No** — neither cloud path nor local sshd.

**Windows firewall modified by this report?** **No** (report only).

---

## Related docs

- [docs/timeweb-firewall-rules.md](../../../docs/timeweb-firewall-rules.md)
- [docs/zero-touch-setup.md](../../../docs/zero-touch-setup.md)
- [scripts/server-access/setup-server.ps1](../../../scripts/server-access/setup-server.ps1)

---

## SSH section update (2026-08-21 17:07:03 +03:00)

Minimal OpenSSH install completed on this VM (did **not** run full `setup-server.ps1`; did **not** open 8080).

| Item | Result |
|------|--------|
| OpenSSH.Server capability | **Installed** (was NotPresent) |
| sshd | **Running** / StartType **Automatic** |
| Listen | `0.0.0.0:22` and `[::]:22` LISTENING |
| Windows FW inbound TCP 22 | Rule `OpenSSH-Server-In-TCP` present and **Enabled** (Enabled=True, DisplayName='OpenSSH SSH Server (sshd)') |
| Port 8080 | Unchanged — **not** opened to internet |
| Timeweb cloud firewall | **Not changed from inside** — user must open **TCP 22** in Timeweb panel if Mac still times out |

**SSH currently working (Windows side)?** **Yes** (sshd + local FW). External Mac reachability still depends on Timeweb allowing TCP 22.

