---
name: opensearch
description: 开放搜索 — websearch失败时的备选搜索引擎，基于OpenCLI+BROWSER-HARNESS双引擎路由
allowed-tools: Bash(opencli:*), Bash(browser-harness:*), Bash(python:*), Bash(curl:*), Bash(taskkill:*), Bash(where:*), Bash(netstat:*), Read, Write, Edit, WebSearch
---

# 开放搜索 (OpenSearch)

## 触发条件

### 自动触发（作为websearch的备选）
当 WebSearch 工具返回空结果、报错、或搜索失败时，**自动启用开放搜索作为备选方案**。

### 手动触发
- **斜杠命令**：`/opensearch <搜索请求>`
  - 示例：`/opensearch 帮我去找一部有关友情的短视频`
- **自然语言**：`用开放搜索` 或 `开放搜索`
  - 示例：`用开放搜索来帮我去找一部有关友情的短视频`

## 首次调用检测（重要）

**每次调用此 skill 时，必须先执行以下检测：**

### 检测步骤

```bash
# 1. 检查 OpenCLI 是否安装
where opencli 2>nul
# 退出码0 = 已安装，非0 = 未安装

# 2. 检查 OpenCLI 扩展是否连接
opencli doctor 2>nul
# 看输出中 "Extension: connected" 还是 "Extension: not connected"
```

### 检测结果处理

**情况A：OpenCLI 未安装**
```
输出提醒：
"OpenCLI 未安装。当前使用 Browser Harness 模式，搜索功能正常。
如需安装 OpenCLI（获取更快的结构化搜索），请运行：
  npm install -g @jackwener/opencli
安装后在 Chrome/Edge 中加载扩展：chrome://extensions"
```

**情况B：OpenCLI 已安装但扩展未连接**
```
输出提醒：
"OpenCLI 扩展未连接。当前使用 Browser Harness 模式，搜索功能正常。
如需启用 OpenCLI 扩展（获取更快的结构化搜索），请：
  1. 打开浏览器，访问 chrome://extensions
  2. 找到 'OpenCLI' 扩展，确保已启用
  3. 如未安装，点击'加载已解压的扩展程序'，选择：
     {skill目录}/vendor/chrome-extension
完成后运行：opencli daemon restart"
```

**情况C：OpenCLI 已安装且扩展已连接**
```
正常执行，无需提醒
```

### 提醒规则

1. **首次调用时**：必须执行检测并输出对应提醒（情况A或B）
2. **后续调用时**：如已检测过且状态未变，不重复提醒
3. **提醒后继续执行**：无论 OpenCLI 状态如何，都继续执行搜索（Browser Harness 兜底）
4. **不要阻断流程**：提醒只是信息，不暂停执行

### 完整首次调用流程

```
用户：/opensearch 帮我搜索xxx
  │
  ├── 1. 执行环境检测（opencli doctor）
  │
  ├── 2. 如果扩展未连接 → 输出提醒（不阻断）
  │
  ├── 3. 继续执行搜索路由
  │   ├── OpenCLI 可用 → 用 OpenCLI
  │   └── OpenCLI 不可用 → 用 Browser Harness
  │
  └── 4. 返回搜索结果
```

## 浏览器兼容性

| 浏览器 | OpenCLI | Browser Harness | 状态 |
|--------|---------|-----------------|------|
| Chrome | ✅ 完整支持 | ✅ 支持 | 首选 |
| Edge | ⚠️ 需手动启用扩展 | ✅ 原生支持 | 完全可用 |
| 其他 Chromium | ⚠️ 未测试 | ✅ 可能可用 | 实验性 |

**只有 Edge 也能正常使用**：Browser Harness 原生支持 Edge，自动检测 Edge 路径和配置。

## 即装即用指南

### 首次使用（3步完成）

```
步骤1: 双击运行 check-and-install.bat
        → 自动检测浏览器（Chrome/Edge）
        → 自动安装 OpenCLI 和 Browser Harness
        → 自动生成启动脚本

步骤2: 双击运行 start-browser.bat
        → 启动浏览器并启用远程调试（CDP）

步骤3: 在 Claude Code 中使用
        /opensearch 搜索内容
        用开放搜索来搜索xxx
```

### 自动检测逻辑

```
check-and-install.bat 运行
  │
  ├── 检测 Chrome → 找到？→ 使用 Chrome
  │
  ├── 检测 Edge → 找到？→ 使用 Edge
  │
  └── 都没找到 → 提示安装浏览器
```

