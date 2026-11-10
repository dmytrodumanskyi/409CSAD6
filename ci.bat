@echo off
setlocal
echo == Node
node --version
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
