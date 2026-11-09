---
name: project-scaffold
description: Створює мінімальний TypeScript Hello World-проєкт — структуру каталогів, src/hello.ts, src/math.ts, README.md і .gitignore. Застосовувати, коли в репозиторії ще немає вихідного коду або його треба привести до стандартної структури.
---

# Skill: project-scaffold

## Коли застосовувати
- Репозиторій порожній або в ньому немає `src/hello.ts`.
- Користувач викликав `/create-project` або `/init`.

## Вхідні дані
| Параметр | Обов'язковий | За замовчуванням | Приклад |
|---|---|---|---|
| `language` | так | `typescript` | `typescript` |
| `projectName` | ні | `hello` | `hello` |
| `author` | ні | з `git config user.name` | `Іваненко І.І.` |
| `group` / `variant` | ні | `<заповнити>` / `6` | `КН-31` / `6` |

Якщо `language` ≠ `typescript` — зупинитись з помилкою (див. «Типова помилка»).

## Результат (файли)
```
src/
  hello.ts      # точка входу, виводить "Hello, World!"
  math.ts       # export function add(a: number, b: number): number
tests/          # порожній каталог (+ .gitkeep), тести додає build-and-test
docs/
  architecture.md
  usage.md
README.md
.gitignore
```

### `src/math.ts`
```ts
export function add(a: number, b: number): number {
  return a + b;
}
```

### `src/hello.ts`
```ts
export function greet(name = "World"): string {
  return `Hello, ${name}!`;
}

console.log(greet());
```

### `.gitignore` (обов'язкові рядки, без дублікатів)
```
node_modules/
dist/
build/
coverage/
*.log
*.tsbuildinfo
.env
.env.*
.DS_Store
Thumbs.db
.vscode/*
!.vscode/extensions.json
```

### `README.md` — мінімальний зміст
ПІП, група, варіант 6, опис проєкту, вимоги (Node.js 20+), запуск агента (`/init`),
запуск проєкту (`npm ci && npm run build && npm start`), запуск тестів (`npm test`).

## Ідемпотентність
- Файл існує і містить потрібний вміст → `SKIP`.
- `.gitignore` існує → додати **лише відсутні** рядки.
- `README.md` існує → не перезаписувати розділи, додати лише відсутні.

## Перевірки
| # | Перевірка | Команда | Очікування |
|---|---|---|---|
| 1 | Вихідний файл існує | `test -f src/hello.ts` (PowerShell: `Test-Path src/hello.ts`) | true |
| 2 | Функція `add` експортується | `grep -q "export function add" src/math.ts` | знайдено |
| 3 | Команда запуску визначена | README містить `npm start` | знайдено |
| 4 | `.gitignore` містить `node_modules/` і `dist/` | `grep -x "dist/" .gitignore` | знайдено |
| 5 | Немає дублікатів у `.gitignore` | `sort .gitignore \| uniq -d` | порожньо |

## Приклад
**Вхід:** `language=typescript, projectName=hello, variant=6`
**Очікуваний вивід агента:**
```
PASS create src/math.ts
PASS create src/hello.ts
PASS create .gitignore (12 rules)
PASS create README.md
project-scaffold: PASS (5/5 checks)
```

## Типова помилка
**Сценарій:** користувач передав `language=python`.
**Реакція:** `FAIL: project-scaffold — мова "python" не підтримується агентом варіанту 6 (лише typescript)`. Жодних файлів не створювати.

**Сценарій:** `src/hello.ts` існує, але не містить `Hello`.
**Реакція:** показати diff, запитати підтвердження перед заміною.
