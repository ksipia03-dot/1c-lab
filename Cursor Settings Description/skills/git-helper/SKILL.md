> Оригинал: `.cursor/skills/git-helper/SKILL.md`
>
> ⚠️ Это **описание для справки**, а не рабочий скилл. Файл ничего не запускает и ни на что не влияет. Рабочая версия лежит в `.cursor/skills/git-helper/SKILL.md` — править поведение нужно только там.

# Скилл `git-helper` — помощник по git-операциям

## Назначение и тип

Скилл — **шпаргалка по git**: генерация сообщений коммитов в формате Conventional Commits, операции с ветками, разрешение конфликтов, откат изменений, исследование истории, stash, теги, cherry-pick, типовые сценарии (PR, squash, «закоммитил не в ту ветку») и правила безопасности.

**Тип: гайдлайн** (справочник). Не оркестрирует агентов и не содержит воркфлоу — это набор рецептов, к которым ассистент обращается при любой git-задаче.

## Разбор frontmatter

| Поле | Значение | Что означает |
|------|----------|--------------|
| `name` | `git-helper` | Имя скилла. |
| `description` | `Git operations helper. Use for commit message generation, branch management, conflict resolution, and git workflow guidance.` | Применять для генерации сообщений коммитов, управления ветками, разрешения конфликтов и руководства по git-потоку. |

## Когда и кем читается/вызывается

- **Триггерные ситуации**: любая работа с git — «сгенерируй сообщение коммита», «создай ветку», «разреши конфликт», «откати изменения», «найди, когда появился баг», «создай PR», «сделай squash».
- **Читает**: основной ассистент (git-операции обычно делает координатор сам, а не отдельный субагент).
- **Дополняется правилами**: `.cursor/rules/commit-messages.md` (формат сообщений) и `.cursor/rules/git-workflow.md` (именование веток, запреты) — скилл даёт команды, правила задают стандарты.

## Подробный пересказ содержимого

### 1. Generate Commit Messages — генерация сообщений коммитов

Анализ staged-изменений и генерация сообщения по Conventional Commits. Сначала смотрим изменения:

```bash
git diff --cached --stat
git diff --cached
```

Формат: `<type>(<scope>): <subject>` + опциональное тело.

**Типы**: `feat` (новая фича), `fix` (исправление бага), `refactor` (переструктурирование без изменения поведения), `docs` (только документация), `test` (только тесты), `chore` (тулинг, конфиги, зависимости), `perf` (улучшения производительности).

**Примеры**: `feat(auth): add JWT token refresh`; `fix(api): handle null response in user endpoint`; `refactor(db): extract query builders to separate file`; `docs(readme): update installation steps`.

### 2. Branch Operations — операции с ветками

**Создание feature-ветки:**

```bash
git checkout main
git pull origin main
git checkout -b feature/description
```

**Чистка слитых веток:**

```bash
git branch --merged | grep -v "main\|master" | xargs git branch -d
```

**Обновление ветки из main** (два варианта): `git fetch origin && git rebase origin/main` ИЛИ `git merge origin/main`.

### 3. Conflict Resolution — разрешение конфликтов (5 шагов)

1. Найти конфликтующие файлы: `git status`.
2. Открыть каждый файл и найти маркеры конфликта.
3. Разрешить, выбрав правильный код.
4. Добавить разрешённые файлы: `git add <file>`.
5. Продолжить: `git rebase --continue` или `git commit`.

### 4. Undo Operations — откат изменений

| Задача | Команда |
|--------|---------|
| Откатить последний коммит (изменения сохранить) | `git reset --soft HEAD~1` |
| Убрать файлы из staging | `git restore --staged <file>` |
| Отбросить локальные изменения | `git restore <file>` |
| Откатить запушенный коммит (создаёт новый коммит) | `git revert <commit-hash>` |

### 5. History Investigation — исследование истории

**Поиск коммита, внёсшего баг (bisect):**

