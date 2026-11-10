---
name: create-build
description: Command. Створює конфігурацію складання (npm scripts + tsc), тести Vitest і скрипти ci.sh / ci.bat через skill build-and-test.
---

> Command-обгортка. Те саме, що `.github/prompts/create-build.prompt.md`, у форматі skill для режимів Copilot, які не читають prompt files.


# /create-build

Дій як агент [build-engineer](../../agents/build-engineer.agent.md).
Виконай skill [build-and-test](../build-and-test/SKILL.md).

## Передумови
- Існують `src/hello.ts` і `src/math.ts`. Якщо ні — `FAIL: create-build — спершу виконайте /create-project`.
- `node --version` ≥ 20, `npm` доступний.

## Дії
1. **build-config:** створи/доповни `package.json`, `tsconfig.json`, `tsconfig.build.json`.
2. **test-config:** створи `vitest.config.ts` і `tests/math.test.ts` з тестом `BasicAddition`.
3. **ci-scripts:** створи `ci.sh` (LF, виконуваний) і `ci.bat` (CRLF).
4. Виконай `npm install` (створить `package-lock.json`).
5. Виконай перевірки 2–5 зі skill.

## Очікувані файли
`package.json`, `package-lock.json`, `tsconfig.json`, `tsconfig.build.json`, `vitest.config.ts`,
`tests/math.test.ts`, `ci.sh`, `ci.bat`, а після складання — `dist/hello.js` (не комітиться).

## Перевірка
```
npm run build
node dist/hello.js      # Hello, World!
npm test                # ✓ BasicAddition
```

## Повідомлення про помилку
`FAIL: create-build — <крок>: <вивід помилки (останні 20 рядків)>. Пропозиція: <виправлення>.`
Не переходити до наступного підкроку після помилки.
