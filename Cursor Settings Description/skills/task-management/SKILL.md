> Оригинал: `.cursor/skills/task-management/SKILL.md`
>
> ⚠️ Это **описание для справки**, а не рабочий скилл. Файл ничего не запускает и ни на что не влияет. Рабочая версия лежит в `.cursor/skills/task-management/SKILL.md` — править поведение нужно только там.

# Скилл `task-management` — управление задачами и планами

## Назначение и тип

Скилл описывает **систему отслеживания задач, планов, отчётов и известных проблем** по гибридному принципу «workspace + документация»: временное состояние оркестраций живёт в `.cursor/workspace/`, а постоянный контент (планы, отчёты, issues) — в настраиваемых путях документации. Это фундамент, на котором работает воркфлоу `/orchestrate`.

**Тип: гайдлайн** (справочник форматов и процедур, который читают агенты). Скилл не исполняется как самостоятельный сценарий.

## Разбор frontmatter

| Поле | Значение | Что означает |
|------|----------|--------------|
| `name` | `task-management` | Имя скилла, совпадает с папкой. |
| `description` | `Task tracking and plan management. Used by planner to create plans and persist tasks, by orchestrator to read tasks and update progress, by documenter to create completion reports, and by any agent to log non-critical issues.` | Кто использует: planner — создание планов и сохранение задач; orchestrator — чтение задач и обновление прогресса; documenter — отчёты о завершении; любой агент — логирование некритичных проблем. |

## Когда и кем читается

- **planner** — при создании плана и инициализации оркестрации.
- **orchestrator** (координатор скилла `orchestration`) — при чтении задач и обновлении прогресса в цикле задач.
- **documenter** — при создании финального отчёта.
- **Любой агент** — при регистрации некритичной проблемы (issue).

## Architecture — двухуровневая система

**1. Workspace (временный) — `.cursor/workspace/`**: метаданные и состояние оркестраций, статусы задач, прогресс; авто-очистка после завершения.
**2. Documentation (постоянный) — настраиваемые пути**: планы, отчёты, архитектурные решения, финальная документация фич.

## Configuration — конфигурация

**Читается из:** `.cursor/config.json` (пример из оригинала):

```json
{
  "workspace": {
    "path": ".cursor/workspace",
    "cleanup": { "autoCleanCompleted": true, "cleanupAfterDays": 7 }
  },
  "documentation": {
    "paths": {
      "root": "docs",
      "reports": "docs/reports",
      "issues": "docs/issues",
      "architecture": "docs/architecture",
      "plans": "docs/plans"
    }
  }
}
```

Все пути настраиваемы (`docs/`, `ai_docs/`, `documentation/`…). **Дефолты, если конфига нет:** workspace — `.cursor/workspace`; root — `ai_docs`; reports/issues/architecture/plans — `ai_docs/develop/{reports|issues|architecture|plans}`.

## Directory Structure — структура директорий

**Workspace (временный):**

```
.cursor/workspace/
├── active/                          # Запущенные оркестрации
│   └── orch-2026-02-10-15-30-auth/
│       ├── progress.json            # Статус, метки времени, счётчики
│       ├── tasks.json               # Статусы задач
│       └── links.json               # Ссылки на файлы документации
├── completed/                       # Авто-очистка через N дней
└── failed/                          # Можно возобновить
```

**Documentation (постоянный):**

```
{configured-path}/                   # Из config.json
├── plans/                           # Высокоуровневые планы
│   └── 2026-02-10-auth-system.md
├── reports/                         # Отчёты о завершении
│   └── 2026-02-10-auth-implementation.md
└── issues/                          # Известные проблемы
    └── ISS-001-token-race.md
```

## Форматы JSON-файлов состояния (workspace)

### progress.json

```json
{
  "id": "orch-2026-02-10-15-30-auth",
  "name": "Authentication System",
  "status": "in-progress",
  "started": "2026-02-10T15:30:00Z",
  "lastUpdated": "2026-02-10T15:45:00Z",
  "tasksTotal": 5,
  "tasksCompleted": 2,
  "currentTask": "AUTH-003"
}
```

### tasks.json

```json
{
  "AUTH-001": {
    "id": "AUTH-001",
    "name": "User Model",
    "status": "completed",
    "startedAt": "2026-02-10T15:30:00Z",
    "completedAt": "2026-02-10T15:40:00Z",
    "filesChanged": ["src/models/User.ts"],
    "testsRun": 5,
    "testsPassed": 5
  },
  "AUTH-002": { "id": "AUTH-002", "status": "in-progress", "startedAt": "2026-02-10T15:40:00Z" }
}
```

### links.json

```json
{
  "plan": "{configured-path}/plans/2026-02-10-auth-system.md",
  "report": null
}
```

Путь берётся из `.cursor/config.json` → `documentation.paths.plans`.

## Форматы файлов документации (постоянные)

**plans/ — высокоуровневые планы.** Создаёт Planner; лежит в workspace (временно) или это файл пользователя. Формат: заголовок `# Plan: ...`; блок с датой, ID оркестрации, статусом (🔄 In Progress); секции `## Goal`, `## Tasks` (чекбоксы вида `- [ ] AUTH-001: User Model (⏳ Pending)`), `## Dependencies` («AUTH-002 requires AUTH-001»), `## Architecture Decisions` («Using JWT with refresh tokens», «Password hashing with bcrypt»).