```bash
git bisect start
git bisect bad          # текущий коммит плохой
git bisect good <hash>  # известный хороший коммит
# Git выкачивает средний коммит; тестируем и помечаем good/bad; повторяем до нахождения
```

**Кто изменил строку:** `git blame <file>`.
**Поиск по сообщениям коммитов:** `git log --grep="keyword"`.
**Поиск по изменениям кода:** `git log -p -S "function_name"`.

### 6. Stash Operations — временное сохранение работы

**Сохранить:**

```bash
git stash push -m "description"
git stash list
git stash show stash@{0}
```

**Восстановить:** `git stash pop` (применить и удалить), `git stash apply` (применить и оставить), `git stash drop` (выбросить).

### 7. Tags (Release Marking) — теги для релизов

**Создать и запушить:**

```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
git push origin --tags  # все теги
```

**Список и удаление:** `git tag -l`; `git tag -d v1.0.0` (локально); `git push origin :refs/tags/v1.0.0` (удалённо).

### 8. Cherry-pick — перенос отдельных коммитов

```bash
git cherry-pick <commit-hash>
git cherry-pick <hash1> <hash2>  # несколько коммитов
```

### Commit Message Generation — алгоритм генерации сообщения (5 шагов)

1. `git diff --cached --stat` — какие файлы изменены.
2. `git diff --cached` — сами изменения.
3. Определить тип: новый файл/фича → `feat`; исправление бага → `fix`; переструктурирование без смены поведения → `refactor`; только тесты → `test`; документация → `docs`; зависимости/конфиги/тулинг → `chore`.
4. Определить scope (затронутый компонент/сервис/область).
5. Сгенерировать сообщение по формату Conventional Commits.

### Common Scenarios — типовые сценарии

**«Create a PR»:**

```bash
git push -u origin HEAD
gh pr create --title "feat: description" --body "..."
# ИЛИ предоставить ссылку на GitHub
```

**«Squash my commits»:** `git rebase -i HEAD~<number>`, в редакторе менять `pick` на `squash` для объединяемых коммитов. **Предупреждение:** не использовать интерактивный rebase на shared/public-ветках.

**«I committed to wrong branch»:**

```bash
git log -1                      # запомнить хеш коммита
git checkout correct-branch     # перейти на правильную ветку
git cherry-pick <hash>          # перенести коммит
git checkout wrong-branch       # вернуться на неправильную
git reset --hard HEAD~1         # удалить коммит оттуда
```

**«Merge vs Rebase»** — когда что использовать:

| | Merge | Rebase |
|---|-------|--------|
| Эффект | Сохраняет историю, создаёт merge-коммит | Линейная история, переписывает коммиты |
| Использовать для | Интеграции фичи в main; когда ветка shared | Актуализации feature-ветки; чистки локальных коммитов |

### Safety Rules — правила безопасности

- Никогда не делать force push в `main`/`master`.
- Никогда не делать rebase публичных/shared веток.
- Всегда делать бэкап перед деструктивными операциями.
- Проверять `git status` перед любой операцией.

Финальная пометка оригинала: в проекте могут быть git-хуки в `.cursor/hooks/` для авто-линтинга/валидации. *(Примечание: в текущем `.cursor/hooks.json` оба списка хуков пусты — см. `../../hooks.json.md`.)*

## Связи с другими файлами

- **Читается**: основным ассистентом при любых git-операциях (коммиты, ветки, PR, конфликты, откаты).
- **Связанные правила**: `.cursor/rules/commit-messages.md` (детальный стандарт сообщений — скилл даёт краткий формат, правило полный), `.cursor/rules/git-workflow.md` (именование веток `feature/`, `fix/`, `hotfix/`, запрет force push в main, запрет секретов в коммитах) — оба Agent Requested, подключаются по запросу.
- **Связанные команды/воркфлоу**: git-операции встречаются в шагах аудита (`/audit --since <ref>` использует `git diff --name-only` из скилла `audit-workflow`).
- **Упоминает**: `.cursor/hooks.json` (хуки после правок — сейчас пустые).
