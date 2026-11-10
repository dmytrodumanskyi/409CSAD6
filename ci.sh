#!/usr/bin/env bash
set -euo pipefail

echo "== Node: $(node --version), npm: $(npm --version)"
if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi
npm run build
npm test
test -f dist/hello.js || { echo "FAIL: dist/hello.js not found"; exit 1; }
OUT="$(node dist/hello.js)"
echo "$OUT"
[ "$OUT" = "Hello, World!" ] || { echo "FAIL: unexpected output"; exit 1; }
echo "== CI PASS"
