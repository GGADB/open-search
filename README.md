# OpenSearch

给 Claude Code 加个搜索能力。

WebSearch 搜不到的时候，OpenSearch 自动顶上。支持 B站、YouTube、Google、GitHub、知乎、淘宝等 155+ 个网站。

## 用法

```
/opensearch 帮我找一部关于友情的短视频
用开放搜索来搜一下 Python 教程
/opensearch 搜一下淘宝上的机械键盘
```

不用手动配置环境。Agent 自动检测浏览器、自动装依赖、自动搜索。你只管提需求。

## 它怎么工作的

```
你输入搜索请求
  → Agent 自动检测环境
  → OpenCLI 有适配器？用 OpenCLI（快）
  → 没有？用 Browser Harness（通用）
  → 返回结果
```

两个引擎：

**OpenCLI** — 155+ 网站的专用适配器，直接调 API，速度快，返回结构化数据。B站、YouTube、Google、GitHub、知乎、淘宝、抖音、微博、小红书等等都有。

**Browser Harness** — 兜底方案，通过 CDP 控制浏览器渲染页面。没有适配器的网站也能搜。

OpenCLI 搜失败了会自动切到 Browser Harness。

## 浏览器

Chrome 和 Edge 都行，脚本自动检测。只有 Edge 也能正常用。

OpenCLI 扩展如果没连上，不影响搜索 — Browser Harness 能独立工作。连上的话速度更快。

## 首次使用

Agent 会自动处理依赖。缺什么装什么，不用操心。

手动装也行：

```bash
# OpenCLI（可选，需要 Node.js + npm）
npm install -g @jackwener/opencli

# Browser Harness（需要 Python 3.11+）
pip install browser-harness
```

## 前置条件

- Python 3.11+
- Chrome 或 Edge
- Node.js + npm（可选，装 OpenCLI 用的）

## 项目结构

```
open-search/
├── SKILL.md                    # Skill 定义（Agent 怎么执行）
├── skills/opensearch.md        # Skill 入口
├── check-and-install.bat/.sh   # 一键安装脚本
├── setup-environment.bat/.sh   # 环境配置
├── start.bat                   # 启动脚本
├── vendor/
│   └── chrome-extension/       # OpenCLI Chrome 扩展
├── references/                 # 路由规则、执行器规范
└── platform-guides/            # 平台兼容性指南
```

## 引用项目

本项目依赖以下开源项目：

- [OpenCLI](https://github.com/jackwener/opencli) — 把网站变成 CLI，155+ 网站适配器
- [Browser Harness](https://github.com/browser-use/browser-harness) — 最轻量的浏览器自动化工具，通过 CDP 控制真实浏览器

## 许可证

[Apache License 2.0](LICENSE)
