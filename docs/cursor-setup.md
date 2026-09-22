# Cursor setup for 1C ERP (Mac)

## BSL extensions (install manually in Cursor)

Open **Cursor → Extensions** (Cmd+Shift+X) and install:

| Extension | ID | Purpose |
|-----------|-----|---------|
| Language 1C (BSL) | `1c-syntax.language-1c-bsl` | Syntax highlighting, BSL Language Server (diagnostics, navigation, formatting) for `.bsl` / `.os` files |

Optional (full 1C platform tooling in the editor):

| Extension | ID | Purpose |
|-----------|-----|---------|
| 1C: Platform Extension Pack | `yellow-hammer.1c-platform-extension-pack` | Bundle: Platform Tools + BSL language support |
| 1C Platform Tools | `yellow-hammer.1c-platform-tools` | Project tree, configurator launch, vrunner integration |
| 1C Platform Tools MCP | `yellow-hammer.mcp-1c-platform-tools` | MCP bridge for Platform Tools (requires Platform Tools + IPC) |

Install via command palette: **Extensions: Install Extensions**, then search by name or paste the ID.

## MCP server (mcp-1c)

Configured globally in `~/.cursor/mcp.json`:

- **Binary:** `/Users/sergey/bin/mcp-1c`
- **Base URL:** `http://127.0.0.1:18080/hs/mcp-1c` (SSH tunnel to Windows server)
- **Config dump:** `/Users/sergey/Documents/1С_тест/config/erp-dump`

After the SSH tunnel is running, restart Cursor or reload MCP servers so `mcp-1c` connects.

## Background services (LaunchAgents)

LaunchAgent plists are installed but **not loaded** until OpenSSH on the Windows server accepts key-based login from this Mac.

| Service | Plist | Log |
|---------|-------|-----|
| SSH tunnel `localhost:18080` → server MCP `:8080` | `~/Library/LaunchAgents/com.1c.mcp-tunnel.plist` | `/tmp/1c-mcp-tunnel.log` |
| Rsync docs + erp-dump every hour | `~/Library/LaunchAgents/com.1c.sync-docs.plist` | `/tmp/1c-sync.log` |

Sync script: `/Users/sergey/bin/1c-sync-from-server.sh`

### Enable after server SSH is ready

1. Verify SSH works (no password prompt):

   ```bash
   ssh -i ~/.ssh/id_ed25519_1clab Administrator@201.34.129.230 "echo ok"
   ```

2. Load both agents:

   ```bash
   launchctl load ~/Library/LaunchAgents/com.1c.mcp-tunnel.plist
   launchctl load ~/Library/LaunchAgents/com.1c.sync-docs.plist
   ```

3. Check status:

   ```bash
   launchctl list | grep com.1c
   tail -f /tmp/1c-mcp-tunnel.log
   tail -f /tmp/1c-sync.log
   ```

4. Restart Cursor so MCP picks up the tunnel.

### Stop or unload

```bash
launchctl unload ~/Library/LaunchAgents/com.1c.mcp-tunnel.plist
launchctl unload ~/Library/LaunchAgents/com.1c.sync-docs.plist
```

## 1C rules and agents

Project rules from [cursor_rules_1c](https://github.com/comol/cursor_rules_1c) are in `.cursor/rules/` and `.cursor/agents/`. Existing orchestration skills in `.cursor/skills/` are kept unchanged.
