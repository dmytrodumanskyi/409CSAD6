# Інструкція з використання

## Вимоги
- VS Code + розширення **GitHub Copilot** і **GitHub Copilot Chat** (студентський план).
- Git, Node.js 20 LTS або новіший, npm.
- У налаштуваннях VS Code увімкнено prompt files і agent skills:
  ```json
  "chat.promptFiles": true,
  "chat.useAgentSkills": true
  ```

## Запуск агента
1. Клонувати репозиторій і перейти в гілку `develop`:
   ```bash
   git clone https://github.com/<user>/<repo>.git
   cd <repo>
   git checkout develop
   git checkout -b feature/lab1-ts
   ```
2. Відкрити папку у VS Code → Copilot Chat → режим **Agent** → у списку агентів обрати **build-engineer**.
3. Ввести у чат:
   ```
   /init
   ```
4. Погоджувати запуск терміналу, коли Copilot просить дозвіл (`npm install`, `npm run build`, `npm test`).
5. Дочекатись таблиці `INIT COMPLETED`.

Окремі кроки можна запускати командами `/git-init`, `/create-project`, `/create-build`,
`/create-actions`, `/check`.

## Локальна перевірка (без агента)
Linux / macOS:
```bash
./ci.sh
```
Windows (cmd):
```bat
ci.bat
```
Або вручну:
```bash
npm ci
npm run build
npm start        # Hello, World!
npm test         # ✓ BasicAddition
```

## Фактично виконані команди

Під час запуску оркестратора були виконані:

```text
git --version
node --version
npm.cmd --version
git rev-parse --is-inside-work-tree
npm.cmd install
npm.cmd ci
npm.cmd run build
node dist\hello.js
npm.cmd test
ci.bat
```

## Демонстрація зламаної перевірки
1. У `src/math.ts` замінити `return a + b;` на `return a - b;`.
2. Запустити `/check` → пункт **C4** отримає `FAIL`, підсумок `CHECK FAILED`.
3. Повернути зміну (`git checkout -- src/math.ts`) і повторити `/check` → `CHECK PASSED`.

## Коміти (виконує користувач)
```bash
git add .github/agents && git commit -m "agent: build-engineer manifest"
git add .github/skills .github/prompts && git commit -m "agent: skills and commands"
git add src tests package.json package-lock.json tsconfig*.json vitest.config.ts ci.sh ci.bat .gitignore \
  && git commit -m "project: TypeScript hello world with Vitest"
git add .github/workflows && git commit -m "ci: GitHub Actions matrix"
git add README.md docs && git commit -m "docs: usage and architecture"
git push -u origin feature/lab1-ts
```
Потім створити pull request `feature/lab1-ts → develop` з назвою **lab1/finish**.
