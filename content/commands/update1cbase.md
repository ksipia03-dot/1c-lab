# Команда: update1cbase — загрузить конфигурацию из файлов в ИБ

**SSOT.** Реализация: [`scripts/1c-remote/Import-Config.ps1`](../scripts/1c-remote/Import-Config.ps1).
Тот же скрипт вызывается агентом и workflow **Deploy to 1C**. Не дублировать команды `1cv8t.exe` вручную.

## Где выполняется

Конфигуратор (Designer) работает **на старом сервере 1С** (`201.34.129.230`), не на vdswin2k22.
Платформа — учебная: **`1cv8t.exe`**, пути из `.dev.env` — пути на старом сервере.

## Шаги

1. **Стандартный путь — push в `main`.** Workflow `.github/workflows/deploy-1c.yml` сам запускает
   Import-Config.ps1 на self-hosted runner. Отдельно «деплоить» не нужно.

2. Запуск вручную с vdswin2k22 (по SSH, когда жив `ssh 1c-erp`):

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\1c-remote\Import-Config.ps1 -Remote
   ```

   Источник (`-SourcePath` / `EXPORT_PATH`) при `-Remote` — путь **на старом сервере**.

3. Локально на раннере (checkout на старом сервере):

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\1c-remote\Import-Config.ps1
   ```

4. Расширение: `-Extension ИмяРасширения`.

5. Лог: `-LogPath` (по умолчанию `1cv8-import.log`). Код возврата ненулевой = загрузка не удалась.

## Что делает скрипт

`1cv8t.exe DESIGNER` + `/LoadConfigFromFiles <путь>` + `/UpdateDBCfg` (+ `-Extension`), лог через `/Out`.

## Правила

- Задача считается закрытой только когда `gh run list` показывает зелёный **Deploy to 1C**.
- После обновления конфигурации базы на старом сервере руками файлы не править — следующий деплой затрёт.
