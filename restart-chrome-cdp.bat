@echo off
REM 一键启动 OpenSearch 浏览器
REM 使用固定配置目录，保留登录态

echo 启动 OpenSearch 浏览器...

start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" ^
    --remote-debugging-port=9333 ^
    --remote-allow-origins=* ^
    --no-first-run ^
    "--user-data-dir=C:\Users\%USERNAME%\opensearch-profile"

echo 等待浏览器就绪...
timeout /t 3 /nobreak >nul
curl -s http://127.0.0.1:9333/json/version >nul 2>&1 && echo 浏览器已就绪（端口 9333） || echo 启动中...
echo.
echo 首次使用需要登录，之后会自动保留登录态
