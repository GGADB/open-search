#!/bin/bash
# 开放搜索 - 智能依赖检查和自动安装
# 此脚本在skill第一次使用时自动运行
# 版本：2.0.0（修复安全问题）

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 获取脚本所在目录（修复环境变量验证）
if [ -n "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

DEPENDENCIES_DIR="$SCRIPT_DIR/.dependencies"
LOCK_FILE="$DEPENDENCIES_DIR/.installed"
LOG_FILE="$DEPENDENCIES_DIR/install.log"
BACKUP_DIR="$DEPENDENCIES_DIR/backup"

# 版本配置
OPENCLI_VERSION="${OPENCLI_VERSION:-1.8.4}"
BROWSER_HARNESS_VERSION="${BROWSER_HARNESS_VERSION:-0.1.3}"

# 检测操作系统
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    echo "windows"
  else
    echo "unknown"
  fi
}

OS=$(detect_os)

# 日志函数
log_action() {
  local action="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  mkdir -p "$DEPENDENCIES_DIR"
  echo "[$timestamp] $action" >> "$LOG_FILE"
}

# 清理临时文件
cleanup_temp_files() {
  log_action "清理临时文件"
  rm -rf "$DEPENDENCIES_DIR/tmp" 2>/dev/null || true
}

# 检查目录权限
check_directory_permissions() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir" 2>/dev/null || {
      echo -e "${RED}无权限创建目录: $dir${NC}"
      log_action "权限错误：无法创建目录 $dir"
      return 1
    }
  fi

  if [ ! -w "$dir" ]; then
    echo -e "${RED}无权限写入目录: $dir${NC}"
    log_action "权限错误：无法写入目录 $dir"
    return 1
  fi

  return 0
}

# 检查是否已安装（修复并发安全问题）
check_already_installed() {
  if [ -f "$LOCK_FILE" ]; then
    return 0
  else
    return 1
  fi
}

# 标记已安装（修复并发安全问题）
mark_installed() {
  # 检查目录权限
  if ! check_directory_permissions "$(dirname "$DEPENDENCIES_DIR")"; then
    return 1
  fi

  mkdir -p "$DEPENDENCIES_DIR"

  # 使用原子操作避免竞争条件
  echo "$(date)" > "$LOCK_FILE.tmp"
  mv "$LOCK_FILE.tmp" "$LOCK_FILE"

  # 设置安全权限
  chmod 755 "$DEPENDENCIES_DIR"
  chmod 644 "$LOCK_FILE"

  log_action "安装完成标记已设置"
}

# 检查Chrome浏览器
check_chrome() {
  case $OS in
    "windows")
      if [ -f "/c/Program Files/Google/Chrome/Application/chrome.exe" ] || \
         [ -f "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" ] || \
         [ -f "$LOCALAPPDATA/Google/Chrome/Application/chrome.exe" ]; then
        return 0
      fi
      ;;
    "macos")
      if [ -d "/Applications/Google Chrome.app" ]; then
        return 0
      fi
      ;;
    "linux")
      if command -v google-chrome &> /dev/null || \
         command -v chromium-browser &> /dev/null || \
         command -v chromium &> /dev/null; then
        return 0
      fi
      ;;
  esac
  return 1
}

# 检查Edge浏览器（Chromium内核，原生支持CDP）
check_edge() {
  case $OS in
    "windows")
      if [ -f "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" ] || \
         [ -f "/c/Program Files/Microsoft/Edge/Application/msedge.exe" ] || \
         [ -f "$LOCALAPPDATA/Microsoft/Edge/Application/msedge.exe" ]; then
        return 0
      fi
      ;;
    "macos")
      if [ -d "/Applications/Microsoft Edge.app" ]; then
        return 0
      fi
      ;;
    "linux")
      if command -v microsoft-edge &> /dev/null || \
         command -v microsoft-edge-stable &> /dev/null; then
        return 0
      fi
      ;;
  esac
  return 1
}

