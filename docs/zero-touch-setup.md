# Zero-touch: учебный стенд 1С:ERP + Cursor

**Для вас:** напишите агенту в Cursor *«настрой ERP»* и один раз передайте логин/пароль Administrator **в чат** (не в файлы). Дальше — **ничего не делать**.

---

## Самый простой способ

На рабочем столе Mac — три RDP-файла:

| Файл | Назначение |
|------|------------|
| **`ERP-Uchebny.rdp`** / **`ERP-Uchebny-plain.rdp`** | **Обычный доступ** — plain RDP, без alternate shell *(рекомендуется)* |
| **`ERP-Uchebny-bootstrap.rdp`** | **Одноразово**, только если нужен bootstrap через RDP **после** успешного plain-подключения |

1. **Дважды кликните** `ERP-Uchebny.rdp` или `ERP-Uchebny-plain.rdp` — откроется Microsoft Remote Desktop и обычный рабочий стол Windows.
2. Настройку сервера (OpenSSH, каталоги, ключ) выполняет **агент с Mac** через SSH — RDP bootstrap **не обязателен**.

**Bootstrap через RDP** *(опционально, продвинутый путь):* только если plain RDP уже работает, один раз откройте `ERP-Uchebny-bootstrap.rdp`. Окно с текстом *«Bootstrap complete, close this window»* — нормально. Закройте сессию, подождите ~1–2 минуты, дальше — только plain RDP.

> **Не подключайтесь через bootstrap-файл «с нуля»:** alternate shell в Microsoft Remote Desktop часто обрывает сессию с *«Your session ended because of an error»*.

Копировать файлы, открывать PowerShell или терминал **не нужно**. Агент обновляет bootstrap-скрипт командой `scripts/server-access/upload-and-update-rdp.sh`.

---

## Четыре пути (от простого к сложному)

| Tier | Ваши действия | Когда |
|------|---------------|-------|
| **B** ★ | 0 — агент всё сделает с Mac | Есть VPS, RDP работает *(рекомендуется)* |
| **A** | 1 вставка в панели хостинга | Новый VPS или переустановка ОС |
| **C** | 0 — только браузер | Не нужен свой сервер |
| **D** | 0 — только Cursor | Учёба по docs / локальный dump |

---

### Tier B — полная автоматизация с Mac *(по умолчанию)*

**Prerequisite для Timeweb VPS:** облачный firewall уже настроен (RDP **3389** открыт). Если RDP не работает — сначала **`ERP-Uchebny-plain.rdp`**; подробнее — [timeweb-firewall-rules.md](timeweb-firewall-rules.md).

Агент запускает `scripts/server-access/remote-probe-and-bootstrap.sh` — скрипт сам ждёт SSH и настраивает сервер. RDP/PowerShell вам не нужны.

**Один раз в чат:** `Administrator` + пароль + IP сервера → *«execute»*.

---

### Tier A — одна вставка в панели хостинга

При **создании** или **переустановке** Windows Server вставьте в поле **User data** / **Cloud-init** / **Скрипт запуска** содержимое файла:

`scripts/server-access/provider-userdata.ps1`

**Провайдеры с таким полем:** Selectel, Timeweb Cloud, Yandex Cloud, VK Cloud, REG.RU Cloud.

**Опционально — bundle по URL:** задайте переменную `ONEC_LAB_SETUP_URL` = HTTPS-ссылка на zip (см. `scripts/server-access/create-setup-bundle.sh`). Скрипт скачает `setup-server.ps1` и ключ, выполнит настройку.

Подождите 3–5 мин → напишите агенту *«продолжай»*.

---

### Tier C — 1С:Fresh, без сервера

Демо ERP в облаке: [1cfresh.com](https://1cfresh.com/) → регистрация → **1С:ERP Управление предприятием 2** (демо).

На Mac: Cursor + этот проект. MCP **ограничен** (нет своей базы и dump). Подходит для изучения интерфейса и документации.

---

### Tier D — только Mac

Cursor + `docs/` + правила в `.cursor/rules/`. Опционально: один раз скачать `.cf` с [releases.1c.ru](https://releases.1c.ru) → положить в `config/erp-dump/` (агент подскажет). Без thick client и без полного MCP.

---

## После настройки (Tier A/B)

| Задача | Действие |
|--------|----------|
| Практика в 1С | Двойной клик `ERP-Uchebny.rdp` → ярлык **«1С:ERP Учебная»** |
| AI в Cursor | Открыть проект `1С_тест` — MCP уже в фоне |

Подробнее: [quick-start.md](quick-start.md).
