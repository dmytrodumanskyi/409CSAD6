---
mode: agent
description: Перевіряє структуру агента і проєкту, складання, тести та workflow. Нічого не змінює.
---

# /check

Дій як агент [build-engineer](../agents/build-engineer.agent.md).

**Ця команда тільки читає і запускає перевірки. Заборонено створювати, змінювати або видаляти
будь-які файли, крім генерованих `dist/` і `node_modules/` під час складання.**
Якщо знайдено проблему — опиши її і запропонуй команду для виправлення, але не виправляй.

## Перевірки

### A. Агент
| # | Перевірка |
|---|---|
| A1 | `.github/agents/build-engineer.agent.md` існує і містить розділи «Роль», «Заборонені дії», «Критерії успішного завершення» |
| A2 | Існують 3 skills: `project-scaffold`, `build-and-test`, `github-actions`; кожен має розділи «Вхідні дані», «Результат», «Перевірки», «Типова помилка» |
| A3 | Існують 6 commands у `.github/prompts/`: `git-init`, `create-project`, `create-build`, `create-actions`, `check`, `init` |
| A4 | `init.prompt.md` викликає команди в порядку git-init → create-project → create-build → create-actions → check |

### B. Проєкт
| # | Перевірка |
|---|---|
| B1 | Існують `src/hello.ts`, `src/math.ts`, `tests/math.test.ts`, `package.json`, `tsconfig.json`, `ci.sh`, `ci.bat` |
| B2 | `package.json` містить скрипти `build`, `start`, `test` |
| B3 | `README.md`, `docs/architecture.md`, `docs/usage.md` існують |

### C. Складання і тести (запустити)
| # | Команда | Очікування |
|---|---|---|
| C1 | `npm ci` (або `npm install`, якщо немає lock-файлу) | exit 0 |
| C2 | `npm run build` | exit 0, існує `dist/hello.js` |
| C3 | `node dist/hello.js` | `Hello, World!` |
| C4 | `npm test` | exit 0, `BasicAddition` passed |
| C5 | `./ci.sh` (Linux/macOS) або `ci.bat` (Windows) | `== CI PASS` |

### D. CI
| # | Перевірка |
|---|---|
| D1 | `.github/workflows/ci.yml` існує, YAML без синтаксичних помилок |
| D2 | matrix містить `ubuntu-latest`, `windows-latest`, `macos-latest` |
| D3 | тригери `push` і `pull_request` на `develop`/`master` |
| D4 | у workflow немає `npm run build` / `npm test` напряму — лише `ci.sh`/`ci.bat` |

### E. Git і безпека
| # | Команда | Очікування |
|---|---|---|
| E1 | `git ls-files node_modules dist build coverage` | порожньо |
| E2 | `git ls-files \| grep -iE "\.env$\|\.pem$\|id_rsa"` | порожньо |
| E3 | `git grep -nIiE "(api[_-]?key\|token\|password)\s*[:=]\s*['\"][^'\"]+"` | порожньо |

## Формат звіту
```
| ID | Перевірка | Статус | Деталі |
|----|-----------|--------|--------|
| A1 | manifest  | PASS   |        |
...
Підсумок: N PASS, M FAIL
```
Якщо є хоча б один `FAIL` — завершити повідомленням `CHECK FAILED` і списком виправлень.
Якщо всі `PASS` — `CHECK PASSED`.
