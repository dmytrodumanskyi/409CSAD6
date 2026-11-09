---
mode: agent
description: Перевіряє Git-репозиторій, створює або доповнює .gitignore і показує стан Git.
---

# /git-init

Дій як агент [build-engineer](../agents/build-engineer.agent.md).

## Передумови
- Встановлено `git` (`git --version` завершується з кодом 0).

## Дії
1. Виконай `git rev-parse --is-inside-work-tree`.
   - Якщо репозиторію немає → виконай `git init -b develop` і повідом про це.
   - Якщо є → нічого не ініціалізуй повторно.
2. Виведи поточну гілку: `git branch --show-current`.
3. Створи або доповни `.gitignore` правилами зі skill
   [project-scaffold](../skills/project-scaffold/SKILL.md#gitignore-обовязкові-рядки-без-дублікатів).
   Додавай **лише відсутні** рядки.
4. Перевір, що генеровані каталоги не відстежуються:
   `git ls-files node_modules dist build coverage` → має бути порожньо.
5. Виведи `git status --short`.

## Очікувані файли
- `.gitignore`

## Перевірка
| Перевірка | Очікування |
|---|---|
| `git rev-parse --is-inside-work-tree` | `true` |
| `.gitignore` містить `node_modules/`, `dist/`, `coverage/`, `.env` | так |
| `sort .gitignore \| uniq -d` | порожньо |
| `git ls-files node_modules dist build coverage` | порожньо |

## Повідомлення про помилку
- `FAIL: git-init — git не встановлено. Встановіть Git і повторіть.`
- `FAIL: git-init — у Git відстежуються генеровані файли: <список>. Виконайте вручну "git rm -r --cached <шлях>" після перевірки.`
  (Агент **не** виконує `git rm` сам.)

## Заборонено
`git commit`, `git push`, `git reset`, зміна віддалених репозиторіїв.
