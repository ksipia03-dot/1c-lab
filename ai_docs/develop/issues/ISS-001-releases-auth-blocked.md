# GATE-001 / DL-001: releases.1c.ru rights + educational platform workaround

**Дата:** 2026-08-21  
**Статус сессии releases/portal:** **AUTH_OK** (`Kuleshov_Sergey`)  
**Статус UC1 (Learning Center):** **AUTH_OK** — скачивание учебной платформы выполнено  
**Статус ERP 2.5 demo `.dt`/`.cf`:** **BLOCKED** (нет прав на продукт)

## UC1 — прогресс (обход DL-001 для платформы)

| Шаг | Результат |
|-----|-----------|
| Страница | `https://uc1.1c.ru/uchebnaya-versiya-1s/?assignmentId=b844196d-925b-4a03-b862-e29d6180d95a&submissionId=8e385f76-79c4-64b8-77fc-fc8a4eb1b571` |
| Сессия | Логин подтверждён (меню аккаунта / logout) |
| Windows ZIP | `C:\1C-Lab\downloads\training_8_3_27_1688.zip` — **542 699 407** байт |
| Копия (запрошенный каталог) | `C:\1C-Lab\downloads\edu-platform\training_8_3_27_1688.zip` |
| Linux ZIP (`training64_*`) | **1 516 033 220** байт — `.run`, не для Windows |
| Установка | `setup.exe /S` → **OK**, продукт «1С:Предприятие 8 (учебная версия) 8.3.27.1688» |
| **Путь учебной платформы** | **`C:\Program Files (x86)\1cv8t\8.3.27.1688\bin\1cv8t.exe`** |
| Каталог версии | `C:\Program Files (x86)\1cv8t\8.3.27.1688\` |
| ИБ | `C:\1C-Lab\Bases\ERP25_Demo` (`ERP25 Учебная`) — **пустая** файловая ИБ (`1Cv8.1CD` ~3.2 MB) |

Публичный `v8.1c.ru` → только ссылки на `online.1c.ru/catalog/free/28765768/` (без прямого zip); фактическая загрузка — с UC1.

Подробности: `C:\1C-Lab\downloads\DOWNLOAD-STATUS.md`.

## Повторная проверка releases (ERP / коммерческая платформа)

| Проверка | Результат |
|----------|-----------|
| `https://releases.1c.ru/total` | Каталог доступен, пользователь виден |
| `https://releases.1c.ru/project/ERP2` | **Нет доступа** |
| `https://releases.1c.ru/project/Platform83` | **Нет доступа** |
| Демо ERP `.dt` / `.cf` | **Недоступно** |

Артефакты: `C:\1C-Lab\downloads\_releases-erp2-probe.json`, `_uc1-edu-snapshot.json`, `_uc1-file-map.json`.

## Следствие

- **GATE-001 (аутентификация)** — снят для releases и UC1.
- **DL-001 (учебная платформа Windows)** — **частично снят** через UC1 (учебная редакция `1cv8t`, не коммерческий `1cv8`).
- **DL-ERP / DEP-ERP** — **заблокированы**: нет права на ERP 2.5; пустая ИБ ≠ демоконфигурация ERP.
- Пиратские зеркала **не используются**.

## Что нужно для полной ERP 2.5

1. Учётка с правом скачивания «1С:ERP Управление предприятием 2» ред. 2.5 (`.dt` демобазы или `.cf`), **или**
2. Регистрация поставки / PIN в [portal.1c.ru](https://portal.1c.ru/), **или**
3. Копия официального `.dt`/`.cf` в `C:\1C-Lab\downloads\` и загрузка в `C:\1C-Lab\Bases\ERP25_Demo`.

## Не блокируется

- Документация ИТС ERP 2.5 (чтение) — **DOC-002**
- Учебная платформа 8.3.27.1688 + пустая ИБ для отработки tooling / MCP prep
