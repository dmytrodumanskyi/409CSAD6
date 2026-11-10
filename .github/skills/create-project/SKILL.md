---
name: create-project
description: Command. Створює початковий TypeScript Hello World-проєкт через skill project-scaffold.
---

> Command-обгортка. Те саме, що `.github/prompts/create-project.prompt.md`, у форматі skill для режимів Copilot, які не читають prompt files.


# /create-project

Дій як агент [build-engineer](../../agents/build-engineer.agent.md).
Виконай skill [project-scaffold](../project-scaffold/SKILL.md).

## Параметри
- `language` = `${input:language:typescript}`
- `projectName` = `${input:projectName:hello}`

## Передумови
- Виконано `/git-init` (існує `.gitignore`). Якщо ні — `FAIL: create-project — спершу виконайте /git-init`.
- `language` = `typescript`.

## Дії
1. Для кожного файлу зі skill перевір, чи він існує і чи відповідає вимогам.
2. Створи відсутні: `src/hello.ts`, `src/math.ts`, `tests/.gitkeep`, `docs/`, `README.md`.
3. Існуючі файли не перезаписуй; при розбіжності покажи diff і запитай підтвердження.

## Очікувані файли
`src/hello.ts`, `src/math.ts`, `tests/.gitkeep`, `README.md`, `.gitignore`

## Перевірка
Усі 5 перевірок зі skill project-scaffold → `PASS`.

## Повідомлення про помилку
`FAIL: create-project — <номер перевірки>: <що не так>. Пропозиція: <виправлення>.`
