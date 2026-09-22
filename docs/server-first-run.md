# Первый запуск сервера — аварийный fallback

> **Обычный путь:** [zero-touch-setup.md](zero-touch-setup.md) — агент настраивает всё без вашего участия.  
> Этот документ — **только если** автоматизация Tier B/A не сработала и нужен ручной RDP + PowerShell.

> **Не копируйте пароли в файлы проекта.** Пароль Administrator вводите только в окне RDP / связке ключей macOS.

---

## Что будет сделано

Скрипт `setup-server.ps1`:

- установит и запустит **OpenSSH Server** (порт 22);
- создаст каталоги **`C:\1C-Lab\`**;
- настроит firewall (SSH снаружи, MCP HTTP 8080 — только localhost);
- установит SSH-ключ Mac для входа без пароля (если файл ключа на месте).

---

## Шаг 1. Подключитесь к серверу

1. На Mac: **двойной клик** по `~/Desktop/ERP-Uchebny.rdp`.
2. Войдите как **`Administrator`** (пароль — из ваших учётных данных, не из репозитория).

---

## Шаг 2. Создайте каталог для скриптов

В **PowerShell от имени администратора**:

```powershell
New-Item -ItemType Directory -Path C:\1C-Lab\scripts -Force
```

---

## Шаг 3. Скопируйте `setup-server.ps1` на сервер

### Вариант A — через буфер обмена (проще всего)

1. На Mac откройте в Cursor файл:
   ```
   scripts/server-access/setup-server.ps1
   ```
2. Выделите **весь текст** (Cmd+A) → скопируйте (Cmd+C).
3. В RDP-сессии откройте **Блокнот** → вставьте (Ctrl+V).
4. **Файл → Сохранить как:**
   - Путь: `C:\1C-Lab\scripts\setup-server.ps1`
   - Тип файла: **Все файлы (*.*)**
   - Кодировка: **UTF-8**

### Вариант B — через общий буфер RDP

Если в клиенте RDP включён общий буфер обмена — скопируйте файл с Mac и вставьте в проводник Windows в `C:\1C-Lab\scripts\`.

### Вариант C — через `RUN-ME-FIRST.bat`

1. Скопируйте на сервер файл `scripts/server-access/RUN-ME-FIRST.bat` в `C:\1C-Lab\scripts\`.
2. Убедитесь, что рядом лежит `setup-server.ps1` (шаг 3).
3. Двойной клик по **`RUN-ME-FIRST.bat`** (запросит права администратора).

---

## Шаг 4. Скопируйте SSH-ключ Mac

1. На Mac откройте файл:
   ```
   scripts/server-access/authorized_key.pub
   ```
2. Скопируйте **одну строку** (начинается с `ssh-ed25519`).
3. На сервере в Блокноте сохраните как:
   ```
   C:\1C-Lab\scripts\authorized_key.pub
   ```

> Скрипт сам пропишет ключ в `C:\ProgramData\ssh\administrators_authorized_keys`, если файл лежит по этому пути.

---

## Шаг 5. Запустите настройку

В **PowerShell от имени администратора**:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
& C:\1C-Lab\scripts\setup-server.ps1
```

Ожидаемый вывод в конце:

```
=== Setup complete ===
Verify: Get-Service sshd; Test-Path C:\1C-Lab\Bases
```

---

## Шаг 6. Проверка на сервере

```powershell
Get-Service sshd
Test-Path C:\1C-Lab
Test-Path C:\1C-Lab\Bases
Test-Path C:\1C-Lab\scripts\setup-server.ps1
```

| Команда | Ожидаемый результат |
|---------|---------------------|
| `Get-Service sshd` | `Status: Running`, `StartType: Automatic` |
| `Test-Path C:\1C-Lab` | `True` |

Дополнительно — проверка SSH-ключа (если копировали `authorized_key.pub`):

```powershell
Test-Path C:\ProgramData\ssh\administrators_authorized_keys
Get-Content C:\ProgramData\ssh\administrators_authorized_keys
```

---

## Шаг 7. Проверка с Mac (для агента / администратора)

После настройки с Mac:

```bash
ssh -i ~/.ssh/id_ed25519_1clab Administrator@201.34.129.230 hostname
```

Успешный ответ — имя сервера Windows без запроса пароля.

Альтернатива — запуск автоматического скрипта:

```bash
cd /Users/sergey/Documents/1С_тест
./scripts/server-access/mac-setup.sh
```

---

## Устранение неполадок

| Симптом | Решение |
|---------|---------|
| `ExecutionPolicy` блокирует скрипт | `Set-ExecutionPolicy Bypass -Scope Process -Force` перед запуском |
| `sshd` не Running | `Start-Service sshd; Set-Service sshd -StartupType Automatic` |
| SSH с Mac: timeout | Проверьте firewall провайдера / проброс порта 22 |
| Ключ не принимается | Перезапустите `sshd`: `Restart-Service sshd` |
| Нет `authorized_key.pub` | Скрипт пропустит ключ; повторите шаг 4 и перезапустите setup |

---

## Следующие шаги

После успешной настройки доступа:

1. Развёртывание платформы 1С и ERP 2.5 (`deploy-1c-server`)
2. Установка MCP и выгрузка конфигурации (`setup-mcp-server`)
3. [Быстрый старт для ежедневной работы](quick-start.md)