**reports/ — отчёты о завершении.** Создаёт Documenter; путь `{config.documentation.paths.reports}/`. Формат: заголовок `# Report: ...`; блок с датой/оркестрацией/статусом ✅ Completed; секции `## Summary`, `## What Was Built`, `## Completed Tasks` (пронумерованный список с ✅ и длительностью: «1. ✅ AUTH-001: User Model (25 min)»), `## Metrics` (файлов создано, строк кода, тестов, ошибок линтера), `## Known Issues` (ссылки на ISS-xxx с приоритетом).

**issues/ — известные проблемы.** Создаёт любой агент; путь `{config.documentation.paths.issues}/`. Формат: заголовок `# Issue: ...`; блок с ID (ISS-001), датой, Severity (Low), Status (Open); секции `## Description`, `## Impact`, `## Why Not Fixed Now` (например: низкий приоритет, нужен Redis, текущей реализации хватает для MVP), `## Proposed Solution`, `## Related` (ссылки на оркестрацию и задачу).

## Helper: Read Configuration (всегда читать конфиг первым)

```javascript
config = readJSON(".cursor/config.json")
if (!config) { /* дефолты: workspace ".cursor/workspace",
     plans/reports/issues/architecture/features/api/components → "ai_docs/develop/...",
     design → "ai_docs/design", changelog → "ai_docs/changelog" */ }

workspacePath = config.workspace.path
docsReports = config.documentation.paths.reports        // null = отключено
docsIssues = config.documentation.paths.issues          // null = отключено
docsArchitecture = config.documentation.paths.architecture  // null = отключено
```

**Проверка перед записью:** отчёт создаётся только если `docsReports !== null`, иначе содержимое показывается только в чате; issue создаётся только если `docsIssues !== null`, иначе выводится предупреждение в чат (`⚠️ Issue found: ...`).

## Planner Workflow — процедура планировщика

**Step 0: Detect Input Type** — определить, дал ли пользователь файл задач (`@TODO.md`, `@roadmap.md`): есть файл → `mode = "file"`, `planFile = taskFile`; нет → `mode = "temporary"`, `planFile = null`.

**Step 1: Initialize Orchestration** — сгенерировать ID `orch-{YYYY-MM-DD-HH-mm}-{slug}`; создать директорию `{workspace.path}/active/{orchestrationId}`; записать `progress.json` со статусом `"planning"`, нулевыми счётчиками, полями `mode` и `sourceFile`.

**Step 2: Create or Use Plan:**
- **Mode A (temporary):** сгенерировать контент плана; `links.json` = `{ plan: null, report: null, temporary: true }`; план сохранить в `{workspaceDir}/plan.md`; `tasks.json` = `{}`.
- **Mode B (file):** прочитать файл пользователя, распарсить задачи; `links.json` = `{ plan: taskFile, report: null, temporary: false }`; `tasks.json` = задачи из файла.
- **Общее:** `progress.json` → `{ status: "ready", tasksTotal: taskCount }`.

**Step 3: Return to User** (формат ответа):

```markdown
✅ Plan created: {planFile}
🎯 Tasks: {taskCount} tasks ({taskIds})
📂 Orchestration: {orchestrationId}

Ready to start with /orchestrate execute {orchestrationId}
```

## Orchestrator Workflow — процедура оркестратора

**Step 1: Load Orchestration** — взять ID из ввода пользователя или `findLatestActive()`; прочитать `progress.json`, `links.json`, `tasks.json`; прочитать план из `links.plan` и извлечь `taskIds`.

**Step 2: Execute Tasks Loop** — для каждого `taskId`: пропустить завершённые; выставить `in-progress` (`startedAt`) в `tasks.json`; пометить задачу «🔄 In Progress» — в Mode B в файле пользователя, в Mode A в `workspace/plan.md`; вызвать worker → test-writer (по `filesChanged`) → test-runner → review; выставить `completed` с `completedAt`, `filesChanged`, `testsRun`, `testsPassed`; пометить «✅ Completed»; инкрементировать `tasksCompleted` и `lastUpdated` в `progress.json`.

**Step 3: Finalize** — `progress.json` → `"documenting"`; вызвать documenter; сохранить `report` в `links.json`; `progress.json` → `{ status: "completed", completedAt, reportFile }`; переместить папку из `active/` в `completed/`.

## Documenter Workflow — процедура документера

Прочитать метаданные из `workspace/completed/{id}/` (`progress.json`, `links.json`, `tasks.json`) и план из `links.plan`; сгенерировать отчёт (id, имя, даты, задачи, файл плана); записать в `{docsReports}/{YYYY-MM-DD}-{slug}-implementation.md`; обновить `links.json` ссылкой `report`.

## Any Agent: Creating Issues — создание issues

**Создавать, когда:** ✅ некритичная проблема; ✅ идея улучшения; ✅ техдолг; ✅ не хочется блокировать текущую работу.