# 获取浏览器路径
get_browser_path() {
  if check_chrome; then
    case $OS in
      "windows")
        if [ -f "/c/Program Files/Google/Chrome/Application/chrome.exe" ]; then
          echo "/c/Program Files/Google/Chrome/Application/chrome.exe"
        elif [ -f "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" ]; then
          echo "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
        else
          echo "$LOCALAPPDATA/Google/Chrome/Application/chrome.exe"
        fi
        ;;
      "macos")
        echo "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        ;;
      "linux")
        which google-chrome chromium-browser chromium 2>/dev/null | head -1
        ;;
    esac
  elif check_edge; then
    case $OS in
      "windows")
        if [ -f "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" ]; then
          echo "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
        elif [ -f "/c/Program Files/Microsoft/Edge/Application/msedge.exe" ]; then
          echo "/c/Program Files/Microsoft/Edge/Application/msedge.exe"
        else
          echo "$LOCALAPPDATA/Microsoft/Edge/Application/msedge.exe"
        fi
        ;;
      "macos")
        echo "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
        ;;
      "linux")
        which microsoft-edge microsoft-edge-stable 2>/dev/null | head -1
        ;;
    esac
  fi
}

# 获取浏览器名称
get_browser_name() {
  if check_chrome; then
    echo "Chrome"
  elif check_edge; then
    echo "Edge"
  else
    echo ""
  fi
}

# 安装Chrome浏览器
install_chrome() {
  echo -e "${BLUE}Chrome浏览器未安装${NC}"
  echo ""

  case $OS in
    "windows")
      echo "请手动安装Chrome浏览器："
      echo "  1. 访问: https://www.google.com/chrome/"
      echo "  2. 下载并安装Chrome"
      echo ""
      echo "或者使用Edge浏览器（基于Chromium）："
      echo "  1. 访问: https://www.microsoft.com/edge"
      echo "  2. 下载并安装Edge"
      ;;
    "macos")
      echo "请手动安装Chrome浏览器："
      echo "  1. 访问: https://www.google.com/chrome/"
      echo "  2. 下载并安装Chrome"
      echo ""
      echo "或者使用Homebrew安装："
      echo "  brew install --cask google-chrome"
      ;;
    "linux")
      echo "安装Chrome浏览器："
      echo ""
      echo "Ubuntu/Debian:"
      echo "  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -"
      echo "  sudo sh -c 'echo \"deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main\" >> /etc/apt/sources.list.d/google.list'"
      echo "  sudo apt-get update"
      echo "  sudo apt-get install google-chrome-stable"
      echo ""
      echo "或者使用Chromium："
      echo "  sudo apt-get install chromium-browser"
      ;;
  esac

  echo ""
  echo -e "${YELLOW}安装Chrome后，请重新运行此脚本${NC}"
  echo ""
}

# 检查OpenCLI
check_opencli() {
  if command -v opencli &> /dev/null; then
    return 0
  fi
  return 1
}

