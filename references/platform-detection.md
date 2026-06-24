# 平台检测规范

## 概述

开放搜索skill需要支持多个AI Agent平台（Claude Code、Codex、Cursor等）。本文档定义了平台检测和命令适配的规范。

## 平台检测方法

### 方法1：环境变量检测
```bash
# Claude Code
if [ -n "$CLAUDE_CODE_VERSION" ]; then
  PLATFORM="claude-code"
fi

# Codex
if [ -n "$CODEX_VERSION" ]; then
  PLATFORM="codex"
fi

# Cursor
if [ -n "$CURSOR_VERSION" ]; then
  PLATFORM="cursor"
fi
```

### 方法2：命令检测
```bash
# 检测可用的skill调用命令
if command -v claude &> /dev/null; then
  PLATFORM="claude-code"
elif command -v codex &> /dev/null; then
  PLATFORM="codex"
elif command -v cursor &> /dev/null; then
  PLATFORM="cursor"
else
  PLATFORM="unknown"
fi
```

### 方法3：配置文件检测
```bash
# 检测配置文件位置
if [ -d "$HOME/.claude" ]; then
  PLATFORM="claude-code"
elif [ -d "$HOME/.codex" ]; then
  PLATFORM="codex"
elif [ -d "$HOME/.cursor" ]; then
  PLATFORM="cursor"
else
  PLATFORM="unknown"
fi
```

## 平台特定适配

### Claude Code
**skill调用方式**：
```bash
# 斜杠命令
/open search <query>

# 自然语言
使用开放搜索 <query>
```

**配置目录**：
```bash
~/.claude/skills/open-search/
```

**工具调用**：
```bash
# Bash命令
Bash(opencli:*), Bash(browser-harness:*)
```

### Codex
**skill调用方式**：
```bash
# 斜杠命令（如果支持）
/open search <query>

# Codex特定语法
@skill open-search <query>

# 自然语言
使用开放搜索 <query>
```

**配置目录**：
```bash
~/.codex/skills/open-search/
```

**工具调用**：
```bash
# Codex特定工具调用方式
# 需要查阅Codex文档
```

### Cursor
**skill调用方式**：
```bash
# 斜杠命令（如果支持）
/open search <query>

# Cursor特定语法
@skill open-search <query>

# 自然语言
使用开放搜索 <query>
```

**配置目录**：
```bash
~/.cursor/skills/open-search/
```

**工具调用**：
```bash
# Cursor特定工具调用方式
# 需要查阅Cursor文档
```

## 命令适配规范

### POSIX兼容性
所有Shell命令必须遵循POSIX标准：

```bash
# ✅ 正确：POSIX兼容
if [ "$PLATFORM" = "claude-code" ]; then
  echo "Claude Code"
fi

# ❌ 错误：Bash特定语法
if [[ "$PLATFORM" == "claude-code" ]]; then
  echo "Claude Code"
fi
```

### 路径处理
使用相对路径或通用路径变量：

```bash
# ✅ 正确：使用相对路径
SKILL_DIR="./open-search"

# ✅ 正确：使用HOME变量
SKILL_DIR="$HOME/.claude/skills/open-search"

# ❌ 错误：硬编码绝对路径
SKILL_DIR="/Users/username/.claude/skills/open-search"
```

### 输出格式
统一使用JSON格式：

```bash
# ✅ 正确：标准JSON输出
echo '{"source":"opencli","query":"test","results":[]}'

# ❌ 错误：平台特定格式
# Claude Code可能期望特定格式
```

## 跨平台兼容性测试

### 测试矩阵
| 平台 | 斜杠命令 | 自然语言 | 工具调用 | 配置目录 |
|------|----------|----------|----------|----------|
| Claude Code | ✅ | ✅ | ✅ | ~/.claude/skills/ |
| Codex | ⚠️ | ✅ | ⚠️ | ~/.codex/skills/ |
| Cursor | ⚠️ | ✅ | ⚠️ | ~/.cursor/skills/ |

### 测试脚本
```bash
#!/bin/sh
# 跨平台兼容性测试脚本

# 检测平台
detect_platform() {
  if [ -n "$CLAUDE_CODE_VERSION" ]; then
    echo "claude-code"
  elif [ -n "$CODEX_VERSION" ]; then
    echo "codex"
  elif [ -n "$CURSOR_VERSION" ]; then
    echo "cursor"
  else
    echo "unknown"
  fi
}

# 测试平台检测
PLATFORM=$(detect_platform)
echo "当前平台: $PLATFORM"

# 测试POSIX兼容性
if [ "$PLATFORM" != "unknown" ]; then
  echo "平台检测成功"
else
  echo "平台检测失败"
fi
```

## 错误处理

### 平台不支持
```json
{
  "error": {
    "code": "PLATFORM_NOT_SUPPORTED",
    "message": "当前平台不支持",
    "details": {
      "platform": "unknown",
      "suggestion": "请使用Claude Code、Codex或Cursor"
    }
  }
}
```

### 命令执行失败
```json
{
  "error": {
    "code": "COMMAND_EXECUTION_FAILED",
    "message": "命令执行失败",
    "details": {
      "command": "opencli bilibili search test",
      "exit_code": 1,
      "stderr": "错误信息"
    }
  }
}
```

## 最佳实践

### 1. 优先使用自然语言触发
- 兼容所有平台
- 用户体验更好
- 无需记忆特定语法

### 2. 使用POSIX兼容命令
- 确保跨平台兼容性
- 避免平台特定语法
- 使用标准Shell命令

### 3. 统一输出格式
- 使用标准JSON格式
- 包含完整错误信息
- 便于后续处理

### 4. 提供回退机制
- 平台检测失败时的处理
- 命令执行失败时的回退
- 用户友好的错误提示

## 更新日期
2026-06-24
