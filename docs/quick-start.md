# Быстрый старт — 1С:ERP Учебная

> **Настройка:** агент делает всё сам — см. [zero-touch-setup.md](zero-touch-setup.md).  
> Вам: creds в чат → *«настрой ERP»* → **0 действий в терминале**.

---

## Шаг после RDP: одна команда на сервере

После подключения по RDP откройте **PowerShell от имени администратора** и выполните **одну команду** (URL выдаёт агент или скрипт на Mac):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex (iwr -UseBasicParsing 'URL').Content
```

Скрипт установит OpenSSH, MCP, платформу 1С (если дистрибутив уже в `C:\1C-Lab\downloads\`), демобазу ERP 2.5 и ярлыки. Журнал: `C:\1C-Lab\install.log`.

На Mac URL публикуется так:

```bash
./scripts/server-access/upload-install-script.sh
```

Если платформы или ERP ещё нет — скрипт откроет **releases.1c.ru** в браузере ИТС и подскажет, что скачать в `C:\1C-Lab\downloads\`, затем перезапустите ту же команду.

---

## Сценарий A: практика в 1С

1. **Двойной клик** на Mac: **`ERP-Uchebny.rdp`** *(или **`ERP-Uchebny-plain.rdp`** — то же подключение, без alternate shell)*
2. На сервере — ярлык **«1С:ERP Учебная»**

> **RDP:** используйте **plain**-файл для обычного доступа. Файл **`ERP-Uchebny-bootstrap.rdp`** с alternate shell — только **одноразово**, если нужен bootstrap через RDP **после** того, как plain-подключение уже работает. Alternate shell в Microsoft Remote Desktop часто обрывает сессию с *«Your session ended because of an error»*.

| Параметр | Значение |
|----------|----------|
| База | `ERP25 Учебная` |
| Пользователь | `Администратор` |
| Пароль | пустой (если не меняли) |

---

## Сценарий B: AI в Cursor

1. **Cursor** → проект **`1С_тест`**
2. MCP работает в фоне (туннель настраивает агент)

Подробнее: [cursor-setup.md](cursor-setup.md).

---

## Альтернативы без своего сервера

| Путь | Документ |
|------|----------|
| Облачное демо 1С:Fresh | [zero-touch-setup.md](zero-touch-setup.md) → Tier C |
| Только Mac + docs | [zero-touch-setup.md](zero-touch-setup.md) → Tier D |

---

## Если что-то не работает

| Проблема | Действие |
|----------|----------|
| Стенд не поднят | Напишите агенту — он перезапустит bootstrap |
| RDP не подключается | Сначала **`ERP-Uchebny-plain.rdp`**; firewall Timeweb — [timeweb-firewall-rules.md](timeweb-firewall-rules.md) *(порт 3389 уже открыт)* |
| RDP обрывается с ошибкой сессии | Убедитесь, что **нет** alternate shell — plain-файл, не bootstrap |
| MCP не отвечает | Агент проверит SSH-туннель |
| Аварийный ручной путь | [server-first-run.md](server-first-run.md) *(не для обычного использования)* |

---

## Ссылки

- [Zero-touch настройка](zero-touch-setup.md)
- [Документация ERP 2.5](1c-erp-25/README.md)
- [Треки экзамена](exam-tracks.md)