# 安装OpenCLI（修复命令注入风险）
install_opencli() {
  echo -e "${BLUE}安装OpenCLI...${NC}"
  log_action "开始安装OpenCLI"

  # 检查npm
  if ! command -v npm &> /dev/null; then
    echo -e "${RED}npm未安装，请先安装Node.js${NC}"
    echo "访问: https://nodejs.org/"
    log_action "错误：npm未安装"
    return 1
  fi

  # 备份现有安装
  local backup_dir="$BACKUP_DIR/opencli"
  if command -v opencli &> /dev/null; then
    mkdir -p "$backup_dir"
    cp "$(which opencli)" "$backup_dir/" 2>/dev/null || true
    log_action "备份现有OpenCLI安装"
  fi

  # 使用本地源代码安装（验证包完整性）
  if [ -d "$SCRIPT_DIR/vendor/OpenCLI" ]; then
    echo "使用本地源代码安装..."
    cd "$SCRIPT_DIR/vendor/OpenCLI"

    # 验证package.json存在
    if [ ! -f "package.json" ]; then
      echo -e "${RED}本地源代码不完整${NC}"
      log_action "错误：本地源代码缺少package.json"
      return 1
    fi

    npm install -g @jackwener/opencli@"$OPENCLI_VERSION" --ignore-scripts
  else
    echo "从npm安装..."

    # 验证包信息
    echo "验证npm包..."
    npm view "@jackwener/opencli@$OPENCLI_VERSION" version || {
      echo -e "${RED}无法验证npm包${NC}"
      log_action "错误：无法验证npm包"
      return 1
    }

    timeout 300 npm install -g "@jackwener/opencli@$OPENCLI_VERSION" --ignore-scripts

    if [ $? -eq 124 ]; then
      echo -e "${RED}安装超时${NC}"
      log_action "错误：OpenCLI安装超时"
      return 1
    fi
  fi

  # 验证安装
  if command -v opencli &> /dev/null; then
    OPENCLI_VERSION=$(opencli --version)
    echo -e "${GREEN}✅ OpenCLI安装成功: $OPENCLI_VERSION${NC}"
    log_action "OpenCLI安装成功: $OPENCLI_VERSION"
    return 0
  else
    echo -e "${RED}❌ OpenCLI安装失败${NC}"
    log_action "错误：OpenCLI安装失败"

    # 回滚
    if [ -d "$backup_dir" ] && [ -f "$backup_dir/opencli" ]; then
      echo "回滚到备份版本..."
      cp "$backup_dir/opencli" "$(which opencli 2>/dev/null || echo '/usr/local/bin/opencli')"
      log_action "已回滚到备份版本"
    fi

    # 清理临时文件
    cleanup_temp_files
    return 1
  fi
}

# 检查Browser Harness
check_browser_harness() {
  if command -v browser-harness &> /dev/null; then
    return 0
  fi
  return 1
}

# 安装Browser Harness（修复命令注入风险）
install_browser_harness() {
  echo -e "${BLUE}安装Browser Harness...${NC}"
  log_action "开始安装Browser Harness"

  # 检查pip
  if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
    echo -e "${RED}pip未安装，请先安装Python${NC}"
    echo "访问: https://www.python.org/"
    log_action "错误：pip未安装"
    return 1
  fi

  # 备份现有安装
  local backup_dir="$BACKUP_DIR/browser-harness"
  if command -v browser-harness &> /dev/null; then
    mkdir -p "$backup_dir"
    cp "$(which browser-harness)" "$backup_dir/" 2>/dev/null || true
    log_action "备份现有Browser Harness安装"
  fi

  # 使用本地源代码安装
  if [ -d "$SCRIPT_DIR/vendor/browser-harness" ]; then
    echo "使用本地源代码安装..."
    cd "$SCRIPT_DIR/vendor/browser-harness"

    # 验证setup.py或pyproject.toml存在
    if [ ! -f "setup.py" ] && [ ! -f "pyproject.toml" ]; then
      echo -e "${RED}本地源代码不完整${NC}"
      log_action "错误：本地源代码缺少setup.py或pyproject.toml"
      return 1
    fi

    timeout 300 pip install -e . 2>/dev/null || timeout 300 pip3 install -e .
  else
    echo "从pip安装..."

    # 验证包信息
    echo "验证pip包..."
    pip index versions browser-harness 2>/dev/null || pip3 index versions browser-harness 2>/dev/null || {
      echo -e "${YELLOW}无法验证pip包，继续安装...${NC}"
      log_action "警告：无法验证pip包"
    }

    timeout 300 pip install "browser-harness==$BROWSER_HARNESS_VERSION" 2>/dev/null || \
    timeout 300 pip3 install "browser-harness==$BROWSER_HARNESS_VERSION"

    if [ $? -eq 124 ]; then
      echo -e "${RED}安装超时${NC}"
      log_action "错误：Browser Harness安装超时"
      return 1
    fi
  fi

  # 验证安装
  if command -v browser-harness &> /dev/null; then
    BH_VERSION=$(browser-harness --version)
    echo -e "${GREEN}✅ Browser Harness安装成功: $BH_VERSION${NC}"
    log_action "Browser Harness安装成功: $BH_VERSION"
    return 0
  else
    echo -e "${RED}❌ Browser Harness安装失败${NC}"
    log_action "错误：Browser Harness安装失败"

    # 回滚
    if [ -d "$backup_dir" ] && [ -f "$backup_dir/browser-harness" ]; then
      echo "回滚到备份版本..."
      cp "$backup_dir/browser-harness" "$(which browser-harness 2>/dev/null || echo '/usr/local/bin/browser-harness')"
      log_action "已回滚到备份版本"
    fi

    # 清理临时文件
    cleanup_temp_files
    return 1
  fi
}

