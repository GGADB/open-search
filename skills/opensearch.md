---
name: opensearch
description: 开放搜索 — websearch失败时的备选搜索引擎
---

# 开放搜索 Skill

## 触发方式

1. **自动触发**：WebSearch 返回空结果或失败时自动启用
2. **斜杠命令**：`/opensearch <搜索请求>`
3. **自然语言**：`用开放搜索` / `开放搜索`

## 首次调用检测

每次调用时先执行：
```bash
opencli doctor 2>nul
```
- `Extension: connected` → 正常使用双引擎
- `Extension: not connected` → 提示用户启用扩展，使用 Browser Harness 模式
- OpenCLI 未安装 → 提示安装命令，使用 Browser Harness 模式

**提醒后不阻断，继续执行搜索。**

## 路由策略

- **优先**：OpenCLI 适配器（155+网站，结构化数据）
- **兜底**：Browser Harness（任意网站，浏览器渲染）

## 快速参考

```bash
# OpenCLI 适配器搜索
opencli <site> search "关键词" --limit 10 -f json

# Browser Harness 兜底
BU_CDP_PORT=9333 browser-harness <<'PY'
ensure_real_tab()
navigate("https://site.com/search?q=关键词")
wait(5)
print(js("document.body.innerText.substring(0, 5000)"))
PY
```

详见主文件 `open-search/SKILL.md`
