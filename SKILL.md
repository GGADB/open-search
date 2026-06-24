---
name: opensearch
description: 开放搜索 — websearch失败时的备选搜索引擎，基于OpenCLI+BROWSER-HARNESS双引擎路由
allowed-tools: Bash(opencli:*), Bash(browser-harness:*), Bash(python:*), Bash(curl:*), Bash(taskkill:*), Bash(where:*), Bash(netstat:*), Read, Write, Edit, WebSearch
---

# 开放搜索 (OpenSearch)

## 触发条件

### 自动触发
WebSearch 返回空结果、报错、或搜索失败时，自动启用。

### 手动触发
- `/opensearch <搜索请求>`
- 自然语言：`用开放搜索` / `开放搜索`

## 执行流程（Agent 全自动）

**用户只需输入搜索请求，Agent 自动完成所有步骤：**

```
用户：/opensearch 帮我搜一下秋明sweet的最新视频
  │
  ├── 1. 检测环境（自动）
  │   ├── 浏览器在跑吗？→ 没有就自动启动
  │   ├── CDP 通吗？→ 不通就等它起来
  │   ├── OpenCLI 装了吗？→ 没装就自动装
  │   └── Browser Harness 装了吗？→ 没装就自动装
  │
  ├── 2. 路由搜索（自动）
  │   ├── OpenCLI 有适配器？→ 用 OpenCLI
  │   └── 没有？→ 用 Browser Harness
  │
  └── 3. 返回结果
```

### 步骤1：连接用户已有浏览器

**核心原则：不启动新浏览器，连接用户已有的 Chrome/Edge（保留登录态和扩展）。**

```bash
# 1. 先检查 CDP 是否可用
curl -s http://127.0.0.1:9333/json/version
# 有响应 → 直接用，用户的登录态和扩展都在

# 2. 没响应 → 检查 DevToolsActivePort 文件
cat "%LOCALAPPDATA%\Google\Chrome\User Data\DevToolsActivePort" 2>/dev/null
# 读取端口号，尝试连接

# 3. 都不行 → Chrome 没有开启 CDP，需要引导用户重启
```

**当 CDP 不可用时，Agent 必须引导用户完成一次性设置：**

1. 告诉用户："需要重启 Chrome 才能使用搜索功能，这是一次性设置"
2. 让用户关闭 Chrome（包括系统托盘）
3. 让用户在终端执行以下命令：

```bash
# Windows Chrome:
! "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9333 --remote-allow-origins=* --user-data-dir="C:\Users\21731\AppData\Local\Google\Chrome\User Data"

# Windows Edge:
! "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --remote-debugging-port=9333 --remote-allow-origins=* --user-data-dir="C:\Users\21731\AppData\Local\Microsoft\Edge\User Data"
```

4. Chrome 打开后，Agent 自动连接（用户的登录态、扩展、书签全在）
5. **后续使用：** Chrome 保持运行即可，Agent 每次自动连接，不需要再重启

**为什么不能自动启动新实例？**
- Chrome 已经在运行时，新实例无法绑定 CDP 端口
- 新实例用 `--user-data-dir` 会创建空配置，丢失登录态
- 只有关闭 Chrome 后用用户默认配置重启，才能同时保留登录态 + 启用 CDP

# 2. OpenCLI 装了吗？
where opencli 2>nul
# 没装 → 自动装：
npm install -g @jackwener/opencli

# 3. Browser Harness 装了吗？
where browser-harness 2>nul
# 没装 → 自动装：
pip install browser-harness
```

### 步骤2：路由搜索

解析用户请求，提取网站和关键词：

| 用户说的 | 映射到 |
|----------|--------|
| B站、bilibili、哔哩哔哩 | bilibili |
| YouTube、油管 | youtube |
| 知乎、zhihu | zhihu |
| 小红书、xhs | xiaohongshu |
| 淘宝、taobao | taobao |
| 没指定网站 + 视频类 | bilibili |
| 没指定网站 + 其他 | google |

**路由决策：**

```bash
# 检查 OpenCLI 适配器
opencli <site> --help 2>nul
# 有适配器 → 用 OpenCLI（结构化数据，最快）
# 没有 → 用 Browser Harness
```

**OpenCLI 路径：**
```bash
opencli <site> search "<query>" --limit 10 -f json
```

**Browser Harness 路径：**
```bash
BU_CDP_PORT=9333 browser-harness <<'PY'
ensure_real_tab()
navigate("https://目标网站搜索URL")
wait(5)
print(js("document.body.innerText.substring(0, 5000)"))
PY
```

常用搜索URL：
| 网站 | URL |
|------|-----|
| Google | `https://www.google.com/search?q={kw}` |
| Bilibili | `https://search.bilibili.com/all?keyword={kw}` |
| YouTube | `https://www.youtube.com/results?search_query={kw}` |
| GitHub | `https://github.com/search?q={kw}` |
| 知乎 | `https://www.zhihu.com/search?type=content&q={kw}` |

### 步骤3：返回结果

```
搜索结果 - <网站>
来源: <opencli|browser-harness>

1. <标题>
   <信息>
   <链接>
```

## 首次调用检测

每次调用时执行 `opencli doctor` 检查扩展状态：
- **未连接** → 提示用户在 `chrome://extensions` 启用扩展
- **已连接** → 正常双引擎模式
- 提醒不阻断搜索，Browser Harness 可独立工作

## 错误处理

- OpenCLI 失败 → 自动回退 Browser Harness
- 浏览器没跑 → 自动启动
- 依赖没装 → 自动安装
- 全部失败 → 报告错误，建议检查网络
