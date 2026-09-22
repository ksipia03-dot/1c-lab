# Plan: Продолжение 1С-лаборатории в Kimi Work

**Created:** 2026-09-22
**Преемник:** [2026-09-11-1c-remote-deploy.md](2026-09-11-1c-remote-deploy.md) (9 задач R1C-001…R1C-009)
**Цель:** вести тот же daily loop «чат → код в `C:\Users\Administrator\Documents\1С_тест` → git → GitHub → Конфигуратор в ИБ», но агентом Kimi Work вместо Cursor.

---

## Фактическое состояние на 2026-09-22 (проверено живьём)

| Проверка | Результат |
|----------|-----------|
| SSH-конфиг `%USERPROFILE%\.ssh\config` | ⚠️ был BOM в первой строке — OpenSSH отказывался читать весь конфиг. **Исправлено 2026-09-22** (бэкап `config.bak-20260922`) |
| Smoke `ssh 1c-erp hostname` | ❌ `Permission denied (publickey)` — sshd на `201.34.129.230` жив, но **публичный ключ этой машины не добавлен** на старый сервер. R1C-002 всё ещё blocked-waiting-owner (владелец не выполнил paste-блок с 2026-09-11) |
| `gh auth status` | ✅ OK, `ksipia03-dot` (keyring) |
| Репозиторий `ksipia03-dot/1c-lab` | ❌ **не существует**; локально в `1С_тест` нет `.git`. R1C-005 не начат |
| `scripts/1c-remote/` | ✅ `Import-Config.ps1`, `Export-Config.ps1`, `Designer-Common.ps1`, `README.md`, тест. R1C-003 по сути готов |
| `AGENTS.md` | ✅ есть (R1C-006), но **ссылка на `docs/07-sync-github-1c-server.md` битая** — файла нет (R1C-008 не сделан) |
| `content/commands/` | ❌ отсутствует (R1C-007 не сделан) |
| `.cursor/mcp.json` | ⚹ указывает на `C:\1C-Lab\...` на старом сервере — на vdswin2k22 этих путей нет (gap R1C-004, задокументирован) |
| `.cursor/rules/` | 50+ правил `.mdc` — Cursor-специфичны, Kimi их сам не подхватывает |

**Вывод:** блокер один — SSH на старый сервер (действие владельца). Всё, что не требует SSH (git/GitHub/доки), можно закрывать уже сейчас.

---

## Что меняется при переходе Cursor → Kimi Work

| Было в Cursor | Станет в Kimi |
|---------------|---------------|
| Правила `.cursor/rules/*.mdc` (auto-apply) | Нет auto-apply. Ключевые правила (`1c-sync-github.mdc`, `coding-standards.mdc`, `getconfigfiles.mdc`) агент читает явно в начале задачи; остальные — по запросу |
| Оркестрация `.cursor/workspace/orch-*` | Планы и статусы остаются в `ai_docs/develop/plans/` и `ai_docs/develop/reports/` (тот же SSOT). Статус задач R1C — в плане от 2026-09-11 |
| MCP-серверы 1С (`.cursor/mcp.json`) | В Kimi MCP-плагинов 1С нет. До восстановления SSH — читаем выгрузку метаданных файлами из git; после SSH (R1C-004) — зеркалим дамп на vdswin2k22 и/или подключаем MCP |
| Коммит/push руками агента | Тот же цикл из AGENTS.md: после каждого завершённого изменения tracked-файлов → commit → push → `gh run list`, задача не закрыта до зелёного Deploy |
| `.dev.env` секреты | Не меняется: не коммитить, ключи только в `%USERPROFILE%\.ssh` |

---

## План фаз

### Фаза 1 — git + GitHub (без SSH, делаем сразу) — R1C-005, R1C-007, R1C-008

1. `git init` в `1С_тест`, проверить `.gitignore` (`*.env`, ключи, `.tools/venv`, большие бинарники — в git не идут)
2. `gh repo create ksipia03-dot/1c-lab --public`, первый commit
3. `.github/workflows/deploy-1c.yml`: `on: push main`, `runs-on: [self-hosted, windows, 1c-erp]`, вызов `scripts/1c-remote/Import-Config.ps1`
4. `content/commands/`: `getconfigfiles.md`, `update1cbase.md`, `deploy-and-test.md` — SSOT, зовут тот же Import/Export
5. `docs/07-sync-github-1c-server.md` — починить битую ссылку из AGENTS.md; чек-лист владельца (Timeweb FW / RDP paste / runner Idle)
6. Обновить статусы задач в плане 2026-09-11 → запушить

### Фаза 2 — разблокировать SSH (действие владельца) — R1C-002

1. Владельцу: RDP на `201.34.129.230` → PowerShell от администратора → вставить блок из [2026-09-11-1c-remote-deploy-owner.md](2026-09-11-1c-remote-deploy-owner.md) (блок уже готов, ничего не менять)
2. Панель Timeweb: входящее TCP 22 с `72.56.105.69/32`
3. После «готово» — smoke `ssh 1c-erp hostname` (один раз)

### Фаза 3 — self-hosted runner + первый деплой — R1C-005 (часть 2)

1. Владельцу: GitHub → Settings → Actions → Runners → New self-hosted runner (Windows, имя `1c-erp`, labels `self-hosted, windows, 1c-erp`, установить как службу). Токен — не в чат/git
2. Первый push с workflow → `gh run list` → ждём зелёный **Deploy to 1C**

### Фаза 4 — дамп и MCP (после SSH) — R1C-004

1. Первый export наших объектов/расширения в git (`Export-Config.ps1`, не полный ERP-дамп ~44k файлов)
2. Зеркало дампа на vdswin2k22 для чтения Kimi; зафиксировать путь в `.dev.env` / доке
3. Обновить `.cursor/mcp.json`-пути (для Cursor) и описать Kimi-способ доступа к дампу

### Фаза 5 — рабочий режим

- Одна конкретная задача за сессию: чат → план → код → commit → push → зелёный Actions
- Учебные треки (экзамен УУ, билеты) — как раньше, по официальным материалам в `exam/`
- Фаза 2 плана от 2026-09-11 (веб-клиент) — не раньше зелёного деплоя

---

## Правила безопасности (без изменений)

- Не коммитить `.dev.env`, пароли, приватные SSH-ключи, токены runner
- На старом сервере tracked-файлы руками не править
- Путь ИБ и платформу не выдумывать — только подтверждённые через SSH/владельца
- Задача не закрыта, пока `gh run list` не показал зелёный **Deploy to 1C**
