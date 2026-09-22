# Команда: deploy-and-test — полный цикл изменения конфигурации

**SSOT.** Выгрузка — [`Export-Config.ps1`](../scripts/1c-remote/Export-Config.ps1),
загрузка — [`Import-Config.ps1`](../scripts/1c-remote/Import-Config.ps1).
Детали в [getconfigfiles.md](getconfigfiles.md) и [update1cbase.md](update1cbase.md).

## Ежедневный цикл (vdswin2k22 → GitHub → Конфигуратор в ИБ)

1. **Вы в чате** описываете задачу простым языком.
2. **Агент** планирует и пишет код в `C:\Users\Administrator\Documents\1С_тест` (источник правды).
3. **Агент** сам делает commit и push — отдельная просьба не нужна.
4. **GitHub Actions** (workflow `Deploy to 1C`) на self-hosted runner `201.34.129.230`
   запускает Import-Config.ps1 → Конфигуратор загружает конфигурацию в ИБ и обновляет БД.
5. **Агент** проверяет `gh run list` и пишет вам: запушено, Actions зелёный, база обновлена.
   Только тогда задача закрыта.

## Проверка после деплоя

```powershell
gh run list --limit 3        # workflow Deploy to 1C должен быть зелёный
```

Если красный — смотреть лог рана и `1cv8-import.log` (путь в шаге workflow), чинить, push повторно.

## Правки напрямую на старом сервере

Запрещены. Runtime-контур обновляется только через push → Actions. Ручная правка будет
перезаписана следующим деплоем.

## Smoke-проверка SSH (не деплой)

```powershell
ssh -o BatchMode=yes -o ConnectTimeout=10 1c-erp "hostname"
```

Нужна только для диагностики и первичной выгрузки (Export). Деплой идёт через Actions, не через SSH.
