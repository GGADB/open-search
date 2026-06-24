# OpenSearch - 开放搜索 Skill

> AI Agent 的通用网络搜索能力 — 支持 155+ 网站，Chrome/Edge 双浏览器兼容

OpenSearch 是一个 Claude Code skill，为 AI Agent 提供网页搜索能力。当内置的 WebSearch 工具搜索失败或返回空结果时，自动启用 OpenSearch 作为备选方案。

## 特性

- **双引擎路由**：OpenCLI（结构化数据） + Browser Harness（通用浏览器控制）
- **155+ 网站适配器**：Bilibili、YouTube、Google、GitHub、知乎、淘宝等
- **浏览器兼容**：支持 Chrome 和 Edge（Chromium 内核）
- **即装即用**：自动检测环境，一键安装依赖
- **智能降级**：OpenCLI 不可用时自动回退到 Browser Harness

## 快速开始

### 前置条件

| 依赖项 | 必需 | 说明 |
|--------|------|------|
| Chrome 或 Edge | ✅ | 脚本自动检测 |
| Python 3.11+ | ✅ | Browser Harness 需要 |
| Node.js + npm | ⚠️ 可选 | 仅 OpenCLI 需要 |

### 安装

**Windows：**
```bash
双击运行 check-and-install.bat
```

**macOS / Linux：**
```bash
chmod +x check-and-install.sh
./check-and-install.sh
```

脚本会自动：
1. 检测 Chrome 或 Edge 浏览器
2. 安装 OpenCLI（如有 npm）
3. 安装 Browser Harness（如有 pip）
4. 生成浏览器启动脚本

### 启动浏览器

安装完成后，双击 `start-browser.bat`（Windows）或运行 `./start-browser.sh`（macOS/Linux）。

### 使用方式

在 Claude Code 中：

```
# 斜杠命令
/opensearch 帮我去找一部有关友情的短视频

# 自然语言
用开放搜索来搜一下 Python 教程

# 指定网站
/opensearch 搜一下淘宝上的机械键盘
```

## 工作原理

```
用户搜索请求
  │
  ├── WebSearch 失败？→ 自动启用 OpenSearch
  │
  ├── OpenCLI 有该网站适配器？
  │   ├── 是 → opencli <site> search "关键词" -f json
  │   └── 否 → Browser Harness 兜底
  │
  └── 返回结构化搜索结果
```

### 引擎对比

| 引擎 | 优点 | 适用场景 |
|------|------|----------|
| OpenCLI | 直接调用 API，速度快，结构化数据 | 有适配器的 155+ 网站 |
| Browser Harness | 通用，支持任意网站 | 无适配器的网站 |

## 浏览器兼容性

| 浏览器 | OpenCLI | Browser Harness |
|--------|---------|-----------------|
| Chrome | ✅ 完整支持 | ✅ 支持 |
| Edge | ⚠️ 需手动启用扩展 | ✅ 原生支持 |

**只有 Edge 也能正常使用**：Browser Harness 原生支持 Edge，自动检测路径。

## 首次使用检测

每次调用 skill 时，会自动检测 OpenCLI 扩展状态：

- **未安装**：提示安装命令，使用 Browser Harness 模式
- **未连接**：提示启用扩展步骤，使用 Browser Harness 模式
- **已连接**：使用双引擎模式

提醒不阻断搜索流程，搜索功能始终可用。

## 项目结构

```
open-search/
├── SKILL.md                    # Skill 定义（Agent 执行逻辑）
├── skills/
│   └── opensearch.md           # Skill 入口
├── check-and-install.bat/.sh   # 一键安装脚本
├── setup-environment.bat/.sh   # 环境配置脚本
├── start.bat/.sh               # 启动脚本
├── vendor/
│   ├── chrome-extension/       # OpenCLI Chrome 扩展
│   └── OpenCLI/                # OpenCLI 源码
├── references/                 # 路由规则、执行器规范
├── platform-guides/            # 平台兼容性指南
├── README.md
├── LICENSE
└── .gitignore
```

## 支持的网站（部分）

| 类别 | 网站 |
|------|------|
| 视频 | Bilibili、YouTube、抖音 |
| 搜索 | Google、Bing、百度 |
| 代码 | GitHub、Gitee |
| 社交 | 知乎、微博、小红书 |
| 电商 | 淘宝、京东、亚马逊 |
| 新闻 | 36氪、今日头条 |
| 学术 | arXiv、Google Scholar |

完整列表：`opencli list`（需安装 OpenCLI）

## 故障排除

**浏览器未启动**
```bash
# 双击 start-browser.bat 或运行：
./start-browser.sh
```

**OpenCLI 扩展未连接**
```
1. 打开 chrome://extensions
2. 找到 OpenCLI 扩展，确保已启用
3. 运行：opencli daemon restart
```

**Browser Harness 连接失败**
```bash
browser-harness --doctor
```

## 许可证

[Apache License 2.0](LICENSE)

## 相关项目

- [OpenCLI](https://github.com/jackwener/opencli) - 155+ 网站的 CLI 适配器
- [Browser Harness](https://github.com/browser-use/browser-harness) - 浏览器自动化工具