### Edge 用户特别说明

Edge 用户无需额外配置：
- Browser Harness **原生支持 Edge**，自动检测 `msedge.exe`
- OpenCLI 扩展**可能**在 Edge 中工作（Edge 是 Chromium 内核）
- 如果 OpenCLI 扩展不工作，自动回退到 Browser Harness 模式
- 两种模式都能正常搜索

## 双引擎路由策略

```
搜索请求
  │
  ├── 1. 解析请求，确定目标网站和关键词
  │
  ├── 2. OpenCLI 有该网站适配器？
  │   ├── 是 → 执行 opencli <site> search "<query>" -f json
  │   │   ├── 成功 → 返回结构化结果
  │   │   └── 失败 → 转步骤3
  │   └── 否 → 转步骤3
  │
  └── 3. Browser Harness 兜底
      └── 生成脚本，模拟浏览器操作搜索
```

## 执行流程

### 步骤1：检查环境

```bash
# 检查 CDP 连接（Chrome 或 Edge）
curl -s http://127.0.0.1:9333/json/version

# 检查 OpenCLI（可选）
where opencli 2>nul && opencli --version

# 检查 Browser Harness
where browser-harness 2>nul && browser-harness --version
```

如果环境未就绪：
1. 浏览器未运行 → 双击 `start-browser.bat`
2. OpenCLI 扩展未连接 → 不影响，Browser Harness 可独立工作
3. Browser Harness 未安装 → 运行 `check-and-install.bat`

### 步骤2：路由决策

解析用户请求，提取：
- **网站名**：从请求中识别
- **关键词**：搜索内容
- **排序方式**：如有指定

检查 OpenCLI 适配器：
```bash
opencli <site> --help
# 退出码0 = 有适配器
# 非0 = 无适配器，用 Browser Harness
```

### 步骤3A：OpenCLI 执行

```bash
opencli <site> search "<query>" --limit 10 -f json
```

### 步骤3B：Browser Harness 兜底

```bash
BU_CDP_PORT=9333 browser-harness <<'PY'
ensure_real_tab()
navigate("https://example.com/search?q=关键词")
wait(5)
text = js("document.body.innerText.substring(0, 5000)")
print(text)
PY
```

常用网站搜索URL：
| 网站 | URL模板 |
|------|---------|
| Google | `https://www.google.com/search?q={kw}` |
| Bing | `https://www.bing.com/search?q={kw}` |
| 百度 | `https://www.baidu.com/s?wd={kw}` |
| Bilibili | `https://search.bilibili.com/all?keyword={kw}` |
| YouTube | `https://www.youtube.com/results?search_query={kw}` |
| GitHub | `https://github.com/search?q={kw}` |
| 知乎 | `https://www.zhihu.com/search?type=content&q={kw}` |
| 小红书 | `https://www.xiaohongshu.com/search_result?keyword={kw}` |

### 步骤4：结果格式化

```
搜索结果 - <网站名>
查询：<关键词>
来源：<opencli|browser-harness>

1. <标题>
   <摘要/作者/日期>
   <链接>
```

## 网站识别规则

| 关键词 | 映射网站 |
|--------|----------|
| B站、bilibili、哔哩哔哩 | bilibili |
| YouTube、油管、yt | youtube |
| GitHub、gh、代码 | github |
| 知乎、zhihu | zhihu |
| 小红书、xhs | xiaohongshu |
| 淘宝、taobao | taobao |
| Google、谷歌 | google |
| 百度、baidu | baidu |
| 微博、weibo | weibo |
| 抖音、douyin | douyin |
| （无明确网站） | bilibili（视频类）/ google（其他） |

## 错误处理

```
OpenCLI 失败？
  → 自动回退到 Browser Harness

Browser Harness 也失败？
  → 检查浏览器是否运行
  → 检查 CDP 端口是否可达
  → 建议用户重启浏览器
```

## 示例

```
用户：/opensearch 帮我去找一部有关友情的短视频
→ 识别：视频类，无指定网站 → 默认 bilibili
→ 执行：opencli bilibili search "友情 短视频" --limit 10 -f json
→ 返回：结构化视频列表

用户：用开放搜索来搜一下淘宝上的机械键盘
→ 识别：电商，网站=淘宝
→ 执行：opencli taobao search "机械键盘" -f json
→ 返回：商品列表

用户：/opensearch 搜一下某个没适配器的网站
→ 无适配器 → browser-harness 兜底
```