**НЕ создавать, когда:** ❌ критический баг (чинить немедленно через debugger); ❌ блокирует текущую задачу; ❌ простое исправление (< 5 минут).

**Процедура:** прочитать конфиг; взять `issuesPath` (дефолт `ai_docs/develop/issues`); найти последний ID (`ISS-003`) → инкрементировать (`ISS-004`); создать `{issuesPath}/ISS-{nextIssueId}-{slug}.md`; опционально добавить ссылку на текущую оркестрацию и задачу.

## Naming Conventions — соглашения об именовании

- **Orchestration IDs**: `orch-YYYY-MM-DD-HH-mm-{slug}` (например, `orch-2026-02-10-15-30-auth`).
- **Plans**: `YYYY-MM-DD-feature-name.md`, в `workspace/active/orch-{id}/plan.md` или файл пользователя.
- **Task IDs**: `PREFIX-NNN`; префиксы: `AUTH` — аутентификация, `PAY` — платежи, `API` — API, `UI` — UI-компоненты, `DB` — база данных, `REF` — рефакторинг.
- **Reports**: `YYYY-MM-DD-feature-implementation.md` в `{config.documentation.paths.reports}/`.
- **Issues**: `ISS-NNN-description.md` в `{config.documentation.paths.issues}/`.

## System Relationships — связи сущностей

```
Orchestration (1) → Plan (1) → Tasks (N) → Report (1)

Workspace (temporary):
  .cursor/workspace/active/orch-2026-02-10-15-30-auth/
    ├── progress.json        [метаданные]
    ├── tasks.json           [статусы]
    └── links.json           [ссылки]
          ↓
Documentation (permanent):
  docs/plans/2026-02-10-auth-system.md      [контент плана]
  docs/reports/2026-02-10-auth-report.md    [финальный отчёт]
  docs/issues/ISS-001-token-race.md         [известные проблемы]
```

## Example: Complete Cycle — полный цикл (пример из оригинала)

1. **Planning**: `/orchestrate Build auth system` → planner создаёт workspace, план, инициализирует три JSON-файла, отвечает «Ready to execute with 5 tasks».
2. **Implementation**: оркестратор обрабатывает AUTH-001 (статусы 🔄 → ✅, вызов worker); при AUTH-002 ревью находит минорную проблему → создаётся `docs/issues/ISS-001-token-refresh-race.md`, работа продолжается (не блокируется).
3. **Documentation**: documenter создаёт отчёт в `docs/reports/`, архивирует workspace (`active/` → `completed/`), авто-очистка через 7 дней (настраивается).
4. **Issue Resolution (позже)**: `/orchestrate Fix known issues` → planner читает открытые `ISS-*.md`, создаёт новую оркестрацию и план исправлений.

## Benefits — преимущества (5 пунктов)

- ✅ **No Duplication**: workspace = только метаданные, документация = контент.
- ✅ **Parallel Orchestrations**: несколько оркестраций в `active/` изолированы.
- ✅ **Crash Recovery**: состояние в workspace → можно возобновить; записанная документация не теряется.
- ✅ **Configurable Paths**: пути можно направить в `specs/` (GitHub Spec Kit), `docs/adr/` (ADR), `.github/issues/`.
- ✅ **Clean Separation**: временное — состояние задач, постоянное — документация фич.

## Status Indicators — индикаторы статусов

**Оркестрация:** 🔵 planning — создание плана; 🟢 ready — готов к исполнению; 🟡 in-progress — задачи выполняются; 🟠 documenting — создание отчёта; ✅ completed — всё готово; ❌ failed — прервано/упало.
**Задача:** ⏳ pending — не начата; 🔄 in-progress — в работе; ✅ completed — готова и проверена; 🚫 blocked — ждёт зависимость.
**Критичность issue:** 🔴 Critical (P1) — немедленно; 🟠 High (P2) — на этой неделе; 🟡 Medium (P3) — в этом месяце; 🟢 Low (P4) — когда возможно; 🔵 Enhancement (P5) — nice to have.

**Итоговая формула оригинала:** двухуровневая система — временный workspace для отслеживания состояния, постоянная документация для спецификаций фич и отчётов.

## Связи с другими файлами

- **Читают агенты**: `planner` (создание планов и задач), координатор-оркестратор (скилл `orchestration`), `documenter` (финальные отчёты), любой агент (создание issue).
- **Читает конфигурацию**: `.cursor/config.json` (блоки `workspace` и `documentation.paths`); при отсутствии — дефолты на `ai_docs/`.
- **Пишет состояние**: `.cursor/workspace/active|completed|failed/orch-{id}/` — `progress.json`, `tasks.json`, `links.json`, `plan.md` (Mode A).
- **Используется воркфлоу**: `orchestration` (весь цикл статусов задач построен на этих форматах); `audit-workflow` (логирование issues).
- **Структура постоянной документации**: скилл `docs` (правила размещения файлов в `ai_docs/`).
- **Смежные гайдлайны**: `code-quality-standards`, `security-guidelines`, `architecture-principles` (читаются исполнительными агентами, а не этим скиллом).
