@echo off
REM 开放搜索 - 智能依赖检查和自动安装 (Windows)
REM 支持 Chrome 和 Edge 浏览器，自动检测并配置
REM 版本：3.0.0

setlocal enabledelayedexpansion

set "GREEN=[OK]"
set "YELLOW=[!]"
set "RED=[X]"
set "BLUE=[i]"

set "SCRIPT_DIR=%~dp0"
set "DEPENDENCIES_DIR=%SCRIPT_DIR%.dependencies"
set "LOCK_FILE=%DEPENDENCIES_DIR%\.installed"
set "LOG_FILE=%DEPENDENCIES_DIR%\install.log"

REM 检查是否已安装
if exist "%LOCK_FILE%" (
    echo %GREEN% 依赖已安装，跳过安装步骤
    goto :show_usage
)

echo.
echo ==========================================
echo 开放搜索 - 依赖检查和自动安装
echo ==========================================
echo.

REM ============================================
REM 步骤1：检测浏览器（Chrome 优先，Edge 兜底）
REM ============================================
echo [1/4] 检测浏览器...
echo.

set "BROWSER_PATH="
set "BROWSER_NAME="
set "BROWSER_TYPE="

REM 检测 Chrome
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    set "BROWSER_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
    set "BROWSER_NAME=Chrome"
    set "BROWSER_TYPE=chrome"
    goto :browser_found
)
if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
    set "BROWSER_PATH=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    set "BROWSER_NAME=Chrome"
    set "BROWSER_TYPE=chrome"
    goto :browser_found
)
if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
    set "BROWSER_PATH=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
    set "BROWSER_NAME=Chrome"
    set "BROWSER_TYPE=chrome"
    goto :browser_found
)

REM 检测 Edge（Chromium 内核，原生支持 CDP）
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER_PATH=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    set "BROWSER_NAME=Edge"
    set "BROWSER_TYPE=edge"
    goto :browser_found
)
if exist "C:\Program Files\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER_PATH=C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    set "BROWSER_NAME=Edge"
    set "BROWSER_TYPE=edge"
    goto :browser_found
)
if exist "%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER_PATH=%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe"
    set "BROWSER_NAME=Edge"
    set "BROWSER_TYPE=edge"
    goto :browser_found
)

REM 都没找到
echo %RED% 未检测到 Chrome 或 Edge 浏览器
echo.
echo 请安装以下任一浏览器：
echo   Chrome: https://www.google.com/chrome/
echo   Edge:   https://www.microsoft.com/edge
echo.
pause
exit /b 1

:browser_found
echo %GREEN% 检测到 %BROWSER_NAME%: !BROWSER_PATH!
echo.

REM ============================================
REM 步骤2：安装 OpenCLI（可选，失败不阻断）
REM ============================================
echo [2/4] 检查 OpenCLI...
echo.

set "OPENCLI_OK=0"
where opencli >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('opencli --version') do set "OPENCLI_VER=%%i"
    echo %GREEN% OpenCLI 已安装: !OPENCLI_VER!
    set "OPENCLI_OK=1"
) else (
    echo %BLUE% 尝试安装 OpenCLI...
    where npm >nul 2>&1
    if %errorlevel% equ 0 (
        call npm install -g @jackwener/opencli 2>nul
        if %errorlevel% equ 0 (
            echo %GREEN% OpenCLI 安装成功
            set "OPENCLI_OK=1"
        ) else (
            echo %YELLOW% OpenCLI 安装失败，将使用 Browser Harness 模式
        )
    ) else (
        echo %YELLOW% npm 未安装，跳过 OpenCLI（将使用 Browser Harness 模式）
        echo %BLUE% 如需 OpenCLI，请先安装 Node.js: https://nodejs.org/
    )
)

echo.

REM ============================================
REM 步骤3：安装 Browser Harness
REM ============================================
echo [3/4] 检查 Browser Harness...
echo.

set "BH_OK=0"
where browser-harness >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('browser-harness --version') do set "BH_VER=%%i"
    echo %GREEN% Browser Harness 已安装: !BH_VER!
    set "BH_OK=1"
) else (
    echo %BLUE% 安装 Browser Harness...
    where pip >nul 2>&1
    if %errorlevel% equ 0 (
        call pip install browser-harness 2>nul
        if %errorlevel% equ 0 (
            echo %GREEN% Browser Harness 安装成功
            set "BH_OK=1"
        ) else (
            echo %RED% Browser Harness 安装失败
        )
    ) else (
        echo %RED% pip 未安装，请先安装 Python 3.11+
        echo 访问: https://www.python.org/
    )
)

echo.

REM ============================================
REM 步骤4：生成启动脚本
REM ============================================
echo [4/4] 生成启动脚本...
echo.

REM 生成浏览器启动脚本（支持 CDP 远程调试）
if "%BROWSER_TYPE%"=="edge" (
    call :create_edge_start_script
) else (
    call :create_chrome_start_script
)

REM 标记安装完成
mkdir "%DEPENDENCIES_DIR%" 2>nul
echo %date% %time% > "%LOCK_FILE%"

