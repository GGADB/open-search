# OpenSearch

给 Claude Code 加个搜索能力。

WebSearch 搜不到的时候，OpenSearch 自动顶上。支持 B站、YouTube、Google、GitHub、知乎、淘宝等 155+ 个网站。

## 用法

```
/opensearch 帮我找一部关于友情的短视频
用开放搜索来搜一下 Python 教程
/opensearch 搜一下淘宝上的机械键盘
```

Agent 全自动处理 — 自动检测浏览器、自动装依赖、自动搜索。你只管提需求。

## 它怎么工作的

```
你输入搜索请求
  → Agent 自动检测环境
  → OpenCLI 有适配器？用 OpenCLI（快）
  → 没有？用 Browser Harness（通用）
  → 返回结果
```

两个引擎：
- **OpenCLI**：155+ 网站的专用适配器，直接调 API，速度快
- **Browser Harness**：兜底方案，控制浏览器渲染页面，啥都能搜

## 浏览器

Chrome 和 Edge 都行，脚本自动检测。只有 Edge 也能正常用。

## 首次使用

Agent 会自动检查依赖。如果缺什么会自己装，不用你操心。

手动装也行：

```bash
# 装 OpenCLI（可选，有 npm 就行）
npm install -g @jackwener/opencli

# 装 Browser Harness（需要 Python 3.11+）
pip install browser-harness
```

## 前置条件

- Python 3.11+
- Chrome 或 Edge
- Node.js + npm（可选，装 OpenCLI 用的）

## 许可证

[Apache License 2.0](LICENSE)
