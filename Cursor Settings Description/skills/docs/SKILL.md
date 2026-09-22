> Оригинал: `.cursor/skills/docs/SKILL.md`
>
> ⚠️ Это **описание для справки**, а не рабочий скилл. Файл ничего не запускает и ни на что не влияет. Рабочая версия лежит в `.cursor/skills/docs/SKILL.md` — править поведение нужно только там.

# Скилл `docs` — структура проектной документации

## Назначение и тип

Скилл объясняет, **как устроена документация проекта** (по умолчанию `ai_docs/`): какие папки существуют, что в них лежит, кто их создаёт, когда обновлять, как читать и как называть файлы. Ключевая идея оригинала: **все пути документации конфигурируются в `.cursor/config.json` и никогда не хардкодятся**.

**Тип: гайдлайн** (справочник). Не содержит воркфлоу и не оркестрирует агентов — это чисто справочный скилл, который применяют, когда нужно понять организацию документации.

## Разбор frontmatter

| Поле | Значение | Что означает |
|------|----------|--------------|
| `name` | `docs` | Имя скилла. |
| `description` | `Skill for understanding project documentation structure. Apply when user asks about documentation or needs to see how docs are organized.` | Применять, когда пользователь спрашивает о документации или нужно понять, как организованы доки. |
| `disable-model-invocation` | `false` | Модели (ассистенту) разрешено вызывать этот скилл самостоятельно — единственный скилл среди описанных, где это поле выставлено явно. |

## Когда и кем читается/вызывается

- **Триггерные ситуации**: пользователь спрашивает о документации («где лежат планы?», «как устроены доки?»); агенту нужно сохранить или найти документ и надо знать правильный путь.
- **Косвенно связан с агентом `documenter`**: команда `/documenter` упоминается в скилле как способ ручного обновления документации.
- **Читают агенты**, которые пишут документацию: прежде всего `documenter`, а также `planner` (кладёт планы в `plans/`) и любой агент, логирующий техдолг в `issues/`.

## Подробный пересказ содержимого

### Configuration-Based Documentation — документация на конфигурации

**ВАЖНО (прямая пометка оригинала):** пути документации настраиваются в `.cursor/config.json`. Никогда не хардкодить `ai_docs/` или любые конкретные пути. Чтение конфигурации (псевдокод из оригинала):

```javascript
config = readJSON(".cursor/config.json")
paths = config.documentation.paths

// paths.root = "ai_docs" (или кастомный путь пользователя)
// paths.plans = "ai_docs/develop/plans"
// paths.reports = "ai_docs/develop/reports"
// и т.д.
```

### Default Documentation Structure — структура по умолчанию

Дерево для случая, когда root = `ai_docs/` (все пути пользователь может переопределить):

```
{configured-root}/               # из config: paths.root
├── design/                      # из config: paths.design
├── develop/
│   ├── api/                     # из config: paths.api
│   ├── architecture/            # из config: paths.architecture
│   ├── components/              # из config: paths.components
│   ├── features/                # из config: paths.features
│   ├── plans/                   # из config: paths.plans
│   ├── reports/                 # из config: paths.reports
│   └── issues/                  # из config: paths.issues
└── changelog/                   # из config: paths.changelog
```

### Directory Purpose — назначение директорий

| Папка | Назначение | Кто создаёт |
|-------|------------|-------------|
| `plans/` | Высокоуровневое: **что строить** | planner |
| `reports/` | Итог: **что было построено** | documenter |
| `issues/` | Техдолг: **что чинить потом** | любой агент |
| `features/` | Описания фич и детали реализации | documenter |
| `api/` | Документация API-эндпоинтов | documenter |
| `components/` | Документация компонентов | documenter |
| `architecture/` | Архитектурные решения и паттерны | documenter |
| `design/` | UI/UX-дизайны, гайды стилей | documenter |
| `changelog/` | История версий | documenter |

### When to Update Documentation — когда обновлять

- **Автоматически** (по завершении оркестрации): после реализации фичи; после исправления багов; после архитектурных решений.
- **Вручную** (по запросу пользователя): команда `/documenter update docs for [feature]`; фразы «update documentation», «document this change».

### How to Read Documentation — как читать доки

Документация может быть исключена из контекста по умолчанию (проверить `.cursorignore`). Чтобы подключить конкретные доки (заменив `{root}` на сконфигурированный путь):

```
@{root}/develop/features/authentication.md
@{root}/develop/api/endpoints.md
```

Чтобы увидеть всю документацию: `@{root}`.

### Commands Available — доступные команды

- `/documenter` — обновить документацию по недавним изменениям.
- `@{root}` — включить документацию в контекст (со своим сконфигурированным root-путём).

### Documentation Guidelines — 6 правил ведения документации

1. **Одна тема на файл** — не смешивать concerns.
2. **Всегда датировать обновления** — включать метки времени.
3. **Ссылаться на код** — указывать реальные файлы.
4. **Держать актуальным** — архивировать старые/завершённые элементы.
5. **Использовать markdown** — стандартное форматирование.
6. **Перекрёстные ссылки** — связывать связанные доки.

### File Naming — правила имён файлов

- Фичи: `feature-name.md` (kebab-case).
- Компоненты: `ComponentName.md` (PascalCase).
- Проблемы: `issue-123.md` или описательное имя.
- Задачи: `task-description.md`.

### Useful Prompts — полезные промпты (примеры запросов)

- «Document the authentication feature I just implemented»
- «Update API documentation with new endpoints»
- «Show me all pending tasks in documentation»
- «Archive completed issues in documentation»
- «Create ADR for switching to server components»

### Configuration Example — пример `.cursor/config.json`

Полный пример блока `documentation`: `paths` — `root: "ai_docs"`, `plans`, `reports`, `issues`, `architecture`, `features`, `api`, `components` (все под `ai_docs/develop/…`), `design: "ai_docs/design"`, `changelog: "ai_docs/changelog"`; `enabled` — все девять типов выставлены в `true`. Пометка: пользователи могут кастомизировать все пути под структуру своего проекта (например, `docs/`, `documentation/` и т.д.).

## Связи с другими файлами

- **Читается агентами**: `documenter` (основной писатель документации), `planner` (пишет в `plans/`), любым агентом, логирующим техдолг в `issues/` (по скиллу `task-management`).
- **Зависит от**: `.cursor/config.json` (блок `documentation.paths` / `documentation.enabled`) и `.cursorignore` (могут ли доки попадать в контекст).
- **Связанные команды**: `/documenter` — ручное обновление доков; упоминаемые в других воркфлоу `/orchestrate`, `/audit` — их documenter-шаги сохраняют результаты по путям, описанным здесь.
- **Связанные скиллы**: `task-management` (форматы служебных JSON и пути планов/отчётов — пересекается по теме «где что лежит»), `orchestration` (фаза финализации пишет отчёт по этим правилам), `audit-workflow` (путь отчёта аудита берётся из тех же настроек).
