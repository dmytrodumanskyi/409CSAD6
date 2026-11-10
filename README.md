# Лабораторна робота №1 — AI-агент для автоматизації розробки та CI/CD

| | |
|---|---|
| Студент | Думанський Дмитро Іванович |
| Група | КІ-409 |
| Варіант | **6** — TypeScript, npm scripts, Vitest |

## Опис
Репозиторій містить AI-агента **build-engineer** для GitHub Copilot, який генерує,
складає, тестує і перевіряє кросплатформний TypeScript Hello World та налаштовує
GitHub Actions для Windows, Linux і macOS.

- Гілка `develop` — лише агент та інструкції.
- Гілка `feature/lab1-ts` — результат запуску `/init`: код, тести, `ci.yml`, документація.

## Структура агента
```
.github/
├── agents/build-engineer.agent.md     # manifest
├── skills/
│   ├── project-scaffold/SKILL.md
│   ├── build-and-test/SKILL.md
│   ├── github-actions/SKILL.md
│   └── git-init, create-project, create-build,
│       create-actions, check, lab-init/SKILL.md   # commands як skills
└── prompts/                            # commands
    ├── git-init.prompt.md
    ├── create-project.prompt.md
    ├── create-build.prompt.md
    ├── create-actions.prompt.md
    ├── check.prompt.md
    └── init.prompt.md                  # orchestrator
docs/
├── architecture.md
├── usage.md
└── ai-log.md
```

## Швидкий старт
1. VS Code → Copilot Chat → режим **Agent** → агент **build-engineer**.
2. Ввести `/lab-init` (або `/init` у класичному Copilot Chat).
3. Перевірити: `./ci.sh` (Linux/macOS) або `ci.bat` (Windows).

Детально — у [docs/usage.md](docs/usage.md), архітектура — у [docs/architecture.md](docs/architecture.md),
журнал роботи з AI — у [docs/ai-log.md](docs/ai-log.md).

## Запуск зібраного проєкту
```bash
npm ci
npm run build
npm start      # Hello, World!
npm test
```
