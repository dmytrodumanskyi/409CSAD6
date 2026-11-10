---
mode: agent
description: Створює GitHub Actions workflow .github/workflows/ci.yml з матрицею Windows/Linux/macOS через skill github-actions.
---

# /create-actions

Дій як агент [build-engineer](../agents/build-engineer.agent.md).
Виконай skill [github-actions](../skills/github-actions/SKILL.md).

## Передумови
- Існують `ci.sh` і `ci.bat`. Якщо ні — `FAIL: create-actions — спершу виконайте /create-build`.

## Дії
1. Перевір, чи існує `.github/workflows/ci.yml`.
   - Існує і проходить усі перевірки skill → `SKIP`.
   - Існує, але неповний → доповни лише відсутнє (ОС у matrix, тригери), покажи diff.
   - Не існує → створи за шаблоном skill.
2. Виконай перевірки 1–5 зі skill.

## Очікувані файли
`.github/workflows/ci.yml`

## Перевірка
- matrix: `ubuntu-latest`, `windows-latest`, `macos-15-intel`;
- тригери: `push` і `pull_request` для `develop` і `master`;
- кроки збірки лише `./ci.sh` / `ci.bat`;
- немає `secrets.*`, токенів і паролів.

## Повідомлення про помилку
`FAIL: create-actions — <перевірка>: <що не так>.`
