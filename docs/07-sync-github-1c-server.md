# Синхронизация: Windows → GitHub → Конфигуратор в ИБ 1С

**Статус:** Актуально
**Обновлено:** 2026-09-22

Поток данных: **Windows (vdswin2k22) → GitHub `ksipia03-dot/1c-lab` → self-hosted runner на старом сервере 1С → Конфигуратор загружает конфигурацию в ИБ**.

Это **не** rsync-картина из UIS: Ubuntu-раннер GitHub не умеет 1С. Робот выкатки стоит **на старом Windows-сервере** (`201.34.129.230`), а загрузка выполняется учебным Конфигуратором: `1cv8t.exe DESIGNER /LoadConfigFromFiles` + `/UpdateDBCfg` (см. [`scripts/1c-remote/Import-Config.ps1`](../scripts/1c-remote/Import-Config.ps1)).

---

## Точки синхронизации

| Точка | Путь / адрес | Роль |
|-------|--------------|------|
| **Windows (источник правды)** | `C:\Users\Administrator\Documents\1С_тест` на vdswin2k22 | Единственное место правок tracked-файлов |
| **GitHub** | `https://github.com/ksipia03-dot/1c-lab`, ветка `main` | Версионирование, триггер деплоя (workflow **Deploy to 1C**) |
| **Старый сервер 1С** | `201.34.129.230` (Brave Smew, Timeweb) | Runtime: self-hosted runner + Конфигуратор загружает файлы в ИБ |

Правки на старом сервере **не делаются** — runtime-копия обновляется только через Actions и будет перезаписана любой ручной правкой.

---

## Правило: синхронизация после каждого изменения

Обязательно для агента (см. также [AGENTS.md](../AGENTS.md)). После каждого завершённого изменения tracked-файлов:

```powershell
git add -A
git commit -m "почему сделали это изменение"
git push origin main
gh run list --limit 3
```

1. **Задача не считается завершённой**, пока workflow **Deploy to 1C** не зелёный (либо, пока runner ещё не установлен, — пока ожидание runner не закрыто, см. раздел «Разовая настройка»).
2. Красный ран — открытый пункт: смотреть лог рана и лог Конфигуратора, чинить, push повторно.
3. Commit-сообщение — **почему**, не перечень «что».

## Что НЕ коммитить

- `.dev.env` (пароли, пути с секретами) — уже в `.gitignore` (`*.env`)
- SSH-ключи (`%USERPROFILE%\.ssh\…` — они и не в проекте; никогда не копировать в git/чат)
- Токены GitHub runner
- Полный ERP-дамп (~44k файлов) — в git только наши объекты/расширение
- Локальные тяжёлые каталоги: `.tools/`, `docs/its/`, `exam/materials/` (уже в `.gitignore`)

---

## SSH-алиас `1c-erp` (локально на vdswin2k22, не в git)

`C:\Users\Administrator\.ssh\config`:

```
Host 1c-erp
    HostName 201.34.129.230
    User Administrator
    IdentityFile C:/Users/Administrator/.ssh/1c_erp_ed25519
    IdentitiesOnly yes
```

Приватный ключ — только локально. Публичный ключ (`1c_erp_ed25519.pub`) — один раз прописывается на старом сервере в `C:\ProgramData\ssh\administrators_authorized_keys` (paste-блок для владельца: [план remote-deploy, раздел Owner handoff](../ai_docs/develop/plans/2026-09-11-1c-remote-deploy.md)).

**Smoke (не меняет сервер):**

```powershell
ssh -o BatchMode=yes -o ConnectTimeout=10 1c-erp "hostname"
```

Ожидание: имя хоста старого сервера. `Permission denied (publickey)` = ключ ещё не прописан на сервере (см. «Разовая настройка», шаг 2).

SSH нужен для диагностики и **выгрузки** объектов из ИБ ([Export-Config.ps1](../scripts/1c-remote/Export-Config.ps1)); **деплой идёт через Actions**, не через SSH.

---

## Разовая настройка (для владельца, один раз)

Детали и готовые блоки: [план remote-deploy — раздел «Что нужно от вас»](../ai_docs/develop/plans/2026-09-11-1c-remote-deploy.md) и короткая записка [2026-09-11-1c-remote-deploy-owner.md](../ai_docs/develop/plans/2026-09-11-1c-remote-deploy-owner.md).

1. **Файрвол Timeweb:** входящее правило TCP **22** только с `72.56.105.69/32` (не «для всех»). Подсказка по экрану: [timeweb-firewall-rules.md](timeweb-firewall-rules.md).
2. **Старый сервер:** RDP на `201.34.129.230` → PowerShell **от администратора** → вставить **один готовый блок** (включает OpenSSH, прописывает публичный ключ vdswin2k22). Ничего не менять. Затем в чат: «блок выполнен» + путь к базе (или «база как в .dev.env, ERP25_MCP»).
3. **Runner:** GitHub → репозиторий `1c-lab` → **Settings → Actions → Runners → New self-hosted runner** → Windows. На старом сервере в PowerShell по очереди: Download, Configure (имя `1c-erp`, labels `self-hosted`, `windows`, `1c-erp`), затем install как службу. Статус на GitHub — **Idle** (зелёный). Токен со страницы GitHub в чат **не копировать**.

После шага 2 — smoke SSH из раздела выше. После шага 3 — первый push уже запускает **Deploy to 1C**.

---

## Проверка после деплоя

```powershell
gh run list --limit 3     # Deploy to 1C — зелёный
```

Дополнительно по SSH (если жив): лог Конфигуратора в `_deploy-logs\1cv8-import.log` рядом с checkout раннера на старом сервере.

---

## Фаза 2 (позже, не блокирует текущий цикл)

Публикация веб-клиента ИБ на старом хосте + `INFOBASE_PUBLISH_URL`. На учебном `1cv8t` нет `webinst` — может понадобиться полная платформа. Порт 80 в интернет сейчас не открываем.
