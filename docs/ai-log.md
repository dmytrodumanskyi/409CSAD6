# Журнал взаємодії з AI

Заповнюйте під час роботи. Мінімум: кожен запуск команди, усі помилки та рішення.

| # | Дата/час | Інструмент | Запит (команда або prompt) | Ключова відповідь AI | Результат перевірки | Рішення |
|---|---|---|---|---|---|---|
| 1 | 09.11 | Claude | підготувати manifest, skills, commands для варіанту 6 | чернетки файлів `.github/` і `docs/` | переглянуто вручну | закомічено в `develop` |
| 2 | 09.11 | Copilot | «привіт» | відповідь, план Copilot Student активний | — | — |
| 3 | 10.11 | Copilot | введення `/` у чаті | є skills, немає commands з `.github/prompts/` | — | помилка 1 |
| 4 | 10.11 | Copilot (build-engineer) | виконати оркестратор `lab-init` | 62 кроки, усі кроки PASS | `ci.bat` → `== CI PASS`, Vitest 2/2 | Keep, окремі коміти |
| 5 | 10.11 | Copilot | skill `check` | `CHECK PASSED` 19/19 | — | — |
| 6 | 10.11 | Copilot | `check` після заміни `a + b` на `a - b` | FAIL C4, C5, причина і пропозиція виправлення | — | зміну відкочено |
| 7 | 10.11 | Claude | розібрати скасований job macOS | брак arm64 runners, заміна на `macos-15-intel` | новий запуск CI | помилка 2 |

## Помилки та виправлення
### Помилка 1: Copilot не бачить commands
- **Що сталося:** у Copilot Chat (VS Code, режим agent host) після введення `/` у списку були skills (`/github-actions`), але не було жодної command з `.github/prompts/` (`/create-project`, `/check`, `/init`).
- **Як виявлено:** ручна перевірка списку slash-команд перед запуском оркестратора.
- **Причина:** цей режим Copilot ігнорує prompt files (про це прямо сказано в налаштуванні «Chat › Customizations › Prompt Migration»), а `/init` зайнято вбудованою командою Copilot.
- **Виправлення через AI:** кожну command продубльовано у форматі skill `.github/skills/<command>/SKILL.md` з тим самим вмістом; оркестратор у цьому форматі названо `/lab-init`. Оновлено manifest, `/check` (пункти A3, A4), `docs/architecture.md`, `docs/usage.md`.
- **Повторна перевірка:** _(після оновлення — скріншот списку `/` з командами `/lab-init`, `/check`, `/create-project`)_

### Помилка 2: job macOS у GitHub Actions скасовано
- **Що сталося:** у запуску CI #1 jobs `ubuntu-latest` і `windows-latest` пройшли успішно, а `macos-latest` двічі (включно з Re-run failed jobs) отримав статус cancelled без жодного виконаного кроку.
- **Як виявлено:** вкладка Actions, анотація job: «The job was not acquired by Runner of type hosted even after multiple attempts», «Due to capacity constraints, jobs targeting macOS arm64 runners may experience longer queue times».
- **Причина:** брак потужностей macOS arm64 runners GitHub; з кодом проєкту не пов'язано.
- **Виправлення через AI (Claude):** у matrix `macos-latest` замінено на Intel-runner `macos-15-intel`; відповідно оновлено skills `github-actions`, `create-actions`, `check`, prompt files і manifest (гілка `develop`), `ci.yml` (гілка `feature/lab1-ts`).
- **Повторна перевірка:** новий запуск CI після push.

## Що перевірено вручну
- [ ] Переглянуто всі згенеровані файли
- [ ] Локально `npm test` — passed
- [ ] GitHub Actions — 3 зелені jobs
- [ ] Немає секретів і `node_modules/`, `dist/` у Git
