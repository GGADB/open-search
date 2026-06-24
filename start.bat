@echo off
REM 开放搜索 - 启动脚本 (Windows)
REM 自动检测浏览器并启动
REM 版本：2.0.0

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"

echo.
echo ==========================================
echo 开放搜索 - 启动
echo ==========================================
echo.

REM 步骤1：检查依赖
echo [1/3] 检查依赖...
if exist "%SCRIPT_DIR%.dependencies\.installed" (
    echo [OK] 依赖已安装
) else (
    echo [!] 依赖未安装，开始安装...
    call "%SCRIPT_DIR%check-and-install.bat"
)

echo.

REM 步骤2：检测浏览器并启动
echo [2/3] 检测浏览器...

set "BROWSER_PATH="
set "BROWSER_NAME="

REM Chrome
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "BROWSER_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
    set "BROWSER_NAME=Chrome"
    goto :browser_ok
)
if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    set "BROWSER_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
    set "BROWSER_NAME=Chrome"
    goto :browser_ok
)

REM Edge
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER_PATH=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    set "BROWSER_NAME=Edge"
    goto :browser_ok
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER_PATH=%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe"
    set "BROWSER_NAME=Edge"
    goto :browser_ok
)

echo [X] 未检测到浏览器
pause
exit /b 1

:browser_ok
echo [OK] 浏览器: !BROWSER_NAME!

REM 检查是否已运行
curl -s "http://127.0.0.1:9333/json/version" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] 浏览器 CDP 已连接
    goto :step3
)

REM 启动浏览器
echo [i] 启动 !BROWSER_NAME!...
if not exist "%USERPROFILE%\open-search-profile" mkdir "%USERPROFILE%\open-search-profile" >nul 2>&1

start "" /b "!BROWSER_PATH!" ^
    --user-data-dir="%USERPROFILE%\open-search-profile" ^
    --remote-debugging-port=9333 ^
    --remote-allow-origins=* ^
    --no-first-run

echo [i] 等待浏览器就绪...
set /a RETRY=0
:wait_loop
curl -s "http://127.0.0.1:9333/json/version" >nul 2>&1
if %errorlevel% equ 0 goto :ready
set /a RETRY+=1
if !RETRY! geq 15 (
    echo [X] 浏览器启动超时
    pause
    exit /b 1
)
timeout /t 1 /nobreak >nul
goto :wait_loop

:ready
echo [OK] 浏览器已就绪

:step3
echo.

REM 步骤3：验证工具
echo [3/3] 验证工具...

where opencli >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] OpenCLI 可用
) else (
    echo [!] OpenCLI 不可用（将使用 Browser Harness 模式）
)

where browser-harness >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Browser Harness 可用
) else (
    echo [X] Browser Harness 不可用
)

echo.
echo ==========================================
echo 启动完成
echo ==========================================
echo.
echo 在你的 AI Agent 中使用：
echo   /opensearch 搜索内容
echo   用开放搜索来搜索xxx
echo.
echo ==========================================
echo.

pause