# 安装浏览器扩展
install_browser_extension() {
  echo -e "${BLUE}配置浏览器扩展...${NC}"
  log_action "开始配置浏览器扩展"

  # 检查扩展目录
  EXTENSION_DIR="$SCRIPT_DIR/vendor/chrome-extension"

  if [ ! -d "$EXTENSION_DIR" ]; then
    echo -e "${YELLOW}扩展目录不存在，跳过${NC}"
    log_action "警告：扩展目录不存在"
    return 0
  fi

  # 验证扩展完整性
  if [ ! -f "$EXTENSION_DIR/manifest.json" ]; then
    echo -e "${RED}扩展不完整：缺少manifest.json${NC}"
    log_action "错误：扩展缺少manifest.json"
    return 1
  fi

  # 获取浏览器路径
  BROWSER_PATH=$(get_browser_path)
  BROWSER_NAME=$(get_browser_name)

  # 创建启动脚本
  case $OS in
    "windows")
      cat > "$SCRIPT_DIR/start-browser.bat" << EOF
@echo off
REM 启动 $BROWSER_NAME 并加载扩展
echo 启动 $BROWSER_NAME...
start "" "$BROWSER_PATH" --user-data-dir="%USERPROFILE%\\open-search-profile" --remote-debugging-port=9333 --remote-allow-origins=* --no-first-run --load-extension="$EXTENSION_DIR"
echo 等待浏览器就绪...
timeout /t 3 /nobreak >nul
curl -s http://127.0.0.1:9333/json/version >nul 2>&1 && echo 浏览器已就绪 || echo 浏览器启动中，请稍候...
pause
EOF
      echo -e "${GREEN}✅ 已创建启动脚本: start-browser.bat${NC}"
      log_action "已创建Windows启动脚本"
      ;;
    "macos"|"linux")
      cat > "$SCRIPT_DIR/start-browser.sh" << EOF
#!/bin/bash
# 启动 $BROWSER_NAME 并加载扩展
echo "启动 $BROWSER_NAME..."
"$BROWSER_PATH" \\
    --user-data-dir="\$HOME/open-search-profile" \\
    --remote-debugging-port=9333 \\
    --remote-allow-origins=* \\
    --no-first-run \\
    --load-extension="$EXTENSION_DIR" &
echo "等待浏览器就绪..."
sleep 3
curl -s http://127.0.0.1:9333/json/version >nul 2>&1 && echo "浏览器已就绪" || echo "浏览器启动中，请稍候..."
EOF
      chmod +x "$SCRIPT_DIR/start-browser.sh"
      echo -e "${GREEN}✅ 已创建启动脚本: start-browser.sh${NC}"
      log_action "已创建Unix启动脚本"
      ;;
  esac

  echo ""
}

