---
mode: agent
description: Оркестратор. Послідовно запускає git-init, create-project, create-build, create-actions і check, зупиняючись на першій помилці.
---

# /init — orchestrator

Дій як агент [build-engineer](../agents/build-engineer.agent.md).

## Передумови (крок 0)
Виконай і перевір:
```
git --version
node --version   # >= 20
npm --version
```
Якщо щось відсутнє → `FAIL: init/preconditions — <що саме>` і зупинка.

## Послідовність
Виконуй команди **строго по черзі**. Кожна наступна стартує лише якщо попередня
завершилась зі статусом `PASS` або `SKIP`.

| Крок | Command | Вхід від попереднього кроку | Результат для наступного |
|---|---|---|---|
| 1 | [/git-init](git-init.prompt.md) | — | репозиторій, `.gitignore` |
| 2 | [/create-project](create-project.prompt.md) | `.gitignore` | `src/hello.ts`, `src/math.ts`, `README.md` |
| 3 | [/create-build](create-build.prompt.md) | `src/*.ts` | `package.json`, тести, `ci.sh`, `ci.bat`, `dist/hello.js` |
| 4 | [/create-actions](create-actions.prompt.md) | `ci.sh`, `ci.bat` | `.github/workflows/ci.yml` |
| 5 | [/check](check.prompt.md) | усі файли | звіт PASS/FAIL |

Після кроку 5 доповни `docs/usage.md` фактичними командами, які були виконані (якщо їх ще немає).

## Обробка помилок
- При `FAIL` на кроці N: **зупинитись**, не виконувати кроки N+1…5.
- Вивести останні 20 рядків помилки, причину і пропозицію виправлення.
- Не «виправляти» помилку видаленням тесту, послабленням перевірки чи пропуском кроку.
- Після виправлення користувач повторно запускає `/init`; завдяки ідемпотентності
  вже виконані кроки отримають `SKIP`.

## Підсумковий звіт
```
| Крок | Command         | Статус | Примітка |
|------|-----------------|--------|----------|
| 0    | preconditions   | PASS   | node v20.x |
| 1    | git-init        | PASS   |          |
| 2    | create-project  | PASS   |          |
| 3    | create-build    | PASS   | 2 tests passed |
| 4    | create-actions  | PASS   |          |
| 5    | check           | PASS   | 21/21    |
INIT COMPLETED
```
або `INIT FAILED at step N (<command>)`.

## Заборонено
Робити `git commit` / `git push` автоматично. Наприкінці лише запропонуй команди
для комітів (окремо: агент, skills/commands, проєкт, CI) — користувач виконує їх сам.