REM ============================================
REM 安装完成
REM ============================================
echo.
echo ==========================================
echo 安装完成
echo ==========================================
echo.
echo 【检测结果】
echo   浏览器: %BROWSER_NAME%
if "%OPENCLI_OK%"=="1" (
    echo   OpenCLI: 已安装
) else (
    echo   OpenCLI: 未安装（可选）
)
if "%BH_OK%"=="1" (
    echo   Browser Harness: 已安装
) else (
    echo   Browser Harness: 未安装
)
echo.
echo 【使用方法】
echo.
echo   1. 双击运行: start-browser.bat
echo      （启动 %BROWSER_NAME% 并启用远程调试）
echo.
echo   2. 在 Claude Code 中使用:
echo      /opensearch 帮我搜索xxx
echo      用开放搜索来搜xxx
echo.
echo 【工作模式】
echo.
if "%OPENCLI_OK%"=="1" (
    echo   OpenCLI + Browser Harness 双引擎
    echo   OpenCLI 优先，失败时自动回退到 Browser Harness
) else (
    echo   Browser Harness 单引擎模式
    echo   直接通过 CDP 控制 %BROWSER_NAME% 进行搜索
)
echo.
echo ==========================================
echo.

pause
exit /b 0

REM ============================================
REM 函数：创建 Chrome 启动脚本
REM ============================================
:create_chrome_start_script
echo @echo off > "%SCRIPT_DIR%start-browser.bat"
echo REM 启动 Chrome 并启用远程调试 >> "%SCRIPT_DIR%start-browser.bat"
echo echo 启动 Chrome... >> "%SCRIPT_DIR%start-browser.bat"
echo start "Chrome" "%BROWSER_PATH%" --user-data-dir="%USERPROFILE%\open-search-chrome" --remote-debugging-port=9333 --remote-allow-origins=* --no-first-run >> "%SCRIPT_DIR%start-browser.bat"
if "%OPENCLI_OK%"=="1" (
    echo REM 加载 OpenCLI 扩展 >> "%SCRIPT_DIR%start-browser.bat"
    echo start "Chrome" "%BROWSER_PATH%" --user-data-dir="%USERPROFILE%\open-search-chrome" --remote-debugging-port=9333 --remote-allow-origins=* --no-first-run --load-extension="%SCRIPT_DIR%vendor\chrome-extension" >> "%SCRIPT_DIR%start-browser.bat"
)
echo echo 等待浏览器就绪... >> "%SCRIPT_DIR%start-browser.bat"
echo timeout /t 3 /nobreak ^>nul >> "%SCRIPT_DIR%start-browser.bat"
echo curl -s http://127.0.0.1:9333/json/version ^>nul 2^>^&1 ^&^& echo 浏览器已就绪 || echo 浏览器启动中，请稍候... >> "%SCRIPT_DIR%start-browser.bat"
echo pause >> "%SCRIPT_DIR%start-browser.bat"
echo %GREEN% 已创建: start-browser.bat
goto :eof

REM ============================================
REM 函数：创建 Edge 启动脚本
REM ============================================
:create_edge_start_script
echo @echo off > "%SCRIPT_DIR%start-browser.bat"
echo REM 启动 Edge 并启用远程调试 >> "%SCRIPT_DIR%start-browser.bat"
echo echo 启动 Edge... >> "%SCRIPT_DIR%start-browser.bat"
echo start "Edge" "%BROWSER_PATH%" --user-data-dir="%USERPROFILE%\open-search-edge" --remote-debugging-port=9333 --remote-allow-origins=* --no-first-run >> "%SCRIPT_DIR%start-browser.bat"
if "%OPENCLI_OK%"=="1" (
    echo REM 尝试加载 OpenCLI 扩展（Edge 兼容 Chromium 扩展） >> "%SCRIPT_DIR%start-browser.bat"
    echo start "Edge" "%BROWSER_PATH%" --user-data-dir="%USERPROFILE%\open-search-edge" --remote-debugging-port=9333 --remote-allow-origins=* --no-first-run --load-extension="%SCRIPT_DIR%vendor\chrome-extension" >> "%SCRIPT_DIR%start-browser.bat"
)
echo echo 等待浏览器就绪... >> "%SCRIPT_DIR%start-browser.bat"
echo timeout /t 3 /nobreak ^>nul >> "%SCRIPT_DIR%start-browser.bat"
echo curl -s http://127.0.0.1:9333/json/version ^>nul 2^>^&1 ^&^& echo 浏览器已就绪 || echo 浏览器启动中，请稍候... >> "%SCRIPT_DIR%start-browser.bat"
echo pause >> "%SCRIPT_DIR%start-browser.bat"
echo %GREEN% 已创建: start-browser.bat
goto :eof

REM ============================================
REM 显示用法（已安装时）
REM ============================================
:show_usage
echo.
echo 【使用方法】
echo   1. 双击运行: start-browser.bat
echo   2. 在 Claude Code 中: /opensearch 搜索内容
echo.
pause
exit /b 0