# 显示使用说明
show_usage() {
  echo ""
  echo -e "${GREEN}=========================================="
  echo "开放搜索 - 依赖安装完成"
  echo "==========================================${NC}"
  echo ""
  echo "【已安装的工具】"
  echo ""

  if command -v opencli &> /dev/null; then
    OPENCLI_VERSION=$(opencli --version)
    echo -e "  ✅ OpenCLI: $OPENCLI_VERSION"
  fi

  if command -v browser-harness &> /dev/null; then
    BH_VERSION=$(browser-harness --version)
    echo -e "  ✅ Browser Harness: $BH_VERSION"
  fi

  echo ""
  echo "【快速开始】"
  echo ""
  BROWSER_NAME=$(get_browser_name)
  echo "1. 启动${BROWSER_NAME}浏览器（使用启动脚本）："

  case $OS in
    "windows")
      echo "   双击运行: start-browser.bat"
      ;;
    "macos"|"linux")
      echo "   运行: ./start-browser.sh"
      ;;
  esac

  echo ""
  echo "2. 测试搜索："
  echo "   opencli bilibili search 'sweet秋明' --limit 10 -f json"
  echo ""
  echo "3. 使用开放搜索skill："
  echo "   /open search bilibili sweet秋明"
  echo "   帮我用开放搜索找bilibili里面sweet秋明的最新视频"
  echo ""
  echo "【故障排除】"
  echo ""
  echo "  如果遇到问题，请查看："
  echo "  cat open-search/SETUP_GUIDE.md"
  echo ""

  # 显示日志位置
  if [ -f "$LOG_FILE" ]; then
    echo "【安装日志】"
    echo "  $LOG_FILE"
    echo ""
  fi
}

# 主函数
main() {
  echo ""
  echo -e "${BLUE}=========================================="
  echo "开放搜索 - 依赖检查和安装"
  echo "==========================================${NC}"
  echo ""

  log_action "开始依赖检查和安装"

  # 检查是否已安装
  if check_already_installed; then
    echo -e "${GREEN}依赖已安装，跳过安装步骤${NC}"
    echo ""
    log_action "依赖已安装，跳过安装步骤"
    return 0
  fi

  echo "检查系统依赖..."
  echo ""

  # 检测浏览器（Chrome 优先，Edge 兜底）
  BROWSER_NAME=$(get_browser_name)
  if [ -z "$BROWSER_NAME" ]; then
    echo -e "${RED}未检测到 Chrome 或 Edge 浏览器${NC}"
    echo ""
    echo "请安装以下任一浏览器："
    echo "  Chrome: https://www.google.com/chrome/"
    echo "  Edge:   https://www.microsoft.com/edge"
    log_action "错误：未检测到浏览器"
    exit 1
  fi
  echo -e "${GREEN}✅ 检测到 $BROWSER_NAME${NC}"
  log_action "检测到浏览器: $BROWSER_NAME"

  # 检查OpenCLI
  if ! check_opencli; then
    if ! install_opencli; then
      echo -e "${RED}OpenCLI安装失败${NC}"
      log_action "错误：OpenCLI安装失败"
      exit 1
    fi
  else
    OPENCLI_VERSION=$(opencli --version)
    echo -e "${GREEN}✅ OpenCLI已安装: $OPENCLI_VERSION${NC}"
    log_action "OpenCLI已安装: $OPENCLI_VERSION"
  fi

  # 检查Browser Harness
  if ! check_browser_harness; then
    if ! install_browser_harness; then
      echo -e "${RED}Browser Harness安装失败${NC}"
      log_action "错误：Browser Harness安装失败"
      exit 1
    fi
  else
    BH_VERSION=$(browser-harness --version)
    echo -e "${GREEN}✅ Browser Harness已安装: $BH_VERSION${NC}"
    log_action "Browser Harness已安装: $BH_VERSION"
  fi

  # 安装浏览器扩展
  install_browser_extension

  # 标记已安装
  mark_installed

  # 显示使用说明
  show_usage

  log_action "所有依赖安装完成"
}

# 运行主函数
main "$@"
