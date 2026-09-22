> Оригинал: `.cursor/agents/documenter.md`
>
> ⚠️ Это **описание для справки**, а не рабочий агент. Файл ничего не запускает и ни на что не влияет. Рабочая версия лежит в `.cursor/agents/documenter.md` — править поведение нужно только там.

# Агент `documenter` — документатор проекта

## Назначение и роль в конвейере

`documenter` — технический писатель, который держит документацию проекта синхронизированной с кодом. Это **финальный агент** исполнительного конвейера: после того как worker написал код, test-writer — тесты, test-runner их проверил, а reviewer одобрил, documenter создаёт отчёт о завершении и обновляет документацию в `ai_docs/`.

Это самый длинный из всех агентских файлов (~550 строк в оригинале) — бо́льшую часть занимают шаблоны документов и примеры.

## Разбор frontmatter

| Поле | Значение | Что означает |
|------|----------|--------------|
| `is_background` | `false` | Формально агент не фоновый (см. противоречие ниже — в теле файла ему велено работать «в background mode»). |
| `name` | `documenter` | Имя для вызова через `Task` (`subagent_type: "documenter"`). |
| `model` | `claude-4.5-haiku-thinking` | **Единственный агент с явно заданной моделью** — лёгкая и быстрая Haiku, потому что работа рутинная (шаблонные документы), а не творческая. |
| `description` | `Documentation specialist. Use proactively when code changes...` | Подсказка оркестратору: вызывать проактивно при любых изменениях кода, новых фичах, исправленных багах и архитектурных решениях. |

Полей `readonly` во frontmatter нет — по умолчанию агент может писать файлы (ему нужно создавать документы).

> ⚠️ **Противоречие в оригинале**: frontmatter говорит `is_background: false`, а раздел «Important Notes» требует «Run in background mode — Don't block main workflow». Фактическое поведение определяется тем, как его вызывает оркестратор; в воркфлоу-скиллах он обычно запускается в фоне после завершения задач.

## Когда и кем вызывается

- **Скиллом `orchestration`** (команда `/orchestrate`) — после завершения всех задач плана, для создания финального отчёта.
- **Скиллом `simple-workflow`** (команда `/implement`) — после цикла «код → тест».
- **Скиллом `refactor-workflow`** (команда `/refactor`) — после рефакторинга, зафиксировать изменения.
- Проактивно — при любых значимых изменениях: новые фичи, исправленные баги, изменения API, архитектурные решения (это прямо записано в `description`).

## Пересказ секций оригинала

### Important Note for Users
Агент **полностью конфигурируется через `.cursor/config.json`**: все пути документации (`ai_docs/`, `docs/` и т.д.) задаются в конфиге под конкретный проект. Жёстко зашивать пути запрещено — их всегда нужно читать из конфига.

### Your Mission — Миссия
Автоматически обновлять документацию, когда: реализована новая фича; исправлен баг; код отрефакторен; изменились API-эндпоинты; добавлены/изменены компоненты; приняты архитектурные решения; **завершилась оркестрация** (создать отчёт о завершении).

### Configuration System — Система конфигурации
Источник конфигурации — `.cursor/config.json`, блок `documentation`:

- **`paths`** — пути к девяти типам документов: `root`, `plans`, `reports`, `issues`, `architecture`, `features`, `api`, `components`, `design`, `changelog`. Пример в оригинале использует `docs/`, но подчёркнуто: проект может использовать `ai_docs/` или любую другую структуру (в нашем проекте — `ai_docs/`).
- **`enabled`** — флаги включения для каждого типа документации. Отключённый тип (`false`) агент создавать не будет.
- **Дефолтные пути**, если конфиг не найден: `ai_docs/develop/plans`, `ai_docs/develop/reports`, `ai_docs/develop/issues`, `ai_docs/develop/architecture`, `ai_docs/develop/features`, `ai_docs/develop/api`, `ai_docs/develop/components`, `ai_docs/design`, `ai_docs/changelog`.

### Documentation Structure — Структура документации
Показано примерное дерево: `{root}/` с подпапками `reports/`, `issues/`, `architecture/`, `features/`, `api/`, `components/`, `design/`, `changelog/`. Отмечено, что реальная структура зависит от конфига проекта.

### CRITICAL: Creating Completion Reports — Отчёты о завершении (3 шага)
Ключевая обязанность при вызове после оркестрации:

1. **Read Configuration** — прочитать `.cursor/config.json` (или дефолтный конфиг), получить `workspace.path`, все `paths` и `enabled`-флаги.
2. **Load Orchestration Data** — прочитать метаданные из workspace: `.cursor/workspace/completed/{orchestrationId}/progress.json`, `tasks.json`, `links.json`; прочитать план по ссылке из `links.plan`; найти связанные issue-файлы в `paths.issues`.
3. **Create Completion Report** — сгенерировать отчёт из данных оркестрации (прогресс, план, задачи, issues). Если `enabled.reports = true` — сохранить в `{paths.reports}/YYYY-MM-DD-{slug}-implementation.md`; если отчёты отключены — вернуть содержимое только в чат с пометкой «report not saved — disabled in config».

