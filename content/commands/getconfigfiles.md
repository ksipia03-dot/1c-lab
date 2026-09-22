# Команда: getconfigfiles — выгрузить объекты конфигурации из ИБ в репозиторий

**SSOT.** Реализация: [`scripts/1c-remote/Export-Config.ps1`](../scripts/1c-remote/Export-Config.ps1).
Тот же скрипт вызывается агентом и CI. Не дублировать команды `1cv8t.exe` вручную.

## Где выполняется

Конфигуратор (Designer) работает **на старом сервере 1С** (`201.34.129.230`), не на vdswin2k22 —
учебной платформы на этой машине нет. `PLATFORM_PATH` и `INFOBASE_PATH` из `.dev.env` — пути **на старом сервере**.

## Шаги

1. Список объектов — в `repoobjects.txt` (одно полное имя метаданного на строку, например `Справочник.Контрагенты`).
   Без `-ListFile` выгрузится вся конфигурация (первый снапшот); список — для частичной выгрузки.

2. Выгрузка **по SSH с vdswin2k22** (после того как жив `ssh 1c-erp`):

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\1c-remote\Export-Config.ps1 `
       -Remote -ListFile repoobjects.txt
   ```

   `-Remote` запускает ту же команду Конфигуратора на старом хосте через `REMOTE_SSH_HOST` (`1c-erp`).
   При `-Remote` пути `-OutputPath` / `EXPORT_PATH` — пути **на старом сервере**.

3. Локально на раннере (checkout репозитория на старом сервере):

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\1c-remote\Export-Config.ps1 -ListFile repoobjects.txt
   ```

4. Расширение: добавить `-Extension ИмяРасширения`.

5. Лог: `-LogPath`; по умолчанию `1cv8-export.log`. Ошибки смотреть в логе до любых правок.

## Правила

- Бинарник — **`1cv8t.exe`** (учебная платформа), не `1cv8.exe`. Скрипт берёт его из `PLATFORM_PATH` сам.
- Пути ИБ и платформы не выдумывать — только подтверждённые значения в `.dev.env`.
- Полный ERP-дамп (~44k файлов) в git не коммитить — только наши объекты/расширение.
