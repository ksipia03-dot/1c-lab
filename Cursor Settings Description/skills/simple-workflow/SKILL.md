> Оригинал: `.cursor/skills/simple-workflow/SKILL.md`
>
> ⚠️ Это **описание для справки**, а не рабочий скилл. Файл ничего не запускает и ни на что не влияет. Рабочая версия лежит в `.cursor/skills/simple-workflow/SKILL.md` — править поведение нужно только там.

# Скилл `simple-workflow` — простой цикл реализации

## Назначение и тип

Скилл оркестрирует **простой линейный цикл реализации** без планирования и ревью: worker (код) → test-writer (тесты) → test-runner (линтер + тесты) → documenter (документация). Это «лёгкая» альтернатива полному циклу `/orchestrate` для небольших одношаговых задач.

**Тип: воркфлоу** (сценарий, который исполняет команда). Координатор (основной ассистент) вызывает субагентов последовательно через Task tool, дожидаясь каждого.

## Разбор frontmatter

| Поле | Значение | Что означает |
|------|----------|--------------|
| `name` | `simple-workflow` | Имя скилла, совпадает с папкой. |
| `description` | `Simple implementation workflow - code, test, document. Use when user invokes /implement, wants to create code with automatic testing and documentation, or for simple single-purpose tasks that don't need planning.` | Триггеры: команда `/implement`; желание получить код с автоматическими тестами и документацией; простые одноцелевые задачи без планирования. |

## Когда и кем вызывается

- **Командой `/implement [task]`** (`.cursor/commands/`).
- **Триггерные фразы** (раздел Trigger Phrases оригинала): `/implement [task]`; «Implement [X]»; «Create [Y] with tests and docs».
- **Подходящие задачи**: создать утилитную функцию; добавить React-компонент; реализовать API-эндпоинт; добавить фичу в существующий файл.
- **Неподходящие** (для них `/orchestrate`): целая система аутентификации; рефакторинг нескольких модулей; миграция схемы БД; сложная фича из нескольких частей.
- **Кем исполняется**: основной ассистент-координатор; всё происходит в одном чате и видно пользователю.

## Архитектура воркфлоу (mermaid-диаграмма из оригинала)

```mermaid
flowchart LR
    Worker[Worker: writes code] --> TestWriter[Test-Writer: writes tests]
    TestWriter --> Hook[Hook: auto-fix formatting]
    Hook -.background.-> Test[Test-Runner: linter + tests]
    Test --> Docs[Documenter: creates documentation]
```

**5 шагов из оригинала:**
1. **Worker** создаёт код реализации.
2. **Test-Writer** пишет исчерпывающие тесты на этот код (сам определяет стек).
3. **Hook** (автоматически, в фоне) исправляет форматирование (prettier, eslint --fix). *Примечание: в оригинале хук упоминается, но в текущем hooks.json он не настроен — см. ../../hooks.json.md*
4. **Test-Runner** запускает проверки линтера и тесты, чтобы убедиться, что всё работает.
5. **Documenter** создаёт документацию в настроенном пути документации.

Все шаги агентов видны в том же чате. Хук работает в фоне (пунктирная связь на диаграмме).

## Example Usage — пример использования

Запрос: `/implement Create a Button component with onClick handler`. Структура ответа координатора из оригинала:

```markdown
I'll implement this in four steps: code, tests, verify, and document.

### Step 1: Implementation
[Call Task with subagent_type="worker"]

### Step 2: Test Creation
[After worker finishes, call Task with subagent_type="test-writer"]

### Step 3: Testing
[After tests are written, call Task with subagent_type="test-runner"]

### Step 4: Documentation
[After tests pass, call Task with subagent_type="documenter"]

### Summary
All steps completed!
- Worker created: [list files]
- Tests written: [list test files]
- Tests: [status]
- Documentation: [list docs]
```

## Important Rules — важные правила (4 пункта)

1. **Sequential execution**: дожидаться завершения каждого агента перед вызовом следующего.
2. **Always run all four steps**: worker → test-writer → test-runner → documenter (все четыре шага обязательны).
3. **Same chat**: всё происходит в текущем разговоре, видимо пользователю.
4. **Pass context forward**: каждому агенту передавать, что сделал предыдущий.

## Code Pattern — паттерн исполнения (псевдокод из оригинала)

```
Step 1: Call worker with task description
  → Wait for result
  → Extract files created

Step 2: Call test-writer
  → "Write tests for: [list from step 1]"
  → Wait for result
  → Extract test files created

Step 3: Call test-runner
  → "Run tests for files: [list from steps 1-2]"
  → Wait for result
  → Check if tests passed

Step 4: Call documenter
  → "Document the implementation: [details from step 1]"
  → Wait for result
  → Compile final summary
```

## When NOT to Use — когда НЕ использовать

- **Complex tasks**: использовать `/orchestrate` (там есть планирование).
- **Multiple subtasks**: использовать `/orchestrate` для разбивки на задачи.
- **Need review/refactor**: использовать полный цикл воркфлоу.

## Key Difference from Full Cycle — отличие от полного цикла

| Simple Workflow | Full Cycle (/orchestrate) |
|-----------------|---------------------------|
| Без планирования | Начинается с planner |
| Один проход | Много задач из плана |
| Без ревью | Включает код-ревью |
| Без циклов debugger | Авто-исправления через debugger |
| Быстро и просто | Полно и тщательно |

## Benefits — преимущества (6 пунктов)

- ✅ Быстро для простых задач.
- ✅ Всегда пишутся тесты (test-writer).
- ✅ Всегда проверяется прохождение тестов (test-runner).
- ✅ Всегда создаётся документация.
- ✅ Всё видно в одном чате.
- ✅ Нет накладных расходов на планирование.

## Example Tasks — примеры задач

**Хорошо для `/implement`:**
- Создать утилитную функцию.
- Добавить React-компонент.
- Реализовать API-эндпоинт.
- Добавить новую фичу в существующий файл.

**Не подходит для `/implement` (лучше `/orchestrate`):**
- Построить целую систему аутентификации.
- Отрефакторить несколько модулей.
- Мигрировать схему базы данных.
- Реализовать сложную фичу из нескольких частей.

## Связи с другими файлами

- **Запускается командой**: `/implement` (`.cursor/commands/`).
- **Вызывает агентов** (строго последовательно): `worker` → `test-writer` → `test-runner` → `documenter`.
- **Гайдлайны, которые читают вызванные агенты**: worker — `code-quality-standards` (+ условно `security-guidelines`, `architecture-principles`).
- **Документация**: documenter пишет в пути из `.cursor/config.json` (структура — в скилле `docs`).
- **Альтернатива**: скилл `orchestration` (команда `/orchestrate`) — полный цикл с планированием, ревью и циклами авто-исправления; сравнительная таблица приведена выше.
- **Хуки**: шаг 3 упоминает фоновый хук авто-форматирования (prettier, eslint --fix). *Примечание: в оригинале хук упоминается, но в текущем hooks.json он не настроен — см. ../../hooks.json.md*