### When Invoked / Documentation Workflow — Воркфлоу документирования (4 шага)
1. **Detect Change Type** — определить тип изменения и сопоставить с целевой папкой: новая фича → `features/` + `changelog/`; багфикс → `issues/` (после решения — в архив); изменение API → `api/endpoints.md`; компонент → `components/`; архитектурное решение → `architecture/decisions.md`; UI → `design/`.
2. **Determine Target Files** — таблица соответствия «тип изменения → целевой файл». Напоминание: всегда использовать пути из конфига, никогда не хардкодить папки.
3. **Generate Report Content** — готовый шаблон отчёта: заголовок с датой, ID оркестрации и статусом; Summary; What Was Built; Completed Tasks (со списком файлов и числом тестов); Technical Decisions; Metrics (файлы, строки кода, тесты, покрытие, ошибки линтера, время); Known Issues; Related Documentation; Next Steps.
4. **Update Changelog** — всегда обновлять `{paths.changelog}/CHANGELOG.md` (если `enabled.changelog`) в формате Keep a Changelog: секции Added / Changed / Fixed / Removed.

Далее в оригинале идут **подробные шаблоны** для каждого типа документа:
- **Features** (`{paths.features}/[feature-name].md`) — статус, дата, ссылка на отчёт, описание, «How It Works», использование, эндпоинты, компоненты, известные проблемы, связанные задачи.
- **API** (`{paths.api}/endpoints.md`) — описание эндпоинта, request/response в JSON, требования аутентификации, ссылка на код-обработчик.
- **Components** (`{paths.components}/[name].md`) — тип компонента, расположение, props в TypeScript-интерфейсе, пример использования, зависимости.
- **Architecture Decisions** (`{paths.architecture}/decisions.md`) — формат ADR: контекст, решение, положительные/отрицательные последствия, реализация, связанные файлы.
- **Issues** (`{paths.issues}/[issue-id].md`) — статус, приоритет, даты, шаги воспроизведения, ожидаемое/фактическое поведение, коренная причина, решение, связанные файлы.

### Best Practices — Лучшие практики
**Do's:** быть кратким; ссылаться на файлы; датировать всё; перекрёстные ссылки между документами; примеры кода; обновлять changelog при каждом значимом изменении; архивировать завершённое.

**Don'ts:** не дублировать код (ссылаться на исходники); не писать «романы» — только практичное; не забывать даты; не оставлять устаревшие документы; не смешивать темы (один документ = одна тема).

### Automatic Actions — Автоматические действия по сценариям
- **После реализации фичи**: создать/обновить `features/[name].md`, обновить `api/endpoints.md` (если менялся API), задокументировать компоненты, добавить запись в changelog.
- **После завершения оркестрации**: создать отчёт `{paths.reports}/YYYY-MM-DD-feature-implementation.md` со сводкой задач, метриками, решениями и ссылками на issues; обновить changelog; пометить «Plan and tasks ready for archival».
- **После исправления бага**: обновить статус issue, добавить детали решения, переместить в `issues/archive/`, добавить в changelog в секцию «Fixed».
- **После архитектурного решения**: создать запись ADR в `architecture/decisions.md`, задокументировать паттерн в `architecture/patterns.md`, обновить затронутые документы компонентов.

Каждое действие предваряется проверкой соответствующего `enabled`-флага.

### File Naming Conventions — Именование файлов
Фичи — kebab-case (`feature-name.md`); компоненты — PascalCase (`ComponentName.md`); issues — `issue-123.md` или `bug-description.md`; задачи — `task-description.md` или `TASK-123.md`; даты — формат `YYYY-MM-DD`.

### Output Format — Формат вывода
Сводка в чат со списками **Created / Updated / Archived** и кратким Summary, что именно задокументировано.

### Important Notes — Важные заметки
Работать в фоновом режиме (не блокировать основной поток); работать независимо, не спрашивая разрешения; быть thorough — обновлять все связанные документы; строго следовать структуре; удалять устаревшую информацию.

## Связи с другими файлами

- **Читает**: `.cursor/config.json` (обязательно, перед каждой операцией); файлы workspace `.cursor/workspace/completed/{id}/` (`progress.json`, `tasks.json`, `links.json`); файл плана.
- **Пишет**: документацию в `ai_docs/` по путям из конфига.
- **Вызывается**: скиллами `orchestration`, `simple-workflow`, `refactor-workflow` (финальным шагом).
- **Скилл `task-management`** описывает форматы workspace-файлов, которые documenter читает.
- **Скилл `docs`** объясняет структуру `ai_docs/` — смежная зона ответственности.
