# Cursor特定指南

## 概述

本指南说明如何在Cursor中安装和使用开放搜索skill。

## 安装

### 前置条件
1. Cursor已安装
2. Node.js >= 20
3. Python 3.12+
4. Chrome/Chromium浏览器

### 安装步骤

#### 步骤1：安装OpenCLI
```bash
npm install -g @jackwener/opencli
```

#### 步骤2：安装Browser Harness
```bash
pip install browser-harness
# 或
uv pip install browser-harness
```

#### 步骤3：安装Skill
按照Cursor的skill安装规范安装。

**方法1：手动安装**
```bash
# 复制skill文件到Cursor技能目录
cp -r open-search ~/.cursor/skills/
```

**方法2：使用Cursor CLI**
```bash
# 如果Cursor支持CLI安装
cursor skill add open-search
```

#### 步骤4：验证安装
```bash
# 检查OpenCLI
opencli --version

# 检查Browser Harness
browser-harness --version

# 检查skill
# 在Cursor中测试skill
```

## 使用方法

### 自动触发（默认）
当websearch工具返回为空或失效时，skill会自动激活。

**示例**：
```
用户：搜索一个极其冷门的话题
（websearch返回空结果）
（skill自动激活，使用开放搜索）
```

### 手动触发

#### 方式1：引用skill
```
/open search 帮我找一个视频
/open search bilibili 机器学习
/open search https://custom-site.com/search?q=test
```

#### 方式2：自然语言触发
```
帮我用开放搜索找一个视频
使用开放搜索搜索AI agent
用开放搜索在bilibili找机器学习视频
```

## 配置

### 环境变量
```bash
# OpenCLI配置
export OPENCLI_DAEMON_PORT=19825
export OPENCLI_BROWSER_CONNECT_TIMEOUT=30
export OPENCLI_BROWSER_COMMAND_TIMEOUT=60

# Browser Harness配置
export BH_DOMAIN_SKILLS=1
export BH_AGENT_WORKSPACE=~/.config/browser-harness/agent-workspace
```

### Cursor特定配置
```bash
# Cursor技能目录
~/.cursor/skills/

# Cursor配置文件
~/.cursor/config.json
```

## 常见问题

### 问题1：skill未识别
**症状**：skill无法被Cursor识别

**解决**：
1. 检查skill文件是否在正确目录
2. 检查skill文件格式是否正确
3. 重启Cursor
4. 查看Cursor文档了解skill安装规范

### 问题2：OpenCLI命令失败
**症状**：`opencli`命令报错

**解决**：
1. 检查OpenCLI安装：`opencli --version`
2. 检查浏览器连接：`opencli doctor`
3. 查看错误日志

### 问题3：Browser Harness连接失败
**症状**：`browser-harness`命令报错

**解决**：
1. 检查Browser Harness安装：`browser-harness --version`
2. 检查浏览器远程调试：`chrome://inspect/#remote-debugging`
3. 运行诊断：`browser-harness --doctor`

### 问题4：搜索结果为空
**症状**：搜索返回空结果

**解决**：
1. 检查搜索词是否正确
2. 检查网站是否可访问
3. 尝试其他搜索引擎

## Cursor特定功能

### 技能调用方式
Cursor可能使用不同的技能调用方式：

```bash
# 方法1：斜杠命令
/open search <query>

# 方法2：自然语言
使用开放搜索 <query>

# 方法3：Cursor特定语法
@skill open-search <query>
```

### 输出格式
Cursor可能对输出格式有特定要求：

```json
{
  "type": "search_result",
  "data": {
    "source": "opencli",
    "query": "机器学习",
    "results": [...]
  }
}
```

### 错误处理
Cursor可能有特定的错误处理方式：

```json
{
  "type": "error",
  "error": {
    "code": "ADAPTER_NOT_FOUND",
    "message": "OpenCLI适配器不存在"
  }
}
```

## 高级用法

### 自定义路由规则
```bash
# 编辑路由规则
vim ~/.cursor/skills/open-search/references/routing-rules.md
```

### 添加自定义适配器
```bash
# 创建自定义适配器
opencli browser init my-site/search

# 编辑适配器
vim ~/.opencli/clis/my-site/search.js
```

### 扩展Browser Harness
```bash
# 添加域技能
vim ~/.config/browser-harness/agent-workspace/domain-skills/my-site/search.py
```

## 调试

### 启用详细日志
```bash
# OpenCLI详细日志
opencli bilibili search "test" -f json -v

# Browser Harness详细日志
browser-harness --verbose

# Cursor日志
cursor --verbose
```

### 查看skill内容
```bash
# 查看skill文件
cat ~/.cursor/skills/open-search/SKILL.md

# 查看参考文件
ls ~/.cursor/skills/open-search/references/
```

### 测试路由逻辑
```bash
# 测试OpenCLI路径
/open search bilibili 机器学习

# 测试Browser Harness路径
/open search https://custom-site.com/search?q=test

# 测试websearch回退
搜索一个极其冷门的话题
```

## 最佳实践

### 1. 优先使用websearch
- 默认使用websearch工具
- 仅在websearch失败时使用开放搜索
- 避免不必要的开放搜索调用

### 2. 明确指定网站
- 使用`/open search <site> <query>`格式
- 明确指定网站可以提高路由准确性
- 避免模糊的搜索请求

### 3. 处理错误
- 检查错误代码和错误信息
- 根据错误类型采取相应措施
- 记录错误便于调试

### 4. 优化性能
- 使用合适的limit参数
- 避免频繁请求
- 使用缓存减少重复搜索

## Cursor兼容性

### 已知兼容性问题
1. **技能调用语法**：Cursor可能使用不同的语法
2. **输出格式**：Cursor可能对输出格式有特定要求
3. **错误处理**：Cursor可能有特定的错误处理方式

### 解决方案
1. **查阅Cursor文档**：了解skill安装和使用规范
2. **测试兼容性**：在Cursor中测试所有功能
3. **反馈问题**：向Cursor团队反馈兼容性问题

## 更新日志

### 版本1.0.0（2026-06-24）
- 初始版本
- 支持OpenCLI和Browser Harness
- 支持自动和手动触发
- 支持跨平台兼容

## 支持

如有问题或建议，请：
1. 查看本文档的常见问题部分
2. 在GitHub上提交Issue
3. 联系开发团队
4. 查阅Cursor文档

## 更新日期
2026-06-24
