@echo off
REM 开放搜索 - 环境自动配置 (Windows)
REM 自动检测浏览器、启动远程调试、验证连接
REM 版本：2.0.0

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "CDP_PORT=9333"

REM ============================================
REM 检测浏览器
REM ============================================
set "BROWSER_PATH="
set "BROWSER_NAME="

REM Chrome
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "BROWSER_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
    set "BROWSER_NAME=Chrome"
    goto :browser_found
)
if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set "BROWSER_PATH=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    set "BROWSER_NAME=Chrome"
    goto :browser_found
)
if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    set "BROWSER_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
    set "BROWSER_NAME=Chrome"
    goto :browser_found
)

REM Edge
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER_PATH=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    set "BROWSER_NAME=Edge"
    goto :browser_found
)
if exist "C:\Program Files\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER_PATH=C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    set "BROWSER_NAME=Edge"
    goto :browser_found
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER_PATH=%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe"
    set "BROWSER_NAME=Edge"
    goto :browser_found
)

echo [X] 未检测到 Chrome 或 Edge
pause
exit /b 1

:browser_found
echo [OK] 浏览器: %BROWSER_NAME%

REM ============================================
REM 检查 CDP 是否已连接
REM ============================================
curl -s "http://127.0.0.1:%CDP_PORT%/json/version" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] CDP 已连接 (端口 %CDP_PORT%)
    goto :verify
)

REM ============================================
REM 启动浏览器
REM ============================================
echo [i] 启动 %BROWSER_NAME% 并启用远程调试...

if not exist "%USERPROFILE%\open-search-profile" mkdir "%USERPROFILE%\open-search-profile" >nul 2>&1

start "" /b "%BROWSER_PATH%" ^
    --user-data-dir="%USERPROFILE%\open-search-profile" ^
    --remote-debugging-port=%CDP_PORT% ^
    --remote-allow-origins=* ^
    --no-first-run

echo [i] 等待浏览器就绪...
set /a RETRY=0
:wait_loop
curl -s "http://127.0.0.1:%CDP_PORT%/json/version" >nul 2>&1
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
echo [OK] %BROWSER_NAME% 已启动 (CDP 端口 %CDP_PORT%)

:verify
echo.
echo ==========================================
echo 环境配置完成
echo ==========================================
echo.
echo 浏览器: %BROWSER_NAME%
echo CDP:    http://127.0.0.1:%CDP_PORT%
echo.
echo 可以使用:
echo   browser-harness --doctor
echo   opencli doctor
echo.

pause
