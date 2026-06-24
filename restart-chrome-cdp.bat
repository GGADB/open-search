@echo off
REM 一键重启 Chrome（带 CDP 远程调试）
REM 保留你的登录态、扩展、书签

echo 正在关闭 Chrome...
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo 正在重启 Chrome（启用远程调试）...
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" ^
    --remote-debugging-port=9333 ^
    --remote-allow-origins=* ^
    --no-first-run ^
    "--user-data-dir=C:\Users\21731\AppData\Local\Google\Chrome\User Data"

echo Chrome 已重启，远程调试端口：9333
echo 你的登录态、扩展、书签全部保留
echo.
timeout /t 3 /nobreak >nul
curl -s http://127.0.0.1:9333/json/version >nul 2>&1 && echo 远程调试已就绪 || echo 启动中...
