#!/bin/bash
# 开放搜索 - 环境自动配置脚本
# 在skill启动时自动设置所有必需的环境变量
# 版本：1.0.0

set -e

# 获取脚本所在目录
if [ -n "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

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

# 设置Chrome路径
setup_chrome_path() {
  case $OS in
    "windows")
      # Windows Chrome路径
      if [ -f "/c/Program Files/Google/Chrome/Application/chrome.exe" ]; then
        export BU_CHROME_PATH="/c/Program Files/Google/Chrome/Application/chrome.exe"
      elif [ -f "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" ]; then
        export BU_CHROME_PATH="/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
      elif [ -f "$LOCALAPPDATA/Google/Chrome/Application/chrome.exe" ]; then
        export BU_CHROME_PATH="$LOCALAPPDATA/Google/Chrome/Application/chrome.exe"
      fi
      ;;
    "macos")
      # macOS Chrome路径
      if [ -d "/Applications/Google Chrome.app" ]; then
        export BU_CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      fi
      ;;
    "linux")
      # Linux Chrome路径
      if command -v google-chrome &> /dev/null; then
        export BU_CHROME_PATH=$(which google-chrome)
      elif command -v chromium-browser &> /dev/null; then
        export BU_CHROME_PATH=$(which chromium-browser)
      elif command -v chromium &> /dev/null; then
        export BU_CHROME_PATH=$(which chromium)
      fi
      ;;
  esac
}

# 设置Browser Harness配置
setup_browser_harness() {
  # 设置Chrome路径
  setup_chrome_path

  # 设置其他配置
  BU_CDP_PORT="${BU_CDP_PORT:-9222}"
  export BU_CDP_PORT
  export BU_LOG_LEVEL="${BU_LOG_LEVEL:-info}"

  # 输出配置信息
  echo "Browser Harness配置完成："
  echo "  Chrome路径: $BU_CHROME_PATH"
  echo "  CDP端口: $BU_CDP_PORT"
  echo "  日志级别: $BU_LOG_LEVEL"
}

# 启动Chrome并启用远程调试
start_chrome_with_debugging() {
  if [ -z "$BU_CHROME_PATH" ]; then
    echo "❌ Chrome路径未设置"
    return 1
  fi

  if [ ! -f "$BU_CHROME_PATH" ]; then
    echo "❌ Chrome路径不存在: $BU_CHROME_PATH"
    return 1
  fi

  if [ ! -d "$HOME/chrome-debug-profile" ]; then
    mkdir -p "$HOME/chrome-debug-profile"
  fi

  echo "启动Chrome并启用远程调试..."
  echo "Chrome路径: $BU_CHROME_PATH"

  "$BU_CHROME_PATH" \
    --remote-debugging-port=$BU_CDP_PORT \
    --user-data-dir="$HOME/chrome-debug-profile" \
    --remote-allow-origins="*" \
    --no-first-run \
    --disable-default-apps &
  local chrome_pid=$!
  export BU_CDP_URL="http://127.0.0.1:$BU_CDP_PORT"
  export OPENCLI_CDP_ENDPOINT="$BU_CDP_URL"
  export BH_CDP_URL="$BU_CDP_URL"

  echo "等待Chrome启动..."
  local retry=0
  while [ $retry -lt 15 ]; do
    if curl -s "http://localhost:$BU_CDP_PORT/json/version" > /dev/null 2>&1; then
      echo "✅ Chrome已启动并启用远程调试"
      echo "   远程调试地址: http://localhost:$BU_CDP_PORT"
      return 0
    fi
    retry=$((retry + 1))
    sleep 1
  done

  echo "❌ Chrome启动失败"
  return 1
}

# 验证Browser Harness连接
verify_browser_harness() {
  echo "验证Browser Harness连接..."

  # 检查Browser Harness是否已安装
  if ! command -v browser-harness &> /dev/null; then
    echo "❌ Browser Harness未安装"
    return 1
  fi

  # 检查Chrome是否正在运行
  if curl -s "http://localhost:$BU_CDP_PORT/json/version" > /dev/null 2>&1; then
    echo "✅ Chrome正在运行"
    echo "✅ Browser Harness可以连接"
    return 0
  else
    echo "❌ Chrome未运行或远程调试未启用"
    return 1
  fi
}

# 主函数
main() {
  echo "=========================================="
  echo "开放搜索 - 环境自动配置"
  echo "=========================================="
  echo ""

  # 设置环境变量
  setup_browser_harness

  echo ""

  # 检查Chrome是否已运行
  if curl -s "http://localhost:$BU_CDP_PORT/json/version" > /dev/null 2>&1; then
    echo "✅ Chrome已在运行"
    verify_browser_harness
  else
    echo "Chrome未运行，正在启动..."
    start_chrome_with_debugging
  fi

  echo ""
  echo "=========================================="
  echo "配置完成"
  echo "=========================================="
  echo ""
  echo "现在可以使用Browser Harness："
  echo "  browser-harness --doctor"
  echo ""
}

# 运行主函数
main "$@"
