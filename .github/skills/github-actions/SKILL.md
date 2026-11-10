---
name: github-actions
description: Створює .github/workflows/ci.yml з однією job та matrix ubuntu-latest / windows-latest / macos-15-intel, яка викликає лише ci.sh або ci.bat і зберігає зібраний dist/ як artifact. Застосовувати після build-and-test.
---

# Skill: github-actions

## Коли застосовувати
- Існують `ci.sh` і `ci.bat`, але немає `.github/workflows/ci.yml`.
- Користувач викликав `/create-actions` або `/init`.

## Вхідні дані
| Параметр | За замовчуванням |
|---|---|
| `branches` | `develop`, `master`, `main` |
| `os` | `ubuntu-latest`, `windows-latest`, `macos-15-intel` |
| `nodeVersion` | `20` |
| Файли з попереднього кроку | `ci.sh`, `ci.bat`, `package.json` |

**Передумова:** `ci.sh` і `ci.bat` існують. Якщо ні → `FAIL: github-actions — спершу виконайте /create-build`.

## Правило
Workflow **не містить** команд складання/тестування напряму (`npm run build`, `npm test`).
Він лише готує середовище (checkout, Node.js) і запускає `ci.sh` / `ci.bat`.
Встановлення Node.js через `actions/setup-node` — це підготовка середовища, а не складання.

## Результат: `.github/workflows/ci.yml`
```yaml
name: CI

on:
  push:
    branches: [develop, master, main, "feature/**"]
  pull_request:
    branches: [develop, master, main]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  build-and-test:
    name: ${{ matrix.os }}
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-15-intel]

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Build and test (Linux/macOS)
        if: runner.os != 'Windows'
        shell: bash
        run: |
          chmod +x ./ci.sh
          ./ci.sh

      - name: Build and test (Windows)
        if: runner.os == 'Windows'
        shell: cmd
        run: call ci.bat

      - name: Upload executable
        if: success()
        uses: actions/upload-artifact@v4
        with:
          name: hello-${{ matrix.os }}
          path: dist/
          if-no-files-found: error
```

## Чому macos-15-intel, а не macos-latest
Під час першого запуску job `macos-latest` (arm64) двічі скасовано GitHub з повідомленням
«The job was not acquired by Runner of type hosted even after multiple attempts» через брак
потужностей macOS arm64 runners. Intel-runner `macos-15-intel` має коротшу чергу; вимога
методички (Windows, Linux, macOS) при цьому виконується.

## Ідемпотентність
- `ci.yml` існує і містить усі три ОС та виклики `ci.sh`/`ci.bat` → `SKIP`.
- Не створювати другий workflow-файл з тією ж метою.

## Перевірки
| # | Перевірка | Команда | Очікування |
|---|---|---|---|
| 1 | YAML валідний | `node -e "…"` або `npx --yes yaml-lint .github/workflows/ci.yml`; якщо інструментів немає — візуальна перевірка відступів | без помилок |
| 2 | Усі три ОС | `grep -E "ubuntu-latest\|windows-latest\|macos-15-intel"` | 3 збіги в matrix |
| 3 | Тригери | містить `push`, `pull_request`, `develop`, `master` | так |
| 4 | Немає прямого складання | `grep -E "npm (run build\|test\|ci)" ci.yml` | порожньо |
| 5 | Немає секретів | `grep -i "secrets\.\|token\|password" ci.yml` | порожньо |

## Приклад
**Вхід:** `branches=[develop, master]`, існують `ci.sh`, `ci.bat`.
**Очікуваний вивід:**
```
PASS create .github/workflows/ci.yml
PASS matrix: ubuntu-latest, windows-latest, macos-15-intel
PASS no direct build commands, no secrets
github-actions: PASS (5/5 checks)
```
Після push у GitHub → вкладка **Actions** → 3 зелені jobs і 3 artifacts `hello-<os>`.

## Типова помилка
**Сценарій:** job на ubuntu/macos падає з `./ci.sh: Permission denied`.
**Причина:** файл закомічено без біта виконання.
**Виправлення:** `chmod +x ./ci.sh` у workflow (вже є) і локально `git update-index --chmod=+x ci.sh`.

**Сценарій:** job на Windows падає з `'#!' is not recognized`.
**Причина:** на Windows запущено `ci.sh` замість `ci.bat`. **Виправлення:** перевірити умови `if: runner.os`.
