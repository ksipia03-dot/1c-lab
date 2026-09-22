# 1С-лаборатория — старт для ИИ-агента

> **Читать первым** при работе над этой лабораторией 1С в Cursor.
> Этот файл — главная точка входа для агентов. Детали синхронизации — в [docs/07-sync-github-1c-server.md](docs/07-sync-github-1c-server.md).

## Что это за проект

Учебная лаборатория **1С**: доработки конфигурации и выгрузка в информационную базу (ИБ).

Владелец — не программист. Объяснения — простым языком; термины — с одной короткой расшифровкой.

Код пишется **здесь**, в чате Cursor на машине **vdswin2k22**. На старом сервере 1С файлы руками **не правят** — туда конфигурацию загружает Конфигуратор после push.

## Точки синхронизации

| Точка | Путь / адрес | Роль |
|-------|----------------|------|
| **Windows (источник правды)** | `C:\Users\Administrator\Documents\1С_тест` на **vdswin2k22** | Единственное место правок tracked-файлов |
| **GitHub** | `https://github.com/ksipia03-dot/1c-lab`, ветка `main` | Удалённый репозиторий, триггер деплоя |
| **Старый сервер 1С** | `201.34.129.230` (self-hosted runner) | Runtime: Конфигуратор загружает файлы в ИБ; **не править tracked-файлы на сервере** |

Поток: **Windows → GitHub `ksipia03-dot/1c-lab` → self-hosted runner на 201.34.129.230 → Конфигуратор загружает в ИБ**.

Это не rsync на Linux: выкатка — `1cv8t.exe DESIGNER /LoadConfigFromFiles` + `/UpdateDBCfg`.

## Куда смотреть (порядок)

1. **Этот файл** — `AGENTS.md`
2. **[docs/07-sync-github-1c-server.md](docs/07-sync-github-1c-server.md)** — commit, push, deploy, проверка Actions
3. Правило alwaysApply: [`.cursor/rules/1c-sync-github.mdc`](.cursor/rules/1c-sync-github.mdc)

## Commit / deploy (кратко)

| Действие | Правило |
|----------|---------|
| Правки | Только локально в `C:\Users\Administrator\Documents\1С_тест` на vdswin2k22. **Не править** tracked-файлы на старом сервере 1С (`201.34.129.230`) |
| **Синхронизация** | **После каждого завершённого изменения** (задача, код, документация) — полный цикл **Windows → GitHub → Конфигуратор в ИБ**, если менялись отслеживаемые файлы |
| Commit | Сразу после изменения, **без ожидания отдельной просьбы**. Сообщение — **почему**, не перечень «что» |
| Push | Сразу после commit: `git push origin main` |
| Deploy | Push триггерит GitHub Actions → self-hosted runner на `201.34.129.230` → Конфигуратор загружает конфигурацию в ИБ |
| Проверка | После push: `gh run list --limit 3`. **Не считать задачу завершённой**, пока workflow **Deploy to 1C** не зелёный |
| GitHub-вход | `gh auth` уже выполнен (аккаунт `ksipia03-dot`). **Не просить** `gh auth login`, пока живая проверка `gh auth status` не упала |
| Сессия | Одна конкретная задача; по завершении — запись в оркестрации, если она идёт |

Цикл после каждого завершённого изменения tracked-файлов:

```powershell
git add -A
git commit -m "почему сделали это изменение"
git push origin main
gh run list --limit 3
```

Задачу **не закрывать**, пока **Deploy to 1C** не зелёный.

Подробности — [docs/07-sync-github-1c-server.md](docs/07-sync-github-1c-server.md).

## Вводная фраза для нового чата

```text
продолжаем 1С. Сначала прочитай AGENTS.md и следуй ему.
```

---

*Связанные документы: [docs/07-sync-github-1c-server.md](docs/07-sync-github-1c-server.md) · [`.cursor/rules/1c-sync-github.mdc`](.cursor/rules/1c-sync-github.mdc)*
