---
name: build-and-test
description: Налаштовує складання TypeScript через npm scripts і tsc, юніт-тести на Vitest (тест BasicAddition) та кросплатформні скрипти ci.sh / ci.bat. Застосовувати після project-scaffold.
---

# Skill: build-and-test

## Коли застосовувати
- Існує `src/math.ts` і `src/hello.ts`, але немає `package.json`, `tsconfig.json` або тестів.
- Користувач викликав `/create-build` або `/init`.

## Вхідні дані
| Параметр | За замовчуванням |
|---|---|
| `projectName` | `hello` |
| `nodeVersion` | `20` |
| `testName` | `BasicAddition` |
| Файли з попереднього кроку | `src/hello.ts`, `src/math.ts` |

**Передумова:** `src/math.ts` існує. Якщо ні → `FAIL: build-and-test — спершу виконайте /create-project`.

## Підкроки
1. **build-config** — `package.json`, `tsconfig.json`, `tsconfig.build.json`.
2. **test-config** — `vitest.config.ts`, `tests/math.test.ts`.
3. **ci-scripts** — `ci.sh`, `ci.bat`.

## Результат (файли)

### `package.json`
```json
{
  "name": "hello",
  "version": "1.0.0",
  "private": true,
  "description": "Cross-platform TypeScript Hello World (lab 1, variant 6)",
  "type": "module",
  "bin": { "hello": "dist/hello.js" },
  "engines": { "node": ">=20" },
  "scripts": {
    "clean": "node -e \"require('fs').rmSync('dist',{recursive:true,force:true})\"",
    "build": "tsc -p tsconfig.build.json",
    "start": "node dist/hello.js",
    "test": "vitest run",
    "typecheck": "tsc --noEmit -p tsconfig.json",
    "ci": "npm run clean && npm run build && npm test"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.6.0",
    "vitest": "^2.1.0"
  }
}
```
> Через `"type": "module"` скрипт `clean` використовує `node -e` з CommonJS — це працює, бо `-e` за замовчуванням CommonJS. Не використовувати `rm -rf` — не працює у Windows cmd.

### `tsconfig.json` (для IDE і typecheck, включає тести)
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist",
    "rootDir": "."
  },
  "include": ["src", "tests", "vitest.config.ts"]
}
```

### `tsconfig.build.json` (лише src → dist)
```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": { "rootDir": "src", "outDir": "dist" },
  "include": ["src"]
}
```

### `vitest.config.ts`
```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["tests/**/*.test.ts"],
    reporters: ["verbose"],
  },
});
```

### `tests/math.test.ts`
```ts
import { describe, it, expect } from "vitest";
import { add } from "../src/math.js";
import { greet } from "../src/hello.js";

describe("math", () => {
  it("BasicAddition", () => {
    expect(add(2, 3)).toBe(5);
    expect(add(-1, 1)).toBe(0);
  });
});

describe("hello", () => {
  it("Greeting", () => {
    expect(greet()).toBe("Hello, World!");
  });
});
```
> Імпорт з `.js` — вимога `NodeNext`; Vitest коректно резолвить його у `.ts`.

### `ci.sh` (Linux/macOS, `chmod +x`, LF)
```sh
#!/usr/bin/env bash
set -euo pipefail
echo "== Node: $(node --version), npm: $(npm --version)"
if [ -f package-lock.json ]; then npm ci; else npm install; fi
npm run build
npm test
test -f dist/hello.js || { echo "FAIL: dist/hello.js not found"; exit 1; }
OUT="$(node dist/hello.js)"
echo "$OUT"
[ "$OUT" = "Hello, World!" ] || { echo "FAIL: unexpected output"; exit 1; }
echo "== CI PASS"
```

### `ci.bat` (Windows, CRLF)
```bat
@echo off
setlocal
echo == Node & node --version
if exist package-lock.json (call npm ci) else (call npm install)
if errorlevel 1 exit /b 1
call npm run build
if errorlevel 1 exit /b 1
call npm test
if errorlevel 1 exit /b 1
if not exist dist\hello.js (echo FAIL: dist\hello.js not found & exit /b 1)
node dist\hello.js
if errorlevel 1 exit /b 1
echo == CI PASS
exit /b 0
```
> `call` перед `npm` обов'язковий: `npm` у Windows — це `.cmd`, без `call` скрипт завершиться після першої команди.

## Ідемпотентність
- `package.json` існує → додати лише відсутні `scripts`/`devDependencies`, не перезаписувати чужі.
- Тест `BasicAddition` вже є → `SKIP`, не додавати другий.

## Перевірки
| # | Перевірка | Команда | Очікування |
|---|---|---|---|
| 1 | Залежності встановлюються | `npm install` | exit 0, з'явився `package-lock.json` |
| 2 | Складання | `npm run build` | exit 0 |
| 3 | Виконуваний файл | `node dist/hello.js` | `Hello, World!` |
| 4 | Тести | `npm test` | `✓ BasicAddition`, exit 0 |
| 5 | Повний сценарій | `./ci.sh` або `ci.bat` | `== CI PASS` |

## Приклад
**Вхід:** `projectName=hello`, існують `src/hello.ts`, `src/math.ts`.
**Очікуваний вивід:**
```
 ✓ tests/math.test.ts > math > BasicAddition
 ✓ tests/math.test.ts > hello > Greeting
 Test Files  1 passed (1)
      Tests  2 passed (2)
build-and-test: PASS (5/5 checks)
```

## Типова помилка
**Сценарій:** `error TS2835: Relative import paths need explicit file extensions` під час `npm run build`.
**Причина:** імпорт `../src/math` без `.js` при `moduleResolution: NodeNext`.
**Виправлення:** змінити імпорт на `../src/math.js`, повторити перевірку 2.

**Сценарій:** `ci.bat` завершується після `npm ci` без запуску тестів.
**Причина:** відсутній `call`. **Виправлення:** додати `call` перед кожною командою `npm`.
